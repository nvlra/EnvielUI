-- EnvielUI Optimization Test Script
local Enviel = loadstring(game:HttpGet("https://raw.githubusercontent.com/nvlra/EnvielUI/main/EnvielUI.lua"))()

local Window = Enviel.new({
	Name = "Optimization Test",
	Theme = "Dark"
})

local Tab1 = Window:CreateTab({Name = "Main Features"})
local Section = Tab1:CreateSection("Performance Tests")

-- Test Theme Switching (Theme Registry)
Tab1:CreateButton({
	Name = "Random Theme Speed Test",
	Callback = function()
		-- Quickly switch themes to test performance
		local themes = {"Dark", "Light"} 
		-- You can add more custom themes here if defined
		local randomTheme = themes[math.random(1, #themes)]
		local start = os.clock()
		Window:SetTheme(randomTheme)
		print("Theme switched to " .. randomTheme .. " in " .. (os.clock() - start) .. "s")
	end
})

-- Test Tween Pooling
Tab1:CreateButton({
	Name = "Spam Tweens",
	Callback = function()
		print("Hover over this button rapidly to test Tween Manager rejection")
	end
})

-- Test Dragify Optimization
Tab1:CreateParagraph({
	Title = "Drag Test",
	Content = "Drag the window around. Check inputs in Dex or Spy. InputChanged events should mostly be quiet when NOT dragging."
})

-- Test Slider Optimization (RenderStepped)
Tab1:CreateSlider({
	Name = "Optimized Slider",
	Min = 0, Max = 100, Default = 50,
	Callback = function(val)
		-- Print only occasionally to not spam output, but logic runs
		if math.random() > 0.9 then print("Slider Value:", val) end
	end
})

-- Test Color Picker Optimization (RenderStepped)
Tab1:CreateColorPicker({
	Name = "Optimized Color Picker",
	Callback = function(col)
		-- Logic runs only when dragging
	end
})

-- Test Destroy Method (Memory Leak Cleanup)
Tab1:CreateButton({
	Name = "Destroy UI",
	Callback = function()
		Window:Destroy()
		print("UI Destroyed. Check memory usage.")
	end
})

-- Test Search Optimization (Large List)
local Tab2 = Window:CreateTab({Name = "Search Test", Icon = "search"})
Tab2:CreateSection("Search Stress Test")

for i = 1, 100 do
	Tab2:CreateButton({
		Name = "Searchable Item " .. i,
		Callback = function() print(i) end
	})
end
Tab2:CreateParagraph({
	Title = "Instructions",
	Content = "Type '10' in the search bar. Notice the smoothness due to debounce."
})


-- Test Validator (Uncomment to test warnings)
-- Tab1:CreateSlider({ Name = "Invalid", Min = 50, Max = 10 }) -- Should warn min > max logic (if impl) or just run
-- Tab1:CreateButton({ Name = "No Callback Config", Callback = "Not a function" }) -- Should warn

print("Optimization Test Script Loaded!")
