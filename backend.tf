terraform {
  backend "s3" {
    bucket       = "your bucket name" # can be global or regional based
    key          = "env/dev/terraform.tfstate"
    region       = "your-region"
    use_lockfile = true
    encrypt      = true
  }
}