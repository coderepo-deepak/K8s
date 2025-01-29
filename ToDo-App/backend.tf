terraform {
  backend "s3" {
    bucket = "deepaks"
    key    = "backend/ToDo-App.tfstate"
    region = "us-east-1"
  }
}