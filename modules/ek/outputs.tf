output "ip" {
    value = "${aws_eip.default.public_ip}"
}
