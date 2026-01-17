local EnvielUI = {}
EnvielUI.__index = EnvielUI

local function GetService(Name)
	return cloneref and cloneref(game:GetService(Name)) or game:GetService(Name)
end

local GuiService = GetService("GuiService")

local TweenService = GetService("TweenService")
local UserInputService = GetService("UserInputService")
local RunService = GetService("RunService")
local Players = GetService("Players")
local CoreGui = GetService("CoreGui")
local HttpService = GetService("HttpService")

local IconLib
pcall(function()
	IconLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/Icons/main/Main-v2.lua"))()
	IconLib.SetIconsType("lucide")
end)

local function GetIcon(Name)
	if not Name then return nil end
	if Name:find("rbxassetid") then return Name end
	if not IconLib then return "" end -- Fallback if lib failed
	
	local s, i = pcall(function() return IconLib.GetIcon(Name) end)
	return (s and i) or ""
end

-- Helper: Validate Config
local function Validate(Config, Defaults)
	Config = Config or {}
	for k, v in pairs(Defaults) do
		if Config[k] == nil then
			Config[k] = v
		end
	end
	return Config
end

local function Create(msg, prop)
	local inst = Instance.new(msg)
	for i, v in pairs(prop) do inst[i] = v end
	return inst
end

local function Tween(instance, properties, duration, style, direction)
	local info = TweenInfo.new(duration or 0.25, style or Enum.EasingStyle.Quart, direction or Enum.EasingDirection.Out)
	local tween = TweenService:Create(instance, info, properties)
	tween:Play()
	return tween
end

