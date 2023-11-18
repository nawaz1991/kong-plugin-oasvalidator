-- Copyright (c) 2023 Muhammad Nawaz
-- Licensed under the MIT License. See LICENSE file for more information.
-- [ END OF LICENSE e2f4afc94de80d2c104519cd5b5e65ca0f4d5b62 ]

local helpers = require "spec.helpers"
local cjson = require "cjson"


local PLUGIN_NAME = "oasvalidator"


for _, strategy in helpers.all_strategies() do if strategy ~= "cassandra" then
  describe(PLUGIN_NAME .. ": (access) [#" .. strategy .. "]", function()
    local client

    lazy_setup(function()

      local bp = helpers.get_db_utils(strategy == "off" and "postgres" or strategy, nil, { PLUGIN_NAME })

      -- Inject a test route. No need to create a service, there is a default
      -- service which will echo the request.
      local route1 = bp.routes:insert({
        hosts = { "test1.com" },
      })
      -- add the plugin to test to the route we created
      bp.plugins:insert {
        name = PLUGIN_NAME,
        route = { id = route1.id },
        config = { oas_spec_path = "/data/openAPI_example.json",
                   validate_request = false,
                   validate_query_params = true,},
      }

      -- start kong
      assert(helpers.start_kong({
        -- set the strategy
        database   = strategy,
        -- use the custom test template to create a local mock server
        nginx_conf = "spec/fixtures/custom_nginx.template",
        -- make sure our plugin gets loaded
        plugins = "bundled," .. PLUGIN_NAME,
        -- write & load declarative config, only if 'strategy=off'
        declarative_config = strategy == "off" and helpers.make_yaml_file() or nil,
      }))
    end)

    lazy_teardown(function()
      helpers.stop_kong(nil, true)
    end)

    before_each(function()
      client = helpers.proxy_client()
    end)

    after_each(function()
      if client then client:close() end
    end)

    describe("Invalid:", function()
      it("Query param", function()
        local r = client:get("/test/query_array_integer_form_true?124.4565", {
          headers = {
            host = "test1.com"
          }
        })
        -- validate that the request is unsuccessful, response status 400
        assert.response(r).has.status(400)
        local body = assert.res_status(400, r)
        local json = cjson.decode(body)
        assert.equal("INVALID_QUERY_PARAM", json["errorCode"])
      end)
    end)

    describe("Invalid:", function()
      it("Query param", function()
        local r = client:get("/test/query_array_integer_form_true?not_a_number", {
          headers = {
            host = "test1.com"
          }
        })
        -- validate that the request is unsuccessful, response status 400
        assert.response(r).has.status(400)
        local body = assert.res_status(400, r)
        local json = cjson.decode(body)
        assert.equal("INVALID_QUERY_PARAM", json["errorCode"])
      end)
    end)

  end)

end end
