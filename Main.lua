Class = require 'class'
push = require 'push'

require 'Ball'
require 'Paddle'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- inputs the speed in which the paddles move, which is multiplied by Deltatime 
PADDLE_SPEED = 200

-- runs the game once when the game starts up and is used to initilise the game

function love.load()
    math.randomseed(os.time())

    -- sets the default filter to "nearest neighbour", which provides a sharper image, enhancing 2D
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- inputs "Pong" as a title of the application
    love.window.setTitle('Pong')

    -- inputs texts in downloaded customised fonts
    smallFont = love.graphics.newFont('font.ttf', 8)
    -- large font for drawing the score in the screen
    scoreFont = love.graphics.newFont('font.ttf', 32)
    victoryFont = love.graphics.newFont('font.ttf', 24)
    -- setting LOVE's font to small font
    love.graphics.setFont(smallFont)

    sounds = {
        ['paddle_hit'] = love.audio.newSource('paddle_hit.wav', 'static'),
        ['point_scored'] = love.audio.newSource('point_scored.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('wall_hit.wav', 'static')
    }

        -- inputs the virtual resolution that will be rendered
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizeable = true
        })

    -- begins the scores at 0, which are rendered on the screen to keep track of scores
    player1Score = 0
    player2Score = 0

    -- initialises a random serves, by implementing a 50/50 probability (boolean)
    servingPlayer = 1

    winningPlayer = 0

    -- inputting paddles using specifications - globailising the paddles so they can be recognised for other functions
    player1 = Paddle (5, 20, 5, 20)
    player2 = Paddle (VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

    -- inputting the ball in the the middle of the screen
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 5, 5)

    -- specifying the dx accordint to the coin flip
    if servingPlayer == 1 then 
        ball.dx = 100
    else
        ball.dx = -100
    end

    gameState = 'start'
end

function love.resize(w, h)
    push:resize(w, h)
end

-- runs the frames by utilising "dt", which is passed in the data, our delta in seconds 
function love.update(dt)
    if gameState == 'play' then

        -- resets the ball and updates the score when the ball reaches the left or right side of the screen
        -- indicates a winner when the score of 10 has been reached, entering 'victory state' otherwise, play on
        if ball.x <= 0 then
            servingPlayer = 1
            player2Score = player2Score + 1

            -- implementing sound of scoring
            sounds['point_scored']:play()

            if player2Score == 10 then
                winningPlayer = 2
                gameState = 'done'
            else
                gameState = 'serve'

                -- resets the ball in the middle of the screen
                ball:reset()
            end
        end

        if ball.x >= VIRTUAL_WIDTH then
            servingPlayer = 2
            player1Score = player1Score + 1

            -- implementing sound of scoring
            sounds['point_scored']:play()

            if playerScore == 10 then
                winningPlayer = 1
                gameState = 'done'
            else
                gameState = 'serve'
                ball:reset()
            end
        end

        -- incorporating the collisions between the ball and our paddles
        -- ball colliding with paddle1 will hit the ball to the right and vice vera
        -- incorporated ball collision detecting, which reverses dx if true
        -- as a result will increase spead and altering dy based on the point of impact
        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.03
            ball.x = player1.x + 5
            -- implementing the sound when the ball collides with a paddle
            sounds['paddle_hit']:play()

            -- maintains speed at the same direction, whilst randomising 
            if ball.dy <= 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
        end

        -- ball colliding with paddle2 will hit the ball to the left
        if ball:collides(player2) then
            ball.dx = -ball.dx * 1.03
            ball.x = player2.x - 4
            -- implementing the sound when the ball collides with a paddle
            sounds['paddle_hit']:play()

            -- maintains speed at the same direction, whilst randomising 
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
        end

        -- inputs boundaries for the top and bottom of the screen and reverse if collided
        if ball.y <= 0 then
            ball.dy = -ball.dy
            ball.y = 0
            -- implementing the sounds for when the ball hits the top or bottom of the screen
            sounds['wall_hit']:play()
        end

        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.dy = -ball.dy
            ball.y = VIRTUAL_HEIGHT - 4
            -- implementing the sounds for when the ball hits the top or bottom of the screen
            sounds['wall_hit']:play()
        end

        player1:update(dt)
        player2:update(dt)

        -- implementing player 1s movements by scaling the paddle speeds by Deltatime
        if love.keyboard.isDown('w') then
            player1.dy = -PADDLE_SPEED
        elseif love.keyboard.isDown('s') then
            player1.dy = PADDLE_SPEED
        else
            player1.dy = 0
        end

        -- implementing player AIs movements tracking the movement of the ball
        -- the paddle also scales to the speed of the ball
        if ball.dy < 0 then
            player2.y = ball.y
        elseif ball.dy > 0 then
            player2.y = ball.y
        else
            player2.y = 0
        end

        -- update will reset the ball when the game enters 'game state'
        -- speed has been based on Deltatime and movement is framerate-independant 
        if gameState == 'play' then
            ball:update(dt)
        end
    end
end

-- keyboard handling, called by LOVE each frame;
-- passes in the key we pressed so we can access
function love.keypressed(key)

    -- allows keys to be accessed by the string name 
    if key == 'escape' then
        
        -- setting 'enter' as the begin function to 'play mode'
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'victory' then
            gameState = 'start'
            player1Score = 0
            player2Score = 0
        elseif gameState == 'serve' then
            gameState = 'play'
        end
    end
end

-- Called after update by LOVE, used to draw anything to the screen, update or otherwise
-- used to implement drawings on the screen as well as updates 
function love.draw()

    -- starts generating the application at virtual resolution
    push:apply('start')

    -- implements the background colouring of the screen to one of which is similar to original 'Pong'
    love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 255 / 255)
    
    -- implement different drawings based on the different states created - using small fonts
    love.graphics.setFont(smallFont)

    -- only present the title at the beginning of the game
    if gameState == 'start' then
        -- implements 'Welcome to Pong' at the centre of the screen by using the specifications
        love.graphics.printf("Welcome to Pong", 0, 20, VIRTUAL_WIDTH, 'center')
        -- implements 'Press Enter to Play!' just below 'welcome to pong' using the specifications
        love.graphics.printf("Press Enter to Play!", 0, 32, VIRTUAL_WIDTH, 'center') 
    elseif gameState == 'serve' then
        -- implementing a 'Press Enter to Serve' message when it is the player X's turn to serve
        love.graphics.printf("Player " .. tostring(servingPlayer) .. "'s turn!", 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press Enter to Serve!", 0, 32, VIRTUAL_WIDTH, 'center')
    -- implementing a victory message at 'victory state'
    elseif gameState == 'victory'then
        love.graphics.setFont(victoryFont)
        love.graphics.printf("Player " .. tostring(winningPlayer) .. " wins!", 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press Enter to Serve!", 0, 42, VIRTUAL_WIDTH, 'center')
    -- no messages during 'plat state'
    elseif gameState == 'play' then
    end

    -- implements the scoring on the screen using the specifications
    love.graphics.setFont(scoreFont)
    love.graphics.print(player1Score, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(player2Score, VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)

    -- inputs the paddles and the ball at the described points

    -- inputs first paddle (left side)
    player1:render()
    player2:render()

   ball:render()
   
   displayFPS()

    -- ends the rendering
    push:apply ('end')
end

-- prints the FPS text on the screen along with the colour and the font
function displayFPS()
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.setFont(smallFont)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 40, 20)
    love.graphics.setColor(1, 1, 1, 1)
end