local Input = {}
Input.__index = Input

function Input.new(type)
    local instance = setmetatable({}, Input)
    instance.type = type
    instance.profile = {}
    instance.initiated = false
    table.insert(Input, instance)
    return instance
end

function Input:add(input, _function, releaseFunction)
    self.profile[input] = {
        ['input'] = input,
        ['activate'] = _function,
    }

    if (releaseFunction) then
        self.profile[input].releaseFunction = releaseFunction
    end

    return self.profile
end

function Input:removeAllActions()
    self.profile = {}
end

function Input:removeAction(key)
    for _, profile in pairs(self.profile) do
        if (profile.input == key) then
            profile = nil
        end
    end
    collectgarbage("collect")
end

function Input:changeBind(key, newKey)
    coroutine.wrap(function()
        for _, profile in pairs(self.profile) do
            if profile.input == key then
                profile.input = nil
                profile.input = newKey
            end
        end
        collectgarbage("collect")
    end)()
end

function Input:changeAction(key, newfunction)
    coroutine.wrap(function()
        for _, profile in pairs(self.profile) do
            if profile.input == key then
                profile.active = nil
                profile.active = newfunction
            end
        end
        collectgarbage("collect")
    end)()
end

function Input:update()
    for _, input in ipairs(Input) do
        if input.type then
            if input.type == "hold" and input.initiated == true then
                for _, profile in pairs(input.profile) do
                    local key = profile.input
                    if love.keyboard.isDown(key) then
                        profile.activate()
                    end
                end
            end
        end
    end
end

function Input:init()
    self.initiated = true
    if self.type == "tap" then
        function love.keypressed(k)
            for _, profile in pairs(self.profile) do
                local key = profile.input
                if key == k then
                    profile.activate()
                end
            end
        end
        function love.keyreleased(k)
            for _, profile in pairs(self.profile) do
                local key = profile.input 
                if (key == k) then
                    if (profile.releaseFunction) then                
                        profile.releaseFunction()
                    end
                end
            end
        end
    end
    if (self.type == "mouse") then
        function love.mousepressed(x, y, button)
            for _, profile in pairs(self.profile) do
                if button == profile.input then
                    profile.activate()
                end
            end
        end
    end
end

return Input