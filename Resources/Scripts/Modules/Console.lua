consoleHistory = {}
line = 0
line_focus = 0
CONSOLE_MAX = 5
popDown = false

do
	originalPrint = print
	newPrint = function(...)
		local bigTable = {...}
		i = 1
		while bigTable[i] ~= nil do
			console_add(tostring(bigTable[i]))
			i = i + 1
		end
	end
	setOriginalPrint = function() print = originalPrint end
	setNewPrint = function() print = newPrint end
end

shift_press = false
caps_hold = false

consoleBuffer = nil
endsInCloseParen = nil
processConsole = false
nestLevel = 0
newHistory = nil
firstTime = true
io.output("XseraOutput.txt")

function console_draw(fontsize)
	graphics.set_camera(-320, -240, 320, 240)
	local i = 1
	while consoleHistory[i] ~= nil do
		if i <= CONSOLE_MAX then
			graphics.draw_text(consoleHistory[i], "CrystalClear", "left", -319, 232 - (i - 1) * fontsize + 1, fontsize)
			i = i + 1
		else
			return
		end
	end
end

function console_add(text, doPrint, output)
	if output ~= nil then
		io.output(output)
	else
		io.output("XseraOutput.txt")
	end
	table.insert(consoleHistory, text)
	if ((text ~= ">") and (text ~= ">>")) then
		if doPrint ~= false then
			originalPrint("[Console] " .. text)
		end
		io.write(text, "\n")
	end
	line = line + 1
	line_focus = line
end

function console_keyup (k)
	if k:gsub("(M)(%w+)", "%1", 1) == "M" then
		local side = nil
		local cmd = nil
		if k:gsub("(M)(%w+)(L)", "%3", 1) == "L" then
			side = "left"
			cmd = k:gsub("(M)(%w+)(L)", "%2", 1)
		elseif k:gsub("(M)(%w+)(R)", "%3", 1) == "R" then
			side = "right"
			cmd = k:gsub("(M)(%w+)(R)", "%2", 1)
		else
			cmd = k:gsub("(M)(%w+)", "%2", 1)
		end
		if cmd == "shift" then
			shift_press = false
		end
	end
end

