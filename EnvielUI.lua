local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local EnvielUI = {}
EnvielUI.__index = EnvielUI

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


local IconLib = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Footagesus/Icons/main/Main-v2.lua"))()
IconLib.SetIconsType("lucide") -- Default to Lucide

local function GetIcon(Name)
	if not Name or Name == "" then return "" end
	-- If it's already an asset ID, return it
	if string.find(Name, "rbxassetid://") then return Name end
	-- Try to get from library (Lucide/Geist)
	local Success, Icon = pcall(function() return IconLib.GetIcon(Name) end)
	if Success and Icon then return Icon end
	return "" -- Return empty if not found
end

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

function EnvielUI.new()
	local self = setmetatable({}, EnvielUI)
	self.Theme = Themes.Dark -- Default
	return self
end

function EnvielUI:CreateWindow(Config)
	local WindowName = Config.Name or "Enviel UI"
	local Theme = Config.Theme or "Dark"
	
	if Themes[Theme] then self.Theme = Themes[Theme] end
	

	local Success, ParentTarget = pcall(function() return CoreGui end)
	if not Success or not ParentTarget then
		ParentTarget = Players.LocalPlayer:WaitForChild("PlayerGui")
	end
	

	if ParentTarget:FindFirstChild("EnvielLibrary") then
		ParentTarget.EnvielLibrary:Destroy()
	end
	

	local ScreenGui = Create("ScreenGui", {
		Name = "EnvielLibrary",
		Parent = ParentTarget,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		ResetOnSpawn = false
	})
	

	local Minimized = false
	local OpenSize = UDim2.new(0, 700, 0, 450)
	

	local MainFrame = Create("Frame", {
		Name = "MainFrame",
		Parent = ScreenGui,
		BackgroundColor3 = self.Theme.Main,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, -350, 0.5, -225),
		Size = UDim2.new(0, 0, 0, 0), -- Animated Start
		ClipsDescendants = true
	})
	
	Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 16)})
	Create("UIStroke", {
		Parent = MainFrame, 
		Color = self.Theme.Stroke, 
		Thickness = 1,
		Transparency = 0.5
	})
	

	Dragify(MainFrame)
	

	Tween(MainFrame, {Size = OpenSize}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	

	local OpenBtn = Create("ImageButton", {
		Name = "OpenButton",
		Parent = ScreenGui,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 30, 0.5, -25),
		Size = UDim2.new(0, 50, 0, 50),
		Image = "rbxassetid://4483345998", -- Placeholder Logo
		Visible = false,
		AutoButtonColor = false
	})
	Create("UICorner", {Parent = OpenBtn, CornerRadius = UDim.new(0, 12)})
	Dragify(OpenBtn)
	

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
	OpenBtn.MouseButton1Click:Connect(ToggleMinimize)
	

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
	CloseBtn.MouseButton1Click:Connect(function()
		Tween(MainFrame, {Size = UDim2.new(0,0,0,0)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In).Completed:Wait()
		ScreenGui.Enabled = false
	end)
	
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
	MinBtn.MouseButton1Click:Connect(ToggleMinimize)


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
	Create("UIListLayout", {Parent = Sidebar, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder})
	
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
	

	function Window:SelectTab(TabId)
		for _, page in pairs(Pages:GetChildren()) do
			if page:IsA("ScrollingFrame") then page.Visible = false end
		end
		for _, btn in pairs(Sidebar:GetChildren()) do
			if btn:IsA("TextButton") then
				-- Inactive
				Tween(btn, {BackgroundTransparency = 1, TextTransparency = 0.6}, 0.3)
				btn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
				if btn:FindFirstChild("UIStroke") then Tween(btn.UIStroke, {Transparency = 1}, 0.3) end
			end
		end
		
		if Pages:FindFirstChild(TabId) then Pages[TabId].Visible = true end
		if Sidebar:FindFirstChild(TabId.."Btn") then
			local btn = Sidebar[TabId.."Btn"]
			-- Active
			Tween(btn, {BackgroundTransparency = 0.85, TextTransparency = 0}, 0.3)
			btn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
			if btn:FindFirstChild("UIStroke") then Tween(btn.UIStroke, {Transparency = 0}, 0.3) end
		end
	end
	
	function Window:CreateTab(Config)
		local Name = Config.Name or "Tab"
		local IconName = Config.Icon or "" 
		local TabId = "Tab"..tostring(#Window.Tabs + 1)
		
		local IconAsset = GetIcon(IconName)
		
		local TabBtn = Create("TextButton", {
			Name = TabId.."Btn",
			Parent = Sidebar,
			BackgroundColor3 = self.Instance.Theme.Accent,
			BackgroundTransparency = 1, 
			Size = UDim2.new(1, 0, 0, 36),
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
			Text = "       "..Name,
			TextColor3 = self.Instance.Theme.Accent,
			TextSize = 13,
			TextTransparency = 0.6,
			TextXAlignment = Enum.TextXAlignment.Left,
			AutoButtonColor = false
		})
		Create("UICorner", {Parent = TabBtn, CornerRadius = UDim.new(0, 8)})
		Create("UIStroke", {Parent = TabBtn, Color = self.Instance.Theme.Accent, Thickness = 1, Transparency = 1})
		
		if IconAsset ~= "" then
			Create("ImageLabel", {
				Parent = TabBtn,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0.5, -8),
				Size = UDim2.new(0, 16, 0, 16),
				Image = IconAsset,
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
				Size = UDim2.new(1, 0, 0, 42),
				BackgroundTransparency = 0,
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
				Parent = Page, BackgroundColor3 = self.Instance.Theme.Secondary, Size = UDim2.new(1,0,0,44), BackgroundTransparency = 0
			})
			Create("UICorner", {Parent = Frame, CornerRadius = UDim.new(0, 8)})
			Create("UIStroke", {Parent = Frame, Color = self.Instance.Theme.Stroke, Thickness = 1, Transparency = 0.5})

			Create("TextLabel", {
				Parent = Frame, BackgroundTransparency=1, Position=UDim2.new(0,15,0,0), Size=UDim2.new(1,-70,1,0),
				FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
				Text=Name, TextColor3=self.Instance.Theme.Text, TextSize=13, TextXAlignment=Enum.TextXAlignment.Left
			})
			
			local Switch = Create("TextButton", {
				Parent=Frame, BackgroundColor3 = Value and self.Instance.Theme.Accent or self.Instance.Theme.Stroke,
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
		
		function Elements:CreateSlider(Config)
			local Name = Config.Name or "Slider"
			local Min = Config.Range[1] or 0
			local Max = Config.Range[2] or 100
			local Default = Config.CurrentValue or Min
			local Callback = Config.Callback or function() end
			
			local Value = math.clamp(Default, Min, Max)
			
			local Frame = Create("Frame", {
				Parent = Page, BackgroundColor3 = self.Instance.Theme.Secondary, Size = UDim2.new(1,0,0,60), BackgroundTransparency = 0
			})
			Create("UICorner", {Parent = Frame, CornerRadius = UDim.new(0, 8)})
			Create("UIStroke", {Parent = Frame, Color = self.Instance.Theme.Stroke, Thickness = 1, Transparency = 0.5})

			local Label = Create("TextLabel", {
				Parent = Frame, BackgroundTransparency=1, Position=UDim2.new(0,15,0,8), Size=UDim2.new(1,-30,0,20),
				FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
				Text=Name, TextColor3=self.Instance.Theme.Text, TextSize=13, TextXAlignment=Enum.TextXAlignment.Left
			})
			local ValueLabel = Create("TextLabel", {
				Parent = Frame, BackgroundTransparency=1, Position=UDim2.new(1,-65,0,8), Size=UDim2.new(0,50,0,20),
				FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
				Text=tostring(Value), TextColor3=self.Instance.Theme.TextSec, TextSize=13, TextXAlignment=Enum.TextXAlignment.Right
			})
			
			local Track = Create("TextButton", {
				Parent = Frame, BackgroundColor3 = self.Instance.Theme.Stroke, Position=UDim2.new(0,15,0,38), Size=UDim2.new(1,-30,0,6), Text="", AutoButtonColor=false
			})
			Create("UICorner", {Parent=Track, CornerRadius=UDim.new(0,3)})
			
			local Fill = Create("Frame", {
				Parent = Track, BackgroundColor3 = self.Instance.Theme.Accent, Size = UDim2.new((Value - Min)/(Max - Min), 0, 1, 0)
			})
			Create("UICorner", {Parent=Fill, CornerRadius=UDim.new(0,3)})
			
			local Thumb = Create("Frame", {
				Parent = Track, BackgroundColor3 = self.Instance.Theme.Text, Position = UDim2.new((Value - Min)/(Max - Min), -7, 0.5, -7), Size = UDim2.new(0,14,0,14)
			})
			Create("UICorner", {Parent=Thumb, CornerRadius=UDim.new(1,0)})
			
			local function UpdateSlider(Input)
				local SizeX = Track.AbsoluteSize.X
				local PosX = Input.Position.X - Track.AbsolutePosition.X
				local Percent = math.clamp(PosX / SizeX, 0, 1)
				Value = math.floor(Min + ((Max - Min) * Percent))
				ValueLabel.Text = tostring(Value)
				Tween(Fill, {Size = UDim2.new(Percent, 0, 1, 0)}, 0.05)
				Tween(Thumb, {Position = UDim2.new(Percent, -7, 0.5, -7)}, 0.05)
				Callback(Value)
			end
			
			local Sliding = false
			Track.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					Sliding = true
					Tween(Thumb, {Size = UDim2.new(0,18,0,18)}, 0.1)
					UpdateSlider(input)
				end
			end)
			
			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					Sliding = false
					Tween(Thumb, {Size = UDim2.new(0,14,0,14)}, 0.1)
				end
			end)
			
			UserInputService.InputChanged:Connect(function(input)
				if Sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					UpdateSlider(input)
				end
			end)
		end
		
		function Elements:CreateDropdown(Config)
			local Name = Config.Name or "Dropdown"
			local Options = Config.Options or {}
			local Default = Config.CurrentValue or Options[1]
			local Callback = Config.Callback or function() end
			
			local Expanded = false
			local DropHeight = 44
			local OptionHeight = 32
			local TotalOptionsHeight = math.min(#Options, 6) * OptionHeight
			
			local Frame = Create("Frame", {
				Parent = Page, BackgroundColor3 = self.Instance.Theme.Secondary, Size = UDim2.new(1,0,0,DropHeight), BackgroundTransparency = 0, ClipsDescendants = true
			})
			Create("UICorner", {Parent = Frame, CornerRadius = UDim.new(0, 8)})
			Create("UIStroke", {Parent = Frame, Color = self.Instance.Theme.Stroke, Thickness = 1, Transparency = 0.5})
			
			local Label = Create("TextLabel", {
				Parent = Frame, BackgroundTransparency=1, Position=UDim2.new(0,15,0,0), Size=UDim2.new(1,-50,0,DropHeight),
				FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
				Text = Name .. " : " .. tostring(Default),
				TextColor3 = self.Instance.Theme.Text, TextSize=13, TextXAlignment=Enum.TextXAlignment.Left
			})
			
			local Arrow = Create("ImageLabel", {
				Parent = Frame, BackgroundTransparency=1, Position=UDim2.new(1,-35,0,12), Size=UDim2.new(0,20,0,20),
				Image = "rbxassetid://6034818372", ImageColor3 = self.Instance.Theme.TextSec -- Arrow Icon
			})
			
			local Trigger = Create("TextButton", {
				Parent = Frame, BackgroundTransparency=1, Size=UDim2.new(1,0,0,DropHeight), Text=""
			})
			
			local OptionContainer = Create("ScrollingFrame", {
				Parent = Frame, BackgroundTransparency=1, Position=UDim2.new(0,0,0,DropHeight), Size=UDim2.new(1,0,0,TotalOptionsHeight),
				ScrollBarThickness=2, ScrollBarImageColor3=self.Instance.Theme.Accent, CanvasSize=UDim2.new(0,0,0,#Options * OptionHeight)
			})
			Create("UIListLayout", {Parent=OptionContainer, SortOrder=Enum.SortOrder.LayoutOrder})
			
			local function RefreshOptions()
				for _, v in pairs(OptionContainer:GetChildren()) do
					if v:IsA("TextButton") then v:Destroy() end
				end
				
				for _, opt in pairs(Options) do
					local Btn = Create("TextButton", {
						Parent=OptionContainer, BackgroundTransparency=0, BackgroundColor3=self.Instance.Theme.Secondary,
						Size=UDim2.new(1,0,0,OptionHeight), Text="    "..tostring(opt),
						FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
						TextColor3 = (opt == Default) and self.Instance.Theme.Accent or self.Instance.Theme.TextSec,
						TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, AutoButtonColor=false
					})
					
					Btn.MouseEnter:Connect(function() 
						Tween(Btn, {BackgroundColor3 = self.Instance.Theme.Stroke}, 0.2)
					end)
					Btn.MouseLeave:Connect(function() 
						Tween(Btn, {BackgroundColor3 = self.Instance.Theme.Secondary}, 0.2)
					end)
					
					Btn.MouseButton1Click:Connect(function()
						Default = opt
						Label.Text = Name .. " : " .. tostring(opt)
						Callback(opt)
						-- Close
						Expanded = false
						Tween(Frame, {Size = UDim2.new(1,0,0,DropHeight)}, 0.3)
						Tween(Arrow, {Rotation = 0}, 0.3)
						RefreshOptions() -- Refresh colors
					end)
				end
			end
			
			RefreshOptions()
			
			Trigger.MouseButton1Click:Connect(function()
				Expanded = not Expanded
				if Expanded then
					Tween(Frame, {Size = UDim2.new(1,0,0,DropHeight + TotalOptionsHeight)}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
					Tween(Arrow, {Rotation = 180}, 0.3)
				else
					Tween(Frame, {Size = UDim2.new(1,0,0,DropHeight)}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
					Tween(Arrow, {Rotation = 0}, 0.3)
				end
			end)
		end
		

	local NotificationContainer = Create("Frame", {
		Name = "Notifications",
		Parent = ScreenGui,
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -320, 1, -20),
		Size = UDim2.new(0, 300, 1, 0),
		AnchorPoint = Vector2.new(0, 1)
	})
	Create("UIListLayout", {
		Parent = NotificationContainer,
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		Padding = UDim.new(0, 10)
	})
	
	function Window:Notify(Config)
		local TitleText = Config.Title or "Notification"
		local ContentText = Config.Content or "Message"
		local Duration = Config.Duration or 3
		local Image = Config.Image or "rbxassetid://4483345998"
		
		local NotifFrame = Create("Frame", {
			Parent = NotificationContainer,
			BackgroundColor3 = self.Theme.Secondary,
			Size = UDim2.new(1, 0, 0, 70),
			BackgroundTransparency = 0.2,
			LayoutOrder = tick()
		})
		Create("UICorner", {Parent = NotifFrame, CornerRadius = UDim.new(0, 8)})
		Create("UIStroke", {Parent = NotifFrame, Color = self.Theme.Stroke, Thickness = 1, Transparency = 0.5})
		
		local Icon = Create("ImageLabel", {
			Parent = NotifFrame, BackgroundTransparency = 1,
			Position = UDim2.new(0, 10, 0, 10), Size = UDim2.new(0, 50, 0, 50),
			Image = Image
		})
		Create("UICorner", {Parent = Icon, CornerRadius = UDim.new(0, 8)})
		
		local TitleLabel = Create("TextLabel", {
			Parent = NotifFrame, BackgroundTransparency = 1,
			Position = UDim2.new(0, 70, 0, 10), Size = UDim2.new(1, -80, 0, 20),
			Font = Enum.Font.GothamBold, Text = TitleText, TextColor3 = self.Theme.Text,
			TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left
		})
		
		local ContentLabel = Create("TextLabel", {
			Parent = NotifFrame, BackgroundTransparency = 1,
			Position = UDim2.new(0, 70, 0, 30), Size = UDim2.new(1, -80, 0, 30),
			Font = Enum.Font.GothamMedium, Text = ContentText, TextColor3 = self.Theme.TextSec,
			TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true
		})
		
		-- Animation: Slide In
		NotifFrame.Position = UDim2.new(1, 100, 0, 0) -- Start off-screen (if no list layout) but ListLayout handles it
		-- Since ListLayout enforces position, we animate transparency or size? 
		-- Better: Use CanvasGroup if possible, but for compatibility, we just Fade/Slide logically or ignore pos tween if ListLayout.
		-- Workaround: Parent to a folder first? No, just fade in.
		
		NotifFrame.BackgroundTransparency = 1
		Icon.ImageTransparency = 1
		TitleLabel.TextTransparency = 1
		ContentLabel.TextTransparency = 1
		
		Tween(NotifFrame, {BackgroundTransparency = 0.2}, 0.3)
		Tween(Icon, {ImageTransparency = 0}, 0.3)
		Tween(TitleLabel, {TextTransparency = 0}, 0.3)
		Tween(ContentLabel, {TextTransparency = 0}, 0.3)
		
		task.delay(Duration, function()
			Tween(NotifFrame, {BackgroundTransparency = 1}, 0.5)
			Tween(Icon, {ImageTransparency = 1}, 0.5)
			Tween(TitleLabel, {TextTransparency = 1}, 0.5)
			Tween(ContentLabel, {TextTransparency = 1}, 0.5).Completed:Wait()
			NotifFrame:Destroy()
		end)
	end

		function Elements:CreateSection(Name)
			local SectionFrame = Create("Frame", {
				Parent = Page, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,30)
			})
			local Label = Create("TextLabel", {
				Parent = SectionFrame, BackgroundTransparency=1, Position=UDim2.new(0,5,0,0), Size=UDim2.new(1,-10,1,0),
				Font=Enum.Font.GothamBold, Text=Name, TextColor3=self.Instance.Theme.TextSec, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left
			})
			return Label
		end

		function Elements:CreateKeybind(Config)
			local Name = Config.Name or "Keybind"
			local Default = Config.CurrentKeybind or Enum.KeyCode.None
			local Callback = Config.Callback or function() end
			
			local Value = Default
			
			local Frame = Create("Frame", {
				Parent = Page, BackgroundColor3 = self.Instance.Theme.Secondary, Size = UDim2.new(1,0,0,46), BackgroundTransparency = 0
			})
			Create("UICorner", {Parent=Frame, CornerRadius=UDim.new(0,8)})
			Create("UIStroke", {Parent=Frame, Color=self.Instance.Theme.Stroke, Thickness=1, Transparency=0.5})

			Create("TextLabel", {
				Parent=Frame, BackgroundTransparency=1, Position=UDim2.new(0,15,0,0), Size=UDim2.new(1,-120,1,0),
				Font=Enum.Font.GothamMedium, Text=Name, TextColor3=self.Instance.Theme.Text, TextSize=14, TextXAlignment=Enum.TextXAlignment.Left
			})
			
			local BindBtn = Create("TextButton", {
				Parent=Frame, BackgroundColor3=self.Instance.Theme.Stroke, Position=UDim2.new(1,-100,0.5,-12), Size=UDim2.new(0,90,0,24),
				Font=Enum.Font.GothamBold, Text=(Value and Value.Name or "None"), TextColor3=self.Instance.Theme.TextSec, TextSize=12, AutoButtonColor=false
			})
			Create("UICorner", {Parent=BindBtn, CornerRadius=UDim.new(0,6)})
			
			local Listening = false
			
			BindBtn.MouseButton1Click:Connect(function()
				Listening = true
				BindBtn.Text = "..."
				BindBtn.TextColor3 = self.Instance.Theme.Accent
				
				local Connection
				Connection = UserInputService.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.Keyboard then
						Value = input.KeyCode
						BindBtn.Text = Value.Name
						BindBtn.TextColor3 = self.Instance.Theme.TextSec
						Callback(Value)
						Listening = false
						Connection:Disconnect()
					elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
						-- Optional: reset or click outside logic
						Listening = false
						BindBtn.Text = (Value and Value.Name or "None")
						BindBtn.TextColor3 = self.Instance.Theme.TextSec
						Connection:Disconnect()
					end
				end)
			end)
		end
		
		function Elements:CreateColorPicker(Config)
			local Name = Config.Name or "Color Picker"
			local Default = Config.CurrentValue or Color3.fromRGB(255, 255, 255)
			local Callback = Config.Callback or function() end
			
			local Value = Default
			local Expanded = false
			
			local Frame = Create("Frame", {
				Parent = Page, BackgroundColor3 = self.Instance.Theme.Secondary, Size = UDim2.new(1,0,0,46), BackgroundTransparency = 0, ClipsDescendants = true
			})
			Create("UICorner", {Parent=Frame, CornerRadius=UDim.new(0,8)})
			Create("UIStroke", {Parent=Frame, Color=self.Instance.Theme.Stroke, Thickness=1, Transparency=0.5})

			Create("TextLabel", {
				Parent=Frame, BackgroundTransparency=1, Position=UDim2.new(0,15,0,0), Size=UDim2.new(1,-60,0,46),
				Font=Enum.Font.GothamMedium, Text=Name, TextColor3=self.Instance.Theme.Text, TextSize=14, TextXAlignment=Enum.TextXAlignment.Left
			})
			
			local ColorDisplay = Create("TextButton", {
				Parent=Frame, BackgroundColor3=Value, Position=UDim2.new(1,-50,0,10), Size=UDim2.new(0,35,0,26), Text="", AutoButtonColor=false
			})
			Create("UICorner", {Parent=ColorDisplay, CornerRadius=UDim.new(0,6)})
			
			-- Expanded Pickers
			local PickerFrame = Create("Frame", {
				Parent=Frame, BackgroundTransparency=1, Position=UDim2.new(0,15,0,50), Size=UDim2.new(1,-30,0,110)
			})
			
			-- Hue Slider (Spectrum)
			local HueBar = Create("ImageButton", {
				Parent=PickerFrame, Position=UDim2.new(0,0,0,0), Size=UDim2.new(1,0,0,15), AutoButtonColor=false,
				Image = "rbxassetid://0", -- Empty image, utilizing Gradient
				BackgroundColor3 = Color3.new(1,1,1)
			})
			Create("UICorner", {Parent=HueBar, CornerRadius=UDim.new(0,4)})
			Create("UIGradient", {
				Parent=HueBar, 
				Color=ColorSequence.new{
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)), ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255,255,0)),
					ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,255,0)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)),
					ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0,0,255)), ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,0,255)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0))
				}
			})
			
			-- RGB Sliders
			local r, g, b = math.floor(Value.R*255), math.floor(Value.G*255), math.floor(Value.B*255)
			
			local function UpdateColor()
				Value = Color3.fromRGB(r, g, b)
				ColorDisplay.BackgroundColor3 = Value
				Callback(Value)
			end
			
			local function makeSlider(yPos, Text, InitialVal, UpdateVal)
				local Label = Create("TextLabel", {
					Parent=PickerFrame, Text=Text, TextColor3=self.Instance.Theme.Text, 
					BackgroundTransparency=1, Position=UDim2.new(0,0,0,yPos), Size=UDim2.new(0,15,0,20),
					Font = Enum.Font.GothamMedium, TextSize = 12
				})
				
				local Track = Create("TextButton", {
					Parent=PickerFrame, BackgroundColor3=self.Instance.Theme.Stroke, 
					Position=UDim2.new(0,25,0,yPos+7), Size=UDim2.new(1,-30,0,6), Text="", AutoButtonColor=false
				})
				Create("UICorner", {Parent=Track, CornerRadius=UDim.new(0,3)})
				
				local Fill = Create("Frame", {
					Parent=Track, BackgroundColor3=self.Instance.Theme.Accent, Size=UDim2.new(InitialVal/255,0,1,0)
				})
				Create("UICorner", {Parent=Fill, CornerRadius=UDim.new(0,3)})
				
				local Sliding = false
				
				Track.InputBegan:Connect(function(i) 
					if i.UserInputType==Enum.UserInputType.MouseButton1 then Sliding=true end 
				end)
				UserInputService.InputEnded:Connect(function(i) 
					if i.UserInputType==Enum.UserInputType.MouseButton1 then Sliding=false end 
				end)
				
				RunService.RenderStepped:Connect(function()
					if Sliding then
						local mouse = UserInputService:GetMouseLocation().X
						local rel = math.clamp((mouse - Track.AbsolutePosition.X)/Track.AbsoluteSize.X, 0, 1)
						Fill.Size = UDim2.new(rel,0,1,0)
						UpdateVal(math.floor(rel * 255))
						UpdateColor()
					end
				end)
				
				return Fill -- Return handle to update visually later if needed
			end
			
			local fillR = makeSlider(25, "R", r, function(v) r = v end)
			local fillG = makeSlider(50, "G", g, function(v) g = v end)
			local fillB = makeSlider(75, "B", b, function(v) b = v end)
			
			-- Hue Logic
			local HueSliding = false
			HueBar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then HueSliding=true end end)
			UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then HueSliding=false end end)
			
			RunService.RenderStepped:Connect(function()
				if HueSliding then
					local mouse = UserInputService:GetMouseLocation().X
					local rel = math.clamp((mouse - HueBar.AbsolutePosition.X)/HueBar.AbsoluteSize.X, 0, 1)
					local HueColor = Color3.fromHSV(rel, 1, 1)
					r, g, b = math.floor(HueColor.R*255), math.floor(HueColor.G*255), math.floor(HueColor.B*255)
					
					-- Update Sliders Visually
					fillR.Size = UDim2.new(r/255, 0, 1, 0)
					fillG.Size = UDim2.new(g/255, 0, 1, 0)
					fillB.Size = UDim2.new(b/255, 0, 1, 0)
					
					UpdateColor()
				end
			end)
			
			ColorDisplay.MouseButton1Click:Connect(function()
				Expanded = not Expanded
				Tween(Frame, {Size = Expanded and UDim2.new(1,0,0,170) or UDim2.new(1,0,0,46)}, 0.3)
			end)
		end
		
		return Elements
	end

return EnvielUI
