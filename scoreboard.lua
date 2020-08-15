local composer = require( "composer" )
 
local scene = composer.newScene()
local score = require("score");
 
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

 
 
 
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
 
-- create()
function scene:create( event )
 
    local sceneGroup = self.view
     
    score_background_display = display.newGroup()
    score_board_display = display.newGroup()
    score_ui_display = display.newGroup()
    -- Code here runs when the scene is first created but has not yet appeared on screen
    sceneGroup:insert(score_background_display)
    sceneGroup:insert(score_board_display)
    sceneGroup:insert(score_ui_display)
 
    lastHighScore = score.load()
end
 
 
-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
    -- Make the background white
    local backdrop_behind = display.newRect(score_background_display, display.contentCenterX,display.contentCenterY,display.contentWidth,display.contentHeight);
    backdrop_behind.isHitTestable = true
    backdrop_behind.isVisible = false
    backdrop_behind:addEventListener("tap", function (event) 
        composer.hideOverlay("fade", 500);
    end);
    local backdrop = display.newRect(score_board_display, display.contentCenterX,display.contentCenterY,display.contentWidth*.8,display.contentHeight*.8);
    backdrop:setFillColor( 1, 1, 1, .9)
    scoreboardtext_intro = display.newText(score_ui_display, "Your high \nscore is:", phoneXSize/2, phoneYSize/2 - 64, "Courier New", 32);
    scoreboardtext_intro:setFillColor( 0, 0, 0 );
    scoreboardtext = display.newText(score_ui_display, score.format_gametime(lastHighScore), phoneXSize/2, phoneYSize/2, "Courier New", 32);
    scoreboardtext:setFillColor( 0, 0, 0 );
 
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
-- -----------------------------------------------------------------------------------
 
return scene