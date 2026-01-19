local Players = game:GetService("Players")

-- Load Library
local LibraryUrl = "https://raw.githubusercontent.com/nvlra/EnvielUI/main/EnvielUI.lua?t="..os.time()
local LibraryContent = game:HttpGet(LibraryUrl)
local EnvielUI = loadstring(LibraryContent)()

local Window = EnvielUI:CreateWindow({
    Name = "EnvielUI Test Suite"
})

-- // Tab 1: Short Content (Test Dynamic Shrink) //
local ShortTab = Window:CreateTab("Short")
ShortTab:CreateSection("Dynamic Sizing Test")
ShortTab:CreateParagraph({Title = "Instructions", Content = "This window should be small, fitting only this content."})
ShortTab:CreateButton({Name = "Values Check", Callback = function() 
    print("Window Config:", Window.Theme.Main)
end})

-- // Tab 2: Long Content (Test Max Height + Scroll) //
local LongTab = Window:CreateTab("Long")
LongTab:CreateSection("Scroll Test")
LongTab:CreateParagraph({Title = "Scroll Check", Content = "This tab should expand to max height and enable scrolling."})

for i = 1, 15 do
    LongTab:CreateButton({Name = "Scroll Item " .. i, Callback = function() end})
end

-- // Tab 3: Components (Test All UI Elements) //
local CompTab = Window:CreateTab("Components")
local MainGroup = CompTab:CreateGroup({ Name = "Input Elements" })

MainGroup:CreateToggle({
    Name = "Test Toggle",
    Flag = "TestToggle",
    Callback = function(v) print("Toggle:", v) end
})

MainGroup:CreateSlider({
    Name = "Test Slider",
    Min = 0, Max = 100, Default = 50,
    Callback = function(v) print("Slider:", v) end
})

MainGroup:CreateInput({
    Name = "Test Input",
    Placeholder = "Type something...",
    Callback = function(v) print("Input:", v) end
})

local DropdownGroup = CompTab:CreateGroup({ Name = "Dropdowns" })

DropdownGroup:CreateDropdown({
    Name = "Single Select",
    Options = {"Option A", "Option B", "Option C"},
    Default = "Option A",
    Callback = function(v) print("Single:", v) end
})

DropdownGroup:CreateDropdown({
    Name = "Multi Select",
    Options = {"Red", "Green", "Blue", "Yellow", "Purple", "Orange", "Pink", "Black", "White", "Gray", "Brown", "Cyan", "Magenta", "Yellow", "Blue", "Green"},
    Multi = true,
    Default = {"Red"},
    Callback = function(v) print("Multi:", table.concat(v, ", ")) end
})

local OtherGroup = CompTab:CreateGroup({ Name = "Others" })

OtherGroup:CreateColorPicker({
    Name = "Accent Color",
    Default = Color3.fromRGB(255, 100, 100),
    Callback = function(v) print("Color:", v) end
})

OtherGroup:CreateButton({
    Name = "Test Alert / Prompt",
    Callback = function()
        Window:Prompt({
            Title = "Confirmation",
            Content = "Do you confirm this action?",
            Actions = {
                {Text = "Yes", Callback = function() print("Confirmed") end},
                {Text = "No", Callback = function() print("Cancelled") end}
            }
        })
    end
})


local AdvGroup = CompTab:CreateGroup({ Name = "Advanced Features" })

local UpdatePara = AdvGroup:CreateParagraph({
    Title = "Status",
    Content = "Waiting for update..."
})

AdvGroup:CreateButton({
    Name = "Test Paragraph :Set()",
    Callback = function()
        UpdatePara:Set({
            Title = "Updated!",
            Content = "This paragraph was updated at " .. os.date("%X")
        })
    end
})

local RefreshDrop = AdvGroup:CreateDropdown({
    Name = "Refreshable List",
    Options = {"Item A", "Item B"},
    Default = "Item A",
    Callback = function(v) print("Refreshed Dropdown:", v) end
})

AdvGroup:CreateButton({
    Name = "Test Dropdown :Refresh()",
    Callback = function()
        RefreshDrop:Refresh({
            "New Item 1",
            "New Item 2",
            "New Item 3",
            "Random " .. math.random(1, 100)
        })
    end
})

AdvGroup:CreateSection("Config System")

AdvGroup:CreateButton({
    Name = "Save Config",
    Callback = function() Window:SaveConfig() end
})

AdvGroup:CreateButton({
    Name = "Load Config",
    Callback = function() Window:LoadConfig() end
})

-- // Cleanup Test //
Window:OnClose(function()
    print("EnvielUI Closed! Cleanup successful.")
end)

Window:Notify({
    Title = "Test Loaded",
    Description = "EnvielUI Test UI Ready.",
    Icon = "check"
})