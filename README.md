# Ballerina Commercetools Customize Data connector

[![Build](https://github.com/ballerina-platform/module-ballerinax-commercetools.customizedata/actions/workflows/ci.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-commercetools.customizedata/actions/workflows/ci.yml)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/ballerina-platform/module-ballerinax-commercetools.customizedata.svg)](https://github.com/ballerina-platform/module-ballerinax-commercetools.customizedata/commits/main)
[![GitHub Issues](https://img.shields.io/github/issues/ballerina-platform/ballerina-library/module/commercetools.customizedata.svg?label=Open%20Issues)](https://github.com/ballerina-platform/ballerina-library/labels/module%2Fcommercetools.customizedata)

## Overview

[commercetools](https://commercetools.com/) is a composable commerce platform that provides API-first building blocks for online storefronts, carts, orders, customers and catalogs. Its customization features let merchants model their own data: product types describe the attributes of products, types add custom fields to resources, and custom objects store arbitrary JSON values.

The commercetools Customize Data connector lets Ballerina applications manage product types, types and custom objects in a commercetools Project. It supports version 1 of the commercetools HTTP API.

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

## Build from the source

### Setting up the prerequisites

1. Download and install Java SE Development Kit (JDK) version 21. You can download it from either of the following sources:

    * [Oracle JDK](https://www.oracle.com/java/technologies/downloads/)
    * [OpenJDK](https://adoptium.net/)

   > **Note:** After installation, remember to set the `JAVA_HOME` environment variable to the directory where JDK was installed.

2. Download and install [Ballerina Swan Lake](https://ballerina.io/).

3. Download and install [Docker](https://www.docker.com/get-started).

   > **Note**: Ensure that the Docker daemon is running before executing any tests.

4. Export Github Personal access token with read package permissions as follows,

    ```bash
    export packageUser=<Username>
    export packagePAT=<Personal access token>
    ```

### Build options

Execute the commands below to build from the source.

1. To build the package:

   ```bash
   ./gradlew clean build
   ```

2. To run the tests:

   ```bash
   ./gradlew clean test
   ```

3. To build the without the tests:

   ```bash
   ./gradlew clean build -x test
   ```

4. To run tests against different environments:

   ```bash
   ./gradlew clean test -Pgroups=<Comma separated groups/test cases>
   ```

5. To debug the package with a remote debugger:

   ```bash
   ./gradlew clean build -Pdebug=<port>
   ```

6. To debug with the Ballerina language:

   ```bash
   ./gradlew clean build -PbalJavaDebug=<port>
   ```

7. Publish the generated artifacts to the local Ballerina Central repository:

    ```bash
    ./gradlew clean build -PpublishToLocalCentral=true
    ```

8. Publish the generated artifacts to the Ballerina Central repository:

   ```bash
   ./gradlew clean build -PpublishToCentral=true
   ```

## Contribute to Ballerina

As an open-source project, Ballerina welcomes contributions from the community.

For more information, go to the [contribution guidelines](https://github.com/ballerina-platform/ballerina-lang/blob/master/CONTRIBUTING.md).

## Code of conduct

All the contributors are encouraged to read the [Ballerina Code of Conduct](https://ballerina.io/code-of-conduct).

## Useful links

* For more information go to the [`commercetools.customizedata` package](https://central.ballerina.io/ballerinax/commercetools.customizedata/latest).
* For example demonstrations of the usage, go to [Ballerina By Examples](https://ballerina.io/learn/by-example/).
* Chat live with us via our [Discord server](https://discord.gg/ballerinalang).
* Post all technical questions on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.
