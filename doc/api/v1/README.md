# Overview

This describes the resources that make up the AAF Identity Enhancement service API v1 (IdE).

If you have any problems please contact [AAF support](mailto:support@aaf.edu.au?subject=IdE API v1 help).

## Access

All API access is over HTTPS without exception. All data is sent and received as JSON.

## Specifying API version

You **MUST** supply an Accept header with all API requests. It **MUST** specify the version of API which your client is expecting to communicate with.

This document specifies interactions for API v1. Clients **MUST** send the following with all requests:

	Accept: application/vnd.aaf.ide.v1+json

Change *within* a version number will only be **by extension**, either with additional endpoints being made available or *additional JSON content being added to currently documented responses*.

Either of these changes should not impact well behaved clients that correctly parse and use JSON as intended.

All clients **MUST** be well behaved, extensions to the API will not be broadcast in advance.

## Authentication
All clients **MUST** posses and supply a valid SSL certificate signed by the AAF Certificate Authority for the federation in which they are operating to establish their validity. For current details on certificate generation and signing contact [AAF support](mailto:support@aaf.edu.au?subject=IdE API certificate) who will work with you to securely complete the request.

Once provided with a certificate administrators for the *Enhancement Provider* **MUST** create an API Account within the IdE *Provider* web interface and submit:

* Details of the certificate issued by the AAF
* A Description of how the remote system intends to use the account to interact with IdE
* Contact information for the **team** (please no individual email addresses, this should be a mailing list for your operational team) responsible for making API requests to IdE.

### Failed authentication

Requests that authenticate with invalid credentials will return `401 Unauthorized`.

You **MUST** ensure your API account is active and is associated with the correct common name (CN) as described in your client certificate.

### Failed resource access

If your API account is successfully authenticated its rights to access resources or undertake actions the request identifies will be verified.

Requests that attempt to access resources or undertake actions with an API account that is not authorised will return `403 Forbidden`.

### Logging
All requests to the API are logged for future audit purposes against the verified client certificate. This certificate **MUST** be kept secure at all times.

### Security Issues
Should you become aware of a problem with your client certificate you **MUST** advise [AAF support](mailto:support@aaf.edu.au?subject=IdE API security) as soon as you're aware of it so it can be revoked.

## HTTP Redirects

The API uses HTTP redirection where appropriate. Clients should assume that any request may result in a redirection. Receiving an HTTP redirection is not an error and clients should follow that redirect. Redirect responses will have a Location header field which contains the URI of the resource to which the client should repeat the requests.

The following redirect responses are possible:

1. 301, Permanent redirection: The URI you used to make the request has been superseded by the one specified in the Location header field. This and all future requests to this resource should be directed to the new URI.
2. 307, Temporary redirection: The request should be repeated to the URI specified in the Location header field, *including the request type*, but clients should continue to use the original URI for future requests.

Other redirection status codes may be used and if so are done in accordance with the HTTP 1.1 spec.

## Client Errors

There are three possible types of client errors on API calls that receive request bodies:

1. Sending invalid JSON will result in a 400 Bad Request response.

    ```
    HTTP/1.1 400 Bad Request
     Content-Length: 35

     {"message":"Request body was invalid."}
    ```

2. Sending the wrong type of JSON values will result in a 400 Bad Request response.

    ```
    HTTP/1.1 400 Bad Request
     Content-Length: 35

     {"message":"Provided data not of correct type."}
    ```

3. Sending invalid fields will result in a 422 Unprocessable Entity response.

    ```
    HTTP/1.1 400 Bad Request
     Content-Length: 35

     {"message":"The request parameters could not be successfully processed."}
    ```

Responses to client errors **SHOULD** contain JSON with the *message* field completed providing a general indication of what went wrong. In circumstances where IdE wishes to supplement the message field with technical specifics of error it will provide the more verbose **error** field.

## Available endpoints
The information supplied thus far is applicable to **all endpoints provided** by the IdE API.

Specific details on interacting with supplied endpoint categories are provided in the following documents:

1. [Subjects](subjects.md)
