local wezterm = require "wezterm"

describe("stargaze.state", function()
  local state, path

  before_each(function()
    wezterm._reset()
    wezterm._respond = function()
      return true, "", ""
    end
    state = require "stargaze.state"
    path = os.tmpname()
  end)

  after_each(function()
    os.remove(path)
  end)

  it("round-trips the starred list", function()
    assert.is_true(state.save(path, { "a/b", "c/d" }))
    assert.same({ "a/b", "c/d" }, state.load(path))
  end)

  it("treats a missing or corrupt file as empty", function()
    assert.same({}, state.load(path .. ".missing"))
    local fh = io.open(path, "w")
    fh:write "not json"
    fh:close()
    assert.same({}, state.load(path))
  end)

  it("keeps the default path out of the config directory", function()
    local p = state.path {}
    assert.truthy(p:find("stargaze.wz", 1, true))
    assert.is_nil(p:find(wezterm.config_dir, 1, true))
    assert.equals("/x.json", state.path { state_file = "/x.json" })
  end)

  it("reports an unwritable path", function()
    assert.is_false((state.save("/nonexistent-dir/x/state.json", { "a/b" })))
  end)
end)
