provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_instance" "DevInstanceAWS" {
  count = "${var.instance_count}"
  instance_type = "${var.instance_type}"
  subnet_id = "${var.subnet_id}"
  ami = "${var.ami_id}"
  key_name = "${var.ssh_key_name}"
  tags {
    Name = "${var.instance_name}"
  }
  security_groups = [
        "${var.security_group}"
  ]
}

resource "null_resource" "ConfigureAnsibleLabelVariable" {
  provisioner "local-exec" {
    command = "echo [${var.dev_host_label}:vars] > ../hosts"
  }
  provisioner "local-exec" {
    command = "echo ansible_ssh_user=${var.ssh_user_name} >> ../hosts"
  }
  provisioner "local-exec" {
    command = "echo ansible_ssh_private_key_file=${var.ssh_key_path} >> ../hosts"
  }
  provisioner "local-exec" {
    command = "echo [${var.dev_host_label}] >> ../hosts"
  }
}

resource "null_resource" "ProvisionRemoteHostsIpToAnsibleHosts" {
  count = "${var.instance_count}"
  connection {
    type = "ssh"
    user = "${var.ssh_user_name}"
    host = "${element(aws_instance.DevInstanceAWS.*.public_ip, count.index)}"
    private_key = "${file("${var.ssh_key_path}")}"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install python-setuptools -y"
    ]
  }
  provisioner "local-exec" {
    command = "echo ${element(aws_instance.DevInstanceAWS.*.public_ip, count.index)} hostname=server-${count.index + 1} datacenter=${var.aws_region} private_ip=${element(aws_instance.DevInstanceAWS.*.private_ip, count.index)} >> ../hosts"
  }
}

resource "null_resource" "ModifyApplyAnsiblePlayBook" {
  provisioner "local-exec" {
    command = "sed -i -e '/hosts:/ s/: .*/: ${var.dev_host_label}/' ../play.yml"   #change host label in playbook dynamically
  }

  provisioner "local-exec" {
    command = "sed -i -e '/bootstrap_expect/ s/: .*/: ${var.instance_count},/' ../roles/consul/templates/bootstrap.json.j2"   #change number of hosts in consul configuration
  }

  provisioner "local-exec" {
    command = "cd ../roles/consul/ && /bin/bash ./bootstrap.sh"   #change consul server private ip configuration
  }

  provisioner "local-exec" {
    command = "sleep 10; ansible-playbook -i ../hosts ../play.yml"
  }
  depends_on = ["null_resource.ProvisionRemoteHostsIpToAnsibleHosts"]
}
