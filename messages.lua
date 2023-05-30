local command_subscribers = {}

local function decode(data)
	decoded_message = {}
	for k, v in data:gmatch("([^=]+)=([^;]+);") do
    	decoded_message[k] = v
    end

	return decoded_message
end

local function encode(data)
	local encoded_message = ""
    for k, v in pairs(data) do
        encoded_message = encoded_message .. k .. "=" .. v .. ";"
    end

	return encoded_message
end

local function subscribe(name, func)
	if command_subscribers[name] == nil then
		command_subscribers[name] = {}
	end
 
	table.insert(command_subscribers[name], func)
end

local function incoming(peer, msg)
	if msg.cmd and command_subscribers[msg.cmd] then
		for _, handler in pairs(command_subscribers[msg.cmd]) do
			handler(peer, msg)
		end
	end
end

return {
	subscribe = subscribe,
	incoming = incoming,
	encode = encode,
	decode = decode,
}
