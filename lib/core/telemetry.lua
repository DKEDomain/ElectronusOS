---------------------------------------
-- PROGRAM TELEMETRY API
---------------------------------------

local protocol = nil
local protocolNamespace = 'eos.telemetry'
local modemSide = settings.get('eos.modem_side')

-- Checks and opens rednet
-- @return void
local function openRednet()
    if not rednet.isOpen(modemSide) then
        rednet.open(modemSide)
    end
end

-- Receive telemetry
-- @return void
local function receive()
    openRednet()

    while true do
        local senderId, message = rednet.receive(protocol)
        os.queueEvent(protocolNamespace..protocol, message, senderId)
    end
end

-- Event watcher to exit telemetry
-- @return void
local function exitTelemetry()
    local exit = nil

    while not exit do
        local key = os.pullEvent()

        if key == 'eos.system.telemetry.exit' then
            exit = true
        end
    end
end

-- Listen and handle incoming telemetry data
-- @param string listenProtocol- protocol to listen on
-- @return void
local function listen(listenProtocol)
    protocol = listenProtocol
    
    parallel.waitForAny(exitTelemetry, receive)
end

-- Send telemetry to recipient
-- @param string - recipient id
-- @param string - message to send
local function send(recipient, message, sendProtocol)
    openRednet()

    rednet.send(recipient, message, protocolNamespace..'.'..sendProtocol)
end

return {
    protocolNamespace = protocolNamespace,
    listen = listen,
    send = send,
}
