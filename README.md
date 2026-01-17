# EnvielUI

A clean, modern, and mobile-responsive UI Library for Roblox, featuring smooth animations, modal dropdowns, and a sleek dark theme.

## Features

- **Mobile Optimizations**:
  - **Dynamic Scaling**: UI elements (Text, Buttons, Header) automatically resize based on screen width (`< 800px`).
  - **Compact Layout**: Optimized Dock height (36px) and padding for smaller screens.
  - **Taller Window**: Main frame height increased to 80% on mobile for better content visibility.
- **Modern Components**:
  - **Modal Dropdown**: New "Bottom Sheet" style dropdown that slides up from the bottom, fully supporting **Multi-Select**.
  - **Floating Dock**: Bottom navigation bar with smooth sliding active indicator (pill).
  - **Notifications**: Slide-in notifications with accent bars and auto-dismiss.
  - **Blur Effect**: Background blurring when Modals are active.
- **Animations**:
  - **Smooth Quint Easing**: All animations use `Enum.EasingStyle.Quint` for a premium feel.
  - **Pop Animations**: Buttons and Windows pop in/out smoothly.
- **Customization**:
  - **Themes**: Built-in Dark Theme with customizable accents.
  - **Icons**: Support for custom icons via `rbxassetid`.

## Installation

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/nvlra/EnvielUI/main/EnvielUI.lua"))()
```

## Usage Example

```lua
local Window = Library:CreateWindow({
    Name = "Enviel Showcase",
    Theme = "Dark" -- Optional, defaults to Dark
})

local Tab = Window:CreateTab("Main")

local Section = Tab:CreateSection("Features")

-- Toggle
Tab:CreateToggle({
    Name = "Enable Safe Mode",
    Flag = "SafeMode",
    Callback = function(Value)
    end
})

-- Button
Tab:CreateButton({
    Name = "Click Me!",
    Text = "Press",
    Callback = function()
        Window:Notify({Title = "Success", Content = "Button Pressed!"})
    end
})

-- Multi-Select Dropdown
Tab:CreateDropdown({
    Name = "Select Items",
    Options = {"Apple", "Banana", "Cherry"},
    Multi = true,
    Default = {"Apple"},
    Callback = function(Value)
    end
})
```

## Roadmap

- [x] Auto-Center Floating Dock
- [x] Mobile Responsive Layouts
- [x] Modal Bottom Sheet Logic
- [ ] Color Picker Component
- [ ] Keybind System
