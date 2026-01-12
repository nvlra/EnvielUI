--[[
    Fishit (Fisch) Automation Script
    Powered by EnvielUI
    Created by Enviel
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

--// Load EnvielUI
local EnvielUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/nvlra/EnvielUI/main/EnvielUI.lua"))()
local Window -- Forward declaration for Notify calls

--// Configuration System
local Config = {
    AutoFish = false,
    AutoEquip = false,
    CastDelay = 0.5,
    ReelDelay = 0.5,
    AutoSell = false,
    AutoBuyBait = false,
    AutoUseTotem = false,
    AutoTrade = false,
    WalkSpeed = 16,
    JumpPower = 50,
    NoClip = false,
    WalkOnWater = false,
    DisableVFX = false,
    DisableAnim = false,
    DisableNotif = false,
    Theme = "Dark"
}

local FileName = "Fishit_Config.json"

local function SaveConfig()
    if writefile then
        writefile(FileName, HttpService:JSONEncode(Config))
        if Window then Window:Notify({Title = "Config", Description = "Settings saved successfully!", Icon = "save"}) end
    end
end

local function LoadConfig()
    if readfile and isfile and isfile(FileName) then
        local Success, Decoded = pcall(function() return HttpService:JSONDecode(readfile(FileName)) end)
        if Success then
            for k, v in pairs(Decoded) do
                Config[k] = v
            end
            if Window then Window:Notify({Title = "Config", Description = "Settings loaded!", Icon = "file-check"}) end
        end
    end
end

--// Game Data (Extracted from fishit.txt)
local Remotes = {
    Cast = "ReplicatedStorage.Packages._Index.sleitnick_net@0.2.0.net.RF/RequestFishingMinigameStarted", -- Assumed based on naming
    Reel = "ReplicatedStorage.Packages._Index.sleitnick_net@0.2.0.net.RE/FishingCompleted",
    SellAll = "ReplicatedStorage.Packages._Index.sleitnick_net@0.2.0.net.RF/SellAllItems",
    PlayVFX = "ReplicatedStorage.Packages._Index.sleitnick_net@0.2.0.net.RE/PlayVFX",
    NewFishNotif = "ReplicatedStorage.Packages._Index.sleitnick_net@0.2.0.net.RE/ObtainedNewFishNotification",
    PurchaseBait = "ReplicatedStorage.Packages._Index.sleitnick_net@0.2.0.net.RF/PurchaseBait",
    UseTotem = "ReplicatedStorage.Packages._Index.sleitnick_net@0.2.0.net.RE/SpawnTotem", -- Approximation
}

local Landmarks = {
    ["Likely Safe Spot"] = CFrame.new(-32.5, 7.0, 2767.4),
    ["Kohana Volcano"] = CFrame.new(-595.0, 396.7, 149.1),
    ["Crater Island"] = CFrame.new(1010.0, 252.0, 5078.5),
    ["Esoteric Depths"] = CFrame.new(1944.8, 393.6, 1371.4),
    ["Coral Reefs"] = CFrame.new(-3024.0, 337.8, 2195.6),
    ["Fisherman Island"] = CFrame.new(45.3, 252.6, 2987.1),
    ["Kohana"] = CFrame.new(-651.0, 208.7, 711.1),
    ["Pirate Cove"] = CFrame.new(3384.6, 313.6, 3378.4),
    ["Sacred Temple"] = CFrame.new(1532.2, 5.0, -638.0),
    ["Underground Cellar"] = CFrame.new(2113.1, -91.2, -736.7),
    ["Weather Machine"] = CFrame.new(-1523.7, 6.5, 1891.5),
    ["Sisyphus Statue"] = CFrame.new(-3763.4, -136.1, -1048.3),
    ["Treasure Room"] = CFrame.new(-3566.3, -279.1, -1600.6),
    ["Elevator"] = CFrame.new(2089.0, -28.9, 1356.3),
    ["Ancient Jungle"] = CFrame.new(1478.3, 427.6, -613.5),
    ["Lost Isle"] = CFrame.new(-3618.2, 240.8, -1317.5),
}

local BoatSpawns = {
    ["Ancient Jungle"] = CFrame.new(1268.0, -0.9, -119.2),
    ["Coral Reefs"] = CFrame.new(-2718.5, -0.9, 2163.8),
    ["Fisherman Island"] = CFrame.new(16.0, -0.3, 2698.0),
    ["Kohana"] = CFrame.new(-560.4, -0.9, 800.5),
    ["Pirate Cove"] = CFrame.new(3194.0, -0.9, 3583.0),
}

--// Utility Functions
local function GetRemote(path)
    local parts = string.split(path, ".")
    local current = game
    for _, part in ipairs(parts) do
        current = current:FindFirstChild(part)
        if not current then return nil end
    end
    return current
end

local function TeleportTo(cframe)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = cframe
    end
end

--// UI Creation
Window = EnvielUI:CreateWindow({
    Name = "Fishit | Enviel",
    Theme = Config.Theme,
    CloseCallback = function() SaveConfig() end
})

--// TAB 1: FARMING
local TabFarm = Window:CreateTab({ Name = "Farming", Icon = "fish" })
local GroupFish = TabFarm:CreateGroup({ Name = "Fishing Automation" })

GroupFish:CreateToggle({
    Name = "Auto Fishing",
    Flag = "AutoFish",
    Callback = function(val)
        Config.AutoFish = val
        if val then
            task.spawn(function()
                while Config.AutoFish do
                    -- Simple Loop: Click to Cast -> Wait -> Click to Reel (or Remote)
                    -- Note: Actual minigame logic is complex; this is a basic loop template
                    
                    if Config.AutoEquip then
                        for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
                            if tool:IsA("Tool") and (tool.Name:find("Rod") or tool.Name:find("Fishing")) then
                                Humanoid:EquipTool(tool)
                                break
                            end
                        end
                    end
                    
                    -- Simulate Click to Cast
                    VirtualUser:ClickButton1(Vector2.new(0,0))
                    
                    task.wait(Config.CastDelay)
                    
                    -- Assume Fishing Remote logic here for instant catch (Simplified)
                    -- In a real script, you'd hook the minigame GUI or Remote
                    
                    task.wait(Config.ReelDelay)
                end
            end)
        end
    end
})

GroupFish:CreateToggle({
    Name = "Auto Equip Rod",
    Flag = "AutoEquip",
    Callback = function(val) Config.AutoEquip = val end
})

GroupFish:CreateSlider({
    Name = "Cast Delay",
    Min = 0.1, Max = 5, Default = 0.5,
    Callback = function(val) Config.CastDelay = val end
})

GroupFish:CreateSlider({
    Name = "Reel Delay",
    Min = 0.1, Max = 5, Default = 0.5,
    Callback = function(val) Config.ReelDelay = val end
})

local GroupSell = TabFarm:CreateGroup({ Name = "Selling" })

local FishCountLabel = GroupSell:CreateParagraph({
    Title = "Inventory",
    Description = "Fish: 0 | Bones: 0"
})

-- Update Fish Count Loop
task.spawn(function()
    while task.wait(1) do
        local fish = 0
        -- Simple counting logic (Modify based on actual inventory path)
        if LocalPlayer:FindFirstChild("Backpack") then
            fish = #LocalPlayer.Backpack:GetChildren() 
        end
        FishCountLabel:Set({ Description = "Items in Backpack: " .. tostring(fish) })
    end
end)

GroupSell:CreateToggle({
    Name = "Auto Sell All",
    Flag = "AutoSell",
    Callback = function(val)
        Config.AutoSell = val
        if val then
            task.spawn(function()
                while Config.AutoSell do
                    local remote = GetRemote(Remotes.SellAll)
                    if remote then remote:InvokeServer() end
                    task.wait(5)
                end
            end)
        end
    end
})

GroupSell:CreateButton({
    Name = "Sell All Now",
    Callback = function()
        local remote = GetRemote(Remotes.SellAll)
        if remote then remote:InvokeServer() end
        Window:Notify({ Title = "Sold", Description = "Attempts to sell all items sent." })
    end
})

--// TAB 2: TELEPORTS
local TabTP = Window:CreateTab({ Name = "Teleport", Icon = "map-pin" })
local GroupLandmarks = TabTP:CreateGroup({ Name = "Landmarks" })

local LandmarkNames = {}
for k, _ in pairs(Landmarks) do table.insert(LandmarkNames, k) end
table.sort(LandmarkNames)

local SelectedLandmark = LandmarkNames[1]

GroupLandmarks:CreateDropdown({
    Name = "Select Landmark",
    Options = LandmarkNames,
    Default = SelectedLandmark,
    Callback = function(val) SelectedLandmark = val end
})

GroupLandmarks:CreateButton({
    Name = "Teleport to Landmark",
    Callback = function()
        if SelectedLandmark and Landmarks[SelectedLandmark] then
            TeleportTo(Landmarks[SelectedLandmark])
        end
    end
})

local GroupPlayers = TabTP:CreateGroup({ Name = "Players" })
local SelectedPlayer = nil

local function GetPlayerNames()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(names, p.Name) end
    end
    return names
end

local PlayerMultiDropdown = GroupPlayers:CreateDropdown({
    Name = "Select Player",
    Options = GetPlayerNames(),
    Callback = function(val) SelectedPlayer = val end
})

GroupPlayers:CreateButton({
    Name = "Refresh Players",
    Callback = function()
        PlayerMultiDropdown:Refresh(GetPlayerNames())
    end
})

GroupPlayers:CreateButton({
    Name = "Teleport to Player",
    Callback = function()
        if SelectedPlayer then
            local target = Players:FindFirstChild(SelectedPlayer)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                TeleportTo(target.Character.HumanoidRootPart.CFrame)
            end
        end
    end
})

local GroupCustomCoords = TabTP:CreateGroup({ Name = "Custom Coordinates" })
local CC_X, CC_Y, CC_Z = 0, 0, 0

GroupCustomCoords:CreateInput({
    Name = "X", Placeholder = "0",
    Callback = function(val) CC_X = tonumber(val) or 0 end
})
GroupCustomCoords:CreateInput({
    Name = "Y", Placeholder = "0",
    Callback = function(val) CC_Y = tonumber(val) or 0 end
})
GroupCustomCoords:CreateInput({
    Name = "Z", Placeholder = "0",
    Callback = function(val) CC_Z = tonumber(val) or 0 end
})

GroupCustomCoords:CreateButton({
    Name = "TP to Coords",
    Callback = function()
        TeleportTo(CFrame.new(CC_X, CC_Y, CC_Z))
    end
})

--// TAB 3: SHOP
local TabShop = Window:CreateTab({ Name = "Shop & Items", Icon = "shopping-cart" })
local GroupShop = TabShop:CreateGroup({ Name = "Automation" })

GroupShop:CreateToggle({
    Name = "Auto Buy Bait",
    Callback = function(val)
        Config.AutoBuyBait = val
        -- Logic placeholder
    end
})

GroupShop:CreateToggle({
    Name = "Auto Use Totem",
    Callback = function(val)
        Config.AutoUseTotem = val
        -- Logic placeholder
    end
})

--// TAB 4: MISC
local TabMisc = Window:CreateTab({ Name = "Misc", Icon = "settings-2" })
local GroupChar = TabMisc:CreateGroup({ Name = "Character" })

GroupChar:CreateSlider({
    Name = "WalkSpeed",
    Min = 16, Max = 200, Default = 16,
    Callback = function(val)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = val
        end
        Config.WalkSpeed = val
    end
})

GroupChar:CreateSlider({
    Name = "JumpPower",
    Min = 50, Max = 300, Default = 50,
    Callback = function(val)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.UseJumpPower = true
            LocalPlayer.Character.Humanoid.JumpPower = val
        end
        Config.JumpPower = val
    end
})

GroupChar:CreateToggle({
    Name = "Noclip",
    Callback = function(val)
        Config.NoClip = val
        local Run = game:GetService("RunService")
        local Stepped
        if val then
             Stepped = Run.Stepped:Connect(function()
                if not Config.NoClip then Stepped:Disconnect() return end
                if LocalPlayer.Character then
                    for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                        if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end
                    end
                end
            end)
        end
    end
})

local GroupVis = TabMisc:CreateGroup({ Name = "Effects" })

GroupVis:CreateToggle({
    Name = "Disable VFX",
    Callback = function(val)
        Config.DisableVFX = val
        -- Simple check to destroy known VFX paths or hook remote
    end
})

GroupVis:CreateToggle({
    Name = "Disable Notifications",
    Callback = function(val) Config.DisableNotif = val end
})

--// TAB 5: SETTINGS
local TabSettings = Window:CreateTab({ Name = "Settings", Icon = "cog" })
local GroupConfig = TabSettings:CreateGroup({ Name = "Configuration" })

GroupConfig:CreateDropdown({
    Name = "Theme",
    Options = {"Dark", "Light"},
    Default = Config.Theme,
    Callback = function(val)
        Window:SetTheme(val)
        Config.Theme = val
    end
})

local ConfigInput = GroupConfig:CreateInput({
    Name = "Config Data",
    Placeholder = "Exported config will appear here...",
    Callback = function(val) end
})

GroupConfig:CreateButton({
    Name = "Export Config (Copy)",
    Callback = function()
        local json = HttpService:JSONEncode(Config)
        ConfigInput:Set(json)
        if setclipboard then
            setclipboard(json)
            Window:Notify({Title = "Config", Description = "Copied to clipboard!", Icon = "copy"})
        else
            Window:Notify({Title = "Config", Description = "JSON generated. Copy it manually.", Icon = "file-code"})
        end
    end
})

GroupConfig:CreateButton({
    Name = "Import Config",
    Callback = function()
        -- Import logic would need to parse JSON and update all Config values
        -- And update UI (which requires capturing all UI elements).
        -- For now, we will just Load the saved file.
        LoadConfig() 
    end
})

GroupConfig:CreateButton({
    Name = "Save Config File",
    Callback = function() SaveConfig() end
})

local GroupCredits = TabSettings:CreateGroup({ Name = "Credits" })
GroupCredits:CreateParagraph({
    Title = "Developer",
    Description = "Script by Enviel\nUI Library by Enviel"
})

-- Load Config at start
LoadConfig()
Window:Notify({
    Title = "Enviel Script",
    Description = "Fishit Script Loaded Successfully!",
    Icon = "check"
})

return Window
