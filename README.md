# Terraform Provision Module
A module for provisioning infrastructure using Terraform and Bolt

## Usage

First ensure that you have the necessary tools:
* [Terraform](https://www.terraform.io/downloads.html)
* [Bolt](https://puppet.com/docs/bolt/latest/bolt_installing.html)

Then, from this directory, run:
```
bolt puppetfile install
bolt plan run terraform_provision -i inventory.yaml tf_path=~/path/to/terraform
```
