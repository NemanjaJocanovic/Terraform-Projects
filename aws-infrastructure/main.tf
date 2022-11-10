# ... root/main.tf ...

module "networking" {
  source           = "./networking"
  vpc_cidr         = local.vpc_cidr
  access_ip        = var.access_ip
  security_groups  = local.security_groups
  public_sn_count  = 2
  private_sn_count = 3
  max_subnets      = 20
  public_cidrs     = [for i in range(2, 255, 2) : cidrsubnet(local.vpc_cidr, 8, i)]
  private_cidrs    = [for i in range(1, 255, 2) : cidrsubnet(local.vpc_cidr, 8, i)]
  db_subnet_group  = true

}

module "database" {
  source                 = "./database"
  db_storage             = 10
  db_engine_version      = "5.7"
  db_instance_class      = "db.t3.micro"
  db_name                = var.dbname
  dbuser                 = var.dbuser
  dbpassword             = var.dbpassword
  db_identifier          = "n-db"
  skip_db_snapshot       = true
  db_subnet_gruop_name   = module.networking.rds_sng_name[0]
  vpc_security_group_ids = module.networking.rds_sg

}

module "loadbalancing" {
  source                 = "./loadbalancing"
  public_subnets         = module.networking.public_subnets
  public_sg              = module.networking.public_sg
  tg_port                = 8000
  tg_protocol            = "HTTP"
  vpc_id                 = module.networking.vpc_id
  lb_healthy_threshold   = 2
  lb_unhealthy_threshold = 2
  lb_timeout             = 3
  lb_interval            = 30
  listener_port          = 80
  listener_protocol      = "HTTP"
}

module "compute" {
  source           = "./compute"
  instance_count   = 1
  instance_type    = "t3.micro"
  public_sg        = module.networking.public_sg
  public_subnet    = module.networking.public_subnets
  vol_size         = 9
  key_name         = "ssh-key"
  public_key_path  = "/home/ubuntu/.ssh/keynem.pub"
  user_data_pth    = "${path.root}/userdata.tpl"
  dbuser           = var.dbuser
  dbpassword       = var.dbpassword
  dbname           = var.dbname
  db_endpoint      = module.database.db_endpoint
  target_group_arn = module.loadbalancing.target_group_arn
  tg_attach_port   = 8000
  private_key_path = var.private_key_path
}