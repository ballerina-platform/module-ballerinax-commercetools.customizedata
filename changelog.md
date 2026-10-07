# Change Log

This file contains all the notable changes done to the Ballerina commercetools Customize Data connector through the releases.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- The connector is regenerated from the commercetools Composable Commerce API specification and still exposes the
  operations for product types, types and custom objects, now as **remote methods**.
- Operations are renamed, so every 1.x call site changes. Methods follow the pattern `list*`, `create*`, `get*`,
  `update*` and `delete*`, with a `ById` or `ByKey` suffix for single-resource operations (for example
  `getProductTypeById`, `updateTypeByKey`), and `listCustomObjectsByContainer`, `getCustomObjectByContainerAndKey`,
  `createOrUpdateCustomObject` and `deleteCustomObjectByContainerAndKey` for custom objects.
- Generated record types follow the current commercetools schema names, for example `ProductType`, `Type` and
  `CustomObject`.
- Authentication uses the OAuth 2.0 client credentials grant with a configurable `tokenUrl`.

### Added

- Two runnable examples under `examples/`, and mock-server based tests.
