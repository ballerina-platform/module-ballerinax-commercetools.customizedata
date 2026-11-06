## Overview

[commercetools](https://commercetools.com/) is a composable commerce platform that provides API-first building blocks for online storefronts, carts, orders, customers and catalogs. Its customization features let merchants model their own data: product types describe the attributes of products, types add custom fields to resources, and custom objects store arbitrary JSON values.

The commercetools Customize Data connector lets Ballerina applications manage product types, types and custom objects in a commercetools Project. It supports version 1 of the commercetools HTTP API.

### Key features

- Create, query, update and delete product types, by ID or by key
- Create, query, update and delete types that add custom fields to commercetools resources
- Store, query and delete custom objects, grouped by container and key
- Versioned update actions that protect against concurrent modification
- Authenticate with the OAuth 2.0 client credentials grant using a commercetools API client

## Setup guide

To use the commercetools Customize Data connector, you need a commercetools Project and an API client that can access its product types, types and custom objects. If you do not have a commercetools account, you can sign up for a trial [here](https://commercetools.com/free-trial).

### Step 1: Create an API client

1. Open the [Merchant Center](https://mc.commercetools.com/) and select your Project.

2. Go to **Settings** → **Developer settings** and select **Create new API client**.

3. Give the client a name and select the scopes for the resources you use: `view_product_types` and `manage_product_types`, `view_types` and `manage_types`, and `view_key_value_documents` and `manage_key_value_documents`.

### Step 2: Note down the credentials

After the client is created, copy the following values. The client secret is shown only once.

* Project key
* Client ID
* Client secret
* Auth URL, for example `https://auth.europe-west1.gcp.commercetools.com`
* API URL, for example `https://api.europe-west1.gcp.commercetools.com`

The token URL is the auth URL followed by `/oauth/token`.

## Quickstart

To use the commercetools Customize Data connector in your Ballerina application, update the `.bal` file as follows:

### Step 1: Import the module

Import the `commercetools.customizedata` module.

```ballerina
import ballerinax/commercetools.customizedata;
```

### Step 2: Instantiate a new connector

1. Create a `Config.toml` file and configure the credentials obtained in the steps above:

```toml
clientId = "<Client ID>"
clientSecret = "<Client Secret>"
tokenUrl = "<Auth URL>/oauth/token"
apiUrl = "<API URL>"
projectKey = "<Project key>"
```

2. Create a `customizedata:ConnectionConfig` with the OAuth 2.0 client credentials and initialize the connector with it.

```ballerina
configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string tokenUrl = ?;
configurable string apiUrl = ?;
configurable string projectKey = ?;

final customizedata:Client commercetools = check new ({
    auth: {
        tokenUrl,
        clientId,
        clientSecret
    }
}, apiUrl);
```

### Step 3: Invoke the connector operation

Now, utilize the available connector operations.

#### List the product types

```ballerina
public function main() returns error? {
    customizedata:ProductTypePagedQueryResponse _ = check commercetools->listProductTypes(projectKey);
}
```

### Step 4: Run the Ballerina application

```bash
bal run
```

## Examples

The commercetools Customize Data connector provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/ballerina-platform/module-ballerinax-commercetools.customizedata/tree/main/examples/), covering the following use cases:

1. [Product type setup](https://github.com/ballerina-platform/module-ballerinax-commercetools.customizedata/tree/main/examples/product_type_setup) - Create a product type with a text attribute, add a numeric attribute with a versioned update action, verify both attributes by key and optionally delete the product type.

2. [Custom object settings](https://github.com/ballerina-platform/module-ballerinax-commercetools.customizedata/tree/main/examples/custom_object_settings) - Store a custom object in a container, read it back, list the objects of the container page by page and optionally delete the object.
