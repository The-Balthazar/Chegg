local comOut, comIn, peerType, enetThread

function GetPeerType()
    return peerType
end

function EnetInit(ip, host)
    if peerType then return end
    comOut, comIn = love.thread.getChannel'comOut', love.thread.getChannel'comIn'
    local i, p = (ip:match'^([%w%.]+)' or 'localhost'), (ip:match'(:[%d]+)' or ':25565')
    if host then
        comOut:push{ host = "*"..p }
        peerType = 'host'
    else
        comOut:push{ connect = i..p }
        peerType = 'client'
    end

    enetThread = love.thread.newThread'enet/thread.lua':start()
end

function EnetHandle(localHandler)
    while comIn and comIn:getCount() ~= 0 do

        local data = comIn:pop()

        if type(data) == 'table' and data.connectionClosed then
            peerType = nil
            comIn:clear()
            comIn:release()
            comIn = nil
            comOut:clear()
            comOut:release()
            comOut = nil
            enetThread = nil
            print('Connection closed', 'Dissconnecting')

        elseif data and localHandler then
            localHandler(data)

        end
    end
end

function EnetDisconnect()
    if comOut then
        comOut:push{closeConnection=true}
        return true
    end
end
