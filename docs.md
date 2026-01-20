# Enviel UI Documentation

A modern, lightweight Roblox UI library with support for both PC and mobile platforms. Features a clean design with smooth animations and comprehensive element support.

## Table of Contents

- [Installation](#installation)
- [Getting Started](#getting-started)
- [Window Management](#window-management)
- [Tabs](#tabs)
- [Elements](#elements)
  - [Section](#section)
  - [Group](#group)
  - [Paragraph](#paragraph)
  - [Button](#button)
  - [Toggle](#toggle)
  - [Slider](#slider)
  - [Input](#input)
  - [Dropdown](#dropdown)
  - [Color Picker](#color-picker)
  - [Collapsible Group](#collapsible-group)
- [Notifications](#notifications)
- [Prompts](#prompts)
- [Dropdown Modal](#dropdown-modal)
- [Configuration](#configuration)
- [Keyboard Shortcuts](#keyboard-shortcuts)
- [Advanced Features](#advanced-features)
- [Technical Details](#technical-details)
- [Library Configuration](#library-configuration)
- [Complete Example](#complete-example)
- [Notes](#notes)

---

## Installation

Load the library in your script:

```lua
local EnvielUI = loadstring(game:HttpGet("your-library-url-here"))()
```

---

## Getting Started

### Creating a Window

The window is the main container for your UI. Create one using:

```lua
local Window = EnvielUI:CreateWindow({
    Name = "My Script Hub",
    Transparency = 0.1
})
```

**Parameters:**

- `Name` (string): The title displayed in the header
- `Transparency` (number, optional): Window transparency from 0 to 1. Default: 0.1
- `Theme` (table, optional): Custom color theme. Default: LibraryConfig.Colors

**Example with custom theme:**

```lua
local Window = EnvielUI:CreateWindow({
    Name = "Custom Hub",
    Theme = {
        Main = Color3.fromHex("1A1A1A"),
        Accent = Color3.fromHex("FF6B6B")
    }
})
```

---

## Window Management

### Window Methods

#### Toggle Window

```lua
Window:Toggle()
```

Toggles the window visibility. Users can also press Right Control to toggle.

````
#### Notifications

Display a notification to the user:

```lua
Window:Notify({
    Title = "Success",
    Content = "Operation completed successfully",
    Duration = 5
})
````

### Stats Bar & Minimization

The library features a smart minimization system with a built-in performance monitor.

1.  **Minimize**: Clicking the minimize button (next to Close) hides the main window and shows the **Stats Bar**.
2.  **Stats Bar**: Displays real-time performance metrics at the top of the screen.
    - **PING**: Real server latency (Color coded: Green < 30ms, Yellow < 70ms, Red > 70ms).
    - **CPU**: Frame Render Time in milliseconds (Syncs with Ping color logic).
    - **FPS**: True visual FPS (calculated using Harmonic Mean for accuracy).
3.  **Mini Icon**: Closing the Stats Bar shrinks it into a small, draggable logo icon. Clicking this icon restores the Main Window.

_Note: The Stats Bar is optimized for both Desktop and Mobile, with automatic positioning and battery-saving loops._

**Parameters:**

- `Title` (string): Notification header
- `Content` (string): Notification message
- `Duration` (number, optional): How long to display in seconds. Default: 3

#### Save Configuration

```lua
Window:SaveConfig()
```

Saves all flagged values to a JSON file.

#### Load Configuration

```lua
Window:LoadConfig()
```

Loads previously saved configuration values.

#### On Close Callback

Execute code when the window is closed:

```lua
Window:OnClose(function()
    print("Window was closed")
    -- Cleanup code here
end)
```

---

## Tabs

Tabs organize your UI into separate pages. They appear in a dock at the bottom of the window.

### Creating a Tab

```lua
local Tab = Window:CreateTab({
    Name = "Main",
    Selected = false
})
```

Or simply:

```lua
local Tab = Window:CreateTab("Main")
```

**Parameters:**

- `Name` (string): Tab label
- `Selected` (boolean, optional): Whether this tab should be selected by default

**Notes:**

- The first tab is automatically selected unless another tab has `Selected = true`
- Only one tab should have `Selected = true`

**Example with multiple tabs:**

```lua
local MainTab = Window:CreateTab("Main")
local SettingsTab = Window:CreateTab("Settings")
local CreditsTab = Window:CreateTab({
    Name = "Credits",
    Selected = false
})
```

---

## Elements

All elements are created on tabs. Elements can also be placed inside groups.

### Section

A text header to organize elements visually.

```lua
Tab:CreateSection("Combat Features")
```

**Parameters:**

- `Name` (string): Section title

You can also create sections inside groups:

```lua
local Group = Tab:CreateGroup("Settings")
Group:CreateSection("Subsection")
```

---

### Group

A container that groups related elements with a background.

```lua
local Group = Tab:CreateGroup("Player Options")
```

**Parameters:**

- `Name` (string, optional): Group title. Leave empty for no title.

**Usage:**

```lua
local Group = Tab:CreateGroup("Movement")

Group:CreateToggle({
    Name = "Speed Boost",
    Default = false,
    Callback = function(value)
        print("Speed boost:", value)
    end
})

Group:CreateSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 100,
    Default = 16,
    Callback = function(value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
})
```

**Available elements in groups:**

- CreateSection
- CreateParagraph
- CreateButton
- CreateToggle
- CreateSlider
- CreateInput
- CreateDropdown
- CreateColorPicker
- CreateCollapsibleGroup

---

### Paragraph

Displays informational text with a title and content.

```lua
Tab:CreateParagraph({
    Title = "Welcome",
    Content = "Thank you for using our script. Please read the instructions carefully."
})
```

**Parameters:**

- `Title` (string): Header text
- `Content` (string): Body text

**Methods:**

```lua
local Para = Tab:CreateParagraph({
    Title = "Status",
    Content = "Initializing..."
})

-- Update both title and content
Para:Set({
    Title = "Complete",
    Content = "All systems ready!"
})

-- Update only content
Para:Set({
    Content = "New message here"
})

-- Update only title
Para:Set({
    Title = "New Title"
})
```

---

### Button

A clickable button that executes code.

```lua
Tab:CreateButton({
    Name = "Execute Action",
    Callback = function()
        print("Button clicked!")
    end
})
```

**Parameters:**

- `Name` (string): Button label
- `Callback` (function): Function to execute on click

**Example:**

```lua
Tab:CreateButton({
    Name = "Teleport to Spawn",
    Callback = function()
        local player = game.Players.LocalPlayer
        if player.Character then
            player.Character:MoveTo(Vector3.new(0, 50, 0))
        end
    end
})
```

---

### Toggle

A switch that can be turned on or off.

```lua
Tab:CreateToggle({
    Name = "ESP",
    Default = false,
    Flag = "ESPEnabled",
    Callback = function(value)
        print("ESP is now:", value)
    end
})
```

**Parameters:**

- `Name` (string): Toggle label
- `Default` (boolean, optional): Initial state. Default: false
- `Flag` (string, optional): Key for saving/loading config
- `Callback` (function): Called when toggled

**Methods:**

```lua
local Toggle = Tab:CreateToggle({
    Name = "Auto Farm",
    Default = false
})

-- Set value programmatically
Toggle:Set(true)  -- Enable
Toggle:Set(false) -- Disable
```

**Toggle Switch Dimensions:**

- Switch: 44x22 pixels
- Circle: 18x18 pixels
- Off position: X=2
- On position: X=width-20

---

### Slider

A draggable slider for numeric values.

```lua
Tab:CreateSlider({
    Name = "FOV",
    Min = 70,
    Max = 120,
    Default = 90,
    Flag = "CameraFOV",
    Callback = function(value)
        workspace.CurrentCamera.FieldOfView = value
    end
})
```

**Parameters:**

- `Name` (string): Slider label
- `Min` (number): Minimum value
- `Max` (number): Maximum value
- `Default` (number, optional): Initial value. Default: Min
- `Flag` (string, optional): Key for saving/loading
- `Callback` (function): Called when value changes

**Methods:**

```lua
local Slider = Tab:CreateSlider({
    Name = "Volume",
    Min = 0,
    Max = 100,
    Default = 50
})

-- Set value
Slider:Set(75)
Slider:Set(0)   -- Minimum
Slider:Set(100) -- Maximum
```

---

### Input

A text input field.

```lua
Tab:CreateInput({
    Name = "Player Name",
    PlaceholderText = "Enter name...",
    RemoveTextAfterFocusLost = false,
    Flag = "TargetPlayer",
    Callback = function(text)
        print("Input value:", text)
    end
})
```

**Parameters:**

- `Name` (string): Input label
- `PlaceholderText` (string, optional): Placeholder text
- `RemoveTextAfterFocusLost` (boolean, optional): Clear input after unfocus
- `Flag` (string, optional): Key for saving/loading
- `Callback` (function): Called when focus is lost

**Input Behavior:**

- `ClearTextOnFocus = false` - Text is preserved when focused
- User must manually clear or type over existing text

**Methods:**

```lua
local Input = Tab:CreateInput({
    Name = "Custom Message",
    PlaceholderText = "Type here..."
})

-- Set value
Input:Set("Hello World")
Input:Set("")                -- Clear
Input:Set(tostring(123))     -- Number to string
```

**Example with number validation:**

```lua
Tab:CreateInput({
    Name = "Player ID",
    PlaceholderText = "123456",
    Callback = function(text)
        local id = tonumber(text)
        if id then
            print("Valid ID:", id)
        else
            print("Invalid number")
        end
    end
})
```

---

### Dropdown

A dropdown menu for selecting from multiple options.

```lua
Tab:CreateDropdown({
    Name = "Select Weapon",
    Options = {"Sword", "Bow", "Staff"},
    CurrentValue = "Sword",
    Flag = "SelectedWeapon",
    Callback = function(value)
        print("Selected:", value)
    end
})
```

**Parameters:**

- `Name` (string): Dropdown label
- `Options` (table): Array of option strings
- `CurrentValue` (string, optional): Initially selected option. Default: First option
- `Multi` (boolean, optional): Allow multiple selections. Default: false
- `Flag` (string, optional): Key for saving/loading
- `Callback` (function): Called when selection changes

**Multi-select example:**

```lua
Tab:CreateDropdown({
    Name = "Active Buffs",
    Options = {"Speed", "Jump", "Damage", "Defense"},
    Multi = true,
    CurrentValue = {},
    Callback = function(selected)
        print("Active buffs:", table.concat(selected, ", "))
    end
})
```

**Methods:**

```lua
local Dropdown = Tab:CreateDropdown({
    Name = "Game Mode",
    Options = {"Easy", "Normal", "Hard"}
})

-- Change selection
Dropdown:Set("Hard")
Dropdown:Set({"A", "C"})  -- Multi-select

-- Update options
Dropdown:Refresh({"Easy", "Normal", "Hard", "Expert"})
```

**Notes on Refresh:**

- Replaces entire options list
- Resets selection to first option (single mode)
- Clears selection (multi mode)
- Updates dropdown button text

**Text Truncation:**
Dropdown button uses `TextTruncate.AtEnd` to prevent overflow.

---

### Color Picker

A color selection interface with RGB sliders.

```lua
Tab:CreateColorPicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(255, 0, 0),
    Flag = "ESPColor",
    Callback = function(color)
        print("Color:", color)
    end
})
```

**Parameters:**

- `Name` (string): Color picker label
- `Default` (Color3, optional): Initial color. Default: Color3.fromRGB(255, 255, 255)
- `Flag` (string, optional): Key for saving/loading
- `Callback` (function): Called when color changes

**Methods:**

```lua
local ColorPicker = Tab:CreateColorPicker({
    Name = "Highlight Color",
    Default = Color3.new(1, 1, 1)
})

-- Set color
ColorPicker:Set(Color3.fromRGB(255, 0, 0))
ColorPicker:Set(Color3.fromHex("00FF00"))
ColorPicker:Set(Color3.new(0, 0, 1))
```

**Color Picker Mechanics:**

**Expandable design:**

- Closed: 42px height
- Expanded: 102px height (42 + 60 for sliders)
- Click header to toggle

**RGB Sliders:**

- Each slider: 6px tall track
- Full-width fill bar
- Colored by component (R=red, G=green, B=blue)
- Update preview in real-time
- 16px thumb with 2px stroke

**Slider Layout:**

- R slider at Y=0
- G slider at Y=20
- B slider at Y=40
- 20px vertical spacing

---

### Collapsible Group

A group that can be expanded or collapsed by clicking its header.

```lua
local CollapseGroup = Tab:CreateCollapsibleGroup({
    Title = "Advanced Settings",
    DefaultOpen = false
})

CollapseGroup:CreateToggle({
    Name = "Debug Mode",
    Default = false
})

CollapseGroup:CreateSlider({
    Name = "Render Distance",
    Min = 100,
    Max = 1000,
    Default = 500
})
```

**Parameters:**

- `Title` (string): Group header text
- `DefaultOpen` (boolean, optional): Whether group starts expanded. Default: false

**Available methods in collapsible groups:**

- All element creation methods except `CreateCollapsibleGroup` itself
- Same as regular groups
- Elements are automatically indented

---

## Notifications

Display temporary notifications to users.

```lua
Window:Notify({
    Title = "Achievement Unlocked",
    Content = "You found the secret area!",
    Duration = 5
})
```

**Parameters:**

- `Title` (string): Notification header
- `Content` (string): Notification message
- `Duration` (number, optional): Display duration in seconds. Default: 3

**Notification System Details:**

**Positioning & Size:**

- Top-right corner placement
- Width: 360px (PC) or 180px (Mobile)
- Auto-height based on content
- Minimum height: 70px (PC) or 50px (Mobile)

**Layout:**

- UIListLayout with bottom alignment
- Stacks vertically with 2px spacing
- Slide-in from right (1.5x offset)
- Auto-removes after duration
- Smooth Quint easing

**Visual Elements:**

- Rounded corners (16px radius)
- Accent color vertical bar (4px wide)
- Title in bold (16px)
- Content in regular font (13px)
- Semi-transparent background (0.05 transparency)

---

## Prompts

Display confirmation dialogs with custom actions.

```lua
Window:Prompt({
    Title = "Reset Progress",
    Content = "Are you sure you want to reset all progress? This cannot be undone.",
    Actions = {
        {
            Text = "Cancel",
            Callback = function()
                print("Cancelled")
            end
        },
        {
            Text = "Confirm",
            Primary = true,
            Callback = function()
                print("Progress reset")
                -- Reset code here
            end
        }
    }
})
```

**Parameters:**

- `Title` (string): Dialog title
- `Content` (string): Dialog message
- `Actions` (table): Array of action buttons

**Action properties:**

- `Text` (string): Button label
- `Primary` (boolean, optional): Makes button visually prominent
- `Callback` (function): Executed when clicked

**Prompt System Details:**

**Layout:**

- Modal overlay with 40% black background
- Alert frame: 300x160px
- Centered on screen
- Two-button layout with auto-spacing
- Buttons are 50% width each minus 6px gap

**Button Styling:**

- Primary button:
  - Filled background (Theme.Text)
  - Dark text (Theme.Main)
  - Full corner radius
- Secondary button:
  - Transparent background
  - Border stroke (Theme.Text, 1px)
  - Light text (Theme.Text)
  - Full corner radius

**Auto-detection:**
Primary is auto-applied if Text contains:

- "yes"
- "confirm"
- "ok"

---

## Dropdown Modal

The library includes a special modal system for dropdowns with search functionality.

### Opening Dropdown Modal

This is used internally by the `CreateDropdown` element, but you can also call it directly:

```lua
Window:OpenDropdownModal({
    Name = "Select Item",
    Options = {"Item 1", "Item 2", "Item 3", "Item 4"},
    Multi = false,
    CurrentValue = "Item 1"
}, function(selected)
    print("User selected:", selected)
end)
```

**Parameters:**

- `Name` (string): Modal title
- `Options` (table): Array of options
- `Multi` (boolean): Allow multiple selections
- `CurrentValue` (string or table): Current selection

**Dropdown Modal Details:**

**Size & Layout:**

- Width: 50% (PC) or 60% (Mobile)
- Dynamic height based on content
- Min height: 180px
- Max height: 70% of window (clamped to 180px minimum)
- Each option: 42px tall
- 12px padding between items

**Features:**

- Search bar with icon (16x16)
- Scrollable option list
- Selected items sorted to top (when not searching)
- Border stroke on selected items
- Different background colors for selected/unselected
- Close on outside click or X button
- Smooth animations

**Search Functionality:**

- Filters options in real-time
- Case-insensitive matching
- Updates list height dynamically
- Uses `string.find()` for matching

---

## Configuration

### Flags

Flags are used to save and load element values.

```lua
local Toggle = Tab:CreateToggle({
    Name = "Auto Collect",
    Flag = "AutoCollect",
    Default = true
})

-- Later, access the value
if Window.Flags.AutoCollect then
    print("Auto collect is enabled")
end

-- Set flag directly
Window.Flags.MyCustomFlag = "value"

-- Read flag
print(Window.Flags.MyCustomFlag)
```

### Saving and Loading

```lua
-- Save all flagged values
Window:SaveConfig()

-- Load previously saved values
Window:LoadConfig()
```

**File Handling:**

Configuration uses executor's filesystem:

- Requires: `writefile(name, data)`, `readfile(name)`, `isfile(name)`
- Format: JSON
- Naming: `WindowName_Config.json` (spaces removed from window name)
- Location: Executor's workspace folder

**SaveConfig:**

- Encodes `Window.Flags` table to JSON
- Writes to workspace folder
- Shows notification on success

**LoadConfig:**

- Checks if file exists with `isfile()`
- Reads and decodes JSON
- Merges into `Window.Flags`
- Shows notification (success or not found)

---

## Keyboard Shortcuts

The library includes built-in keyboard shortcuts:

### Toggle UI Visibility

Press **Right Control** to show/hide the entire UI.

```lua
-- This is handled automatically, but you can also toggle programmatically:
Window:Toggle()
```

**Behavior:**

- Hides/shows the entire ScreenGui
- Preserves UI state when hidden
- Works on both PC and mobile

---

## Advanced Features

### Custom Icons

The library supports Lucide icons loaded from GitHub.

```lua
-- Get icon URL
local iconUrl = Window:GetIcon("settings")
-- Returns Lucide icon URL or empty string if not found
```

**Common icons:**

- "user", "settings", "home", "search", "x", "check"
- "chevron-down", "minimize"

**Icon Fallbacks:**

If IconLib fails to load or icon not found:

- `GetIcon()` returns empty string `""`
- UI still functions, just without icon images

Common fallback asset IDs:

- X button: "6031094678"
- Search: "6031154871"
- Chevron down: "6031091004"

### Mobile Support

The library automatically detects mobile devices and adjusts.

**Mobile Detection:**

```lua
local IsMobile = workspace.CurrentCamera.ViewportSize.X < 800
```

Any viewport width under 800 pixels triggers mobile mode.

**Mobile Adjustments:**

- Smaller text sizes (10px vs 13px)
- Compact layouts
- Touch-optimized controls
- Responsive sizing
- Smaller window size (55% width vs fixed 650px)
- Reduced element heights (32px vs 42px)
- Compact header (34px vs 50px)
- Smaller nav dock (32px vs 44px)
- Auto-height with constraints
- Disabled hover effects
- Touch-optimized controls

### Theme Customization

Override default colors when creating a window:

```lua
local Window = EnvielUI:CreateWindow({
    Name = "Custom Theme",
    Theme = {
        Main = Color3.fromRGB(30, 30, 30),
        Secondary = Color3.fromRGB(20, 20, 20),
        Accent = Color3.fromRGB(100, 200, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextDark = Color3.fromRGB(150, 150, 150)
    }
})
```

**Available Theme Colors:**

- `Main`: Primary background
- `Secondary`: Secondary background (groups, inputs)
- `Stroke`: Border colors
- `Text`: Primary text color
- `TextDark`: Muted text color
- `Accent`: Accent color (highlights, active states)
- `Element`: Element backgrounds
- `ToggleActive`: Active toggle color
- `ToggleInactive`: Inactive toggle color
- `Input`: Input field background
- `Button`: Button background
- `ButtonText`: Button text color

### Minimize Feature

The UI includes a minimize button that collapses the window into a small floating button.

**Features:**

- Click minimize button (top-right, next to close)
- Window shrinks to a small circular button
- Button can be dragged anywhere on screen
- Click the button to restore the window
- Smooth scale animations

**Minimize Button:**

- Size: 45x45 pixels
- Positioned using `GuiService:GetGuiInset()` for safe area
- Position: SafeArea.X + 20, Y centered
- Draggable
- Shows Enviel logo

### Window Dragging

The header bar is draggable.

**Dragify Function:**
Applied automatically to:

- Window header (for moving window)
- Minimize button (for moving mini button)

**Features:**

- Click and hold the header
- Drag to move the window
- Works on both PC and mobile
- Smooth position tweening (0.05s)

### Auto-Resizing (Mobile)

On mobile devices, the window automatically resizes based on content.

**Features:**

- `AutomaticSize.Y` enabled
- Min height: 130px (mobile) / 320px (PC)
- Max height: 80% of screen or 450px
- Adjusts when switching tabs (0.4s animation)
- Content-aware sizing

**Size Constraints:**

- Mobile MainFrame: MinSize Y = 130, MaxSize Y = min(450, 80% of screen)
- PC MainFrame: Fixed 650x450
- Dock: MaxSize = 650px (PC) or 350px (Mobile)

### Tab Selection

Manually select a tab programmatically:

```lua
Window:SelectTab("Tab_Main")
```

**Tab ID Format:**

- Generated as `"Tab_" .. TabName:gsub(" ", "")`
- Example: "Main Menu" becomes "Tab_MainMenu"

**Behavior:**

- Switches to the specified tab
- Updates dock indicators and scrolls tab into view
- Auto-resizes window based on new tab content
- Smooth 0.4s Quint easing

### Safe Connections

Track connections that auto-cleanup on close:

```lua
Window:SafeConnect(workspace.ChildAdded, function(child)
    print("New child:", child.Name)
end)
```

**Benefits:**

- Automatically disconnected when window closes
- Prevents memory leaks
- Stored in `Window.Connections` table

**Used Internally For:**

- Input events (mouse, touch, keyboard)
- Property change signals
- Custom event handlers

### Transparency Control

Elements have different transparency based on location:

```lua
-- Elements in groups
InGroup = true: BackgroundTransparency = 1

-- Elements on tabs
InGroup = false: BackgroundTransparency = WindowTransparency (default 0.1)
```

### Splash Screen

The library shows a splash screen on load.

**Features:**

- Displays Enviel logo (150x150)
- 3-second display duration
- Fade in: 0.8s Sine easing
- Fade out: 0.5s Sine easing
- Auto-removed after display
- Smooth transition to main window

**Sequence:**

1. Logo fades in (0.8s)
2. Display for 3 seconds
3. Logo fades out (0.5s)
4. Removed, main window appears

### Element Styling

Elements automatically apply hover effects on PC:

**Hover-enabled elements:**

- Buttons
- Toggles (switch)
- Sliders (thumb)
- Input boxes
- Dropdown buttons
- Color picker preview

**Hover Effect:**
Uses `Lighten()` function:

```lua
-- Increases HSV value by 0.1
-- Smooth 0.2s transition
```

**Mobile behavior:**

- Hover effects disabled
- Touch-optimized interactions
- Larger touch targets

### Utility Functions

**Get Icon:**

```lua
local iconUrl = Window:GetIcon("icon-name")
```

**Select Tab:**

```lua
Window:SelectTab("Tab_Main")
```

### Internal Helper Functions

**Dragify**: Makes frames draggable
**Tween**: Smooth animations (default: 0.25s, Quart, Out)
**Lighten**: Brightens colors for hover (+0.1 HSV value)
**Validate**: Merges configs with defaults
**Create**: Helper for instance creation with properties

---

## Technical Details

### Corner Radius System

```lua
CornerRadius = {
    Window = 14,      -- Main window and major containers
    Group = 12,       -- Group containers
    Element = 8,      -- Standard elements
    Inner = 6         -- Inner elements (input boxes, dropdowns)
}
```

### AutomaticSize Usage

**Elements using AutomaticSize.Y:**

- Paragraphs (content text)
- Groups
- MainFrame (mobile only)
- Collapsible groups
- Notification content text

**Elements using AutomaticSize.X:**

- Window title text
- Tab buttons in dock
- "Made By Enviel" credit text

### Canvas Auto-Sizing

**Scrolling frames:**

- All tab pages: `AutomaticCanvasSize.Y`
- Dock list: Manual CanvasSize management
- Dropdown modal list: Manual calculation

### Z-Index Layering

```lua
0   - Active indicator (behind tabs)
2   - Tab buttons
9   - Patch frame (dropdown modal)
10  - Main dock, dropdown modal container
50  - Modal overlay
100 - Alert/Prompt overlay
```

### Button AutoButtonColor

All custom buttons use:

```lua
AutoButtonColor = false
```

This allows custom hover effects via Tween.

### Stroke Styling

**UIStroke thickness and colors:**

- MiniButton: 1px, Theme.Stroke
- Paragraph: 1px, Theme.TextDark (50% transparency)
- Input containers: 1px, Theme.Stroke
- Dropdown buttons: 1px, Theme.Stroke
- Selected dropdown items: 1px, Theme.Stroke
- Color picker thumbs: 2px, Theme.Secondary
- Prompt secondary buttons: 1px, Theme.Text

### Layout Orders

**Element sorting:**

- Tabs: Ordered by creation (TabIndex)
- Group title: LayoutOrder = -1 (always first)
- Decor folder in dock: Contains non-button elements
- All others: Default LayoutOrder = 0

### Enum Values Used

**ScrollingDirection:**

- Tab pages: Y-axis only
- Dock: X-axis only

**FillDirection:**

- Dock layout: Horizontal
- All others: Vertical

**TextXAlignment:**

- Left: Element labels, paragraphs
- Center: Buttons, notifications
- Right: Value labels, "Made By Enviel"

**EasingStyle:**

- Quart: Default for most animations
- Quint: Window scaling, tab switching, notifications
- Back: Minimize animation (In direction)
- Sine: Splash screen fade

### Event Connections

**Input events handled:**

- MouseButton1Click: Buttons, toggles
- MouseButton1Down: Sliders
- MouseEnter/Leave: Hover effects (PC only)
- InputBegan: Drag start, slider drag
- InputChanged: Drag update, slider update
- InputEnded: Drag/slide end
- FocusLost: Input boxes
- PropertyChanged: Text changes, AbsoluteContentSize

### Service Access

```lua
-- Uses cloneref if available for security
local function GetService(Name)
    return cloneref and cloneref(game:GetService(Name)) or game:GetService(Name)
end
```

**Services Used:**

- GuiService: GuiInset (safe area)
- TweenService: All animations
- UserInputService: Input handling
- RunService: Frame timing, RenderStepped
- Players: LocalPlayer access
- CoreGui: UI parent (fallback to PlayerGui)
- HttpService: JSON encode/decode, HttpGet
- Lighting: Blur effect (optional, not fully implemented)

### GuiService.GuiInset

Used for minimize button positioning:

```lua
local SafeArea = GuiService:GetGuiInset()
MiniButton.Position = UDim2.new(0, SafeArea.X + 20, 0.5, 0)
```

Accounts for mobile notches, camera cutouts, etc.

### Task Scheduling

**task.wait() usage:**

- 0.05: Before dragify (ensures frame loaded)
- 0.1: Dock update debounce
- 0.05: Tab content resize delay
- 0.2: Animation completion waits
- 3: Splash screen display time

**task.spawn() usage:**

- Non-blocking tab selection
- Splash screen animation
- Notification timers
- Layout updates
- Resize calculations

**task.delay() usage:**

- Notification auto-dismiss

### Scale Animations

**UIScale for zoom effects:**

**Main window:**

- Starts at scale 0.9
- Animates to 1.0 on show
- Uses Quint easing

**Minimize button:**

- Starts at scale 0
- Animates to 1.0 when shown
- Reverse on restore

**Button press feedback:**

- Scales to 0.95 on press (0.05s)
- Returns to 1.0 (0.1s Quint)

## Transparency Animations

### GroupTransparency for fade effects

**Applied to:**

- ContentWindow (main container)
- Dock (bottom tab bar)
- MiniButton (minimized state)
- AlertFrame (prompt dialogs)
- NotificationFrame (notifications)

**Timing:**

- Fade in: 0.2-0.4s
- Fade out: 0.15-0.2s
- Synchronized with scale/position

---

## Tab Dock System (Extended)

### Bottom dock features:

- Horizontal scrolling if tabs overflow
- Auto-width based on content
- Max width: 650px (PC) or MainFrame width (Mobile)
- Smooth scroll to active tab
- Active indicator slides between tabs
- Rounded pill shape (full corner radius)
- 4px padding on sides
- 10px gap between buttons

### Active Indicator:

- Full height minus 8px padding
- Matches active tab width
- Smooth Quint easing (0.4s)
- Accent color background
- Positioned at tab center
- Z-Index 0 (behind tabs)

### Auto-scroll behavior:

- Scrolls to center active tab in viewport
- Only scrolls if content exceeds dock width
- Smooth 0.4s Quint animation
- Uses CanvasPosition tween

### Dock Update System:

```lua
-- Queued update to prevent spam
local UpdateQueued = false

local function QueueDockUpdate()
    if UpdateQueued then return end
    UpdateQueued = true

    task.defer(function()
        task.wait(0.1)
        -- Calculate and update dock width
        -- Update canvas size if needed
        UpdateQueued = false
    end)
end
```

---

## Color Manipulation System

### Lighten Function

```lua
local function Lighten(Color, Amount)
    local H, S, V = Color:ToHSV()
    V = math.clamp(V + Amount, 0, 1)
    return Color3.fromHSV(H, S, V)
end
```

**Usage:**

- Hover effects: +0.1 brightness
- Applied on MouseEnter
- Reverted on MouseLeave
- 0.2s smooth transition

**Elements with hover:**

- Buttons: Window.Theme.Button → Lighten(Button, 0.1)
- Input containers: Window.Theme.Input → Lighten(Input, 0.1)
- Dropdown buttons: Window.Theme.Input → Lighten(Input, 0.1)
- Slider thumbs: Window.Theme.Accent → Lighten(Accent, 0.1)

---

## Create Helper Function

### Utility for instance creation

```lua
local function Create(className, properties)
    local inst = Instance.new(className)
    for i, v in pairs(properties) do
        inst[i] = v
    end
    return inst
end
```

**Examples:**

```lua
Create("Frame", {
    Parent = ScreenGui,
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.new(0, 0, 0)
})

Create("TextLabel", {
    Parent = Frame,
    Text = "Hello World",
    TextColor3 = Color3.new(1, 1, 1)
})
```

**Used throughout library for:**

- All GUI instances
- Clean, concise code
- Batch property setting

---

## Validate Configuration Function

### Merges configs with defaults

```lua
local function Validate(Config, Defaults)
    Config = Config or {}
    for k, v in pairs(Defaults) do
        if Config[k] == nil then
            Config[k] = v
        end
    end
    return Config
end
```

**Usage example:**

```lua
Config = Validate(Config, {
    Name = "Default Window",
    Transparency = 0.1,
    Theme = LibraryConfig.Colors
})
```

**Ensures:**

- All required parameters have values
- User config takes priority
- Missing values filled with defaults
- No nil errors

---

## Tween Function Wrapper

### Simplified tweening

```lua
local function Tween(instance, properties, duration, style, direction)
    local info = TweenInfo.new(
        duration or 0.25,
        style or Enum.EasingStyle.Quart,
        direction or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(instance, info, properties)
    tween:Play()
    return tween
end
```

**Default values:**

- Duration: 0.25 seconds
- EasingStyle: Quart
- EasingDirection: Out

**Common usages:**

```lua
-- Basic tween (uses defaults)
Tween(Frame, {BackgroundColor3 = Color3.new(1, 1, 1)})

-- Custom duration
Tween(Frame, {Size = UDim2.fromScale(1, 1)}, 0.5)

-- Custom easing
Tween(Frame, {Position = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
```

---

## Dragify System

### Makes frames draggable

```lua
local function Dragify(Frame, Parent)
    if not Frame then return end
    Parent = Parent or Frame
    local Dragging, DragInput, DragStart, StartPos

    local function Update(input)
        local Delta = input.Position - DragStart
        local Position = UDim2.new(
            StartPos.X.Scale, StartPos.X.Offset + Delta.X,
            StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y
        )
        TweenService:Create(Parent, TweenInfo.new(0.05), {Position = Position}):Play()
    end

    Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPos = Parent.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    Frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or
           input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            Update(input)
        end
    end)
end
```

**Features:**

- Smooth position tweening (0.05s)
- Supports mouse and touch
- Can drag different frame than moved frame
- Updates in real-time

**Applied to:**

- Window header → Moves MainFrame
- MiniButton → Moves MiniButton

---

## AddHover Helper Function

### Automatic hover effects (PC only)

```lua
local function AddHover(Obj, NormalColor)
    if IsMobile then return end
    if not Obj then return end

    Obj.MouseEnter:Connect(function()
        Tween(Obj, {BackgroundColor3 = Lighten(NormalColor, 0.1)}, 0.2)
    end)

    Obj.MouseLeave:Connect(function()
        Tween(Obj, {BackgroundColor3 = NormalColor}, 0.2)
    end)
end
```

**Usage:**

```lua
local Button = Create("TextButton", {
    BackgroundColor3 = Window.Theme.Button
})

AddHover(Button, Window.Theme.Button)
```

**Features:**

- Disabled on mobile
- +0.1 brightness on hover
- 0.2s smooth transition
- Automatic color restoration

---

## Parent Container Fallback

### Automatic parent detection

```lua
local Parent = game:GetService("CoreGui")
if not pcall(function() return Parent.Name end) then
    Parent = Players.LocalPlayer.PlayerGui
end
```

**Priority:**

1. CoreGui (preferred, hidden from player list)
2. PlayerGui (fallback if CoreGui blocked)

**Why CoreGui?**

- Hidden from F9 developer console
- More secure
- Professional appearance

**Why PlayerGui fallback?**

- Some executors block CoreGui access
- Ensures compatibility

---

## Service Cloning Protection

### CloneRef support

```lua
local function GetService(Name)
    return cloneref and cloneref(game:GetService(Name)) or game:GetService(Name)
end
```

**Purpose:**

- Protects against service detection
- Uses cloneref if executor supports it
- Falls back to normal GetService

**Services protected:**

- GuiService
- TweenService
- UserInputService
- RunService
- Players
- CoreGui
- HttpService

---

## Icon Loading System

### Lucide Icons integration

```lua
local IconLib
pcall(function()
    IconLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/Icons/main/Main-v2.lua"))()
    IconLib.SetIconsType("lucide")
end)

local function GetIcon(Name)
    if not Name then return nil end
    if Name:find("rbxassetid") then return Name end
    if not IconLib then return "" end

    local s, i = pcall(function() return IconLib.GetIcon(Name) end)
    return (s and i) or ""
end
```

**Features:**

- Loads from GitHub
- Uses Lucide icon set
- Returns empty string on failure
- Accepts direct asset IDs
- Safe pcall protection

**Common icons:**

- "x" - Close button
- "minimize" - Minimize button
- "search" - Search icon
- "chevron-down" - Dropdown arrow
- "user", "settings", "home"

---

## Window Close System

### Multi-callback support

```lua
Window.OnCloseCallbacks = {}

function Window:OnClose(Callback)
    if type(Callback) == "function" then
        table.insert(Window.OnCloseCallbacks, Callback)
    end
end

-- On close:
for _, cb in pairs(Window.OnCloseCallbacks) do
    task.spawn(cb)
end
```

**Features:**

- Multiple callbacks supported
- Executed on window close
- Non-blocking (task.spawn)
- Useful for cleanup

**Example:**

```lua
Window:OnClose(function()
    print("Saving data...")
    Window:SaveConfig()
end)

Window:OnClose(function()
    print("Disconnecting...")
    -- Disconnect your connections
end)
```

---

## Safe Connection System

### Auto-cleanup connections

```lua
Window.Connections = {}

function Window:SafeConnect(Signal, Callback)
    local Conn = Signal:Connect(Callback)
    table.insert(Window.Connections, Conn)
    return Conn
end

-- On close:
for _, c in pairs(Window.Connections) do
    c:Disconnect()
end
Window.Connections = {}
```

**Benefits:**

- Prevents memory leaks
- Automatic cleanup
- All connections stored centrally

**Example:**

```lua
Window:SafeConnect(workspace.ChildAdded, function(child)
    print("New child:", child.Name)
end)

Window:SafeConnect(game.Players.PlayerAdded, function(player)
    print("Player joined:", player.Name)
end)

-- Automatically disconnected when window closes
```

---

## Tab ID Generation

### Consistent tab naming

```lua
local TabId = "Tab_"..TabName:gsub(" ", "")
```

**Examples:**

- "Main" → "Tab_Main"
- "Main Menu" → "Tab_MainMenu"
- "Settings & Config" → "Tab_Settings&Config"

**Used for:**

- Internal tab identification
- SelectTab() method
- Page container naming
- Button naming

---

## Explicit Tab Selection

### HasExplicitSelection flag

```lua
Window.HasExplicitSelection = false

-- When creating tab:
local IsSelected = (type(Config) == "table" and Config.Selected)
if IsSelected then
    Window.HasExplicitSelection = true
end

-- Auto-select logic:
if TabIndex == 1 and Window.HasExplicitSelection and not IsSelected then
    return  -- Don't auto-select first tab
end
```

**Purpose:**

- Prevents first tab auto-selection if another tab is explicitly selected
- Allows user to control which tab shows first
- Only one tab should have `Selected = true`

---

## Mobile-Specific Adjustments

### Complete list of mobile changes

**Sizes:**

- Window: 55% width vs 650px fixed
- Header height: 34px vs 50px
- Nav height: 32px vs 44px
- Item height: 32px vs 42px
- Text size: 10px vs 13px
- Title size: 14px vs 18px
- Min height: 130px vs 320px

**Layout:**

- AutomaticSize.Y enabled
- Max height constraint: min(450, 80% screen)
- Notification width: 180px vs 360px
- Dock max width: 350px vs 650px

**Interactions:**

- Hover effects disabled
- Touch input optimized
- Larger touch targets
- No MouseEnter/Leave events

---

## Complete Event List

### All events used in library

**Mouse/Touch Events:**

- MouseButton1Click
- MouseButton1Down
- MouseEnter
- MouseLeave
- InputBegan
- InputChanged
- InputEnded

**Focus Events:**

- FocusLost (TextBox)

**Property Changes:**

- Text (TextBox search)
- AbsoluteContentSize (UIListLayout)

**Keyboard:**

- InputBegan (Right Control toggle)

---

## Animation Timing Reference

### Complete timing chart

**Window Animations:**

- Show: 0.5s Quint Out (scale 0.9 → 1.0)
- Hide: 0.2s Back In (scale 1.0 → 0)
- ContentWindow fade: 0.4s (opacity 1 → 0)
- Dock show: 0.5s Quint Out

**Element Animations:**

- Hover: 0.2s (color change)
- Toggle switch: 0.2s (position + color)
- Button press: 0.05s → 0.1s (scale 1.0 → 0.95 → 1.0)
- Slider thumb: Real-time (no tween during drag)

**Modal Animations:**

- Overlay fade in: 0.3s (transparency 1 → 0.4)
- Container slide: 0.4s Quint Out
- Close: 0.3s Quint In

**Notification:**

- Container expand: 0.3s Quint Out
- Slide in: 0.4s Quint Out
- Slide out: 0.4s Quint In
- Collapse: 0.3s Quint Out

**Tab Switching:**

- Indicator move: 0.4s Quint Out
- Text color: 0.3s
- Window resize: 0.4s Quint Out
- Dock scroll: 0.4s Quint Out

**Collapsible Group:**

- Expand/collapse: 0.3s Quart Out
- Arrow rotation: 0.2s

**Color Picker:**

- Expand/collapse: 0.2s

**Splash Screen:**

- Fade in: 0.8s Sine Out
- Display: 3s
- Fade out: 0.5s Sine Out

---

## File System Operations

### Save/Load implementation

**writefile usage:**

```lua
if writefile then
    writefile(Name, HttpService:JSONEncode(Data))
end
```

**readfile usage:**

```lua
if isfile and isfile(Name) then
    return HttpService:JSONDecode(readfile(Name))
end
```

**File naming:**

```lua
local ConfigName = Name:gsub(" ", "").."_Config.json"
-- "My Hub" → "MyHub_Config.json"
```

**Saved data structure:**

```json
{
    "FlagName1": "value",
    "FlagName2": true,
    "FlagName3": 50,
    "FlagName4": {"multi", "select"}
}
```

---

## Prompt Auto-Detection

### Primary button detection

```lua
local IsPrimary = Action.Primary or (
    Action.Text:lower() == "yes" or
    Action.Text:lower() == "confirm" or
    Action.Text:lower() == "ok"
)
```

**Triggers primary styling:**

- Explicitly set `Primary = true`
- Text is "yes" (case-insensitive)
- Text is "confirm"
- Text is "ok"

**Primary vs Secondary:**

Primary:

- Filled background (Theme.Text)
- Dark text (Theme.Main)
- More prominent

Secondary:

- Transparent background
- Border stroke
- Light text

---

## Dropdown Search Implementation

### Real-time filtering

```lua
SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
    Refresh(SearchInput.Text)
end)

local function Refresh(Query)
    for _, v in pairs(List:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end

    local filtered = {}
    for _, opt in pairs(Options) do
        if not Query or string.find(tostring(opt):lower(), Query:lower()) then
            table.insert(filtered, opt)
        end
    end

    -- Sort: selected first, then unselected
    -- Recreate buttons
    -- Update heights
end
```

**Features:**

- Case-insensitive search
- Real-time updates
- Selected items sorted to top (when not searching)
- Dynamic height adjustment

---

## Element Return Objects Summary

### All methods available

**Toggle:**

- `Toggle:Set(boolean)`

**Slider:**

- `Slider:Set(number)`

**Input:**

- `Input:Set(string)`

**Dropdown:**

- `Dropdown:Set(string or table)`
- `Dropdown:Refresh(table)`

**ColorPicker:**

- `ColorPicker:Set(Color3)`

**Paragraph:**

- `Paragraph:Set({Title = "...", Content = "..."})`

**Window:**

- `Window:Toggle()`
- `Window:Notify({...})`
- `Window:Prompt({...})`
- `Window:SaveConfig()`
- `Window:LoadConfig()`
- `Window:OnClose(function)`
- `Window:SelectTab(string)`
- `Window:GetIcon(string)`
- `Window:SafeConnect(signal, callback)`
- `Window:OpenDropdownModal({...}, callback)`
- `Window:CreateTab(config)`

**Tab:**

- `Tab:CreateSection(config)`
- `Tab:CreateGroup(config)`
- `Tab:CreateParagraph(config)`
- `Tab:CreateButton(config)`
- `Tab:CreateToggle(config)`
- `Tab:CreateSlider(config)`
- `Tab:CreateInput(config)`
- `Tab:CreateDropdown(config)`
- `Tab:CreateColorPicker(config)`
- `Tab:CreateCollapsibleGroup(config)`

---

## Complete Color Theme Reference

### All customizable colors

```lua
{
    Main = Color3.fromHex("2B2B2B"),           -- Primary background
    Secondary = Color3.fromHex("1D1D1D"),      -- Groups, inputs
    Stroke = Color3.fromHex("787878"),         -- Borders
    Text = Color3.fromHex("FFFFFF"),           -- Primary text
    TextDark = Color3.fromHex("888888"),       -- Muted text
    Accent = Color3.fromHex("FFFFFF"),         -- Highlights
    Element = Color3.fromHex("1D1D1D"),        -- Element backgrounds
    ToggleActive = Color3.fromHex("D4D4D4"),   -- Active toggle
    ToggleInactive = Color3.fromHex("676767"), -- Inactive toggle
    Input = Color3.fromHex("414141"),          -- Input background
    Button = Color3.fromHex("FFFFFF"),         -- Button background
    ButtonText = Color3.fromHex("000000")      -- Button text
}
```

**Usage locations:**

- Main: ContentWindow background
- Secondary: Groups, input containers, modal backgrounds
- Stroke: All borders (UIStroke)
- Text: All primary labels, tab buttons (active)
- TextDark: Placeholder text, inactive tabs, value labels
- Accent: Logo, active indicator, slider fill, toggle active
- Element: Group backgrounds
- ToggleActive: Active toggle background
- ToggleInactive: Inactive toggle background
- Input: Input field backgrounds, dropdown buttons
- Button: Button backgrounds
- ButtonText: Button text color

---

## Best Practices Extended

### Advanced tips

**Memory Management:**

```lua
-- Use SafeConnect for all event connections
Window:SafeConnect(signal, callback)

-- Use OnClose for cleanup
Window:OnClose(function()
    -- Cleanup code
end)
```

**Flag Naming:**

```lua
-- Good
Flag = "Player_WalkSpeed"
Flag = "ESP_Enabled"
Flag = "Combat_AutoParry"

-- Bad
Flag = "ws"
Flag = "enabled"
Flag = "setting1"
```

**Callback Optimization:**

```lua
-- Good
Callback = function(value)
    if value then
        EnableFeature()
    else
        DisableFeature()
    end
end

-- Bad
Callback = function(value)
    while value do
        task.wait()
        -- Expensive operation
    end
end
```

**Element Organization:**

```lua
-- Good structure
MainTab:CreateSection("Combat")
local CombatGroup = MainTab:CreateGroup("Auto Combat")
CombatGroup:CreateToggle({Name = "Auto Parry"})
CombatGroup:CreateSlider({Name = "Parry Distance"})

-- Bad structure
MainTab:CreateToggle({Name = "Auto Parry"})
MainTab:CreateToggle({Name = "Auto Block"})
MainTab:CreateToggle({Name = "Auto Dodge"})
-- ... 20 more toggles without organization
```

---

This supplement provides all the remaining technical details for the Enviel UI library.
