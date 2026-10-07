# Custom object settings

This example stores a custom object in a container, reads it back by container and key, lists every object in the container page by page, and can delete the object afterwards.

## Prerequisites

### 1. Create a commercetools API client

Follow the [Setup guide](https://github.com/ballerina-platform/module-ballerinax-commercetools.customizedata/blob/main/ballerina/README.md#setup-guide) to obtain a client ID, client secret, auth URL, API URL and Project key. The API client needs the `view_key_value_documents` and `manage_key_value_documents` scopes.

### 2. Configuration

Create a `Config.toml` file in this example's directory with the following content:

```toml
clientId = "<client-id>"
clientSecret = "<client-secret>"
tokenUrl = "<auth-url>/oauth/token"
apiUrl = "<api-url>"
projectKey = "<project-key>"
container = "<container>"
objectKey = "<object-key>"
applyChange = false
deleteAfterwards = false
```

Storing a custom object changes the Project, so the example only does so when `applyChange` is `true`. Otherwise it prints what it would store. Set `deleteAfterwards` to `true` to remove the object again after it has been read back.

## Run the example

Execute the following command to run the example:

```bash
bal run
```
