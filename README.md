**See [blog post for more information](https://medium.com/@yohan.belval/provisioning-a-vsts-agent-cluster-in-azure-with-ansible-packer-and-terraform-d06c23deef71)**

# Packer Configuration
Example _packer_vars.json_ file:
```
{
    "subscription_id": "***",
    "resource_group_name": "vsts-agent-images",
    "location": "East US",
    "image_name": "vsts-agent-ubuntu"
}
```

# Terraform Configuration
Example _vars.auto.tfvars_ file:
```
subscription_id         = "***"
location                = "East US"
vm_resource_group       = "vsts-agent-vms"
image_name              = "vsts-agent-ubuntu"
image_resource_group    = "vsts-agent-images"
vm_name                 = "ubuntu-agent"
vm_instance_count       = 3
vsts_account_name       = "***"
vsts_pat                = "***"
```

# How To Get Going
```
az login
packer build -var-file=packer_vars.json packer.json
terraform init
terraform apply
```

# Try It Out With Vagrant
`vagrant up`
