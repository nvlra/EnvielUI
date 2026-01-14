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
local Window = EnvielUI.new():CreateWindow({
    Name = "Enviel UI Script",
    Theme = "Dark", -- Options: "Dark" or "Light"
    Icon = "rbxassetid://12345678" -- Optional custom icon
})

-- 3. Create a Tab
local MainTab = Window:CreateTab({
    Name = "Main",
    Icon = "swords" -- Use any Lucide Icon name (lowercase)
})

local SettingsTab = Window:CreateTab({
    Name = "Settings",
    Icon = "settings"
})

-- 4. Add Elements
local Section = MainTab:CreateSection("Farming")

Section:CreateButton({
    Name = "Kill All Enemies",
    Callback = function()
        print("Killing enemies...")
    end
})

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
```

---

## Icon System (Lucide)

EnvielUI uses the **Lucide** icon set. You don't need Asset IDs!
Just use the icon name in lowercase.

**Examples:**

- `home`
- `settings`
- `user`
- `swords`
- `shield`
- `zap`

[View All Lucide Icons Here](https://lucide.dev/icons)  
_(Note: Use the name, e.g., "arrow-right")_

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
| `CreateGroup`         | Creates a container to organize elements (WindUI Style). |
| `Watermark`           | Shows the branded HUD overlay.                           |
| `Prompt`              | Displays a rich alert popup with actions.                |
| `Notify`              | Sends a temporary toast notification.                    |
| `CreateClickableList` | Creates a scrollable list of buttons.                    |

---

## Advanced Features

### 1. Watermark HUD

Minimalist, theme-adaptive branding at the bottom-left.
_Note: The text is hardcoded to "Enviel UI v1.0" for security/branding._

```lua
Window:Watermark({
    Title = "Enviel UI", -- (Currently hardcoded internally)
})
```

### 2. Group System (iOS Style Layout)

Organize your elements into clean, separated groups.

```lua
local SettingsGroup = MainTab:CreateGroup({ Title = "General Settings" })

SettingsGroup:CreateToggle({ ... }) -- Automatically inside the group
SettingsGroup:CreateButton({ ... })
```

### 3. Rich Alerts (Prompts)

Show important warnings or confirmations (uses smooth Pop-In animation).

```lua
Window:Prompt({
    Title = "Confirmation",
    Content = "Are you sure you want to proceed?",
    Actions = {
        {
            Text = "Yes",
            Callback = function() print("Confirmed") end
        },
        {
            Text = "No",
            Callback = function() print("Cancelled") end
        }
    }
})
```

### 4. Clickable Lists (Explorer Style)

Create a scrollable list where each item is a button. Perfect for files, players, or inventory.

```lua
local FileList = Tab:CreateClickableList({
    Title = "Files",
    Content = {"Folder1", "Script.lua", "Model"},
    Height = UDim2.new(1, 0, 0, 200),
    Callback = function(ItemName)
        print("Clicked:", ItemName)
    end
})

-- Update list dynamically
FileList:Refresh({"New Item 1", "New Item 2"})
```

---

_Created by nvlra. Open Source & Free to Use._
