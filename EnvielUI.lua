local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")

local EnvielUI = {}
EnvielUI.__index = EnvielUI
EnvielUI.Version = "Validation_v4_NoScroll"

local Themes = {
	Dark = {
		Main = Color3.fromHex("181818"),
		Secondary = Color3.fromHex("202020"),
		Stroke = Color3.fromHex("303030"),
		Text = Color3.fromHex("E0E0E0"),
		TextSec = Color3.fromHex("888888"),
		Accent = Color3.fromHex("FFFFFF"),
		AccentText = Color3.fromHex("000000"),
		
		Hover = Color3.fromHex("252525"),
		Element = Color3.fromHex("1E1E1E"),
		TextSelected = Color3.fromHex("FFFFFF"),
		Description = Color3.fromHex("666666"),
		
		AccentHover = Color3.fromHex("D0D0D0"),
	},
	Light = {
		Main = Color3.fromHex("F5F5F5"),
		Secondary = Color3.fromHex("EBEBEB"),
		Stroke = Color3.fromHex("D0D0D0"),
		Text = Color3.fromHex("101010"),
		TextSec = Color3.fromHex("606060"),
		Accent = Color3.fromHex("151515"),
		AccentText = Color3.fromHex("FFFFFF"),

		Hover = Color3.fromHex("E0E0E0"),
		Element = Color3.fromHex("FFFFFF"),
		TextSelected = Color3.fromHex("000000"),
		Description = Color3.fromHex("808080"),
		
		AccentHover = Color3.fromHex("303030"),
	}
}

print("[EnvielUI] Loading Library...")

local IconLib
local SuccessIcon, ErrIcon = pcall(function()
	IconLib = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Footagesus/Icons/main/Main-v2.lua"))()
	IconLib.SetIconsType("lucide")
end)

if not SuccessIcon then
	warn("[EnvielUI] Failed to load IconLib:", ErrIcon)
	IconLib = { GetIcon = function(...) return "" end }
else
	print("[EnvielUI] IconLib loaded successfully")
end

local function GetIcon(Name)
	if not Name or Name == "" then return "" end
	if string.find(Name, "rbxassetid://") then return Name end
	local Success, Icon = pcall(function() return IconLib.GetIcon(Name) end)
	if Success and Icon then return Icon end
	return ""
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
	self.Theme = Themes.Dark 
	self.Flags = {}
	return self
end

