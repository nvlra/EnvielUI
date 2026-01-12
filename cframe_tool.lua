local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "CFrame Debugger | Rayfield",
   LoadingTitle = "Position Tools",
   LoadingSubtitle = "by Enviel",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil, 
      FileName = "CFrameTool"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink", 
      RememberJoins = true 
   },
   KeySystem = false, 
})

local Tab = Window:CreateTab("Main", 4483362458) -- Just a generic icon id or nil

local PosParagraph = Tab:CreateParagraph({Title = "Position", Content = "Waiting..."})
local CFParagraph = Tab:CreateParagraph({Title = "CFrame", Content = "Waiting..."})

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local LocationName = "Landmark"

Tab:CreateInput({
   Name = "Location Name",
   PlaceholderText = "e.g. Spawn, Shop",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      LocationName = Text
   end,
})

Tab:CreateButton({
   Name = "Copy CFrame (Formatted)",
   Callback = function()
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
         local cf = LocalPlayer.Character.HumanoidRootPart.CFrame
         local str = tostring(cf)
         -- Format: ["Name"] = CFrame.new(...)
         local formatted = string.format('["%s"] = CFrame.new(%s),', LocationName, str)
         setclipboard(formatted)
         Rayfield:Notify({
            Title = "Copied!",
            Content = formatted,
            Duration = 2.5,
            Image = 4483362458,
         })
      end
   end,
})

Tab:CreateButton({
   Name = "Copy Vector3",
   Callback = function()
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
         local pos = LocalPlayer.Character.HumanoidRootPart.Position
         local str = string.format("%.2f, %.2f, %.2f", pos.X, pos.Y, pos.Z)
         setclipboard("Vector3.new(" .. str .. ")")
         Rayfield:Notify({
            Title = "Copied!",
            Content = "Vector3 has been copied to clipboard.",
            Duration = 2.5,
            Image = 4483362458,
         })
      end
   end,
})

RunService.RenderStepped:Connect(function()
   if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
      local pos = LocalPlayer.Character.HumanoidRootPart.Position
      local cf = LocalPlayer.Character.HumanoidRootPart.CFrame
      
      PosParagraph:Set({Title = "Position", Content = string.format("X: %.2f, Y: %.2f, Z: %.2f", pos.X, pos.Y, pos.Z)})
      CFParagraph:Set({Title = "CFrame", Content = string.format("%.2f, %.2f, %.2f...", cf.X, cf.Y, cf.Z)})
   end
end)
