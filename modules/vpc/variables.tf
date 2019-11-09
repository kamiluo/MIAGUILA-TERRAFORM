variable "name" {
  description = "VPC's Name"
  type        = string
}

variable "cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "0.0.0.0/0"
}

variable "tenancy" {
  description = "VPC tenancy"
  type        = string
}


#Subnets Vars
variable "public_subnets" {
  description = "List of public subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "List of private subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "azs" {
  description = "List of Availability Zones, must be equal to subnet numbers"
  type        = list(string)
  default     = []
}

#Common Vars
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "default_cidr" {
  description = "Default CIDR"
  type        = string
  default     = "0.0.0.0/0"
}

#Key Pair Vars
variable "key_pair_name" {
  description = "Key Pair name for EC2 instances"
  type        = string
  default     = "conexion-miaguila"
}

variable "key_pair_public_key" {
  description = "Key Pair public content"
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCg+E+DTCFHtSLWxSlLpi3oypx2YHNL+Ngj8ppyNHk3Cu6MVC5sYTIyxTMYXBF4zpuaCNpMo9RMCMhpOReA5VzNX7sqpy8/u2QxWD1HpWc7pU2NwP7jQmgHJhULMKxv3GFZaqmisAbdHT3zWw4OY6pxjHvyqBeywxtetmiUybwCq6XOHzdAlaPbFdFHZoLPX5O+2RJeWNcLGGZ/fbVVJK+rYk/QDzHJgaye9E2TBPQ0nRTbnipX1VzKpf/oFL8xojF7NBR60YbvHObC7io2PaztgegqfeJpBVpPlmAAYbsRL/jyIFRUQ/BOjfs31qEEkrne5k/jMMKEgW7QtKCnAj09"
}

#Launc Template Vars
variable "lt_ec2_microservice_name"{
  description = "Launch template for microservices name"
  type        = string
  default     = "lt_ma_ec2_dev_microservice"
}

variable "lt_ec2_bastion_name"{
  description = "Launch template for bastion name"
  type        = string
  default     = "lt_ma_ec2_dev_bastion"
}

variable "lt_ec2_webpage_name"{
  description = "Launch template for WebPage name"
  type        = string
  default     = "lt_ma_ec2_dev_webpage"
}

variable "lt_ec2_microservice_instance_type"{
  description = "Instance Type for lt microservices"
  type        = string
  default     = "t2.micro"
}


/* User Data Used
#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
#########################################################################################################
## Ejecución de los 3 microservicios internos en los puertos especificados
########################################################################################################
docker run -d -p 3001:8080 drhelius/helloworld-python-microservice
docker run -d -p 3002:8080 drhelius/helloworld-python-microservice
docker run -d -p 3003:8080 drhelius/helloworld-python-microservice
*/
variable "lt_ec2_microservice_user_data"{
  description = "User Data for EC2 Microservices Instances"
  type        = string
  default     = "IyEvYmluL2Jhc2ggLXhlCmV4ZWMgPiA+KHRlZSAvdmFyL2xvZy91c2VyLWRhdGEubG9nfGxvZ2dlciAtdCB1c2VyLWRhdGEgLXMgMj4vZGV2L2NvbnNvbGUpIDI+JjEKIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjCiMjIEVqZWN1Y2nDs24gZGUgbG9zIDMgbWljcm9zZXJ2aWNpb3MgaW50ZXJub3MgZW4gbG9zIHB1ZXJ0b3MgZXNwZWNpZmljYWRvcwojIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIwpkb2NrZXIgcnVuIC1kIC1wIDMwMDE6ODA4MCBkcmhlbGl1cy9oZWxsb3dvcmxkLXB5dGhvbi1taWNyb3NlcnZpY2UKZG9ja2VyIHJ1biAtZCAtcCAzMDAyOjgwODAgZHJoZWxpdXMvaGVsbG93b3JsZC1weXRob24tbWljcm9zZXJ2aWNlCmRvY2tlciBydW4gLWQgLXAgMzAwMzo4MDgwIGRyaGVsaXVzL2hlbGxvd29ybGQtcHl0aG9uLW1pY3Jvc2VydmljZQ=="
}


/* User Data Used
#!/bin/bash -xe
#########################################################################################################
## Instlacion de Servidor básico y ejecución del servicio
########################################################################################################
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
yum install -y httpd
cat > /var/www/html/index.html << EOF
<html>
<header><title>Bienvenidos a Mi Águila</title></header>
<body>
Bienvenidos a Mi Águila
</body>
</html>
EOF
systemctl start httpd.service
*/
variable "lt_ec2_webpage_user_data"{
  description = "User Data for EC2 WebPage Instances"
  type        = string
  default     = "IyEvYmluL2Jhc2ggLXhlCiMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIwojIyBJbnN0bGFjaW9uIGRlIFNlcnZpZG9yIGLDoXNpY28geSBlamVjdWNpw7NuIGRlbCBzZXJ2aWNpbwojIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIwpleGVjID4gPih0ZWUgL3Zhci9sb2cvdXNlci1kYXRhLmxvZ3xsb2dnZXIgLXQgdXNlci1kYXRhIC1zIDI+L2Rldi9jb25zb2xlKSAyPiYxCnl1bSBpbnN0YWxsIC15IGh0dHBkCmNhdCA+IC92YXIvd3d3L2h0bWwvaW5kZXguaHRtbCA8PCBFT0YKPGh0bWw+CjxoZWFkZXI+PHRpdGxlPkJpZW52ZW5pZG9zIGEgTWkgw4FndWlsYTwvdGl0bGU+PC9oZWFkZXI+Cjxib2R5PgpCaWVudmVuaWRvcyBhIE1pIMOBZ3VpbGEKPC9ib2R5Pgo8L2h0bWw+CkVPRgpzeXN0ZW1jdGwgc3RhcnQgaHR0cGQuc2VydmljZQ=="
}

#Sec Group Vars
variable "sg_ma_ec2_microservices_desc"{
  description = "Sec Group Description"
  type        = string
  default     = "Sec Group For EC2 Microservices Instances"
}

#Auto Scaling EC2 Microservice Vars

variable "ag_ec2_microservices_max"{
  description = "Auto Scaling max instances number"
  type        = number
  default     = 3
}

variable "ag_ec2_microservices_min"{
  description = "Auto Scaling min instances number"
  type        = number
  default     = 0
}

variable "ag_ec2_microservices_desired"{
  description = "Auto Scaling desired instances number"
  type        = number
  default     = 3
}

variable "ag_ec2_microservices_grace"{
  description = "Auto Scaling instances grace period"
  type        = number
  default     = 20
}

#Target Groups Vars
variable "tg_ec2_ports"{
  description = "List of ports for target group"
  type        = list(string)
  default     = ["3001", "3002", "3003"]
}

variable "tg_ec2_web_ports"{
  description = "List of ports for WebPage target group"
  type        = list(string)
  default     = ["80"]
}

variable "tg_ec2_names"{
  description = "List of names for target group"
  type        = list(string)
  default     = ["admin", "client", "driver"]
}

#RDS Vars
variable "rds_instance_postgres_type"{
  description = "Instance type for postgres db"
  type        = string
  default     = "db.t2.micro"
}

variable "rds_instance_dwh_type"{
  description = "Instance type for dwh db"
  type        = string
  default     = "db.t2.micro"
}

variable "elas_cache_node_type"{
  description = "Node type for elastic cache"
  type        = string
  default     = "cache.t2.micro"
}