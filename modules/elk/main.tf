resource "aws_security_group" "elk" {
  name        = "${var.system_name}_elk"
  description = "Allow access to ELK Stack"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["${var.cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 64000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.system_name}_elk"
  }
}

resource "aws_iam_role" "elk" {
  name = "${var.system_name}-elk-role"
  assume_role_policy = <<EOF
{
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Sid": ""
    }
  ],
  "Version": "2012-10-17"
}
EOF
}

resource "aws_iam_instance_profile" "elk" {
  name = "${var.system_name}-elk"
  roles = ["${aws_iam_role.elk.name}"]
}

# policy with complete access to the dynamodb table
resource "aws_iam_role_policy" "elk" {
  name = "volume_access"
  role = "${aws_iam_role.elk.id}"

  policy = <<EOF
{
 "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AttachVolume",
                "ec2:DetachVolume"
            ],
            "Resource": "arn:aws:ec2:eu-west-1:${var.aws_account_id}:volume/${aws_ebs_volume.es-data.id}"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AttachVolume",
                "ec2:DetachVolume"
            ],
            "Resource": "arn:aws:ec2:eu-west-1:${var.aws_account_id}:instance/*"
        }
    ]
}
EOF
}

data "template_file" "es_config" {
  template = "${file("${path.module}/files/elasticsearch.yml")}"

  vars {
    cluster_name = "${var.es_cluster_name}",
    data_dir = "${var.elasticsearch_data_dir}"
  }
}

data "template_file" "kibana_config" {
  template = "${file("${path.module}/files/kibana.yml")}"

  vars {
    es_basic_username  = "${var.es_basic_username}",
    es_basic_password  = "${var.es_basic_password}",
  }
}

resource "aws_ebs_volume" "es-data" {
  availability_zone = "${var.availability_zones[0]}"
  size = "${var.volume_size}"
  encrypted   = "${var.volume_encryption}"
}

data "template_file" "mount_ebs" {
  template = "${file("${path.module}/files/mount-ebs.sh")}"

  vars {
    availability_zone = "eu-west-1"
    volume_id = "${aws_ebs_volume.es-data.id}"
    device_name = "${var.device_name}"
    lsblk_name = "${var.lsblk_name}"
    elasticsearch_data_dir = "${var.elasticsearch_data_dir}"
  }
}

resource "aws_instance" "elk" {
  ami                    = "${var.ami_image_id}"
  instance_type          = "${var.instance_type}"
  availability_zone      = "${var.availability_zones[0]}"
  vpc_security_group_ids = ["${aws_security_group.elk.id}"]
  key_name               = "${var.key_name}"
  private_ip             = "${var.private_ip}"
  iam_instance_profile   = "${aws_iam_instance_profile.elk.name}"

  tags {
    Name = "${var.system_name}-elk"
    Type = "ELK"
  }

  connection {
    user        = "ubuntu"
    private_key = "${file("${var.key_path}")}"
  }

  # Setup Elastic Search ----------------------------------------------

  provisioner "file" {
    content = "${data.template_file.mount_ebs.rendered}"
    destination = "/tmp/mount-es.sh"
  }

  provisioner "file" {
    content     = "${data.template_file.es_config.rendered}"
    destination = "/tmp/elasticsearch.yml"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/mount-es.sh",
      "sudo /tmp/mount-es.sh",
      "sudo mv /tmp/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml",
      "sudo chown -R root:root /etc/elasticsearch/elasticsearch.yml",
      "sudo systemctl start elasticsearch",
    ]
  }

  # Setup Kibana ----------------------------------------------

  provisioner "file" {
    content     = "${data.template_file.kibana_config.rendered}"
    destination = "/tmp/kibana.yml"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/kibana.yml /etc/kibana/kibana.yml",
      "sudo chown -R root:root /etc/kibana/kibana.yml",
      "sudo systemctl enable kibana",
      "sudo systemctl start kibana"
    ]
  }

  # Setup ES Head ----------------------------------------------

  provisioner "remote-exec" {
    inline = [
      "sudo docker run -d -p 9100:9100 mobz/elasticsearch-head:5"
    ]
  }

  # Setup nginx ----------------------------------------------

  provisioner "file" {
    source      = "${path.module}/files/nginx.conf"
    destination = "/tmp/nginx.conf"
  }

  provisioner "local-exec" {
    command = "htpasswd -b -c /tmp/.htpasswd ${var.es_basic_username} ${var.es_basic_password}"
  }

  provisioner "file" {
    source      = "/tmp/.htpasswd"
    destination = "/tmp/.htpasswd"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/nginx.conf /etc/nginx/nginx.conf",
      "sudo chown -R root:root /etc/nginx/nginx.conf",
      "sudo mv /tmp/.htpasswd /etc/nginx/.htpasswd",
      "sudo chown -R root:root /etc/nginx/.htpasswd",
      "sudo systemctl enable nginx.service",
      "sudo systemctl restart nginx.service"
    ]
  }
}

resource "aws_eip" "default" {
  vpc = true
}

resource "aws_eip_association" "eip_assoc" {
  instance_id = "${aws_instance.elk.id}"
  allocation_id = "${aws_eip.default.id}"
}
