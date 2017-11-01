_print = print
_error = error
--_assert = assert

--_print("print", print)
--_print("error", error)
--_print("assert", assert)

trace = {}

function hook()
  local info = debug.getinfo(2)
  local upperinfo = debug.getinfo(3)
  if info == nil then
    return
  end

  local source = info.source:sub(2) .. ":" .. info.currentline
  if info.what == "C" then
    source = "[C]"
  end

  --[[if info.name then
    source = source .. " " .. info.name
  end]]

  if upperinfo.name then
    source = source .. " in function " .. upperinfo.name
  end

  trace[0] = "\t" .. source
  local trace_copy = trace
  for i,v in ipairs(trace_copy) do
    if i < 10 then
      trace[i + 1] = v
      trace[i] = nil
    end
  end
end

debug.sethook(hook, "c")

function traceback()
  return table.concat(trace, "\n")
end

function print(...)
  local data = {...}
  if not IsInToolsMode() then
    CustomGameEventManager:Send_ServerToAllClients("vconsole", {
      type = "print",
      data = data
    })
    data[1] = '[Server] ' .. data[1]
  end
  _print(unpack(data))
end

function error(...)
  local args = {...}
  local offset = args[2] or 2
  local info = debug.getinfo(offset, "Sl")
  local data = {
    "Script Runtime Error: " .. info.source:sub(2) .. ":" .. info.currentline .. ": " .. args[1],
    debug.traceback()
  }
  if not IsInToolsMode() then
    CustomGameEventManager:Send_ServerToAllClients("vconsole", {
      type = "error",
      data = data -- pass traceback to panorma
    })
  end
  for _,v in pairs(data) do
    _print(tostring(v))
  end
  _error(unpack({...}))
end

--_print("print", print)
--_print("error", error)
--_print("assert", assert)
