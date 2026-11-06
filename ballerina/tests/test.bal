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
import ballerina/os;
import ballerina/test;

final boolean isLiveServer = os:getEnv("IS_LIVE_SERVER") == "true";
final string serviceUrl = isLiveServer ? os:getEnv("COMMERCETOOLS_SERVICE_URL") : "http://localhost:9090";
final string tokenUrl = isLiveServer ? os:getEnv("COMMERCETOOLS_TOKEN_URL") : "http://localhost:9444/oauth/token";
final string clientId = isLiveServer ? os:getEnv("COMMERCETOOLS_CLIENT_ID") : "test-client-id";
final string clientSecret = isLiveServer ? os:getEnv("COMMERCETOOLS_CLIENT_SECRET") : "test-client-secret";
final string projectKey = isLiveServer ? os:getEnv("COMMERCETOOLS_PROJECT_KEY") : "test-project";

// The mock token endpoint starts after module initialisation, so the client is created before the suite.
isolated Client? commercetoolsClient = ();

@test:BeforeSuite
function initClient() returns error? {
    if isLiveServer {
        if serviceUrl == "" {
            return error("COMMERCETOOLS_SERVICE_URL must be set when IS_LIVE_SERVER is true");
        }
        if tokenUrl == "" {
            return error("COMMERCETOOLS_TOKEN_URL must be set when IS_LIVE_SERVER is true");
        }
    }
    Client c = check new ({
        auth: {
            tokenUrl,
            clientId,
            clientSecret
        },
        httpVersion: isLiveServer ? http:HTTP_2_0 : http:HTTP_1_1
    }, serviceUrl);
    lock {
        commercetoolsClient = c;
    }
}

isolated function getClient() returns Client|error {
    lock {
        Client? c = commercetoolsClient;
        if c is Client {
            return c;
        }
    }
    return error("The client is not initialised");
}

const string PRODUCT_TYPE_ID = "pt-1001";
const string PRODUCT_TYPE_KEY = "shoe-type";
const string TYPE_ID = "ty-2001";
const string TYPE_KEY = "gift-wrap";
const string CONTAINER = "settings";
const string OBJECT_KEY = "ui";

