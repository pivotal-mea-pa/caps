## Initialize backend state

```
terraform init \
    -backend-config="bucket=$TF_VAR_state_bucket" \
    -backend-config="prefix=$TF_VAR_state_prefix"
```

## Bootstrap environment

```
terraform plan \
    -var="bootstrap_state_bucket=$TF_VAR_state_bucket" \
    -var="bootstrap_state_prefix=$TF_VAR_state_prefix"

terraform apply -auto-approve \
    -var="bootstrap_state_bucket=$TF_VAR_state_bucket" \
    -var="bootstrap_state_prefix=$TF_VAR_state_prefix"
```
