# ... root/variables.tf ...

variable "aws_region" {
  default = "eu-north-1"
}

variable "access_ip" {
  type = string
}

# ... db variables ...

variable "dbname" {
  type = string
}

variable "dbuser" {
  type      = string
  sensitive = true
}

variable "dbpassword" {
  type      = string
  sensitive = true
}

variable "private_key_path" {}