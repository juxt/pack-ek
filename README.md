# Image-ELK

![ELK](elk.jpg)

Elasticsearch, Kibana and es-head in a box, protected by NGINX!

Setup of Elastic, Kibana and head plugin using Packer and Terraform.

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

You will need `htpasswd` to run.

# Resources

+ https://github.com/docker-library/elasticsearch
+ https://hub.docker.com/r/dtagdevsec/elk/~/dockerfile/
+ https://www.digitalocean.com/community/tutorials/how-to-install-elasticsearch-logstash-and-kibana-elk-stack-on-ubuntu-16-04
+ https://github.com/nadnerb/terraform-elasticsearch
