-- EnvielUI Showcase Script
-- Loads the latest version from GitHub

local EnvielUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/nvlra/EnvielUI/main/EnvielUI.lua?v="..tostring(os.time())))()

-- 1. Create Window
local Window = EnvielUI.new():CreateWindow({
    Name = "Enviel Showcase",
    Theme = "Dark", -- Default Theme
    Icon = "rbxassetid://12345678" -- Optional
})

-- 2. Create Tabs
local MainTab = Window:CreateTab({ Name = "Dashboard", Icon = "layout-dashboard" })
local CombatTab = Window:CreateTab({ Name = "Combat", Icon = "swords" })
local SettingsTab = Window:CreateTab({ Name = "Settings", Icon = "settings" })

-- 3. Main Dashboard (Group System)
local InfoGroup = MainTab:CreateGroup({ Title = "Information" })

InfoGroup:CreateButton({
    Name = "Send Notification",
    Callback = function()
        Window:Notify({
            Title = "Hello User!",
            Content = "This is a toast notification.",
            Duration = 3,
            Image = "bell" -- Lucide Icon Name
        })
    end
})

InfoGroup:CreateButton({
    Name = "Test Alert (Prompt)",
    Callback = function()
        Window:Prompt({
            Title = "DANGER ZONE",
            Content = "Do you really want to nuke the server?",
            Actions = {
                {
                    Text = "Yes, Nuke It",
                    Callback = function() 
                        Window:Notify({Title = "Boom!", Content = "Server nuked (fake).", Duration = 2})
                    end
                },
                {
                    Text = "Cancel",
                    Callback = function() 
                        print("Cancelled nuke.")
                    end
                }
            }
        })
    end
})

-- 4. Combat Tab (Interactions)
local FarmSection = CombatTab:CreateSection("Auto Farming")

CombatTab:CreateToggle({
    Name = "Auto Loop Kill",
    Default = false,
    Callback = function(Value)
        print("Loop Kill:", Value)
    end
})

CombatTab:CreateSlider({
    Name = "Attack Range",
    Min = 1, Max = 100, Default = 15,
    Callback = function(Value)
        print("Range set to:", Value)
    end
})

CombatTab:CreateDropdown({
    Name = "Weapon Select",
    Options = {"Sword", "Bow", "Magic Staff", "Dagger"},
    Default = "Sword",
    Callback = function(Value)
        print("Equipped:", Value)
    end
})

CombatTab:CreateInput({
    Name = "Kill Message",
    Placeholder = "Enter text...",
    Callback = function(Text)
        print("Message set:", Text)
    end
})

CombatTab:CreateColorPicker({
    Name = "ESP Color",
    CurrentValue = Color3.fromRGB(255, 0, 0),
    Callback = function(Color)
        print("Color:", Color)
    end
})

CombatTab:CreateKeybind({
    Name = "Aimbot Key",
    CurrentKey = Enum.KeyCode.E,
    HoldToInteract = true,
    Callback = function(Key)
        print("Keybind set to:", Key.Name)
    end
})

-- 5. Information Tab (Text Display)
local InfoSection = MainTab:CreateSection("Documentation")

MainTab:CreateParagraph({
    Title = "What is this?",
    Content = "This is a comprehensive showcase of EnvielUI features.\nIt includes every component available available in v1.0."
})
local UISection = SettingsTab:CreateSection("UI Customization")

SettingsTab:CreateDropdown({
    Name = "Theme",
    Options = {"Dark", "Light"},
    Default = "Dark",
    Callback = function(Value)
        Window:SetTheme(Value)
        Window:Notify({Title = "Theme Changed", Content = "Switched to " .. Value .. " Mode.", Duration = 2})
    end
})

SettingsTab:CreateButton({
    Name = "Unload UI",
    Callback = function()
        -- Logic to destroy UI would go here if supported
        Window:Notify({Title = "Unload", Content = "Unloading interface...", Duration = 2})
    end
})

-- 6. Initialize Watermark
Window:Watermark({
    Title = "Enviel UI", -- Text is hardcoded in lib, but calling this enables it
    Enabled = true
})

print("Showcase Loaded!")
