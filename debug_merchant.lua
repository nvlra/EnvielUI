-- Enviel Debugger: Merchant & Weather (Log to File)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local LogBuffer = {}
local function Log(msg)
    print(msg)
    table.insert(LogBuffer, "[" .. os.date("%X") .. "] " .. msg)
end

local function FindRemoteRecursively(root, name)
    return root:FindFirstChild(name, true)
end

local function GetRemote(path)
    if not path or path == "" then return nil end
    local parts = string.split(path, "/") 
    local current = game
    local valid = true
    for _, part in ipairs(parts) do
        current = current:FindFirstChild(part)
        if not current then valid = false break end
    end
    if valid then return current end

    -- Smart Find
    local name = parts[#parts]
    Log("Direct path failed for " .. name .. ". Smart searching...")
    local found = FindRemoteRecursively(ReplicatedStorage, name)
    if found then 
        Log("Smart Found: " .. found:GetFullName())
        return found
    end
    return nil
end

local Remotes = {
    BuyWeather = "ReplicatedStorage/Packages/_Index/sleitnick_net@0.2.0/net/RF/PurchaseWeatherEvent",
}

Log("=== Enviel Debug Start ===")

-- 1. Test Weather
local start = tick()
local weatherRemote = GetRemote(Remotes.BuyWeather)
Log("Weather Scan Time: " .. (tick() - start) .. "s")

if weatherRemote then
    Log("[SUCCESS] Weather Remote Ready.")
else
    Log("[FAIL] Weather Remote Totally Missing.")
    -- Dump RFs
    Log("--- Dump of RFs in RepStorage ---")
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteFunction") and v.Name:match("Purchase") then
            Log("Candidate: " .. v:GetFullName())
        end
    end
end

-- 2. Dump Merchant
Log("--- Merchant Dump ---")
local gui = LocalPlayer.PlayerGui:FindFirstChild("Merchant") or LocalPlayer.PlayerGui:FindFirstChild("MerchantGui")
if gui then
    local container = nil
    for _, v in pairs(gui:GetDescendants()) do
        if v:IsA("UIGridLayout") then container = v.Parent break end
    end
    
    if container then
        local children = container:GetChildren()
        local count = 0
        local firstItem = nil
        for _, c in pairs(children) do
            if c:IsA("Frame") or c:IsA("ImageLabel") then
                count = count + 1
                if not firstItem then firstItem = c end
            end
        end
        Log("Found " .. count .. " items.")
        
        if firstItem then
            Log("Testing Recursive Search on First Item:")
            local nameLabel = firstItem:FindFirstChild("ItemName", true)
            if nameLabel then
                Log("[SUCCESS] Recursive Search Found 'ItemName': " .. nameLabel.Text)
            else
                Log("[FAIL] Recursive Search 'ItemName' NOT FOUND")
                Log("Dumping Descendants:")
                for _, d in pairs(firstItem:GetDescendants()) do
                    if d:IsA("TextLabel") then
                        Log(" > " .. d.Name .. " [" .. d.Text .. "]")
                    end
                end
            end
        end
    else
        Log("[FAIL] No Grid Container")
    end
else
    Log("[FAIL] No Merchant GUI")
end

Log("=== Enviel Debug End ===")

-- Write to clipboard (User Request)
pcall(function()
    if setclipboard then
        setclipboard(table.concat(LogBuffer, "\n"))
        print("Log copied to clipboard!")
    else
        print("Clipboard not supported, printing to console.")
    end
end)
