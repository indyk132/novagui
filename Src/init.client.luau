--[[
	Nova UI Library
	General-purpose executor GUI framework with Nova's visual style.
	
	Layout:
	- Title bar with icon, title, version, settings gear, minimize, close
	- Left sidebar with category list
	- Right content area with options for selected category
	- Settings panel (DPI scale, etc.)
	
	API:
		local Nova = loadstring(...)()
		local Main = Nova:AddCategory("Main", "home")
		Main:AddToggle("Aimbot", false, function(value) end)
		Main:AddSlider("FOV", 50, 1, 360, function(value) end)
		Main:AddDropdown("Mode", {"Silent", "Legit"}, "Silent", function(value) end)
		Main:AddButton("Execute", function() end)
		Main:AddKeybind("Toggle", Enum.KeyCode.RightShift, function(key) end)
		Main:AddLabel("Status: Ready")
		Main:AddSeparator()
]]

-- UI Modules
local UI = script.UI
local Theme = require(UI.Theme)
local Interface = require(UI.Interface)
local Helper = require(UI.Helper)
local Resize = require(UI.Resize)
local Drag = require(UI.Drag)
local Sonner = require(UI.Sonner)
local Icons = require(UI.Icons)

-- Services
for _, Service in pairs({
	"CoreGui",
	"TweenService",
	"Players",
	"UserInputService",
}) do
	wax.shared[Service] = cloneref(game:GetService(Service))
end

local TweenService = wax.shared.TweenService
local UserInputService = wax.shared.UserInputService

-- Default tween info
local DefaultTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Library state
local Library = {}
Library.Categories = {}
Library.CategoryOrder = {}
Library.ActiveCategory = nil
Library.SettingsVisible = false

-- ============================================================
-- SCREEN GUI
-- ============================================================

local ScreenGui = Interface.CreateScreenGui("NovaUI")

local ScreenDPIScale = Interface.New("UIScale", {
	Scale = 1,
	Parent = ScreenGui,
})

Sonner.Initialize(ScreenGui, Icons)

-- ============================================================
-- MAIN FRAME
-- ============================================================

local MainFrame = Interface.New("Frame", {
	BackgroundColor3 = Theme.Background,
	Size = UDim2.fromOffset(620, 450),
	Position = UDim2.new(0.5, -310, 0.5, -225),
	BorderSizePixel = 0,
	Parent = ScreenGui,
	["UICorner"] = { CornerRadius = UDim.new(0, 8) },
	["UIStroke"] = { Color = Theme.Border, Thickness = 1 },
})

-- ============================================================
-- TITLE BAR
-- ============================================================

local TitleBar = Interface.New("Frame", {
	BackgroundColor3 = Theme.Surface,
	Size = UDim2.new(1, 0, 0, 36),
	BorderSizePixel = 0,
	Parent = MainFrame,
	["UICorner"] = { CornerRadius = UDim.new(0, 8) },
})

Interface.New("Frame", {
	BackgroundColor3 = Theme.Surface,
	Size = UDim2.new(1, 0, 0, 10),
	Position = UDim2.new(0, 0, 1, -10),
	BorderSizePixel = 0,
	Parent = TitleBar,
})

Drag.new(MainFrame, TitleBar, function() return ScreenDPIScale.Scale end)

-- Title icon
local TitleIcon = Interface.New("ImageLabel", {
	BackgroundTransparency = 1,
	Size = UDim2.fromOffset(18, 18),
	Position = UDim2.new(0, 12, 0.5, 0),
	AnchorPoint = Vector2.new(0, 0.5),
	ImageColor3 = Theme.Accent,
	Parent = TitleBar,
})
Icons.ApplyIcon(TitleIcon, "radar")

Interface.New("TextLabel", {
	BackgroundTransparency = 1,
	Size = UDim2.new(0, 200, 1, 0),
	Position = UDim2.new(0, 36, 0, 0),
	Text = "Nova",
	TextColor3 = Theme.Text,
	TextSize = 16,
	Font = Enum.Font.GothamBold,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = TitleBar,
})

Interface.New("TextLabel", {
	BackgroundTransparency = 1,
	Size = UDim2.new(0, 60, 0, 18),
	Position = UDim2.new(0, 72, 0.5, 0),
	AnchorPoint = Vector2.new(0, 0.5),
	Text = "v1.0.0",
	TextColor3 = Theme.TextMuted,
	TextSize = 11,
	Font = Enum.Font.GothamMedium,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = TitleBar,
})

