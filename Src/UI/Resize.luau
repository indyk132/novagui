--[[
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
