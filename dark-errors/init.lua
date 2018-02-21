local currentFolder = (...):match("(.+)[/.].*$")

local function error_printer(msg, layer)
	print((debug.traceback("Error: " .. tostring(msg), 1+(layer or 1)):gsub("\n[^\n]+$", "")))
end

function love.errhand(msg)
	msg = tostring(msg)

	error_printer(msg, 2)

	if not love.window or not love.graphics or not love.event then
		return
	end

	if not love.graphics.isCreated() or not love.window.isOpen() then
		local success, status = pcall(love.window.setMode, 800, 600)
		if not success or not status then
			return
		end
	end

	-- Reset state.
	if love.mouse then
		love.mouse.setVisible(true)
		love.mouse.setGrabbed(false)
		love.mouse.setRelativeMode(false)
	end
	if love.joystick then
		-- Stop all joystick vibrations.
		for i,v in ipairs(love.joystick.getJoysticks()) do
			v:setVibration()
		end
	end
	if love.audio then love.audio.stop() end
	love.graphics.reset()
	local font = love.graphics.setNewFont(math.floor(love.window.toPixels(14)))

	love.graphics.setBackgroundColor(38, 38, 38)
	love.graphics.setColor(255, 255, 255, 255)

	local trace = debug.traceback()

	love.graphics.clear(love.graphics.getBackgroundColor())
	love.graphics.origin()

	local err = {}

	table.insert(err, msg.."\n\n")

	for l in string.gmatch(trace, "(.-)\n") do
		if not string.match(l, "boot.lua") and not string.match(l, "errorscreen/init.lua") then
			l = string.gsub(l, "stack traceback:", "Traceback:\n")
			table.insert(err, l)
		end
	end

	local p = table.concat(err, "\n")

	p = string.gsub(p, "\t", "")
	p = string.gsub(p, "%[string \"(.-)\"%]", "%1")

    -- load image
    --errorImage = love.graphics.newImage(currentFolder .. '/error.png')


    local function format(stack)
        local result = {}
        local lines = string_split(stack, '\n')
        for k, v in ipairs(lines) do
            local parts = string_split(v, ':')
            for i=1, #parts do
                if i == 1 then
                    table.insert(result, {156, 220, 254})
                    table.insert(result, parts[i])
                elseif i == 2 then
                    table.insert(result, {123, 255, 219})
                    table.insert(result, parts[i])
                else
                    table.insert(result, {0, 255, 0})
                    table.insert(result, parts[i])
                end
                if i < #parts then
                    result[#result] = result[#result] .. ":"
                else
                    result[#result-1] = {255, 255, 255}
                end
            end
            result[#result] = result[#result] .. "\n"
        end
        result[#result-1] = {255, 255, 255}
        return result
    end
    stackTrace = format(p)


	local function draw()
		local pos = love.window.toPixels(70)
		love.graphics.clear(love.graphics.getBackgroundColor())
        --love.graphics.draw(errorImage, pos, pos)
        love.graphics.printf(stackTrace, pos + 70, pos + 64, love.graphics.getWidth() - pos - 70)
		love.graphics.present()
	end

	while true do
		love.event.pump()

		for e, a, b, c in love.event.poll() do
			if e == "quit" then
				return
			elseif e == "keypressed" and a == "escape" then
				return
			elseif e == "touchpressed" then
				local name = love.window.getTitle()
				if #name == 0 or name == "Untitled" then name = "Game" end
				local buttons = {"OK", "Cancel"}
				local pressed = love.window.showMessageBox("Quit "..name.."?", "", buttons)
				if pressed == 1 then
					return
				end
			end
		end

		draw()

		if love.timer then
			love.timer.sleep(0.1)
		end
	end

end

-- Service functions
function string_split(inputstr, sep)
    sep = sep == nil and "%s" or sep
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		table.insert(t, str)
    end
    return t
end
