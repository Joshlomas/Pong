Ball = Class{}

function Ball:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height

    -- provides random returns of value between left and right number
    self.dx = math.random(2) == 1 and -100 or 100
    self.dy = math.random(-50, 50)

end



-- resets the ball
function Ball:reset()
    -- positions the ball at the centre of the screen
    self.x = VIRTUAL_WIDTH / 2 - 2
    self.y = VIRTUAL_HEIGHT / 2 - 2

    -- provides the balls x and y variables a random value
    self.dx = math.random(2) == 1 and -100 or 100
    self.dy = math.random(-50, 50) * 1.5

end

-- implementing the collision function for the ball by utilising the relativity of the shapes
function Ball:collides(box)
    if self.x > box.x + box.width or self.x + self.width < box.x then
        return false
    end

    if self.y > box.y + box.height or self.y + self.height < box.y then
        return false
    end

    return true
end

-- applies velocity to the position, which is scaled by Deltatime
function Ball:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt

end

function Ball:render()
     -- rendering the ball to the centre
    love.graphics.rectangle('fill', self.x, self.y, 4, 4)
    
end