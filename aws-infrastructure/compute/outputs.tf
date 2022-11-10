# ... compute/outputs.tf ...

output "instance" {
  value     = aws_instance.n_instance[*]
  sensitive = true
}

output "instance_port" {
  value = aws_lb_target_group_attachment.n_tg_attach[0].port
}