// Custom objects

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testListCustomObjects() returns error? {
    Client commercetools = check getClient();
    CustomObjectPagedQueryResponse response = check commercetools->listCustomObjects(projectKey, 'limit = 5);
    test:assertEquals(response.count, response.results.length());
    test:assertTrue(response.'limit > 0);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testListCustomObjectsByContainer() returns error? {
    Client commercetools = check getClient();
    CustomObjectPagedQueryResponse response =
        check commercetools->listCustomObjectsByContainer(projectKey, CONTAINER, 'limit = 5);
    test:assertEquals(response.count, response.results.length());
    foreach CustomObject item in response.results {
        test:assertEquals(item.container, CONTAINER);
    }
}

@test:Config {groups: ["mock_tests"]}
isolated function testCreateOrUpdateCustomObject() returns error? {
    Client commercetools = check getClient();
    CustomObject created = check commercetools->createOrUpdateCustomObject(projectKey, {
        container: CONTAINER,
        'key: "mail",
        value: {"sender": "noreply@example.com"}
    });
    test:assertEquals(created.container, CONTAINER);
    test:assertEquals(created.'key, "mail");
    test:assertEquals(created.version, 1);

    CustomObject updated = check commercetools->createOrUpdateCustomObject(projectKey, {
        container: CONTAINER,
        'key: "mail",
        value: {"sender": "support@example.com"},
        version: 1
    });
    test:assertEquals(updated.version, 2);
}

@test:Config {groups: ["mock_tests"]}
isolated function testCreateOrUpdateCustomObjectConflict() returns error? {
    Client commercetools = check getClient();
    CustomObject|error result = commercetools->createOrUpdateCustomObject(projectKey, {
        container: CONTAINER,
        'key: "mail",
        value: "x",
        version: STALE_VERSION
    });
    test:assertTrue(result is error);
}

@test:Config {groups: ["mock_tests"]}
isolated function testGetCustomObjectByContainerAndKey() returns error? {
    Client commercetools = check getClient();
    CustomObject response = check commercetools->getCustomObjectByContainerAndKey(projectKey, CONTAINER, OBJECT_KEY);
    test:assertEquals(response.container, CONTAINER);
    test:assertEquals(response.'key, OBJECT_KEY);
}

@test:Config {groups: ["mock_tests"]}
isolated function testGetCustomObjectNotFound() returns error? {
    Client commercetools = check getClient();
    CustomObject|error result = commercetools->getCustomObjectByContainerAndKey(projectKey, CONTAINER, MISSING_ID);
    test:assertTrue(result is error);
}

@test:Config {groups: ["mock_tests"]}
isolated function testDeleteCustomObjectByContainerAndKey() returns error? {
    Client commercetools = check getClient();
    CustomObject fixture = check commercetools->createOrUpdateCustomObject(projectKey, {
        container: CONTAINER,
        'key: "obsolete",
        value: "temporary"
    });
    CustomObject deleted = check commercetools->deleteCustomObjectByContainerAndKey(
        projectKey, fixture.container, fixture.'key, version = fixture.version);
    test:assertEquals(deleted.'key, "obsolete");
}

// Product types

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testListProductTypes() returns error? {
    Client commercetools = check getClient();
    ProductTypePagedQueryResponse response = check commercetools->listProductTypes(projectKey, 'limit = 5);
    test:assertEquals(response.count, response.results.length());
    test:assertTrue(response.'limit > 0);
}

@test:Config {groups: ["mock_tests"]}
isolated function testCreateProductType() returns error? {
    Client commercetools = check getClient();
    ProductType created = check commercetools->createProductType(projectKey, {
        name: "Jacket",
        description: "Attributes shared by all jackets",
        'key: "jacket-type"
    });
    test:assertEquals(created.name, "Jacket");
    test:assertEquals(created.'key, "jacket-type");
    test:assertEquals(created.version, 1);
}

@test:Config {groups: ["mock_tests"]}
isolated function testGetProductTypeById() returns error? {
    Client commercetools = check getClient();
    ProductType response = check commercetools->getProductTypeById(projectKey, PRODUCT_TYPE_ID);
    test:assertEquals(response.id, PRODUCT_TYPE_ID);
    test:assertTrue((response.attributes ?: []).length() > 0);
}

@test:Config {groups: ["mock_tests"]}
isolated function testGetProductTypeByKey() returns error? {
    Client commercetools = check getClient();
    ProductType response = check commercetools->getProductTypeByKey(projectKey, PRODUCT_TYPE_KEY);
    test:assertEquals(response.'key, PRODUCT_TYPE_KEY);
}

@test:Config {groups: ["mock_tests"]}
isolated function testGetProductTypeNotFound() returns error? {
    Client commercetools = check getClient();
    ProductType|error result = commercetools->getProductTypeById(projectKey, MISSING_ID);
    test:assertTrue(result is error);
}

@test:Config {groups: ["mock_tests"]}
isolated function testUpdateProductTypeById() returns error? {
    Client commercetools = check getClient();
    ProductType updated = check commercetools->updateProductTypeById(projectKey, PRODUCT_TYPE_ID, {
        version: 3,
        actions: [{action: "changeName", "name": "Boot"}]
    });
    test:assertEquals(updated.version, 4);
}

@test:Config {groups: ["mock_tests"]}
isolated function testUpdateProductTypeByKey() returns error? {
    Client commercetools = check getClient();
    ProductType updated = check commercetools->updateProductTypeByKey(projectKey, PRODUCT_TYPE_KEY, {
        version: 3,
        actions: [{action: "changeDescription", "description": "Footwear"}]
    });
    test:assertEquals(updated.version, 4);
}

@test:Config {groups: ["mock_tests"]}
isolated function testUpdateProductTypeConflict() returns error? {
    Client commercetools = check getClient();
    ProductType|error result = commercetools->updateProductTypeById(projectKey, PRODUCT_TYPE_ID, {
        version: STALE_VERSION,
        actions: [{action: "changeName", "name": "Boot"}]
    });
    test:assertTrue(result is error);
}

@test:Config {groups: ["mock_tests"]}
isolated function testDeleteProductTypeById() returns error? {
    Client commercetools = check getClient();
    ProductType fixture = check commercetools->createProductType(projectKey, {
        name: "Boot",
        description: "Attributes shared by all boots",
        'key: "boot-type"
    });
    ProductType deleted = check commercetools->deleteProductTypeById(projectKey, fixture.id, version = fixture.version);
    test:assertEquals(deleted.id, fixture.id);
}

@test:Config {groups: ["mock_tests"]}
isolated function testDeleteProductTypeByKey() returns error? {
    Client commercetools = check getClient();
    ProductType fixture = check commercetools->createProductType(projectKey, {
        name: "Boot",
        description: "Attributes shared by all boots",
        'key: "boot-type"
    });
    ProductType deleted =
        check commercetools->deleteProductTypeByKey(projectKey, fixture.'key ?: "boot-type", version = fixture.version);
    test:assertEquals(deleted.'key, fixture.'key);
}

@test:Config {groups: ["mock_tests"]}
isolated function testDeleteProductTypeConflict() returns error? {
    Client commercetools = check getClient();
    ProductType fixture = check commercetools->createProductType(projectKey, {
        name: "Boot",
        description: "Attributes shared by all boots",
        'key: "boot-type"
    });
    ProductType|error result = commercetools->deleteProductTypeById(projectKey, fixture.id, version = STALE_VERSION);
    test:assertTrue(result is error);
}

// Types

@test:Config {groups: ["live_tests", "mock_tests"]}
isolated function testListTypes() returns error? {
    Client commercetools = check getClient();
    TypePagedQueryResponse response = check commercetools->listTypes(projectKey, 'limit = 5);
    test:assertEquals(response.count, response.results.length());
    test:assertTrue(response.'limit > 0);
}

@test:Config {groups: ["mock_tests"]}
isolated function testCreateType() returns error? {
    Client commercetools = check getClient();
    Type created = check commercetools->createType(projectKey, {
        'key: "delivery-note",
        name: {"en": "Delivery note"},
        resourceTypeIds: ["order"]
    });
    test:assertEquals(created.'key, "delivery-note");
    test:assertEquals(created.resourceTypeIds, ["order"]);
    test:assertEquals(created.version, 1);
}

@test:Config {groups: ["mock_tests"]}
isolated function testGetTypeById() returns error? {
    Client commercetools = check getClient();
    Type response = check commercetools->getTypeById(projectKey, TYPE_ID);
    test:assertEquals(response.id, TYPE_ID);
    test:assertTrue(response.fieldDefinitions.length() > 0);
}

@test:Config {groups: ["mock_tests"]}
isolated function testGetTypeByKey() returns error? {
    Client commercetools = check getClient();
    Type response = check commercetools->getTypeByKey(projectKey, TYPE_KEY);
    test:assertEquals(response.'key, TYPE_KEY);
}

@test:Config {groups: ["mock_tests"]}
isolated function testGetTypeNotFound() returns error? {
    Client commercetools = check getClient();
    Type|error result = commercetools->getTypeById(projectKey, MISSING_ID);
    test:assertTrue(result is error);
}

@test:Config {groups: ["mock_tests"]}
isolated function testUpdateTypeById() returns error? {
    Client commercetools = check getClient();
    Type updated = check commercetools->updateTypeById(projectKey, TYPE_ID, {
        version: 2,
        actions: [{action: "changeLabel", "label": {"en": "Gift wrapping"}}]
    });
    test:assertEquals(updated.version, 3);
}

@test:Config {groups: ["mock_tests"]}
isolated function testUpdateTypeByKey() returns error? {
    Client commercetools = check getClient();
    Type updated = check commercetools->updateTypeByKey(projectKey, TYPE_KEY, {
        version: 2,
        actions: [{action: "changeKey", "key": "gift-wrapping"}]
    });
    test:assertEquals(updated.version, 3);
}

@test:Config {groups: ["mock_tests"]}
isolated function testUpdateTypeConflict() returns error? {
    Client commercetools = check getClient();
    Type|error result = commercetools->updateTypeById(projectKey, TYPE_ID, {
        version: STALE_VERSION,
        actions: [{action: "changeKey", "key": "other"}]
    });
    test:assertTrue(result is error);
}

@test:Config {groups: ["mock_tests"]}
isolated function testDeleteTypeById() returns error? {
    Client commercetools = check getClient();
    Type fixture = check commercetools->createType(projectKey, {
        'key: "label",
        name: {"en": "Label"},
        resourceTypeIds: ["order"]
    });
    Type deleted = check commercetools->deleteTypeById(projectKey, fixture.id, version = fixture.version);
    test:assertEquals(deleted.id, fixture.id);
}

@test:Config {groups: ["mock_tests"]}
isolated function testDeleteTypeByKey() returns error? {
    Client commercetools = check getClient();
    Type fixture = check commercetools->createType(projectKey, {
        'key: "label",
        name: {"en": "Label"},
        resourceTypeIds: ["order"]
    });
    Type deleted = check commercetools->deleteTypeByKey(projectKey, fixture.'key, version = fixture.version);
    test:assertEquals(deleted.'key, fixture.'key);
}

@test:Config {groups: ["mock_tests"]}
isolated function testDeleteTypeConflict() returns error? {
    Client commercetools = check getClient();
    Type fixture = check commercetools->createType(projectKey, {
        'key: "label",
        name: {"en": "Label"},
        resourceTypeIds: ["order"]
    });
    Type|error result = commercetools->deleteTypeById(projectKey, fixture.id, version = STALE_VERSION);
    test:assertTrue(result is error);
}
