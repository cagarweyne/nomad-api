variable "region" {
  type    = string
  default = "us-east-2"
}

variable "docker_username" {
  type = string
}

variable "docker_password" {
  type = string
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioners and post-processors on a - dasdasdas
# source.
source "amazon-ebs" "nomad" {
  ami_name      = "nomad-ec2-${local.timestamp}"
  instance_type = "t2.micro"
  region        = var.region
  // source_ami    = "ami-02465d3cadb122e4f"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*" 
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["679593333241"]
  }
  ssh_username = "ubuntu"
}

# a build block invokes sources and runs provisioning steps on them.
build {
  sources = ["source.amazon-ebs.nomad"]

  provisioner "shell" {
    environment_vars = [
    "USERNAME=${var.docker_username}",
    "PASSWORD=${var.docker_password}"
  ]
    script = "./setup.sh"
  }
  provisioner "file" {
    source      = "./daemon.json"
    destination = "/tmp/daemon.json"
  }
  provisioner "shell" {
    script = "./move-daemon.sh"
  }
}
