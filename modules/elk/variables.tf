variable "system_name" {}

variable "availability_zones" {
  type = "list"
}

variable "ami_image_id" {}

variable "instance_type" {
  default = "t2.medium"
}

variable "key_name" {}
