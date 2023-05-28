local command_subscribers = {}
 
local function subscribe(name, func)
	if command_subscribers[name] == nil then
		command_subscribers[name] = {}
	end
 
	table.insert(command_subscribers[name], func)
end

local function incoming(msg)
	if msg.cmd and command_subscribers[msg.cmd] then
		for _, handler in pairs(command_subscribers[msg.cmd]) do
			handler(msg)
		end
	end
end

return {
	subscribe = subscribe,
	incoming = incoming
}