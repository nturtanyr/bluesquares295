-- Module for managing colour schemes and the graphic display

-- Dark mode
-- Font size?

-- Monochromatic
-- Numbers on boxes
-- Colour gradient used
local C = {}

function C.change_colour(box , num)
    
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

return C