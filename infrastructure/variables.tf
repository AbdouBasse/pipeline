variable "region" {
  description = "Région AWS"
  type        = string
}

variable "vpc_cidr" {
  description = "Plage d’adresses IP du VPC"
  type        = string
}

variable "subnet_cidr" {
  description = "Plage IP du subnet public"
  type        = string
}

variable "ami_id" {
  description = "ID de l’AMI (Amazon Linux 2 ou Ubuntu)"
  type        = string
}

variable "instance_type" {
  description = "Type d’instance EC2"
  type        = string
}

variable "db_user" {
  description = "Nom d’utilisateur de la base de données"
  type        = string
}

variable "db_pass" {
  description = "Mot de passe de la base de données"
  type        = string
  sensitive   = true
}
