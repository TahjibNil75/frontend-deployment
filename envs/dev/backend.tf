terraform {
  backend "s3" {
    bucket         = "heygen-roleplay-bot-tf"
    key            = "terraform.tfstate"
    region         = "ap-south-1"
    profile        = "mlbd-tahjib"
  }
}