-- Window buttons container
local WindowButtons = Interface.New("Frame", {
	BackgroundTransparency = 1,
	Size = UDim2.new(0, 110, 1, 0),
	Position = UDim2.new(1, -110, 0, 0),
	Parent = TitleBar,
	["UIListLayout"] = {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 4),
	},
	["UIPadding"] = { PaddingRight = UDim.new(0, 8) },
})

local function CreateWindowButton(iconName, callback)
	local btn = Interface.New("TextButton", {
		Text = "",
		BackgroundColor3 = Theme.SurfaceHover,
		BackgroundTransparency = 0.5,
		Size = UDim2.fromOffset(28, 28),
		Parent = WindowButtons,
		AutoButtonColor = false,
		["UICorner"] = { CornerRadius = UDim.new(0, 6) },
	})

	local icon = Interface.New("ImageLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(14, 14),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		ImageColor3 = Theme.TextMuted,
		Parent = btn,
	})
	Icons.ApplyIcon(icon, iconName)

	Helper.HoverEffect(btn, Theme.SurfaceHover, Theme.Surface)
	btn.MouseButton1Click:Connect(callback)
	return btn
end

-- Settings gear button
CreateWindowButton("settings", function()
	Library:ToggleSettings()
end)

-- Separator dot
Interface.New("Frame", {
	BackgroundColor3 = Color3.fromRGB(50, 50, 50),
	Size = UDim2.fromOffset(4, 4),
	Parent = WindowButtons,
	["UICorner"] = { CornerRadius = UDim.new(1, 0) },
})

-- Minimize & Close
CreateWindowButton("minus", function() MainFrame.Visible = not MainFrame.Visible end)
CreateWindowButton("x", function() ScreenGui:Destroy() end)

-- ============================================================
-- LEFT SIDEBAR (CATEGORIES)
-- ============================================================

local Sidebar = Interface.New("Frame", {
	BackgroundColor3 = Theme.Surface,
	Size = UDim2.new(0, 160, 1, -36),
	Position = UDim2.new(0, 0, 0, 36),
	BorderSizePixel = 0,
	Parent = MainFrame,
})

local SidebarScroll = Interface.New("ScrollingFrame", {
	BackgroundTransparency = 1,
	Size = UDim2.fromScale(1, 1),
	BorderSizePixel = 0,
	ScrollBarThickness = 2,
	ScrollBarImageColor3 = Theme.Border,
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	CanvasSize = UDim2.fromScale(0, 0),
	Parent = Sidebar,
	["UIListLayout"] = {
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0, 2),
		SortOrder = Enum.SortOrder.LayoutOrder,
	},
	["UIPadding"] = {
		PaddingLeft = UDim.new(0, 6),
		PaddingRight = UDim.new(0, 6),
		PaddingTop = UDim.new(0, 6),
		PaddingBottom = UDim.new(0, 6),
	},
})

-- ============================================================
-- SIDEBAR DIVIDER (RESIZABLE)
-- ============================================================

local SidebarDivider = Interface.New("Frame", {
	BackgroundColor3 = Color3.fromRGB(25, 25, 25),
	Size = UDim2.new(0, 2, 1, -36),
	Position = UDim2.new(0, 160, 0, 36),
	ZIndex = 5,
	Parent = MainFrame,
})

local DividerHandle = Interface.New("TextButton", {
	Text = "",
	BackgroundTransparency = 1,
	Size = UDim2.new(0, 8, 1, 0),
	Position = UDim2.new(0.5, 0, 0, 0),
	AnchorPoint = Vector2.new(0.5, 0),
	AutoButtonColor = false,
	ZIndex = 6,
	Parent = SidebarDivider,
})

local isDraggingDivider = false
local dividerDragStart = nil
local dividerStartWidth = 160

DividerHandle.MouseEnter:Connect(function() SidebarDivider.BackgroundColor3 = Color3.fromRGB(50, 50, 50) end)
DividerHandle.MouseLeave:Connect(function() if not isDraggingDivider then SidebarDivider.BackgroundColor3 = Color3.fromRGB(25, 25, 25) end end)
DividerHandle.MouseButton1Down:Connect(function()
	isDraggingDivider = true
	dividerDragStart = UserInputService:GetMouseLocation().X
	dividerStartWidth = Sidebar.Size.X.Offset
end)

-- Forward declare ContentWrapper for divider logic
local ContentWrapper