local function Dragify(Frame, Parent)
	if not Frame then return end
	Parent = Parent or Frame
	local Dragging, DragInput, DragStart, StartPos

	local function Update(input)
		local Delta = input.Position - DragStart
		local Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
		TweenService:Create(Parent, TweenInfo.new(0.05), {Position = Position}):Play()
	end

	Frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			Dragging = true
			DragStart = input.Position
			StartPos = Parent.Position
			
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					Dragging = false
				end
			end)
		end
	end)

	Frame.InputChanged:Connect(function(input)
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

local function SaveFile(Name, Data)
	if writefile then
		writefile(Name, HttpService:JSONEncode(Data))
	end
end

local function LoadFile(Name)
	if isfile and isfile(Name) then
		return HttpService:JSONDecode(readfile(Name))
	end
	return nil
end

function EnvielUI:CreateWindow(Config)
	Config = Validate(Config, {
		Name = "Enviel UI",
		Theme = {
			Main = Color3.fromRGB(15, 15, 15),
			Secondary = Color3.fromRGB(25, 25, 25),
			Stroke = Color3.fromRGB(0, 0, 0),
			Accent = Color3.fromRGB(255, 255, 255),
			Text = Color3.fromRGB(255, 255, 255),
			TextDark = Color3.fromRGB(170, 170, 170),
			ActiveText = Color3.fromRGB(0, 0, 0)
		}
	})

	local Window = {
		Flags = {}, 
		Theme = Config.Theme,
		Connections = {}
	}
	
	function Window:SafeConnect(Signal, Callback)
		local Conn = Signal:Connect(Callback)
		table.insert(Window.Connections, Conn)
		return Conn
	end
	
	local Name = Config.Name
	
	local Parent = game:GetService("CoreGui")
	if not pcall(function() return Parent.Name end) then Parent = Players.LocalPlayer.PlayerGui end
	
	local ScreenGui = Create("ScreenGui", {
		Name = "EnvielUI", Parent = Parent, 
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling, ResetOnSpawn = false,
		IgnoreGuiInset = true
	})
	
	local MainFrame = Create("Frame", {
		Name = "MainFrame", Parent = ScreenGui, BackgroundTransparency = 1,
		Size = UDim2.fromOffset(580, 380), Position = UDim2.fromScale(0.5, 0.45),
		AnchorPoint = Vector2.new(0.5, 0.5), Active = true
	})
	
	local ContentWindow = Create("CanvasGroup", {
		Name = "ContentWindow", Parent = MainFrame, BackgroundColor3 = Window.Theme.Main,
		Size = UDim2.fromScale(1, 1), BorderSizePixel = 0, GroupTransparency = 1
	})
	
	-- Mobile Responsive Logic
	local Camera = Workspace.CurrentCamera
	if Camera.ViewportSize.X < 600 then
		MainFrame.Size = UDim2.fromScale(0.9, 0.6) -- Auto-scale on small screens
	end
	
	Create("UICorner", {Parent = ContentWindow, CornerRadius = UDim.new(0, 14)})

	Tween(ContentWindow, {GroupTransparency = 0}, 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local LOGO_WHITE = "94854804824909"
	local LOGO_BLACK = "120261170817156"
	
	local Header = Create("Frame", {Parent = ContentWindow, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 50)})
	Create("UIPadding", {Parent = Header, PaddingLeft = UDim.new(0, 20), PaddingRight = UDim.new(0, 20)})
	
	local LogoIcon = Create("ImageLabel", {
		Parent = Header, BackgroundTransparency = 1, Size = UDim2.fromOffset(24, 24), Position = UDim2.new(0, 0, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
		Image = "rbxthumb://type=Asset&id="..LOGO_WHITE.."&w=150&h=150", ImageColor3 = Window.Theme.Accent
	})
	
	Create("TextLabel", {
		Parent = Header, BackgroundTransparency = 1, Size = UDim2.new(0, 0, 1, 0), Position = UDim2.new(0, 32, 0, 0), AutomaticSize = Enum.AutomaticSize.X,
		Font = Enum.Font.GothamBold, Text = Name, TextColor3 = Window.Theme.Text, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left
	})

	Create("TextLabel", {
		Parent = Header, BackgroundTransparency = 1, Size = UDim2.new(0, 0, 1, 0), Position = UDim2.new(0, 32, 0, 0), AutomaticSize = Enum.AutomaticSize.X,
		Font = Enum.Font.GothamBold, Text = Name, TextColor3 = Window.Theme.Text, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left
	})

	task.wait(0.05)
	Dragify(Header, MainFrame)
	
	local Controls = Create("Frame", {
		Parent = Header, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.new(0, 200, 1, 0), BackgroundTransparency = 1
	})
	
	Create("TextLabel", {
		Parent = Controls, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -70, 0.5, 0), Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X,
		Text = "Made By Enviel", Font = Enum.Font.Gotham, TextColor3 = Window.Theme.TextDark, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right, BackgroundTransparency = 1
	})
	
	local CloseBtn = Create("ImageButton", {
		Parent = Controls, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(20, 20),
		BackgroundTransparency = 1, Image = GetIcon("x") or "", ImageColor3 = Window.Theme.TextDark
	})
	-- Cleanup on Close
	CloseBtn.MouseButton1Click:Connect(function() 
		Window:Prompt({
			Title = "Close Interface?",
			Content = "Are you sure you want to close Enviel UI?",
			Actions = {
				{Text = "Cancel", Callback = function() end}, 
				{Text = "Confirm", Callback = function() 
					ScreenGui:Destroy() 
					-- Cleanup Connections
					for _, c in pairs(Window.Connections) do c:Disconnect() end
					Window.Connections = {}
				end}
			}
		})
	end)

	local MinBtn = Create("ImageButton", {
		Parent = Controls, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -30, 0.5, 0), Size = UDim2.fromOffset(20, 20),
		BackgroundTransparency = 1, Image = GetIcon("minimize") or "", ImageColor3 = Window.Theme.TextDark
	})
	
	
	local SafeArea = GuiService:GetGuiInset()
	local MiniButton = Create("CanvasGroup", {
		Name = "MiniButton", Parent = ScreenGui, BackgroundColor3 = Window.Theme.Main, Size = UDim2.fromOffset(45, 45),
		Position = UDim2.new(0, SafeArea.X + 20, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5), Visible = false, GroupTransparency = 1
	})
	local MiniClick = Create("TextButton", {
		Parent = MiniButton, Size = UDim2.fromScale(1,1), BackgroundTransparency = 1, Text = ""
	})
	Create("UICorner", {Parent = MiniButton, CornerRadius = UDim.new(0, 10)})
	Create("UIStroke", {Parent = MiniButton, Color = Window.Theme.Stroke, Thickness = 1})
	
	local MiniIcon = Create("ImageLabel", {
		Parent = MiniButton, BackgroundTransparency = 1, Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5), Image = "rbxthumb://type=Asset&id="..LOGO_WHITE.."&w=150&h=150", ImageColor3 = Window.Theme.Accent
	})
	
	Dragify(MiniButton)
	
	
	-- Restore logic
	MiniClick.MouseButton1Click:Connect(function()
		Tween(MiniButton, {GroupTransparency = 1}, 0.3)
		Tween(ContentWindow, {GroupTransparency = 0}, 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		MainFrame.Visible = true
		MiniButton.Visible = false
	end)

	-- Minimize Logic
	MinBtn.MouseButton1Click:Connect(function()
		Tween(ContentWindow, {GroupTransparency = 1}, 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out).Completed:Wait()
		MainFrame.Visible = false
		MiniButton.Visible = true
		MiniButton.GroupTransparency = 1
		Tween(MiniButton, {GroupTransparency = 0}, 0.3)
	end)
	
	local NotifHolder = Create("Frame", {
		Parent = ScreenGui, BackgroundTransparency = 1, Size = UDim2.new(0, 300, 1, -20), 
		Position = UDim2.new(1, -320, 0, 20), AnchorPoint = Vector2.new(0, 0)
	})
	Create("UIListLayout", {Parent = NotifHolder, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10), VerticalAlignment = Enum.VerticalAlignment.Bottom})
	
	function Window:Notify(Cfg)
		local Title = Cfg.Title or "Notification"
		local Content = Cfg.Content or ""
		
		local F = Create("Frame", {
			Parent = NotifHolder, BackgroundColor3 = Window.Theme.Secondary, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 0.1
		})
		Create("UICorner", {Parent = F, CornerRadius = UDim.new(0, 8)})
		Create("UIListLayout", {Parent = F, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4)})
		Create("UIPadding", {Parent = F, PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12)})
		
		Create("TextLabel", {
			Parent = F, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18), Text = Title,
			Font = Enum.Font.GothamBold, TextColor3 = Window.Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left
		})
		Create("TextLabel", {
			Parent = F, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
			Text = Content, Font = Enum.Font.Gotham, TextColor3 = Window.Theme.TextDark, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true
		})
		
		task.delay(Cfg.Duration or 3, function()
			Tween(F, {BackgroundTransparency = 1}, 0.5)
			for _, v in pairs(F:GetChildren()) do if v:IsA("TextLabel") then Tween(v, {TextTransparency = 1}, 0.5) end end
			task.wait(0.5)
			F:Destroy()
		end)
	end
	
	local ContentHolder = Create("Frame", {
		Parent = ContentWindow, BackgroundTransparency = 1, Size = UDim2.new(1, -40, 1, -80), Position = UDim2.new(0, 20, 0, 60), ClipsDescendants = true
	})
	
	local Dock = Create("Frame", {
		Parent = MainFrame, BackgroundColor3 = Window.Theme.Secondary, Size = UDim2.new(0, 0, 0, 46), Position = UDim2.new(0.5, 0, 1, 12),
		AnchorPoint = Vector2.new(0.5, 0), AutomaticSize = Enum.AutomaticSize.X
	})
	Create("UICorner", {Parent = Dock, CornerRadius = UDim.new(1, 0)})

	

	local DockList = Create("Frame", {Parent = Dock, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0)})
	Create("UIListLayout", {Parent = DockList, FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 10), HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center})
	Create("UIPadding", {Parent = DockList, PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6)})
	
	local ActiveIndicator = Create("Frame", {
		Parent = Dock, BackgroundColor3 = Window.Theme.Accent, Size = UDim2.new(0, 0, 1, -8), Position = UDim2.new(0, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5), ZIndex = 0
	})
	Create("UICorner", {Parent = ActiveIndicator, CornerRadius = UDim.new(1, 0)})

	function Window:SelectTab(TabId)
		for _, p in pairs(ContentHolder:GetChildren()) do 
			if p:IsA("ScrollingFrame") then p.Visible = false end 
		end
		
		local Page = ContentHolder:FindFirstChild(TabId)
		if Page then
			Page.Visible = true
			
			local Btn = DockList:FindFirstChild(TabId.."Btn")
			if Btn then
				task.spawn(function()
					local TargetX = Btn.AbsolutePosition.X - Dock.AbsolutePosition.X
					
					Tween(ActiveIndicator, {
						Size = UDim2.new(0, Btn.AbsoluteSize.X, 1, -8), 
						Position = UDim2.new(0, TargetX, 0.5, 0)
					}, 0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
				end)

				for _, b in pairs(DockList:GetChildren()) do
					if b:IsA("TextButton") then
						local TargetColor = (b == Btn) and Color3.new(0,0,0) or Window.Theme.TextDark
						Tween(b, {TextColor3 = TargetColor}, 0.3)
					end
				end
			end
		end
	end

	function Window:CreateTab(Config)
		local TabName = (type(Config) == "table" and Config.Name) or Config
		local TabId = "Tab_"..TabName:gsub(" ", "")
		
		local Btn = Create("TextButton", {
			Name = TabId.."Btn", Parent = DockList, BackgroundTransparency = 1, Text = "  "..TabName.."  ", Font = Enum.Font.GothamBold,
			TextColor3 = Window.Theme.TextDark, TextSize = 14, Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, ZIndex = 2
		})
		Create("UIPadding", {Parent = Btn, PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12)})
		Btn.MouseButton1Click:Connect(function() Window:SelectTab(TabId) end)
		
		local Page = Create("ScrollingFrame", {
			Name = TabId, Parent = ContentHolder, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Visible = false,
			ScrollBarThickness = 2, ScrollBarImageColor3 = Window.Theme.Stroke, CanvasSize = UDim2.new(0, 0, 0, 0)
		})
		Create("UIListLayout", {Parent = Page, Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder})
		Create("UIPadding", {Parent = Page, PaddingBottom = UDim.new(0, 10)})
		Page.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() 
			Page.CanvasSize = UDim2.new(0, 0, 0, Page.UIListLayout.AbsoluteContentSize.Y + 20) 
		end)
		
		local Elements = {}
		
		function Elements:CreateSection(Text)
			Create("TextLabel", {
				Parent = Page, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24), Text = Text,
				Font = Enum.Font.GothamBold, TextColor3 = Window.Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left
			})
		end
		
		function Elements:CreateParagraph(Cfg)
			local F = Create("Frame", {Parent = Page, BackgroundColor3 = Window.Theme.Secondary, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y})
			Create("UICorner", {Parent = F, CornerRadius = UDim.new(0, 8)})

			Create("UIPadding", {Parent = F, PaddingTop = UDim.new(0,10), PaddingBottom = UDim.new(0,10), PaddingLeft = UDim.new(0,12), PaddingRight = UDim.new(0,12)})
			Create("TextLabel", {Parent = F, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,18), Text = Cfg.Title or "Header", Font = Enum.Font.GothamBold, TextColor3 = Window.Theme.Text, TextSize=13, TextXAlignment=Enum.TextXAlignment.Left})
			Create("TextLabel", {Parent = F, BackgroundTransparency = 1, Position=UDim2.new(0,0,0,20), Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y, Text = Cfg.Content or "", Font = Enum.Font.Gotham, TextColor3 = Window.Theme.TextDark, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true})
		end

		function Elements:CreateButton(Config)
			local F = Create("Frame", {Parent = Page, BackgroundColor3 = Window.Theme.Secondary, Size = UDim2.new(1, 0, 0, 42)})
			Create("UICorner", {Parent = F, CornerRadius = UDim.new(0, 8)})

			
			Create("TextLabel", {
				Parent = F, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 0), Size = UDim2.new(1, -95, 1, 0),
				Text = Config.Name or "Button", Font = Enum.Font.GothamBold, TextColor3 = Window.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
			})
			
			local B = Create("TextButton", {
				Parent = F, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.new(0, 80, 0, 28),
				BackgroundColor3 = Window.Theme.Stroke, Text = Config.Text or "Interact", Font = Enum.Font.GothamBold, TextColor3 = Window.Theme.Text, TextSize = 11, AutoButtonColor=false
			})
			Create("UICorner", {Parent = B, CornerRadius = UDim.new(0, 6)})
			
			B.MouseButton1Click:Connect(function()
				Tween(B, {Size = UDim2.new(0, 76, 0, 26)}, 0.05).Completed:Wait()
				Tween(B, {Size = UDim2.new(0, 80, 0, 28)}, 0.05)
				if Config.Callback then Config.Callback() end
			end)
		end

		function Elements:CreateToggle(Config)
			local F = Create("Frame", {Parent = Page, BackgroundColor3 = Window.Theme.Secondary, Size = UDim2.new(1, 0, 0, 42)})
			Create("UICorner", {Parent = F, CornerRadius = UDim.new(0, 8)})

			
			Create("TextLabel", {
				Parent = F, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 0), Size = UDim2.new(1, -70, 1, 0),
				Text = Config.Name or "Toggle", Font = Enum.Font.GothamBold, TextColor3 = Window.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
			})
			
			local Val = Config.CurrentValue or Config.Default or false
			local Switch = Create("TextButton", {
				Parent = F, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.new(0, 44, 0, 22),
				BackgroundColor3 = Val and Window.Theme.Accent or Window.Theme.Stroke, Text = "", AutoButtonColor = false
			})
			Create("UICorner", {Parent = Switch, CornerRadius = UDim.new(1, 0)})
			local Circle = Create("Frame", {
				Parent = Switch, BackgroundColor3 = Val and Window.Theme.Secondary or Window.Theme.Text, Size = UDim2.new(0, 18, 0, 18),
				Position = Val and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
			})
			Create("UICorner", {Parent = Circle, CornerRadius = UDim.new(1, 0)})
			
			local function Update()
				Tween(Switch, {BackgroundColor3 = Val and Window.Theme.Accent or Window.Theme.Stroke}, 0.2)
				Tween(Circle, {Position = Val and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9), BackgroundColor3 = Val and Window.Theme.Secondary or Window.Theme.Text}, 0.2)
				if Config.Flag then Window.Flags[Config.Flag] = Val end
				if Config.Callback then Config.Callback(Val) end
			end
			Switch.MouseButton1Click:Connect(function() Val = not Val Update() end)
			if Config.Default then Update() end
			return {Set = function(self, v) Val = v Update() end}
		end

		function Elements:CreateSlider(Config)
			local Min, Max = Config.Min or 0, Config.Max or 100
			local Val = Config.Default or Min
			local F = Create("Frame", {Parent = Page, BackgroundColor3 = Window.Theme.Secondary, Size = UDim2.new(1, 0, 0, 50)})
			Create("UICorner", {Parent = F, CornerRadius = UDim.new(0, 8)})

			
			Create("TextLabel", {
				Parent = F, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 5), Size = UDim2.new(1, -50, 0, 20),
				Text = Config.Name or "Slider", Font = Enum.Font.GothamBold, TextColor3 = Window.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
			})
			local ValLbl = Create("TextLabel", {
				Parent = F, BackgroundTransparency = 1, Position = UDim2.new(1, -50, 0, 5), Size = UDim2.new(0, 40, 0, 20),
				Text = tostring(Val), Font = Enum.Font.Gotham, TextColor3 = Window.Theme.TextDark, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right
			})
			local Track = Create("TextButton", {
				Parent = F, BackgroundColor3 = Window.Theme.Stroke, Position = UDim2.new(0, 15, 0, 32), Size = UDim2.new(1, -30, 0, 6), Text = "", AutoButtonColor = false
			})
			Create("UICorner", {Parent = Track, CornerRadius = UDim.new(1, 0)})
			local Fill = Create("Frame", {Parent = Track, BackgroundColor3 = Window.Theme.Accent, Size = UDim2.new((Val-Min)/(Max-Min), 0, 1, 0)})
			Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(1, 0)})
			local Thumb = Create("Frame", {
				Parent = Track, BackgroundColor3 = Window.Theme.Accent, Size = UDim2.fromOffset(16, 16),
				Position = UDim2.new((Val-Min)/(Max-Min), -8, 0.5, -8), ZIndex = 2
			})
			Create("UICorner", {Parent = Thumb, CornerRadius = UDim.new(1, 0)})
			Create("UIStroke", {Parent = Thumb, Color = Window.Theme.Secondary, Thickness = 2})
			
			local function Update(Input)
				local Pct = math.clamp((Input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
				Val = math.floor(Min + (Max - Min) * Pct)
				Fill.Size = UDim2.new(Pct, 0, 1, 0)
				Thumb.Position = UDim2.new(Pct, -8, 0.5, -8)
				ValLbl.Text = tostring(Val)
				if Config.Flag then Window.Flags[Config.Flag] = Val end
				if Config.Callback then Config.Callback(Val) end
			end
			
			local Sliding = false
			Track.InputBegan:Connect(function(input) 
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
					Sliding = true 
					Update(input) 
				end 
			end)
			UserInputService.InputEnded:Connect(function(input) 
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
					Sliding = false 
				end 
			end)
			UserInputService.InputChanged:Connect(function(input) 
				if Sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then 
					Update(input) 
				end 
			end)
			return {Set = function(self, v) 
				Val = math.clamp(v, Min, Max) 
				local Pct = (Val-Min)/(Max-Min)
				Fill.Size = UDim2.new(Pct, 0, 1, 0) 
				Thumb.Position = UDim2.new(Pct, -8, 0.5, -8)
				ValLbl.Text = tostring(Val) 
			end}
		end

		function Elements:CreateInput(Config)
			local F = Create("Frame", {Parent = Page, BackgroundColor3 = Window.Theme.Secondary, Size = UDim2.new(1, 0, 0, 46)})
			Create("UICorner", {Parent = F, CornerRadius = UDim.new(0, 8)})

			Create("TextLabel", {
				Parent = F, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 0), Size = UDim2.new(1, -15, 0, 24),
				Text = Config.Name or "Input", Font = Enum.Font.GothamBold, TextColor3 = Window.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
			})
			local Box = Create("TextBox", {
				Parent = F, BackgroundColor3 = Window.Theme.Main, Position = UDim2.new(0, 15, 0, 24), Size = UDim2.new(1, -30, 0, 16),
				Text = "", PlaceholderText = Config.PlaceholderText or "...", Font = Enum.Font.Gotham, TextColor3 = Window.Theme.TextDark, 
				PlaceholderColor3 = Color3.fromRGB(80, 80, 80), TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, ClearTextOnFocus = false
			})
			Box.FocusLost:Connect(function()
				if Config.Flag then Window.Flags[Config.Flag] = Box.Text end
				if Config.Callback then Config.Callback(Box.Text) end
				if Config.RemoveTextAfterFocusLost then Box.Text = "" end
			end)
		end
		
		function Elements:CreateDropdown(Config)
			local Options = Config.Options or {}
			local Default = Config.Default or Options[1]
			local Dropped = false
			
			local F = Create("Frame", {Parent = Page, BackgroundColor3 = Window.Theme.Secondary, Size = UDim2.new(1, 0, 0, 42), ClipsDescendants = true})
			Create("UICorner", {Parent = F, CornerRadius = UDim.new(0, 8)})

			
			local Top = Create("TextButton", {Parent = F, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 42), Text = ""})
			Create("TextLabel", {Parent = Top, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 0), Size = UDim2.new(1, -40, 1, 0), Text = Config.Name, Font = Enum.Font.GothamBold, TextColor3 = Window.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
			local Current = Create("TextLabel", {Parent = Top, BackgroundTransparency = 1, Position = UDim2.new(1, -120, 0, 0), Size = UDim2.new(0, 100, 1, 0), Text = tostring(Default), Font = Enum.Font.Gotham, TextColor3 = Window.Theme.TextDark, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right})
			
			local List = Create("ScrollingFrame", {
				Parent = F, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 42), Size = UDim2.new(1, 0, 1, -42), 
				ScrollBarThickness = 2, ScrollBarImageColor3 = Window.Theme.Stroke, CanvasSize = UDim2.new(0, 0, 0, 0)
			})
			Create("UIListLayout", {Parent = List, SortOrder = Enum.SortOrder.LayoutOrder})
			
			local function Refresh()
				for _, v in pairs(List:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
				for _, opt in pairs(Options) do
					local b = Create("TextButton", {
						Parent = List, BackgroundColor3 = Window.Theme.Main, Size = UDim2.new(1, 0, 0, 30),
						Text = "   "..tostring(opt), Font = Enum.Font.Gotham, TextColor3 = Window.Theme.TextDark, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false
					})
					b.MouseButton1Click:Connect(function()
						Default = opt
						Current.Text = tostring(opt)
						Dropped = false
						Tween(F, {Size = UDim2.new(1, 0, 0, 42)}, 0.2)
						if Config.Flag then Window.Flags[Config.Flag] = opt end
						if Config.Callback then Config.Callback(opt) end
					end)
				end
				List.CanvasSize = UDim2.new(0, 0, 0, #Options * 30)
			end
			Refresh()
			
			Top.MouseButton1Click:Connect(function()
				Dropped = not Dropped
				Tween(F, {Size = UDim2.new(1, 0, 0, Dropped and (42 + math.min(#Options, 5) * 30) or 42)}, 0.2)
			end)
		end
		
		function Elements:CreateColorPicker(Config)
			local Flag = Config.Flag or Config.Name
			local Val = Config.Default or Color3.fromRGB(255, 255, 255)
			local Expanded = false
			
			local BaseH = 42
			local ExpandH = 42 + 60
			
			local F = Create("Frame", {Parent = Page, BackgroundColor3 = Window.Theme.Secondary, Size = UDim2.new(1, 0, 0, BaseH), ClipsDescendants = true})
			Create("UICorner", {Parent = F, CornerRadius = UDim.new(0, 8)})

			
			local Top = Create("TextButton", {Parent = F, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 42), Text = "", AutoButtonColor = false})
			Create("TextLabel", {Parent = Top, BackgroundTransparency=1, Position=UDim2.new(0,15,0,0), Size=UDim2.new(1,-60,0,42), Text = Config.Name or "Color Picker", Font = Enum.Font.GothamBold, TextColor3 = Window.Theme.Text, TextSize=13, TextXAlignment=Enum.TextXAlignment.Left})
			
			local Preview = Create("Frame", {Parent = Top, Position=UDim2.new(1,-45,0,10), Size=UDim2.new(0,30,0,22), BackgroundColor3 = Val})
			Create("UICorner", {Parent = Preview, CornerRadius = UDim.new(0, 6)})

			local SliderCont = Create("Frame", {Parent = F, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 42), Size = UDim2.new(1, -20, 0, 60)})
			
			local function MakeSlider(Prop, YVal, Color)
				local S = Create("Frame", {Parent = SliderCont, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, YVal), Size = UDim2.new(1, 0, 0, 16)})
				local Bar = Create("TextButton", {Parent = S, BackgroundColor3 = Window.Theme.Stroke, Position = UDim2.new(0, 0, 0.5, -3), Size = UDim2.new(1, 0, 0, 6), Text = "", AutoButtonColor = false})
				Create("UICorner", {Parent = Bar, CornerRadius=UDim.new(1,0)})
				local Fill = Create("Frame", {
					Parent = Bar, BackgroundColor3 = Color, Size = UDim2.new(Val[Prop], 0, 1, 0)
				})
				Create("UICorner", {Parent = Fill, CornerRadius=UDim.new(1,0)})
				
				local function Update(Input)
					local Pct = math.clamp((Input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
					local R, G, B = Val.R, Val.G, Val.B
					if Prop == "R" then R = Pct elseif Prop == "G" then G = Pct else B = Pct end
					Val = Color3.new(R, G, B)
					Fill.Size = UDim2.new(Pct, 0, 1, 0)
					Preview.BackgroundColor3 = Val
					if Config.Flag then Window.Flags[Config.Flag] = Val end
					if Config.Callback then Config.Callback(Val) end
					
				end
				
				local Sliding = false
				Bar.InputBegan:Connect(function(i) 
					if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then 
						Sliding = true 
						Update(i) 
					end 
				end)
				UserInputService.InputEnded:Connect(function(i) 
					if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then 
						Sliding = false 
					end 
				end)
				UserInputService.InputChanged:Connect(function(i) 
					if Sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then 
						Update(i) 
					end 
				end)
				
				return {UpdateFill = function() Fill.Size = UDim2.new(Val[Prop], 0, 1, 0) end}
			end
			
			local RS = MakeSlider("R", 0, Color3.fromRGB(255, 50, 50))
			local GS = MakeSlider("G", 20, Color3.fromRGB(50, 255, 50))
			local BS = MakeSlider("B", 40, Color3.fromRGB(50, 50, 255))
			
			Top.MouseButton1Click:Connect(function()
				Expanded = not Expanded
				Tween(F, {Size = UDim2.new(1, 0, 0, Expanded and ExpandH or BaseH)}, 0.2)
				RS.UpdateFill() GS.UpdateFill() BS.UpdateFill()
			end)
		end

		return Elements
	end
	
	-- Alert / Prompt System
	function Window:Prompt(Config)
		local Title = Config.Title or "Alert"
		local Content = Config.Content or "Are you sure?"
		local Actions = Config.Actions or {{Text = "OK", Callback = function() end}}
		
		local Blur = Create("Frame", {
			Parent = ScreenGui, BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 1, Size = UDim2.fromScale(1,1), Name = "AlertBlur", ZIndex = 100
		})
		
		local AlertFrame = Create("CanvasGroup", {
			Parent = Blur, Size = UDim2.fromOffset(300, 160), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
			BackgroundColor3 = Window.Theme.Secondary, GroupTransparency = 1
		})
		Create("UICorner", {Parent = AlertFrame, CornerRadius = UDim.new(0, 12)})
		Create("UIStroke", {Parent = AlertFrame, Color = Window.Theme.Stroke, Thickness = 1})
		
		Create("TextLabel", {
			Parent = AlertFrame, Size = UDim2.new(1, 0, 0, 40), Position = UDim2.new(0, 0, 0, 10), BackgroundTransparency = 1,
			Text = Title, Font = Enum.Font.GothamBold, TextColor3 = Window.Theme.Text, TextSize = 16
		})
		
		Create("TextLabel", {
			Parent = AlertFrame, Size = UDim2.new(1, -40, 0, 40), Position = UDim2.new(0, 20, 0, 45), BackgroundTransparency = 1,
			Text = Content, Font = Enum.Font.Gotham, TextColor3 = Window.Theme.TextDark, TextSize = 13, TextWrapped = true
		})
		
		local BtnContainer = Create("Frame", {
			Parent = AlertFrame, Size = UDim2.new(1, -40, 0, 35), Position = UDim2.new(0, 20, 1, -50), BackgroundTransparency = 1
		})
		Create("UIListLayout", {Parent = BtnContainer, FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 10), HorizontalAlignment = Enum.HorizontalAlignment.Center})
		
		for _, Action in pairs(Actions) do
			local Btn = Create("TextButton", {
				Parent = BtnContainer, Size = UDim2.new(0.5, -5, 1, 0), BackgroundColor3 = Window.Theme.Stroke,
				Text = Action.Text, Font = Enum.Font.GothamBold, TextColor3 = Window.Theme.Text, TextSize = 12, AutoButtonColor = false
			})
			Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(0, 6)})
			Btn.MouseButton1Click:Connect(function()
				if Action.Callback then Action.Callback() end
				Tween(AlertFrame, {GroupTransparency = 1, Size = UDim2.fromOffset(280, 140)}, 0.2)
				Tween(Blur, {BackgroundTransparency = 1}, 0.2).Completed:Wait()
				Blur:Destroy()
			end)
		end
		
		Tween(Blur, {BackgroundTransparency = 0.4}, 0.3)
		Tween(AlertFrame, {GroupTransparency = 0, Size = UDim2.fromOffset(300, 160)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	end
	
	local ConfigName = Name:gsub(" ", "").."_Config.json"
	
	function Window:SaveConfig()
		SaveFile(ConfigName, Window.Flags)
		Window:Notify({Title = "Configuration", Content = "Settings saved to "..ConfigName})
	end
	
	function Window:LoadConfig()
		local Data = LoadFile(ConfigName)
		if Data then
			for Flag, Val in pairs(Data) do
				Window.Flags[Flag] = Val
			end
			Window:Notify({Title = "Configuration", Content = "Settings loaded from "..ConfigName})
		else
			Window:Notify({Title = "Configuration", Content = "No saved config found."})
		end
	end

	local Toggled = true
	function Window:Toggle()
		Toggled = not Toggled
		ScreenGui.Enabled = Toggled
	end
	
	UserInputService.InputBegan:Connect(function(input, gp)
		if not gp and input.KeyCode == Enum.KeyCode.RightControl then
			Window:Toggle()
		end
	end)

	return Window
end

return EnvielUI