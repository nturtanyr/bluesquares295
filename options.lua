-- Initial module load
local composer = require( "composer" )
local widget = require( "widget" )
local colours = require( "colours" )

-- Define this as a scene
local scene = composer.newScene()

option_background_display = display.newGroup()
option_board_display = display.newGroup()
option_ui_display = display.newGroup()


-- Handle press events for the buttons
local function onDarkModeSwitch( event )
    local switch = event.target
    colours.saveDarkMode(switch.id)
    colours.set_TextColour(menuButtonText)
    colours.set_MainColour(menuButton)
    colours.set_BackgroundColour()
end

local function toggleBoxNumbers( event )
    local switch = event.target
    if(not switch.isOn)
    then
        colours.saveBoxNumbers("show")
    else
        colours.saveBoxNumbers("hide")
    end
    
end


-- Define the function for returning to the main menu
local function return_menu()
    -- Set up a transition to the score.lua scene - fade in
    -- It will be an overlay over the main screen
    local options = {
        effect = "fade",
        time = 500
    }
    composer.gotoScene( "menu", options )
end

-- create()
function scene:create( event )
    colours.set_BackgroundColour()

 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
    sceneGroup:insert(option_background_display)
    sceneGroup:insert(option_board_display)
    sceneGroup:insert(option_ui_display)
    -- Create a group for the radio button set
    local radioGroup = display.newGroup()
    
    -- Create two associated radio buttons (inserted into the same display group)
    local lightButton = widget.newSwitch(
        {
            left = display.contentCenterX-50,
            top = 30,
            style = "radio",
            id = "Light",
            initialSwitchState = (colours.loadDarkMode() == 'Light'),
            onPress = onDarkModeSwitch
        }
    )
    radioGroup:insert( lightButton )
    
    local darkButton = widget.newSwitch(
        {
            left = display.contentCenterX+50,
            top = 30,
            style = "radio",
            id = "Dark",
            initialSwitchState = (colours.loadDarkMode() == 'Dark'),
            onPress = onDarkModeSwitch
        }
    )
    radioGroup:insert( darkButton )

    -- Create the widget
    local onOffSwitch = widget.newSwitch(
        {
            left = display.contentCenterX,
            top = 75,
            style = "onOff",
            id = "boxNumbers",
            initialSwitchState = (colours.loadBoxNumbers() == "show"),
            onPress = toggleBoxNumbers
        }
    )

    option_board_display:insert(radioGroup)
    option_board_display:insert(onOffSwitch)

     -- Display it
     menuButton = display.newRect(option_board_display, display.contentCenterX, display.contentCenterY + 50 , 20, 20);
     -- Into the game_ui_display group
     menuButtonText = display.newText(option_ui_display, "Main Menu", display.contentCenterX, display.contentCenterY+50, "Arial", 32)
     -- Make it green?
     colours.set_TextColour(menuButtonText)
     colours.set_MainColour(menuButton)
     -- And give it our display_highScore function defined earlier
     menuButtonText:addEventListener("tap", return_menu )
 
end

-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen

	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- ----------------------------------------

 return scene