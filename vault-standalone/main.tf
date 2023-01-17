# Configure AWS provider
provider "aws" {
  region = "ap-northeast-2"
}

# Create an EC2 instance for each Vault node
resource "aws_instance" "conor-tf-vault" {
  count          = 1
  ami            = "ami-0ab04b3ccbadfae1f"
  instance_type  = "t3.micro"
  key_name       = "conor-seoul-keys"
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.conor-subnet.id}"
  # security_groups is an array, so it needs to be in square brackets:
  security_groups = ["${aws_security_group.conor-vault-sg.id}"]
  tags = {
    Name = "conor-tf-test"
  }


  # Provisioner for the SSH connection to the server for subsequent Vault installation
  connection {
    host = "${self.public_ip}"
    type = "ssh"
    user = "ubuntu"
    private_key = "${file("/Users/conormccullough/Documents/keys/conor-seoul-keys.pem")}"
    timeout = "2m"

  }

  provisioner "file" {
    source = "./vault-license.hcl"
    destination = "/tmp/vault-license.hcl"
  }
  
  provisioner "file" {
    source = "./bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }

  provisioner "file" {
    source = "./vault.service"
    destination = "/tmp/vault.service"
  }

  user_data = file("./bootstrap.sh")

} 

output "instance_ip_addr" {
  value = aws_instance.conor-tf-vault.*.public_ip
}



