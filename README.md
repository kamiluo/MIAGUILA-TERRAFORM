# MiAguila Terraform
## Estructura
![Estructura](https://github.com/kamiluo/MIAGUILA-TERRAFORM/raw/master/images/MiAguila.vpd.png)
## Requerimientos:
- Terraform 0.12.13.
- Linux (Preferiblemente ubuntu).
- Git (Para clonar el proyecto).
### Instrucciones

  - Descargar el proyecto
    ```sh
    $ git clone https://github.com/kamiluo/MIAGUILA-TERRAFORM.git 
    ```
  - Renombrar el archivo provider.tf.example como provider.tf y cambiar las variables por las credenciales para su nube:
    ```hcl
    provider "aws" {
     access_key = "<your access key>"
     secret_key = "<your secret key>"
    # By default the region is us-east-2 ohio if you want to change 
    # by other region you also have to change the availability zones
     region     = "us-east-2"
     version = "~> 2.25"
    }
    ```
    > **_NOTA:_**  Si desea utilizar otra región se debe cambiar las variables de zonas de disponibilidad en el código de terraform.
  
  - Ejecutar los comandos:
    ```sh
    $ terraform init
    $ terraform plan
    $ terraform apply
    ```
### Modulo VPC
```hcl
module "vpc" {
  source    = "./modules/vpc"
  
  #Vpc Vars
  name      = "vpc"
  cidr      = "10.0.0.0/16"
  tenancy   = "default"

  #Subnets Vars
  public_subnets  = ["10.0.0.0/24","10.0.1.0/24"]
  private_subnets = ["10.0.2.0/24","10.0.3.0/24"]
  azs             = ["us-east-2a","us-east-2b"]
  default_cidr    = "0.0.0.0/0"

  #Common tags  
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
```
### Variables de Entrada
| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| ag\_ec2\_microservices\_desired | Auto Scaling desired instances number | number | `"3"` | no |
| ag\_ec2\_microservices\_grace | Auto Scaling instances grace period | number | `"20"` | no |
| ag\_ec2\_microservices\_max | Auto Scaling max instances number | number | `"3"` | no |
| ag\_ec2\_microservices\_min | Auto Scaling min instances number | number | `"0"` | no |
| azs | List of Availability Zones, must be equal to subnet numbers | list(string) | `` | yes |
| cidr | VPC CIDR | string | `"0.0.0.0/0"` | no |
| default\_cidr | Default CIDR | string | `"0.0.0.0/0"` | no |
| elas\_cache\_node\_type | Node type for elastic cache | string | `"cache.t2.micro"` | no |
| key\_pair\_name | Key Pair name for EC2 instances | string | `"conexion-miaguila"` | no |
| key\_pair\_public\_key | Key Pair public content | string | `` | no |
| lt\_ec2\_bastion\_name | Launch template for bastion name | string | `"lt_ma_ec2_dev_bastion"` | no |
| lt\_ec2\_microservice\_instance\_type | Instance Type for lt microservices | string | `"t2.micro"` | no |
| lt\_ec2\_microservice\_name | Launch template for microservices name | string | `"lt_ma_ec2_dev_microservice"` | no |
| lt\_ec2\_microservice\_user\_data | User Data for EC2 Microservices Instances | string | `` | no |
| lt\_ec2\_webpage\_name | Launch template for WebPage name | string | `"lt_ma_ec2_dev_webpage"` | no |
| lt\_ec2\_webpage\_user\_data | User Data for EC2 WebPage Instances | string | `` | no |
| name | VPC's Name | string | n/a | yes |
| private\_subnets | List of private subnets inside the VPC | list(string) | `` | yes |
| public\_subnets | List of public subnets inside the VPC | list(string) | `` | yes |
| rds\_instance\_dwh\_type | Instance type for dwh db | string | `"db.t2.micro"` | no |
| rds\_instance\_postgres\_type | Instance type for postgres db | string | `"db.t2.micro"` | no |
| sg\_ma\_ec2\_microservices\_desc | Sec Group Description | string | `"Sec Group For EC2 Microservices Instances"` | no |
| tags | A map of tags to add to all resources | string | `<map>` | no |
| tenancy | VPC tenancy | string | n/a | yes |
| tg\_ec2\_names | List of names for target group | list(string) | `` | yes |
| tg\_ec2\_ports | List of ports numbers for target group must be equal of tg\_ec2\_names number | list(string) | `` | yes |
| tg\_ec2\_web\_ports | List of ports numbers for WebPage target group | list(string) | `` | yes |

### Variables de Salida
Para esta prueba no se tomó en cuenta las variables de salida ya que por el momento no se van a utilizar para otros proyectos.

### Estructura del proyecto
La siguiente es la estructura del proyecto:
```
MIAGUILA-TERRAFORM
├── conexion-miaguila.pem
├── lambda_function.py
├── lambda.zip
├── main.tf
├── modules
│   └── vpc
│       ├── 01_main.tf
│       ├── 02_securitygroups.tf
│       ├── 03_ec2.tf
│       ├── 04_hosted_zone.tf
│       ├── 05_s3.tf
│       ├── 06_lambda.tf
│       ├── 07_rds.tf
│       ├── 08_elasticache.tf
│       └── variables.tf
├── provider.tf.example (Cambiar a provider.tf con las credenciales correctas)
└── README.md
```
## Consideraciones Especiales
* Las lambdas se crearon automaticamente tomando como archivo de entrada `lambda.zip` este archivo contiene una funcion en python basica `(ver archivo lambda_function.py)` que imprime la fecha y hora cuando se llama y retorna un `"lambda ejecutado correctamente"`
* La creación de las instancias se hizo a traves de **AutoScaling Group** y **Launch Template** se crearon 3 de cada tipo para los siguientes tipos de instancias.
  * Instancias para microservicios. `ag_ma_ec2_microservices` y `lt_ma_ec2_microservices`
  * Instancia para la WebPage. `ag_ma_ec2_webpage` y `lt_ma_ec2_webpage`
  * Instancia para el bastion. Por facilidad se crea esta instancia para poder verificar el correcto funcionamiento de los microservicios y de la WebPage y acceder a las instancias de la zona privada. `ag_ma_ec2_bastion` y `lt_ma_ec2_microservices`
* En las instancias de microservicios se incluyó el siguiente user data de instancia en el código terraform para exponer los servicios de los puertos `3001`,`3002` y `3003`, este user data fue codificado en base64 para incluirlo más facilmente en el código terraform.
    ```sh
    #!/bin/bash -xe
    exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
    #########################################################################################################
    ## Ejecución de los 3 microservicios internos en los puertos especificados
    ########################################################################################################
    docker run -d -p 3001:8080 drhelius/helloworld-python-microservice
    docker run -d -p 3002:8080 drhelius/helloworld-python-microservice
    docker run -d -p 3003:8080 drhelius/helloworld-python-microservice
    ```
* En la instancia de la WebPage se incluyó el siguiente user data de instancia en el código terraform para exponer el servidor web con pagina de inicio básica, este user data fue codificado en base64 para incluirlo más facilmente en el código terraform.
    ```sh
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
    ```
* Se incluye el archivo `conexion-miaguila.pem` el cual se usa para la conexión con las instancias de las subnets, en el launch template de las instancias se incluye el nombre del archivo y a través del resource `aws_key_pair.key_pair_ma` se incluye la clave pública codificada en base64.
## Mejoras
Algunas mejoras que se pueden implementar son:
* Incluir un ECS para la ejecución de las tareas de los microservicios.
* Si los microservicios son sencillos sustituirlos por lambdas ya que su costo es muy bajo y se corren en ambiente serverless por lo que no se necesitarían instancias EC2 ni balanceadores de carga.
* Incluir un api gateway para mejorar la seguridad de los servicios.
* Cambiar la WebPage desde una instancia EC2 y pasarla totalmente a una WebPage alojada en S3 (con un front  con esto se tiene disponibilidad del %99.9.