![](https://www.ga4gh.org/wp-content/themes/ga4gh-theme/gfx/GA-logo-horizontal-tag-RGB.svg)

# Service Registry API <a href="https://github.com/ga4gh-discovery/ga4gh-service-registry/blob/develop/service-registry.yaml"><img src="http://validator.swagger.io/validator?url=https://raw.githubusercontent.com/ga4gh-discovery/ga4gh-service-registry/develop/service-registry.yaml" alt="Swagger Validator" height="20em" width="72em"></a> [![Build Status](https://travis-ci.org/ga4gh-discovery/ga4gh-service-registry.svg?branch=develop)](https://travis-ci.org/ga4gh-discovery/ga4gh-service-registry) [![](https://img.shields.io/badge/license-Apache%202-blue.svg)](https://raw.githubusercontent.com/ga4gh-discovery/ga4gh-service-registry/develop/LICENSE)

Service registry is a GA4GH service providing information about other GA4GH services, primarily for the purpose of organizing services into networks or groups and service discovery across organizational boundaries. Information about the individual services in the registry is described in a complementary [service-info](https://github.com/ga4gh-discovery/ga4gh-service-info) specification.

The specification is useful whenever you're dealing with technologies that handle multiple GA4GH services. Common use cases include creating networks or groups of services of a certain type (e.g. [Beacon Network](https://beacon-network.org/) searches networks of [Beacon](https://github.com/ga4gh-beacon/specification) services across multiple organizations, a workflow can be executed by a specific group of [Workflow Execution Services](https://github.com/ga4gh/workflow-execution-service-schemas), or [Search](https://github.com/ga4gh-discovery/ga4gh-discovery-search) on biomedical data is federated across a set of nodes), or a certain host (e.g. an organization provides provides implementations of Beacon, Search and [Data Repository Service](https://github.com/ga4gh/data-repository-service-schemas) APIs, or a server hosts an implementation of [refget](http://samtools.github.io/hts-specs/refget.html) and [htsget](http://samtools.github.io/hts-specs/htsget.html) APIs).

## How to view

Service registry API is specified in OpenAPI in [service-registry.yaml](./service-registry.yaml), which [you can view using Swagger Editor](https://editor.swagger.io/?url=https://raw.githubusercontent.com/ga4gh-discovery/ga4gh-service-registry/develop/service-registry.yaml).

## How to implement

There are two ways to implement this specifications - directly (e.g. a registry of services hosted by an institution), or indirectly through an upstream specification (e.g. an implementation of the Beacon Network specification, which itself provides registry functionality by extending this specification).

When implementing a registry directly, please use the following as your service `type` under `/service-info`. 

```yaml
"type": {
  "group": "org.ga4gh",
  "artifact": "service-registry",
  "version": "1.0.0"
}
```

When implementing a registry indirectly, rely on the upstream specification for guidance on the service type to use.

Sometimes, for example when implementing a specification extending this specification, you might want to include additional information not easily captured by fields currently specified in our schemas. In such situations, we recommend you [add custom fields directly as top-level fields](#implementation-decisions) in your schemas, [as recommended by service-info](https://github.com/ga4gh-discovery/ga4gh-service-info#extending-service-info-payloads).

Service registry is useful for discovering where other services live, even if their locations change over time. As such, we recommend you deploy your service registry implementation with a stable URL, and use it to anchor variable URLs of other services for your clients.

Feel free to check out [our reference implementation](https://github.com/ga4gh-discovery/ga4gh-service-registry-impl).

## Security

Service metadata is viewed as public data and can be provided without restriction. However, an implementation may choose to distribute additional metadata, which may be considered sensitive. Effective security measures are essential to protect the integrity and confidentiality of this data.

Sensitive information transmitted over public networks, such as access tokens and human genomic data, MUST be protected using Transport Level Security (TLS) version 1.2 or later, as specified in [RFC 5246](https://tools.ietf.org/html/rfc5246).

If the data holder requires client authentication and/or authorization, then the client’s HTTPS API request MUST present an OAuth 2.0 bearer access token as specified in [RFC 6750](https://tools.ietf.org/html/rfc6750), in the `Authorization` request header field with the Bearer authentication scheme:

```
Authorization: Bearer [access_token]
```

The policies and processes used to perform user authentication and authorization, and the means through which access tokens are issued, are beyond the scope of this API specification. GA4GH recommends the use of the [OpenID Connect](https://openid.net/connect/) and [OAuth 2.0 framework (RFC 6749)](https://tools.ietf.org/html/rfc6749) for authentication and authorization.

## CORS

Cross-origin resource sharing (CORS) is an essential technique used to overcome the same origin content policy seen in browsers. This policy restricts a webpage from making a request to another website and leaking potentially sensitive information. However the same origin policy is a barrier to using open APIs. GA4GH open API implementers should enable CORS to an acceptable level as defined by their internal policy. For any public API implementations should allow requests from any server.

GA4GH published a [CORS best practices document](https://docs.google.com/document/d/1Ifiik9afTO-CEpWGKEZ5TlixQ6tiKcvug4XLd9GNcqo/edit?usp=sharing), which implementers should refer to for guidance when enabling CORS on public API instances.

## How to test

Use [Swagger Validator Badge](https://github.com/swagger-api/validator-badge) to validate the YAML file, or its [OAS Validator](https://github.com/mcupak/oas-validator) wrapper.

## How to contribute

Guidelines for contributing to this repository are listed in [CONTRIBUTING.md](CONTRIBUTING.md).

## How to notify GA4GH of potential security flaws

Please send an email to security-notification@ga4gh.org.

## Implementation decisions

1. Don't prescribe pagination ([#71](https://github.com/ga4gh-discovery/ga4gh-service-registry/issues/71)).
1. Don't compromise design in favour of static no-code implementation ([#71](https://github.com/ga4gh-discovery/ga4gh-service-registry/issues/71)).
1. When extending the specification, add custom fields directly as top-level fields in your schemas - no need to nest in a particular field ([service-info/issues/35](https://github.com/ga4gh-discovery/ga4gh-service-info/issues/35#issuecomment-521665116)).

## FAQ

### How is this service registry different from other popular service registry technologies?

General-purpose service registries you might know from microservices (like [Eureka](https://github.com/Netflix/eureka) or [Consul](https://www.hashicorp.com/products/consul/service-discovery)) are designed to allow services to programmatically discover other services in their environment. They work within organizational boundaries and rely on the environment being under your control. They use custom proprietary APIs and are fairly heavy-weight (provide a lot of additional functionality like rich health checking, multi-datacenter awareness, service management).

This service registry is a minimalistic, light-weight, read-only, standard API. It's designed to aggregate services from many organizations across organizational boundaries, without imposing communication restrictions on these services, or even requiring them to be aware of the registry they're a part of. Rather than internal service-service discovery, this registry is often used to advertise services to arbitrary clients outside of the service organization. The registry is GA4GH-aware and supports metadata specific to GA4GH web services.

### Does the registry support non-GA4GH services?

Yes, you're welcome to list arbitrary services in your registry. This specification relies on the [service-info specification](https://github.com/ga4gh-discovery/ga4gh-service-info), which [supports arbitrary service types](https://github.com/ga4gh-discovery/ga4gh-service-info#can-i-use-this-specification-with-my-custom-non-ga4gh-apis).

### How do you model hierarchies and networks?

While there's no inherent support for structure within a group of services exposed by the registry, a service registry can list other service registries amongst its services. It is then the responsibility of the client to crawl through the graph to discover all the services available in the network. Alternatively, you can perform such crawling in your implementation of the service registry server. While this eases the burden on the client, it comes at the cost of losing the structure of the network, and maintaining the list of services in sync across registries.   

## Contributors

The following people have contributed to the design of this specification.

- Miro Cupak
- Andy Yates
- Jordi Rambla
- Milan Panik
- Juha Tonroos
