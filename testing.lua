local EnvielUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/nvlra/EnvielUI/main/EnvielUI.lua"))()

local Window = EnvielUI.new():CreateWindow({
	Name = "Enviel Dock Test",
	Theme = "Dark", -- or "Light"
	Width = 450,
	NoSidebar = false -- Ensure Navbar is shown
})

-- Tab 1: Home (Test Standard Elements)
local HomeTab = Window:CreateTab({
	Name = "Home",
	Icon = "home" -- Lucide Icon Name
})

local HomeSection = HomeTab:CreateSection("Dashboard")

HomeTab:CreateButton({
	Name = "Test Button",
	Callback = function()
		print("Button Pressed")
	end
})

HomeTab:CreateToggle({
	Name = "Enable Feature",
	Flag = "FeatureToggle",
	Callback = function(Value)
		print("Toggle:", Value)
	end
})

-- Tab 2: Player (Test Scrolling & Layout)
local PlayerTab = Window:CreateTab({
	Name = "Player",
	Icon = "user"
})

PlayerTab:CreateSlider({
	Name = "WalkSpeed",
	Min = 16,
	Max = 500,
	Default = 16,
	Callback = function(Value)
		print("WalkSpeed:", Value)
	end
})

-- Tab 3: Combat (Test More Tabs)
local CombatTab = Window:CreateTab({
	Name = "Combat",
	Icon = "sword"
})

CombatTab:CreateDropdown({
	Name = "Target Mode",
	Options = {"Nearest", "Lowest Health", "Mouse"},
	Default = "Nearest",
	Callback = function(Value)
		print("Target:", Value)
	end
})

-- Adding extra tabs to force Horizontal Scroll on the Dock
Window:CreateTab({ Name = "Visuals", Icon = "eye" })
Window:CreateTab({ Name = "World", Icon = "globe" })
Window:CreateTab({ Name = "Misc", Icon = "box" })
Window:CreateTab({ Name = "Settings", Icon = "settings" })
Window:CreateTab({ Name = "Credits", Icon = "info" })

-- Notification Test
Window:Notify({
	Title = "System Ready",
	Content = "Dock Navigation Loaded Successfully!",
	Duration = 5
})
