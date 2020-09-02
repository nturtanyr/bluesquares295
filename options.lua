-- Initial module load
local composer = require( "composer" )
local widget = require( "widget" )
local colours = require( "colours" )
local score = require( "score" )

-- Define this as a scene
local scene = composer.newScene()

option_background_display = display.newGroup()
option_board_display = display.newGroup()
option_ui_display = display.newGroup()

colour_options = colours.num_of_options
coloured_boxes = {}

local tm

-- Define how big our "boxes" will be
boxSize = (display.contentWidth/4) - 10
gap = (display.contentWidth - 3*boxSize)/4

-- Handle press events for the buttons
local function onDarkModeSwitch( event )
    local switch = event.target
    colours.saveDarkMode(switch.id)
    colours.set_TextColour(menuButtonText, true)
    colours.set_TextColour(tokenCountText, true)
    colours.set_BackgroundColour()
end

local function toggleBoxNumbers( event )
    local switch = event.target
    if(not switch.isOn)
    then
        colours.saveBoxNumbers("show")
        boxNumbers = true
    else
        colours.saveBoxNumbers("hide")
        boxNumbers = false
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

local function setupOption(i)
    
    if (i % 3 == 0)
    then
        x = display.contentCenterX - (boxSize + gap)
    elseif (i % 3 == 1)
    then
        x = display.contentCenterX
    elseif (i % 3 == 2)
    then
        x = display.contentCenterX + (boxSize + gap)
    end

    y = math.floor(1 + (i/3)) * (boxSize + 40)

    local box = display.newRect(x,y,boxSize,boxSize);
    box:setFillColor(0,0,0);
    -- Flag for telling if an option has been unlocked yet
    -- Show affect whether the "cost" is visible, whether it shows a locked graphic
    box.unlocked = false
    -- Flag for telling if we show this options as "selected"
    -- In game loop, we check if an option is selected to show cursor
    -- Value is also saved to game preferences
    box.selected = false
    box.cost = 600 + (i*100)
    box.costText = display.newText(box.cost, x, (y+ (boxSize/2)+20), "Arial", 24);

    box.heatUpLimit = 300
    box.heatUp = 0
    
    box.overlayText = display.newText(tostring(box.heatUpLimit - box.heatUp), x, y, "Arial", 24)
    colours.set_TextColour(box.overlayText, boxNumbers)
    -- Colours it blue
    colours.change_colour(box, colour_option, boxNumbers)

    return box

end

local function loopColours( event )
    print("looping - numbers are "..tostring(boxNumbers))
    for i = #coloured_boxes, 1, -1 do
        local currentBox = coloured_boxes[i]
        if currentBox.heatUp > currentBox.heatUpLimit
        then 
            currentBox.heatUp = 0
        else
            currentBox.heatUp = currentBox.heatUp + 1;
        end
        
        colours.change_colour(currentBox, (i-1), boxNumbers)
    end
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

    boxNumbers = (colours.loadBoxNumbers() == "show")
    -- Create the widget
    local onOffSwitch = widget.newSwitch(
        {
            left = display.contentCenterX,
            top = 75,
            style = "onOff",
            id = "boxNumbers",
            initialSwitchState = boxNumbers,
            onPress = toggleBoxNumbers
        }
    )

    option_board_display:insert(radioGroup)
    option_board_display:insert(onOffSwitch)


    tokenCountText = display.newText(option_ui_display, score.loadTokens().." tokens", display.contentCenterX, display.contentCenterY-65, "Arial", 28);
     -- Into the game_ui_display group
     menuButtonText = display.newText(option_ui_display, "Main Menu", display.contentCenterX, display.contentCenterY-25, "Arial", 32)
     -- Make it green?
     colours.set_TextColour(menuButtonText, true)
     -- And give it our display_highScore function defined earlier
     menuButtonText:addEventListener("tap", return_menu )

     -- ScrollView listener
    local function scrollListener( event )
    
        local phase = event.phase
        if ( phase == "began" ) then print( "Scroll view was touched" )
        elseif ( phase == "moved" ) then print( "Scroll view was moved" )
        elseif ( phase == "ended" ) then print( "Scroll view was released" )
        end
    
        -- In the event a scroll limit is reached...
        if ( event.limitReached ) then
            if ( event.direction == "up" ) then print( "Reached bottom limit" )
            elseif ( event.direction == "down" ) then print( "Reached top limit" )
            elseif ( event.direction == "left" ) then print( "Reached right limit" )
            elseif ( event.direction == "right" ) then print( "Reached left limit" )
            end
        end
    
        return true
    end
    
    -- Create the widget
    scrollView = widget.newScrollView(
        {
            top = display.contentCenterY,
            left = 0,
            width = display.contentWidth,
            height = display.contentHeight - (display.contentCenterY+10),
            scrollWidth = display.contentWidth,
            scrollHeight = 800,
            listener = scrollListener,
            backgroundColor = { 0.8, 0.8, 0.8 }
        }
    )

    option_board_display:insert(scrollView)
    for i=0, (colour_options-1) do
        local b = setupOption(i)
        scrollView:insert(b)
        scrollView:insert(b.costText)
        scrollView:insert(b.overlayText)
        table.insert(coloured_boxes,b);
    end
 
end

-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
        colours.set_TextColour(tokenCountText, true)
        tokenCountText.text = score.loadTokens().." tokens"

	elseif ( phase == "did" ) then
        tm = timer.performWithDelay( 16, loopColours, 0);
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
    for i = scrollView.numChildren, 1, -1 do
        display.remove(scrollView[i])
    end
    for i = game_ui_display.numChildren, 1, -1 do
        display.remove(game_ui_display[i])
    end
    
    for i = game_board_display.numChildren, 1, -1 do
        display.remove(game_board_display[i])
    end

    for i = #coloured_boxes, 1, -1 do
        -- Remove it from our table - no need to track it anymore
        table.remove(coloured_boxes, i);
    end
    timer.cancel(tm);

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