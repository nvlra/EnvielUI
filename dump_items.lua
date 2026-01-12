local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Item Dumper",
   LoadingTitle = "Enviel Item Scanner",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false,
})

local Tab = Window:CreateTab("Scanner", 4483362458)

local LogParagraph = Tab:CreateParagraph({Title = "Scan Results", Content = "Click Scan to start..."})
local ScannedContent = ""

Tab:CreateButton({
    Name = "Scan for Items (Tools)",
    Callback = function()
        local items = {}
        local text = "--- BACKPACK ---\n"
        
        -- Scan Backpack
        if game.Players.LocalPlayer then
             for _, v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                 if v:IsA("Tool") then
                     table.insert(items, v.Name)
                     text = text .. "[Owned] " .. v.Name .. "\n"
                 end
             end
        end
        
        text = text .. "\n--- REPLICATED STORAGE (Guess) ---\n"
        -- Try to find common Item folders
        local folders = {"Items", "Tools", "Assets", "Storage"}
        for _, name in pairs(folders) do
            local f = game:GetService("ReplicatedStorage"):FindFirstChild(name)
            if f then
                text = text .. "Found Folder: " .. name .. "\n"
                for _, item in pairs(f:GetChildren()) do
                    text = text .. item.Name .. " (" .. item.ClassName .. ")\n"
                end
            end
        end
        
        ScannedContent = text
        LogParagraph:Set({Title = "Scan Complete", Content = text})
        print(text)
    end
})

Tab:CreateButton({
   Name = "Copy Results",
   Callback = function()
      if setclipboard then
          setclipboard(ScannedContent)
          Rayfield:Notify({Title = "Copied", Content = "Results copied to clipboard!", Duration = 3})
      end
   end
})
