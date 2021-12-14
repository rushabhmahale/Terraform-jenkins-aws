#aws provider
provider "aws" {
  region     = "ap-south-1"
  profile    = "Awsadmin"
}

#security group
resource "aws_security_group" "ssh-http-1" {
  name        = "ssh-http"
  description = "allow ssh and http"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    from_port   = 80
    to_port     = 80
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

#aws instance
resource "aws_instance" "aws-os-1" {
  ami               = "ami-0447a12f28fddb066"
  instance_type     = "t2.micro"
  availability_zone = "ap-south-1a"
  security_groups   = ["ssh-http"]
  key_name          = "test-os-key"
  user_data         = <<-EOF
                       #!/bin/bash
                       sudo yum install httpd -y
                       sudo yum install git -y
                       sudo systemctl start httpd
                       sudo systemctl enable httpd
                       EOF  
  tags = {
    Name = "aws-os-1"
  }
}

#aws ebs
resource "aws_ebs_volume" "ebs-test" {
  availability_zone = "ap-south-1a"
  size              = 2
  #force_destroy     = false

  tags = {
    Name = "aws-ebs-1"
  }
}

#attaching ebs volume
resource "aws_volume_attachment" "aws-ebs-attach" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.ebs-test.id}"
  instance_id = "${aws_instance.aws-os-1.id}"
}

resource "null_resource" "nullremote" {
  depends_on = [
    aws_volume_attachment.aws-ebs-attach,  
  ]
  
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("D:/Terraformcode/terraform with jenkinstest/test-os-key.pem")
    host        = aws_instance.aws-os-1.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkfs.ext4 /dev/xvdh",
      "sudo mount /dev/xvdh /var/www/html",
      "sudo rm -rf /var/www/html/*",
    ]
  }
}

#aws s3
resource "aws_s3_bucket" "aws-s3-test" {
  bucket = "awstestbucket747"
  acl    = "public-read"
  force_destroy = true
}

#aws cloudfront with s3
resource "aws_cloudfront_distribution" "aws-cloudfront-s3" {
    origin {
        domain_name = "awstestbucket747.s3.amazonaws.com"
        origin_id = "S3-awstestbucket747"
	
        custom_origin_config {
            http_port = 80
            https_port = 443
            origin_protocol_policy = "match-viewer"
            origin_ssl_protocols = ["TLSv1", "TLSv1.1", "TLSv1.2"]
        }
    }
    enabled = true
    
    default_cache_behavior {
        allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
        cached_methods = ["GET", "HEAD"]
        target_origin_id = "S3-awstestbucket747"
    
        # Forward all query strings, cookies and headers
        forwarded_values {
            query_string = false

            cookies {
              forward = "none"
           }
       }


        viewer_protocol_policy = "allow-all"
        min_ttl = 0
        default_ttl = 3600
        max_ttl = 86400
    }

    # Restricts who is able to access this content
    restrictions {
        geo_restriction {
            # type of restriction, blacklist, whitelist or none
            restriction_type = "none"
        }
    }

    # SSL certificate for the service.
    viewer_certificate {
        cloudfront_default_certificate = true
    }
}
