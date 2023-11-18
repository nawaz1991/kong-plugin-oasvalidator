-- Copyright (c) 2023 Muhammad Nawaz
-- Licensed under the MIT License. See LICENSE file for more information.
-- [ END OF LICENSE e2f4afc94de80d2c104519cd5b5e65ca0f4d5b62 ]

local PLUGIN_NAME = "oasvalidator"


-- helper function to validate data against a schema
local validate do
  local validate_entity = require("spec.helpers").validate_plugin_config_schema
  local plugin_schema = require("kong.plugins."..PLUGIN_NAME..".schema")

  function validate(data)
    return validate_entity(data, plugin_schema)
  end
end


describe(PLUGIN_NAME .. ": (schema)", function()

  it("OAS spec file provided", function()
    local ok, err = validate({
      oas_spec_path = "/data/openAPI_example.json",
      })
    assert.is_nil(err)
    assert.is_truthy(ok)
  end)

end)
