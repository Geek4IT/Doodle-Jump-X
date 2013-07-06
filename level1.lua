module(..., package.seeall)


function new()	

display.setStatusBar(display.HiddenStatusBar)

level_name = "Friendly Level Name"
level_id = "level1" 
		
local localGroup = display.newGroup()		
	
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
local level_menu = display.newGroup()
	level_menu:setReferencePoint(display.CenterReferencePoint);
	level_menu.alpha = 0;

-- pop menu function
function popMenu(e)
	transition.to(level_menu, {delay=200, time=500, alpha=1});	
end	

-- close the menu if unpausing
function closeMenu(e)
	transition.to(level_menu, {delay=200, time=500, alpha=0});	
end

-- change scene function
function changeScene(e)
	if(e.phase == "ended") then
		local path = system.pathForFile( "loadlast.txt", system.DocumentsDirectory )
		local file = io.open( path, "r" )
		if file then
		  file = io.open( path, "w" )
		  file:write(level_id)
		    io.close( file )
		else
		 -- create file b/c it doesn't exist yet
			file = io.open( path, "w" )
			file:write(level_id)
			io.close( file )
		end
		
		director:changeScene(e.target.scene, "moveFromRight");
	end
end
	

function addGameMenuView()
	background = display.newImage('level1Bg.jpg')
	localGroup:insert(background)

	--Score Text
	scoreTF = display.newText('0',303,22,system.nativeFont,12)
	scoreTF:setTextColor(68,68,68)
	--Lives Text
	livesTF = display.newText('x3',289,56,system.nativeFont,12)
	livesTF:setTextColor(245,248,248)

	addInitialBlocks(3)
	addOptionsMenu()

end

function addOptionsMenu()
	local optionsBtn = display.newImage('optionsBtn.png')
	optionsBtn.x = optionsBtn.width/2;
	optionsBtn.y =optionsBtn.height/2;
	optionsBtn.scene = "apps";
	optionsBtn:addEventListener("touch", popMenu);	
		
local black_out = display.newRect(0,0,_w,_h);	
	black_out:setFillColor(0,0,0);
	black_out.alpha = .8;
	level_menu:insert(black_out);

local menuBg = display.newImage('menuBg.png')
	menuBg:setReferencePoint( display.CenterReferencePoint )
	menuBg.x = _w/2
	menuBg.y = _h/2
	level_menu:insert(menuBg)
	

local backBtn = display.newText("Back", 0, 0, native.systemFontBold, 24);
	backBtn:setReferencePoint(display.CenterReferencePoint);
	backBtn:setTextColor(205,0,0,255)
	backBtn.x = _w/2;
	backBtn.y = _h/2 - 45;
	backBtn.scene = "index";
	level_menu:insert(backBtn);
	backBtn:addEventListener("touch", changeScene);

local restartBtn = display.newText("Restart", 0, 0, native.systemFontBold, 24);
	restartBtn:setReferencePoint(display.CenterReferencePoint);
	restartBtn:setTextColor(205,0,0,255)
	restartBtn.x = _w/2;
	restartBtn.y = _h/2;
	restartBtn.scene = "reloader";
	level_menu:insert(restartBtn);
	restartBtn:addEventListener("touch", changeScene);	

local continueBtn = display.newText("Continue", 0, 0, native.systemFontBold, 24);
	continueBtn:setReferencePoint(display.CenterReferencePoint);
	continueBtn:setTextColor(205,0,0,255)
	continueBtn.x = _w/2;
	continueBtn.y = _h/2 + 45;
	level_menu:insert(continueBtn);
	continueBtn:addEventListener("touch", closeMenu);
	
localGroup:insert(optionsBtn)
localGroup:insert(level_menu)
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

function startGame()
	addGameMenuView()
end

startGame()
			

clean = function ()
end
	
return localGroup
	
end