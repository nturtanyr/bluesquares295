
local composer = require( "composer" )

local scene = composer.newScene()

-- Make a box

-- Make the background white
display.setDefault("background", 255, 255, 255, 1);

-- Get the current space size
phoneYSize = display.contentHeight
phoneXSize = display.contentWidth
phoneYCentre = display.contentCenterY
phoneXCentre = display.contentCenterX

boxGridSize = phoneXSize

boxSize = (display.contentWidth/4) - 10
local boxGrid = {}
local tapAll
local tapAllText
local replay
local replayText
-- Display a box - set this box to variable box

maxCoolDownLimit = 600
maxHeatUpLimit = 600
fastestHeatUp = 30
fastestCoolDown = 180
inGameTime = 0

tapAllCenterX = phoneXCentre
tapAllCenterY = phoneYCentre + (boxGridSize/2) + ((boxSize + 5)/2)

timerCenterX = phoneXCentre
timerCenterY = phoneYCentre - (boxGridSize/2) - ((boxSize + 5)/2)

local function format_gametime(time)

    milliseconds = math.floor(time) % 1000;

    seconds = math.floor(time /1000) % 60;
    minutes = math.floor(time /60000);

    if minutes < 10
    then 
        niceTime = "0" .. minutes .. ":"
    else
        niceTime = minutes .. ":"
    end

    -- 00:
    -- 00:

    if seconds < 10
    then 
        niceTime = niceTime .. "0"
    end
    -- 00:
    -- 00:0

    niceTime = niceTime .. seconds .. ":"
    -- 00:12:
    -- 00:00:

    if milliseconds < 100
    then 
        niceTime = niceTime .. "0"
    end

    -- 00:12:0
    -- 00:00:0

    if milliseconds < 10
    then 
        niceTime = niceTime .. "0"
    end

    -- 00:12:0
    -- 00:00:00

    niceTime = niceTime .. milliseconds

    -- 00:12:051
    -- 00:00:000

    return niceTime
end

local function tapFunction(self, event)
    if self.heatUp > 0
    then
        self.tapped = true
    end
end

local function tap_all(self,event)
    print(self.coolDown)
    if self.coolDown <= 0
    then
        self.tapped = true
    end
end

local function setupBox(xCoords, yCoords)
    local box = display.newRect(phoneXCentre + (boxSize + 5)*(xCoords - 2.5), phoneYCentre + (boxSize + 5)*(yCoords - 2.5), boxSize, boxSize)
    box:setFillColor(0,0,1,1);
    box:addEventListener("tap", box )
    box.tap = tapFunction
    box.xCoords = xCoords
    box.yCoords = yCoords
    box.heatUpLimit = maxHeatUpLimit
    box.heatUp = 0

    box.tapped = false

    box.coolDownLimit = maxCoolDownLimit
    box.coolDown = math.random(box.coolDownLimit);

    return box
end

local function destroy_game()
    display.remove(gameOverText)
    for i = #boxGrid, 1, -1 do
        display.remove(boxGrid[i]);
        table.remove(boxGrid, i);
    end
end

local function setup_game()

    display.remove(replay);
    display.remove(replayText);
    display.remove(clock);

    for i=1,4 do 
        for j=1,4 do
            table.insert(boxGrid,setupBox(i,j));
        end
    end
    
    tapAll = display.newRect(tapAllCenterX, tapAllCenterY, boxSize*2.5, boxSize*0.8);
    tapAllText = display.newText( "Tap All", tapAllCenterX, tapAllCenterY, "Arial", 32)
    tapAll:setFillColor(1,.5,0);
    tapAll.tapped = false
    tapAll.coolDown = 600
    tapAll:addEventListener("tap", tapAll )
    tapAll.tap = tap_all

    clock = display.newText( format_gametime(inGameTime), timerCenterX, timerCenterY, "Courier New", 32)
    clock:setFillColor(0,0,0)

    gameOver = false
    startTime = system.getTimer();
end

local function replay_game(self,event)
    destroy_game()
    setup_game()
end

local function display_replay()

    replay = display.newRect(tapAllCenterX, tapAllCenterY, boxSize*2.5, boxSize*0.8);
    replayText = display.newText( "Replay", tapAllCenterX, tapAllCenterY, "Arial", 32)
    replay:setFillColor(0,1,0);
    replay:addEventListener("tap", replay )
    replay.tap = replay_game
end

local function reset_box(box)
    print("Tapped " .. box.xCoords .. box.yCoords)
    box.tapped = false
    if not gameOver
    then
        if box.heatUp > box.heatUpLimit
        then 
            print("game is now over")
        elseif box.heatUp > 0
        then
            if not tapAll.tapped
            then
                tapAll.coolDown = tapAll.coolDown - box.heatUp
                box.coolDownLimit = box.coolDownLimit - (100)
                box.heatUpLimit = box.heatUpLimit - (100)
            end

            -- Prevent heatup or cooldown to be below 30
            box.heatUpLimit = math.max(box.heatUpLimit,fastestHeatUp);
            box.coolDownLimit = math.max(box.coolDownLimit,fastestCoolDown);
            print("Cooldown Limit for " .. box.xCoords .. box.yCoords .. " Changed to:" .. box.coolDownLimit)
            print("HeatUp Limit for " .. box.xCoords .. box.yCoords .. " Changed to:" .. box.heatUpLimit)
            box.heatUp = 0
            box.coolDown = math.random(box.coolDownLimit);
            box:setFillColor(0,0,1,1);
        end
    end
end

local function change_colour(box)
    time = box.heatUp
    r = 0
    g = 0
    b = 0

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

local function gameLoop( event )
    -- Access "params" table by pointing to "event.source" (the timer handle)
    local params = event.source.params
    --print( params.myParam1 )
    --print( params.myParam2 )
    if not gameOver then
        inGameTime = system.getTimer() - startTime;
        --print(inGameTime);
        clock.text = format_gametime(inGameTime)

        for i = #boxGrid, 1, -1 do

            local currentBox = boxGrid[i]
            if tapAll.tapped
            then
                tapAll:setFillColor( 1, 0.5, 0 );
                for j = #boxGrid, 1, -1 do
                    if boxGrid[j].heatUp > 0
                    then
                        reset_box(boxGrid[j]);
                    end
                end
                tapAll.tapped = false;
                tapAll.coolDown = 600;
            elseif currentBox.tapped
            then 
                reset_box(currentBox);
            elseif currentBox.coolDown> 0
            then 
                currentBox.coolDown = currentBox.coolDown - 1;
                --print("Cooldown:" .. coolDown)        
            elseif currentBox.heatUp > currentBox.heatUpLimit
            then
                gameOver = true;
                gameOverText = display.newText( "Game Over", phoneXSize/2, phoneYSize/2, "Arial", 32);
                gameOverText:setFillColor( 0, 0, 0 );
                print("Game Over");
                display.remove(tapAll);
                display.remove(tapAppText);
                display_replay()
            else
                currentBox.heatUp = currentBox.heatUp + 1;
                --print("HeatUp:" .. inGameTime)
                change_colour(currentBox);
            end
        end

        if tapAll.coolDown <= 0
        then
            tapAll:setFillColor( 0, 1, 1 );
        end

    end
end

 
-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
 
end

-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
        
        setup_game();
        local tm = timer.performWithDelay( 16, gameLoop, 0);

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
        destroy_game();
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