output "instance_ips" {
  description = "IP Addresses of EC2 instances"
  value = [aws_instance.web.*.public_ip]
  }

  output "instance_security_groups" {
  description = "Security Groups Instances are associated with"
  value = [aws_instance.web.*.security_groups]
  }

  output "instance_state" {
  description = "The state of the instance i.e. on, off, running"
  value = [aws_instance.web.*.instance_state]
  }

output "alb_dns_name" {
  description = "DNS of the Application Load Balancer"
  value = [aws_alb.https-lb.dns_name]
  }
