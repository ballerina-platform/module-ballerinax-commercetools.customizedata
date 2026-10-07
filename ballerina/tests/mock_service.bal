// Copyright (c) 2026, WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/http;

const string MISSING_ID = "missing-id";
const int STALE_VERSION = 999;

// A path segment is either an ID or `key=<key>`.
function isMissing(string idOrKey) returns boolean => idOrKey == MISSING_ID || idOrKey == "key=" + MISSING_ID;

function keyOf(string idOrKey) returns string? {
    if idOrKey.startsWith("key=") {
        return idOrKey.substring(4);
    }
    return ();
}

function productTypeFor(string idOrKey) returns ProductType {
    string? k = keyOf(idOrKey);
    return mockProductType(k is () ? idOrKey : "pt-1001", k);
}

function typeFor(string idOrKey) returns Type {
    string? k = keyOf(idOrKey);
    return mockType(k is () ? idOrKey : "ty-2001", k);
}

function mockProductType(string id, string? 'key = ()) returns ProductType => {
    id,
    'key: 'key ?: "shoe-type",
    version: 3,
    createdAt: "2025-02-01T08:15:00.000Z",
    lastModifiedAt: "2025-02-10T10:20:30.000Z",
    name: "Shoe",
    description: "Attributes shared by all shoes",
    attributes: [
        {
            name: "color",
            label: {"en": "Color", "de": "Farbe"},
            isRequired: true,
            level: "Variant",
            attributeConstraint: "SameForAll",
            inputHint: "SingleLine",
            isSearchable: true,
            'type: {name: "text"}
        },
        {
            name: "size",
            label: {"en": "Size"},
            isRequired: false,
            level: "Variant",
            attributeConstraint: "None",
            inputHint: "SingleLine",
            isSearchable: true,
            'type: {name: "number"}
        }
    ]
};

function mockType(string id, string? 'key = ()) returns Type => {
    id,
    'key: 'key ?: "gift-wrap",
    version: 2,
    createdAt: "2025-03-01T09:00:00.000Z",
    lastModifiedAt: "2025-03-05T12:30:00.000Z",
    name: {"en": "Gift wrap", "de": "Geschenkverpackung"},
    description: {"en": "Gift wrapping options for a line item"},
    resourceTypeIds: ["line-item", "order"],
    fieldDefinitions: [
        {
            name: "giftMessage",
            label: {"en": "Gift message"},
            required: false,
            inputHint: "MultiLine",
            'type: {name: "String"}
        },
        {
            name: "wrapped",
            label: {"en": "Wrapped"},
            required: true,
            'type: {name: "Boolean"}
        }
    ]
};

function mockCustomObject(string container, string 'key, int version = 4) returns CustomObject => {
    id: "co-" + container + "-" + 'key,
    container,
    'key,
    version,
    createdAt: "2025-04-01T07:45:00.000Z",
    lastModifiedAt: "2025-04-02T11:10:00.000Z",
    value: {"theme": "dark", "retries": 3}
};

function staleVersionError() returns ErrorResponse => {
    statusCode: 409,
    message: "Object has a different version than expected.",
    errors: [{code: "ConcurrentModification", message: "Object has a different version than expected."}]
};

listener http:Listener ep0 = new (9090);

