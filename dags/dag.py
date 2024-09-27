from airflow import DAG
from datetime import datetime, timedelta
import requests
import pandas as pd
from bs4 import BeautifulSoup
from airflow.providers.postgres.hooks.postgres import PostgresHook
from airflow.operators.python import PythonOperator
from airflow.providers.postgres.operators.postgres import PostgresOperator
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator

headers = {
    "Referer": "https://www.amazon.com/",
    "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/600.2.5 (KHTML\, like Gecko) Version/8.0.2 Safari/600.2.5 (Amazonbot/0.1; +https://developer.amazon.com/support/amazonbot)",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
    "Accept-Language": "en-US,en;q=0.5"
}


def fetch_books(num_books, **kwargs):
    base_url = "https://www.amazon.com/s?k=data+engineering+books"
    books = []
    seen_titles = set()

    postgres_hook = PostgresHook(postgres_conn_id='books_connection')

    # Check if the 'books' table exists in the database
    check_table_query = """
    SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'books'
    );
    """
    table_exists = postgres_hook.get_first(check_table_query)[0]

    existing_titles = set()
    if table_exists:
        # If table exists, retrieve existing titles
        existing_books_query = "SELECT title FROM books"
        existing_books = postgres_hook.get_records(existing_books_query)
        existing_titles = {book[0] for book in existing_books}  # Set of existing titles

    page = 1

    while len(books) < num_books:
        url = f"{base_url}&page={page}"
        response = requests.get(url, headers=headers)
        if response.status_code == 200: 
            soup = BeautifulSoup(response.text, 'html.parser')
            book_divs = soup.find_all('div', class_='s-result-item')

            for book in book_divs:
                title = book.find('span', class_='a-text-normal')
                author = book.find('a', class_='a-size-base')
                price = book.find('span', class_='a-offscreen')
                rating = book.find('span', class_='a-icon-alt')

                if title and author and price and rating:
                    book_title = title.text.strip()
                    if book_title not in existing_titles and book_title not in seen_titles:
                        seen_titles.add(book_title)
                        books.append({
                            'Title': book_title,
                            'Author': author.text.strip(),
                            'Price': price.text.lstrip("$"),
                            'Rating': rating.text.strip()
                        })
            page += 1
        else:
            print("Failed to retrieve the page")
            break

    books = books[:num_books]

    df = pd.DataFrame(books)
    df.drop_duplicates(subset='Title', inplace=True)

    kwargs['ti'].xcom_push(key='book_data', value=df.to_dict('records'))

    
def insert_book_to_postgres(**kwargs):
    books = kwargs['ti'].xcom_pull(task_ids='fetch_books', key='book_data')
    if not books:
        raise ValueError('No book data found')
    
    #postgres_hook = PostgresHook(postgres_conn_id='airflow_db')
    postgres_hook = PostgresHook(postgres_conn_id='books_connection')
    query = """
    INSERT INTO books (title, author, price, rating) 
    values (%s, %s, %s, %s)
    """
    for book in books:
        postgres_hook.run(query, parameters=(book['Title'], book['Author'], book['Price'], book['Rating']))

    
            
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2024, 9, 23),
    'retries': 1,
    'retry_delay': timedelta(minutes=5)
}

dag = DAG(
    'fetch_and_store_amazon_books',
    default_args=default_args,
    description='Fetch and store Amazon books and store it to Postgres',
    schedule_interval=timedelta(days=1)
)


fetch_books_task = PythonOperator(
    task_id='fetch_books',
    python_callable=fetch_books,
    op_args=[10],
    provide_context=True,
    dag=dag
)

insert_book_to_postgres_task = PythonOperator(
    task_id='insert_book_to_postgres',
    python_callable=insert_book_to_postgres,
    provide_context=True,
    dag=dag
)


create_table_task = SQLExecuteQueryOperator(
    task_id='create_table',
    sql='''CREATE TABLE IF NOT EXISTS books (
        id SERIAL PRIMARY KEY,
        title VARCHAR NOT NULL,
        author VARCHAR NOT NULL,
        price VARCHAR NOT NULL,
        rating VARCHAR NOT NULL
    )''',
    conn_id='books_connection',
    database='amazon_books',
    dag=dag
)


fetch_books_task >> create_table_task >> insert_book_to_postgres_task


        

