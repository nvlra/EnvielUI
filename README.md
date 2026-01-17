# 🛠️ EnvielUI

**EnvielUI** is a modern, lightweight, and responsive User Interface library for Roblox. Designed for ease of use, it features a sleek dark theme, mobile support, and a comprehensive set of interactive components.

## ✨ Features

- **Modern Aesthetic**: Clean, dark-themed UI with glassmorphism effects.
- **Mobile Responsive**: Auto-scaling and touch-optimized controls for mobile devices.
- **Robust System**: Built-in memory management and validation.
- **Config System**: built-in Save/Load functionality for toggles and sliders.
- **Notifications**: Clean toast notification system.

## 📦 Installation

Load EnvielUI directly into your script using the following loadstring:

```lua
local EnvielUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/nvlra/EnvielUI/main/EnvielUI.lua"))()
```

---

## 🚀 Getting Started

### 1. Create a Window

The `CreateWindow` function initializes the UI.

```lua
local Window = EnvielUI:CreateWindow({
    Name = "My Hub",
    Theme = { -- Optional Custom Theme
        Main = Color3.fromRGB(20, 20, 20),
        Accent = Color3.fromRGB(0, 120, 215)
    }
})
```

### 2. Create a Tab

Tabs allow you to organize your features.

```lua
local MainTab = Window:CreateTab({
    Name = "Main"
})
```

---

## 🧩 Components

All components are created from a **Tab** object (e.g., `MainTab`).

### Section & Paragraph

Use sections to divide content and paragraphs for info.

```lua
MainTab:CreateSection("Feature Section")

MainTab:CreateParagraph({
    Title = "Welcome",
    Content = "This is a paragraph example."
})
```

### Button

A simple clickable button.

```lua
MainTab:CreateButton({
    Name = "Click Me",
    Text = "Execute", -- Button label
    Callback = function()
        print("Button Clicked!")
    end
})
```

### Toggle

A switch for boolean states. Supports `Flag` for config saving.

```lua
MainTab:CreateToggle({
    Name = "Auto Farm",
    Default = false,
    Flag = "AutoFarm", -- Unique ID for Config
    Callback = function(Value)
        print("Auto Farm is now:", Value)
    end
})
```

### Slider

A numeric slider with Min/Max values.

```lua
MainTab:CreateSlider({
    Name = "WalkSpeed",
    Min = 16,
    Max = 500,
    Default = 16,
    Flag = "WalkSpeed",
    Callback = function(Value)
        print("Speed set to:", Value)
    end
})
```

### Input (TextBox)

A text input field.

```lua
MainTab:CreateInput({
    Name = "Target Player",
    PlaceholderText = "Username",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        print("Target:", Text)
    end
})
```

### Dropdown

A selectable list of options.

```lua
MainTab:CreateDropdown({
    Name = "Teleport Method",
    Options = {"CFrame", "Tween", "Instant"},
    Default = "CFrame",
    Flag = "Method",
    Callback = function(Option)
        print("Selected:", Option)
    end
})
```

### Color Picker

An RGB color selector.

```lua
MainTab:CreateColorPicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(255, 0, 0),
    Flag = "ESPColor",
    Callback = function(Color)
        print("New Color:", Color)
    end
})
```

---

## 🔔 Notifications

Send toast notifications to the user.

```lua
Window:Notify({
    Title = "Success",
    Content = "Operation completed successfully!",
    Duration = 3 -- Time in seconds
})
```

## ⚙️ Configuration System

EnvielUI has a built-in system to save and load `Flag` values.

```lua
-- Save current settings to file
Window:SaveConfig()

-- Load settings from file
Window:LoadConfig()
```

## ⚠️ Notes

- **Mobile Support**: The UI automatically scales down for screens smaller than 600px width.
- **Keybind**: Press `RightControl` to toggle UI visibility.

---

**Made by Enviel**
