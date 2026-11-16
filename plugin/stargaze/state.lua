---@module "stargaze.state"
---@author sravioli
---@license GNU-GPLv2

---Remembers which repositories stargaze starred, in a JSON file in the user
---data directory (never the config directory, which WezTerm watches).

local deps = require "stargaze.deps"
local wezterm = require "wezterm"

local M = {}

-- selene: allow(incorrect_standard_library_use)
local SEP = package.config:sub(1, 1)

---@param cfg Stargaze.Config
---@return string
function M.path(cfg)
  if cfg.state_file then
    return cfg.state_file
  end
  local base = os.getenv "XDG_DATA_HOME"
  if not base or base == "" then
    if SEP == "\\" then
      base = os.getenv "LOCALAPPDATA" or (wezterm.home_dir .. "\\AppData\\Local")
    else
      base = wezterm.home_dir .. "/.local/share"
    end
  end
  return table.concat({ base, "wezterm", "stargaze.wz", "state.json" }, SEP)
end

---@param path string
---@return string[] starred Empty when the file is missing or unreadable.
function M.load(path)
  local fh = io.open(path, "rb")
  if not fh then
    return {}
  end
  local text = fh:read "*a"
  fh:close()
  local ok, data = pcall(wezterm.serde.json_decode, text)
  if not ok or type(data) ~= "table" or type(data.starred) ~= "table" then
    return {}
  end
  return data.starred
end

---@param path string
---@param starred string[]
---@return boolean ok
function M.save(path, starred)
  local dir = path:match "^(.*)[/\\]" or "."
  local argv = SEP == "\\" and { "cmd", "/c", "mkdir", dir } or { "mkdir", "-p", dir }
  deps.warp().process.run(argv) -- fails harmlessly when the directory exists

  local fh, err = io.open(path, "w")
  if not fh then
    return false, err
  end
  local ok, write_err = fh:write(wezterm.serde.json_encode { starred = starred })
  fh:close()
  return ok ~= nil, write_err
end

return M
