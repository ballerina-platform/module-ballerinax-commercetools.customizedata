// Stores a custom object in a container, reads it back, lists every object in the container,
// and optionally deletes the object again.

import ballerina/io;
import ballerinax/commercetools.customizedata;

configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string tokenUrl = ?;
configurable string apiUrl = ?;
configurable string projectKey = ?;
configurable string container = ?;
configurable string objectKey = ?;
configurable boolean applyChange = false;
configurable boolean deleteAfterwards = false;

public function main() returns error? {
    customizedata:Client commercetools = check new ({
        auth: {
            tokenUrl,
            clientId,
            clientSecret
        }
    }, apiUrl);

    if !applyChange {
        io:println(string `Dry run: would store the custom object "${container}/${objectKey}". Set applyChange = true to apply.`);
        return;
    }

    // Step 1: Create the custom object, or replace its value when it already exists
    customizedata:CustomObject stored = check commercetools->createOrUpdateCustomObject(projectKey, {
        container,
        'key: objectKey,
        value: {"theme": "dark", "pageSize": 25}
    });
    io:println(string `Stored ${stored.container}/${stored.'key} (version ${stored.version})`);

    // Step 2: Read the custom object back by container and key
    customizedata:CustomObject fetched =
        check commercetools->getCustomObjectByContainerAndKey(projectKey, container, objectKey);
    if fetched.version != stored.version {
        return error(string `Expected version ${stored.version} but found ${fetched.version}`);
    }
    io:println(string `Read back value: ${fetched.value.toString()}`);

    // Step 3: List the objects of the container, following the pages until a short page is returned
    int pageSize = 20;
    int offset = 0;
    string[] keys = [];
    while true {
        customizedata:CustomObjectPagedQueryResponse page = check commercetools->listCustomObjectsByContainer(
            projectKey, container, 'limit = pageSize, offset = offset);
        foreach customizedata:CustomObject item in page.results {
            keys.push(item.'key);
        }
        if page.results.length() < pageSize {
            break;
        }
        offset += pageSize;
    }
    io:println(string `The container "${container}" holds ${keys.length()} object(s): ${keys.toString()}`);

    // Step 4: Remove the custom object again when requested
    if deleteAfterwards {
        customizedata:CustomObject deleted = check commercetools->deleteCustomObjectByContainerAndKey(
            projectKey, container, objectKey, version = fetched.version);
        io:println(string `Deleted ${deleted.container}/${deleted.'key}`);
    }
}
