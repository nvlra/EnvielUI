# EnvielUI Documentation

A modern, transparent, and aesthetically pleasing UI Library for Roblox scripts.

## 1. Getting Started

Load the library using `loadstring`. The library automatically handles transparency and themes (Default: Glass/Dark).

```lua
local LibraryUrl = "https://raw.githubusercontent.com/nvlra/EnvielUI/main/EnvielUI.lua"
local EnvielUI = loadstring(game:HttpGet(LibraryUrl))()
```

---

## 2. Global Configuration

You can customize the library's look and feel by editing the `LibraryConfig` table at the top of `EnvielUI.lua`.
Here is the **complete** default configuration for reference:

```lua
local LibraryConfig = {
    Transparency = 0.20, -- Default Window Transparency (20% Transparent / 80% Opacity)
    CornerRadius = {
        Window = 14,
        Group = 12,
        Element = 8,
        Inner = 6
    },
    Colors = {
        Main = Color3.fromHex("2B2B2B"),       -- Main Background (Dark Grey)
        Secondary = Color3.fromHex("1D1D1D"),  -- Element/Group Background
        Stroke = Color3.fromHex("787878"),     -- Border/Outline Color
        Text = Color3.fromHex("FFFFFF"),       -- Main Text Color
        TextDark = Color3.fromHex("888888"),   -- Secondary/Darker Text
        Accent = Color3.fromHex("FFFFFF"),     -- Active/Highlight Color
        Element = Color3.fromHex("1D1D1D"),    -- Container Group Background

        -- Specific Element Colors
        ToggleActive = Color3.fromHex("D4D4D4"),
        ToggleInactive = Color3.fromHex("505050"),
        Input = Color3.fromHex("414141"),
        Button = Color3.fromHex("FFFFFF"),     -- Button Background
        ButtonText = Color3.fromHex("000000"), -- Button Text Color
    },
    Sizes = {
        HeaderHeight = {PC = 50, Mobile = 34},
        NavHeight = {PC = 44, Mobile = 32},
        NavPadding = {PC = 20, Mobile = 10},
        ItemHeight = {PC = 42, Mobile = 32},
        TextSize = {PC = 13, Mobile = 10},
        TitleSize = {PC = 18, Mobile = 14}
    },
    Animation = {
        TweenSpeed = 0.25,
        SpringSpeed = 0.4
    }
}
```

---

## 3. Responsive Behavior (New!)

EnvielUI now handles sizing differently based on the device:

- **Desktop (PC)**:
  - **Width:** Fixed at 650px.
  - **Height:** Dynamic, adjusting to content height.
  - **Constraint:** Height is constrained between 320px (Min) and 450px (Max). Scrollbar appears if content exceeds 450px.
- **Mobile**:
  - **Width:** Fixed at 60% of screen width (Compact Mode).
  - **Height:** Dynamic, adjusting to content height.
  - **Constraint:** Height is constrained up to 80% of the screen height. Items are smaller (32px height) for better fit.

---

## 3. Creating a Window

The Window is the main container.

```lua
local Window = EnvielUI:CreateWindow({
    Name = "My Script Name",
    -- Transparency and Theme are now strictly handled by LibraryConfig (see above).
    -- You do not need to pass them here unless modifying the library code.
})
```

---

## 4. Tabs

Tabs appearing in the floating bottom dock.

```lua
local MainTab = Window:CreateTab({
    Name = "Main" -- Text displayed on the pill button
})
```

---

## 5. Groups (Containers) & Styling

Groups organize elements.
**New Styling Feature**: Elements placed inside a group (using `Group:CreateX`) now automatically adopt a "Clean List" unified style, blending into the group's background for a premium look.

There are two types:

### A. Container Group (Fixed)

A static, rounded container with a dark background. Best for "Settings" or "Farming" sections.

```lua
local FarmGroup = MainTab:CreateGroup({
    Name = "Auto Farm Config"
})
```

### B. Collapsible Group (Accordion)

A group that can be expanded or collapsed.

```lua
local AdvGroup = MainTab:CreateCollapsibleGroup({
    Title = "Advanced Settings",
    DefaultOpen = false -- Set to true to expand by default
})
```

---

## 6. Interface Elements

All elements below should be called on a **Group** object (e.g., `FarmGroup:CreateButton(...)`).

### Button

```lua
FarmGroup:CreateButton({
    Name = "Start Feature",
    Callback = function()
        print("Button Clicked")
    end
})
```

