-- Module for managing colour schemes and the graphic display

-- Dark mode
-- Font size?

-- Monochromatic
-- Numbers on boxes
-- Colour gradient used
local C = {}

C.num_of_options = 3
C.selected_colour = 0

function C.saveBoxNumbers(value)
 
    local saved = system.setPreferences( "app", { boxNumbers = value } )
    if ( saved == false ) then
        print( "ERROR: could not save base mode" )
    end
end
 
function C.loadBoxNumbers()
 
    local value = system.getPreference( "app", "boxNumbers", "string" )
    return value
end


function C.saveDarkMode(value)
 
    local saved = system.setPreferences( "app", { darkMode = value } )
    if ( saved == false ) then
        print( "ERROR: could not save base mode" )
    end
end
 
function C.loadDarkMode()
 
    local value = system.getPreference( "app", "darkMode", "string" )
    return value
end

function C.set_TextColour(textObject, show)
    if(show)
    then
        if(C.loadDarkMode() == 'Dark')
        then
            textObject:setFillColor(1,1,1,1)
        else
            textObject:setFillColor(0,0,0,1)
        end
    else
        textObject:setFillColor(0,0,0,0)
    end
    
end

function C.set_BackgroundColour()
    if(C.loadDarkMode() == 'Dark')
    then
        display.setDefault("background", 0, 0, 0, 1);
    else
        display.setDefault("background", 255, 255, 255, 1);
    end
    
end

function C.set_MainColour(textObject)
    if(C.loadDarkMode() == 'Dark')
    then
        textObject:setFillColor(0,0,0)
    else
        textObject:setFillColor(1,1,1)
    end
    
end

function C.unlockColourOption(option)

    optionPreference = "optionPreference"..tostring(option)
    preferences = {}
    preferences[optionPreference] = "unlocked"
    local saved = system.setPreferences( "app", preferences)
    if ( saved == false ) then
        print( "ERROR: could not save unlocking" )
    end

end

function C.getLockedStatus(option)
 
    optionPreference = "optionPreference"..tostring(option)
    local lockstatus = system.getPreference( "app", optionPreference , "string" )
 
    if ( lockstatus == "unlocked" ) then
        return false
    elseif ( lockstatus == "locked" ) then
        return true
    else
        preferences = {}
        preferences[optionPreference] = "locked"
        local saved = system.setPreferences( "app", preferences)
        return true
    end

end

function C.saveSelectedColour()
 
    local saved = system.setPreferences( "app", { selectedColour=C.selected_colour } )
    if ( saved == false ) then
        print( "ERROR: could not save current colour selection" )
    end

end

function C.loadSelectedColour()
 
    local selected_colour = system.getPreference( "app", "selectedColour", "number" )
 
    if ( selected_colour ) then
        return tonumber(selected_colour)
    else
        print( "ERROR: could not load the current selected colour" )
        return 0
    end

end

function C.change_colour(box, num, show)
    
    box.overlayText.text = (tostring(box.heatUpLimit - box.heatUp))
    C.set_TextColour(box.overlayText, show)


    if num == 0
    then C.gradient_bgr(box)
    elseif num ==1
    then C.gradient_br(box)
    elseif num ==2
    then C.gradient_yg(box)
    end

end

-- Define the function by which the box changes colour
function C.gradient_bgr(box)
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

-- Define the function by which the box changes colour
function C.gradient_br(box)
    -- We change colour based on its current "heat"
    time = box.heatUp

    -- Set some initial RGB values
    r = 0
    g = 0
    b = 0

    -- This is all the mathematical function of how the RGB values change according to time
    sectionLength = box.heatUpLimit / 2
    sec1 = 1*sectionLength
    sec2 = 2*sectionLength

    timeStep = 1/sectionLength
    if time < sec1
    then
        b = 1
        r = timeStep*time
        g = 0
        box:setFillColor(r,g,b,1);
    elseif time >= sec1 and time < sec2
    then
        b = 1 - timeStep*(time-sec1)
        r = 1
        g = 0
        box:setFillColor(r,g,b,1);
    end

end

-- Define the function by which the box changes colour
function C.gradient_yg(box)
    -- We change colour based on its current "heat"
    time = box.heatUp

    -- Set some initial RGB values
    r = 0
    g = 0
    b = 0

    -- This is all the mathematical function of how the RGB values change according to time
    sectionLength = box.heatUpLimit
    sec1 = 1*sectionLength

    timeStep = 1/sectionLength
    if time < sec1
    then
        b = 0
        r = 1 - timeStep*time
        g = 1
        box:setFillColor(r,g,b,1);
    end

end

C.selected_colour = C.loadSelectedColour() 

return C