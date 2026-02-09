--[[
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
