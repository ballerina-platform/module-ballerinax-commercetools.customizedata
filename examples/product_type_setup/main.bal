// Creates a product type with a text attribute, adds a numeric attribute with a versioned
// update action, reads the product type back by key to verify both attributes, and optionally
// deletes it.

import ballerina/io;
import ballerinax/commercetools.customizedata;

configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string tokenUrl = ?;
configurable string apiUrl = ?;
configurable string projectKey = ?;
configurable string productTypeKey = ?;
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
        io:println(string `Dry run: would create the product type "${productTypeKey}" with a color and a size attribute. Set applyChange = true to apply.`);
        return;
    }

    // Step 1: Create the product type with a text attribute
    customizedata:ProductType created = check commercetools->createProductType(projectKey, {
        'key: productTypeKey,
        name: "Shoe",
        description: "Attributes shared by all shoes",
        attributes: [
            {
                name: "color",
                label: {"en": "Color"},
                isRequired: true,
                'type: {name: "text"}
            }
        ]
    });
    io:println(string `Created product type ${created.id} (version ${created.version})`);

    // Step 2: Add a numeric attribute against the version that was just returned
    customizedata:ProductType updated = check commercetools->updateProductTypeById(projectKey, created.id, {
        version: created.version,
        actions: [
            {
                action: "addAttributeDefinition",
                "attribute": {
                    name: "size",
                    label: {"en": "Size"},
                    isRequired: false,
                    'type: {name: "number"}
                }
            }
        ]
    });
    io:println(string `Updated to version ${updated.version}`);

    // Step 3: Read the product type again by key and verify both attributes are present
    customizedata:ProductType verified = check commercetools->getProductTypeByKey(projectKey, productTypeKey);
    string[] names = (verified.attributes ?: []).map(attribute => attribute.name);
    if names.indexOf("color") is () || names.indexOf("size") is () {
        return error(string `Expected the attributes color and size but found ${names.toString()}`);
    }
    io:println(string `Verified attributes: ${names.toString()}`);

    // Step 4: Remove the product type again when requested
    if deleteAfterwards {
        customizedata:ProductType deleted =
            check commercetools->deleteProductTypeById(projectKey, verified.id, version = verified.version);
        io:println(string `Deleted product type ${deleted.id}`);
    }
}
