# Providers

## List Providers

List all enhancement providers visible to the requesting user.

```
GET /api/providers
```

### Response

```
Status: 200 OK
```

```json
{
  "providers": [
    {
      "name": "Example Provider One",
      "identifier": "urn:mace:aaf.edu.au:ide:providers:provider1"
    },
    {
      "name": "Example Provider Two",
      "identifier": "urn:mace:aaf.edu.au:ide:providers:provider2"
    },
    {
      "name": "Example Provider Three",
      "identifier": "urn:mace:aaf.edu.au:ide:providers:provider3"
    },
    {
      "name": "Example Provider Four",
      "identifier": "urn:mace:aaf.edu.au:ide:providers:provider4"
    }
  ]
}
```
