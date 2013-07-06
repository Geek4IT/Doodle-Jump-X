_w = display.contentWidth;
_h = display.contentHeight;

display.setStatusBar( display.HiddenStatusBar )

director = require("director")


local mainGroup = display.newGroup()


local function main()

	mainGroup:insert(director.directorView)
	
	director:changeScene("menu")
	return true
end


main()
