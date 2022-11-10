# ... loadbalancing/outputs.tf ... 

output "target_group_arn" {
  value = aws_lb_target_group.n_tg.arn
}

output "lb_endpoint" {
  value = aws_lb.n_lb.dns_name
}
