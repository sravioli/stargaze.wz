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

  it("creates the folder through warp and leaves no temp file", function()
    assert.is_true(state.save(path, { "a/b" }))
    assert.same({ path:match "^(.*)/" }, wezterm._mkdirs)
    for file in io.popen("ls " .. path .. ".* 2>/dev/null"):lines() do
      error("left behind " .. file)
    end
    -- A second save replaces the file instead of failing on it.
    assert.is_true(state.save(path, { "c/d" }))
    assert.same({ "c/d" }, state.load(path))
  end)

  it("round-trips the user's own stars and reads old files without them", function()
    assert.is_true(state.save(path, { "a/b" }, { "c/d" }))
    local starred, theirs = state.load(path)
    assert.same({ "a/b" }, starred)
    assert.same({ "c/d" }, theirs)
    local fh = io.open(path, "w")
    fh:write '{"starred":["a/b"]}'
    fh:close()
    assert.same({}, select(2, state.load(path)))
  end)

  it("keeps the old file when the final rename fails", function()
    assert.is_true(state.save(path, { "a/b" }))
    local rename = os.rename
    local calls = 0
    os.rename = function(from, to) -- luacheck: ignore 122
      calls = calls + 1
      if calls == 1 or calls == 3 then
        return nil, "simulated" -- the plain rename and the retry fail
      end
      return rename(from, to)
    end
    local ok = state.save(path, { "c/d" })
    os.rename = rename -- luacheck: ignore 122
    assert.is_false(ok)
    assert.same({ "a/b" }, state.load(path))
  end)

  it("reports an unwritable path", function()
    assert.is_false((state.save("/nonexistent-dir/x/state.json", { "a/b" })))
  end)
end)
