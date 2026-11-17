---@module "stargaze.state"
---@author sravioli
---@license GNU-GPLv2

---Remembers which repositories stargaze starred, in a JSON file in the user
---data directory (never the config directory, which WezTerm watches).

local deps = require "stargaze.deps"
local wezterm = require "wezterm"

local M = {}

---@param cfg Stargaze.Config
---@return string
function M.path(cfg)
  if cfg.state_file then
    return cfg.state_file
  end
  return (deps.warp().filesystem.data_dir() or ".") .. "/stargaze.wz/state.json"
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
  local text = deps.warp().filesystem.read_file(path)
  if not text then
    return {}, {}
  end
  local ok, data = pcall(wezterm.serde.json_decode, text)
  if not ok or type(data) ~= "table" or type(data.starred) ~= "table" then
    return {}, {}
  end
  return data.starred, strings(data.theirs)
end

---@param path string
---@param starred string[]
---@param theirs? string[]
---@return boolean ok
---@return string|nil err
function M.save(path, starred, theirs)
  local fs = deps.warp().filesystem
  local dir = path:match "^(.*)[/\\]"
  if dir and dir ~= "" then
    -- warp skips existing folders and refuses cmd.exe special characters.
    local made, mkdir_err = fs.mkdir(dir)
    if not made then
      return false, mkdir_err
    end
  end

  -- Atomic: a crash mid-write must not empty the state, or stargaze forgets
  -- which stars it added.
  local body = wezterm.serde.json_encode { starred = starred, theirs = theirs or {} }
  return fs.write_file(path, body)
end

return M
