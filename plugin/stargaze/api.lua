---@module "stargaze"
---@author sravioli
---@license GNU-GPLv2

---Stars the GitHub plugins WezTerm has installed, via the `gh` CLI.
---
---```lua
---local stargaze = wezterm.plugin.require "https://github.com/sravioli/stargaze.wz"
---stargaze.setup { unstar_on_uninstall = true }
---```

local config = require "stargaze.config"
local deps = require "stargaze.deps"
local github = require "stargaze.github"
local logger = require "stargaze.logger"
local plan = require "stargaze.plan"
local state = require "stargaze.state"
local wezterm = require "wezterm"

local STEP_SECONDS = 0.5 -- spacing between API calls; keeps each blocking call short

---@class Stargaze.Api
local M = {}

---@type Stargaze.Config|nil
local current
local registered = false

---@param list string[]
---@param handle string
---@return string[]
local function without(list, handle)
  local out = {}
  for _, item in ipairs(list) do
    if item:lower() ~= handle then
      out[#out + 1] = item
    end
  end
  return out
end

---Run `jobs` one per timer tick. A job returns the new starred list and/or
---the new list of the user's own stars when it changed one, else nil.
---@param jobs (fun(starred: string[], theirs: string[]): string[]|nil, string[]|nil)[]
---@param starred string[]
---@param theirs string[]
---@param path string
---@param i integer
local function drain(jobs, starred, theirs, path, i)
  local job = jobs[i]
  if not job then
    return
  end
  local new_starred, new_theirs = job(starred, theirs)
  if new_starred or new_theirs then
    starred, theirs = new_starred or starred, new_theirs or theirs
    local saved, err = state.save(path, starred, theirs)
    if not saved then
      logger.warn(("unable to write %s: %s"):format(path, tostring(err)))
    end
  end
  wezterm.time.call_after(STEP_SECONDS, function()
    drain(jobs, starred, theirs, path, i + 1)
  end)
end

---Star new plugins and unstar removed ones, once per call.
---Respects `dry_run`. Safe to call by hand. Never raises.
---@param cfg? Stargaze.Config
function M.run(cfg)
  cfg = cfg or current
  if not cfg then
    logger.warn "run() needs setup() first"
    return
  end
  local path = state.path(cfg)
  local starred, theirs = state.load(path)
  local to_star, to_unstar = plan.diff(wezterm.plugin.list(), starred, cfg, theirs)
  if #to_star + #to_unstar == 0 then
    return
  end
  if not cfg.dry_run and not github.available() then
    logger.warn "gh is missing or not logged in (`gh auth login`); nothing starred"
    return
  end

  local jobs = {}
  for _, handle in ipairs(to_star) do
    jobs[#jobs + 1] = function(list, own)
      if cfg.dry_run then
        logger.info(("dry run: would star %s"):format(handle))
        return
      end
      local already, err = github.is_starred(handle)
      if already == nil then
        logger.warn(("cannot check %s: %s"):format(handle, tostring(err))) -- retried next run
        return
      end
      if already then
        -- The user starred it: not ours to unstar, and never asked about again.
        local out = { handle }
        for _, item in ipairs(own) do
          out[#out + 1] = item
        end
        return nil, out
      end
      local ok, star_err = github.star(handle)
      if not ok then
        logger.warn(("cannot star %s: %s"):format(handle, tostring(star_err)))
        return
      end
      logger.info(("starred %s"):format(handle))
      local out = { handle }
      for _, item in ipairs(list) do
        out[#out + 1] = item
      end
      return out
    end
  end
  for _, handle in ipairs(to_unstar) do
    jobs[#jobs + 1] = function(list)
      if cfg.dry_run then
        logger.info(("dry run: would unstar %s"):format(handle))
        return
      end
      local ok, err = github.unstar(handle)
      if not ok then
        logger.warn(("cannot unstar %s: %s"):format(handle, tostring(err)))
        return
      end
      logger.info(("unstarred %s"):format(handle))
      return without(list, handle)
    end
  end
  -- Dry runs change nothing, so skip the state write they would trigger.
  if cfg.dry_run then
    for _, job in ipairs(jobs) do
      job(starred, theirs)
    end
    return
  end
  drain(jobs, starred, theirs, path, 1)
end

---Resolve `opts` and star installed plugins after the first window event.
---Invalid options or a missing warp.wz are logged and leave stargaze off.
---@param opts? Stargaze.Options
---@return boolean ok
function M.setup(opts)
  local ok, resolved = pcall(config.resolve, opts)
  if not ok then
    logger.error(resolved)
    return false
  end
  -- Load dependencies now, while the config is evaluated, so the pass never does.
  local loaded, err = pcall(deps.warp)
  if not loaded then
    logger.error(err)
    return false
  end
  logger.resolve()
  current = resolved

  if not registered then
    registered = true
    wezterm.on("update-status", function()
      -- GLOBAL survives config reloads: one pass per WezTerm process.
      if wezterm.GLOBAL.__stargaze_scheduled or not current then
        return
      end
      wezterm.GLOBAL.__stargaze_scheduled = true
      wezterm.time.call_after(current.delay_seconds, function()
        local pass_ok, pass_err = pcall(M.run)
        if not pass_ok then
          logger.warn(pass_err)
        end
      end)
    end)
  end
  return true
end

return M
