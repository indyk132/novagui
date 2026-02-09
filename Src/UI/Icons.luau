--[[
	Icons Module - Template
	Fetches and manages Lucide icons for the UI.
	Uses deividcomsono's lucide-roblox-direct for icon spritesheet.
	
	Usage:
		local Icons = require(path.to.Icons)
		
		-- Apply icon to ImageLabel
		Icons.ApplyIcon(imageLabel, "settings")
		Icons.ApplyIcon(imageLabel, "home")
		
		-- Get icon data
		local iconData = Icons.GetIcon("user")
		if iconData then
			print(iconData.Url, iconData.ImageRectOffset, iconData.ImageRectSize)
		end
]]

local Icons = {}

export type IconData = {
	Url: string,
	Id: number,
	IconName: string,
	ImageRectOffset: Vector2,
	ImageRectSize: Vector2,
}

-- Try to load the icons module
local Success, IconsModule = pcall(function()
	local IconFetchSuccess, IconModuleSource = pcall(request, {
		Url = "https://raw.githubusercontent.com/deividcomsono/lucide-roblox-direct/refs/heads/main/source.lua",
		Method = "GET",
	})

	assert(
		IconFetchSuccess and IconModuleSource.Success or IconModuleSource.StatusCode >= 200 and IconModuleSource.StatusCode < 300,
		"Failed to fetch lucide icons direct module source"
	)
	return (loadstring(IconModuleSource.Body) :: () -> { Icons: { string }, GetAsset: (Name: string) -> IconData? })()
end)

if not Success then
	warn("[Icons] Failed to load Lucide icons module. Icons will not be available.")
end

--[[
	Get icon data by name
	@param iconName The name of the Lucide icon
	@return IconData or nil if not found
]]
function Icons.GetIcon(iconName: string): IconData?
	if not Success or not IconsModule then
		return nil
	end

	local success, icon = pcall(IconsModule.GetAsset, iconName)
	if not success then
		return nil
	end

	return icon
end

--[[
	Apply icon to an ImageLabel
	@param imageLabel The ImageLabel to apply the icon to
	@param iconName The name of the Lucide icon
	@return boolean indicating success
]]
function Icons.ApplyIcon(imageLabel: ImageLabel, iconName: string): boolean
	local icon = Icons.GetIcon(iconName)
	if not icon then
		return false
	end

	imageLabel.Image = icon.Url
	imageLabel.ImageRectOffset = icon.ImageRectOffset
	imageLabel.ImageRectSize = icon.ImageRectSize
	return true
end

--[[
	Check if icons are available
	@return boolean
]]
function Icons.IsAvailable(): boolean
	return Success and IconsModule ~= nil
end

--[[
	Get list of all available icon names
	@return Array of icon names or empty array if not loaded
]]
function Icons.GetAllIconNames(): { string }
	if not Success or not IconsModule or not IconsModule.Icons then
		return {}
	end
	return IconsModule.Icons
end

return Icons
