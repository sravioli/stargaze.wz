---@module "stargaze.github"
---@author sravioli
---@license GNU-GPLv2

---Star API calls through the `gh` CLI, run via warp.wz so `gh` is found
---even when WezTerm is launched outside a shell.

local deps = require "stargaze.deps"

local M = {}

---@param args string[]
---@return boolean ok
---@return string stderr
local function gh(args)
  local argv = { "gh", "api" }
  for _, arg in ipairs(args) do
    argv[#argv + 1] = arg
  end
  local ok, _, stderr = deps.warp().process.run(argv)
  return ok, stderr
end

---@return boolean
function M.available()
  return (deps.warp().process.run { "gh", "auth", "status" })
end

---@param handle string `owner/repo`
---@return boolean|nil starred nil when the answer is unknown (network, auth).
---@return string|nil err
function M.is_starred(handle)
  local ok, stderr = gh { "user/starred/" .. handle }
  if ok then
    return true
  end
  if stderr:find("HTTP 404", 1, true) then
    return false
  end
  return nil, stderr
end

---@param handle string
---@return boolean ok
---@return string|nil err
function M.star(handle)
  local ok, stderr = gh { "-X", "PUT", "user/starred/" .. handle }
  return ok, not ok and stderr or nil
end

---@param handle string
---@return boolean ok
---@return string|nil err
function M.unstar(handle)
  local ok, stderr = gh { "-X", "DELETE", "user/starred/" .. handle }
  return ok, not ok and stderr or nil
end

return M
