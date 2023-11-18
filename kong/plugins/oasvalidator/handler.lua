-- Copyright (c) 2023 Muhammad Nawaz
-- Licensed under the MIT License. See LICENSE file for more information.
-- [ END OF LICENSE e2f4afc94de80d2c104519cd5b5e65ca0f4d5b62 ]

local oasvalidator = require("oasvalidator")

local kong_oasvalidator = {
    PRIORITY = 1000,
    VERSION = "1.0.0",
}

local validators
local prefix_len = 1

function kong_oasvalidator:init_worker()
end

local function handleError(err_code, err_msg)
    kong.log.err("error_code: ", err_code, " error_message: ", err_msg)
    return kong.response.exit(400, err_msg, {["Content-Type"] = "application/json"})
end

function kong_oasvalidator:access(conf)
    if not validators then
        validators = oasvalidator.GetValidators(conf.oas_spec_path)
        local prefix = kong.request.get_forwarded_prefix()
        prefix_len = prefix and (#prefix + 1) or 1
    end

    local method = kong.request.get_method()
    local path = kong.request.get_path_with_query():sub(prefix_len)
    local err_code, err_msg

    if conf.validate_request then
        local body = kong.request.get_raw_body()
        local headers = kong.request.get_headers()
        err_code, err_msg = validators:ValidateRequest(method, path, body, headers)
        if err_code ~= 0 then return handleError(err_code, err_msg) end
    else
        if conf.validate_body then
            local body = kong.request.get_raw_body()
            err_code, err_msg = validators:ValidateBody(method, path, body)
            if err_code ~= 0 then return handleError(err_code, err_msg) end
        end

        if conf.validate_path_params then
            err_code, err_msg = validators:ValidatePathParam(method, path)
            if err_code ~= 0 then return handleError(err_code, err_msg) end
        end

        if conf.validate_query_params then
            err_code, err_msg = validators:ValidateQueryParam(method, path)
            if err_code ~= 0 then return handleError(err_code, err_msg) end
        end

        if conf.validate_header_params then
            local headers = kong.request.get_headers()
            err_code, err_msg = validators:ValidateHeaders(method, path, headers)
            if err_code ~= 0 then return handleError(err_code, err_msg) end
        end

        if conf.validate_route then
            err_code, err_msg = validators:ValidateRoute(method, path)
            if err_code ~= 0 then return handleError(err_code, err_msg) end
        end
    end
end

return kong_oasvalidator
