# Create Lambda and SQS resources using Terraform

## Terraform Syntax
```
resource "<PROVIDER>_<TYPE>" "<NAME>" {
 [CONFIG …]
}
```

	• PROVIDER is the name of a provider (e.g., aws), 
	• TYPE is the type of resource to create in that provider (e.g., instance), 
	• NAME is an identifier you can use throughout the Terraform code to refer to this resource (e.g., my_instance).
	• CONFIG consists of one or more arguments that are specific to that resource.

## Root folder of the project. 
### main.tf
Inside the project directory, create a file named `main.tf`. 
This is where we will define our infrastructure configuration using the **HashiCorp Configuration Language (HCL).**

### Go to project directory in CMD.

Run below commands

### `terraform init`
Terraform will download the necessary provider plugins and create a hidden .terraform directory in your project.
* Below files and directory created in the project when do `terraform init`
```
.terraform
terraform.tfstate
terraform.tfstate.backup
```

### `terraform plan`
The plan command lets you see what Terraform will do before actually making any changes. This is a great way to sanity-check your code before unleashing it onto the world.

### `terraform apply`
You’ll notice that the apply command shows you the same plan output and asks you to confirm whether you actually want to proceed with this plan.

## Secret Manager using Terraform Code
**Refer code**
https://github.com/lgallard/terraform-aws-secrets-manager?tab=readme-ov-file

