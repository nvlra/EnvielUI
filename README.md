# Enviel UI Library

Enviel UI is a premium, minimalistic User Interface library for Roblox developers. It features a modern acrylic aesthetic, smooth Tween animations, and a robust component system designed for professional scripts.

## Features

- **Modern Aesthetics**: Clean Dark & Light themes with high-quality visual hierarchy.
- **Fluid Animations**: Custom Tween logic for window dragging, toggling, and interactions.
- **Dynamic Icons**: Integrated support for Lucide and Geist icons. Simply use icon names (e.g., "home", "settings") without needing Asset IDs.
- **Advanced Components**:
  - **Color Picker**: Full HSV spectrum bar with precise RGB sliders.
  - **Notifications**: Built-in toast notification system.
  - **Interactive Controls**: Smooth sliders, animated dropdowns, and keybind listeners.
- **Window Management**: Draggable interface with a minimize-to-icon feature.

## Installation

Import the library directly into your script using `loadstring`.

```lua
local EnvielUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/nvlra/EnvielUI/main/EnvielUI.lua"))()
```

## Documentation

### Creating a Window

```lua
local Window = EnvielUI.new():CreateWindow({
    Name = "My Hub",
    Theme = "Dark",
    Keybind = Enum.KeyCode.RightControl
})
```

### Tab System

Tabs are created within a Window. You can use direct names for icons.

```lua
local HomeTab = Window:CreateTab({
    Name = "Home",
    Icon = "layout-dashboard"
})
```

### Notifications

Send local notifications to the user.

```lua
Window:Notify({
    Title = "Welcome",
    Content = "Script loaded successfully.",
    Duration = 5,
    Image = "check"
})
```

### Components Reference

| Component           | Description                              |
| :------------------ | :--------------------------------------- |
| `CreateButton`      | Standard clickable button with callback. |
| `CreateToggle`      | On/Off switch with boolean state.        |
| `CreateSlider`      | Draggable slider for number ranges.      |
| `CreateDropdown`    | Expandable menu for multiple choices.    |
| `CreateInput`       | Text input field.                        |
| `CreateColorPicker` | HSV/RGB color selection tool.            |
| `CreateKeybind`     | Key press listener for custom binds.     |
| `CreateSection`     | Visual separator text.                   |

## Credits

- **Library Creator**: Enviel
- **Icon System**: Powered by Footagesus/Icons (Lucide/Geist)
