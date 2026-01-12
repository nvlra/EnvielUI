-- Enviel Universal Explorer & Dumper
-- Loads the EnvielUI library (Remote)
local EnvielUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/nvlra/EnvielUI/main/EnvielUI.lua?v=14"))()
local Window = EnvielUI:CreateWindow({
    Name = "Enviel Explorer",
    Theme = { -- Dark Theme
        Main = Color3.fromRGB(25, 25, 25),
        Secondary = Color3.fromRGB(35, 35, 35),
        Stroke = Color3.fromRGB(60, 60, 60),
        Divider = Color3.fromRGB(60, 60, 60),
        Text = Color3.fromRGB(240, 240, 240),
        TextSec = Color3.fromRGB(150, 150, 150),
        Accent = Color3.fromRGB(0, 150, 255),
        AccentText = Color3.fromRGB(255, 255, 255),
        Element = Color3.fromRGB(45, 45, 45)
    },
    CloseCallback = function() end
})

local Tab = Window:CreateTab({ Name = "Explorer", Icon = "folder" })
local GroupNav = Tab:CreateGroup({ Name = "Navigation" })

local CurrentFolder = game
local SelectedChildName = nil

-- UI Elements
local PathLabel = GroupNav:CreateParagraph({ Title = "Current Path", Content = "game" })
local ChildDropdown = nil

local function FormatName(obj)
    return obj.Name .. " [" .. obj.ClassName .. "]"
end

local function GetChildList()
    local list = {}
    local children = CurrentFolder:GetChildren()
    -- Sort: Folders/Services first, then A-Z
    table.sort(children, function(a, b)
        if a.ClassName ~= b.ClassName then
            return a.ClassName < b.ClassName
        end
        return a.Name < b.Name
    end)
    
    for _, c in ipairs(children) do
        table.insert(list, FormatName(c))
    end
    if #list == 0 then table.insert(list, "<Empty>") end
    return list
end

local function RefreshUI()
    PathLabel:Set({ Title = "Current Path", Content = CurrentFolder:GetFullName() })
    if ChildDropdown then
        ChildDropdown:Refresh(GetChildList())
    end
    SelectedChildName = nil
end

-- Child Selector
ChildDropdown = GroupNav:CreateDropdown({
    Name = "Select Child",
    Options = GetChildList(),
    Callback = function(val) 
        SelectedChildName = val 
    end
})

-- Navigation Buttons
GroupNav:CreateButton({
    Name = "Open Selected Folder/Object",
    ButtonText = "Open / Enter",
    Callback = function()
        if not SelectedChildName or SelectedChildName == "<Empty>" then return end
        
        -- Parse name back from "Name [Class]" matches
        -- We loop children to match formatted name to handle duplicate names correctly-ish
        local target = nil
        for _, c in ipairs(CurrentFolder:GetChildren()) do
            if FormatName(c) == SelectedChildName then
                target = c
                break
            end
        end
        
        if target then
            CurrentFolder = target
            RefreshUI()
        else
            print("Target not found/changed.")
        end
    end
})

GroupNav:CreateButton({
    Name = "Go Back / Up",
    ButtonText = "Back",
    Callback = function()
        if CurrentFolder ~= game then
            CurrentFolder = CurrentFolder.Parent or game
            RefreshUI()
        end
    end
})

GroupNav:CreateButton({
    Name = "Quick Dump Selected (Deep Copy)",
    ButtonText = "Dump Selected",
    Callback = function()
        if not SelectedChildName or SelectedChildName == "<Empty>" then return end
        
        -- Resolve target
        local target = nil
        for _, c in ipairs(CurrentFolder:GetChildren()) do
            if FormatName(c) == SelectedChildName then
                target = c
                break
            end
        end
        
        if target then
            local result = "=== Dump of " .. target:GetFullName() .. " ===\n"
            result = result .. DumpRecursively(target, 0)
            
            if setclipboard then
                setclipboard(result)
                if Window.Notify then Window:Notify({Title = "Dumped", Description = "Deep copy of '"..target.Name.."' to clipboard!", Icon = "copy"}) end
            else
                print(result)
            end
        else
            if Window.Notify then Window:Notify({Title = "Error", Description = "Target not found", Icon = "alert-triangle"}) end
        end
    end
})

-- Dumper Section
local GroupDump = Tab:CreateGroup({ Name = "Actions" })