function EnvielUI:CreateWindow(Config)
	local WindowName = Config.Name or "Enviel UI"
	local Theme = Config.Theme or "Dark"
	
	if Themes[Theme] then 
		self.Theme = Themes[Theme] 
	else
		self.Theme = Themes.Dark
	end
	
	for key, val in pairs(Themes.Dark) do
		if self.Theme[key] == nil then
			self.Theme[key] = val
		end
	end
	
	print("[EnvielUI] Debug: Theme check passed.")
	
	print("[EnvielUI] Initializing...")
	
	local function GetCorrectParent()
		local Success, Parent = pcall(function() return gethui() end)
		if Success and Parent then 
			print("[EnvielUI] Using gethui()")
			return Parent 
		end
		
		Success, Parent = pcall(function() return game:GetService("CoreGui") end)
		if Success and Parent then 
			print("[EnvielUI] Using CoreGui")
			return Parent 
		end
		
		print("[EnvielUI] Using PlayerGui (Fallback)")
		return Players.LocalPlayer:WaitForChild("PlayerGui")
	end
	
	local ParentTarget = GetCorrectParent()
	print("[EnvielUI] Final Parent: " .. tostring(ParentTarget))
	
	local function RandomString(length)
		local str = ""
		for i = 1, length do
			str = str .. string.char(math.random(97, 122))
		end
		return str
	end

	print("[EnvielUI] Debug: Cleaning old instances...")
	for _, child in pairs(ParentTarget:GetChildren()) do
		if child:GetAttribute("EnvielID") == "MainInstance" then
			child:Destroy()
		end
	end
	
	print("[EnvielUI] Debug: Creating ScreenGui...")
	local ScreenGui = Create("ScreenGui", {
		Name = RandomString(10),
		Parent = ParentTarget,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		ResetOnSpawn = false,
		DisplayOrder = 10000
	})
	ScreenGui:SetAttribute("EnvielID", "MainInstance")
	
	local Minimized = false
	local OpenSize = UDim2.new(0, 700, 0, 450)
	
	print("[EnvielUI] Debug: Creating MainFrame...")
	local MainFrame = Create("Frame", {
		Name = "MainFrame",
		Parent = ScreenGui,
		BackgroundColor3 = self.Theme.Main,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		ClipsDescendants = true
	})
	print("[EnvielUI] Debug: MainFrame Created.")

	Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 16)})
	Create("UIStroke", {
		Parent = MainFrame, 
		Color = self.Theme.Stroke, 
		Thickness = 1,
		Transparency = 0.5
	})
	
	Dragify(MainFrame)
	
	Tween(MainFrame, {
		Size = OpenSize, 
		BackgroundTransparency = 0
	}, 0.8, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
	
	local OpenBtn = Create("ImageButton", {
		Name = "OpenButton",
		Parent = ScreenGui,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 30, 0.5, -25),
		Size = UDim2.new(0, 50, 0, 50),
		Image = "rbxassetid://4483345998",
		Visible = false,
		AutoButtonColor = false
	})
	Create("UICorner", {Parent = OpenBtn, CornerRadius = UDim.new(0, 12)})
	Dragify(OpenBtn)
	
	local function ToggleMinimize()
		Minimized = not Minimized
		if Minimized then
			Tween(MainFrame, {Size = UDim2.new(0,0,0,0)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In).Completed:Wait()
			MainFrame.Visible = false
			OpenBtn.Visible = true
			OpenBtn.Size = UDim2.new(0, 0, 0, 0)
			Tween(OpenBtn, {Size = UDim2.new(0, 50, 0, 50)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		else
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
				if not Minimized then
					Tween(MainFrame, {Size = UDim2.new(0,0,0,0)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In).Completed:Wait()
				end
				ScreenGui.Enabled = false
			else
				ScreenGui.Enabled = true
				if not Minimized then
					MainFrame.Size = UDim2.new(0,0,0,0)
					Tween(MainFrame, {Size = OpenSize}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
				end
			end
		end
	end)

	if UserInputService.TouchEnabled then
		local MobileToggle = Create("TextButton", {
			Name = "EnvielMobileToggle",
			Parent = ScreenGui,
			BackgroundColor3 = self.Theme.Main,
			Position = UDim2.new(0.5, -25, 0, 10),
			Size = UDim2.new(0, 50, 0, 50),
			Text = "",
			AutoButtonColor = false
		})
		Create("UICorner", {Parent = MobileToggle, CornerRadius = UDim.new(1, 0)})
		Create("UIStroke", {Parent = MobileToggle, Color = self.Theme.Accent, Thickness = 2})
		Create("ImageLabel", {
			Parent = MobileToggle,
			BackgroundTransparency = 1,
			Position = UDim2.new(0.5, -12, 0.5, -12),
			Size = UDim2.new(0, 24, 0, 24),
			Image = GetIcon("menu"),
			ImageColor3 = self.Theme.Accent
		})
		
		local MobileOpen = true
		MobileToggle.MouseButton1Click:Connect(function()
			MobileOpen = not MobileOpen
			ScreenGui.Enabled = true
			if not MobileOpen then
				if not Minimized then
					Tween(MainFrame, {Size = UDim2.new(0,0,0,0)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In).Completed:Wait()
				end
				MainFrame.Visible = false
			else
				MainFrame.Visible = true
				if not Minimized then
					MainFrame.Size = UDim2.new(0,0,0,0)
					Tween(MainFrame, {Size = OpenSize}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
				end
			end
		end)
	end

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

	if UserInputService.TouchEnabled then
		Create("UIScale", {
			Parent = MainFrame,
			Scale = 1.2
		})
	end

	local ContentContainer = Create("Frame", {
		Name = "ContentContainer",
		Parent = MainFrame,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, -50),
		Position = UDim2.new(0, 0, 0, 50)
	})
	
	local SearchBarFrame = Create("Frame", {
		Parent = ContentContainer,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 20, 0, 5),
		Size = UDim2.new(0, 160, 0, 32)
	})
	local SearchBar = Create("TextBox", {
		Parent = SearchBarFrame,
		BackgroundColor3 = self.Theme.Secondary,
		Size = UDim2.new(1, 0, 1, 0),
		Text = "",
		PlaceholderText = "Search...",
		TextColor3 = self.Theme.Text,
		PlaceholderColor3 = self.Theme.TextSec,
		TextSize = 14,
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
		TextXAlignment = Enum.TextXAlignment.Left
	})
	Create("UICorner", {Parent = SearchBar, CornerRadius = UDim.new(0, 6)})
	Create("UIPadding", {Parent = SearchBar, PaddingLeft = UDim.new(0, 10)})
	Create("UIStroke", {Parent = SearchBar, Color = self.Theme.Stroke, Thickness = 1, Transparency = 0.5})

	local Sidebar = Create("ScrollingFrame", {
		Name = "Sidebar",
		Parent = ContentContainer,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 20, 0, 45),
		Size = UDim2.new(0, 160, 1, -55),
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(0,0,0,0)
	})
	
	SearchBar:GetPropertyChangedSignal("Text"):Connect(function()
		local Input = SearchBar.Text:lower()
		for _, page in pairs(ContentContainer:FindFirstChild("Pages"):GetChildren()) do
			if page:IsA("ScrollingFrame") then
				for _, frame in pairs(page:GetChildren()) do
					if frame:IsA("Frame") and frame:FindFirstChild("TextLabel") then
						local NameLabel = frame:FindFirstChild("TextLabel")
						if NameLabel and NameLabel.Text:lower():find(Input) then
							frame.Visible = true
						else
							frame.Visible = false
						end
					end
				end
			end
		end
	end)
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
		Instance = self,
		MainFrame = MainFrame,
		Sidebar = Sidebar,
		Pages = Pages,
		TitleLabel = Title,
		Search = SearchBar
	}
	
	function Window:SetTheme(ThemeName)
		if not Themes[ThemeName] then warn("Theme not found: " .. tostring(ThemeName)) return end
		self.Instance.Theme = Themes[ThemeName]
		local T = self.Instance.Theme
		
		Tween(MainFrame, {BackgroundColor3 = T.Main}, 0.3)
		Tween(MainFrame.UIStroke, {Color = T.Stroke}, 0.3)
		Tween(Title, {TextColor3 = T.TextSec}, 0.3)
		
		for _, btn in pairs(Sidebar:GetChildren()) do
			if btn:IsA("TextButton") then
				local label = btn:FindFirstChild("Label")
				local icon = btn:FindFirstChild("ImageLabel")
				local stroke = btn:FindFirstChild("UIStroke")
				
				Tween(btn.UIStroke, {Color = T.Accent}, 0.3)
				if label then Tween(label, {TextColor3 = T.Accent}, 0.3) end
				if icon then Tween(icon, {ImageColor3 = T.Accent}, 0.3) end
			end
		end
		
		for _, page in pairs(Pages:GetChildren()) do
			if page:IsA("ScrollingFrame") then
				page.ScrollBarImageColor3 = T.Stroke 
				
				for _, frame in pairs(page:GetChildren()) do
					if frame:IsA("Frame") and frame:FindFirstChild("UIStroke") then
						Tween(frame, {BackgroundColor3 = T.Element}, 0.3)
						Tween(frame.UIStroke, {Color = T.Stroke}, 0.3)
	
						for _, desc in pairs(frame:GetDescendants()) do
							if desc:IsA("TextLabel") then
								if desc.Text == "Interact" then
								else
									Tween(desc, {TextColor3 = T.Text}, 0.3)
								end
							elseif desc:IsA("TextButton") then
								local Type = desc:GetAttribute("EnvielType")
								
								if Type == "ActionButton" then
									Tween(desc, {BackgroundColor3 = T.Accent}, 0.3)
									Tween(desc, {TextColor3 = T.AccentText}, 0.3)
								elseif Type == "ToggleSwitch" then
									local FlagName = desc:GetAttribute("EnvielFlag")
									local IsOn = self.Instance.Flags[FlagName]
									
									if IsOn then
										Tween(desc, {BackgroundColor3 = T.Accent}, 0.3)
									else
										Tween(desc, {BackgroundColor3 = T.Stroke}, 0.3)
									end
									
									local Circle = desc:FindFirstChild("Frame")
									if Circle then
										Tween(Circle, {BackgroundColor3 = T.Main}, 0.3)
									end
								end
							end
						end
					end
				end
			end
		end
		
		for _, page in pairs(Pages:GetChildren()) do
			if page.Visible then
				Window:SelectTab(page.Name)
				break
			end
		end
	end
	
	function Window:SelectTab(TabId)
		for _, page in pairs(Pages:GetChildren()) do
			if page:IsA("ScrollingFrame") then page.Visible = false end
		end
		for _, btn in pairs(Sidebar:GetChildren()) do
			if btn:IsA("TextButton") then
				Tween(btn, {BackgroundTransparency = 1, TextTransparency = 0.6, TextColor3 = self.Instance.Theme.TextSec}, 0.3)
				btn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
				if btn:FindFirstChild("UIStroke") then Tween(btn.UIStroke, {Transparency = 1}, 0.3) end
			end
		end
		
		if Pages:FindFirstChild(TabId) then Pages[TabId].Visible = true end
		if Sidebar:FindFirstChild(TabId.."Btn") then
			local btn = Sidebar[TabId.."Btn"]
			local label = btn:FindFirstChild("Label")
			local icon = btn:FindFirstChild("ImageLabel")
			
			if label then
				Tween(label, {TextTransparency = 0, TextColor3 = self.Instance.Theme.TextSelected}, 0.3)
				label.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
			end
			
			if icon then Tween(icon, {ImageColor3 = self.Instance.Theme.TextSelected}, 0.3) end
			
			Tween(btn, {BackgroundTransparency = 0.85}, 0.3)
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
			Text = "",
			AutoButtonColor = false
		})
		
		Create("UICorner", {Parent = TabBtn, CornerRadius = UDim.new(0, 8)})
		Create("UIStroke", {Parent = TabBtn, Color = self.Instance.Theme.Accent, Thickness = 1, Transparency = 1})
		
		if IconAsset ~= "" then
			Create("ImageLabel", {
				Parent = TabBtn,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 12, 0.5, -9),
				Size = UDim2.new(0, 18, 0, 18),
				Image = IconAsset,
				ImageColor3 = self.Instance.Theme.Accent
			})
		end
		
		local TabLabel = Create("TextLabel", {
			Parent = TabBtn,
			Name = "Label",
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 40, 0, 0),
			Size = UDim2.new(1, -45, 1, 0),
			Text = Name,
			FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
			TextColor3 = self.Instance.Theme.Accent,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTransparency = 0.6
		})
		
		TabBtn.MouseButton1Click:Connect(function() Window:SelectTab(TabId) end)
		
		local Page = Create("ScrollingFrame", {
			Name = TabId,
			Parent = Pages,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			ScrollBarThickness = 0,
			ScrollBarImageColor3 = self.Instance.Theme.Stroke,
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
		Elements.Instance = self.Instance
		
		function Elements:CreateButton(Config)
			local Name = Config.Name or "Button"
			local Callback = Config.Callback or function() end
			
			local Frame = Create("Frame", {
				Parent = Page,
				BackgroundColor3 = self.Instance.Theme.Element,
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
			Btn:SetAttribute("EnvielType", "ActionButton")
			
			Btn.MouseEnter:Connect(function()
				Tween(Btn, {BackgroundColor3 = self.Instance.Theme.AccentHover}, 0.2)
			end)
			
			Btn.MouseLeave:Connect(function()
				Tween(Btn, {BackgroundColor3 = self.Instance.Theme.Accent}, 0.2)
			end)
			
			Btn.MouseButton1Click:Connect(function()
				Tween(Btn, {Size = UDim2.new(0,85,0,24)}, 0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.In).Completed:Wait()
				Tween(Btn, {Size = UDim2.new(0,90,0,26)}, 0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
				Callback()
			end)
		end

		function Elements:CreateToggle(Config)
			local Name = Config.Name or "Toggle"
			local Flag = Config.Flag or Name
			local Default = Config.CurrentValue or false
			local Callback = Config.Callback or function() end
			
			if self.Instance.Flags[Flag] ~= nil then
				Default = self.Instance.Flags[Flag]
			end
			
			local Value = Default
			self.Instance.Flags[Flag] = Value
			
			local Frame = Create("Frame", {
				Parent = Page, BackgroundColor3 = self.Instance.Theme.Element, Size = UDim2.new(1,0,0,44), BackgroundTransparency = 0
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
			Switch:SetAttribute("EnvielType", "ToggleSwitch")
			Switch:SetAttribute("EnvielFlag", Flag)
			
			local Circle = Create("Frame", {
				Name="Frame",
				Parent=Switch, BackgroundColor3=self.Instance.Theme.Main,
				Position=Value and UDim2.new(1,-22,0.5,-9) or UDim2.new(0,2,0.5,-9), Size=UDim2.new(0,18,0,18)
			})
			Create("UICorner", {Parent=Circle, CornerRadius=UDim.new(1,0)})
			
			Switch.MouseButton1Click:Connect(function()
				Value = not Value
				self.Instance.Flags[Flag] = Value
				Callback(Value)
				Tween(Switch, {BackgroundColor3=Value and self.Instance.Theme.Accent or self.Instance.Theme.Stroke}, 0.2)
				Tween(Circle, {Position=Value and UDim2.new(1,-22,0.5,-9) or UDim2.new(0,2,0.5,-9)}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
			end)
		end
		
		function Elements:CreateSlider(Config)
			local Name = Config.Name or "Slider"
			local Flag = Config.Flag or Name
			local Min = Config.Range[1] or 0
			local Max = Config.Range[2] or 100
			local Default = Config.CurrentValue or Min
			local Callback = Config.Callback or function() end
			
			if self.Instance.Flags[Flag] ~= nil then
				Default = self.Instance.Flags[Flag]
			end
			
			local Value = math.clamp(Default, Min, Max)
			self.Instance.Flags[Flag] = Value
			
			local Frame = Create("Frame", {
				Parent = Page, BackgroundColor3 = self.Instance.Theme.Element, Size = UDim2.new(1,0,0,60), BackgroundTransparency = 0
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
				self.Instance.Flags[Flag] = Value
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
			local Flag = Config.Flag or Name
			local Options = Config.Options or {}
			local Default = Config.CurrentValue or Options[1]
			local Callback = Config.Callback or function() end
			
			if self.Instance.Flags[Flag] ~= nil then
				Default = self.Instance.Flags[Flag]
			end
			
			self.Instance.Flags[Flag] = Default
			
			local Expanded = false
			local DropHeight = 44
			local OptionHeight = 32
			local TotalOptionsHeight = math.min(#Options, 6) * OptionHeight
			
			local Frame = Create("Frame", {
				Parent = Page, BackgroundColor3 = self.Instance.Theme.Element, Size = UDim2.new(1,0,0,DropHeight), BackgroundTransparency = 0, ClipsDescendants = true
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
				Image = "rbxassetid://6034818372", ImageColor3 = self.Instance.Theme.TextSec 
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
						Parent=OptionContainer, BackgroundTransparency=0, BackgroundColor3=self.Instance.Theme.Element,
						Size=UDim2.new(1,0,0,OptionHeight), Text="    "..tostring(opt),
						FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
						TextColor3 = (opt == Default) and self.Instance.Theme.Accent or self.Instance.Theme.TextSec,
						TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, AutoButtonColor=false
					})
					
					Btn.MouseEnter:Connect(function() 
						Tween(Btn, {BackgroundColor3 = self.Instance.Theme.Hover}, 0.2)
					end)
					Btn.MouseLeave:Connect(function() 
						Tween(Btn, {BackgroundColor3 = self.Instance.Theme.Element}, 0.2)
					end)
					
					Btn.MouseButton1Click:Connect(function()
						Default = opt
						self.Instance.Flags[Flag] = Default
						Callback(Default)
						Label.Text = Name .. " : " .. tostring(Default)
						Expanded = false
						Tween(Frame, {Size=UDim2.new(1,0,0,DropHeight)}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
						Tween(Arrow, {Rotation=0}, 0.3)
						RefreshOptions()
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
		
		print("[EnvielUI] Debug: Notify called.", TitleText)
		
		local NotifFrame = Create("Frame", {
			Parent = NotificationContainer,
			BackgroundColor3 = self.Instance.Theme.Secondary,
			Size = UDim2.new(1, 0, 0, 70),
			BackgroundTransparency = 0.2,
			LayoutOrder = tick()
		})
		Create("UICorner", {Parent = NotifFrame, CornerRadius = UDim.new(0, 8)})
		Create("UIStroke", {Parent = NotifFrame, Color = self.Instance.Theme.Stroke, Thickness = 1, Transparency = 0.5})
		
		local Icon = Create("ImageLabel", {
			Parent = NotifFrame, BackgroundTransparency = 1,
			Position = UDim2.new(0, 10, 0, 10), Size = UDim2.new(0, 50, 0, 50),
			Image = Image
		})
		Create("UICorner", {Parent = Icon, CornerRadius = UDim.new(0, 8)})
		
		local TitleLabel = Create("TextLabel", {
			Parent = NotifFrame, BackgroundTransparency = 1,
			Position = UDim2.new(0, 70, 0, 10), Size = UDim2.new(1, -80, 0, 20),
			Font = Enum.Font.GothamBold, Text = TitleText, TextColor3 = self.Instance.Theme.Text,
			TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left
		})
		
		local ContentLabel = Create("TextLabel", {
			Parent = NotifFrame, BackgroundTransparency = 1,
			Position = UDim2.new(0, 70, 0, 30), Size = UDim2.new(1, -80, 0, 30),
			Font = Enum.Font.GothamMedium, Text = ContentText, TextColor3 = self.Instance.Theme.TextSec,
			TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true
		})
		
		NotifFrame.Position = UDim2.new(1, 50, 0, 0)
		NotifFrame.BackgroundTransparency = 1
		Icon.ImageTransparency = 1
		TitleLabel.TextTransparency = 0
		ContentLabel.TextTransparency = 0
		TitleLabel.ZIndex = 2
		ContentLabel.ZIndex = 2

		Tween(NotifFrame, {Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0.2}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		Tween(Icon, {ImageTransparency = 0}, 0.5)
		Tween(TitleLabel, {TextTransparency = 0}, 0.5)
		Tween(ContentLabel, {TextTransparency = 0}, 0.5)
		
		task.delay(Duration, function()
			Tween(NotifFrame, {Position = UDim2.new(1, 50, 0, 0), BackgroundTransparency = 1}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)
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

		function Elements:CreateInput(Config)
			local Name = Config.Name or "Input"
			local Flag = Config.Flag or Name
			local Placeholder = Config.PlaceholderText or "Type here..."
			local Callback = Config.Callback or function() end
			local RemoveTextAfterFocusLost = Config.RemoveTextAfterFocusLost or false
			
			local Frame = Create("Frame", {
				Parent = Page, BackgroundColor3 = self.Instance.Theme.Element, Size = UDim2.new(1,0,0,44), BackgroundTransparency = 0
			})
			Create("UICorner", {Parent = Frame, CornerRadius = UDim.new(0, 8)})
			Create("UIStroke", {Parent = Frame, Color = self.Instance.Theme.Stroke, Thickness = 1, Transparency = 0.5})
			
			local Label = Create("TextLabel", {
				Parent = Frame, BackgroundTransparency=1, Position=UDim2.new(0,15,0,0), Size=UDim2.new(1,-15,0,20),
				FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
				Text = Name, TextColor3 = self.Instance.Theme.Text, TextSize=13, TextXAlignment=Enum.TextXAlignment.Left
			})
			
			local InputBox = Create("TextBox", {
				Parent = Frame, BackgroundTransparency=1, Position=UDim2.new(0,15,0,22), Size=UDim2.new(1,-30,0,18),
				FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
				Text = "", PlaceholderText = Placeholder, TextColor3 = self.Instance.Theme.Accent, PlaceholderColor3 = self.Instance.Theme.TextSec,
				TextSize = 13, TextXAlignment=Enum.TextXAlignment.Left, ClearTextOnFocus = false
			})
			
			InputBox.FocusLost:Connect(function(enterPressed)
				local Text = InputBox.Text
				if RemoveTextAfterFocusLost then InputBox.Text = "" end
				self.Instance.Flags[Flag] = Text
				Callback(Text)
			end)
		end
		
		function Elements:CreateParagraph(Config)
			local Title = Config.Title or "Paragraph"
			local Content = Config.Content or "Content"
			
			local Frame = Create("Frame", {
				Parent = Page, BackgroundColor3 = self.Instance.Theme.Element, Size = UDim2.new(1,0,0,0), BackgroundTransparency = 0, AutomaticSize = Enum.AutomaticSize.Y
			})
			Create("UICorner", {Parent = Frame, CornerRadius = UDim.new(0, 8)})
			Create("UIStroke", {Parent = Frame, Color = self.Instance.Theme.Stroke, Thickness = 1, Transparency = 0.5})
			Create("UIPadding", {Parent = Frame, PaddingTop=UDim.new(0,10), PaddingBottom=UDim.new(0,10), PaddingLeft=UDim.new(0,15), PaddingRight=UDim.new(0,15)})
			
			local TitleLabel = Create("TextLabel", {
				Parent = Frame, BackgroundTransparency=1, Size=UDim2.new(1,0,0,16),
				FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
				Text = Title, TextColor3 = self.Instance.Theme.Text, TextSize=14, TextXAlignment=Enum.TextXAlignment.Left
			})
			
			local ContentLabel = Create("TextLabel", {
				Parent = Frame, BackgroundTransparency=1, Size=UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y,
				FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
				Text = Content, TextColor3 = self.Instance.Theme.Description, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, TextWrapped = true
			})
			Create("UIListLayout", {Parent = Frame, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
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
			
			local PickerFrame = Create("Frame", {
				Parent=Frame, BackgroundTransparency=1, Position=UDim2.new(0,15,0,50), Size=UDim2.new(1,-30,0,110)
			})
			
			local HueBar = Create("ImageButton", {
				Parent=PickerFrame, Position=UDim2.new(0,0,0,0), Size=UDim2.new(1,0,0,15), AutoButtonColor=false,
				Image = "rbxassetid://0", 
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
				
				return Fill 
			end
			
			local fillR = makeSlider(25, "R", r, function(v) r = v end)
			local fillG = makeSlider(50, "G", g, function(v) g = v end)
			local fillB = makeSlider(75, "B", b, function(v) b = v end)
			
			local HueSliding = false
			HueBar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then HueSliding=true end end)
			UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then HueSliding=false end end)
			
			RunService.RenderStepped:Connect(function()
				if HueSliding then
					local mouse = UserInputService:GetMouseLocation().X
					local rel = math.clamp((mouse - HueBar.AbsolutePosition.X)/HueBar.AbsoluteSize.X, 0, 1)
					local HueColor = Color3.fromHSV(rel, 1, 1)
					r, g, b = math.floor(HueColor.R*255), math.floor(HueColor.G*255), math.floor(HueColor.B*255)
					
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
	
	return Window
end

return EnvielUI
