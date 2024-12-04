module "web" {
  source = "../../modules/web"
  
  env      = var.env
  app_name = var.app_name
  region = var.region
}


