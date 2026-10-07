# Product type setup

This example creates a product type with a text attribute, adds a numeric attribute with a versioned `addAttributeDefinition` update action, reads the product type again by key to verify both attributes, and can delete the product type afterwards.

## Prerequisites

### 1. Create a commercetools API client

Follow the [Setup guide](https://github.com/ballerina-platform/module-ballerinax-commercetools.customizedata/blob/main/ballerina/README.md#setup-guide) to obtain a client ID, client secret, auth URL, API URL and Project key. The API client needs the `view_product_types` and `manage_product_types` scopes.

### 2. Configuration

Create a `Config.toml` file in this example's directory with the following content:

```toml
clientId = "<client-id>"
clientSecret = "<client-secret>"
tokenUrl = "<auth-url>/oauth/token"
apiUrl = "<api-url>"
projectKey = "<project-key>"
productTypeKey = "<product-type-key>"
applyChange = false
deleteAfterwards = false
```

Creating a product type changes the Project, so the example only does so when `applyChange` is `true`. Otherwise it prints what it would create. Set `deleteAfterwards` to `true` to remove the product type again after it has been verified.

## Run the example

Execute the following command to run the example:

```bash
bal run
```
