terraform {
  backend "s3" {
    bucket         = "bookystuff-terraform-state"
    key            = "terraform.tfstate"
    region         = "ap-southeast-2"
  }
}