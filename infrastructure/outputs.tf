output "ec2_public_ip" {
  description = "Adresse IP publique de l’instance EC2"
  value       = aws_instance.web.public_ip
}

output "rds_endpoint" {
  description = "Endpoint de la base de données RDS"
  value       = aws_db_instance.db.endpoint
}
