
display.setStatusBar(display.HiddenStatusBar)

local physics = require('physics')
physics.start()
physics.setGravity(0,0)

-- Graphics
-- [Background]
local background

-- [Game Menu View]
local title
local startBtn;
local creditsBtn;

-- [MenunView Group]
local menuView 

-- [Score&Lives]
local live
local livesTF
local lives = 3
local scoreTF
local score = 0
local alertScore

-- [Blocks group,Player]
local blocks 
local player 

-- [CreditsView]
local credits

-- [GameView Group]
local gameView 

-- Variables
local moveSpeed = 2
local blockTimer
local liveTimer

-- Functions Declaration
local Main = {}
local addGameMenuView = {}
local initialListeners = {}
local showCredits = {}
local hideCredits = {}
local destroyCredits = {}
local gameView = {}
local addInitialBlocks = {}
local addPlayer = {}
local movePlayer = {}
local addBlock = {}
local addLive  = {}
local gameListeners = {}
local update = {}
local collisionHandler = {}
local showAlert = {}

function startGame()
	addGameMenuView()
end

function addGameMenuView()
	background = display.newImage('bg.png')
	title = display.newImage('titleBg.png')
	startBtn = display.newImage('startBtn.png')
	startBtn.x = display.contentCenterX
	startBtn.y = display.contentCenterY
	startBtn.name = 'startBtn'
	creditsBtn = display.newImage('creditsBtn.png')
	creditsBtn.x = display.contentCenterX
	creditsBtn.y = display.contentCenterY + 60
	creditsBtn.name = 'creditsBtn'

	menuView = display.newGroup()
	menuView:insert(title)
	menuView:insert(startBtn)
	menuView:insert(creditsBtn)
	initialListeners('add')
end


function initialListeners(action)
	if(action == 'add') then
		startBtn:addEventListener('tap',gameView)
		creditsBtn:addEventListener('tap',showCredits)
	else 
		startBtn:removeEventListener('tap',gameView)
		creditsBtn:removeEventListener('tap',showCredits)
	end
end

function showCredits()
	credits = display.newImage('creditsView.png')
	transition.from(credits,{time = 400,x = display.contentWidth*2,transition = easing.outExpo})
	credits:addEventListener('tap',hideCredits)
	startBtn.isVisible = false
	credotsBtn.isVisible = false
end

function hideCredits()
	startBtn.isVisible  = true
	creditsBtn.isVisible = true
	transition.to(credits,{time = 600,x = display.contentWidth*2,transition = easing.outExpo,onComplete = destroyCredits})
end

function destroyCredits()
	credits:removeEventListener('tap',hideCredits)
	display.remove(credits)
	credits = nil
end

function gameView()
	initialListeners('rmv')
	transition.to(menuView,{time = 500,x = -menuView.height,onComplete = function()display.remove(menuView)menuView = nil addInitialBlocks(3)end})
	--Score Text
	scoreTF = display.newText('0',303,22,system.nativeFont,12)
	scoreTF:setTextColor(68,68,68)
	--Lives Text
	livesTF = display.newText('x3',289,56,system.nativeFont,12)
	livesTF:setTextColor(245,248,248)
end

function addInitialBlocks(n)
	blocks = display.newGroup()
	for i = 1, n do
		local block = display.newImage('block.png')
		block.x = math.floor(math.random()*(display.contentWidth - block.width))
		block.y = (display.contentHeight*0.5) + math.floor(math.random()*(display.contentHeight*0.5))
		physics.addBody(block,{density = 1,bounce = 0})
		block.bodyType = 'static'
		blocks:insert(block)
	end
	addPlayer()
end

function addPlayer()
	player = display.newImage('player.png')
	player.x = (display.contentWidth*0.5)
	player.y = display.height
	physics.addBody(player,{density = 1,friction = 0,bounce = 0})
	player.isFixedRotation = true
	gameListeners('add')
end

function movePlayer:accelerometer(e)
	-- Accelerometer Movement
	
	player.x = display.contentCenterX + (display.contentCenterX * (e.xGravity*3))
	
	-- Borders 
	
	if((player.x - player.width * 0.5) < 0) then
		player.x = player.width * 0.5
	elseif((player.x + player.width * 0.5) > display.contentWidth) then
		player.x = display.contentWidth - player.width * 0.5
	end
end

function addBlock()
	local r = math.floor(math.random()*4)
	if(r ~= 0) then
		local block = display.newImage('block.png')
		block.x = math.random()*(display.contentWidth - (block.width * 0.5))
		block.y = display.contentHeight + block.height
		physics.addBody(block ,{density = 1, bounce = 0})
		blocks:insert(block)
	else
		local badBlock = display.newImage('badBlock.png')
		badBlock.name = 'bad'
		physics.addBody(badBlock,{density = 1 ,bounce = 0})
		badBlock.bodyType = 'static'
		badBlock.x = math.random() * (display.contentWidth - (badBlock.width * 0.5))
		badBlock.y = display.contentHeight + badBlock.height
		blocks:insert(badBlock)
	end
end

function addLive()
	live = display.newImage('live.png')
	live.name = 'live'
	live.x = blocks[blocks.numChildren - 1].x
	live.y = blocks[blocks.numChildren - 1].y - live.height
	physics.addBody(live,{density = 1,friction = 0,bounce = 0})
end


function gameListeners(action)
	if(action == 'add') then
		Runtime:addEventListener('accelerometer',movePlayer)
		Runtime:addEventListener('enterFrame',update)
		blockTimer =  timer.performWithDelay(800,addBlock,0)
		liveTimer = timer.performWithDelay(8000,addLive,0)
		player:addEventListener('collision',collisionHandler)
	else
		Runtime.removeEventListener('accelerometer',movePlayer)
		Runtime.removeEventListener('enterFrame',update)
		timer.cancel(blockTimer)
		timer.cancel(liveTimer)
		blockTimer = nil
		liveTimer = nil
		player:removeEventListener('collision',collisionHandler)
	end
end

function update(e)
	--Player Movement
	player.y = player.y + moveSpeed
	--Score
	score = score + 1
	scoreTF.text = score
	--Lose lives
	if(player.y > display.contentHeight or player.y < -5) then
		player.x = blocks[blocks.numChildren - 1].x
		player.y = blocks[blocks.numChildren - 1].y - player.height
		lives = lives - 1
		livesTF.text = 'x' .. lives
	end

	--Check for game over
	if(lives < 0) then
		showAlert()
	end

	--Levels
	if(score > 500 and score < 502) then
		moveSpeed = 3
	end
end

function collisionHandler(e)
	--Grab Lives
	if(e.other.name == 'live') then
		display.remove(e.other)
		e.other = nil
		lives = lives + 1
		livesTF.text = 'x' .. lives
	end
	--Bad Blocks
	if(e.other.name == 'bad') then
		lives = lives - 1
		livesTF.text = 'x' .. lives
	end
end

function  showAlert()
	gameListeners('rmv')
	local alert = display.newImage('alert.png',70,190)
	alertScore = display.newText(scoreTF.text .. '!',134,240,native.systemFontBold,30)
	livesTF.text = ''
	transition.from(alert,{time = 200,xScale = 0.8})
end

startGame()

















































