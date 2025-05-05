
module "dns" {
  source        = "./modules/dns"
  domain_ip = module.web_lb.web_lb_ip
}

module "sql" {
  source = "./modules/sql"
}

module "app_template" {
  source      = "./modules/template"
  region      = var.region
  network     = var.network
  name_prefix = "app"
  startup_script = templatefile("${path.module}/modules/template/script/startup_app.sh", {
    db_host     = module.sql.db_host,
    db_user     = module.sql.db_user,
    db_password = module.sql.db_password,
    db_name     = module.sql.db_name
  })
  depends_on = [module.sql]
}

module "app_mig" {
  source               = "./modules/mig"
  name_prefix          = "app"
  instance_template_id = module.app_template.instance_template_id
  region               = var.region
  depends_on           = [module.app_template]
}

module "app_lb" {
  source             = "./modules/app_lb"
  name_prefix        = "app"
  instance_group_app = module.app_mig.instance_group
  region             = var.region
  network            = var.network
  subnetwork         = var.subnetwork
  depends_on         = [module.app_mig]
}

////////////////////////////////////////////////////////////

module "web_template" {
  source      = "./modules/template"
  region      = var.region
  network     = var.network
  name_prefix = "web"
  startup_script = templatefile("${path.module}/modules/template/script/startup_web.sh", {
    lb_app_ip     = module.app_lb.app_lb_ip
  })
  depends_on = [module.app_lb]
}

module "web_mig" {
  source               = "./modules/mig"
  name_prefix          = "web"
  instance_template_id = module.web_template.instance_template_id
  region             = var.region
  depends_on         = [module.web_template]
}

module "web_lb" {
  source             = "./modules/web_lb"
  name_prefix        = "web"
  instance_group_web = module.web_mig.instance_group
  region             = var.region
  network            = var.network
  subnetwork         = var.subnetwork
  depends_on         = [module.web_mig]
}

