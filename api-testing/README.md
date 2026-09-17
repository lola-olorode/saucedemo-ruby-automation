# Postman API Regression — Reqres

A standalone Postman collection covering the same reqres.in API surface as
[`api_tests/users_api_spec.rb`](../api_tests/users_api_spec.rb) — status
codes, response schema, response time, and header behavior — kept as an
actual Postman artifact rather than folded into the RSpec suite. This is
the tool used for manual/exploratory API regression day-to-day (see the
main [README](../README.md)); the RSpec suite is the automated,
CI-integrated version of the same coverage.

## Files

| File | Purpose |
|---|---|
| `SauceDemo-Reqres-API.postman_collection.json` | The requests + test scripts |
| `Reqres-API.postman_environment.json` | `base_url` and `api_key` variables the collection reads |

## Running it

**Postman GUI:**
1. Import both files (File → Import).
2. Select the "Reqres API" environment from the environment dropdown.
3. Open the collection and Run Collection, or run requests individually.

**Newman (CLI):**
```bash
npm install -g newman
newman run SauceDemo-Reqres-API.postman_collection.json -e Reqres-API.postman_environment.json
```

## Coverage

| Request | Verifies |
|---|---|
| Get single user returns expected shape | 200, response schema, `Content-Type`, response time |
| Get user list is paginated | 200, pagination fields, `data.length == per_page` |
| Get nonexistent user returns 404 | 404, response time |
| Create user returns 201 | 201, request/response field echo, `id`/`createdAt` present |
| Update user returns 200 | 200, updated field, `updatedAt` present |
| Delete user returns 204 | 204, empty body |
| Get single user succeeds without an API key | Documents current reqres.in behavior — see note below |

**On the "API key" request:** the original version of this check asserted
that a missing/empty `x-api-key` gets rejected (401/403). Verified directly
against the live API with curl (no key, an empty key, a bogus key, and a
valid key) that reqres.in's free tier no longer gates `GET /users/:id` on
that header at all — every variant returns 200. The request now asserts
the behavior that's actually true today, so a future tightening on
reqres's side shows up as a clear, intentional regression here rather than
an assertion that silently stopped meaning anything.
