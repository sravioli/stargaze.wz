local wezterm = require "wezterm"

describe("stargaze.github", function()
  local github

  before_each(function()
    wezterm._reset()
    github = require "stargaze.github"
  end)

  it("tells starred, not starred and unknown apart", function()
    wezterm._respond = function()
      return true, "", ""
    end
    assert.is_true(github.is_starred "a/b")
    wezterm._respond = function()
      return false, "", "gh: Not Found (HTTP 404)"
    end
    assert.is_false(github.is_starred "a/b")
    wezterm._respond = function()
      return false, "", "gh: Bad credentials (HTTP 401)"
    end
    local starred, err = github.is_starred "a/b"
    assert.is_nil(starred)
    assert.truthy(err:find("401", 1, true))
  end)

  it("uses PUT to star and DELETE to unstar", function()
    wezterm._respond = function()
      return true, "", ""
    end
    github.star "a/b"
    github.unstar "a/b"
    assert.same({ "gh", "api", "-X", "PUT", "user/starred/a/b" }, wezterm._commands[1])
    assert.same({ "gh", "api", "-X", "DELETE", "user/starred/a/b" }, wezterm._commands[2])
  end)

  it("reports gh failures", function()
    wezterm._respond = function()
      return false, "", "boom"
    end
    local ok, err = github.star "a/b"
    assert.is_false(ok)
    assert.equals("boom", err)
    assert.is_false(github.available())
  end)
end)
