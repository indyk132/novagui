# UI Template

A clean, reusable GUI template based on Nova's UI system.

## Structure

```
Template/
├── Example.luau      # Complete window example with tabs
├── README.md         # This file
└── UI/
    ├── Theme.luau    # Color definitions
    ├── Interface.luau # Instance creation utilities
    ├── Helper.luau   # UI interaction helpers
    ├── Drag.luau     # Draggable frames
    ├── Resize.luau   # Resizable frames
    ├── Sonner.luau   # Toast notifications
    └── Icons.luau    # Lucide icons integration
```

## Quick Start

```lua
-- Import modules
local UI = script.Parent.UI
local Theme = require(UI.Theme)
local Interface = require(UI.Interface)
local Helper = require(UI.Helper)
local Drag = require(UI.Drag)
local Sonner = require(UI.Sonner)

-- Create ScreenGui
local ScreenGui = Interface.CreateScreenGui("MyApp")

-- Initialize notifications
Sonner.Initialize(ScreenGui)

-- Create a window
local MainFrame = Interface.New("Frame", {
    BackgroundColor3 = Theme.Background,
    Size = UDim2.fromOffset(600, 400),
    Position = UDim2.fromScale(0.5, 0.5),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Parent = ScreenGui,
    
    ["UICorner"] = { CornerRadius = UDim.new(0, 8) },
    ["UIStroke"] = { Color = Theme.Border, Thickness = 1 },
})

-- Make it draggable
Drag.new(MainFrame)

-- Show a notification
Sonner.success("Window created!")
```

## Modules

### Theme
Centralized color definitions:
- `Theme.Background`, `Theme.Surface`, `Theme.SurfaceHover`
- `Theme.Border`, `Theme.BorderLight`
- `Theme.Text`, `Theme.TextMuted`
- `Theme.Accent`, `Theme.AccentHover`
- `Theme.Success`, `Theme.Warning`, `Theme.Error`, `Theme.Info`

### Interface
Instance creation with inline child support:
```lua
local frame = Interface.New("Frame", {
    Size = UDim2.fromOffset(200, 100),
    ["UICorner"] = { CornerRadius = UDim.new(0, 8) },
    ["UIPadding"] = { PaddingAll = UDim.new(0, 12) },
})
```

Helper functions:
- `Interface.CreateScreenGui(name)`
- `Interface.CreateTextLabel(props)`
- `Interface.CreateTextButton(props)`
- `Interface.CreateImageLabel(props)`
- `Interface.CreateScrollingFrame(props)`

### Helper
UI interaction utilities:
- `Helper.Ripple(button)` - Material-style ripple effect
- `Helper.HoverEffect(element, hoverColor, normalColor)` - Color transition on hover
- `Helper.HoverTransparency(element, hoverTransparency, normalTransparency)`
- `Helper.Tween(element, props, duration)` - Quick tween helper
- `Helper.Truncate(text, maxLength)` - Truncate text with ellipsis
- `Helper.FormatNumber(num)` - Format large numbers (1K, 1M)
- `Helper.FormatTimestamp(seconds)` - Format as HH:MM:SS
- `Helper.Debounce(func, wait)` - Debounce a function

### Drag
Make frames draggable:
```lua
local dragger = Drag.new(mainFrame, titleBar)
dragger:SetEnabled(false) -- Disable dragging
dragger:Destroy() -- Clean up
```

### Resize
Make frames resizable:
```lua
local resizer = Resize.new({
    MainFrame = mainFrame,
    MinimumSize = Vector2.new(300, 200),
    MaximumSize = UDim2.fromOffset(800, 600),
})
resizer:SetEnabled(false) -- Disable resizing
resizer:Destroy() -- Clean up
```

### Sonner
Toast notifications:
```lua
Sonner.Initialize(screenGui, Icons) -- Icons module is optional

Sonner.info("Information message")
Sonner.success("Success!")
Sonner.warning("Warning!")
Sonner.error("Error!")
Sonner.toast("Simple toast")
Sonner.clear() -- Clear all notifications
```

### Icons
Lucide icons integration:
```lua
Icons.ApplyIcon(imageLabel, "settings")
Icons.ApplyIcon(imageLabel, "home")
Icons.ApplyIcon(imageLabel, "x")

-- Check if icons loaded
if Icons.IsAvailable() then
    local iconData = Icons.GetIcon("user")
end
```

## License

MIT - Use freely in your projects.
