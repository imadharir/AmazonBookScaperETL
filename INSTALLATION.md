# Installation Guide
> **Note:** This setup guide is intended for Windows users. If you're using a different operating system, please refer to the official documentation for installation instructions specific to your platform.
## Prerequisites

Before starting the project setup, ensure you have the following tools and accounts configured:

1. **Google Cloud Platform (GCP) Account**  
   - A GCP account is required to create and manage cloud resources. If you don't have an account, create one at [cloud.google.com](https://cloud.google.com).

2. **Google Cloud Project**  
   - Create a new GCP project or use an existing one. Make a note of the project ID, as it will be used throughout the setup.

3. **Install Terraform**  
   - Download and install Terraform from [terraform.io](https://www.terraform.io/downloads.html).  
   - Verify the installation by running:
     ```bash
     terraform -v
     ```
   
4. **Install Google Cloud SDK (`gcloud`)**  
   - Install the Google Cloud SDK by following the instructions [here](https://cloud.google.com/sdk/docs/install).  
   - Initialize `gcloud` and set the default project:
     ```bash
     gcloud init
     gcloud config set project <YOUR_PROJECT_ID>
     ```
   
5. **Enable Required APIs**  
   - Ensure the following APIs are enabled in your GCP project:
     - Compute Engine API
     - Cloud Composer API
     - Cloud SQL Admin API
     - Identity and Access Management (IAM) API
     - Cloud Storage API
   - Enable them using the `gcloud` command:
     ```bash
     gcloud services enable compute.googleapis.com \
                            composer.googleapis.com \
                            sqladmin.googleapis.com \
                            iam.googleapis.com \
                            storage.googleapis.com
     ```

## Step 1: Set Up Service Account

1. **Create a Service Account**  
   - Go to the [IAM & Admin Console](https://console.cloud.google.com/iam-admin/serviceaccounts) and create a new service account with the following details:
     - **Name**: `terraform-admin`
     - **Role**: `Owner`, `roles/roleAdmin`, `roles/iam.securityAdmin`

2. **Generate a JSON Key**  
   - After creating the service account, generate a JSON key and download it.  
   - Store the JSON key in a secure location, as it will be used by Terraform to authenticate with GCP.

3. **Set Environment Variable for Authentication**  
   - Set the `GOOGLE_APPLICATION_CREDENTIALS` environment variable to the path of your service account key file:
     ```bash
     export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account-key.json"
     ```

## Step 2: Clone the Repository and Configure Terraform

1. **Clone the Project Repository**  
   - Clone the repository containing the Terraform configurations and DAGs:
     ```bash
     git clone https://github.com/imadharir/AmazonBookScaperETL.git
     cd AmazonBookScaperETL
     ```

2. **Update `terraform.tfvars`**  
   - Create or edit a `terraform.tfvars` file in the root directory with your project-specific values:
     ```hcl
     project_id = "<YOUR_PROJECT_ID>"
     region     = "us-central1"
     credentials_file = "/path/to/service-account-key.json"
     ```
   
3. **Initialize and Validate Terraform Configuration**  
   - Initialize the Terraform workspace:
     ```bash
     terraform init
     ```
   - Validate the configuration to ensure everything is set up correctly:
     ```bash
     terraform validate
     ```

## Step 3: Deploy the Infrastructure

1. **Deploy the Resources**  
   - Deploy the infrastructure using Terraform:
     ```bash
     terraform apply
     ```
   - Review the plan and confirm by typing `yes`.

2. **Verify the Deployment**  
   - Check the GCP console to ensure that all the resources (e.g., Cloud Composer environment, Cloud SQL instance, VPC, etc.) have been created successfully.

## Step 4: Cloud Composer Configuration

1. **Configure Airflow Connections**  
   - If you didn't create the Airflow connections using Terraform, go to the [Cloud Composer UI](https://console.cloud.google.com/composer/environments) and configure the necessary connections:
     - **Postgres Connection**:
       - **Conn Id**: `books_connection`
       - **Conn Type**: `Postgres`
       - **Host**: `<Your Cloud SQL Internal IP>`
       - **Schema**: `amazon_books`
       - **Login**: `postgres`
       - **Password**: `<Your Password>`
       - **Port**: `5432`
   
2. **Upload DAG Files**  
   - Upload the DAG file(s) to the `dags` folder in the Cloud Composer bucket:
     ```bash
     gsutil cp /local/path/to/dag.py gs://<COMPOSER_BUCKET_NAME>/dags/
     ```
## Step 5: Monitoring and Logs

**Monitor the DAG Runs**  
   - Navigate to the [Airflow UI](https://console.cloud.google.com/composer/environments) and monitor your DAG runs.

## Step 6: Clean Up Resources

To avoid incurring charges for unused resources, remember to delete the GCP project or individual resources when the project is no longer needed:

```bash
terraform destroy
```
