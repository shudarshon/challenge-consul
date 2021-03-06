init:
	cd ./terraform && /usr/local/bin/terraform init
apply:
	cd ./terraform && /usr/local/bin/terraform apply -auto-approve
destroy:
	cd ./terraform && /usr/local/bin/terraform destroy -auto-approve
all:
	/usr/bin/make init
	/usr/bin/make apply
