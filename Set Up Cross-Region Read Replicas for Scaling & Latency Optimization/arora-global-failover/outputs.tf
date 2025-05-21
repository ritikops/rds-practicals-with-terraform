output "primary_endpoint" {
  value = module.aurora.primary_endpoint
}

output "secondary_endpoint" {
  value = module.aurora.secondary_endpoint
}

output "dns_name" {
  value = format("%s.%s", var.db_hostname, var.hosted_zone_id)
}
