# Enviel UI Library

Enviel UI is a customizable User Interface library for Roblox, designed with a focus on smooth animations and a modern aesthetic.

## Features

- **Modern Design**: Dark & Light themes with an acrylic-style appearance.
- **Animations**: Tweens for window interactions, buttons, and toggles.
- **Dynamic Icons**: Integrated support for Lucide and Geist icons via automated fetching.
- **Component Library**:
  - Color Picker (Hue Spectrum & RGB Sliders)
  - Smooth Sliders
  - Toggles
  - Dropdown Menus
  - Keybind Listeners
  - Notification System
- **Window Management**: Drag and drop support with a minimized floating icon state.

## Getting Started

### Installation

Load the library directly into your script using `loadstring`:

```lua
local EnvielUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/YourUsername/EnvielUI/main/EnvielUI.lua"))()
```

### Basic Usage

```lua
local Window = EnvielUI.new():CreateWindow({
    Name = "My Script",
    Theme = "Dark", -- or "Light"
    Keybind = Enum.KeyCode.RightControl
})

local Tab = Window:CreateTab({
    Name = "Home",
    Icon = "home"
})

Tab:CreateButton({
    Name = "Click Me",
    Callback = function()
        Window:Notify({Title = "Success", Content = "Button Clicked!"})
    end
})
```

## Documentation

### Window Configuration

- **Name**: Title of the window.
- **Theme**: Color scheme ("Dark" or "Light").
- **Keybind**: Key to toggle UI visibility.

### Components

#### CreateTab

Adds a new tab to the sidebar.

```lua
Window:CreateTab({ Name = "Tab Name", Icon = "settings" })
```

#### Notify

Displays a temporary notification toast.

```lua
Window:Notify({
    Title = "Alert",
    Content = "Notification message",
    Duration = 3,
    Image = "info"
})
```

#### Interactive Elements

The following methods are available on a Tab object:

- `CreateButton`
- `CreateToggle`
- `CreateSlider`
- `CreateDropdown`
- `CreateInput`
- `CreateColorPicker`
- `CreateKeybind`
- `CreateSection`

## Credits

- **Creator**: Enviel
- **Icons**: Footagesus/Icons (Lucide/Geist)
