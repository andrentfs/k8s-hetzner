#Terraform create K8S for Hetzner Cloud.

created your id_rsa private key. 
```
ssh-keygen -t ed25519 -C "seuemail@provedor.com" -f id_rsa
```
and create one archive with name `token.env` and into your token for connect in hetzner cloud.

Ex:.

token.env
```
8J4eJHgWTebFBubgwccxrnayWWsyd3SgRk2UFmb355GfEgrfgbHP11tV56EyFPFz
```

exec the command: 
```
terraform init
terraform apply -auto-approve
```
