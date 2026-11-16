local wezterm = require "wezterm"

describe("stargaze.config", function()
  local config

  before_each(function()
    wezterm._reset()
    config = require "stargaze.config"
  end)

  it("fills in defaults", function()
    assert.same({
      ignore_repos = {},
      ignore_authors = {},
      unstar_on_uninstall = false,
      dry_run = false,
      delay_seconds = 5,
    }, config.resolve())
  end)

  it("keeps explicit options", function()
    local cfg = config.resolve {
      ignore = { repos = { "a/b.wz" }, authors = { "c" } },
      unstar_on_uninstall = true,
      dry_run = true,
      delay_seconds = 0,
      state_file = "/tmp/x.json",
    }
    assert.same({ "a/b.wz" }, cfg.ignore_repos)
    assert.same({ "c" }, cfg.ignore_authors)
    assert.is_true(cfg.unstar_on_uninstall)
    assert.is_true(cfg.dry_run)
    assert.equals(0, cfg.delay_seconds)
    assert.equals("/tmp/x.json", cfg.state_file)
  end)

  it("rejects invalid options with their path", function()
    local ok, err = pcall(config.resolve, { ignore = { repos = { "not-a-repo" } } })
    assert.is_false(ok)
    assert.truthy(tostring(err):find("ignore", 1, true))
    assert.is_false((pcall(config.resolve, { dry_run = "yes" })))
    assert.is_false((pcall(config.resolve, "nope")))
  end)

  it("skips validation when asked", function()
    assert.is_true((pcall(config.resolve, { validate = false, dry_run = "yes" })))
  end)
end)
