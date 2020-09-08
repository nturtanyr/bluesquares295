local M = {}
 
M.score = 0  -- Set the score to 0 initially

function M.format_gametime( time )
    --M.save(M.score)

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

function M.initScore( options )
 
    local customOptions = options or {}
    local opt = {}
    opt.x = customOptions.x or display.contentCenterX
    opt.y = customOptions.y or opt.fontSize*0.5

    -- Create the score display object
    M.scoreText = display.newText( M.format_gametime(M.score), opt.x, opt.y, "Courier New", 32)
    M.scoreText:setFillColor(0,0,0)
 
    return M.scoreText
end
 
function M.setScore( value )
 
    M.score = tonumber(value)
    M.scoreText.text = M.format_gametime(M.score)
end
 
function M.getScore()
 
    return M.score
end
 
function M.addScore( amount )
 
    M.score = M.score + tonumber(amount)
    M.scoreText.text = string.format( M.format, M.score )
end

function M.saveScore()
 
    local saved = system.setPreferences( "app", { highScore=M.score } )
    if ( saved == false ) then
        print( "ERROR: could not save score" )
    end
end
 
function M.loadScore()
 
    local score = system.getPreference( "app", "highScore", "number" )
 
    if ( score ) then
        return tonumber(score)
    else
        print( "ERROR: could not load score (score may not exist in storage)" )
    end
end

function M.saveTokens()
 
    local saved = system.setPreferences( "app", { tokenCount=M.tokens } )
    if ( saved == false ) then
        print( "ERROR: could not save tokens" )
    end

end

function M.loadTokens()
 
    local tokens = system.getPreference( "app", "tokenCount", "number" )
 
    if ( tokens ) then
        return tonumber(tokens)
    else
        print( "ERROR: could not load tokens (tokens may not exist in storage)" )
        return 0
    end

end
 
function M.subtractTokens( value )
 
    M.tokens = M.tokens - tonumber(value)
    M.saveTokens()
end

function M.addTokens( value )
 
    M.tokens = M.tokens + tonumber(value)
    M.saveTokens()
end
 
function M.getTokens()
 
    return M.tokens
end

M.tokens = M.loadTokens()  -- Set the tokens to how many we have on our phone

return M