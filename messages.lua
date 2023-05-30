local message_subscribers = {}

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
	if message_subscribers[name] == nil then
		message_subscribers[name] = {}
	end
 
	table.insert(message_subscribers[name], func)
end

local function incoming(peer, msg)
	local fired_handlers = 0
	if msg.cmd and message_subscribers[msg.cmd] then
		for _, handler in pairs(message_subscribers[msg.cmd]) do
			handler(peer, msg)
			fired_handlers = fired_handlers + 1
		end
	end

	return fired_handlers
end

return {
	subscribe = subscribe,
	incoming = incoming,
	encode = encode,
	decode = decode,
}
