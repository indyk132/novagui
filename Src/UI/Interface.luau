--[[
	Interface Module - Template
	Utility for creating UI elements with properties applied automatically.
	
	Usage:
		local Interface = require(path.to.Interface)
		
		local frame = Interface.New("Frame", {
			Size = UDim2.fromOffset(200, 100),
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			Parent = screenGui,
			
			["UICorner"] = { CornerRadius = UDim.new(0, 8) },
			["UIStroke"] = { Color = Color3.fromRGB(50, 50, 50), Thickness = 1 },
		})
]]

local Interface = {}

-- Special UI components that can be created inline
local SpecialProperties = {
	["UICorner"] = true,
	["UIStroke"] = true,
	["UIPadding"] = true,
	["UIListLayout"] = true,
	["UIGridLayout"] = true,
	["UITableLayout"] = true,
	["UIPageLayout"] = true,
	["UIFlexItem"] = true,
	["UISizeConstraint"] = true,
	["UITextSizeConstraint"] = true,
	["UIAspectRatioConstraint"] = true,
	["UIGradient"] = true,
	["UIScale"] = true,
}

--[[
	Create a new instance with properties
	@param className The class name of the instance to create
	@param properties Table of properties to apply (supports nested UI components)
	@return The created instance
]]
function Interface.New(className: string, properties: { [string]: any }?): Instance
	local instance = Instance.new(className)

	if properties then
		for key, value in pairs(properties) do
			if SpecialProperties[key] then
				-- Create UI component as child
				local uiComponent = Instance.new(key)
				if type(value) == "table" then
					for prop, val in pairs(value) do
						uiComponent[prop] = val
					end
				end
				uiComponent.Parent = instance
			else
				instance[key] = value
			end
		end
	end

	return instance
end

--[[
	Create a ScreenGui with common settings
	@param name The name of the ScreenGui
	@param parent Optional parent (defaults to CoreGui/PlayerGui)
	@return The created ScreenGui
]]
function Interface.CreateScreenGui(name: string, parent: Instance?): ScreenGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = name
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 999999

	if parent then
		screenGui.Parent = parent
	else
		-- Try gethui first, then CoreGui
		local success, _ = pcall(function()
			if gethui then
				screenGui.Parent = gethui()
			else
				screenGui.Parent = wax.shared.CoreGui
			end
		end)

		if not success then
			pcall(function()
				screenGui.Parent = wax.shared.Players.LocalPlayer:WaitForChild("PlayerGui")
			end)
		end
	end

	return screenGui
end

--[[
	Create a TextLabel with sensible defaults
]]
function Interface.CreateTextLabel(properties: { [string]: any }): TextLabel
	local defaults = {
		BackgroundTransparency = 1,
		TextColor3 = Color3.fromRGB(220, 220, 220),
		TextSize = 14,
		Font = Enum.Font.GothamMedium,
		TextXAlignment = Enum.TextXAlignment.Left,
	}

	for key, value in pairs(defaults) do
		if properties[key] == nil then
			properties[key] = value
		end
	end

	return Interface.New("TextLabel", properties) :: TextLabel
end

--[[
	Create a TextButton with sensible defaults
]]
function Interface.CreateTextButton(properties: { [string]: any }): TextButton
	local defaults = {
		BackgroundTransparency = 1,
		TextColor3 = Color3.fromRGB(220, 220, 220),
		TextSize = 14,
		Font = Enum.Font.GothamMedium,
		AutoButtonColor = false,
	}

	for key, value in pairs(defaults) do
		if properties[key] == nil then
			properties[key] = value
		end
	end

	return Interface.New("TextButton", properties) :: TextButton
end

--[[
	Create an ImageLabel with sensible defaults
]]
function Interface.CreateImageLabel(properties: { [string]: any }): ImageLabel
	local defaults = {
		BackgroundTransparency = 1,
		ScaleType = Enum.ScaleType.Fit,
	}

	for key, value in pairs(defaults) do
		if properties[key] == nil then
			properties[key] = value
		end
	end

	return Interface.New("ImageLabel", properties) :: ImageLabel
end

--[[
	Create an ImageButton with sensible defaults
]]
function Interface.CreateImageButton(properties: { [string]: any }): ImageButton
	local defaults = {
		BackgroundTransparency = 1,
		ScaleType = Enum.ScaleType.Fit,
		AutoButtonColor = false,
	}

	for key, value in pairs(defaults) do
		if properties[key] == nil then
			properties[key] = value
		end
	end

	return Interface.New("ImageButton", properties) :: ImageButton
end

--[[
	Create a ScrollingFrame with sensible defaults
]]
function Interface.CreateScrollingFrame(properties: { [string]: any }): ScrollingFrame
	local defaults = {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
	}

	for key, value in pairs(defaults) do
		if properties[key] == nil then
			properties[key] = value
		end
	end

	return Interface.New("ScrollingFrame", properties) :: ScrollingFrame
end

return Interface
