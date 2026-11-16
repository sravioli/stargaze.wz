---@module "stargaze.plan"
---@author sravioli
---@license GNU-GPLv2

---Pure decisions: which installed plugins are GitHub repositories, and what
---to star or unstar. No I/O, so it is trivially testable.

local M = {}

---`https://github.com/owner/repo[.git]` -> `owner/repo` (lowercase, GitHub
---names are case-insensitive). Anything else (file://, ssh, other hosts)
---returns nil.
---@param url any
---@return string|nil handle
---@return string|nil owner
function M.parse_url(url)
  local owner, repo = tostring(url):match "^https://github%.com/([%w%-%._]+)/([%w%-%._]+)/?$"
  if not owner then
    return nil
  end
  repo = repo:gsub("%.git$", "")
  if repo == "" then
    return nil
  end
  return (owner .. "/" .. repo):lower(), owner:lower()
end

---@param list string[]
---@return table<string, true>
local function set(list)
  local out = {}
  for _, item in ipairs(list) do
    out[item:lower()] = true
  end
  return out
end

---@param plugins { url: string }[] Entries from `wezterm.plugin.list()`.
---@param starred string[] Handles this plugin starred earlier.
---@param cfg Stargaze.Config
---@return string[] to_star
---@return string[] to_unstar
function M.diff(plugins, starred, cfg)
  local ignored_repos, ignored_authors = set(cfg.ignore_repos), set(cfg.ignore_authors)
  local function ignored(handle)
    return ignored_repos[handle] or ignored_authors[handle:match "^[^/]+"]
  end

  local installed, order = {}, {}
  for _, plugin in ipairs(plugins) do
    local handle = M.parse_url(plugin.url)
    if handle and not installed[handle] then
      installed[handle] = true
      order[#order + 1] = handle
    end
  end

  local recorded = set(starred)
  local to_star, to_unstar = {}, {}
  for _, handle in ipairs(order) do
    if not recorded[handle] and not ignored(handle) then
      to_star[#to_star + 1] = handle
    end
  end
  if cfg.unstar_on_uninstall then
    for _, handle in ipairs(starred) do
      handle = handle:lower()
      if not installed[handle] and not ignored(handle) then
        to_unstar[#to_unstar + 1] = handle
      end
    end
  end
  return to_star, to_unstar
end

return M
