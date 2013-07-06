module(..., package.seeall)


function new()
	local localGroup = display.newGroup()
	
	local path = system.pathForFile( "loadlast.txt", system.DocumentsDirectory )
	local file = io.open( path, "r" )
	if file then
	   return_to = file:read( "*a" )
	   print(return_to)
	   io.close(file)
	end
	
	local theTimer
	local loadingImage
	
	local showLoadingScreen = function()
		loadingImage = display.newImage( "loading.png")
		loadingImage.x = _w/2; loadingImage.y = _h/2
		
		local goToLevel = function()
			director:changeScene( return_to )
		end
		
		theTimer = timer.performWithDelay( 1000, goToLevel, 1 )
	end
	
	showLoadingScreen()
	
	clean = function()
		if theTimer then timer.cancel( theTimer ); end
		
		if loadingImage then
			display.remove( loadingImage )
			loadingImage = nil
		end
	end
	
	return localGroup
end
