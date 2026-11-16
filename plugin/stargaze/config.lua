---@module "stargaze.config"
---@author sravioli
---@license GNU-GPLv2

---@class Stargaze.Ignore
---@field repos? string[] Repositories to leave alone, as `owner/name`.
---@field authors? string[] Owners whose repositories are left alone.

---@class Stargaze.Options
---@field ignore? Stargaze.Ignore Never star (or unstar) these.
---@field unstar_on_uninstall? boolean Unstar what this plugin starred once it is uninstalled. Default false.
---@field dry_run? boolean Only log what would be starred or unstarred. Default false.
---@field delay_seconds? number Seconds to wait after the first window event. Default 5.
---@field state_file? string Where starred repositories are remembered. Defaults to the user data directory.
---@field validate? boolean Set to `false` to skip validation and never load warden. Default true.

---@class Stargaze.Config
---@field ignore_repos string[]
---@field ignore_authors string[]
---@field unstar_on_uninstall boolean
---@field dry_run boolean
---@field delay_seconds number
---@field state_file? string

local M = {}

local REPO = "^[%w%-%._]+/[%w%-%._]+$"
local AUTHOR = "^[%w%-%._]+$"

---@return Warden.Schema
local function schema()
  local w = require("stargaze.deps").warden()
  return w.object({
    ignore = w.object({
      repos = w.array(w.string():matches(REPO)):optional(),
      authors = w.array(w.string():matches(AUTHOR)):optional(),
    }):optional(),
    unstar_on_uninstall = w.boolean():optional(),
    dry_run = w.boolean():optional(),
    delay_seconds = w.number():min(0):optional(),
    state_file = w.string():not_empty():optional(),
    validate = w.boolean():optional(),
  }):unknown "warn"
end

---Validate options and fill in defaults. Raises on the first invalid option
---and warns about unknown ones. Performs no I/O beyond logging.
---@param opts? Stargaze.Options
---@return Stargaze.Config
function M.resolve(opts)
  opts = opts or {}
  if type(opts) ~= "table" then
    error("Options must be a table.", 0)
  end
  if opts.validate ~= false then
    local result = schema():safe_parse(opts)
    if not result.ok then
      local issue = result.issues[1]
      error(("Invalid option `%s`: %s"):format(issue.path_text, issue.message), 0)
    end
    result:log { warn = require("stargaze.logger").warn }
  end

  local ignore = opts.ignore or {}
  return {
    ignore_repos = ignore.repos or {},
    ignore_authors = ignore.authors or {},
    unstar_on_uninstall = opts.unstar_on_uninstall == true,
    dry_run = opts.dry_run == true,
    delay_seconds = opts.delay_seconds or 5,
    state_file = opts.state_file,
  }
end

return M
