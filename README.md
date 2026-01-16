# EnvielUI Library for Roblox

A modern, secure, and aesthetic UI Library for Roblox Scripting.  
Designed to be **reliable**, **customizable**, and **undetected**.

![EnvielUI Banner](https://via.placeholder.com/700x200?text=Enviel+UI+Library) _Placeholder for future banner_

## Features

- **Secure Protection**: Advanced concealment methods to ensure safety and reliability.
- **Smart Overlay**: Intelligent priority management for optimal UI visibility.
- **Elastic Animations**: Premium "Pop-up" entrance animation (Quint Easing).
- **Auto-Layout Tabs**: Smart layout system preventing checks.
- **Lucide Icons**: Integrated support for thousands of icons (e.g., "home", "settings", "user").
- **Theme System**: Full support for **Dark** and **Light** modes.
- **Modern UX**: Auto-transparency (Glass effect) and Click-Through blocking enabled by default.

---

## How to Use

Copy and paste this script into your Executor (Synapse X, Krnl, Fluxus, etc.):

```lua
-- 1. Load the Library
local EnvielUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/nvlra/EnvielUI/main/EnvielUI.lua"))()

-- 2. Create a Window
local Window = EnvielUI:CreateWindow({
    Name = "Enviel UI Script",
    Theme = "Dark", -- Options: "Dark" or "Light"
    Width = 360, -- Optional: Custom Window Width (Default: 360)
    NoSidebar = false -- Optional: Hide sidebar for simple UIs (Default: false)
})

-- 3. Create a Tab
local MainTab = Window:CreateTab({
    Name = "Main",
    Icon = "swords" -- Use any Lucide Icon name (lowercase)
})

-- 4. Add Elements
local Section = MainTab:CreateSection("Farming")

Section:CreateToggle({
    Name = "Auto Farm",
    Default = false,
    Callback = function(Value)
        print("Auto Farm is now:", Value)
    end
})

Section:CreateSlider({
    Name = "WalkSpeed",
    Min = 16,
    Max = 500,
    Default = 16,
    Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
    end
})

Section:CreateDropdown({
    Name = "Select Weapon",
    Options = {"Sword", "Bow", "Magic"},
    Default = "Sword",
    Callback = function(Value)
        print("Selected:", Value)
    end
})

Section:CreateColorPicker({
    Name = "ESP Color",
    CurrentValue = Color3.fromRGB(255, 0, 0),
    Callback = function(Value)
        print("Color changed:", Value)
    end
})
```

---

## Component Reference

| Component             | Description                                              |
| :-------------------- | :------------------------------------------------------- |
| `CreateWindow`        | Creates the main draggable GUI window.                   |
| `CreateTab`           | Adds a sidebar tab with an icon and text.                |
| `CreateSection`       | Adds a header text to organize elements.                 |
| `CreateButton`        | A clickable button that executes a function.             |
| `CreateToggle`        | A switch button for boolean (true/false) states.         |
| `CreateSlider`        | A draggable bar to select a number within a range.       |
| `CreateDropdown`      | A collapsible menu to select options.                    |
| `CreateInput`         | A text box for user input.                               |
| `CreateColorPicker`   | A tool to visually select colors.                        |
| `CreateParagraph`     | Displays a title and content text block.                 |
| `CreateGroup`         | Creates a container to organize elements (WindUI Style). |
| `Watermark`           | Shows the branded HUD overlay.                           |
| `Prompt`              | Displays a rich alert popup with actions.                |
| `Notify`              | Sends a temporary toast notification.                    |
| `CreateClickableList` | Creates a scrollable list of buttons.                    |

---

## Detailed Examples

### Dropdown (Single & Multi)

```lua
-- Single Select
Section:CreateDropdown({
    Name = "Teleport Method",
    Options = {"CFrame", "MoveTo", "Instant"},
    Default = "CFrame",
    Callback = function(Value) end
})

-- Multi Select (Pass Multi=true) (Beta)
Section:CreateDropdown({
    Name = "Target Parts",
    Options = {"Head", "Torso", "Arms"},
    Default = {"Head", "Torso"},
    Multi = true,
    Callback = function(Table) end
})
```

### Input Box

```lua
Section:CreateInput({
    Name = "Target Player",
    PlaceholderText = "Username...",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        print("Input:", Text)
    end
})
```

### Paragraph (Info)

```lua
Section:CreateParagraph({
    Title = "Status",
    Content = "Waiting for game..."
})
```

---

## Advanced Features

### 1. Watermark HUD

Minimalist, theme-adaptive branding at the bottom-left.

```lua
Window:Watermark({
    Title = "Enviel UI",
})
```

### 2. Group System (iOS Style Layout)

Organize your elements into clean, separated groups.

```lua
local SettingsGroup = MainTab:CreateGroup({ Title = "General Settings" })
SettingsGroup:CreateToggle({ ... }) -- Automatically inside the group
```

---

_Created by nvlra. Open Source & Free to Use._