service / on ep0 {
    # Delete a custom object by container and key
    #
    # + projectKey - Key of the commercetools project
    # + container - Container of the custom object
    # + 'key - Key of the custom object
    # + version - Last seen version of the custom object
    # + expand - Reference expansion paths
    # + dataErasure - Whether to delete personal data related to the object
    # + return - The deleted custom object, or an error response
    resource function delete [string projectKey]/custom\-objects/[string container]/[string 'key](int? version,
            string[]? expand, boolean? dataErasure) returns CustomObject|ErrorResponseConflict|http:NotFound {
        if 'key == MISSING_ID {
            return http:NOT_FOUND;
        }
        if version == STALE_VERSION {
            return <ErrorResponseConflict>{body: staleVersionError()};
        }
        return mockCustomObject(container, 'key);
    }

    # Delete a product type by ID, or by key when the path segment is `key=<key>`
    #
    # + projectKey - Key of the commercetools project
    # + id - ID of the product type, or `key=<key>`
    # + version - Last seen version of the product type
    # + expand - Reference expansion paths
    # + return - The deleted product type, or an error response
    resource function delete [string projectKey]/product\-types/[string id](int version, string[]? expand)
            returns ProductType|ErrorResponseConflict|http:NotFound {
        if isMissing(id) {
            return http:NOT_FOUND;
        }
        if version == STALE_VERSION {
            return <ErrorResponseConflict>{body: staleVersionError()};
        }
        return productTypeFor(id);
    }

    # Delete a type by ID, or by key when the path segment is `key=<key>`
    #
    # + projectKey - Key of the commercetools project
    # + id - ID of the type, or `key=<key>`
    # + version - Last seen version of the type
    # + expand - Reference expansion paths
    # + return - The deleted type, or an error response
    resource function delete [string projectKey]/types/[string id](int version, string[]? expand)
            returns Type|ErrorResponseConflict|http:NotFound {
        if isMissing(id) {
            return http:NOT_FOUND;
        }
        if version == STALE_VERSION {
            return <ErrorResponseConflict>{body: staleVersionError()};
        }
        return typeFor(id);
    }

    # Query custom objects
    #
    # + projectKey - Key of the commercetools project
    # + expand - Reference expansion paths
    # + sort - Sort expressions
    # + 'limit - Maximum number of results
    # + offset - Number of results to skip
    # + withTotal - Whether to include the total count
    # + 'where - Query predicates
    # + return - A paged list of custom objects
    resource function get [string projectKey]/custom\-objects(string[]? expand, string[]? sort, int? 'limit,
            int? offset, boolean? withTotal, string[]? 'where) returns CustomObjectPagedQueryResponse {
        return {
            total: 2,
            offset: 0,
            'limit: 20,
            count: 2,
            results: [mockCustomObject("settings", "ui"), mockCustomObject("feature-flags", "beta")]
        };
    }

    # Query custom objects in a container
    #
    # + projectKey - Key of the commercetools project
    # + container - Container of the custom objects
    # + sort - Sort expressions
    # + 'where - Query predicates
    # + expand - Reference expansion paths
    # + 'limit - Maximum number of results
    # + offset - Number of results to skip
    # + withTotal - Whether to include the total count
    # + return - A paged list of the custom objects in the container
    resource function get [string projectKey]/custom\-objects/[string container](string[]? sort,
            string[]? 'where, string[]? expand, int? 'limit, int? offset, boolean? withTotal)
            returns CustomObjectPagedQueryResponse {
        return {
            total: 2,
            offset: 0,
            'limit: 20,
            count: 2,
            results: [mockCustomObject(container, "ui"), mockCustomObject(container, "mail")]
        };
    }

    # Get a custom object by container and key
    #
    # + projectKey - Key of the commercetools project
    # + container - Container of the custom object
    # + 'key - Key of the custom object
    # + expand - Reference expansion paths
    # + return - The custom object, or an error response
    resource function get [string projectKey]/custom\-objects/[string container]/[string 'key](string[]? expand)
            returns CustomObject|http:NotFound {
        if 'key == MISSING_ID {
            return http:NOT_FOUND;
        }
        return mockCustomObject(container, 'key);
    }

    # Query product types
    #
    # + projectKey - Key of the commercetools project
    # + expand - Reference expansion paths
    # + sort - Sort expressions
    # + 'limit - Maximum number of results
    # + offset - Number of results to skip
    # + withTotal - Whether to include the total count
    # + 'where - Query predicates
    # + return - A paged list of product types
    resource function get [string projectKey]/product\-types(string[]? expand, string[]? sort, int? 'limit,
            int? offset, boolean? withTotal, string[]? 'where) returns ProductTypePagedQueryResponse {
        return {
            total: 2,
            offset: 0,
            'limit: 20,
            count: 2,
            results: [mockProductType("pt-1001"), mockProductType("pt-1002", "jacket-type")]
        };
    }

    # Get a product type by ID, or by key when the path segment is `key=<key>`
    #
    # + projectKey - Key of the commercetools project
    # + id - ID of the product type, or `key=<key>`
    # + expand - Reference expansion paths
    # + return - The product type, or an error response
    resource function get [string projectKey]/product\-types/[string id](string[]? expand)
            returns ProductType|http:NotFound {
        if isMissing(id) {
            return http:NOT_FOUND;
        }
        return productTypeFor(id);
    }

    # Query types
    #
    # + projectKey - Key of the commercetools project
    # + expand - Reference expansion paths
    # + sort - Sort expressions
    # + 'limit - Maximum number of results
    # + offset - Number of results to skip
    # + withTotal - Whether to include the total count
    # + 'where - Query predicates
    # + return - A paged list of types
    resource function get [string projectKey]/types(string[]? expand, string[]? sort, int? 'limit,
            int? offset, boolean? withTotal, string[]? 'where) returns TypePagedQueryResponse {
        return {
            total: 2,
            offset: 0,
            'limit: 20,
            count: 2,
            results: [mockType("ty-2001"), mockType("ty-2002", "delivery-note")]
        };
    }

    # Get a type by ID, or by key when the path segment is `key=<key>`
    #
    # + projectKey - Key of the commercetools project
    # + id - ID of the type, or `key=<key>`
    # + expand - Reference expansion paths
    # + return - The type, or an error response
    resource function get [string projectKey]/types/[string id](string[]? expand)
            returns Type|http:NotFound {
        if isMissing(id) {
            return http:NOT_FOUND;
        }
        return typeFor(id);
    }

    # Create or update a custom object
    #
    # + projectKey - Key of the commercetools project
    # + expand - Reference expansion paths
    # + payload - The custom object draft
    # + return - The created or updated custom object, or an error response
    resource function post [string projectKey]/custom\-objects(string[]? expand, @http:Payload CustomObjectDraft payload)
            returns CustomObjectOk|ErrorResponseConflict {
        int? version = payload?.version;
        if version == STALE_VERSION {
            return <ErrorResponseConflict>{body: staleVersionError()};
        }
        CustomObject saved = mockCustomObject(payload.container, payload.'key, version is () ? 1 : version + 1);
        saved.value = payload.value;
        return <CustomObjectOk>{body: saved};
    }

    # Create a product type
    #
    # + projectKey - Key of the commercetools project
    # + expand - Reference expansion paths
    # + payload - The product type draft
    # + return - The created product type
    resource function post [string projectKey]/product\-types(string[]? expand, @http:Payload ProductTypeDraft payload)
            returns ProductType {
        ProductType created = mockProductType("pt-1003", payload?.'key);
        created.name = payload.name;
        created.description = payload.description;
        created.version = 1;
        return created;
    }

    # Update a product type by ID, or by key when the path segment is `key=<key>`
    #
    # + projectKey - Key of the commercetools project
    # + id - ID of the product type, or `key=<key>`
    # + expand - Reference expansion paths
    # + payload - The version and update actions
    # + return - The updated product type, or an error response
    resource function post [string projectKey]/product\-types/[string id](string[]? expand,
            @http:Payload ProductTypeUpdate payload)
            returns ProductTypeOk|ErrorResponseConflict|http:NotFound {
        if isMissing(id) {
            return http:NOT_FOUND;
        }
        if payload.version == STALE_VERSION {
            return <ErrorResponseConflict>{body: staleVersionError()};
        }
        ProductType updated = productTypeFor(id);
        updated.version = payload.version + 1;
        return <ProductTypeOk>{body: updated};
    }

    # Create a type
    #
    # + projectKey - Key of the commercetools project
    # + expand - Reference expansion paths
    # + payload - The type draft
    # + return - The created type
    resource function post [string projectKey]/types(string[]? expand, @http:Payload TypeDraft payload)
            returns Type {
        Type created = mockType("ty-2003", payload.'key);
        created.name = payload.name;
        created.resourceTypeIds = payload.resourceTypeIds;
        created.version = 1;
        return created;
    }

    # Update a type by ID, or by key when the path segment is `key=<key>`
    #
    # + projectKey - Key of the commercetools project
    # + id - ID of the type, or `key=<key>`
    # + expand - Reference expansion paths
    # + payload - The version and update actions
    # + return - The updated type, or an error response
    resource function post [string projectKey]/types/[string id](string[]? expand, @http:Payload TypeUpdate payload)
            returns TypeOk|ErrorResponseConflict|http:NotFound {
        if isMissing(id) {
            return http:NOT_FOUND;
        }
        if payload.version == STALE_VERSION {
            return <ErrorResponseConflict>{body: staleVersionError()};
        }
        Type updated = typeFor(id);
        updated.version = payload.version + 1;
        return <TypeOk>{body: updated};
    }
}

// Service-mode response types. `bal openapi --mode client` collapses 4XX/5XX
// to `error` and never emits these, so they are defined here for the mock only.
public type ErrorResponseConflict record {|
    *http:Conflict;
    ErrorResponse body;
|};

public type CustomObjectOk record {|
    *http:Ok;
    CustomObject body;
|};

public type ProductTypeOk record {|
    *http:Ok;
    ProductType body;
|};

public type TypeOk record {|
    *http:Ok;
    Type body;
|};

public type ErrorObject record {
    string code;
    string message;
};

public type ErrorResponse record {
    string message;
    ErrorObject[] errors?;
    int:Signed32 statusCode;
};