UserInputService.InputChanged:Connect(function(input)
	if isDraggingDivider and input.UserInputType == Enum.UserInputType.MouseMovement then
		local scale = ScreenDPIScale.Scale
		local delta = (input.Position.X - dividerDragStart) / scale
		local newWidth = math.clamp(dividerStartWidth + delta, 120, math.floor(MainFrame.AbsoluteSize.X / 2))
		Sidebar.Size = UDim2.new(0, newWidth, 1, -36)
		SidebarDivider.Position = UDim2.new(0, newWidth, 0, 36)
		if ContentWrapper then
			ContentWrapper.Size = UDim2.new(1, -(newWidth + 2), 1, -36)
		end
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		isDraggingDivider = false
		SidebarDivider.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	end
end)

-- ============================================================
-- CONTENT AREA (RIGHT SIDE)
-- ============================================================

ContentWrapper = Interface.New("Frame", {
	AnchorPoint = Vector2.one,
	BackgroundTransparency = 1,
	Position = UDim2.fromScale(1, 1),
	Size = UDim2.new(1, -162, 1, -36),
	Parent = MainFrame,
	["UIPadding"] = {
		PaddingLeft = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 8),
		PaddingTop = UDim.new(0, 8),
		PaddingBottom = UDim.new(0, 8),
	},
})

-- ============================================================
-- SETTINGS PANEL
-- ============================================================

local SettingsFrame = Interface.New("Frame", {
	BackgroundTransparency = 1,
	Size = UDim2.fromScale(1, 1),
	Visible = false,
	Parent = ContentWrapper,
	["UIPadding"] = { PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4), PaddingTop = UDim.new(0, 4) },
})

local SettingsScroll = Interface.New("ScrollingFrame", {
	BackgroundTransparency = 1,
	Size = UDim2.fromScale(1, 1),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	CanvasSize = UDim2.fromScale(0, 0),
	ScrollBarThickness = 3,
	ScrollBarImageColor3 = Theme.Border,
	BorderSizePixel = 0,
	Parent = SettingsFrame,
	["UIListLayout"] = { FillDirection = Enum.FillDirection.Vertical, Padding = UDim.new(0, 8) },
})

local function CreateSettingsSection(title)
	local wrapper = Interface.New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = SettingsScroll,
		["UIListLayout"] = { FillDirection = Enum.FillDirection.Vertical, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4) },
	})

	Interface.New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 20),
		LayoutOrder = 0,
		Text = string.upper(title),
		TextColor3 = Theme.TextMuted,
		TextSize = 11,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = wrapper,
	})

	local section = Interface.New("Frame", {
		BackgroundColor3 = Theme.Surface,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 1,
		Parent = wrapper,
		["UICorner"] = { CornerRadius = UDim.new(0, 8) },
		["UIStroke"] = { Color = Theme.Border, Thickness = 1, Transparency = 0.5 },
		["UIListLayout"] = { FillDirection = Enum.FillDirection.Vertical, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 0) },
		["UIPadding"] = { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 2) },
	})

	return section
end

local settingsRowOrder = 0
local function CreateSettingsRow(section)
	settingsRowOrder += 1
	return Interface.New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 36),
		LayoutOrder = settingsRowOrder,
		Parent = section,
	})
end

local function CreateSettingsToggle(section, text, default, callback)
	local value = default or false
	local row = CreateSettingsRow(section)

	Interface.New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -52, 1, 0),
		Text = text,
		TextColor3 = Theme.Text,
		TextSize = 13,
		Font = Enum.Font.GothamMedium,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = row,
	})

	local toggleTrack = Interface.New("TextButton", {
		Text = "",
		BackgroundColor3 = value and Theme.Accent or Theme.SurfaceHover,
		Size = UDim2.fromOffset(40, 22),
		Position = UDim2.new(1, -44, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		AutoButtonColor = false,
		Parent = row,
		["UICorner"] = { CornerRadius = UDim.new(1, 0) },
	})

	local toggleKnob = Interface.New("Frame", {
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Size = UDim2.fromOffset(16, 16),
		Position = value and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		Parent = toggleTrack,
		["UICorner"] = { CornerRadius = UDim.new(1, 0) },
	})

	toggleTrack.MouseButton1Click:Connect(function()
		value = not value
		TweenService:Create(toggleTrack, DefaultTweenInfo, { BackgroundColor3 = value and Theme.Accent or Theme.SurfaceHover }):Play()
		TweenService:Create(toggleKnob, DefaultTweenInfo, { Position = value and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0) }):Play()
		if callback then callback(value) end
	end)
end

