terraform {
  backend "s3" {
    bucket = "deepaks"
    key    = "backend/ToDo-App.tfstate"
    region = "us-west-2"
  }
}