resource "aws_security_group" "elk" {
  name        = "${var.system_name}_elk"
  description = "Allow access to ELK Stack"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

    # ideally

    # cidr_blocks = ["10.0.0.0/14"]
  }

  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9300
    to_port     = 9300
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.system_name}_elk"
  }
}

resource "aws_instance" "elk" {
  ami                    = "${var.ami_image_id}"
  instance_type          = "${var.instance_type}"
  availability_zone      = "${var.availability_zones[0]}"
  vpc_security_group_ids = ["${aws_security_group.elk.id}"]
  key_name               = "${var.key_name}"
  private_ip             = "${var.private_ip}"

  tags {
    Name = "${var.system_name}-elk"
    Type = "ELK"
  }

  ebs_block_device {
    device_name = "${var.volume_name}"
    volume_size = "${var.volume_size}"
    encrypted   = "${var.volume_encryption}"
    delete_on_termination = false
  }

  connection {
    user        = "ubuntu"
    private_key = "${file("${var.key_path}")}"
  }

  # Mount the persistent EBS volume and set permissions
  provisioner "remote-exec" {
    inline = [
      "sudo mkfs -t ext4 ${var.volume_name}",
      "sudo mkdir -p ${var.elasticsearch_data_dir}",
      "sudo mount ${var.volume_name} ${var.elasticsearch_data_dir}",
      "sudo echo \"${var.volume_name} ${var.elasticsearch_data_dir} ext4 defaults,nofail 0 2\" >> /etc/fstab",
      "sudo chown -R elasticsearch. ${var.elasticsearch_data_dir}"
    ]
  }

  provisioner "file" {
    source      = "${var.config_file}"
    destination = "/tmp/elasticsearch.yml"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml",
      "sudo chown -R root:root /etc/elasticsearch/elasticsearch.yml",
      "sudo systemctl start elasticsearch",
      "sudo docker run -d -p 9100:9100 mobz/elasticsearch-head:5"
    ]
  }

  provisioner "file" {
    source      = "${var.config_file}"
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
}