local function CreateSettingsDropdown(section, text, values, default, callback)
	local row = CreateSettingsRow(section)
	local currentIndex = table.find(values, default) or 1

	Interface.New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0.55, 0, 1, 0),
		Text = text,
		TextColor3 = Theme.Text,
		TextSize = 13,
		Font = Enum.Font.GothamMedium,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row,
	})

	local valueLabel = Interface.New("TextButton", {
		Text = default,
		TextColor3 = Theme.TextMuted,
		TextSize = 12,
		Font = Enum.Font.GothamMedium,
		BackgroundColor3 = Theme.SurfaceHover,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 100, 0, 26),
		Position = UDim2.new(1, 0, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		AutoButtonColor = false,
		Parent = row,
		["UICorner"] = { CornerRadius = UDim.new(0, 6) },
	})

	valueLabel.MouseButton1Click:Connect(function()
		currentIndex = (currentIndex % #values) + 1
		local newValue = values[currentIndex]
		valueLabel.Text = newValue
		if callback then callback(newValue) end
	end)
end

-- Build settings sections
local GeneralSection = CreateSettingsSection("General")
CreateSettingsDropdown(GeneralSection, "DPI Scale", { "50%", "75%", "100%", "125%", "150%" }, "100%", function(value)
	local scaleNumber = tonumber(string.match(value, "%d+"))
	ScreenDPIScale.Scale = (scaleNumber or 100) / 100
end)

-- Unload button
local DangerSection = CreateSettingsSection("Danger Zone")
local unloadRow = CreateSettingsRow(DangerSection)

local unloadBtn = Interface.New("TextButton", {
	Text = "",
	BackgroundTransparency = 1,
	Size = UDim2.new(1, 0, 1, -8),
	Position = UDim2.new(0, 0, 0, 4),
	AutoButtonColor = false,
	ClipsDescendants = true,
	Parent = unloadRow,
})

local unloadIcon = Interface.New("ImageLabel", {
	BackgroundTransparency = 1,
	Size = UDim2.fromOffset(14, 14),
	Position = UDim2.new(0, 10, 0.5, 0),
	AnchorPoint = Vector2.new(0, 0.5),
	ImageColor3 = Theme.Error,
	Parent = unloadBtn,
})
Icons.ApplyIcon(unloadIcon, "power")

Interface.New("TextLabel", {
	BackgroundTransparency = 1,
	Size = UDim2.new(1, -34, 1, 0),
	Position = UDim2.new(0, 30, 0, 0),
	Text = "Unload Nova",
	TextColor3 = Theme.Error,
	TextSize = 13,
	Font = Enum.Font.GothamBold,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = unloadBtn,
})

unloadBtn.MouseEnter:Connect(function()
	unloadBtn.BackgroundTransparency = 0.85
	unloadBtn.BackgroundColor3 = Theme.Error
end)
unloadBtn.MouseLeave:Connect(function()
	unloadBtn.BackgroundTransparency = 1
end)
unloadBtn.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
end)

local AboutSection = CreateSettingsSection("About")
Interface.New("TextLabel", {
	BackgroundTransparency = 1,
	Size = UDim2.new(1, 0, 0, 24),
	Text = "<b>Nova UI</b> — GUI Library",
	TextColor3 = Theme.TextMuted,
	TextSize = 12,
	Font = Enum.Font.GothamMedium,
	TextXAlignment = Enum.TextXAlignment.Left,
	RichText = true,
	Parent = AboutSection,
})
Interface.New("TextLabel", {
	BackgroundTransparency = 1,
	Size = UDim2.new(1, 0, 0, 20),
	Text = "Creator: <b>04xSkater</b>",
	TextColor3 = Theme.TextMuted,
	TextSize = 12,
	Font = Enum.Font.GothamMedium,
	TextXAlignment = Enum.TextXAlignment.Left,
	RichText = true,
	Parent = AboutSection,
})

-- ============================================================
-- OPTION ELEMENT BUILDERS
-- ============================================================

local optionOrder = 0
local function NextOrder()
	optionOrder += 1
	return optionOrder
end

local function CreateToggle(parent, text, default, callback)
	local value = default or false
	local container = Interface.New("Frame", {
		BackgroundColor3 = Color3.fromRGB(25, 25, 25),
		Size = UDim2.new(1, 0, 0, 38),
		LayoutOrder = NextOrder(),
		Parent = parent,
		["UICorner"] = { CornerRadius = UDim.new(0, 6) },
		["UIPadding"] = { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) },
	})

	Interface.New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -52, 1, 0),
		Text = text,
		TextColor3 = Theme.Text,
		TextSize = 13,
		Font = Enum.Font.GothamMedium,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = container,
	})

	local toggleTrack = Interface.New("TextButton", {
		Text = "",
		BackgroundColor3 = value and Theme.Accent or Theme.SurfaceHover,
		Size = UDim2.fromOffset(40, 22),
		Position = UDim2.new(1, -44, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		AutoButtonColor = false,
		Parent = container,
		["UICorner"] = { CornerRadius = UDim.new(1, 0) },
	})

	local toggleKnob = Interface.New("Frame", {
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Size = UDim2.fromOffset(16, 16),
		Position = value and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		Parent = toggleTrack,
		["UICorner"] = { CornerRadius = UDim.new(1, 0) },
	})

	local element = {
		Type = "Toggle",
		Value = value,
		Set = function(self, newValue)
			self.Value = newValue
			TweenService:Create(toggleTrack, DefaultTweenInfo, { BackgroundColor3 = newValue and Theme.Accent or Theme.SurfaceHover }):Play()
			TweenService:Create(toggleKnob, DefaultTweenInfo, { Position = newValue and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0) }):Play()
		end,
	}

	toggleTrack.MouseButton1Click:Connect(function()
		element.Value = not element.Value
		element:Set(element.Value)
		if callback then callback(element.Value) end
	end)

	return element
