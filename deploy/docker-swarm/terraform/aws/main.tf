provider "aws" {
  region = "eu-west-1"
}

data "aws_ami" "docker-swarm" {
  most_recent = true
  filter {
    name = "name"
    values = ["docker-swarm"]
  }
}

resource "aws_security_group" "docker-swarm" {
  name        = "docker-swarm"
  description = "allow all internal traffic, all traffic http from anywhere"
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = "true"
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22 
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "docker-swarm-node" {
  depends_on      = [ "aws_instance.docker-swarm-master" ] 
  count           = "3"
  instance_type   = "t2.micro"
  ami             = "${data.aws_ami.docker-swarm.id}"
  key_name        = "kubernetes-0491e3dac2a2ad5ef21af84b7f40dc12"
  security_groups = ["${aws_security_group.docker-swarm.name}"]
  tags {
    Name = "docker-swarm-node"
  }

  connection {
    user = "ubuntu"
    private_key = "${file("~/.ssh/kube_aws_rsa")}"
  }

  provisioner "local-exec" {
    command = "ssh ubuntu@${self.public_ip} TOKEN=$(ssh ubuntu@${aws_instance.docker-swarm-master.public_ip} 'docker swarm join-token worker -q') docker swarm join --token $TOKEN ${aws_instance.docker-swarm-master.private_ip}:2377",
  }
}

resource "aws_instance" "docker-swarm-master" {
  instance_type   = "t2.micro"
  ami             = "${data.aws_ami.docker-swarm.id}"
  key_name        = "kubernetes-0491e3dac2a2ad5ef21af84b7f40dc12"
  security_groups = ["${aws_security_group.docker-swarm.name}"]
  tags {
    Name = "docker-swarm-master"
  }

  connection {
    user = "ubuntu"
    private_key = "${file("~/.ssh/kube_aws_rsa")}"
  }

  provisioner "file" { 
     source = "../../docker-compose.yml"
     destination = "/tmp/docker-compose.yml"
  }

  provisioner "remote-exec" {
    inline = [
        "docker swarm init",
        "docker-compose -f /tmp/docker-compose.yml pull",
        "docker-compose -f /tmp/docker-compose.yml bundle",
        "docker deploy dockerswarm"
    ]
  }
}
