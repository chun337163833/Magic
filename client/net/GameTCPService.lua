 -- GameTCPService;
-- 游戏TCP服务;
-- @author crazyjohn;
-- 继承自{@code SocketTCP}

-- 日志
local logger = LoggerFactory:getLogger("GameTCPService")

local GameTCPService = class("GameTCPService", requireAndNew("framework.cc.net.SocketTCP"))
-- gameDecoder
local gameDecoder = requireAndNew("client.net.GameDecoder")

function GameTCPService:ctor( ... )
	-- 调用父类的构造器
	GameTCPService.super:ctor(...)
	-- init SocketTCP
	--self.__socket = requireAndNew("framework.cc.net.SocketTCP")
	self:addEventListener(self.EVENT_CONNECTED, handler(self,self.onConnected))
	self:addEventListener(self.EVENT_DATA, handler(self,self.onReceivedData))
end

-- 建立连接以后回调;
function GameTCPService:onConnected(event)
	logger:debug("Socket status: %s", event.name)
	local userName = "john"
	local password = "john"
	CGPlayerMessage:CG_PLAYER_LOGIN(userName, password)
end

-- 发送消息包;
-- @param messageType 消息类型;
-- @param body 消息体;
function GameTCPService:sendPacket(messageType, body)
	body = body or requireNewByteArray()
	-- wirteBuffer
	local writeBuffer = requireNewByteArray()
	writeBuffer:writeShort(body:getLen() + 4)
	logger:debug("Send message type is: %s (%d)", getMessageTypeName(messageType), messageType)
	writeBuffer:writeShort(messageType)
	if body:getLen() > 0 then
		writeBuffer:writeBytes(body)
	end
	self:send(writeBuffer:getPack())
end

-- 接受到服务器数据;
-- @param event 回调网络事件;
function GameTCPService:onReceivedData(event)
	-- 这里要处理粘包的情况，写一个Decoder
	-- logger:debug("Socket status: %s", event.name)
	gameDecoder:decode(event.data)
end

return GameTCPService