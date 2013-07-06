module(..., package.seeall)
 
directorView = display.newGroup()
currView     = display.newGroup()
nextView     = display.newGroup()
effectView   = display.newGroup()


local currScreen, nextScreen
local currScene, nextScene = "main", "main"
local newScene
local fxTime = 200
local safeDelay = 50
local isChangingScene = false

directorView:insert(currView)
directorView:insert(nextView)
directorView:insert(effectView)

currView.x = 0
currView.y = 0
nextView.x = display.contentWidth
nextView.y = 0


local function getColor ( arg1, arg2, arg3 )
	--
	local r, g, b
	--
	if type(arg1) == "nil" then
		arg1 = "black"
	end
	--
	if string.lower(arg1) == "red" then
		r=255
		g=0
		b=0
	elseif string.lower(arg1) == "green" then
		r=0
		g=255
		b=0
	elseif string.lower(arg1) == "blue" then
		r=0
		g=0
		b=255
	elseif string.lower(arg1) == "yellow" then
		r=255
		g=255
		b=0
	elseif string.lower(arg1) == "pink" then
		r=255
		g=0
		b=255
	elseif string.lower(arg1) == "white" then
		r=255
		g=255
		b=255
	elseif type (arg1) == "number"
	   and type (arg2) == "number"
	   and type (arg3) == "number" then
		r=arg1
		g=arg2
		b=arg3
	else
		r=0
		g=0
		b=0
	end
	--
	return r, g, b
	--
end

------------------------------------------------------------------------        
-- CHANGE CONTROLS
------------------------------------------------------------------------

function director:changeFxTime ( newFxTime )
  if type(newFxTime) == "number" then
    fxTime = newFxTime
  end
end

-- safeDelay
function director:changeSafeDelay ( newSafeDelay )
  if type(newSafeDelay) == "number" then
    safeDelay = newSafeDelay
  end
end

------------------------------------------------------------------------        
-- GET SCENES
------------------------------------------------------------------------

function director:getCurrScene ()
	return currScene
end
--
function director:getNextScene ()
	return nextScene
end
 
------------------------------------------------------------------------        
-- CLEAN GROUP
------------------------------------------------------------------------
 
local function cleanGroups ( curGroup, level )
	if curGroup.numChildren then
		while curGroup.numChildren > 0 do
			cleanGroups ( curGroup[curGroup.numChildren], level+1 )
		end
		if level > 0 then
			curGroup:removeSelf()
		end
	else
		curGroup:removeSelf()
		curGroup = nil
		return true
	end
end

------------------------------------------------------------------------        
-- CALL CLEAN FUNCTION
------------------------------------------------------------------------

local function callClean ( moduleName )
	if type(package.loaded[moduleName]) == "table" then
		if string.lower(moduleName) ~= "main" then
			for k,v in pairs(package.loaded[moduleName]) do
				if k == "clean" and type(v) == "function" then
					package.loaded[moduleName].clean()
				end
			end
		end
	end
end

------------------------------------------------------------------------        
-- UNLOAD SCENE
------------------------------------------------------------------------

local function unloadScene ( moduleName )
	if moduleName ~= "main" and type(package.loaded[moduleName]) == "table" then
		package.loaded[moduleName] = nil
		local function garbage ( event )
			collectgarbage("collect")
		end
		garbage()
		timer.performWithDelay(fxTime,garbage)
	end
end
 
------------------------------------------------------------------------        
-- LOAD SCENE
------------------------------------------------------------------------
 
local function loadScene ( moduleName, target )

	-- Test parameters
	if type(moduleName) == "nil" then
		return true
	end
	if type(target) == "nil" then
		target = "next"
	end
	
	-------------------------------------
	-- Load choosed scene
	-------------------------------------
	
	-- Prev
 	if string.lower(target) == "curr" then
 		--
 		callClean ( moduleName )
 		--
 		cleanGroups(currView,0)
 		--
 		if nextScene == moduleName then
 			cleanGroups(nextView,0)
 		end
 		--
 		unloadScene( moduleName )
 		--
		currScreen = require(moduleName).new()
		currView:insert(currScreen)
		currScene = moduleName

	-- Next
	else
		--
		callClean ( moduleName )
		--
		cleanGroups(nextView,0)
		--
 		if currScene == moduleName then
 			cleanGroups(currView,0)
 		end
 		--
 		unloadScene( moduleName )
 		--
		nextScreen = require(moduleName).new()
		nextView:insert(nextScreen)
		nextScene = moduleName
		
	end
	
end

-- Load curr screen
function director:loadCurrScene ( moduleName )
	loadScene ( moduleName, "curr" )
