# EnvielUI Library

A modern, optimized, and aesthetic UI Library for Roblox.  
Designed for **performance**, **clean aesthetics**, and **ease of use**.

![EnvielUI Banner](https://via.placeholder.com/700x200?text=Enviel+UI+Library)

## Features

- **Modern Design**: Clean interface with "Underline" tab animations and glass-morphism effects.
- **Optimized Performance**: efficiently manages connections and memory.
- **Theme System**: Built-in Dark and Light modes with active visual feedback.
- **Floating Navbar**: Unique floating navigation bar for a premium feel.
- **Rich Elements**: Full suite of interactive elements (Sliders, ColorPickers, Dropdowns, etc.).

---

## 🚀 Quick Start

Load the library in your script:

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/nvlra/EnvielUI/main/EnvielUI.lua"))()
```

## 1. Create a Window

Initialize the main UI window.

```lua
local Window = Library:CreateWindow({
    Name = "Enviel Base",
    Theme = "Dark", -- "Dark" or "Light"
    Width = 650,    -- Recommended width for best layout
    NoSidebar = false
})
```

## 2. Create Tabs

Tabs are located in the floating navbar at the bottom.

```lua
local MainTab = Window:CreateTab({
    Name = "Home",
    Icon = "home", -- Lucide Icon Name
})

local SettingsTab = Window:CreateTab({
    Name = "Settings",
    Icon = "settings",
})
```

## 3. Add Elements

Elements are added to Tabs. You can organize them into **Sections**.

### Section (Header)

```lua
MainTab:CreateSection("Main Features")
```

### Button

```lua
MainTab:CreateButton({
    Name = "Kill All Mobs",
    ButtonText = "Execute", -- Optional right-side text
    Callback = function()
        print("Killed all mobs!")
    end
})
```

### Toggle

```lua
MainTab:CreateToggle({
    Name = "Auto Farm",
    Default = false,
    Callback = function(Value)
        print("Auto Farm is:", Value)
    end
})
```

### Slider

```lua
MainTab:CreateSlider({
    Name = "WalkSpeed",
    Min = 16,
    Max = 300,
    Default = 16,
    Increment = 1,
    Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
    end
})
```

### Dropdown

```lua
MainTab:CreateDropdown({
    Name = "Select Weapon",
    Options = {"Sword", "Bow", "Staff"},
    Default = "Sword",
    Multi = false, -- Set to true for multi-select
    Search = true,  -- Enable search bar
    Callback = function(Value)
        print("Selected:", Value)
    end
})
```

### Color Picker

```lua
MainTab:CreateColorPicker({
    Name = "Accent Color",
    CurrentValue = Color3.fromRGB(0, 170, 255),
    Callback = function(Value)
        print("New Color:", Value)
    end
})
```

### Input Box

```lua
MainTab:CreateInput({
    Name = "Teleport Place ID",
    PlaceholderText = "123456...",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        print("Input:", Text)
    end
})
```

### Clickable List

A scrollable list of buttons.

```lua
MainTab:CreateClickableList({
    Title = "Player List",
    Content = {"Player1", "Player2", "Player3"},
    Height = UDim2.new(1, 0, 0, 150),
    Callback = function(Item)
        print("Clicked:", Item)
    end
})
```

### Paragraph

Display text information.

```lua
MainTab:CreateParagraph({
    Title = "Status",
    Content = "Script is currently active and running safely."
})
```

## 4. Advanced Features

### Notifications

Send a toast notification to the user.

```lua
Window:Notify({
    Title = "Success",
    Content = "Config loaded successfully!",
    Duration = 5, -- Optional duration in seconds
    Image = "check" -- Optional Lucide Icon
})
```

### Prompt (Alert)

Show a modal dialog for user confirmation.

```lua
Window:Prompt({
    Title = "Warning",
    Content = "Are you sure you want to overwrite your config?",
    Actions = {
        {
            Text = "Yes",
            Callback = function() print("Overwriting...") end,
        },
        {
            Text = "No",
            Callback = function() print("Cancelled") end,
        }
    }
})
```

### Watermark

Display a subtle watermark on the screen.

```lua
Window:Watermark({
    Title = "Enviel UI | FPS: 60 | Ping: 45ms",
    Enabled = true
})
```

---

## 💡 Tips

- **Destruction**: Call `Window:Destroy()` to cleanly remove the UI and disconnect all events.
- **Theming**: You can switch themes dynamically (advanced usage).
- **Icons**: Use any [Lucide Icon](https://lucide.dev/icons) name for your tabs.

---

_Built by Enviel._
