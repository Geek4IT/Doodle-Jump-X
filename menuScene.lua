module(..., package.seeall)


function new()	
	
	-- we store everything inside this group at the end
	local localGroup = display.newGroup()		
	
	-- change scene function
	function changeScene(e)
		if(e.phase == "ended") then
			director:changeScene(e.target.scene, "moveFromRight");
		end
	end
		
		
	
	local background = display.newImage('background.png')
		background.x = _w/2;
		background.y = _h/2;
	
	-- menu buttons	
	local playBtn = display.newImage('playBtn.png')
		playBtn.x = _w/2
		playBtn.y = _h/2 - 45
		playBtn.scene = "selectLevelScene"
		playBtn:addEventListener("touch",changeScene)

	local helpBtn = display.newImage('helpBtn.png')
		helpBtn.x = _w/2
		helpBtn.y = _h/2 + 45
		helpBtn.scene = "helpScene"
		helpBtn:addEventListener("touch",changeScene)

	local exitBtn = display.newImage('exitBtn.png')
		exitBtn.x = _w - exitBtn.width/2
		exitBtn.y = _h - exitBtn.height/2
		exitBtn.scene = "exit"
		exitBtn:addEventListener("touch",changeScene)
		
		
	--- insert everything into the localGroup	
	localGroup:insert(background)
	localGroup:insert(playBtn)
	localGroup:insert(helpBtn)
	localGroup:insert(exitBtn)
	
	
	-- clean everything up
	clean = function ()
	
	end
	
	-- do not remove lest the sky shalt fall upon thine head
	return localGroup
	
end