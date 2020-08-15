-- Initial module load
local composer = require( "composer" )
local score = require( "score" )

-- Define this as a scene
local scene = composer.newScene()

-- Make the background white
display.setDefault("background", 255, 255, 255, 1);
game_background_display = display.newGroup()
game_board_display = display.newGroup()
game_ui_display = display.newGroup()


-- Get the current space size
phoneYSize = display.contentHeight
phoneXSize = display.contentWidth
phoneYCentre = display.contentCenterY
phoneXCentre = display.contentCenterX

-- Define how big our grid will be
boxGridSize = phoneXSize

-- Define how big our "boxes" will be
boxSize = (display.contentWidth/4) - 10

-- Define where our 'tap all' button will go
tapAllCenterX = phoneXCentre
tapAllCenterY = phoneYCentre + (boxGridSize/2) + ((boxSize + 5)/2)

-- Define where our 'clock' will go
timerCenterX = phoneXCentre
timerCenterY = phoneYCentre - (boxGridSize/2) - ((boxSize + 5)/2)
-- Define where the coutndown will go
countDownCenterX = phoneXCentre
countDownCenterY = phoneYCentre - (boxGridSize/2) - ((boxSize + 5))


-- Declare a few variables so they can be used later
-- The grid table
local boxGrid = {}
-- The tap all button
local tapAll
local tapAllText
-- The replay button
local replay
local replayText
-- The timer that the player can see
local clock
-- And our ingame timer
local tm

-- Assign a few global variables off the bat
-- The maximum time it can take for a box to "wait"
-- The minimum time it can take for a box to "wait"
fastestCoolDown = 180
maxCoolDownLimit = 600
-- The maximum time it can take for a box to "heat up"
maxHeatUpLimit = 600
-- The minimum time it can take for a box to heat up
fastestHeatUp = 60

-- Current in game time to track how long the player is surviving
inGameTime = 0

-- Define the function for when a box is tapped
local function tapFunction(self, event)
    -- If it's currently heating up
    if self.heatUp > 0
    then
        -- We register it as being tapped
        self.tapped = true
    end
end

-- Define the function for the "tap all" button
local function tap_all(self,event)
    -- If it's own cooldown is over
    if self.coolDown <= 0
    then
        -- It registers as being tapped
        self.tapped = true
    end
end

-- Define the function for the creating one of our boxes
-- Takes the location as a value between 1-4 and 1-4 in reference to the 4x4 grid
local function setupBox(xCoords, yCoords)
    -- Creates the display object based off the coordinates given
    local box = display.newRect(phoneXCentre + (boxSize + 5)*(xCoords - 2.5), phoneYCentre + (boxSize + 5)*(yCoords - 2.5), boxSize, boxSize)
    -- Chuck it in to the game_board_display group
    game_board_display:insert(box)
    -- Colours it blue
    box:setFillColor(0,0,1,1);
    -- Create the listener and relate it to the tapFunction defined earlier
    box:addEventListener("tap", box )
    box.tap = tapFunction

    -- Define it's coords so we can debug if necessary
    box.xCoords = xCoords
    box.yCoords = yCoords

    -- Define the time that it takes for it to heatUp based off the maximum
    -- This will change as the game progress
    box.heatUpLimit = maxHeatUpLimit

    -- It's starts off as cold as it gets
    box.heatUp = 0

    -- It also has not been tapped
    box.tapped = false

    -- define the maximum time that it takes to wait
    box.coolDownLimit = maxCoolDownLimit
    -- And set this to instead be a random value between 0 and that value
    box.coolDown = math.random(box.coolDownLimit);

    -- Returns the variable to be stored
    return box
end

-- Define the function when we want to basically clear the screen and move on
local function destroy_game()
    -- Removes the Game Over text if its showing

    for i = game_ui_display.numChildren, 1, -1 do
        display.remove(game_ui_display[i])
    end
    
    for i = game_board_display.numChildren, 1, -1 do
        display.remove(game_board_display[i])
    end
    --display.remove(gameOverText)
    --display.remove(clock);
    -- Then removes each box one by one
    for i = #boxGrid, 1, -1 do
        -- Remove it from our table - no need to track it anymore
        table.remove(boxGrid, i);
    end

    -- Removes the replay button if its onscreen
    --display.remove(replay);
    --display.remove(replayText);
    --display.remove(highScore);
    --display.remove(highScoreText);
    --display.remove(tapAll);
    --display.remove(tapAllText);
end

-- Define the function for consolidating what happens when we reach Game Over
local function game_over()
    -- We grab the high score currently saved
    lastHighScore = score.load()
    print("Last high score is" .. lastHighScore)

    if lastHighScore == nil then lastHighScore = 0 end
    -- If the current score is higher
    if tonumber(score.get()) > tonumber(lastHighScore)
    then
        -- We replace it in the stored variable
        print("Saving the score")
        score.save();
    end
end

