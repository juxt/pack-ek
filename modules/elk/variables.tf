variable "aws_account_id" {}

variable "system_name" {}

variable "availability_zones" {
  type = "list"
}

variable "cidr" {}

variable "ami_image_id" {}

variable "instance_type" {
  default = "t2.medium"
}

variable "key_name" {}

variable "key_path" {}

variable "private_ip" {}

variable "es_cluster_name" {}

variable "es_basic_username" {}
variable "es_basic_password" {}

# ----------------------- Mounting

variable "device_name" {
  default = "/dev/xvdf"
}

variable "lsblk_name" {
  default = "xvdf"
}

variable "volume_size" {
  default = "50"
}

variable "volume_type" {
  default = "gp2"
}

variable "volume_encryption" {
    default = "false"
}

variable "elasticsearch_data_dir" {
  default = "/opt/elasticsearch/data"
}
