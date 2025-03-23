require'utils'
local enet = require'enet'
local comOut = love.thread.getChannel'comOut'
local comIn = love.thread.getChannel'comIn'

local data = comOut:demand()
local enethost, enetserver
if data.connect then
    enethost = enet.host_create()
    enetserver = enethost:connect(data.connect)
elseif data.host then
    enethost = enet.host_create(data.host)
end

local peers = {}

local maintainConnection = true

while maintainConnection do
    local event = enethost:service(50)
    while event do
        if event.type == 'connect' then
            comIn:push'MSG: connection established'
            table.insert(peers, event.peer)

        elseif event.type == 'disconnect' then
            if table.removeByValue(peers, event.peer) then
                comIn:push'MSG: disconnected'
                if enetserver then
                    maintainConnection = false
                end
            else
                comIn:push'MSG: connection timed out'
                maintainConnection = false
            end

        elseif event.type == 'receive' then
            local data = loadstring(event.data)
            if data then
                comIn:push(data())
            else
                comIn:push(event.data)
            end
        end
        event = enethost:service()
    end

    while comOut and comOut:getCount() ~= 0 do
        pop = comOut:pop()
        if type(pop)=='table' and pop.closeConnection then
            if enetserver then
                enetserver:disconnect()
            else
                for i, peer in ipairs(peers) do
                    peer:disconnect()
                end
            end
            maintainConnection = false
        elseif pop then
            for i, peer in ipairs(peers) do
                peer:send(pop)
            end
        end
    end
end

enethost:flush()
comIn:push{connectionClosed=true}
