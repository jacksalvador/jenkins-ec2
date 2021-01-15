resource "aws_instance" "ec2_yang" {
  ami           = "ami-0e67aff698cb24c1d" # ap-northeast-2 Ubuntu 18.04
  instance_type = "t2.micro"
  vpc_security_group_ids = [
      "sg-1436abcf",
  ]
  tags          = {
    Name        = "EC2-YANG-JENKINS"
    Environment = "production"
  }
   root_block_device {
    delete_on_termination = false
  }
}