end

local function CreateSlider(parent, text, default, min, max, callback)
	local value = math.clamp(default or min, min, max)

	local container = Interface.New("Frame", {
		BackgroundColor3 = Color3.fromRGB(25, 25, 25),
		Size = UDim2.new(1, 0, 0, 50),
		LayoutOrder = NextOrder(),
		Parent = parent,
		["UICorner"] = { CornerRadius = UDim.new(0, 6) },
		["UIPadding"] = { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) },
	})

	Interface.New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -60, 0, 20),
		Position = UDim2.new(0, 0, 0, 6),
		Text = text,
		TextColor3 = Theme.Text,
		TextSize = 13,
		Font = Enum.Font.GothamMedium,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = container,
	})

	local valueLabel = Interface.New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 50, 0, 20),
		Position = UDim2.new(1, -50, 0, 6),
		Text = tostring(math.floor(value)),
		TextColor3 = Theme.Accent,
		TextSize = 13,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = container,
	})

	local sliderBg = Interface.New("Frame", {
		BackgroundColor3 = Theme.SurfaceHover,
		Size = UDim2.new(1, 0, 0, 6),
		Position = UDim2.new(0, 0, 0, 34),
		Parent = container,
		["UICorner"] = { CornerRadius = UDim.new(1, 0) },
	})

	local sliderFill = Interface.New("Frame", {
		BackgroundColor3 = Theme.Accent,
		Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
		Parent = sliderBg,
		["UICorner"] = { CornerRadius = UDim.new(1, 0) },
	})

	local sliderKnob = Interface.New("Frame", {
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Size = UDim2.fromOffset(12, 12),
		Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		ZIndex = 2,
		Parent = sliderBg,
		["UICorner"] = { CornerRadius = UDim.new(1, 0) },
	})

	local isDragging = false

	local function UpdateSlider(inputX)
		local relativeX = (inputX - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X
		relativeX = math.clamp(relativeX, 0, 1)
		value = math.floor(min + (max - min) * relativeX)
		valueLabel.Text = tostring(value)
		sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
		sliderKnob.Position = UDim2.new(relativeX, 0, 0.5, 0)
		if callback then callback(value) end
	end

	sliderBg.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			isDragging = true
			UpdateSlider(input.Position.X)
		end
	end)

	sliderKnob.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			isDragging = true
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			UpdateSlider(input.Position.X)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			isDragging = false
		end
	end)

	return {
		Type = "Slider",
		Value = value,
		Set = function(self, newValue)
			value = math.clamp(math.floor(newValue), min, max)
			self.Value = value
			local pct = (value - min) / (max - min)
			valueLabel.Text = tostring(value)
			sliderFill.Size = UDim2.new(pct, 0, 1, 0)
			sliderKnob.Position = UDim2.new(pct, 0, 0.5, 0)
		end,
	}
end

