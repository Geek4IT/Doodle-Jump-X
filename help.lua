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
		backBtn.scene = "menu"
		backBtn:addEventListener("touch",changeScene)
		
		
	--- insert everything into the localGroup
	localGroup:insert(background)
	localGroup:insert(backBtn)	
		
		
	-- clean everything up
	clean = function ()
	
	end
	
	
	-- do not remove lest the sky shalt fall upon thine head
	return localGroup
	
end