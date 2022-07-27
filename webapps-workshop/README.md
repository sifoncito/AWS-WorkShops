## Simple wordpres installation with ansible and terraform at aws free tier

### Requirements
- Aws free tier account
- Ansible
- Terraform 

![diagram](https://media-exp1.licdn.com/dms/image/D4D12AQH5Hafa2lMSGg/article-inline_image-shrink_1500_2232/0/1658861392523?e=1664409600&v=beta&t=mOUHQ_IUe7DCG3DfOb39lV01h0b10qnZU3TD_RaGPAk)

### Steps
- Create aws key pair 
- Clone repository
```
git clone https://github.com/sifoncito/AWS-WorkShops
cd webapps-workshop
```
- Change key pair name and path in main.tf

![key-pair_name](https://media-exp1.licdn.com/dms/image/D4D12AQEoSeXPVysyKg/article-inline_image-shrink_1500_2232/0/1658866740609?e=1664409600&v=beta&t=fx-wEnHIk3oN1mBAbMslNI5D7OFpO3eC4yjriK3GiEk)


![key-pair-path](https://media-exp1.licdn.com/dms/image/D4D12AQFuIL7IvfCoCQ/article-inline_image-shrink_1500_2232/0/1658862247774?e=1664409600&v=beta&t=2B5LKPOxmXHlwvVDcyLBKtVuhyAinzyUbFjMAjrgoso)

```
terraform init
terraform plan
terraform apply
```
If everything went well, it should show you the IP of the instance


![intance-ip](https://media-exp1.licdn.com/dms/image/D4D12AQHIMDcvydD-Ig/article-inline_image-shrink_1500_2232/0/1658866930365?e=1664409600&v=beta&t=dP8Y3UC_OtgpiQaMPRQx_UgpN3GfGZcRy9sUgsKYF4M)