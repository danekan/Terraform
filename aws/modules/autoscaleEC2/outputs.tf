#Output the load balancer DNS

output "dns_name" {
    value = aws_elb.this.dns_name
}