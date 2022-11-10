# ... compute/main.tf ...

data "aws_ami" "server_ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "random_id" "n_node_id" {
  byte_length = 2
  count       = var.instance_count
  keepers = {
    key_name = var.key_name
  }
}

resource "aws_key_pair" "n_auth" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

resource "aws_instance" "n_instance" {
  count         = var.instance_count
  ami           = data.aws_ami.server_ami.id
  instance_type = var.instance_type

  tags = {
    Name = "n-node-${random_id.n_node_id[count.index].dec}"
  }
  key_name               = aws_key_pair.n_auth.id
  vpc_security_group_ids = [var.public_sg]
  subnet_id              = var.public_subnet[count.index]
  user_data = templatefile(var.user_data_pth,
    {
      nodename    = "n-node-${random_id.n_node_id[count.index].dec}"
      db_endpoint = var.db_endpoint
      dbuser      = var.dbuser
      dbpass      = var.dbpassword
      dbname      = var.dbname
  })
  root_block_device {
    volume_size = var.vol_size
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.public_ip
      private_key = file(var.private_key_path)
    }
    script = "${path.root}/delay.sh"
  }
  provisioner "local-exec" {
    command = templatefile("${path.cwd}/scp_script.tpl",
      {
        nodeip           = self.public_ip
        k3s_path         = "${path.cwd}/../"
        nodename         = self.tags.Name
        private_key_path = var.private_key_path
      }
    )
  }
  provisioner "local-exec" {
    when    = destroy
    command = "rm -f ${path.cwd}/../k3-${self.tags.Name}.yaml"
  }

}

resource "aws_lb_target_group_attachment" "n_tg_attach" {
  count            = var.instance_count
  target_group_arn = var.target_group_arn
  target_id        = aws_instance.n_instance[count.index].id
  port             = var.tg_attach_port
}