module(..., package.seeall)

function new()	
	
	-- we store everything inside this group at the end
	local localGroup = display.newGroup()

	-- change scene function
	function changeScene(e)
		if(e.phase == "ended") then
			director:changeScene(e.target.scene, "moveFromLeft");
		end
	end
	
	local background = display.newImage('selectLevelBg.png')
		background.x = _w/2;
		background.y = _h/2;
	
	-- menu buttons	
	local backBtn = display.newImage('backBtn.png')
		backBtn.x = backBtn.width/2
		backBtn.y = backBtn.height/2
		backBtn.scene = "menuScene"
		backBtn:addEventListener("touch",changeScene)

	local level1Label = display.newText("level1#",0,0,native.systemFontBold,23)
		level1Label:setReferencePoint(display.CenterReferencePoint)
		level1Label:setTextColor(234,34,34,255)
		level1Label.x = _w/2
		level1Label.y = _h/2 - 30
		level1Label.scene = "level1Scene"
		level1Label:addEventListener("touch",changeScene)


	local level2Label = display.newText("level2#",0,0,native.systemFontBold,23)
		level2Label:setReferencePoint(display.CenterReferencePoint)
		level2Label:setTextColor(234,34,34,255)
		level2Label.x = _w/2
		level2Label.y = _h/2 + 30
		level2Label.scene = "level1Scene"
		level1Label:addEventListener("touch",changeScene)
					
		
	--- insert everything into the localGroup
	localGroup:insert(background)
	localGroup:insert(backBtn)	
	localGroup:insert(level1Label)	
	localGroup:insert(level2Label)
		
		
	-- clean everything up
	clean = function ()
	
	end
	
	
	-- do not remove lest the sky shalt fall upon thine head
	return localGroup
	
end