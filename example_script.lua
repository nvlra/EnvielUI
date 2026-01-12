print("Starting Script...")
print("[EnvielUI] Script starting...") -- Tanda script jalan
-- Load the Library
-- NOTE: URL "refs/heads/main" itu SALAH untuk raw.githubusercontent. Kita pakai "/main/" saja.
local LibraryURL = "https://raw.githubusercontent.com/nvlra/EnvielUI/refs/heads/main/EnvielUI.lua"
local EnvielUI = loadstring(game:HttpGet(LibraryURL))()

if EnvielUI.Version then
	print("[Check] Library Version:", EnvielUI.Version)
else
	warn("[Check] OLD VERSION DETECTED! CACHE STILL ACTIVE.")
end
print("[EnvielUI] Library loaded successfully!")

-- Create Window
local Window = EnvielUI.new():CreateWindow({
	Name = "Enviel UI Showcase",
	Theme = "Dark", -- "Dark" or "Light"
	Keybind = Enum.KeyCode.RightControl -- Toggle Key
})

-- [[ TAB: HOME ]]
local TabHome = Window:CreateTab({
	Name = "Dashboard",
	Icon = "layout-dashboard"
})

TabHome:CreateSection("Main Interaction")

TabHome:CreateParagraph({
	Title = "Welcome User",
	Content = " This is an example of a Paragraph element. It fits nicely for descriptions or changelogs."
})

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

TabHome:CreateButton({
	Name = "Test Notification",
	Callback = function()
		Window:Notify({
			Title = "Test Notification",
			Content = "This is how a notification looks like!",
			Duration = 3,
			Image = "bell"
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

TabSettings:CreateInput({
	Name = "Custom Webhook",
	PlaceholderText = "https://discord.com/api/...",
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
		print("Webhook URL set to:", Text)
	end
})

TabSettings:CreateDropdown({
	Name = "Select Team",
	Options = {"Red Team", "Blue Team", "Spectator"},
	CurrentValue = "Red Team",
	Callback = function(Option)
		print("Selected Team:", Option)
	end
})

TabSettings:CreateSection("Visuals")

TabSettings:CreateColorPicker({
	Name = "ESP Color",
	CurrentValue = Color3.fromRGB(255, 0, 0),
	Callback = function(Color)
		print("New Color:", Color)
	end
})

TabSettings:CreateKeybind({
	Name = "Toggle Menu Key",
	CurrentKeybind = Enum.KeyCode.RightControl,
	Callback = function(Key)
		print("New Keybind:", Key)
	end
})

TabSettings:CreateSection("Config Manager")

TabSettings:CreateButton({
	Name = "Save Config",
	Callback = function()
		Window.Instance:SaveConfig("ShowcaseConfig")
		Window:Notify({Title="System", Content="Config Saved!", Image="check"})
	end
})

TabSettings:CreateButton({
	Name = "Load Config",
	Callback = function()
		Window.Instance:LoadConfig("ShowcaseConfig")
		Window:Notify({Title="System", Content="Config Loaded!", Image="check"})
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
