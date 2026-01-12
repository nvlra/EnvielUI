--[[ 
	ENVIEL UI LIBRARY - COMBINED TEST SCRIPT 
	Copy ALL of this into your executor.
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

--------------------------------------------------------------------------------
-- LIBRARY SOURCE CODE
--------------------------------------------------------------------------------
local EnvielUI = {}
EnvielUI.__index = EnvielUI

-- Themes (Updated with your Colors)
local Themes = {
	Dark = {
		Main = Color3.fromHex("1A1A1A"),
		Secondary = Color3.fromHex("1D1D1D"),
		Stroke = Color3.fromHex("333333"),
		Text = Color3.fromHex("FFFFFF"),
		TextSec = Color3.fromHex("888888"),
		Accent = Color3.fromHex("FFDE25"),
		AccentText = Color3.fromHex("1A1A1A"), 
	},
	Light = {
		Main = Color3.fromHex("FFFFFF"),
		Secondary = Color3.fromHex("DDDDDD"),
		Stroke = Color3.fromHex("E0E0E0"),
		Text = Color3.fromHex("333333"),
		TextSec = Color3.fromHex("666666"),
		Accent = Color3.fromHex("A78F0A"),
		AccentText = Color3.fromHex("FFFFFF"),
	}
}

-- Utility
local function Create(msg, prop)
	local inst = Instance.new(msg)
	for i, v in pairs(prop) do
		inst[i] = v
	end
	return inst
end

local function Tween(instance, properties, duration, style, direction)
	local info = TweenInfo.new(
		duration or 0.3, 
		style or Enum.EasingStyle.Quart, 
		direction or Enum.EasingDirection.Out
	)
	local tween = TweenService:Create(instance, info, properties)
	tween:Play()
	return tween
end

function EnvielUI.new()
	local self = setmetatable({}, EnvielUI)
	self.Theme = Themes.Dark
	return self
end

function EnvielUI:CreateWindow(Config)
	local WindowName = Config.Name or "Enviel UI"
	local Theme = Config.Theme or "Dark"
	
	if Themes[Theme] then self.Theme = Themes[Theme] end
	
	-- Safe Parent Logic: Try CoreGui, fallback to PlayerGui
	local Success, ParentTarget = pcall(function()
		return CoreGui
	end)
	
	if not Success or not ParentTarget then
		ParentTarget = Players.LocalPlayer:WaitForChild("PlayerGui")
	end
	
	-- Cleanup Old UI
	if ParentTarget:FindFirstChild("EnvielLibrary") then
		ParentTarget.EnvielLibrary:Destroy()
	end
	
	-- Main Layout
	local ScreenGui = Create("ScreenGui", {
		Name = "EnvielLibrary",
		Parent = ParentTarget,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		ResetOnSpawn = false
	})
	
	local MainFrame = Create("Frame", {
		Name = "MainFrame",
		Parent = ScreenGui,
		BackgroundColor3 = self.Theme.Main,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, -350, 0.5, -225),
		Size = UDim2.new(0, 0, 0, 0), -- Start small for animation
		ClipsDescendants = true
	})
	
	-- Opening Animation
	Tween(MainFrame, {Size = UDim2.new(0, 700, 0, 450)}, 0.5, Enum.EasingStyle.Back)
	
	Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 16)})
	Create("UIStroke", {
		Parent = MainFrame, 
		Color = self.Theme.Stroke, 
		Thickness = 1,
		Transparency = 0.5
	})
	
	-- Smooth Drag Function
	local function Dragify(Frame, DragObject)
		local Dragging, DragInput, DragStart, StartPos
		local DragTarget = DragObject or Frame
		
		local function Update(input)
			local Delta = input.Position - DragStart
			local TargetPos = UDim2.new(
				StartPos.X.Scale, 
				StartPos.X.Offset + Delta.X, 
				StartPos.Y.Scale, 
				StartPos.Y.Offset + Delta.Y
			)
			-- Smooth Tween
			local DragTween = TweenService:Create(Frame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = TargetPos})
			DragTween:Play()
		end
		
		DragTarget.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				Dragging = true
				DragStart = input.Position
				StartPos = Frame.Position
				
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						Dragging = false
					end
				end)
			end
		end)
		
		DragTarget.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				DragInput = input
			end
		end)
		
		UserInputService.InputChanged:Connect(function(input)
			if input == DragInput and Dragging then
				Update(input)
			end
		end)
	end
	
	-- Apply Drag to MainFrame
	-- We apply it to MainFrame but we can also treat the whole frame as the handle
	Dragify(MainFrame)
	
	-- Header
	local Header = Create("Frame", {
		Name = "Header",
		Parent = MainFrame,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 50)
	})
	
	local Title = Create("TextLabel", {
		Name = "Title",
		Parent = Header,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 24, 0, 0),
		Size = UDim2.new(1, -48, 1, 0),
		Font = Enum.Font.GothamBold,
		Text = WindowName,
		TextColor3 = self.Theme.Accent,
		TextSize = 18,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	
	-- State Variables
	local Minimized = false
	local OpenSize = UDim2.new(0, 700, 0, 450)
	
	-- Toggle Key Logic
	local ToggleKey = Config.Keybind or Enum.KeyCode.RightControl
	
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and input.KeyCode == ToggleKey then
			if ScreenGui.Enabled then
				-- Closing
				if not Minimized then
					Tween(MainFrame, {Size = UDim2.new(0,0,0,0)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In).Completed:Wait()
				end
				ScreenGui.Enabled = false
			else
				-- Opening
				ScreenGui.Enabled = true
				if not Minimized then
					MainFrame.Size = UDim2.new(0,0,0,0)
					Tween(MainFrame, {Size = OpenSize}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
				end
			end
		end
	end)

	-- Header Controls
	local Controls = Create("Frame", {
		Name = "Controls",
		Parent = Header,
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -70, 0, 0),
		Size = UDim2.new(0, 60, 1, 0)
	})
	
	local CloseBtn = Create("TextButton", {
		Parent = Controls,
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -30, 0, 10),
		Size = UDim2.new(0, 30, 0, 30),
		Text = "X",
		TextColor3 = self.Theme.TextSec,
		Font = Enum.Font.GothamBold,
		TextSize = 14
	})
	
	local MinBtn = Create("TextButton", {
		Parent = Controls,
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -60, 0, 10),
		Size = UDim2.new(0, 30, 0, 30),
		Text = "-",
		TextColor3 = self.Theme.TextSec,
		Font = Enum.Font.GothamBold,
		TextSize = 18
	})

	-- Open/Minimize Button (The floating icon)
	local OpenBtn = Create("ImageButton", {
		Name = "OpenButton",
		Parent = ScreenGui,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 30, 0.5, -25), -- Default center-left or custom
		Size = UDim2.new(0, 50, 0, 50),
		Image = "rbxassetid://4483345998", -- Replace with your logo
		Visible = false,
		AutoButtonColor = false
	})
	
	-- Optional: Add a corner or stroke to the icon if it's not a transparent png
	Create("UICorner", {Parent = OpenBtn, CornerRadius = UDim.new(0, 12)})
	-- Make the open button draggable
	Dragify(OpenBtn)

	-- Close (Hide) Logic
	CloseBtn.MouseButton1Click:Connect(function()
		Tween(MainFrame, {Size = UDim2.new(0,0,0,0)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In).Completed:Wait()
		ScreenGui.Enabled = false
	end)
	
	-- Minimize Logic
	local function ToggleMinimize()
		Minimized = not Minimized
		if Minimized then
			-- Switch to Icon Mode
			Tween(MainFrame, {Size = UDim2.new(0,0,0,0)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In).Completed:Wait()
			MainFrame.Visible = false
			OpenBtn.Visible = true
			OpenBtn.Size = UDim2.new(0, 0, 0, 0)
			Tween(OpenBtn, {Size = UDim2.new(0, 50, 0, 50)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		else
			-- Restore Window
			OpenBtn.Visible = false
			MainFrame.Visible = true
			Tween(MainFrame, {Size = OpenSize}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		end
	end
	
	MinBtn.MouseButton1Click:Connect(ToggleMinimize)
	OpenBtn.MouseButton1Click:Connect(ToggleMinimize)

	-- Content
	local ContentContainer = Create("Frame", {
		Name = "Content",
		Parent = MainFrame,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 60),
		Size = UDim2.new(1, 0, 1, -60)
	})
	
	local Sidebar = Create("ScrollingFrame", {
		Name = "Sidebar",
		Parent = ContentContainer,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 20, 0, 0),
		Size = UDim2.new(0, 160, 1, -20),
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(0,0,0,0)
	})
	
	Create("UIListLayout", {
		Parent = Sidebar,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder
	})
	
	local Pages = Create("Frame", {
		Name = "Pages",
		Parent = ContentContainer,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 200, 0, 0),
		Size = UDim2.new(1, -220, 1, -20)
	})
	
	local Window = {
		Tabs = {},
		Instance = self
	}
	
	-- Internal Selection Logic
	-- Function to get Lucide Icons (Placeholder for now)
	-- You can upload icons yourself or find IDs on the Roblox heavy toolbox.
	-- Recommended: Search "Lucide Icons" in Toolbox > Images.
	
	function Window:SelectTab(TabId)
		for _, page in pairs(Pages:GetChildren()) do
			if page:IsA("ScrollingFrame") then page.Visible = false end
		end
		for _, btn in pairs(Sidebar:GetChildren()) do
			if btn:IsA("TextButton") then
				-- Inactive State
				Tween(btn, {BackgroundTransparency = 1, TextTransparency = 0.6}, 0.3)
				-- Reset Font to Normal
				btn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
			end
		end
		
		if Pages:FindFirstChild(TabId) then Pages[TabId].Visible = true end
		if Sidebar:FindFirstChild(TabId.."Btn") then
			local btn = Sidebar[TabId.."Btn"]
			-- Active State
			Tween(btn, {BackgroundTransparency = 0.85, TextTransparency = 0}, 0.3)
			-- Animated Font Weight Change (Workaround: Just set it)
			btn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
		end
	end
	
	function Window:CreateTab(Config)
		local Name = Config.Name or "Tab"
		local Icon = Config.Icon or "" 
		local TabId = "Tab"..tostring(#Window.Tabs + 1)
		
		local TabBtn = Create("TextButton", {
			Name = TabId.."Btn",
			Parent = Sidebar,
			BackgroundColor3 = self.Instance.Theme.Accent,
			BackgroundTransparency = 1, -- Invisible default
			Size = UDim2.new(1, 0, 0, 36),
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
			Text = "       "..Name,
			TextColor3 = self.Instance.Theme.Accent,
			TextSize = 13, -- Slightly smaller for elegance
			TextTransparency = 0.6,
			TextXAlignment = Enum.TextXAlignment.Left,
			AutoButtonColor = false
		})
		Create("UICorner", {Parent = TabBtn, CornerRadius = UDim.new(0, 8)})
		
		if Icon ~= "" then
			local Ico = Create("ImageLabel", {
				Parent = TabBtn,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0.5, -8),
				Size = UDim2.new(0, 16, 0, 16),
				Image = Icon,
				ImageColor3 = self.Instance.Theme.Accent
			})
		end
		
		TabBtn.MouseButton1Click:Connect(function() Window:SelectTab(TabId) end)
		
		local Page = Create("ScrollingFrame", {
			Name = TabId,
			Parent = Pages,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = self.Instance.Theme.Accent,
			Visible = false,
			CanvasSize = UDim2.new(0,0,0,0)
		})
		Create("UIListLayout", {Parent = Page, Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder})
		Create("UIPadding", {Parent = Page, PaddingBottom = UDim.new(0,10), PaddingTop = UDim.new(0,2), PaddingRight = UDim.new(0,10)})
		
		Page.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			Page.CanvasSize = UDim2.new(0, 0, 0, Page.UIListLayout.AbsoluteContentSize.Y + 20)
		end)
		
		if #Window.Tabs == 0 then Window:SelectTab(TabId) end
		table.insert(Window.Tabs, TabId)
		
		local Elements = {}
		
		function Elements:CreateButton(Config)
			local Name = Config.Name or "Button"
			local Callback = Config.Callback or function() end
			
			local Frame = Create("Frame", {
				Parent = Page,
				BackgroundColor3 = self.Instance.Theme.Secondary,
				Size = UDim2.new(1, 0, 0, 42), -- Compact height
				BackgroundTransparency = 0  -- Solid for better contrast
			})
			Create("UICorner", {Parent = Frame, CornerRadius = UDim.new(0, 8)})
			Create("UIStroke", {Parent = Frame, Color = self.Instance.Theme.Stroke, Thickness = 1, Transparency = 0.5})

			Create("TextLabel", {
				Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0,15,0,0), Size = UDim2.new(1,-120,1,0),
				FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
				Text = Name, TextColor3 = self.Instance.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
			})
			
			local Btn = Create("TextButton", {
				Parent = Frame, BackgroundColor3 = self.Instance.Theme.Accent, Position = UDim2.new(1,-105,0.5,-13), Size = UDim2.new(0,90,0,26),
				FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
				Text = "Interact", TextColor3 = self.Instance.Theme.AccentText, TextSize = 11, AutoButtonColor = false
			})
			Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(0, 6)})
			
			Btn.MouseButton1Click:Connect(function()
				Tween(Btn, {Size = UDim2.new(0,85,0,24)}, 0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.In).Completed:Wait()
				Tween(Btn, {Size = UDim2.new(0,90,0,26)}, 0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
				Callback()
			end)
		end
		
		function Elements:CreateToggle(Config)
			local Name = Config.Name or "Toggle"
			local Default = Config.CurrentValue or false
			local Callback = Config.Callback or function() end
			local Value = Default
			
			local Frame = Create("Frame", {
				Parent = Page, BackgroundColor3 = self.Instance.Theme.Secondary, Size = UDim2.new(1,0,0,46), BackgroundTransparency = 0.5
			})
			Create("UICorner", {Parent = Frame, CornerRadius = UDim.new(0,8)})
			Create("TextLabel", {
				Parent = Frame, BackgroundTransparency=1, Position=UDim2.new(0,15,0,0), Size=UDim2.new(1,-70,1,0),
				Font=Enum.Font.GothamMedium, Text=Name, TextColor3=self.Instance.Theme.Text, TextSize=14, TextXAlignment=Enum.TextXAlignment.Left
			})
			local Switch = Create("TextButton", {
				Parent=Frame, BackgroundColor3=Value and self.Instance.Theme.Accent or self.Instance.Theme.Stroke,
				Position=UDim2.new(1,-55,0.5,-12), Size=UDim2.new(0,44,0,24), Text="", AutoButtonColor=false
			})
			Create("UICorner", {Parent=Switch, CornerRadius=UDim.new(0,12)})
			local Circle = Create("Frame", {
				Parent=Switch, BackgroundColor3=self.Instance.Theme.Main,
				Position=Value and UDim2.new(1,-22,0.5,-9) or UDim2.new(0,2,0.5,-9), Size=UDim2.new(0,18,0,18)
			})
			Create("UICorner", {Parent=Circle, CornerRadius=UDim.new(1,0)})
			Switch.MouseButton1Click:Connect(function()
				Value = not Value
				Callback(Value)
				Tween(Switch, {BackgroundColor3=Value and self.Instance.Theme.Accent or self.Instance.Theme.Stroke}, 0.2)
				Tween(Circle, {Position=Value and UDim2.new(1,-22,0.5,-9) or UDim2.new(0,2,0.5,-9)}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
			end)
		end
		
		return Elements
	end
	return Window
end

--------------------------------------------------------------------------------
-- EXAMPLE USAGE (Bagian ini yang kita pake buat ngetes)
--------------------------------------------------------------------------------

local Window = EnvielUI.new():CreateWindow({
	Name = "Enviel UI Debug",
	Theme = "Dark"
})

local Tab1 = Window:CreateTab({
	Name = "Main"
})

Tab1:CreateToggle({
	Name = "Test Toggle",
	CurrentValue = true,
	Callback = function(v)
		print("Toggle is now:", v)
	end
})

Tab1:CreateButton({
	Name = "Click Me",
	Callback = function()
		print("Button Clicked!")
	end
})
