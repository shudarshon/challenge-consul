# About

This project will help you to create consul cluster in AWS cloud with a consul GUI.

# Dependencies
 - jq
 - ansible
 - terraform
 - make

# Usage

* Make sure terraform `host_count` variable and `bootstrap_expect` parameter of consul is same.
* Change parameter values in `terraform.tfvars` file according to your AWS cloud.
* Apply `make all` command to provision and run the consul cluster in cloud.

# Report

If you find any bug/issue or want more features then create an issue in the repository or mail me at sdrsn.chaki@gmail.com.
