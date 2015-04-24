# Subjects

## List Attributes

List all attributes and enhancement providers associated with the specified identity.

```
GET /api/subjects/:shared_token/attributes
```

### Parameters

| Name  | Type | Description |
|---|---|---|
| shared_token | string  | auEduPersonSharedToken for the identity whose attributes the client wishes to resolve  |

### Response

```
Status: 200 OK
```

```json
{
  "subject": {
    "shared_token": "W4ohH-6FCupmiBdwRv_w18AToQ",
    "mail": "john.doe@example.com",
    "name": "John Doe"
  },
  "attributes": [{
    "name":      "eduPersonEntitlement",
    "value":     "urn:mace:aaf.edu.au:ide:researcher:1",
    "providers": [
      "urn:mace:aaf.edu.au:ide:providers:provider1",
      "urn:mace:aaf.edu.au:ide:providers:provider2"
    ]
  }]
}
```

## Modify Attributes

Add or delete attributes associated with the specified identity.

Manipulation of attributes attempts to be idempotent, in that attempting to create an attribute which already exists, or delete an attribute which does not exist will have no effect.

```
POST /api/subjects/attributes
```

### Input

| Name | Type | Description | Optional |
|---|---|---|---|
| subject | object | An object specifying the identity which will be modified by the request | No |
| provider | string | URN of the enhancement provider who will assert or modify attributes for the identity in this request | No |
| attributes | array | An array of *attribute* objects specifying the attributes which will be modified by the request | No |

#### subject
There are 3 keys way to identify a subject within an API request:

1. A subject can be identified by shared_token **only**, in which case the Subject must exist in IdE, and must have previously authenticated to IdE via the invitation system.

1. The subject can be identified by name AND mail in which case:

    1. If there is no Subject matching the provided mail attribute, one will be invited to the system. The attribute modifications specified will occur and become active after the invitation has been accepted
    1. If there is a Subject matching the provided mail attribute with an invite pending, the attribute modifications specified will occur and become active after the invitation has been accepted
    1. If there is a complete Subject matching the provided mail attribute, the attribute modifications specified will occur and become active immediately immediately

1. A shared_token, name and mail attribute is provided in the request along with the attribute *allow_create* set to true. In this case a complete Subject record will be populated and the attribute modifications specified will occur and become active immediately

| Name | Type | Description | Optional |
|---|---|---|---|
| shared_token | string  | auEduPersonSharedToken for the identity whose attributes the client wishes to modify | Yes |
| name | string | The name for the target identity whose attributes the client wishes to modify | Yes |
| mail | string | The email address for the target identity whose attributes the client wishes to modify | Yes |
| expires | string | The expiry date of the invitation, as a YYYY-mm-dd formatted date. |
| allow_create | boolean | If a shared_token, name and mail attribute is provided in the request and an existing identity for the shared_token is not present within IdE should a full record (including attribute manipulation for this request) be created | Yes |

#### attribute

| Name | Type | Description | Optional |
|---|---|---|---|
| name | string | The name of the attribute to modify | No |
| value | string | URN value of the attribute to modify | No |
| _destroy | boolean | Indicates if the attribute should be removed from the identity if present | Yes |

### Example

Specification via shared_token:

```
{
  "subject": {
    "shared_token": "W4ohH-6FCupmiBdwRv_w18AToQ"
  },
  "provider": {
    "identifier": "urn:mace:aaf.edu.au:ide:providers:provider1"
  },
  "attributes": [{
    "name":      "eduPersonEntitlement"
    "value":     "urn:mace:aaf.edu.au:ide:researcher:1"
  }]
}
```

Specification via mail and name:

```
{
  "subject": {
    "mail": "john.doe@example.com",
    "name": "John Doe"
  },
  "provider": {
    "identifier": "urn:mace:aaf.edu.au:ide:providers:provider1"
  },
  "attributes": [{
    "name":      "eduPersonEntitlement",
    "value":      "urn:mace:aaf.edu.au:ide:researcher:1"
  },
  {
    "name":      "eduPersonEntitlement",
    "value":      "urn:mace:aaf.edu.au:ide:researcher:2",
    "_destroy":   true
  }]
}
```

Specification with invitation expiry time:

```
{
  "subject": {
    "mail": "john.doe@example.com",
    "name": "John Doe",
    "expires": "2018-01-01'
  },
  "provider": {
    "identifier": "urn:mace:aaf.edu.au:ide:providers:provider1"
  },
  "attributes": [{
    "name":      "eduPersonEntitlement",
    "value":      "urn:mace:aaf.edu.au:ide:researcher:1"
  }]
}
```

## Response

```Status: 204 NO CONTENT```
