provider "aws" {
  shared_credentials_files = ["$HOME/.aws/credentials"]
  region                   = "us-east-1"
}
