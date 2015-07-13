# Identity Enhancement Service (IdE)

[![Build Status][BS img]][Build Status]
[![Dependency Status][DS img]][Dependency Status]
[![Code Climate][CC img]][Code Climate]
[![Coverage Status][CS img]][Code Climate]

[Build Status]: https://travis-ci.org/ausaccessfed/identity-enhancement-service
[Dependency Status]: https://gemnasium.com/ausaccessfed/identity-enhancement-service
[Code Climate]: https://codeclimate.com/github/ausaccessfed/identity-enhancement-service

[BS img]: https://img.shields.io/codeship/df5b4950-08d1-0133-a2f5-52c6dae51101/develop.svg
[DS img]: https://img.shields.io/gemnasium/ausaccessfed/identity-enhancement-service/develop.svg
[CC img]: https://img.shields.io/codeclimate/github/ausaccessfed/identity-enhancement-service.svg
[CS img]: https://img.shields.io/codeclimate/coverage/github/ausaccessfed/identity-enhancement-service.svg

```
Copyright 2014-2015, Australian Access Federation

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

**Current Release:** 1.0.0 (15/05/2015)

IdE enhances existing institution identities for users undertaking research
activities in the Australian Higher Education sector by specifically identifying
these users as a "researchers".

NeCTAR funded Virtual Laboratories (VL) and other AAF connected services will be
able to use this information to make informed access control decisions
specifically for researchers.

## Integration

### RESTful API

Documentation is available for developers wishing to use the [RESTful API](doc/api/v1/README.md).

For the AAF deployment of IdE, the base URLs are:

* Production: <https://ide.aaf.edu.au>
* Test: <https://ide.test.aaf.edu.au>

To request an API Certificate for use with the AAF IdE API, please request
access to the [AAF Certificate Service](https://certs.aaf.edu.au). This can be
requested from [AAF Support](http://support.aaf.edu.au).

### Shibboleth Simple Aggregation

For information on configuring Simple Aggregation in Shibboleth, please refer to
the [attribute resolver documentation][simple-aggregation].

The `AttributeResolver` and corresponding `Attribute` mapping used for our
[example application][sp-example] are shown below. Please note this is for the
**test federation**. The `Entity` will need to be corrected when using this for
a production service.

1. Add to `/etc/shibboleth/shibboleth2.xml` **below your existing
   `AttributeResolver`**:

    ```xml
    <AttributeResolver type="SimpleAggregation" attributeId="auEduPersonSharedToken"
        format="urn:oasis:names:tc:SAML:2.0:nameid-format:federated">
      <!-- Test Federation -->
      <Entity>https://ide.test.aaf.edu.au/idp/shibboleth</Entity>
      <saml2:Attribute xmlns:saml2="urn:oasis:names:tc:SAML:2.0:assertion"
          Name="urn:oid:1.3.6.1.4.1.5923.1.1.1.7"
          NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri"
          FriendlyName="eduPersonEntitlement"/>
    </AttributeResolver>
    ```

2. Add to `/etc/shibboleth/attribute-map.xml`:

    ```xml
    <Attribute name="urn:mace:dir:attribute-def:eduPersonEntitlement" id="entitlement"/>
    <Attribute name="urn:oid:1.3.6.1.4.1.5923.1.1.1.7" id="entitlement"/>
    ```

### Example Applications

Example applications in Ruby have been made available for each of these approaches:

* [Example application for integration via Rapid Connect + IdE RESTful API][rapid-example]
* [Example application for integration via a Shibboleth SP][sp-example]

[simple-aggregation]: https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPAttributeResolver#NativeSPAttributeResolver-SimpleAggregationAttributeResolver
[rapid-example]: https://github.com/ausaccessfed/ide-rapidconnect-example
[sp-example]: https://github.com/ausaccessfed/ide-shibbolethsp-example

## Authors

IdE was developed by **Shaun Mangelsdorf** and **Bradley Beddoes** for the
[Australian Access Federation](http://www.aaf.edu.au) and the [National
eResearch Collaboration Tools and Resources (NeCTAR)
Project](https://www.nectar.org.au).
