_Author_:  @DimuthuMadushan \
_Created_: 2026/10/07 \
_Updated_: 2026/10/07 \
_Edition_: Swan Lake

# Sanitation for OpenAPI specification

This document records the sanitation done on top of the official OpenAPI specification from Commercetools.
The OpenAPI specification is obtained from [https://github.com/wso2/api-specs/blob/main/openapi/commercetools/customizedata/v1/openapi.yaml](https://github.com/wso2/api-specs/blob/main/openapi/commercetools/customizedata/v1/openapi.yaml).
These changes are done in order to improve the overall usability, and as workarounds for some known language limitations.

1. **Subset the spec to the previous connector's 21 operations.** The source spec is the full commercetools Composable Commerce API. Only these operations under `/{projectKey}` were kept: `product-types` (GET, POST), `product-types/key={key}` (GET, POST, DELETE), `product-types/{ID}` (GET, POST, DELETE), `types` (GET, POST), `types/key={key}` (GET, POST, DELETE), `types/{ID}` (GET, POST, DELETE), `custom-objects` (GET, POST), `custom-objects/{container}` (GET) and `custom-objects/{container}/{key}` (GET, DELETE). All HEAD operations, all `/in-store/...` paths and every other path were dropped. `components` was pruned to the transitive closure of the referenced schemas and responses (including `discriminator.mapping` targets, so every polymorphic subtype such as the `*UpdateAction` variants survives in `openapi.yaml` (item 13 covers how four of these bases are collapsed in the aligned spec); the mappings of the generic `Reference`, `ResourceIdentifier`, `KeyReference` and `ErrorObject` families are not followed, as they span the whole API), plus the `oauth_2_0` security scheme: 120 schemas and 8 responses. Items 1 and 2 are scripted: `python3 docs/resources/script.py` reads the source spec (cached beside the script as `commercetools-openapi.yaml`, untracked; downloaded from the api-specs `main` URL when missing) and rewrites `docs/spec/openapi.yaml`. Re-running it drops items 3 onward, which must be re-applied after it.

2. **Prune dangling discriminator mappings.** Any `discriminator.mapping` entry whose target was not kept was dropped. `Reference` keeps `customer`, `customer-group`, `product-type` and `type`; `KeyReference` keeps `store`. The `discriminator` of `ErrorObject` was removed because none of its targets survive.

3. **Remove a bogus required property from `ErrorObject`.** The `required` list contained `//` (from a comment in the vendor's source definition). It was removed so the schema only requires `code` and `message`.

4. **Replace the templated server URL with a concrete one.** `https://api.{region}.commercetools.com` (with its `region` variable) was replaced by `https://api.us-central1.gcp.commercetools.com`, so the generated client has a matching default `serviceUrl`.

5. **Match the token URL region to the server.** `securitySchemes.oauth_2_0.flows.clientCredentials.tokenUrl` was changed from `https://auth.europe-west1.gcp.commercetools.com/oauth/token` to `https://auth.us-central1.gcp.commercetools.com/oauth/token`.

6. **Add missing operation summaries.** None of the 21 operations had a `summary`. Each now has a one-line summary (for example "Query product types", "Update a type by key", "Create or update a custom object"), written before the flatten step because the generator derives request-body descriptions from them.

7. **Replace generic response descriptions.** The 22 `'200'`/`'201'` success responses were described only as `'200'` or `'201'`. They now describe what is returned (for example "A paged list of product types", "The updated type", "The deleted custom object").

8. **Describe every inline parameter.** All 63 parameter definitions had no `description`. Each now has one: path `projectKey`, `key`, `id` and `container`; query `expand`, `sort`, `limit`, `offset`, `withTotal`, `where`, `version` and `dataErasure`, with the API defaults and maximums where the vendor documents them.

9. **Describe the inline request bodies.** The 7 inline request bodies (the three create operations, the four update operations and the custom object create-or-update) got a one-line description through the generator's description step on the aligned spec, copied back with `tooling/apply_descriptions.py`.

10. **Rename the by-ID path parameter to `id`.** The two `/{projectKey}/{product-types|types}/{ID}` paths used `{ID}` / `name: ID`, which the align step turned into `iD`, so the six by-ID client methods took `string iD`. The path template and parameter name were renamed to `{id}` / `id`.

11. **Remove the regex-named `var.<name>` query parameter.** The four list operations (`GET` on `custom-objects`, `custom-objects/{container}`, `product-types` and `types`) declared a query parameter named `/^var[.][a-zA-Z0-9]+$/` for the predicate input variables. It generated a record field named after the regex and sent the regex itself as the literal query key, so callers could never name their variables. The parameter was removed. The generated `List*Queries` records are open, so predicate variables are passed as quoted `"var.<name>"` keys, for example `{'where: ["key = :key"], "var.key": "x"}`, which sends `where=key%20%3D%20%3Akey&var.key=x`.

12. **Use integer types for `limit`, `offset` and `version`.** The query parameters `limit` and `offset` (4 list operations each) and `version` (5 operations) were `type: number, format: double`, so the client took `decimal` values for counts and optimistic-concurrency versions. They are now `type: integer` with no `format`, so the generated records have `int 'limit`, `int offset` and `int version`.

13. **Collapse the polymorphic subtypes of four discriminated bases in the aligned spec.** The flatten and align steps drop the subtype schemas that are reachable only through `discriminator.mapping`, which leaves 63 mapping entries dangling in `aligned_ballerina_openapi.json`. `tooling/sanitize_spec.py` removed them from the aligned spec: `ProductTypeUpdateAction` (21), `TypeUpdateAction` (17), `AttributeType` (13) and `FieldType` (12). As a result `ProductTypeUpdateAction` and `TypeUpdateAction` are generated as generic open records with only `string action`, and `AttributeType` and `FieldType` with only `string name`. The action- or type-specific fields are passed as quoted keys, for example `{action: "changeName", "name": "Boot"}`. `openapi.yaml` still holds the full subtypes (item 1). This change is made to the aligned spec, so it must be re-applied (by re-running `sanitize_spec.py`) after a re-align.

## OpenAPI cli command

The following command was used to generate the Ballerina client from the OpenAPI specification. The command should be executed from the repository root directory.

```bash
bal openapi -i docs/spec/aligned_ballerina_openapi.json -o ballerina --mode client --client-methods remote --license docs/license.txt
```

Note: The license year is hardcoded to 2024, change if necessary.
