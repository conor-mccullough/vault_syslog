# Configure AWS provider
provider "aws" {
  region = "<CHANGEME>"
}

# Create an EC2 instance for each Vault node, define its security groups, and provide it with a public IP
resource "aws_instance" "conor-tf-vault" {
  count          = 1
  ami            = "<CHANGEME>"
  instance_type  = "t3.micro"
  key_name       = "<CHANGEME>"
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.conor-subnet.id}"
  # security_groups is an array, so it needs to be in square brackets:
  security_groups = ["${aws_security_group.conor-vault-sg.id}"]
  tags = {
    Name = "conor-tf-test"
  }

  # Provisioner for the SSH connection to the server for subsequent Vault file provisioning
  connection {
    host = "${self.public_ip}"
    type = "ssh"
    user = "ubuntu"
    private_key = "${file("/LOCAL/PATH/TO/KEYS/<CHANGEME>")}"
    timeout = "2m"
  }

  # Provisioners to place the license & systemd service files on the target system
  provisioner "file" {
    source = "./vault-license.hcl"
    destination = "/tmp/vault-license.hcl"
  }
  provisioner "file" {
    source = "./vault.service"
    destination = "/tmp/vault.service"
  }

  provisioner "file" {
    source = "./vault-logrotate"
    destination = "/tmp/vault-log"
  }

  # Install and configure the Vault server
  user_data = file("./bootstrap.sh")
} 

# Output the public IP so that you don't have to open the AWS console to find it
output "instance_ip_addr" {
  value = aws_instance.conor-tf-vault.*.public_ip
}



