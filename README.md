# Terraform-jenkins-aws

## Diagram-Flowchat:- 

![terraform jenkins aws  drawio](https://user-images.githubusercontent.com/63963025/146136328-04f83b87-94cb-41be-9431-ebb87e3aa660.png)

## steps to be followed

1. Create the key and security group which allow the port 80.

2. Launch EC2 instance.

3. In this Ec2 instance use the key and security group which we have created in step 1.

4. Launch one Volume (EBS) and mount that volume into /var/www/html

5. Developer have uploded the code into github repo also the repo has some images.

6. Copy the github repo code into /var/www/html

7. Create S3 bucket, and copy/deploy the images from github repo into the s3 bucket and change the permission to public readable.

8 Create a Cloudfront using s3 bucket(which contains images) and use the Cloudfront URL to update in code in /var/www/html

Optional

- Those who are familiar with jenkins or are in devops AL have to integrate jenkins in this task wherever you feel can be integrated

-  create snapshot of ebs

## Step-1: Creating key-pairs
goto aws dashboard -> Services -> EC2 -> NETWORK & SECURITY -> Key pairs

Now create new key-pairs



![key pair](https://user-images.githubusercontent.com/63963025/146127716-1ca42a51-18e3-471c-92a4-111ca4bc3f1d.png)

## Step-2: Creating terraform script to perform below task

At first add aws provider

#aws provider

provider "aws" { region = "ap-south-1" profile = "mytest" }

- <b> Follow the given Code :- jenk.tf</b>

## Step-3: Creating Jenkins JOB

Login to your Jenkins

goto Manage Jenkins -> Manage Plugins -> Available plugins and search

SSH plugin, git plugin, Github plugin, SSH Agent, SSH build agent, SSH Build agent, SSH credentials plugin and install it.

Now goto Manage Jenkins -> Congfigure System -> Publish over SSH

- <b> if you are terraform is install on windows create windows node if you are using linux system you can do ssh </b>

![image](https://user-images.githubusercontent.com/63963025/146128649-40a72136-3e17-4c5b-bb09-4ecb62013e56.png)

![image](https://user-images.githubusercontent.com/63963025/146128657-49258542-7b07-4caa-9b14-5f94c5b3cc59.png)

Now create New Job and configure it same as below

![image](https://user-images.githubusercontent.com/63963025/146128939-4b164fa0-6efc-4f06-a89b-f57dfe29bf6f.png)

![image](https://user-images.githubusercontent.com/63963025/146128948-a1fbdeec-3ccf-4499-b0f7-d7645d7a8ce9.png)

![image](https://user-images.githubusercontent.com/63963025/146128953-784869d7-a00b-4659-8f18-878c07a52fb4.png)

![image](https://user-images.githubusercontent.com/63963025/146128966-4754ce80-1fa0-4460-87ce-9a96ef5cbc28.png)

```
terraform init 

terraform plan 

terraform destroy  --auto-approve
```
![Screenshot (151)](https://user-images.githubusercontent.com/63963025/146133011-427dd43f-7fa3-4c9f-bf60-d8d2d13410f5.png)

 ## VPC

create by yourself you can also use terraform to create vpc i have created manually 

![Screenshot (145)](https://user-images.githubusercontent.com/63963025/146130198-a2abf9f2-bd00-4d3a-8b7c-05474a04ff88.png)

## Ec2 instance
![Screenshot (146)](https://user-images.githubusercontent.com/63963025/146130224-19df1367-0dda-4ec7-93f5-ae31286c7b5e.png)

## volume
![Screenshot (147)](https://user-images.githubusercontent.com/63963025/146130275-9424ae9e-2b74-47eb-a23c-0b82401a4b2d.png)

## storage s3 bucket
![Screenshot (148)](https://user-images.githubusercontent.com/63963025/146130512-8bfc5c3b-23a4-4541-b9bd-45a1b35b53bb.png)

## cloudfront
![Screenshot (149)](https://user-images.githubusercontent.com/63963025/146130608-67b2fd83-24e2-4f4a-b630-8ff7c1df7693.png)

<b> Check apache installed or not </b>
![Screenshot (155)](https://user-images.githubusercontent.com/63963025/146133203-3c597140-9384-4c09-ace2-83753ed3bc8f.png)


<b>JOB-1 successfully created.</b>

This job works when new terraform script available on your repository then this job will automatically start and apply terraform script.

Checking New EC2 instance PublicDnsName and keyname using aws cli


![Screenshot (150)](https://user-images.githubusercontent.com/63963025/146129194-0d62e37a-fc7f-4091-a001-d45091bccd37.png)

```
aws ec2 describe-instances --query "Reservations[*].Instances[*].[PublicOnsMame, KeyName]"
```

on next job we will use public DnsName for login.

checking additional attached EBS ID for creating snapshot on next job:-

![Screenshot (157)](https://user-images.githubusercontent.com/63963025/146129698-2c9415ab-58c6-477e-999c-89bdada498f8.png)

```
aws ec2 describe-instances --query "Reservations[*].Instances[*].[KeyName,BlockDeviceMappings[*].[DeviceName,Ebs.[VolumeId]]]"

```
## Step-4: Now upload some images to your S3 bucket after this we will use that images on our webpage with cloudfront link

ex:-

![Screenshot (152)](https://user-images.githubusercontent.com/63963025/146129902-3cebf92a-2c7a-4479-bb37-315a33ace51e.png)

- <b> Make it public </b>
Click Next -> set permission -> make public

Now copy cloudfront link
add cloudfront link to your web page like :- http://{cloudfront Domain Name}/{your S3 images name}

![Screenshot (153)](https://user-images.githubusercontent.com/63963025/146130091-b86542cd-d03d-456e-a3ed-c49f8e310ce6.png)

![Screenshot (154)](https://user-images.githubusercontent.com/63963025/146130119-62fbf359-5145-41c7-8a30-d0ed4dc93f34.png)

Example of my webpage which we going to host on our EC2 server:- 

![image](https://user-images.githubusercontent.com/63963025/146130857-72fab44c-f421-4651-95d6-af3c84d7fc41.png)

## Step-5: Creating SNAPSHOT of additional attached EBS volume

Goto Jenkins -> Create New Job

Create Job configuration same as below:-

![image](https://user-images.githubusercontent.com/63963025/146130954-bd3eabb8-7f08-4070-a01f-5f0f13d6227f.png)


![image](https://user-images.githubusercontent.com/63963025/146130972-a4728549-77bd-4545-9353-7935c1213121.png)


![image](https://user-images.githubusercontent.com/63963025/146130992-8be58f15-826e-490b-ae07-d81b283fbde7.png)


![image](https://user-images.githubusercontent.com/63963025/146131013-d7ff6f64-ec9b-4f0c-bd1b-ae2b124058ce.png)

![Screenshot (162)](https://user-images.githubusercontent.com/63963025/146132802-82a028ac-4f21-4e1b-8560-fc5ec7f92c42.png)

```
#create snapshot of additional EBS volume before new website is clone to aws ec2 machine

aws ec2 describe-instances --query "Reservations[*] Instances[*] [KeyName,BlockDeviceMappings[*] [DeviceName,Ebs.[Volumeld]]]"

echo "generating snapshot of xvdh volume"

aws ec2 create-snapshot --volume-id vol-0eab5a11a6fbe326f --description "This is my xvdh volume snapshot"
```
Note:- Get volume id from aws cli ex:-
```
aws ec2 describe-instances --query "Reservations[*].Instances[*].[KeyName,BlockDeviceMappings[*].[DeviceName,Ebs.[VolumeId]]]"
```
- <b> Change your volume id given below cmd </b>

This JOB will create a snapshot of every new website clone in our system

## Step-6: Create JOB which clone website html file on AWS EC2 instanceStep-7: Create JOB which clone website html file on AWS EC2 instance

Before creating new JOB create new Publish Over SSH from Jenkins Configure

![image](https://user-images.githubusercontent.com/63963025/146131467-03fb2837-594a-49f4-8289-0a0f25af5fb2.png)

![image](https://user-images.githubusercontent.com/63963025/146131621-8f148232-73b3-4370-86b4-bdc2a47c65ac.png)

Select Kind as SSH Username with private key

Copy hostname from aws ec2 usin below command :-

```
aws ec2 describe-instances --query "Reservations[*].Instances[*].[KeyName, PublicDnsName]"
```

Goto Jenkins -> Create New Job

Configure job same as below job:-

![image](https://user-images.githubusercontent.com/63963025/146132285-27fc5fe8-c03d-44c8-ae40-120cb424f620.png)

Note:- This job will run after previous job (creating snapshot job)

![image](https://user-images.githubusercontent.com/63963025/146132343-77534039-dc65-4ffb-ad7a-9eafce8da2aa.png)

![image](https://user-images.githubusercontent.com/63963025/146132369-cfa0775c-5fed-47a3-adb3-06e30a5c640c.png)

<b> use this webpage for refrence:- </b> https://github.com/rushabhmahale/terraform-jenkinswebpage.git

save your job 
```
if ls /var/www/html/ | grep index.html
then
echo "directory is not empty"
echo "removing oid data"
sudo rm -rf /var/www/html/*
sudo rm -rf /var/www/html/.git
#cloning git repo
sudo git clone https://github.com/rushabhmahale/terraform-jenkinswebpage.git /var/www/html/
else
#cloning git repo
sudo git clone https://github.com/rushabhmahale/terraform-jenkinswebpage.git /var/www/html/
fi
```
![Screenshot (163)](https://user-images.githubusercontent.com/63963025/146132566-6c96f8c7-2468-4d00-af60-4cf83ea104c9.png)

![Screenshot (161)](https://user-images.githubusercontent.com/63963025/146132585-23eff318-bfd4-4226-bb8c-19903c5d6d05.png)


You have successfuly created all jenkins jobs.

Now visit your PublicDnsName on browser your website will appear to whole world.







