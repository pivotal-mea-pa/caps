## Initialize backend state

```
terraform init \
    -backend-config="bucket=$TF_VAR_state_bucket" \
    -backend-config="prefix=$TF_VAR_state_prefix"
```