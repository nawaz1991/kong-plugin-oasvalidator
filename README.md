# 🛡️ OASValidator Kong Plugin

`kong-plugin-oasvalidator` is a Kong plugin that validates incoming HTTP requests against OpenAPI specifications. It offers a granular level of validation including request, body, path parameters, query parameters, header parameters, and routes.

## 📚 Table of Contents
1. [Features](#-features)
2. [Prerequisites](#-prerequisites)
3. [Installation](#-installation)
4. [Configuration](#-configuration)
5. [Usage](#-usage)
6. [Validation Strategies](#-validation-strategies)
7. [Troubleshooting](#-troubleshooting)
8. [License](#-license)

## 🌟 Features

- Validates the entire request or individual parts like body, path, query, and header.
- Low latency and high efficiency.
- Highly configurable through Kong's admin API.

## 🔧 Prerequisites

- Kong >= 2.x.x
- LUA >= 5.1

## 📦 Installation

Install it as a LuaRocks package:

```bash
luarocks install oasvalidator
```

## ⚙️ Configuration

You can add the plugin with the following request:

```bash
curl -X POST http://localhost:8001/services/{serviceName|Id}/plugins \
--data "name=oasvalidator" \
--data "config.oas_spec_path=/path/to/oas/spec" \
--data "config.validate_request=true" \
--data "config.validate_body=false" \
--data "config.validate_path_params=false" \
--data "config.validate_query_params=false" \
--data "config.validate_header_params=false" \
--data "config.validate_route=false"
```

Or, you can use *Declarative (YAML)* to configure:
```yaml
_services:
- name: my-service
  url: http://example.com
  plugins:
    - name: oasvalidator
      config:
        oas_spec_path: "/path/to/oas/spec"
        validate_request: true
        validate_body: false
        validate_path_params: false
        validate_query_params: false
        validate_header_params: false
        validate_route: false
```

### Schema

```lua
-- Refer to the schema.lua file for the full configuration schema
```

### Parameters

- `oas_spec_path`: Path to the OpenAPI specification file (required).
- `validate_request`: Validate the entire request (super set of all validations). Default is true.
- `validate_body`: Validate request body against the OpenAPI spec. Default is false.
- `validate_path_params`: Validate path parameters against the OpenAPI spec. Default is false.
- `validate_query_params`: Validate query parameters against the OpenAPI spec. Default is false.
- `validate_header_params`: Validate header parameters against the OpenAPI spec. Default is false.
- `validate_route`: Validate route against the OpenAPI spec. Default is false.

## 🔍 Usage

After installation and configuration, the plugin will validate incoming requests based on the rules you've set.

## 📜 Validation Strategies

- **Validate Request**: This is a super set of all other validators. If this is enabled, all other validators should be set to false.
- **Individual Validations**: You can also use individual validators for the body, path parameters, query parameters, header parameters, and routes.

## 🛠️ Troubleshooting

Check the Kong error logs for any issues. Error logs provide detailed information about what went wrong, aiding in rapid debugging.

```bash
tail -f /usr/local/kong/logs/error.log
```

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for the full license text.

© 2023 [Muhammad Nawaz](mailto:m.nawaz2003@gmail.com). All Rights Reserved.