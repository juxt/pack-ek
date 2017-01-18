# Image-ELK

![ELK](elk.jpg)

Setup Elastic and Kibana using Packer and Terraform.

## Build the AMI using Packer

This Packer setup depends on AWS credentials having been pre-configured. Before running, set the `AWS_PROFILE` environmental variable.

```
packer build elk.json
```
## Deploy using Terraform

```
terraform plan -var-file=<?> -out proposed.plan
terraform apply proposed.plan
```

# Resources

+ https://github.com/docker-library/elasticsearch
+ https://hub.docker.com/r/dtagdevsec/elk/~/dockerfile/
+ https://www.digitalocean.com/community/tutorials/how-to-install-elasticsearch-logstash-and-kibana-elk-stack-on-ubuntu-16-04
+ https://github.com/nadnerb/terraform-elasticsearch
