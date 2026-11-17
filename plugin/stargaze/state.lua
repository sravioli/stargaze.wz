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

---@param list any
---@return string[]
local function strings(list)
  local out = {}
  if type(list) == "table" then
    for _, item in ipairs(list) do
      if type(item) == "string" then
        out[#out + 1] = item
      end
    end
  end
  return out
end

---@param path string
---@return string[] starred Repositories stargaze starred. Empty when the file is missing or unreadable.
---@return string[] theirs  Repositories the user had already starred: never ours to unstar.
function M.load(path)
  local fh = io.open(path, "rb")
  if not fh then
    return {}, {}
  end
  local text = fh:read "*a"
  fh:close()
  local ok, data = pcall(wezterm.serde.json_decode, text)
  if not ok or type(data) ~= "table" or type(data.starred) ~= "table" then
    return {}, {}
  end
  return data.starred, strings(data.theirs)
end

local seq = 0

---Unique sibling path, so two WezTerm processes never share a temp file.
---@param path string
---@param suffix string
---@return string
local function sibling(path, suffix)
  seq = seq + 1
  return ("%s.%x%x%x%s"):format(path, os.time(), math.random(0, 0x7fffffff), seq, suffix)
end

---@param path string
---@param starred string[]
---@param theirs? string[]
---@return boolean ok
---@return string|nil err
function M.save(path, starred, theirs)
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
  local tmp = sibling(path, ".tmp")
  local fh, err = io.open(tmp, "w")
  if not fh then
    return false, err
  end
  local body = wezterm.serde.json_encode { starred = starred, theirs = theirs or {} }
  local wrote, write_err = fh:write(body)
  local closed, close_err = fh:close()
  if not (wrote and closed) then
    os.remove(tmp)
    return false, write_err or close_err
  end
  if os.rename(tmp, path) then
    return true
  end
  -- Windows: rename does not replace a file. Move the old one aside first and
  -- put it back if the second rename fails, so the state is never missing.
  local aside = sibling(path, ".old")
  local moved = os.rename(path, aside)
  local renamed, rename_err = os.rename(tmp, path)
  if renamed then
    if moved then
      os.remove(aside)
    end
    return true
  end
  if moved then
    os.rename(aside, path)
  end
  os.remove(tmp)
  return false, rename_err
end

return M