local function CreateDropdown(parent, text, options, default, callback)
	local currentIndex = table.find(options, default) or 1
	local value = options[currentIndex]

	local container = Interface.New("Frame", {
		BackgroundColor3 = Color3.fromRGB(25, 25, 25),
		Size = UDim2.new(1, 0, 0, 38),
		LayoutOrder = NextOrder(),
		Parent = parent,
		["UICorner"] = { CornerRadius = UDim.new(0, 6) },
		["UIPadding"] = { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) },
	})

	Interface.New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -120, 1, 0),
		Text = text,
		TextColor3 = Theme.Text,
		TextSize = 13,
		Font = Enum.Font.GothamMedium,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = container,
	})

	local dropdownBtn = Interface.New("TextButton", {
		Text = value,
		TextColor3 = Theme.TextMuted,
		TextSize = 12,
		Font = Enum.Font.GothamMedium,
		BackgroundColor3 = Theme.SurfaceHover,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 110, 0, 26),
		Position = UDim2.new(1, -110, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		AutoButtonColor = false,
		Parent = container,
		["UICorner"] = { CornerRadius = UDim.new(0, 6) },
	})

	local arrowIcon = Interface.New("ImageLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(10, 10),
		Position = UDim2.new(1, -14, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		ImageColor3 = Theme.TextMuted,
		Parent = dropdownBtn,
	})
	Icons.ApplyIcon(arrowIcon, "chevron-down")

	dropdownBtn.MouseButton1Click:Connect(function()
		currentIndex = (currentIndex % #options) + 1
		value = options[currentIndex]
		dropdownBtn.Text = value
		if callback then callback(value) end
	end)

	Helper.HoverEffect(dropdownBtn, Theme.Border, Theme.SurfaceHover)

	return {
		Type = "Dropdown",
		Value = value,
		Set = function(self, newValue)
			local idx = table.find(options, newValue)
			if idx then
				currentIndex = idx
				value = newValue
				self.Value = value
				dropdownBtn.Text = value
			end
		end,
	}
end

local function CreateButton(parent, text, callback)
	local container = Interface.New("TextButton", {
		Text = "",
		BackgroundColor3 = Color3.fromRGB(25, 25, 25),
		Size = UDim2.new(1, 0, 0, 38),
		LayoutOrder = NextOrder(),
		AutoButtonColor = false,
		ClipsDescendants = true,
		Parent = parent,
		["UICorner"] = { CornerRadius = UDim.new(0, 6) },
		["UIPadding"] = { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) },
	})

	local btnIcon = Interface.New("ImageLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(14, 14),
		Position = UDim2.new(0, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		ImageColor3 = Theme.Accent,
		Parent = container,
	})
	Icons.ApplyIcon(btnIcon, "play")

	Interface.New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -24, 1, 0),
		Position = UDim2.new(0, 20, 0, 0),
		Text = text,
		TextColor3 = Theme.Text,
		TextSize = 13,
		Font = Enum.Font.GothamMedium,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = container,
	})

	Helper.HoverEffect(container, Color3.fromRGB(30, 30, 30), Color3.fromRGB(25, 25, 25))

	container.MouseButton1Click:Connect(function()
		Helper.Ripple(container)
		if callback then callback() end
	end)

	return { Type = "Button" }
end

local function CreateKeybind(parent, text, default, callback)
	local currentKey = default or Enum.KeyCode.Unknown
	local isListening = false

	local container = Interface.New("Frame", {
		BackgroundColor3 = Color3.fromRGB(25, 25, 25),
		Size = UDim2.new(1, 0, 0, 38),
		LayoutOrder = NextOrder(),
		Parent = parent,
		["UICorner"] = { CornerRadius = UDim.new(0, 6) },
		["UIPadding"] = { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) },
	})

	Interface.New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -90, 1, 0),
		Text = text,
		TextColor3 = Theme.Text,
		TextSize = 13,
		Font = Enum.Font.GothamMedium,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = container,
	})

	local keyBtn = Interface.New("TextButton", {
		Text = currentKey.Name,
		TextColor3 = Theme.TextMuted,
		TextSize = 11,
		Font = Enum.Font.GothamBold,
		BackgroundColor3 = Theme.SurfaceHover,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 80, 0, 24),
		Position = UDim2.new(1, -80, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		AutoButtonColor = false,
		Parent = container,
		["UICorner"] = { CornerRadius = UDim.new(0, 4) },
	})

	keyBtn.MouseButton1Click:Connect(function()
		isListening = true
		keyBtn.Text = "..."
		keyBtn.TextColor3 = Theme.Accent
	end)

	UserInputService.InputBegan:Connect(function(input)
		if not isListening then return end
		if input.UserInputType == Enum.UserInputType.Keyboard then
			isListening = false
			currentKey = input.KeyCode
			keyBtn.Text = currentKey.Name
			keyBtn.TextColor3 = Theme.TextMuted
			if callback then callback(currentKey) end
		end
	end)

	return {
		Type = "Keybind",
		Value = currentKey,
		Set = function(self, key)
			currentKey = key
			self.Value = key
			keyBtn.Text = key.Name
		end,
	}
end

local function CreateLabel(parent, text)
	local label = Interface.New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 24),
		LayoutOrder = NextOrder(),
		Text = text,
		TextColor3 = Theme.TextMuted,
		TextSize = 12,
		Font = Enum.Font.GothamMedium,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = parent,
		["UIPadding"] = { PaddingLeft = UDim.new(0, 4) },
	})

	return {
		Type = "Label",
		Set = function(_, newText) label.Text = newText end,
	}
