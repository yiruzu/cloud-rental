local Config = require("config.cfg_main")

local DebugPrint = function(...)
	if Config.DebugMode then
		local args = { ... }
		local printPrefix = ""
		local lastArg = args[#args]

		-- Check for recognized print types and assign prefixes
		if lastArg == "info" then
			printPrefix = "^5[INFO]^0 "
			table.remove(args)
		elseif lastArg == "warning" then
			printPrefix = "^3[WARNING]^0 "
			table.remove(args)
		elseif lastArg == "error" then
			printPrefix = "^1[ERROR]^0 "
			table.remove(args)
		end

		-- Retrieve file and line number information from debug stack
		local debugInfo = debug.getinfo(2, "Sl")
		local fileInfo = debugInfo.short_src or "Unknown file"
		local lineNumber = debugInfo.currentline or "Unknown line"

		-- Print formatted debug message
		local debugMessage = table.concat(args, " ")
		print(("%s%s ^3[%s:%d]^0"):format(printPrefix, debugMessage, fileInfo, lineNumber))
	end
end

return DebugPrint