local function countDown_countDown()
    countDown_num = countDown_num - 1
    if countDown_num > 0
    then countDown.text = countDown_num
    elseif countDown_num == 0
    then 
        countDown.text = "GO!"
        countDown:setFillColor(0,0.6,0);
        countDown.size = 48;
        -- set that our game isn't over
        gameOver = false
        -- Set the starttime so we know when the game began running
        startTime = system.getTimer();
        timer.resume(tm);
    else
        display.remove(countDown)
    end
end

-- Define the function for consolidating the start-up of the game
local function setup_game()


    lastHighScore = score.load()
    print("Last high score is" .. lastHighScore)
    -- Then setup all boxes in the 4x4 format, storing them in the table boxGrid
    for i=1,4 do 
        for j=1,4 do
            table.insert(boxGrid,setupBox(i,j));
        end
    end
    
    -- We display the tap all button
    tapAll = display.newRect(tapAllCenterX, tapAllCenterY, boxSize*2.5, boxSize*0.8);
    -- Add it to the game_board_display group
    game_board_display:insert(tapAll)
    tapAllText = display.newText(game_ui_display, "Tap All", tapAllCenterX, tapAllCenterY, "Arial", 32)
    -- Set it to be Orange (not usable)
    tapAll:setFillColor(1,.5,0);
    -- It's not been tapped
    tapAll.tapped = false
    -- Has a coolDown of 600
    tapAll.coolDown = 600
    -- And add the tap event listener to refer to the tap_all function defined earlier
    tapAll:addEventListener("tap", tapAll )
    tapAll.tap = tap_all
    
    -- remove the clock from the last play if it exists
    -- Set up the clock, using the initialising function from our score module
    clock = score.init(
    {
        x = timerCenterX,
        y = timerCenterY
    })
    -- Add this into the game_ui_display
    game_ui_display:insert(clock)

    --Set the countDown
    countDown_num =  3
    countDown = display.newText(game_ui_display, countDown_num, countDownCenterX, countDownCenterY, "Arial" , 32);
    countDown:setFillColor(0,0,0.75)

    countDownTimer = timer.performWithDelay( 1000, countDown_countDown, 4);

end

-- Define the function for when the "replay" button is pressed
local function replay_game(self,event)
    -- Destroy the whole game
    destroy_game()
    -- And set it up again
    setup_game()
end

-- Define the function for creating the replay button
local function display_replaybutton()

    -- Display it
    replay = display.newRect(tapAllCenterX*0.5, tapAllCenterY, boxSize*1.5, boxSize*0.8);
    -- Into the game_ui_display group
    game_board_display:insert(replay)
    replayText = display.newText( "Replay", tapAllCenterX*0.5, tapAllCenterY, "Arial", 32)
    game_ui_display:insert(replayText)
    -- Make it green
    replay:setFillColor(0,1,0);
    -- And give it our replay_game function defined earlier
    replay:addEventListener("tap", replay )
    replay.tap = replay_game
end

-- Define the function for displaying highscores
local function display_highScore()
    -- Set up a transition to the score.lua scene - fade in
    -- It will be an overlay over the main screen
    local options = {
        effect = "fade",
        time = 500,
        isModal = true
    }
    composer.showOverlay( "scoreboard", options )
end

-- Define the function for creating the high score button
local function display_highScoreButton()

    -- Display it
    highScore = display.newRect(tapAllCenterX*1.5, tapAllCenterY, boxSize*1.5, boxSize*0.8);
    -- Into the game_ui_display group
    game_board_display:insert(highScore)
    highScoreText = display.newText( "Scores", tapAllCenterX*1.5, tapAllCenterY, "Arial", 32)
    game_ui_display:insert(highScoreText)
    -- Make it green?
    highScore:setFillColor(0,1,0);
    -- And give it our display_highScore function defined earlier
    highScore:addEventListener("tap", highScore )
    highScore.tap = display_highScore
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

-- Define the function for creating the high score button
local function display_menubutton()

    -- Display it
    menuButton = display.newRect(game_board_display,tapAllCenterX, tapAllCenterY+boxSize, boxSize*2.5, boxSize*0.8);
    -- Into the game_ui_display group
    menuButtonText = display.newText(game_ui_display, "Main Menu", tapAllCenterX, tapAllCenterY+boxSize, "Arial", 32)
    -- Make it green?
    menuButton:setFillColor(0,1,0);
    -- And give it our display_highScore function defined earlier
    menuButton:addEventListener("tap", menuButton )
    menuButton.tap = return_menu
end

