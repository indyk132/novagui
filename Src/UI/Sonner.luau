--[[
	Sonner Module - Template
	Toast notification system inspired by Emil Kowalski's Sonner.
	
	Usage:
		local Sonner = require(path.to.Sonner)
		
		-- Initialize with parent ScreenGui
		Sonner.Initialize(screenGui)
		
		-- Show notifications
		Sonner.info("Information message")
		Sonner.success("Operation successful!")
		Sonner.warning("Warning message")
		Sonner.error("Something went wrong")
		Sonner.toast("Simple toast message")
]]

local Sonner = {
	Queue = {},
	TweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
	Wrapper = nil,
	PendingQueue = {},
	Processing = false,
}

local TweenService = game:GetService("TweenService")

-- Default notification icons (Lucide icon names)
local NotificationIcons = {
	info = "info",
	success = "circle-check",
	warning = "triangle-alert",
	error = "circle-alert",
	loading = "loader-circle",
}

-- Optional Icons module reference (set via Initialize)
local Icons = nil

local function CreateNotificationObject(zindex: number, iconName: string?, text: string)
	-- Main notification container
	local notification = Instance.new("CanvasGroup")
	notification.BorderSizePixel = 0
	notification.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	notification.AnchorPoint = Vector2.new(0.5, 1)
	notification.Size = UDim2.new(1, 0, 0, 42)
	notification.GroupTransparency = 1
	notification.ZIndex = zindex
	notification.Position = UDim2.new(0.5, 0, 1, 50)

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = notification

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(40, 40, 40)
	stroke.Thickness = 1
	stroke.Parent = notification

	-- Icon (if provided and Icons module available)
	local hasIcon = iconName and Icons
	if hasIcon then
		local iconLabel = Instance.new("ImageLabel")
		iconLabel.BackgroundTransparency = 1
		iconLabel.Size = UDim2.fromOffset(16, 16)
		iconLabel.Position = UDim2.new(0, 12, 0.5, 0)
		iconLabel.AnchorPoint = Vector2.new(0, 0.5)
		iconLabel.ImageColor3 = Color3.fromRGB(200, 200, 200)
		iconLabel.Parent = notification

		if Icons.ApplyIcon then
			Icons.ApplyIcon(iconLabel, iconName)
		end
	end

	-- Text
	local textLabel = Instance.new("TextLabel")
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.new(1, -44, 1, 0)
	textLabel.Position = UDim2.new(0, hasIcon and 36 or 12, 0, 0)
	textLabel.Text = text
	textLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
	textLabel.TextSize = 13
	textLabel.Font = Enum.Font.GothamMedium
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextTruncate = Enum.TextTruncate.AtEnd
	textLabel.Parent = notification

	return notification
end

local function ProcessQueue()
	if Sonner.Processing then
		return
	end
	Sonner.Processing = true

	while #Sonner.PendingQueue > 0 do
		local entry = table.remove(Sonner.PendingQueue, 1)
		local notif = entry.notif
		local duration = entry.duration or 4.5

		if Sonner.Wrapper then
			notif.Parent = Sonner.Wrapper

			-- Animate in
			TweenService:Create(notif, Sonner.TweenInfo, {
				Position = UDim2.new(0.5, 0, 1, -8),
				GroupTransparency = 0,
			}):Play()

			-- Auto dismiss
			task.delay(duration, function()
				local tween = TweenService:Create(notif, Sonner.TweenInfo, {
					Position = UDim2.new(0.5, 0, 1, 50),
					GroupTransparency = 1,
				})
				tween:Play()
				tween.Completed:Connect(function()
					notif:Destroy()

					-- Remove from queue
					local index = table.find(Sonner.Queue, notif)
					if index then
						table.remove(Sonner.Queue, index)
					end
				end)
			end)
		end
	end

	Sonner.Processing = false
end

local function ShowToast(iconName: string?, text: string, duration: number?)
	if not Sonner.Wrapper then
		return
	end

	local zindex = #Sonner.Queue + 1
	local notif = CreateNotificationObject(zindex, iconName, text)

	table.insert(Sonner.Queue, notif)
	table.insert(Sonner.PendingQueue, {
		notif = notif,
		duration = duration or 4.5,
	})

	task.spawn(ProcessQueue)
end

--[[
	Initialize Sonner with a parent ScreenGui
	@param parent The ScreenGui to parent notifications to
	@param iconsModule Optional Icons module for displaying icons
]]
function Sonner.Initialize(parent: ScreenGui, iconsModule: any?)
	Icons = iconsModule

	Sonner.Wrapper = Instance.new("Frame")
	Sonner.Wrapper.BackgroundTransparency = 1
	Sonner.Wrapper.Size = UDim2.new(0, 360, 0, 200)
	Sonner.Wrapper.Position = UDim2.new(0.5, 0, 1, -20)
	Sonner.Wrapper.AnchorPoint = Vector2.new(0.5, 1)
	Sonner.Wrapper.ZIndex = 100000
	Sonner.Wrapper.Parent = parent
end

--[[
	Show an info notification
	@param text The notification text
	@param duration Optional duration in seconds (default: 4.5)
]]
function Sonner.info(text: string, duration: number?)
	ShowToast(NotificationIcons.info, text, duration)
end

--[[
	Show a success notification
	@param text The notification text
	@param duration Optional duration in seconds (default: 4.5)
]]
function Sonner.success(text: string, duration: number?)
	ShowToast(NotificationIcons.success, text, duration)
end

--[[
	Show a warning notification
	@param text The notification text
	@param duration Optional duration in seconds (default: 4.5)
]]
function Sonner.warning(text: string, duration: number?)
	ShowToast(NotificationIcons.warning, text, duration)
end

--[[
	Show an error notification
	@param text The notification text
	@param duration Optional duration in seconds (default: 4.5)
]]
function Sonner.error(text: string, duration: number?)
	ShowToast(NotificationIcons.error, text, duration)
end

--[[
	Show a simple toast without icon
	@param text The notification text
	@param duration Optional duration in seconds (default: 4.5)
]]
function Sonner.toast(text: string, duration: number?)
	ShowToast(nil, text, duration)
end

--[[
	Clear all active notifications
]]
function Sonner.clear()
	for _, notif in ipairs(Sonner.Queue) do
		notif:Destroy()
	end
	Sonner.Queue = {}
	Sonner.PendingQueue = {}
end

return Sonner