local function DumpRecursively(root, level)
    local indent = string.rep("  ", level)
    local output = indent .. FormatName(root)
    
    -- Try to dump script source if possible
    if root:IsA("LocalScript") or root:IsA("ModuleScript") then
        local src = nil
        -- Standard executor functions
        if decompile then
             pcall(function() src = decompile(root) end)
        end
        if not src and getscriptbytecode then
             src = "-- Source Hidden (Decompile failed or unavailable)"
        end
        
        if src then
            output = output .. " -- [HAS SOURCE]\n"
            -- Add source with wrapper for readability
            output = output .. indent .. "-- [[ SOURCE START: " .. root.Name .. " ]]\n"
            
            -- Indent the source lines for tree structure consistency (optional, but good for reading)
            -- But pure copy-paste might be better. Let's just wrap it.
            output = output .. src .. "\n"
            output = output .. indent .. "-- [[ SOURCE END ]]"
        end
    elseif root:IsA("RemoteEvent") or root:IsA("RemoteFunction") then
        output = output .. " -- [REMOTE]"
    end
    
    output = output .. "\n"
    
    local children = root:GetChildren()
    for _, c in ipairs(children) do
        output = output .. DumpRecursively(c, level + 1)
    end
    
    return output
end

local DumpAllBtn = GroupDump:CreateButton({
    Name = "Dump EVERYTHING (Logic & Remotes)",
    ButtonText = "Dump All",
    Callback = function()
        if DumpAllBtn then DumpAllBtn:SetText("Scanning...") end
        if task then task.wait(0.1) end -- Let UI update
        
        local services = {}
        
        -- 1. Scan Game Services (Excluding Heavy/Protected)
        local blocked = {
            ["Workspace"] = true,
            ["CoreGui"] = true,
            ["CorePackages"] = true,
            ["NetworkClient"] = true,
            ["Stats"] = true,
            ["SoundService"] = true,
            ["LogService"] = true
        }
        
        for _, s in ipairs(game:GetChildren()) do
            if not blocked[s.Name] then
                table.insert(services, s)
            end
        end
        
        -- 2. Add Player Specifics (Crucial for Logic)
        local lp = game:GetService("Players").LocalPlayer
        if lp then
            if lp:FindFirstChild("PlayerGui") then table.insert(services, lp.PlayerGui) end
            if lp:FindFirstChild("Backpack") then table.insert(services, lp.Backpack) end
            if lp.Character then table.insert(services, lp.Character) end
        end
        
        if DumpAllBtn then DumpAllBtn:SetText("Compiling...") end
        if task then task.wait(0.1) end
        
        local result = "=== Enviel Smart Dump (ALL) ===\n" ..
                       "-- Time: " .. os.date("%X") .. "\n" ..
                       "-- Map: " .. game.PlaceId .. "\n\n"
        
        for _, srv in ipairs(services) do
            if srv then
                result = result .. DumpRecursively(srv, 0)
                result = result .. "\n"
            end
        end
        
        if setclipboard then
            setclipboard(result)
            if Window.Notify then Window:Notify({Title = "Dumped Everything", Description = "Size: " .. #result .. " chars", Icon = "copy"}) end
        else
            print("Clipboard missing. Check console.")
            print(result)
        end
        
        if DumpAllBtn then DumpAllBtn:SetText("Dump All") end
    end
})

GroupDump:CreateButton({
    Name = "Dump Current Folder (Recursive)",
    ButtonText = "Copy Tree",
    Callback = function()
        local result = "=== Dump of " .. CurrentFolder:GetFullName() .. " ===\n"
        result = result .. DumpRecursively(CurrentFolder, 0)
        
        if setclipboard then
            setclipboard(result)
            if Window.Notify then Window:Notify({Title = "Dumped", Description = "Structure copied to clipboard!", Icon = "copy"}) end
        else
            print(result)
            if Window.Notify then Window:Notify({Title = "Dumped", Description = "Check Console (F9)", Icon = "terminal"}) end
        end
    end
})

GroupDump:CreateButton({
    Name = "Copy Instance Path",
    ButtonText = "Copy Path",
    Callback = function()
        if setclipboard then
            setclipboard(CurrentFolder:GetFullName())
             if Window.Notify then Window:Notify({Title = "Copied", Description = "path copied!", Icon = "copy"}) end
        end
    end
})
