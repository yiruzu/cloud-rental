local FloatingHelpText = function(msg, vehicle)
	local vehCoords = GetEntityCoords(vehicle)
	local _, maxZ = GetModelDimensions(GetEntityModel(vehicle))
	---@diagnostic disable-next-line: param-type-mismatch
	local helpTextPosition = vec3(vehCoords.x, vehCoords.y, (vehCoords.z + maxZ))

	AddTextEntry("FloatingHelpText", msg)
	-- SetFloatingHelpTextToEntity(1, vehicle, 0.0, 0.0)
	SetFloatingHelpTextWorldPosition(1, helpTextPosition.x, helpTextPosition.y, helpTextPosition.z)
	SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
	BeginTextCommandDisplayHelp("FloatingHelpText")
	EndTextCommandDisplayHelp(2, false, false, -1)
end

local HelpText = function(msg)
	AddTextEntry("HelpText", msg)
	BeginTextCommandDisplayHelp("HelpText")
	EndTextCommandDisplayHelp(0, false, false, -1)
end

return {
	FloatingHelpText = FloatingHelpText,
	HelpText = HelpText,
}
