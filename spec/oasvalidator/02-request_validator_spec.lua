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
                   validate_request = true },
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

    -- Valid request
    describe("valid request", function()
      it("A test valid request", function()
        local r = client:get("/test/query_two_integer_form_mixed?param1=123&param2=6", {
          headers = {
            host = "test1.com"
          }
        })
        -- validate that the request succeeded, response status 404 as no valid upstream server present
        assert.response(r).has.status(404)
      end)
    end)

    -- Invalid path param
    describe("invalid path", function()
      it("An invalid test request", function()
        local r = client:get("/invalid/path", {
          headers = {
            host = "test1.com"
          }
        })
        -- validate that the request is unsuccessful, response status 400
        assert.response(r).has.status(400)
        local body = assert.res_status(400, r)
        local json = cjson.decode(body)
        assert.equal("INVALID_ROUTE", json["errorCode"])
      end)
    end)

    -- Invalid query param
    describe("invalid query param", function()
      it("An invalid test request", function()
        local r = client:get("/test/query_two_integer_form_mixed?param1=123&param2=not_a_num", {
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

    -- Invalid header
    describe("invalid header", function()
      it("An invalid test request", function()
        local r = client:get("/test/header_single1", {
          headers = {
            host = "test1.com",
            intHeader = "not_a_num"
          }
        })
        -- validate that the request is unsuccessful, response status 400
        assert.response(r).has.status(400)
        local body = assert.res_status(400, r)
        local json = cjson.decode(body)
        assert.equal("INVALID_HEADER_PARAM", json["errorCode"])
      end)
    end)

    -- Invalid body
    describe("invalid body", function()
      it("An invalid test request", function()
        local r = client:post("/test/all/123/abc/str1,str2/field1,0,field2,string?param4=string1&param4=string2&param5=field1,0,field2,string&param6=field1,0,field2,string&param7=field1,0,field2,string&param8=field1,0,field2,string&param9=field1,0,field2,string&param10=false",
                 {
          headers = {
            host = "test1.com"
          },
          body = "{\"field1\":123,\"field2\":\"abc\",\"field3\":[\"abc\",\"def\"],\"field4\":{\"subfield1\":123,\"subfield2\":\"abc\"},\"field5\":{\"subfield1\":123},\"field6\":true,\"field7\":[123,456],\"field8\":[123,456],\"field9\":\"abc\",\"field10\":\"option1\",\"field11\":{\"field\":123},\"field12\":[{\"name\":\"abc\"},{\"name\":\"def\"}]}"
        })
        -- validate that the request is unsuccessful, response status 400
        assert.response(r).has.status(400)
        local body = assert.res_status(400, r)
        local json = cjson.decode(body)
        assert.equal("INVALID_BODY", json["errorCode"])
      end)
    end)

  end)

end end
