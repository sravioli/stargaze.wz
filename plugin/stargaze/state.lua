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
---@return string|nil err
function M.save(path, starred)
  local dir = path:match "^(.*)[/\\]"
  if dir and dir ~= "" then
    -- warp skips existing folders and refuses cmd.exe special characters.
    local made, mkdir_err = deps.warp().filesystem.mkdir(dir)
    if not made then
      return false, mkdir_err
    end
  end

  -- Write a temp file, then rename it: a crash mid-write must not empty the
  -- state, or stargaze forgets which stars it added.
  local tmp = path .. ".tmp"
  local fh, err = io.open(tmp, "w")
  if not fh then
    return false, err
  end
  local wrote, write_err = fh:write(wezterm.serde.json_encode { starred = starred })
  local closed, close_err = fh:close()
  if not (wrote and closed) then
    os.remove(tmp)
    return false, write_err or close_err
  end
  local renamed, rename_err = os.rename(tmp, path)
  if not renamed then
    -- Windows: rename does not replace an existing file.
    os.remove(path)
    renamed, rename_err = os.rename(tmp, path)
  end
  if not renamed then
    os.remove(tmp)
  end
  return renamed == true, rename_err
end

return M