function console_key (k)
	if k == "unhandled" then
		return
	end
	
	asciikey = k:byte(1)
	if k == "return" then
		if ((consoleHistory == ">>") or (consoleHistory == ">")) then
			return
		end
		io.write(consoleHistory[line], "\n")
		originalPrint("[Console] " .. consoleHistory[line])
		local string = nil
		local error = nil
		local list = { "if", "do", "while", "repeat", "for", "function", "local function" }
		num = 1
		while list[num] ~= nil do
			if consoleHistory[line]:find(list[num]) ~= nil then
				nestLevel = nestLevel + 1
				num = 8 -- outside of the range
			end
			num = num + 1
		end
		if (consoleHistory[line]:sub(-1, -1) == ")") then
			endsInCloseParen = true
		else
			endsInCloseParen = false
		end
		local withoutGT = nil
		if consoleHistory[line]:gsub("(>>)(.)", "%2", 1) ~= nil then
			withoutGT = consoleHistory[line]:gsub("(>>)(.)", "%2", 1)
		else
			withoutGT = consoleHistory[line]:gsub("(>>)(.)", "%2", 1)
		end
		if withoutGT == "end" then
			nestLevel = nestLevel - 1
			if nestLevel == 0 then
				processConsole = true
			elseif nestLevel < 0 then
				processConsole = true
			end
		end
		if consoleBuffer ~= nil then
			consoleBuffer = consoleBuffer .. "\n" .. withoutGT
		else
			consoleBuffer = consoleHistory[line]:gsub("(>)(.)", "%2", 1)
		end
		if endsInCloseParen == true then
			if consoleBuffer == consoleHistory[line]:gsub("(>)(.)", "%2", 1) then
				if consoleBuffer:find("function") == nil then
					processConsole = true
				end
			end
		end
		if processConsole == false then
			console_add(">>")
		else
			string, error = loadstring(consoleBuffer)
			if error == nil then
				string()
			else
				console_add(error)
			end
			consoleBuffer = nil
			nestLevel = 0
			console_add(">")
		end
	elseif k == "escape" then
		setNewPrint()
		if popDown == true then
			consoleDraw = false
			popDown = false
		else
			mode_manager.switch("MainMenu")
		end
	elseif k == "backspace" then
		if ((consoleHistory[line] ~= ">") and (consoleHistory[line] ~= ">>")) then
			consoleHistory[line] = consoleHistory[line]:sub(1, -2)
		end
	elseif k == "tab" then
		consoleDraw = false
		release = true
	elseif asciikey >= 97 and asciikey <= 122 then
		if k:byte(2, 2) == nil then
			if ((shift_press == true) or (caps_hold == true)) then
				consoleHistory[line] = consoleHistory[line] .. k:upper()
			else
				consoleHistory[line] = consoleHistory[line] .. k
			end
		end
	elseif asciikey == 32 then
		consoleHistory[line] = consoleHistory[line] .. k
	elseif k == "," then
		if ((shift_press == true) or (caps_hold == true)) then
			consoleHistory[line] = consoleHistory[line] .. "<"
		else
			consoleHistory[line] = consoleHistory[line] .. k
		end
	elseif k == "." then
		if ((shift_press == true) or (caps_hold == true)) then
			consoleHistory[line] = consoleHistory[line] .. ">"
		else
			consoleHistory[line] = consoleHistory[line] .. k
		end
	elseif k == "-" then
		if ((shift_press == true) or (caps_hold == true)) then
			consoleHistory[line] = consoleHistory[line] .. "_"
		else
			consoleHistory[line] = consoleHistory[line] .. k
		end
	elseif k == "1" then
		if ((shift_press == true) or (caps_hold == true)) then
			consoleHistory[line] = consoleHistory[line] .. "!"
		else
			consoleHistory[line] = consoleHistory[line] .. k
		end
	elseif k == "2" then
		if ((shift_press == true) or (caps_hold == true)) then
			consoleHistory[line] = consoleHistory[line] .. "@"
		else
			consoleHistory[line] = consoleHistory[line] .. k
		end
	elseif k == "3" then
		if ((shift_press == true) or (caps_hold == true)) then
			consoleHistory[line] = consoleHistory[line] .. "#"
		else
			consoleHistory[line] = consoleHistory[line] .. k
		end
	elseif k == "4" then
		if ((shift_press == true) or (caps_hold == true)) then
			consoleHistory[line] = consoleHistory[line] .. "$"
		else
			consoleHistory[line] = consoleHistory[line] .. k
		end
	elseif k == "5" then
		if ((shift_press == true) or (caps_hold == true)) then
			consoleHistory[line] = consoleHistory[line] .. "%"
		else
			consoleHistory[line] = consoleHistory[line] .. k
		end
	elseif k == "6" then
		if ((shift_press == true) or (caps_hold == true)) then
			consoleHistory[line] = consoleHistory[line] .. "^"
		else
			consoleHistory[line] = consoleHistory[line] .. k
		end
	elseif k == "7" then
		if ((shift_press == true) or (caps_hold == true)) then
			consoleHistory[line] = consoleHistory[line] .. "&"
		else
			consoleHistory[line] = consoleHistory[line] .. k
		end
	elseif k == "8" then
		if ((shift_press == true) or (caps_hold == true)) then
			consoleHistory[line] = consoleHistory[line] .. "*"
		else
			consoleHistory[line] = consoleHistory[line] .. k
		end
	elseif k == "9" then
		if ((shift_press == true) or (caps_hold == true)) then
			consoleHistory[line] = consoleHistory[line] .. "("
		else
			consoleHistory[line] = consoleHistory[line] .. k
		end
	elseif k == "0" then
		if ((shift_press == true) or (caps_hold == true)) then
			consoleHistory[line] = consoleHistory[line] .. ")"
		else
			consoleHistory[line] = consoleHistory[line] .. k
		end
	elseif k == "\'" then
		if ((shift_press == true) or (caps_hold == true)) then
			consoleHistory[line] = consoleHistory[line] .. "\""
		else
			consoleHistory[line] = consoleHistory[line] .. k
		end
	elseif k == "\=" then
		if ((shift_press == true) or (caps_hold == true)) then
			consoleHistory[line] = consoleHistory[line] .. "\+"
		else
			consoleHistory[line] = consoleHistory[line] .. k
		end
	elseif k == "/" then
		if ((shift_press == true) or (caps_hold == true)) then
			consoleHistory[line] = consoleHistory[line] .. "?"
		else
			consoleHistory[line] = consoleHistory[line] .. k
		end
	elseif k == "[" then
		if ((shift_press == true) or (caps_hold == true)) then
			consoleHistory[line] = consoleHistory[line] .. "{"
		else
			consoleHistory[line] = consoleHistory[line] .. k
		end
	elseif k == "]" then
		if ((shift_press == true) or (caps_hold == true)) then
			consoleHistory[line] = consoleHistory[line] .. "}"
		else
			consoleHistory[line] = consoleHistory[line] .. k
		end
	elseif k == ";" then
		if ((shift_press == true) or (caps_hold == true)) then
			consoleHistory[line] = consoleHistory[line] .. ":"
		else
			consoleHistory[line] = consoleHistory[line] .. k
		end
	elseif k == "left" then
		originalPrint("BOING")
	elseif k == "right" then
		originalPrint("BOING")
	elseif k == "up" then
		originalPrint("BOING")
	elseif k == "down" then
		originalPrint("BOING")
	elseif k == "KP9" then
		if line_focus > 1 then
			if newHistory == nil then
				newHistory = consoleHistory[line]
				originalPrint(newHistory)
			end
			line_focus = line_focus - 1
			if consoleHistory[line_focus]:sub(1, 1) == "$" then
				line_focus = line_focus + 1
			end
			while consoleHistory[line_focus]:sub(1, 1) ~= ">" do
				line_focus = line_focus - 1
			end
		end
		consoleHistory[line] = consoleHistory[line_focus]
	elseif k == "KP3" then
		originalPrint(line_focus, line)
		if line_focus < line then
			line_focus = line_focus + 1
			while consoleHistory[line_focus]:sub(1, 1) ~= ">" do
				line_focus = line_focus + 1
			end
			consoleHistory[line] = consoleHistory[line_focus]
		end
		originalPrint(line_focus, line)
		if ((line_focus == line) and (newHistory ~= nil)) then
			consoleHistory[line] = newHistory
			newHistory = nil
		end
		originalPrint(line_focus, line)
		if line_focus > line then
			line_focus = line_focus - 1
		end
		originalPrint(line_focus, line)
		originalPrint("----------")
	else
		if k:gsub("(M)(%w+)", "%1", 1) == "M" then
			local side = nil
			local cmd = nil
			if k:gsub("(M)(%w+)(L)", "%3", 1) == "L" then
				side = "left"
				cmd = k:gsub("(M)(%w+)(L)", "%2", 1)
			elseif k:gsub("(M)(%w+)(R)", "%3", 1) == "R" then
				side = "right"
				cmd = k:gsub("(M)(%w+)(R)", "%2", 1)
			else
				cmd = k:gsub("(M)(%w+)", "%2", 1)
			end
			if cmd == "shift" then
				shift_press = true
			end
			if cmd == "caps" then
				if caps_hold == true then
					caps_hold = false
				else
					caps_hold = true
				end
				originalPrint("Caps: ", caps_hold)
			end
		end
	end
end

function cout_table (t, name, doPrint)
	console_add(table_define(t, name), doPrint, "XseraTables.txt")
end


function errLog(text, level)
	console_add(text .. "(level " .. level .. ")")
	if level > 10 then
		os.exit()
	end
	if level > 5 then
		errNotice = { start = mode_manager.time(), duration = level - 5, text = text }
	end
end

--[[ error level scheme:
	1-5: non-fatal, continue
		1: code not implemented
		2: load error
	6-10: non-fatal, display on screen
	11-15: fatal, exit
		11: Improper input - data is not of the correct type
		12: No input given - file is missing necessary data
--]]