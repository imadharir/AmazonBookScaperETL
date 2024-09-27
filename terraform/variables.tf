variable "project_id" {
  type        = string
  description = "The google cloud project id"
}

variable "region" {
  type        = string
  description = "The google cloud region"
  default     = "us-central1"
}

variable "postgres_username" {
  type        = string
  description = "The username for the postgres database"
}

variable "postgres_password" {
  type        = string
  description = "The password for the postgres database"
}

variable "postgres_root_password" {
  type        = string
  description = "The root password for the postgres database"
}