resource "aws_security_group" "sg" {
  vpc_id = "vpc-XXXXXXX" #Correct VPC ID

  ingress {
    description      = "Traffic from EKS(redpanda-console)"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    security_groups = ["sg-XXXXXXXXXXXXXX"] #SG id of the EKS nodes
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_msk_cluster" "test-msk" {
  cluster_name           = "Test-MSK"
  kafka_version          = "3.2.0"
  number_of_broker_nodes = 2

  broker_node_group_info {
    instance_type = "kafka.t3.small"
    client_subnets = [
      "subnet-XXXXXXX", #Subnet ID of the VPC, need to mention at least 2
      "subnet-XXXXXXX",
    ]
    storage_info {
      ebs_storage_info {
        volume_size = 10
      }
    }
    security_groups = [aws_security_group.sg.id]
  }

  tags = {
    Env = "Test"
  }
}

output "bootstrap_brokers_tls" {
  description = "TLS connection host:port pairs"
  value       = aws_msk_cluster.test-msk.bootstrap_brokers_tls
}
