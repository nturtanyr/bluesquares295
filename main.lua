-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here

-- Make a box

-- Make the backgroudn white
display.setDefault("background", 255, 255, 255, 1);

-- Get the current space size
phoneYSize = display.contentHeight
phoneXSize = display.contentWidth
phoneYCentre = phoneYSize / 2
phoneXCentre = phoneXSize / 2

boxSize = (display.contentWidth/4) - 10
local boxGrid = {}

-- Display a box - set this box to variable box


maxCoolDownLimit = 600
maxHeatUpLimit = 600
fastestHeatUp = 30
fastestCoolDown = 30
inGameTime = 0

-- Function to chagne between blue and red
local function resetTimer(self, event)
    print("Tapped " .. self.xCoords .. self.yCoords)
    if self.heatUp > self.heatUpLimit
    then 
        print("game is now over")
    elseif self.heatUp > 0
    then
        self.coolDownLimit = self.coolDownLimit - (100)
        self.heatUpLimit = self.heatUpLimit - (100)

        -- Prevent heatup or cooldown to be below 30
        self.heatUpLimit = math.max(self.heatUpLimit,fastestHeatUp);
        self.coolDownLimit = math.max(self.coolDownLimit,fastestCoolDown);
        print("Cooldown Limit for " .. self.xCoords .. self.yCoords .. " Changed to:" .. self.coolDownLimit)
        print("HeatUp Limit for " .. self.xCoords .. self.yCoords .. " Changed to:" .. self.heatUpLimit)
        self.heatUp = 0
        self.coolDown = math.random(self.coolDownLimit);
        self:setFillColor(0,0,1,1);
    end
end

local function setupBox(xCoords, yCoords)
    local box = display.newRect(phoneXCentre + (boxSize + 5)*(xCoords - 2.5), phoneYCentre + (boxSize + 5)*(yCoords - 2.5), boxSize, boxSize)
    box:setFillColor(0,0,1,1);
    box:addEventListener("tap", box )
    box.tap = resetTimer
    box.xCoords = xCoords
    box.yCoords = yCoords
    box.heatUpLimit = maxHeatUpLimit
    box.heatUp = 0

    box.coolDownLimit = maxCoolDownLimit
    box.coolDown = math.random(box.coolDownLimit);
    function box:change_colour()
        time = self.heatUp
        r = 0
        g = 0
        b = 0
    
        sectionLength = self.heatUpLimit / 4
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
            self:setFillColor(r,g,b,1);
        elseif time >= sec1 and time < sec2
        then
            b = 1 - timeStep*(time-sec1)
            r = 0
            g = 1
            self:setFillColor(r,g,b,1);
        elseif time >= sec2 and time < sec3
        then
            b = 0
            r = timeStep*(time-sec2)
            g = 1
            self:setFillColor(r,g,b,1);
        elseif time >= sec3 and time < sec4
        then
            b = 0
            r = 1
            g = 1 - timeStep*(time-sec3)
            self:setFillColor(r,g,b,1);
        end
    
    end

    return box
end

for i=1,4 do 
    for j=1,4 do
        table.insert(boxGrid,setupBox(i,j));
    end
end

gameOver = false
local function gameLoop( event )
    -- Access "params" table by pointing to "event.source" (the timer handle)
    local params = event.source.params
    --print( params.myParam1 )
    --print( params.myParam2 )
    if not gameOver then 
        for i = #boxGrid, 1, -1 do
            local currentBox = boxGrid[i]
            if currentBox.coolDown> 0
            then 
                currentBox.coolDown = currentBox.coolDown - 1
                --print("Cooldown:" .. coolDown)        
            elseif currentBox.heatUp > currentBox.heatUpLimit
            then
                gameOver = true
                gameOverText = display.newText( "Game Over", phoneXSize/2, phoneYSize/2, "Arial", 32)
                gameOverText:setFillColor( 0, 0, 0 )
                print("Game Over")
            else
                currentBox.heatUp = currentBox.heatUp + 1
                --print("HeatUp:" .. inGameTime)
                currentBox:change_colour()
            end
        end
    end
end

local tm = timer.performWithDelay( 16, gameLoop, 0)
-- Assign a table of parameters to the "tm" handl