### Toggle

````lua
FarmGroup:CreateToggle({
    Name = "Enable Auto Farm",
    Default = false, -- Initial State
    Flag = "AutoFarm", -- Access via Window.Flags["AutoFarm"]
    Callback = function(Value)
        -- Value is boolean (true/false)
        print("Toggle is:", Value)
    end
})

#### Update Programmatically
```lua
local MyToggle = FarmGroup:CreateToggle({ ... })
MyToggle:Set(true) -- Turns it ON
````

````

### Slider

```lua
FarmGroup:CreateSlider({
    Name = "WalkSpeed",
    Min = 16,
    Max = 100,
    Default = 16,
    Flag = "WS",
    Callback = function(Value)
        -- Value is a number
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
    end
})

#### Update Programmatically
```lua
local MySlider = FarmGroup:CreateSlider({ ... })
MySlider:Set(50) -- Sets value to 50
````

````

### Input (Result Box)

```lua
FarmGroup:CreateInput({
    Name = "Target Player",
    PlaceholderText = "Enter Username...",
    RemoveTextAfterFocusLost = false, -- Set true to clear after enter
    Flag = "TargetName",
    Callback = function(Text)
        print("Input:", Text)
    end
})
````

### Dropdown

Supports Search and Multi-Select. opens in a modal.

````lua
FarmGroup:CreateDropdown({
    Name = "Select Weapon",
    Options = {"Sword", "Bow", "Staff", "Axe"},
    CurrentValue = "Sword", -- String for Single, Table for Multi (e.g. {"Sword"})
    Multi = false, -- Set true to allow picking multiple items
    Flag = "WeaponSelect",
    Callback = function(Option)
        -- Option: String (Single) or Table (Multi)
        print("Selected:", Option)
    end
})

#### Refresh Options / Set Value
```lua
local MyDropdown = FarmGroup:CreateDropdown({ ... })

-- Update the List of Options
MyDropdown:Refresh({"New Item A", "New Item B", "New Item C"})

-- Select a specific Option programmatically
MyDropdown:Set("New Item A")
````

````

### Color Picker

```lua
FarmGroup:CreateColorPicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(255, 0, 0),
    Flag = "ESPColor",
    Callback = function(Color)
        -- Color is a Color3 value
        print("New Color:", Color)
    end
})

#### Update Color
```lua
local MyCP = FarmGroup:CreateColorPicker({ ... })
MyCP:Set(Color3.fromRGB(0, 255, 0)) -- Sets color to Green
````

````

### Paragraph

Static text for information.

```lua
FarmGroup:CreateParagraph({
    Title = "Status",
    Content = "Waiting for User..."
})
````

Update a paragraph later:

```lua
local MyPara = FarmGroup:CreateParagraph({ Title = "Info", Content = "..." })
MyPara:Set({ Content = "New Status: Active" })
```

---

## 7. Utilities & Icons

You can use the built-in icon loader (Lucide Icons) using `GetIcon`.

### Getting an Icon Asset

```lua
-- Fetch the asset URI for a Lucide icon name
local HomeIcon = EnvielUI:GetIcon("home")
-- Returns: "rbxassetid://..." or similar
```

### Using Icons in Elements

Currently, icons are primarily used internally (Close, Minimize, Search), but you can use `GetIcon` if you are adding your own ImageLabels or extending the UI.

---

## 8. Notifications

Displays a notification at the bottom right.

```lua
Window:Notify({
    Title = "Alert",
    Content = "This is a notification message.",
    Duration = 3 -- Time in seconds before disappearing
})
```

---

## 9. Prompt (Alert Dialog)

Show a modal confirmation dialog.

```lua
Window:Prompt({
    Title = "Confirmation",
    Content = "Do you really want to delete this?",
    Actions = {
        {
            Text = "Cancel",
            Callback = function() print("Cancelled") end
        },
        {
            Text = "Confirm",
            Callback = function() print("Confirmed") end
        }
    }
})
```

---

## 10. Cleanup & Destructor

To ensure your script stops running when the UI is closed (e.g. stopping auto-farm loops), register a cleanup callback.

```lua
-- Example: Stopping a RenderStepped loop
local Connection = game:GetService("RunService").RenderStepped:Connect(function()
    print("Looping...")
end)

Window:OnClose(function()
    Connection:Disconnect()
    print("Cleaned up loop!")
end)
```
