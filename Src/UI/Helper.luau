--[[
	Helper Module - Template
	Various UI utility functions for common interactions.
	
	Usage:
		local Helper = require(path.to.Helper)
		Helper.HoverEffect(button, hoverColor, normalColor)
		Helper.Ripple(button)
]]

local Helper = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

--[[
	Add ripple effect to a button on click
	@param button The button to add ripple effect to
	@param color Optional ripple color (default: white)
]]
function Helper.Ripple(button: TextButton | ImageButton, color: Color3?)
	color = color or Color3.fromRGB(255, 255, 255)
	button.ClipsDescendants = true

	button.MouseButton1Click:Connect(function()
		local mouse = UserInputService:GetMouseLocation()
		local absolutePos = button.AbsolutePosition
		local relativeX = mouse.X - absolutePos.X
		local relativeY = mouse.Y - absolutePos.Y

		local circle = Instance.new("Frame")
		circle.BackgroundColor3 = color
		circle.BackgroundTransparency = 0.7
		circle.Position = UDim2.fromOffset(relativeX, relativeY)
		circle.AnchorPoint = Vector2.new(0.5, 0.5)
		circle.Size = UDim2.fromOffset(0, 0)

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(1, 0)
		corner.Parent = circle

		circle.Parent = button

		local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
		local tween = TweenService:Create(circle, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.fromOffset(size, size),
			BackgroundTransparency = 1,
		})

		tween:Play()
		tween.Completed:Connect(function()
			circle:Destroy()
		end)
	end)
end

--[[
	Add hover effect to a UI element
	@param element The UI element to add hover effect to
	@param hoverColor Color when hovered
	@param normalColor Color when not hovered (defaults to current BackgroundColor3)
]]
function Helper.HoverEffect(element: GuiObject, hoverColor: Color3?, normalColor: Color3?)
	normalColor = normalColor or element.BackgroundColor3
	hoverColor = hoverColor or Color3.fromRGB(
		math.min(normalColor.R * 255 + 20, 255) / 255,
		math.min(normalColor.G * 255 + 20, 255) / 255,
		math.min(normalColor.B * 255 + 20, 255) / 255
	)

	element.MouseEnter:Connect(function()
		TweenService:Create(element, TweenInfo.new(0.15), {
			BackgroundColor3 = hoverColor,
		}):Play()
	end)

	element.MouseLeave:Connect(function()
		TweenService:Create(element, TweenInfo.new(0.15), {
			BackgroundColor3 = normalColor,
		}):Play()
	end)
end

--[[
	Add hover transparency effect to a UI element
	@param element The UI element
	@param hoverTransparency Transparency when hovered
	@param normalTransparency Transparency when not hovered
]]
function Helper.HoverTransparency(element: GuiObject, hoverTransparency: number?, normalTransparency: number?)
	normalTransparency = normalTransparency or element.BackgroundTransparency
	hoverTransparency = hoverTransparency or math.max(normalTransparency - 0.2, 0)

	element.MouseEnter:Connect(function()
		TweenService:Create(element, TweenInfo.new(0.15), {
			BackgroundTransparency = hoverTransparency,
		}):Play()
	end)

	element.MouseLeave:Connect(function()
		TweenService:Create(element, TweenInfo.new(0.15), {
			BackgroundTransparency = normalTransparency,
		}):Play()
	end)
end

--[[
	Truncate text to a maximum length
	@param text The text to truncate
	@param maxLength Maximum length before truncation
	@return Truncated text with "..." if needed
]]
function Helper.Truncate(text: string, maxLength: number): string
	if #text <= maxLength then
		return text
	end
	return string.sub(text, 1, maxLength - 3) .. "..."
end

--[[
	Format a large number to a readable string (e.g., 1.5K, 2.3M)
	@param num The number to format
	@return Formatted string
]]
function Helper.FormatNumber(num: number): string
	if num >= 1000000 then
		return string.format("%.1fM", num / 1000000)
	elseif num >= 1000 then
		return string.format("%.1fK", num / 1000)
	end
	return tostring(num)
end

--[[
	Format seconds to HH:MM:SS timestamp
	@param timestamp Time in seconds
	@return Formatted timestamp string
]]
function Helper.FormatTimestamp(timestamp: number): string
	local seconds = math.floor(timestamp) % 60
	local minutes = math.floor(timestamp / 60) % 60
	local hours = math.floor(timestamp / 3600) % 24
	return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

--[[
	Create a debounced version of a function
	@param func The function to debounce
	@param wait Wait time in seconds
	@return Debounced function
]]
function Helper.Debounce(func: (...any) -> (), wait: number): (...any) -> ()
	local lastCall = 0
	return function(...)
		local now = tick()
		if now - lastCall >= wait then
			lastCall = now
			func(...)
		end
	end
end

--[[
	Tween a UI element with default settings
	@param element The UI element to tween
	@param properties Properties to tween to
	@param duration Optional duration (default: 0.2)
	@return The Tween object
]]
function Helper.Tween(element: Instance, properties: { [string]: any }, duration: number?): Tween
	local tween = TweenService:Create(
		element,
		TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		properties
	)
	tween:Play()
	return tween
end

return Helper
