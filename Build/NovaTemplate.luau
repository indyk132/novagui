--[[
    Nova Template
    A reusable UI template based on Nova's interface design.
    
    This script is NOT intended to be modified.
    Powered by Wax Bundler
--]]

-- ++++++++ WAX BUNDLED DATA BELOW ++++++++ --

-- Will be used later for getting flattened globals
local ImportGlobals

-- Holds direct closure data (defining this before the DOM tree for line debugging etc)
local ClosureBindings = {
    [10] = function()local wax,script,require=ImportGlobals(10)local ImportGlobals return (function(...)--[[
	Theme Module - Template (Based on Nova)
	Centralized color definitions for consistent UI theming.
	
	Usage:
		local Theme = require(path.to.Theme)
		frame.BackgroundColor3 = Theme.Background
]]

local Theme = {
	-- Base colors
	Background = Color3.fromRGB(15, 15, 15),
	Surface = Color3.fromRGB(20, 20, 20),
	SurfaceHover = Color3.fromRGB(28, 28, 28),
	
	-- Border colors
	Border = Color3.fromRGB(40, 40, 40),
	BorderLight = Color3.fromRGB(55, 55, 55),
	
	-- Text colors
	Text = Color3.fromRGB(220, 220, 220),
	TextMuted = Color3.fromRGB(140, 140, 140),
	
	-- Accent colors
	Accent = Color3.fromRGB(88, 101, 242),
	AccentHover = Color3.fromRGB(98, 111, 252),
	
	-- Status colors
	Success = Color3.fromRGB(63, 185, 80),
	Warning = Color3.fromRGB(210, 153, 34),
	Error = Color3.fromRGB(248, 81, 73),
	Info = Color3.fromRGB(88, 166, 255),
	
	-- Direction colors (from Nova's Incoming/Outgoing)
	Primary = Color3.fromRGB(63, 185, 80),
	Secondary = Color3.fromRGB(247, 129, 102),
}

-- Utility function to lighten a color
function Theme.Lighten(color: Color3, amount: number): Color3
	return Color3.new(
		math.min(color.R + amount, 1),
		math.min(color.G + amount, 1),
		math.min(color.B + amount, 1)
	)
end

-- Utility function to darken a color
function Theme.Darken(color: Color3, amount: number): Color3
	return Color3.new(
		math.max(color.R - amount, 0),
		math.max(color.G - amount, 0),
		math.max(color.B - amount, 0)
	)
end

return Theme

end)() end,
    [2] = function()local wax,script,require=ImportGlobals(2)local ImportGlobals return (function(...)--[[
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
	BackgroundColor3 = Color3.fromRGB(60, 20, 20),
	Size = UDim2.new(1, 0, 1, -8),
	Position = UDim2.new(0, 0, 0, 4),
	AutoButtonColor = false,
	ClipsDescendants = true,
	Parent = unloadRow,
	["UICorner"] = { CornerRadius = UDim.new(0, 6) },
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

Helper.HoverEffect(unloadBtn, Color3.fromRGB(80, 25, 25), Color3.fromRGB(60, 20, 20))
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

end)() end,
    [6] = function()local wax,script,require=ImportGlobals(6)local ImportGlobals return (function(...)--[[
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

end)() end,
    [9] = function()local wax,script,require=ImportGlobals(9)local ImportGlobals return (function(...)--[[
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

end)() end,
    [8] = function()local wax,script,require=ImportGlobals(8)local ImportGlobals return (function(...)--[[
	Resize Module - Template
	Enables resize functionality on UI frames.
	
	Usage:
		local Resize = require(path.to.Resize)
		
		Resize.new({
			MainFrame = mainFrame,
			MinimumSize = Vector2.new(300, 200),
			MaximumSize = UDim2.fromOffset(800, 600),
		})
]]

local Resize = {}
Resize.__index = Resize

local UserInputService = game:GetService("UserInputService")

local HANDLE_SIZE = 6
local CORNER_HANDLE_SIZE = 20

export type ResizeOptions = {
	MainFrame: Frame,
	MinimumSize: Vector2? | UDim2?,
	MaximumSize: UDim2?,
	HandleSize: number?,
	CornerHandleSize: number?,
	Mirrored: boolean?,
}

export type ResizeObject = {
	MainFrame: Frame,
	ResizeHandle: TextButton,
	Enabled: boolean,
	SetEnabled: (self: ResizeObject, enabled: boolean) -> (),
	Destroy: (self: ResizeObject) -> (),
}

--[[
	Create a new resizable frame
	@param options Configuration options
	@return ResizeObject
]]
function Resize.new(options: ResizeOptions): ResizeObject
	local MainFrame = options.MainFrame
	local HandleSize = options.HandleSize or HANDLE_SIZE
	local CornerHandleSize = options.CornerHandleSize or CORNER_HANDLE_SIZE
	local Mirrored = options.Mirrored or false

	local MinimumSize
	if typeof(options.MinimumSize) == "Vector2" then
		MinimumSize = UDim2.fromOffset(options.MinimumSize.X, options.MinimumSize.Y)
	elseif typeof(options.MinimumSize) == "UDim2" then
		MinimumSize = options.MinimumSize
	else
		MinimumSize = UDim2.fromOffset(200, 150)
	end

	local MaximumSize = options.MaximumSize or UDim2.fromOffset(9999, 9999)

	local self = setmetatable({}, Resize)
	self.MainFrame = MainFrame
	self.Enabled = true

	-- Bottom-right corner resize handle
	local ResizeHandle = Instance.new("TextButton")
	ResizeHandle.Text = ""
	ResizeHandle.BackgroundTransparency = 1
	ResizeHandle.Size = UDim2.fromOffset(CornerHandleSize, CornerHandleSize)
	ResizeHandle.Position = UDim2.new(1, -CornerHandleSize, 1, -CornerHandleSize)
	ResizeHandle.ZIndex = 100
	ResizeHandle.Parent = MainFrame

	self.ResizeHandle = ResizeHandle

	local dragging = false
	local dragStart = nil
	local startSize = nil
	local connections = {}

	table.insert(connections, ResizeHandle.InputBegan:Connect(function(input)
		if not self.Enabled then return end
		
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startSize = MainFrame.Size

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end))

	table.insert(connections, UserInputService.InputChanged:Connect(function(input)
		if not self.Enabled then return end
		
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			local newWidth = math.clamp(
				startSize.X.Offset + (Mirrored and -delta.X or delta.X),
				MinimumSize.X.Offset,
				MaximumSize.X.Offset
			)
			local newHeight = math.clamp(
				startSize.Y.Offset + (Mirrored and -delta.Y or delta.Y),
				MinimumSize.Y.Offset,
				MaximumSize.Y.Offset
			)

			MainFrame.Size = UDim2.fromOffset(newWidth, newHeight)
		end
	end))

	function self:SetEnabled(enabled: boolean)
		self.Enabled = enabled
		ResizeHandle.Visible = enabled
		if not enabled then
			dragging = false
		end
	end

	function self:Destroy()
		for _, connection in ipairs(connections) do
			connection:Disconnect()
		end
		connections = {}
		ResizeHandle:Destroy()
	end

	return self
end

return Resize

end)() end,
    [7] = function()local wax,script,require=ImportGlobals(7)local ImportGlobals return (function(...)--[[
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

end)() end,
    [5] = function()local wax,script,require=ImportGlobals(5)local ImportGlobals return (function(...)--[[
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

end)() end,
    [4] = function()local wax,script,require=ImportGlobals(4)local ImportGlobals return (function(...)--[[
	Drag Module - Template
	Enables drag functionality on UI frames.
	Supports UIScale by dividing delta by a scale factor.
	
	Usage:
		local Drag = require(path.to.Drag)
		
		-- Basic usage
		Drag.new(mainFrame, titleBar)
		
		-- With DPI/UIScale support
		Drag.new(mainFrame, titleBar, function()
			return uiScale.Scale
		end)
]]

local Drag = {}
Drag.__index = Drag

local UserInputService = game:GetService("UserInputService")

export type DragObject = {
	Frame: Frame,
	Handle: Frame,
	Enabled: boolean,
	SetEnabled: (self: DragObject, enabled: boolean) -> (),
	Destroy: (self: DragObject) -> (),
}

--[[
	Create a new draggable frame
	@param frame The main frame to move
	@param handle The frame to use as drag handle (defaults to frame itself)
	@param getScale Optional function returning the current UI scale
	@return DragObject
]]
function Drag.new(frame: Frame, handle: Frame?, getScale: (() -> number)?): DragObject
	handle = handle or frame
	getScale = getScale or function() return 1 end

	local self = setmetatable({}, Drag)
	self.Frame = frame
	self.Handle = handle
	self.Enabled = true

	local dragging = false
	local dragStart = nil
	local startPos = nil
	local connections = {}

	table.insert(connections, handle.InputBegan:Connect(function(input)
		if not self.Enabled then return end
		
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end))

	table.insert(connections, UserInputService.InputChanged:Connect(function(input)
		if not self.Enabled then return end
		
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local scale = getScale()
			local delta = input.Position - dragStart
			local newPosition = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X / scale,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y / scale
			)
			frame.Position = newPosition
		end
	end))

	function self:SetEnabled(enabled: boolean)
		self.Enabled = enabled
		if not enabled then
			dragging = false
		end
	end

	function self:Destroy()
		for _, connection in ipairs(connections) do
			connection:Disconnect()
		end
		connections = {}
	end

	return self
end

return Drag

end)() end
} -- [RefId] = Closure

-- Holds the actual DOM data
local ObjectTree = {
    {
        1,
        1,
        {
            "NovaTemplate"
        },
        {
            {
                2,
                4,
                {
                    "Src"
                },
                {
                    {
                        3,
                        1,
                        {
                            "UI"
                        },
                        {
                            {
                                4,
                                2,
                                {
                                    "Drag"
                                }
                            },
                            {
                                10,
                                2,
                                {
                                    "Theme"
                                }
                            },
                            {
                                8,
                                2,
                                {
                                    "Resize"
                                }
                            },
                            {
                                5,
                                2,
                                {
                                    "Helper"
                                }
                            },
                            {
                                7,
                                2,
                                {
                                    "Interface"
                                }
                            },
                            {
                                9,
                                2,
                                {
                                    "Sonner"
                                }
                            },
                            {
                                6,
                                2,
                                {
                                    "Icons"
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

-- Line offsets for debugging (only included when minifyTables is false)
local LineOffsets = {
    [6] = 1311,
    [9] = 1416,
    [2] = 75,
    [10] = 16,
    [8] = 1644,
    [7] = 1783,
    [5] = 1987,
    [4] = 2169
}

-- Misc AOT variable imports
local WaxVersion = "0.4.2"
local EnvName = "WaxRuntime"

-- ++++++++ RUNTIME IMPL BELOW ++++++++ --

-- Localizing certain libraries and built-ins for runtime efficiency
local string, task, setmetatable, error, next, table, unpack, coroutine, script, type, require, pcall, tostring, tonumber, _VERSION =
      string, task, setmetatable, error, next, table, unpack, coroutine, script, type, require, pcall, tostring, tonumber, _VERSION

local table_insert = table.insert
local table_remove = table.remove
local table_freeze = table.freeze or function(t) return t end -- lol

local coroutine_wrap = coroutine.wrap

local string_sub = string.sub
local string_match = string.match
local string_gmatch = string.gmatch

-- The Lune runtime has its own `task` impl, but it must be imported by its builtin
-- module path, "@lune/task"
if _VERSION and string_sub(_VERSION, 1, 4) == "Lune" then
    local RequireSuccess, LuneTaskLib = pcall(require, "@lune/task")
    if RequireSuccess and LuneTaskLib then
        task = LuneTaskLib
    end
end

local task_defer = task and task.defer

-- If we're not running on the Roblox engine, we won't have a `task` global
local Defer = task_defer or function(f, ...)
    coroutine_wrap(f)(...)
end

-- ClassName "IDs"
local ClassNameIdBindings = {
    [1] = "Folder",
    [2] = "ModuleScript",
    [3] = "Script",
    [4] = "LocalScript",
    [5] = "StringValue",
}

local RefBindings = {} -- [RefId] = RealObject

local ScriptClosures = {}
local ScriptClosureRefIds = {} -- [ScriptClosure] = RefId
local StoredModuleValues = {}
local ScriptsToRun = {}

-- wax.shared __index/__newindex
local SharedEnvironment = {}

-- We're creating 'fake' instance refs soley for traversal of the DOM for require() compatibility
-- It's meant to be as lazy as possible
local RefChildren = {} -- [Ref] = {ChildrenRef, ...}

-- Implemented instance methods
local InstanceMethods = {
    GetFullName = { {}, function(self)
        local Path = self.Name
        local ObjectPointer = self.Parent

        while ObjectPointer do
            Path = ObjectPointer.Name .. "." .. Path

            -- Move up the DOM (parent will be nil at the end, and this while loop will stop)
            ObjectPointer = ObjectPointer.Parent
        end

        return Path
    end},

    GetChildren = { {}, function(self)
        local ReturnArray = {}

        for Child in next, RefChildren[self] do
            table_insert(ReturnArray, Child)
        end

        return ReturnArray
    end},

    GetDescendants = { {}, function(self)
        local ReturnArray = {}

        for Child in next, RefChildren[self] do
            table_insert(ReturnArray, Child)

            for _, Descendant in next, Child:GetDescendants() do
                table_insert(ReturnArray, Descendant)
            end
        end

        return ReturnArray
    end},

    FindFirstChild = { {"string", "boolean?"}, function(self, name, recursive)
        local Children = RefChildren[self]

        for Child in next, Children do
            if Child.Name == name then
                return Child
            end
        end

        if recursive then
            for Child in next, Children do
                -- Yeah, Roblox follows this behavior- instead of searching the entire base of a
                -- ref first, the engine uses a direct recursive call
                return Child:FindFirstChild(name, true)
            end
        end
    end},

    FindFirstAncestor = { {"string"}, function(self, name)
        local RefPointer = self.Parent
        while RefPointer do
            if RefPointer.Name == name then
                return RefPointer
            end

            RefPointer = RefPointer.Parent
        end
    end},

    -- Just to implement for traversal usage
    WaitForChild = { {"string", "number?"}, function(self, name)
        return self:FindFirstChild(name)
    end},
}

-- "Proxies" to instance methods, with err checks etc
local InstanceMethodProxies = {}
for MethodName, MethodObject in next, InstanceMethods do
    local Types = MethodObject[1]
    local Method = MethodObject[2]

    local EvaluatedTypeInfo = {}
    for ArgIndex, TypeInfo in next, Types do
        local ExpectedType, IsOptional = string_match(TypeInfo, "^([^%?]+)(%??)")
        EvaluatedTypeInfo[ArgIndex] = {ExpectedType, IsOptional}
    end

    InstanceMethodProxies[MethodName] = function(self, ...)
        if not RefChildren[self] then
            error("Expected ':' not '.' calling member function " .. MethodName, 2)
        end

        local Args = {...}
        for ArgIndex, TypeInfo in next, EvaluatedTypeInfo do
            local RealArg = Args[ArgIndex]
            local RealArgType = type(RealArg)
            local ExpectedType, IsOptional = TypeInfo[1], TypeInfo[2]

            if RealArg == nil and not IsOptional then
                error("Argument " .. RealArg .. " missing or nil", 3)
            end

            if ExpectedType ~= "any" and RealArgType ~= ExpectedType and not (RealArgType == "nil" and IsOptional) then
                error("Argument " .. ArgIndex .. " expects type \"" .. ExpectedType .. "\", got \"" .. RealArgType .. "\"", 2)
            end
        end

        return Method(self, ...)
    end
end

local function CreateRef(className, name, parent)
    -- `name` and `parent` can also be set later by the init script if they're absent

    -- Extras
    local StringValue_Value

    -- Will be set to RefChildren later aswell
    local Children = setmetatable({}, {__mode = "k"})

    -- Err funcs
    local function InvalidMember(member)
        error(member .. " is not a valid (virtual) member of " .. className .. " \"" .. name .. "\"", 3)
    end
    local function ReadOnlyProperty(property)
        error("Unable to assign (virtual) property " .. property .. ". Property is read only", 3)
    end

    local Ref = {}
    local RefMetatable = {}

    RefMetatable.__metatable = false

    RefMetatable.__index = function(_, index)
        if index == "ClassName" then -- First check "properties"
            return className
        elseif index == "Name" then
            return name
        elseif index == "Parent" then
            return parent
        elseif className == "StringValue" and index == "Value" then
            -- Supporting StringValue.Value for Rojo .txt file conv
            return StringValue_Value
        else -- Lastly, check "methods"
            local InstanceMethod = InstanceMethodProxies[index]

            if InstanceMethod then
                return InstanceMethod
            end
        end

        -- Next we'll look thru child refs
        for Child in next, Children do
            if Child.Name == index then
                return Child
            end
        end

        -- At this point, no member was found; this is the same err format as Roblox
        InvalidMember(index)
    end

    RefMetatable.__newindex = function(_, index, value)
        -- __newindex is only for props fyi
        if index == "ClassName" then
            ReadOnlyProperty(index)
        elseif index == "Name" then
            name = value
        elseif index == "Parent" then
            -- We'll just ignore the process if it's trying to set itself
            if value == Ref then
                return
            end

            if parent ~= nil then
                -- Remove this ref from the CURRENT parent
                RefChildren[parent][Ref] = nil
            end

            parent = value

            if value ~= nil then
                -- And NOW we're setting the new parent
                RefChildren[value][Ref] = true
            end
        elseif className == "StringValue" and index == "Value" then
            -- Supporting StringValue.Value for Rojo .txt file conv
            StringValue_Value = value
        else
            -- Same err as __index when no member is found
            InvalidMember(index)
        end
    end

    RefMetatable.__tostring = function()
        return name
    end

    setmetatable(Ref, RefMetatable)

    RefChildren[Ref] = Children

    if parent ~= nil then
        RefChildren[parent][Ref] = true
    end

    return Ref
end

-- Create real ref DOM from object tree
local function CreateRefFromObject(object, parent)
    local RefId = object[1]
    local ClassNameId = object[2]
    local Properties = object[3] -- Optional
    local Children = object[4] -- Optional

    local ClassName = ClassNameIdBindings[ClassNameId]

    local Name = Properties and table_remove(Properties, 1) or ClassName

    local Ref = CreateRef(ClassName, Name, parent) -- 3rd arg may be nil if this is from root
    RefBindings[RefId] = Ref

    if Properties then
        for PropertyName, PropertyValue in next, Properties do
            Ref[PropertyName] = PropertyValue
        end
    end

    if Children then
        for _, ChildObject in next, Children do
            CreateRefFromObject(ChildObject, Ref)
        end
    end

    return Ref
end

local RealObjectRoot = CreateRef("Folder", "[" .. EnvName .. "]")
for _, Object in next, ObjectTree do
    CreateRefFromObject(Object, RealObjectRoot)
end

-- Now we'll set script closure refs and check if they should be ran as a BaseScript
for RefId, Closure in next, ClosureBindings do
    local Ref = RefBindings[RefId]

    ScriptClosures[Ref] = Closure
    ScriptClosureRefIds[Ref] = RefId

    local ClassName = Ref.ClassName
    if ClassName == "LocalScript" or ClassName == "Script" then
        table_insert(ScriptsToRun, Ref)
    end
end

local function LoadScript(scriptRef)
    local ScriptClassName = scriptRef.ClassName

    -- First we'll check for a cached module value (packed into a tbl)
    local StoredModuleValue = StoredModuleValues[scriptRef]
    if StoredModuleValue and ScriptClassName == "ModuleScript" then
        return unpack(StoredModuleValue)
    end

    local Closure = ScriptClosures[scriptRef]

    local function FormatError(originalErrorMessage)
        originalErrorMessage = tostring(originalErrorMessage)

        local VirtualFullName = scriptRef:GetFullName()

        -- Check for vanilla/Roblox format
        local OriginalErrorLine, BaseErrorMessage = string_match(originalErrorMessage, "[^:]+:(%d+): (.+)")

        if not OriginalErrorLine or not LineOffsets then
            return VirtualFullName .. ":*: " .. (BaseErrorMessage or originalErrorMessage)
        end

        OriginalErrorLine = tonumber(OriginalErrorLine)

        local RefId = ScriptClosureRefIds[scriptRef]
        local LineOffset = LineOffsets[RefId]

        local RealErrorLine = OriginalErrorLine - LineOffset + 1
        if RealErrorLine < 0 then
            RealErrorLine = "?"
        end

        return VirtualFullName .. ":" .. RealErrorLine .. ": " .. BaseErrorMessage
    end

    -- If it's a BaseScript, we'll just run it directly!
    if ScriptClassName == "LocalScript" or ScriptClassName == "Script" then
        local RunSuccess, ErrorMessage = pcall(Closure)
        if not RunSuccess then
            error(FormatError(ErrorMessage), 0)
        end
    else
        local PCallReturn = {pcall(Closure)}

        local RunSuccess = table_remove(PCallReturn, 1)
        if not RunSuccess then
            local ErrorMessage = table_remove(PCallReturn, 1)
            error(FormatError(ErrorMessage), 0)
        end

        StoredModuleValues[scriptRef] = PCallReturn
        return unpack(PCallReturn)
    end
end

-- We'll assign the actual func from the top of this output for flattening user globals at runtime
-- Returns (in a tuple order): wax, script, require
function ImportGlobals(refId)
    local ScriptRef = RefBindings[refId]

    local function RealCall(f, ...)
        local PCallReturn = {pcall(f, ...)}

        local CallSuccess = table_remove(PCallReturn, 1)
        if not CallSuccess then
            error(PCallReturn[1], 3)
        end

        return unpack(PCallReturn)
    end

    -- `wax.shared` index
    local WaxShared = table_freeze(setmetatable({}, {
        __index = SharedEnvironment,
        __newindex = function(_, index, value)
            SharedEnvironment[index] = value
        end,
        __len = function()
            return #SharedEnvironment
        end,
        __iter = function()
            return next, SharedEnvironment
        end,
    }))

    local Global_wax = table_freeze({
        -- From AOT variable imports
        version = WaxVersion,
        envname = EnvName,

        shared = WaxShared,

        -- "Real" globals instead of the env set ones
        script = script,
        require = require,
    })

    local Global_script = ScriptRef

    local function Global_require(module, ...)
        local ModuleArgType = type(module)

        local ErrorNonModuleScript = "Attempted to call require with a non-ModuleScript"
        local ErrorSelfRequire = "Attempted to call require with self"

        if ModuleArgType == "table" and RefChildren[module]  then
            if module.ClassName ~= "ModuleScript" then
                error(ErrorNonModuleScript, 2)
            elseif module == ScriptRef then
                error(ErrorSelfRequire, 2)
            end

            return LoadScript(module)
        elseif ModuleArgType == "string" and string_sub(module, 1, 1) ~= "@" then
            -- The control flow on this SUCKS

            if #module == 0 then
                error("Attempted to call require with empty string", 2)
            end

            local CurrentRefPointer = ScriptRef

            if string_sub(module, 1, 1) == "/" then
                CurrentRefPointer = RealObjectRoot
            elseif string_sub(module, 1, 2) == "./" then
                module = string_sub(module, 3)
            end

            local PreviousPathMatch
            for PathMatch in string_gmatch(module, "([^/]*)/?") do
                local RealIndex = PathMatch
                if PathMatch == ".." then
                    RealIndex = "Parent"
                end

                -- Don't advance dir if it's just another "/" either
                if RealIndex ~= "" then
                    local ResultRef = CurrentRefPointer:FindFirstChild(RealIndex)
                    if not ResultRef then
                        local CurrentRefParent = CurrentRefPointer.Parent
                        if CurrentRefParent then
                            ResultRef = CurrentRefParent:FindFirstChild(RealIndex)
                        end
                    end

                    if ResultRef then
                        CurrentRefPointer = ResultRef
                    elseif PathMatch ~= PreviousPathMatch and PathMatch ~= "init" and PathMatch ~= "init.server" and PathMatch ~= "init.client" then
                        error("Virtual script path \"" .. module .. "\" not found", 2)
                    end
                end

                -- For possible checks next cycle
                PreviousPathMatch = PathMatch
            end

            if CurrentRefPointer.ClassName ~= "ModuleScript" then
                error(ErrorNonModuleScript, 2)
            elseif CurrentRefPointer == ScriptRef then
                error(ErrorSelfRequire, 2)
            end

            return LoadScript(CurrentRefPointer)
        end

        return RealCall(require, module, ...)
    end

    -- Now, return flattened globals ready for direct runtime exec
    return Global_wax, Global_script, Global_require
end

for _, ScriptRef in next, ScriptsToRun do
    Defer(LoadScript, ScriptRef)
end
