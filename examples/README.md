# Examples

The `ballerinax/commercetools.customizedata` connector provides practical examples illustrating usage in various scenarios.

1. **[Product type setup](https://github.com/ballerina-platform/module-ballerinax-commercetools.customizedata/tree/main/examples/product_type_setup)** - Create a product type with a text attribute, add a numeric attribute with a versioned update action, verify both attributes by key and optionally delete the product type.

2. **[Custom object settings](https://github.com/ballerina-platform/module-ballerinax-commercetools.customizedata/tree/main/examples/custom_object_settings)** - Store a custom object in a container, read it back, list the objects of the container page by page and optionally delete the object.

## Prerequisites

1. Create a commercetools API client as described in the [Setup guide](https://central.ballerina.io/ballerinax/commercetools.customizedata/latest#setup-guide).

2. For each example, create a `Config.toml` file with the related configuration. Here's an example of how your Config.toml file should look:

```toml
clientId = "<client-id>"
clientSecret = "<client-secret>"
tokenUrl = "<auth-url>/oauth/token"
apiUrl = "<api-url>"
projectKey = "<project-key>"
```

Each example lists the additional values it needs in its own README.

## Running an example

Execute the following commands to build an example from the source:

* To build an example:

    ```bash
    bal build
    ```

* To run an example:

    ```bash
    bal run
    ```