end

local function CreateSeparator(parent)
	Interface.New("Frame", {
		BackgroundColor3 = Theme.Border,
		Size = UDim2.new(1, 0, 0, 1),
		LayoutOrder = NextOrder(),
		Parent = parent,
	})
end

local function CreateTextInput(parent, text, placeholder, callback)
	local container = Interface.New("Frame", {
		BackgroundColor3 = Color3.fromRGB(25, 25, 25),
		Size = UDim2.new(1, 0, 0, 38),
		LayoutOrder = NextOrder(),
		Parent = parent,
		["UICorner"] = { CornerRadius = UDim.new(0, 6) },
		["UIPadding"] = { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) },
	})

	Interface.New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0.45, 0, 1, 0),
		Text = text,
		TextColor3 = Theme.Text,
		TextSize = 13,
		Font = Enum.Font.GothamMedium,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = container,
	})

	local inputBox = Interface.New("TextBox", {
		BackgroundColor3 = Theme.SurfaceHover,
		Size = UDim2.new(0.5, 0, 0, 26),
		Position = UDim2.new(1, 0, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		Text = "",
		PlaceholderText = placeholder or "...",
		PlaceholderColor3 = Color3.fromRGB(80, 80, 80),
		TextColor3 = Theme.Text,
		TextSize = 12,
		Font = Enum.Font.GothamMedium,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		Parent = container,
		["UICorner"] = { CornerRadius = UDim.new(0, 6) },
		["UIPadding"] = { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) },
	})

	inputBox.FocusLost:Connect(function(enterPressed)
		if callback then callback(inputBox.Text, enterPressed) end
	end)

	return {
		Type = "TextInput",
		Value = "",
		Set = function(self, newText) inputBox.Text = newText; self.Value = newText end,
	}
end

-- ============================================================
-- CATEGORY CLASS
-- ============================================================

local Category = {}
Category.__index = Category

function Category.new(name, iconName, contentParent)
	local self = setmetatable({}, Category)
	self.Name = name
	self.IconName = iconName
	self.ContentFrame = Interface.New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Visible = false,
		Parent = contentParent,
	})

	local categoryScroll = Interface.New("ScrollingFrame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.fromScale(0, 0),
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Theme.Border,
		BorderSizePixel = 0,
		Parent = self.ContentFrame,
		["UIListLayout"] = {
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, 4),
			SortOrder = Enum.SortOrder.LayoutOrder,
		},
	})

	self.Scroll = categoryScroll
	self.Elements = {}
	return self
end

function Category:AddToggle(text, default, callback)
	local elem = CreateToggle(self.Scroll, text, default, callback)
	table.insert(self.Elements, elem)
	return elem
end

function Category:AddSlider(text, default, min, max, callback)
	local elem = CreateSlider(self.Scroll, text, default, min, max, callback)
	table.insert(self.Elements, elem)
	return elem
end

function Category:AddDropdown(text, options, default, callback)
	local elem = CreateDropdown(self.Scroll, text, options, default, callback)
	table.insert(self.Elements, elem)
	return elem
end

function Category:AddButton(text, callback)
	local elem = CreateButton(self.Scroll, text, callback)
	table.insert(self.Elements, elem)
	return elem
end

function Category:AddKeybind(text, default, callback)
	local elem = CreateKeybind(self.Scroll, text, default, callback)
	table.insert(self.Elements, elem)
	return elem
end

function Category:AddLabel(text)
	local elem = CreateLabel(self.Scroll, text)
	table.insert(self.Elements, elem)
	return elem
end

function Category:AddSeparator()
	CreateSeparator(self.Scroll)
end

function Category:AddTextInput(text, placeholder, callback)
	local elem = CreateTextInput(self.Scroll, text, placeholder, callback)
	table.insert(self.Elements, elem)
	return elem
end

-- ============================================================
-- LIBRARY API
-- ============================================================

