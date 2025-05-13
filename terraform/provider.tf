# AWS Provider Configuration
provider "aws" {
  # Using environment variables directly:
  # AWS_ACCESS_KEY_ID
  # AWS_SECRET_ACCESS_KEY
  # AWS_DEFAULT_REGION
  skip_credentials_validation = true
  skip_metadata_api_check = true
}

