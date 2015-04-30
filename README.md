# Identity Enhancement Service (IdE)

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

**Current Release:** 0.2.0 (30/04/2015)

IdE enhances existing institution identities for users undertaking research activities in the Australian Higher Education sector by specifically identifying these users as a "researchers".

NeCTAR funded Virtual Laboratories (VL) and other AAF connected services will be able to use this information to make informed access control decisions specifically for researchers.

## Integration

Documentation for developers wishing to use the [IdE RESTful API is available](doc/api/v1/README.md). Server details will be provided by the AAF once deployment to the test federation is completed.

Documentation for developers wishing to use IdE support for the Shibboleth [Simple Aggregation](https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPAttributeResolver#NativeSPAttributeResolver-SimpleAggregationAttributeResolver) profile will be provided by the AAF once deployment to the test federation is completed.

Example applications in Ruby have been made available for each of these approaches:

* [Example application for integration via Rapid Connect + IdE RESTful API][rapid-example]
* [Example application for integration via a Shibboleth SP][sp-example]

[rapid-example]: https://github.com/ausaccessfed/ide-rapidconnect-example
[sp-example]: https://github.com/ausaccessfed/ide-shibbolethsp-example

## Authors

IdE was developed by **Shaun Mangelsdorf** and **Bradley Beddoes** for the [Australian Access Federation](http://www.aaf.edu.au) and the [National eResearch Collaboration Tools and Resources (NeCTAR) Project](https://www.nectar.org.au).