function Library:AddCategory(name, iconName)
	local category = Category.new(name, iconName or "folder", ContentWrapper)
	local order = #self.CategoryOrder + 1

	-- Create sidebar button
	local btn = Interface.New("TextButton", {
		Text = "",
		BackgroundColor3 = Theme.Surface,
		Size = UDim2.new(1, 0, 0, 36),
		LayoutOrder = order,
		AutoButtonColor = false,
		Parent = SidebarScroll,
		["UICorner"] = { CornerRadius = UDim.new(0, 6) },
	})

	local btnIcon = Interface.New("ImageLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(14, 14),
		Position = UDim2.new(0, 10, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		ImageColor3 = Theme.TextMuted,
		Parent = btn,
	})
	Icons.ApplyIcon(btnIcon, iconName or "folder")

	local btnLabel = Interface.New("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -36, 1, 0),
		Position = UDim2.new(0, 30, 0, 0),
		Text = name,
		TextColor3 = Theme.TextMuted,
		TextSize = 13,
		Font = Enum.Font.GothamMedium,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = btn,
	})

	Helper.HoverEffect(btn, Theme.SurfaceHover, Theme.Surface)

	category.SidebarButton = btn
	category.SidebarIcon = btnIcon
	category.SidebarLabel = btnLabel

	self.Categories[name] = category
	table.insert(self.CategoryOrder, name)

	btn.MouseButton1Click:Connect(function()
		self:SelectCategory(name)
	end)

	-- Auto-select first category
	if #self.CategoryOrder == 1 then
		self:SelectCategory(name)
	end

	return category
end

function Library:SelectCategory(name)
	self.ActiveCategory = name
	self.SettingsVisible = false

	-- Update sidebar highlights
	for catName, cat in pairs(self.Categories) do
		local isActive = (catName == name)
		cat.SidebarButton.BackgroundColor3 = isActive and Theme.Accent or Theme.Surface
		cat.SidebarLabel.TextColor3 = isActive and Color3.fromRGB(255, 255, 255) or Theme.TextMuted
		cat.SidebarIcon.ImageColor3 = isActive and Color3.fromRGB(255, 255, 255) or Theme.TextMuted
		cat.ContentFrame.Visible = isActive
	end

	SettingsFrame.Visible = false
end

function Library:ToggleSettings()
	self.SettingsVisible = not self.SettingsVisible

	if self.SettingsVisible then
		-- Deselect all categories
		for _, cat in pairs(self.Categories) do
			cat.SidebarButton.BackgroundColor3 = Theme.Surface
			cat.SidebarLabel.TextColor3 = Theme.TextMuted
			cat.SidebarIcon.ImageColor3 = Theme.TextMuted
			cat.ContentFrame.Visible = false
		end
		SettingsFrame.Visible = true
	else
		-- Re-select previous category
		if self.ActiveCategory and self.Categories[self.ActiveCategory] then
			self:SelectCategory(self.ActiveCategory)
		end
	end
end

function Library:Notify(text, notifType)
	if notifType == "success" then
		Sonner.success(text)
	elseif notifType == "error" then
		Sonner.error(text)
	elseif notifType == "warning" then
		Sonner.warning(text)
	else
		Sonner.info(text)
	end
end

function Library:Destroy()
	ScreenGui:Destroy()
end

function Library:SetVisible(visible)
	MainFrame.Visible = visible
end

function Library:Toggle()
	MainFrame.Visible = not MainFrame.Visible
end

-- Toggle keybind (RightShift)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.RightShift then
		Library:Toggle()
	end
end)

-- ============================================================
-- EXAMPLE USAGE (remove this block when using as a library)
-- ============================================================

local Main = Library:AddCategory("Main", "house")
Main:AddToggle("Feature A", false, function(v)
	Library:Notify(`Feature A: {v and "ON" or "OFF"}`)
end)
Main:AddToggle("Feature B", true)
Main:AddSlider("Speed", 16, 1, 100)
Main:AddDropdown("Mode", { "Normal", "Rage", "Legit" }, "Normal", function(v)
	Library:Notify(`Mode: {v}`)
end)
Main:AddSeparator()
Main:AddButton("Execute Script", function()
	Library:Notify("Script executed!", "success")
end)
Main:AddKeybind("Toggle Key", Enum.KeyCode.RightControl, function(key)
	Library:Notify(`Keybind set: {key.Name}`)
end)
Main:AddTextInput("Target", "Player name...", function(text, enter)
	if enter then Library:Notify(`Target: {text}`) end
end)

local Visuals = Library:AddCategory("Visuals", "eye")
Visuals:AddToggle("ESP", false)
Visuals:AddToggle("Chams", false)
Visuals:AddDropdown("ESP Type", { "Box", "Corner", "3D" }, "Box")
Visuals:AddSlider("Transparency", 50, 0, 100)
Visuals:AddSeparator()
Visuals:AddLabel("Customize your ESP settings above.")

local Misc = Library:AddCategory("Misc", "wrench")
Misc:AddToggle("Anti-AFK", true)
Misc:AddButton("Rejoin Server", function()
	Library:Notify("Rejoining...", "warning")
end)
Misc:AddButton("Copy Game Link", function()
	Library:Notify("Copied!", "success")
end)

Library:Notify("Nova UI loaded!")

return Library
