local wezterm = require "wezterm"

describe("stargaze.plan", function()
  local plan

  before_each(function()
    wezterm._reset()
    plan = require "stargaze.plan"
  end)

  describe("parse_url", function()
    it("accepts github https urls", function()
      assert.equals("owner/repo", plan.parse_url "https://github.com/owner/repo")
      assert.equals("owner/repo.wz", plan.parse_url "https://github.com/owner/repo.wz.git")
      assert.equals("owner/repo", plan.parse_url "https://github.com/Owner/Repo/")
    end)

    it("skips everything else", function()
      assert.is_nil(plan.parse_url "file:///home/me/plugins/x.wz")
      assert.is_nil(plan.parse_url "git@github.com:owner/repo.git")
      assert.is_nil(plan.parse_url "https://gitlab.com/owner/repo")
      assert.is_nil(plan.parse_url "https://github.com/owner")
      assert.is_nil(plan.parse_url "https://github.com/owner/.git")
    end)
  end)

  describe("diff", function()
    local function cfg(extra)
      return setmetatable(extra or {}, {
        __index = { ignore_repos = {}, ignore_authors = {}, unstar_on_uninstall = false },
      })
    end

    local plugins = {
      { url = "https://github.com/a/one.wz" },
      { url = "https://github.com/a/one.wz.git" },
      { url = "https://github.com/b/two.wz" },
      { url = "file:///local/three.wz" },
    }

    it("stars new github plugins once, deduplicated, skipping file plugins", function()
      local to_star, to_unstar = plan.diff(plugins, {}, cfg())
      assert.same({ "a/one.wz", "b/two.wz" }, to_star)
      assert.same({}, to_unstar)
    end)

    it("skips what is already recorded", function()
      assert.same({ "b/two.wz" }, (plan.diff(plugins, { "a/one.wz" }, cfg())))
    end)

    it("honours ignored repos and authors", function()
      local to_star = plan.diff(plugins, {}, cfg { ignore_repos = { "B/Two.wz" } })
      assert.same({ "a/one.wz" }, to_star)
      to_star = plan.diff(plugins, {}, cfg { ignore_authors = { "a" } })
      assert.same({ "b/two.wz" }, to_star)
    end)

    it("unstars removed plugins only when asked, never ignored ones", function()
      local starred = { "a/one.wz", "gone/x.wz", "ign/y.wz" }
      assert.same({}, select(2, plan.diff(plugins, starred, cfg())))
      local on = cfg { unstar_on_uninstall = true, ignore_authors = { "ign" } }
      assert.same({ "gone/x.wz" }, select(2, plan.diff(plugins, starred, on)))
    end)
  end)
end)
