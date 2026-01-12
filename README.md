# EnvielUI Library for Roblox

A modern, secure, and aesthetic UI Library for Roblox Scripting.  
Designed to be **reliable**, **customizable**, and **undetected**.

![EnvielUI Banner](https://via.placeholder.com/700x200?text=Enviel+UI+Library) _Placeholder for future banner_

## 🔥 Features

- **Secure Parenting**: Automatically attempts to use `gethui()` (Secure) or `CoreGui` to hide the UI from game checks. Falls back to `PlayerGui` if necessary.
- **Overlay Priority**: Forces the UI to render on top of **everything** (DisplayOrder 10000), including the Roblox Pause Menu (if executor supports it).
- **Elastic Animations**: Premium "Pop-up" entrance animation and smooth slide-in/out notifications.
- **Auto-Layout Tabs**: Smart layout system that prevents text and icons from overlapping.
- **Lucide Icons**: Integrated support for Lucide icons (e.g., "swords", "settings", "home").
- **Auto-Update**: The script always fetches the latest version from GitHub.

---

## 🚀 How to Use

Copy and paste this script into your Executor (Synapse X, Krnl, Fluxus, etc.):

```lua
-- 1. Load the Library
-- Tip: Add ?v=RandomNumber to the URL to bypass Roblox caching if you don't see updates.
local LibraryURL = "https://raw.githubusercontent.com/nvlra/EnvielUI/refs/heads/main/EnvielUI.lua"
local EnvielUI = loadstring(game:HttpGet(LibraryURL))()

-- 2. Create a Window
local Window = EnvielUI.new():CreateWindow({
    Name = "Enviel UI Script",
    Theme = "Dark", -- Options: Dark
    Icon = "rbxassetid://12345678" -- Optional custom icon
})

-- 3. Create a Tab
local MainTab = Window:CreateTab({
    Name = "Main",
    Icon = "swords" -- Use Lucide icon names
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

-- 5. Send a Notification
Window:Notify({
    Title = "Welcome!",
    Content = "Script loaded successfully.",
    Duration = 5,
    Image = "rbxassetid://4483345998"
})
```

---

## 🎨 Component Reference

| Component       | Description                                        |
| :-------------- | :------------------------------------------------- |
| `CreateWindow`  | Creates the main dragable GUI window.              |
| `CreateTab`     | Adds a sidebar tab with an icon and text.          |
| `CreateSection` | Adds a header text to organize elements.           |
| `CreateButton`  | A clickable button that executes a function.       |
| `CreateToggle`  | A switch button for boolean (true/false) states.   |
| `CreateSlider`  | A draggable bar to select a number within a range. |
| `Notify`        | Sends a temporary toast notification.              |

---

## 🛠 Troubleshooting

### UI Not Appearing?

- Ensure your executor supports `gethui()` or `CoreGui`.
- If on a strict game/executor, it might fallback to `PlayerGui` which can be covered by the Pause Menu.
- Check the **Console (F9)** for any error messages.

### Updates Not Showing? (Caching)

Roblox caches `loadstring` URLs for a few minutes. To force an update immediately, add a random number to the URL:

```lua
local LibraryURL = "https://raw.githubusercontent.com/nvlra/EnvielUI/main/EnvielUI.lua?v=" .. tostring(math.random())
```

---

_Created by nvlra. Open Source & Free to Use._
