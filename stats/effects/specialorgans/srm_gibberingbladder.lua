function init()
	speechTables = root.assetJson(config.getParameter("bladderSpeech"))
	conversations = speechTables.conversations
	statements = speechTables.statements
	
	srm_message = { 
		important = false,
		unique = false,
		type = "generic",
		textSpeed = 30,
		portraitFrames = 2,
		persistTime = 1,
		messageId = sb.makeUuid(),		
		chatterSound = "/sfx/interface/aichatter3_loop.ogg",
	
		portraitImage = "/ai/portraits/gibberingbladder.png:talk.<frame>",
		senderName = "The Gibbering Bladder",
		text = "Dumb shit, you know, the usual. I'm just here to test the functionality of dialogue."
	}
	
	script.setUpdateDelta(600)
end

function update(dt)
	local messageIndex = math.random(1, #conversations+#statements)
	local convo = true
	if (messageIndex > #conversations) then
		messageIndex = messageIndex - #conversations
		convo = false
	end
	if convo then
		messageArray = conversations[messageIndex]
		for i=1,#messageArray,1 do
			srm_message.messageId = sb.makeUuid()
			srm_message.text = messageArray[i]
			world.sendEntityMessage(
				entity.id(),
				"queueRadioMessage",
				srm_message
			)
		end
	else
		srm_message.messageId = sb.makeUuid()
		srm_message.text = statements[messageIndex]
		world.sendEntityMessage(
			entity.id(),
			"queueRadioMessage",
			srm_message
		)
	end
end

function uninit()
	
end