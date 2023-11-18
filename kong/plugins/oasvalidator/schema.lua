-- Copyright (c) 2023 Muhammad Nawaz
-- Licensed under the MIT License. See LICENSE file for more information.
-- [ END OF LICENSE e2f4afc94de80d2c104519cd5b5e65ca0f4d5b62 ]

local typedefs = require "kong.db.schema.typedefs"

local PLUGIN_NAME = "oasvalidator"

local oas_validator_config_schema = {
    name = PLUGIN_NAME,
    fields = {
        { consumer = typedefs.no_consumer },
        { protocols = typedefs.protocols_http },
        { config = {
            type = "record",
            fields = {
                { oas_spec_path = {
                    type = "string",
                    required = true,
                },
                },
                { validate_request = {
                    type = "boolean",
                    default = true,
                    required = false,
                },
                },
                { validate_body = {
                    type = "boolean",
                    default = false,
                    required = false,
                },
                },
                { validate_path_params = {
                    type = "boolean",
                    default = false,
                    required = false,
                },
                },
                { validate_query_params = {
                    type = "boolean",
                    default = false,
                    required = false,
                },
                },
                { validate_header_params = {
                    type = "boolean",
                    default = false,
                    required = false,
                },
                },
                { validate_route = {
                    type = "boolean",
                    default = false,
                    required = false,
                },
                },
            },
            entity_checks = {
                {
                    conditional = {
                        if_field = "validate_request",
                        if_match = { eq = true },
                        then_field = "validate_route",
                        then_match = { eq = false }
                    }
                },
                {
                    conditional = {
                        if_field = "validate_request",
                        if_match = { eq = true },
                        then_field = "validate_path_params",
                        then_match = { eq = false }
                    }
                },
                {
                    conditional = {
                        if_field = "validate_request",
                        if_match = { eq = true },
                        then_field = "validate_query_params",
                        then_match = { eq = false }
                    }
                },
                {
                    conditional = {
                        if_field = "validate_request",
                        if_match = { eq = true },
                        then_field = "validate_header_params",
                        then_match = { eq = false }
                    }
                },
                {
                    conditional = {
                        if_field = "validate_path_params",
                        if_match = { eq = true },
                        then_field = "validate_route",
                        then_match = { eq = false }
                    }
                },
                {
                    conditional = {
                        if_field = "validate_query_params",
                        if_match = { eq = true },
                        then_field = "validate_route",
                        then_match = { eq = false }
                    }
                },
                {
                    conditional = {
                        if_field = "validate_header_params",
                        if_match = { eq = true },
                        then_field = "validate_route",
                        then_match = { eq = false }
                    }
                },
            },
        },
        },
    },
}

return oas_validator_config_schema
