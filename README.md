# Identity Enhancement Service (IdE)

[![Build Status][BS img]][Build Status]
[![Dependency Status][DS img]][Dependency Status]
[![Code Climate][CC img]][Code Climate]
[![Coverage Status][CS img]][Code Climate]

[Build Status]: https://travis-ci.org/ausaccessfed/identity-enhancement-service
[Dependency Status]: https://gemnasium.com/ausaccessfed/identity-enhancement-service
[Code Climate]: https://codeclimate.com/github/ausaccessfed/identity-enhancement-service

[BS img]: https://img.shields.io/codeship/df5b4950-08d1-0133-a2f5-52c6dae51101/develop.svg
[DS img]: https://img.shields.io/gemnasium/ausaccessfed/identity-enhancement-service.svg
[CC img]: https://img.shields.io/codeclimate/github/ausaccessfed/identity-enhancement-service.svg
[CS img]: https://img.shields.io/codeclimate/coverage/github/ausaccessfed/identity-enhancement-service.svg

```
Copyright 2014-2017, Australian Access Federation

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

Identity Enhancement (IdE) is an AAF internal service for assigning and
resolving entitlement values out of band.

## Integration

### RESTful API

Documentation is available for developers wishing to use the [RESTful API](doc/api/v1/README.md).

For the AAF deployment of IdE, the base URLs are:

* Production: <https://ide.aaf.edu.au>
* Test: <https://ide.test.aaf.edu.au>

Note that these are internal services and not accessible publicly.
