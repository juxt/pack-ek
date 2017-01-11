# Image-ELK

Setup Elastic and Kibana using Packer and Terraform.

## Build the AMI using Packer

This Packer setup depends on AWS credentials having been pre-configured. Before running, set the `AWS_PROFILE` environmental variable.

```
packer build elk.json
```
