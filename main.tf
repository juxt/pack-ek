# Variables -----------------------------

variable "aws_profile" {}

variable "aws_region" {}

variable "availability_zone" {}

variable "system_name" {
  default = "all"
}

variable "elk_ami" {}

variable "elk_key_name" {}

variable "elk_key_path" {}

# Providers -----------------------------

provider "aws" {
  profile = "${var.aws_profile}"
  region  = "${var.aws_region}"
}

# Modules -----------------------------

module "elk" {
  source             = "./modules/elk"
  availability_zones = ["${var.availability_zone}"]
  system_name        = "${var.system_name}"
  key_name           = "${var.elk_key_name}"
  key_path           = "${var.elk_key_path}"
  ami_image_id       = "${var.elk_ami}"
}
