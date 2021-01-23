resource "aws_instance" "ec2_yang" {
  subnet_id     = aws_subnet.sbn_yang_public1.id

  ami           = "ami-0e67aff698cb24c1d" # ap-northeast-2 Ubuntu 18.04
  associate_public_ip_address = true
  instance_type = "t2.micro"

  vpc_security_group_ids = [ aws_security_group.sg_yang_jenkins.id ]
  
  tags          = {
    Name        = "EC2-YANG-JENKINS"
    Environment = "prod"
    Network     = "public"
  }
   root_block_device {
    delete_on_termination = true
    volume_size = "8"
  }
  key_name = aws_key_pair.key_yang.key_name
  user_data = file("jenkins-init.sh")
}

resource "aws_instance" "ec2_yang_private" {
  subnet_id     = aws_subnet.sbn_yang_private1.id

  ami           = "ami-0e67aff698cb24c1d" # ap-northeast-2 Ubuntu 18.04
  instance_type = "t2.micro"

  vpc_security_group_ids = [ aws_security_group.sg_yang_jenkins.id ]
  
  tags          = {
    Name        = "EC2-YANG-WEB"
    Environment = "prod"
    Network     = "private"
  }
   root_block_device {
    delete_on_termination = true
    volume_size = "8"
  }
  key_name = aws_key_pair.key_yang.key_name
}
