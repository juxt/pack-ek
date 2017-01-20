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

variable "config_file" {}

variable "volume_name" {
  default = "/dev/sdh"
}

variable "volume_size" {
  default = "50"
}

variable "volume_encryption" {
    default = "false"
}

variable "elasticsearch_data_dir" {
  default = "/opt/elasticsearch/data"
}
