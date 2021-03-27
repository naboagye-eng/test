variable "app" {
  type = map
  default = {
    name = "ss"
    env  = "dev"
  }
}

variable "availability_zones" {
  type = list
  default = [
    "us-west-1c", 
    "us-west-1b",
  ]
}

variable "region" {
  type = string
  default = "us-west-1"
}

variable "network" {
  type = map
  default = {
    cidr       = "10.100.96.0/20"
    publicAz1  = "10.100.96.0/22"
    publicAz2  = "10.100.100.0/22"
    privateAz1 = "10.100.104.0/22"
    privateAz2 = "10.100.108.0/22"
  }
}

variable "certificate_arn" {
  type = string
  default = "arn:aws:acm:us-west-1:710789462061:certificate/5841c2c4-403a-436b-bf03-91f891677fba"
}

variable "domain" {
  type = string
  default = "isvc.tech"
}

variable "ssl_cert" {
  type = string
  default = "*.isvc.tech"
}

variable "node_volume_size" {
  type = string
  default = "10"
}

variable "node_instance_type" {
  type = string
  default = "t2.large"
}

variable "nosql_volume_size" {
  type = string
  default = "10"
}

variable "nosql_instance_type" {
  type = string
  default = "t2.large"
}

variable "nat_count" {
  type = string
  default = "1"
}

variable "escluster_instance_count" {
  type = string
  default = "2"
}

variable "escluster_instance_type" {
  type = string
  default = "t2.medium.elasticsearch"
}
