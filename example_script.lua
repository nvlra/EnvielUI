-- Load the Library (Assumes EnvielUI.lua is in the same folder or workspace)
local EnvielUI = loadstring(readfile("EnvielUI.lua"))()

-- Create Window
local Window = EnvielUI.new():CreateWindow({
	Name = "Enviel UI Showcase",
	Theme = "Dark", -- "Dark" or "Light"
	Keybind = Enum.KeyCode.RightControl -- Toggle Key
})

-- [[ TAB: HOME ]]
local TabHome = Window:CreateTab({
	Name = "Dashboard",
	Icon = "layout-dashboard" -- Using Lucide Icon Name directly!
})

TabHome:CreateSection("Main Interaction")

TabHome:CreateButton({
	Name = "Kill All Enemies",
	Callback = function()
		Window:Notify({
			Title = "Action Triggered",
			Content = "Killed all enemies in radius!",
			Duration = 3,
			Image = "skull" -- Lucide Icon
		})
	end
})

TabHome:CreateToggle({
	Name = "Auto Farm",
	CurrentValue = false,
	Callback = function(Value)
		print("Auto Farm is now:", Value)
		if Value then
			Window:Notify({Title="System", Content="Auto Farm Enabled", Image="check"})
		else
			Window:Notify({Title="System", Content="Auto Farm Stopped", Image="x"})
		end
	end
})

TabHome:CreateSection("Character Stats")

TabHome:CreateSlider({
	Name = "WalkSpeed",
	Range = {16, 200},
	CurrentValue = 16,
	Callback = function(Value)
		if game.Players.LocalPlayer.Character then
			game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
		end
	end
})

TabHome:CreateSlider({
	Name = "JumpPower",
	Range = {50, 500},
	CurrentValue = 50,
	Callback = function(Value)
		if game.Players.LocalPlayer.Character then
			game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
		end
	end
})


-- [[ TAB: SETTINGS ]]
local TabSettings = Window:CreateTab({
	Name = "Settings",
	Icon = "settings"
})

TabSettings:CreateSection("Configuration")

TabSettings:CreateDropdown({
	Name = "Select Team",
	Options = {"Red Team", "Blue Team", "Spectator"},
	CurrentValue = "Red Team",
	Callback = function(Option)
		print("Selected Team:", Option)
	end
})

TabSettings:CreateInput({
	Name = "Webhook URL",
	PlaceholderText = "https://discord.com/api/...",
	Callback = function(Text)
		print("Webhook set to:", Text)
	end
})

TabSettings:CreateSection("Visuals")

TabSettings:CreateColorPicker({
	Name = "ESP Color",
	CurrentValue = Color3.fromRGB(255, 0, 0),
	Callback = function(Color)
		print("New Color:", Color)
		-- Example: workspace.Part.Color = Color
	end
})

TabSettings:CreateKeybind({
	Name = "Toggle Menu Key",
	CurrentKeybind = Enum.KeyCode.RightControl,
	Callback = function(Key)
		print("New Keybind:", Key)
	end
})


-- [[ TAB: INFO ]]
local TabInfo = Window:CreateTab({
	Name = "Information",
	Icon = "info"
})

TabInfo:CreateButton({
	Name = "Join Discord",
	Callback = function()
		print("Discord Invite Copied!")
		Window:Notify({Title="Discord", Content="Link copied to clipboard!", Duration=2})
	end
})

-- Initial Notification
Window:Notify({
	Title = "Welcome",
	Content = "Enviel UI loaded successfully!",
	Duration = 5,
	Image = "party-popper"
})
