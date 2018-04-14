## Developing Templates

1) Ensure you are logged into the environment's VPN and determine the credentials to your Ops Manager by running `caps-info`.

2) Retrieving properties for a particular product

  List staged products

  ```
  om --skip-ssl-validation \
    --target https://$OPSMAN_HOST --username $OPSMAN_USERNAME --password $OPSMAN_PASSWORD \
    curl -path /api/v0/staged/products"
  ```

  Retrieve product properties

  ```
  om --skip-ssl-validation \
    --target https://$OPSMAN_HOST --username $OPSMAN_USERNAME --password $OPSMAN_PASSWORD \
    curl -path /api/v0/staged/products/<product guid>/properties"
  ```

3) Source the template generation script

```
source <repository home>/lib/scripts/utility/template-utils.sh
```

4) Test templates generation and validity

  * Export the environment variables that will provide input for the template for the variables if defaults do not exist.

  * To execute and view the template

  ```
  TEMPLATE_PATH=<required path to folder container jq templates>
  TEMPLATE_OVERRIDE_PATH=<optional path to folder container jq override templates>
  IAAS=<IAAS if you are processing an IAAS specific template within $TEMPLATE_PATH>

  json_result=$(eval_jq_templates \
      "<name of template in $TEMPLATE_PATH without the .jq ext>" 
      "$TEMPLATE_PATH" "$TEMPLATE_OVERRIDE_PATH" "$IAAS")

  echo $json_result
  ```
  * To test if the template is valid you should apply it to Ops Manager as follows.

  ```
  om --skip-ssl-validation \
    --target https://$OPSMAN_HOST --username $OPSMAN_USERNAME --password $OPSMAN_PASSWORD \
    configure-product --product-name cf --product-<configuration type> "$json_result"
  ```
