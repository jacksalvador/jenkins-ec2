resource "aws_instance" "ec2_yang" {
  subnet_id     = "aws_subnet.sbn_yang_public1.ids"

  ami           = "ami-0e67aff698cb24c1d" # ap-northeast-2 Ubuntu 18.04
  associate_public_ip_address = true
  instance_type = "t2.micro"
  vpc_security_group_ids = [
      "sg-1436abcf",
  ]
  tags          = {
    Name        = "EC2-YANG-JENKINS"
    Environment = "prod"
  }
   root_block_device {
    delete_on_termination = true
    volume_size = "8GiB"
  }
  key_name = "aws_key_pair.key_yang.KEY-YANG"
}
