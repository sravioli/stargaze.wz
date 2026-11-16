local wezterm = require "wezterm"

describe("stargaze.api", function()
  local api, path, calls

  ---Fake gh: `starred` maps handle -> true when already starred on GitHub.
  local function gh(starred)
    wezterm._respond = function(args)
      local line = table.concat(args, " ")
      calls[#calls + 1] = line
      local handle = line:match "user/starred/(%S+)"
      if line == "gh auth status" or args[1] == "mkdir" then
        return true, "", ""
      elseif line:find("-X ", 1, true) then
        return true, "", ""
      elseif starred[handle] then
        return true, "", ""
      end
      return false, "", "gh: Not Found (HTTP 404)"
    end
  end

  local function drain()
    while #wezterm._timers > 0 do
      wezterm._fire()
    end
  end

  local function run(opts)
    opts = opts or {}
    opts.state_file = path
    assert.is_true(api.setup(opts))
    wezterm._emit "update-status"
    drain()
  end

  before_each(function()
    wezterm._reset()
    calls = {}
    path = os.tmpname()
    os.remove(path)
    api = require "stargaze.api"
    wezterm._plugins = {
      { url = "https://github.com/a/one.wz" },
      { url = "file:///local/two.wz" },
    }
  end)

  after_each(function()
    os.remove(path)
  end)

  it("refuses invalid options and stays off", function()
    assert.is_false(api.setup { dry_run = "yes" })
    assert.equals(1, #wezterm._logs.error)
    assert.is_nil(wezterm._handlers["update-status"])
  end)

  it("schedules a single pass per process after the first window event", function()
    assert.is_true(api.setup { state_file = path })
    assert.equals(0, #wezterm._timers)
    wezterm._emit "update-status"
    wezterm._emit "update-status"
    assert.equals(1, #wezterm._timers)
    assert.equals(5, wezterm._timers[1].delay)
  end)

  it("stars new plugins and remembers them", function()
    gh {}
    run()
    assert.same({ "a/one.wz" }, require("stargaze.state").load(path))
    assert.truthy(table.concat(calls, "\n"):find("-X PUT user/starred/a/one.wz", 1, true))
    for _, call in ipairs(calls) do
      assert.is_nil(call:find("two.wz", 1, true))
    end
  end)

  it("never records or stars a repo the user already starred", function()
    gh { ["a/one.wz"] = true }
    run()
    assert.same({}, require("stargaze.state").load(path))
    assert.is_nil(table.concat(calls, "\n"):find("-X PUT", 1, true))
  end)

  it("dry run logs and changes nothing", function()
    gh {}
    run { dry_run = true }
    assert.truthy(wezterm._logs.info[1]:find("would star a/one.wz", 1, true))
    assert.is_nil(table.concat(calls, "\n"):find("-X", 1, true))
    assert.is_nil(io.open(path, "r"))
  end)

  it("unstars removed plugins only when enabled", function()
    require("stargaze.state").save(path, { "gone/x.wz", "a/one.wz" })
    gh { ["a/one.wz"] = true }
    run()
    assert.is_nil(table.concat(calls, "\n"):find("DELETE", 1, true))
    wezterm._reset()
    api = require "stargaze.api"
    wezterm._plugins = { { url = "https://github.com/a/one.wz" } }
    gh {}
    run { unstar_on_uninstall = true }
    assert.truthy(table.concat(calls, "\n"):find("-X DELETE user/starred/gone/x.wz", 1, true))
    assert.same({ "a/one.wz" }, require("stargaze.state").load(path))
  end)

  it("does nothing, with one warning, when gh is unavailable", function()
    wezterm._respond = function()
      return false, "", "not found"
    end
    run()
    assert.equals(1, #wezterm._logs.warn)
    assert.is_nil(io.open(path, "r"))
  end)

  it("retries later when a star fails", function()
    wezterm._respond = function(args)
      local line = table.concat(args, " ")
      if line:find("-X PUT", 1, true) then
        return false, "", "HTTP 500"
      elseif line == "gh auth status" then
        return true, "", ""
      end
      return false, "", "gh: Not Found (HTTP 404)"
    end
    run()
    assert.same({}, require("stargaze.state").load(path))
    assert.truthy(wezterm._logs.warn[1]:find("cannot star a/one.wz", 1, true))
  end)
end)
