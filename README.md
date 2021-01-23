# jenkins-ec2
Making EC2 as a Jenkins Server by terraform

# ec2.tf
1. ami

ami는 EC2에서 사용하는 os 이미지의 고유 일련번호이다
주의할 것은 같은 Ubuntu 18.04 이미지라고 해도 aws Region 마다 일련번호가 다르니까 주의할 것

2. associate_public_ip_address = true

aws 인스턴스에는 Public ip를 할당하는 방법이 약 3가지 정도 있는데..
1) 자동 ip 할당 - 이 옵션을 true 로 하면 인스턴스 생성 과정에서 랜덤으로 public ip 를 할당
다만 인스턴스를 중지하거나 삭제하면 public ip 가 사라지며 동일한 ip를 다시 못받을 수 있다.
2) elastic ip 할당 - public ip를 별도로 할당받아 개별 관리 및 사용 IP 값을 고정해야 할 경우 ex) UTM, NAT
3) global accelerator - 관심 있으면 후에 wire 검색

테스트용으로는 public_ip 자동할당 옵션으로 해두면 편리하다
elastic ip 와는 달리 쿼타 제한도 없고 인스턴스를 삭제하면 public_ip를 자동반납하기 때문

3. vpc_security_group_ids

sg를 associate 하기 위한 자원명
security_groups 란 리소스가 있어서 헷갈리는데
일반적으로 VPC를 새로 생성하고 인스턴스를 생성할 경우 vpc_security_group_ids 를 쓰면 된다
(If you are creating Instances in a VPC, use vpc_security_group_ids)
security_groups 란 리소스는 default VPC 를 사용할 경우에만 사용

* default VPC - 처음에 생성되어 있는 VPC
일반적인 프로젝트에서는 새로운 VPC를 할당받은 CIDR에 맞게 생성한 후 삭제한다

4. tags
태그는 일반적인 꼬리표와 기능이 동일하나 특이한 건 aws 에서는 자원의 이름을 tag 로 정의한다
Name 속성값에 적어주는 이름이 자원명이 되며 이는 콘솔에서 확인할 수 있다
이 외에 environment 값등은 일반적인 태그와 완전 동일

5. root_block_device {
    delete_on_termination = true
ebs라고도 불리는 block storage 는 EC2 인스턴스의 하드디스크 역할을 한다고 보면 된다
delete_on_termination = false 값으로 프로젝트에서는 주로 설정하지만
연습할 때는 false 로 바꿔주면 ec2를 끄면 ebs가 자동으로 삭제되서 남는 것 없이 깔끔

6. key_name
작성할 때 헤매던 자원인데 aws_key_pair.key_yang.key_name 마지막에 key_name 이 들어간다.
앞서 aws_key_pair.key_yang 까지만 해도 자원은 key.tf 에 생성한 자원이 특정되고
그 자원의 속성값 중 key_name 값을 불러와서 넣어준다는 뜻이다.

이처럼 terraform apply 로 복수의 자원을 생성하고, 동시에 생성된 자원을 다른 자원이 사용하는 경우
'Terraform 리소스 이름'.'내가 붙인 이름' 으로 호출하는데
key_name 처럼 눈에 보이는 속성값들도 있는 반면
id 처럼 눈에는 보이지 않지만 자원이 생성되면서 자동으로 부여되는 값을 사용해 매핑(연결)을 해주기도 한다.

ex1) ec2.tf 2번째 줄 subnet_id = aws_subnet.sbn_yang_public1.id
    EC2 생성 위치를 network.tf 에서 생성한 public1 subnet 내부로 매핑
ex2) ec2.tf 8번째 줄 vpc_security_group_ids = [ aws_security_group.sg_yang_jenkins.id ]
    EC2 에 부착할 sg 를 security_group.tf 에서 생성한 sg 의 id 값을 통해 매핑

7. user_data
인스턴스 생성 후 자동으로 실행되는 스크립트
보통 기본으로 혹은 공통적으로 설정되어야 할 것 들을 넣어준다
스크립트라 줄 바꾸기 등에 특히 민감하다
jenkins-init.sh 에서 5, 6번째 line 을 붙여주니까 에러가 나지 않았다.

userdata 가 제대로 돌았는지
/var/log/cloud-init-output.log 를 확인하면 내가 생성한 스크립트가 돌았는지 확인가능하다.
ps -ef | grep 'jenkins' 로 젠킨스가 설치되었는지도 알 수 있다 - by Folwer

user_data = << EOF
    #! /bin/bash
    sudo apt-get update
    sudo apt-get install -y apache2
    sudo systemctl start apache2
    sudo systemctl enable apache2
    echo "<h1>Deployed via Terraform</h1>" | sudo tee /var/www/html/index.html
EOF

user_data는 위처럼 직접 테라폼 코드 안에 넣을 수도 있지만 스크립트 파일을 생성해서 file("") 로 호출하는 것이 일반적

# key.tf
1. public_key
terraform 으로 aws key 를 만드는 방법이 몇가지가 있는데
public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQAB ~ 처럼 퍼블릭 키값을 전부 넣어줄 수도 있고
public key 값이 들어있는 파일 경로를 지정해 줄 수도 있다
* passphrase 는 보안 차원에서 간단하게라도 설정하는 것을 추천합니다

Ubuntu 에서 기본으로 제공하는 ssh-keygen -t rsa -b 4096 -C "yangiksoon@gmail.com" 커맨드를 통해 key gen을 하면
/home/사용자/.ssh 폴더가 생성되며 이 안에 id_rsa, id_rsa_pub 키가 한 쌍으로 생긴다
key.tf 3번째 줄에 file("/home/사용자/.ssh/id_rsa.pub") 로 경로 값을 지정해 줬다.

* file 을 호출할 때는 file("") 경로를 사용한다. 위 예제에서는 jenkins-init.sh 와 키값을 import 할 때 사용
* 일반적으로 다른 자원의 네이밍과는 달리 key 값은 항상 소문자로 만들어서 소문자로 생성
* 생성할 때는 public key로 접속할 때는 private key를 사용

# network.tf
네트워크 관련 자원들을 생성
VPC - Subnet 패킷들 의 도로 표지판 역할을 하는 route_table
1. aws_route_table
일반적으로 고 가용성을 위해 2개 이상의 AZ에 이중화 구성

# provider.tf
Terraform은 aws 뿐만 아니라 google cloud platform, azure 등에서도 사용 가능
어떠한 환경에서 사용할 것인지 설정하고 이와 관련한 파일 및 플러그인을 terraform init 단계에서 다운

# security_group.tf
SSH 접속을 위한 22번 포트는 사용자가 직접 시스템에 붙을 때 사용하는 보안에 민감
이 때문에 프로젝트에서는 Bastion Host 라는 것을 사용하기도 한다

icmp(v4) 프로토콜은 ping 등 명령어를 사용하기 위해 열어주는 포트
일반적으로 Security Group 에서는 ingress 를 제한하지 않고
필요할 경우 Network ACLs 라고 좀더 큰 단계에서 egress를 제한한다.

* cidr_blocks 은 U-Cloud IP 대역 10.64.0.0/16 이나 My IP 에 대해서 여는 것을 추천