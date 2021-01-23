resource "aws_key_pair" "key_yang" {
  key_name   = "key-yang"
  public_key = file("/home/yangiksoon/.ssh/id_rsa.pub")
}
