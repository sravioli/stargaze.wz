--- Hand-written WezTerm mock. Specs drive child processes through `wezterm._respond`.

-- warden is a real sibling checkout, so specs exercise actual validation.
-- selene: allow(incorrect_standard_library_use)
-- So is warp's filesystem module, minus mkdir, which specs record instead.
for _, base in ipairs { "../warden.wz/plugin/", "../warp.wz/plugin/" } do
  package.path = base .. "?.lua;" .. base .. "?/init.lua;" .. package.path
end

local M = {}

local function real_fs(name)
  return function(...)
    return require("warp.filesystem")[name](...)
  end
end

-- warp.wz stand-in: real filesystem helpers, recorded mkdir, scripted processes.
local warp = {
  filesystem = {
    mkdir = function(path)
      M._mkdirs[#M._mkdirs + 1] = path
      return true
    end,
    write_file = real_fs "write_file",
    data_dir = real_fs "data_dir",
    read_file = real_fs "read_file",
  },
  process = {
    run = function(argv)
      local ok, success, stdout, stderr = pcall(M.run_child_process, argv)
      if not ok then
        return false, "", tostring(success)
      end
      return success == true, stdout or "", stderr or ""
    end,
  },
}

---Reset all recorded state and remove cached stargaze modules.
function M._reset()
  M.GLOBAL = {}
  M.config_dir = "config dir"
  M._handlers = {}
  M._timers = {}
  M._commands = {}
  M._mkdirs = {}
  M._logs = { info = {}, warn = {}, error = {} }
  M._respond = function(args)
    error("unexpected command " .. table.concat(args, " "))
  end
  M._json = {}
  M._warp = warp
  M.home_dir = "/home/user"
  M.target_triple = "x86_64-unknown-linux-gnu"
  M._plugins = {}
  M.plugin = {
    list = function()
      return M._plugins
    end,
    require = function(url)
      if url:find("warp.wz", 1, true) and M._warp then
        return M._warp
      end
      error("plugin.require disabled in specs: " .. tostring(url))
    end,
  }
  M.json_parse = function(text)
    local value = M._json[text]
    if value == nil then
      error "invalid JSON"
    end
    return value
  end
  for name in pairs(package.loaded) do
    if name == "stargaze" or name:match "^stargaze%." then
      package.loaded[name] = nil
    end
  end
end

-- Just enough JSON for `{ starred = { "owner/repo", ... } }`.
M.serde = {
  -- Objects of string lists only: what state.lua writes.
  json_encode = function(value)
    local fields = {}
    for _, key in ipairs { "starred", "theirs" } do
      if value[key] then
        local items = {}
        for i, item in ipairs(value[key]) do
          items[i] = ('"%s"'):format(item)
        end
        fields[#fields + 1] = ('"%s":[%s]'):format(key, table.concat(items, ","))
      end
    end
    return "{" .. table.concat(fields, ",") .. "}"
  end,
  json_decode = function(text)
    if not text:find('"starred"', 1, true) then
      error "invalid JSON"
    end
    local out = {}
    for key, body in text:gmatch '"(%w+)":%[([^%]]*)%]' do
      local list = {}
      for item in body:gmatch '"([^"]+)"' do
        list[#list + 1] = item
      end
      out[key] = list
    end
    return out
  end,
}

function M.on(event, callback)
  M._handlers[event] = M._handlers[event] or {}
  table.insert(M._handlers[event], callback)
end

---Emit an event to every registered handler.
function M._emit(event, ...)
  for _, callback in ipairs(M._handlers[event] or {}) do
    callback(...)
  end
end

M.time = {
  call_after = function(delay, callback)
    table.insert(M._timers, { delay = delay, callback = callback })
  end,
}

---Run the oldest pending timer.
function M._fire()
  local timer = table.remove(M._timers, 1)
  assert(timer, "no pending timer")
  timer.callback()
end

function M.run_child_process(args)
  table.insert(M._commands, args)
  return M._respond(args)
end

for _, level in ipairs { "info", "warn", "error" } do
  M["log_" .. level] = function(message)
    table.insert(M._logs[level], message)
  end
end

M._reset()
package.loaded.wezterm = M

return M