end

-- Load next screen
function director:loadNextScene ( moduleName )
	loadScene ( moduleName, "next" )
end
 
------------------------------------------------------------------------
-- EFFECT ENDED
------------------------------------------------------------------------
 
local function fxEnded ( event )
 
	currView.x = 0
	currView.y = 0
	currView.xScale = 1
	currView.yScale = 1
	--
	callClean  ( currScene )
	cleanGroups( currView ,0)
	unloadScene( currScene )
	--
	currScreen = nextScreen
	currScene = newScene
	currView:insert(currScreen)
	--
	nextView.x = display.contentWidth
	nextView.y = 0
	nextView.xScale = 1
	nextView.yScale = 1
	--
	isChangingScene = false
        
end
 
------------------------------------------------------------------------        
-- CHANGE SCENE
------------------------------------------------------------------------
 
function director:changeScene(nextLoadScene, 
                              effect, 
                              arg1,
                              arg2,
                              arg3)

	-----------------------------------
	-- If is changing scene, return without do anything
	-----------------------------------
 
 	if isChangingScene then
 		return true
 	else
 		isChangingScene = true
 	end
 
	-----------------------------------
	-- If is the same, don't change
	-----------------------------------
        
	if currScene then
		if string.lower(currScene) == string.lower(nextLoadScene) then
			return true
		end
	end
        
	newScene = nextLoadScene
	local showFx
 
	-----------------------------------
	-- EFFECT: Move From Right
	-----------------------------------
        
	if effect == "moveFromRight" then
                        
		nextView.x = display.contentWidth
		nextView.y = 0
		--
		loadScene (newScene)
		--
		showFx = transition.to ( nextView, { x=0, time=fxTime } )
		showFx = transition.to ( currView, { x=display.contentWidth*-1, time=fxTime } )
		--
		timer.performWithDelay( fxTime+safeDelay, fxEnded )
                
	-----------------------------------
	-- EFFECT: Over From Right
	-----------------------------------
        
	elseif effect == "overFromRight" then
        
		nextView.x = display.contentWidth
		nextView.y = 0
		--
		loadScene (newScene)
		--
		showFx = transition.to ( nextView, { x=0, time=fxTime } )
		--
		timer.performWithDelay( fxTime+safeDelay, fxEnded )
                
	-----------------------------------
	-- EFFECT: Move From Left
	-----------------------------------
        
	elseif effect == "moveFromLeft" then
        
		nextView.x = display.contentWidth*-1
		nextView.y = 0
		--
		loadScene (newScene)
		--
		showFx = transition.to ( nextView, { x=0, time=fxTime } )
		showFx = transition.to ( currView, { x=display.contentWidth, time=fxTime } )
		--
		timer.performWithDelay( fxTime+safeDelay, fxEnded )
        
	-----------------------------------
	-- EFFECT: Over From Left
	-----------------------------------
        
	elseif effect == "overFromLeft" then
        
		nextView.x = display.contentWidth*-1
		nextView.y = 0
		--
		loadScene (newScene)
		--
		showFx = transition.to ( nextView, { x=0, time=fxTime } )
		--
		timer.performWithDelay( fxTime+safeDelay, fxEnded )
		
	-----------------------------------
	-- EFFECT: Move From Top
	-----------------------------------

	elseif effect == "moveFromTop" then

		nextView.x = 0
		nextView.y = display.contentHeight*-1
		--
		loadScene (newScene)
		--
		showFx = transition.to ( nextView, { y=0, time=fxTime } )
		showFx = transition.to ( currView, { y=display.contentHeight, time=fxTime } )
		--
		timer.performWithDelay( fxTime+safeDelay, fxEnded )
        
	-----------------------------------
	-- EFFECT: Over From Top
	-----------------------------------
        
	elseif effect == "overFromTop" then
        
		nextView.x = 0
		nextView.y = display.contentHeight*-1
		--
		loadScene (newScene)
		--
		showFx = transition.to ( nextView, { y=0, time=fxTime } )
		--
		timer.performWithDelay( fxTime+safeDelay, fxEnded )
		
	-----------------------------------
	-- EFFECT: Move From Bottom
	-----------------------------------

	elseif effect == "moveFromBottom" then

		nextView.x = 0
		nextView.y = display.contentHeight
		--
		loadScene (newScene)
		--
		showFx = transition.to ( nextView, { y=0, time=fxTime } )
		showFx = transition.to ( currView, { y=display.contentHeight*-1, time=fxTime } )
		--
		timer.performWithDelay( fxTime+safeDelay, fxEnded )
        
	-----------------------------------
	-- EFFECT: Over From Bottom
	-----------------------------------
        
	elseif effect == "overFromBottom" then
        
		nextView.x = 0
		nextView.y = display.contentHeight
		--
		loadScene (newScene)
		--
		showFx = transition.to ( nextView, { y=0, time=fxTime } )
		--
		timer.performWithDelay( fxTime+safeDelay, fxEnded )
		
	-----------------------------------
	-- EFFECT: Crossfade
	-----------------------------------

	elseif effect == "crossfade" then

		nextView.x = display.contentWidth
		nextView.y = 0
		--
		loadScene (newScene)
		--
		nextView.alpha = 0
		nextView.x = 0
		--
		showFx = transition.to ( nextView, { alpha=1, time=fxTime*2 } )
		--
		timer.performWithDelay( fxTime*2+safeDelay, fxEnded )
                
	-----------------------------------
	-- EFFECT: Fade
	-----------------------------------
	-- ARG1 = color [string]
	-----------------------------------
	-- ARG1 = red   [number]
	-- ARG2 = green [number]
	-- ARG3 = blue  [number]
	-----------------------------------
        
	elseif effect == "fade" then
        
		local r, g, b = getColor ( arg1, arg2, arg3 )
		--
		nextView.x = display.contentWidth
		nextView.y = 0
		--
		loadScene (newScene)
		--
		local fade = display.newRect( 0 - display.contentWidth, 0 - display.contentHeight, display.contentWidth * 3, display.contentHeight * 3 )
		fade.alpha = 0
		fade:setFillColor( r,g,b )
		effectView:insert(fade)
		--
		showFx = transition.to ( fade, { alpha=1.0, time=fxTime } )
		--
		timer.performWithDelay( fxTime+safeDelay, fxEnded )
		--
		local function returnFade ( event )
                
			showFx = transition.to ( fade, { alpha=0, time=fxTime } )
			--
			local function removeFade ( event )
				fade:removeSelf()
			end
			--
			timer.performWithDelay( fxTime+safeDelay, removeFade )

		end
		--
		timer.performWithDelay( fxTime+safeDelay+1, returnFade )
                
	-----------------------------------
	-- EFFECT: Flip
	-----------------------------------
        
	elseif effect == "flip" then
        
		showFx = transition.to ( currView, { xScale=0.001, time=fxTime } )
		showFx = transition.to ( currView, { x=display.contentWidth*0.5, time=fxTime } )
		--
		loadScene (newScene)
		--
		nextView.xScale=0.001
		nextView.x=display.contentWidth*0.5
		--
		showFx = transition.to ( nextView, { xScale=1, delay=fxTime, time=fxTime } )
		showFx = transition.to ( nextView, { x=0, delay=fxTime, time=fxTime } )
		--
		timer.performWithDelay( fxTime*2+safeDelay, fxEnded )
                
	-----------------------------------
	-- EFFECT: Down Flip
	-----------------------------------
        
	elseif effect == "downFlip" then
        
		showFx = transition.to ( currView, { xScale=0.7, time=fxTime } )
		showFx = transition.to ( currView, { yScale=0.7, time=fxTime } )
		showFx = transition.to ( currView, { x=display.contentWidth*0.15,  time=fxTime } )
		showFx = transition.to ( currView, { y=display.contentHeight*0.15, time=fxTime } )
		showFx = transition.to ( currView, { xScale=0.001, delay=fxTime, time=fxTime } )
		showFx = transition.to ( currView, { x=display.contentWidth*0.5, delay=fxTime, time=fxTime } )
		--
		loadScene (newScene)
		--
		nextView.x = display.contentWidth*0.5
		nextView.xScale=0.001
		nextView.yScale=0.7
		nextView.y=display.contentHeight*0.15
		--
		showFx = transition.to ( nextView, { x=display.contentWidth*0.15, delay=fxTime*2, time=fxTime } )
		showFx = transition.to ( nextView, { xScale=0.7, delay=fxTime*2, time=fxTime } )
		showFx = transition.to ( nextView, { xScale=1, delay=fxTime*3, time=fxTime } )
		showFx = transition.to ( nextView, { yScale=1, delay=fxTime*3, time=fxTime } )
		showFx = transition.to ( nextView, { x=0, delay=fxTime*3, time=fxTime } )
		showFx = transition.to ( nextView, { y=0, delay=fxTime*3, time=fxTime } )
		--
		timer.performWithDelay( fxTime*4+safeDelay, fxEnded )
                
	-----------------------------------
	-- EFFECT: None
	-----------------------------------
        
	else
		timer.performWithDelay( 0, fxEnded )
		loadScene (newScene)
	end
    
	return true
	
end