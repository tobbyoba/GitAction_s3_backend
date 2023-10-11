variable "region" {
  type = string
  #  default = "us-east-2"

}

variable "private_subnet_cidr" {
  type = list(string)
  #  default = ["10.0.1.0/24", "10.0.2.0/24"]

}

variable "public_subnet_cidr" {
  type = list(string)
  #  default = ["10.0.5.0/24", "10.0.6.0/24"]

}

variable "azs" {
  type = list(string)
  #  default = ["us-east-1a", "us-east-2b"]

}