-- define the function for when a box is tapped
local function reset_box(box)
    print("Tapped " .. box.xCoords .. box.yCoords)
    -- Once we start processing the box, we unregister it's no longer been tapped to prevent this running more than once
    box.tapped = false
    -- If the game isn't over
    if not gameOver
    then
        -- And if the box is beyond it's limit for "heating up"
        if box.heatUp > box.heatUpLimit
        then 
            -- The game is over
            print("game is now over")
        -- Else if it's in the process of heating up
        elseif box.heatUp > 0
        then
            -- And we've not used the "tap all" function to tap it
            if not tapAll.tapped
            then
                -- The cool down for the tap all reduces
                -- When the cooldown reaches 0, it can be tapped again
                tapAll.coolDown = tapAll.coolDown - box.heatUp
                -- The amount of time the box can possibly wait reduces
                box.coolDownLimit = box.coolDownLimit - (100)
                -- The amount of time the box will take to heat up also reduces
                box.heatUpLimit = box.heatUpLimit - (100)
            end

            -- Prevent the box's heatup or cooldown to be below its minimum
            box.heatUpLimit = math.max(box.heatUpLimit,fastestHeatUp);
            box.coolDownLimit = math.max(box.coolDownLimit,fastestCoolDown);

            -- Debug messages
            print("Cooldown Limit for " .. box.xCoords .. box.yCoords .. " Changed to:" .. box.coolDownLimit)
            print("HeatUp Limit for " .. box.xCoords .. box.yCoords .. " Changed to:" .. box.heatUpLimit)

            -- The box is made as cold as it can be
            box.heatUp = 0

            -- A new wait time is chosen
            box.coolDown = math.random(box.coolDownLimit);

            -- And the box is now blue again
            box:setFillColor(0,0,1,1);
        end
    end
end

-- Define the function by which the box changes colour
local function change_colour(box)
    -- We change colour based on its current "heat"
    time = box.heatUp

    -- Set some initial RGB values
    r = 0
    g = 0
    b = 0

    -- This is all the mathematical function of how the RGB values change according to time
    sectionLength = box.heatUpLimit / 4
    sec1 = 1*sectionLength
    sec2 = 2*sectionLength
    sec3 = 3*sectionLength
    sec4 = 4*sectionLength

    timeStep = 1/sectionLength
    if time < sec1
    then
        b = 1
        r = 0
        g = timeStep*time
        box:setFillColor(r,g,b,1);
    elseif time >= sec1 and time < sec2
    then
        b = 1 - timeStep*(time-sec1)
        r = 0
        g = 1
        box:setFillColor(r,g,b,1);
    elseif time >= sec2 and time < sec3
    then
        b = 0
        r = timeStep*(time-sec2)
        g = 1
        box:setFillColor(r,g,b,1);
    elseif time >= sec3 and time < sec4
    then
        b = 0
        r = 1
        g = 1 - timeStep*(time-sec3)
        box:setFillColor(r,g,b,1);
    end

end

-- Define the actual game loop that runs the game
local function gameLoop( event )
    -- Runs off the timer event
    -- If the game isn't over
    if not gameOver then
        -- We record how the player has survived
        inGameTime = system.getTimer() - startTime;
        -- And we set that as their current score
        score.set(inGameTime)
        if inGameTime > score.load()
        then
            clock:setFillColor(0,1,0)
        else
            clock:setFillColor(1,0,0)
        end
        -- Then we check each box in our table
        for i = #boxGrid, 1, -1 do

            local currentBox = boxGrid[i]
            -- At any point, if the tap all button has been tapped
            if tapAll.tapped
            then
                -- We reset the tap button's cooldown - make it orange
                tapAll:setFillColor( 1, 0.5, 0 );
                -- And for all boxes we reset them
                for j = #boxGrid, 1, -1 do
                    if boxGrid[j].heatUp > 0
                    then
                        reset_box(boxGrid[j]);
                    end
                end
                -- Then register the tap all button is no longer tapped
                tapAll.tapped = false;
                -- And reset its cooldown
                tapAll.coolDown = 600;
            -- Now if the box we're checking has been tapped
            elseif currentBox.tapped
            then 
                -- We reset it
                reset_box(currentBox);
            -- Else if it's waiting
            elseif currentBox.coolDown> 0
            then 
                -- we continue waiting
                currentBox.coolDown = currentBox.coolDown - 1;
            -- Else if it's too hot  
            elseif currentBox.heatUp > currentBox.heatUpLimit
            then
                -- The game is over
                gameOver = true;
                -- We display the game over text
                gameOverText = display.newText( "Game Over", phoneXSize/2, phoneYSize/2, "Arial", 32);
                game_ui_display:insert(gameOverText)
                gameOverText:setFillColor( 0, 0, 0 );
                print("Game Over");

                -- we remove the tap all button
                display.remove(tapAll);
                display.remove(tapAllText);

                -- We display the replay button
                display_replaybutton()
                display_highScoreButton()
                display_menubutton()
                -- And then run the rest of the game over function
                game_over()
            -- Else the only situation is the box is heating up
            else
                -- So we heat it up
                currentBox.heatUp = currentBox.heatUp + 1;
                -- And have it change colour to reflect its current heat
                change_colour(currentBox);
            end
        end

        -- Then at the end, if the tap all button has finished cooling down
        if tapAll.coolDown <= 0
        then
            -- we show its ready to use by setting its colour to cyan
            tapAll:setFillColor( 0, 1, 1 );
        end
    end
end

-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
    sceneGroup:insert(game_background_display)
    sceneGroup:insert(game_board_display)
    sceneGroup:insert(game_ui_display)

 
end

-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
        -- So we set-up our game
        setup_game();
        -- Begin the game timer to start the game
        tm = timer.performWithDelay( 16, gameLoop, 0);
        timer.pause(tm);

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
        -- So we destroy our game
        destroy_game();
        -- And cancel our game loop
        timer.cancel(tm);

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