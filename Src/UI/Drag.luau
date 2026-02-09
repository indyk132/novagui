--[[
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
