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
	
	local MainScale = Create("UIScale", {Parent = MainFrame, Scale = 0.9}) -- Start smaller for animation
	
	local ContentWindow = Create("CanvasGroup", {
		Name = "ContentWindow", Parent = MainFrame, BackgroundColor3 = Window.Theme.Main,
		Size = UDim2.fromScale(1, 1), BorderSizePixel = 0, GroupTransparency = 1
	})
	
	-- Mobile Responsive Logic
	local Camera = Workspace.CurrentCamera
	local IsMobile = Camera.ViewportSize.X < 800
	
	-- Dynamic Sizing Constants
	local ItemH = IsMobile and 36 or 42
	local TextS = IsMobile and 11 or 13
	local TitleS = IsMobile and 14 or 18
	local HdrH = IsMobile and 38 or 50
	
	if IsMobile then 
		MainFrame.Size = UDim2.fromScale(0.60, 0.80)
		MainFrame.Position = UDim2.fromScale(0.5, 0.50)
	end
	
	Create("UICorner", {Parent = ContentWindow, CornerRadius = UDim.new(0, 14)})

	task.spawn(function()
		ContentWindow.GroupTransparency = 1
		Tween(MainScale, {Scale = 1}, 0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		Tween(ContentWindow, {GroupTransparency = 0}, 0.4)
	end)

	local LOGO_WHITE = "94854804824909"
	local LOGO_BLACK = "120261170817156"
	
	local Header = Create("Frame", {Parent = ContentWindow, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, HdrH)})
	Create("UIPadding", {Parent = Header, PaddingLeft = UDim.new(0, 20), PaddingRight = UDim.new(0, 20)})
	
	local LogoIcon = Create("ImageLabel", {
		Parent = Header, BackgroundTransparency = 1, Size = UDim2.fromOffset(24, 24), Position = UDim2.new(0, 0, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5),
		Image = "rbxthumb://type=Asset&id="..LOGO_WHITE.."&w=150&h=150", ImageColor3 = Window.Theme.Accent
	})
	
	Create("TextLabel", {
		Parent = Header, BackgroundTransparency = 1, Size = UDim2.new(0, 0, 1, 0), Position = UDim2.new(0, 32, 0, 0), AutomaticSize = Enum.AutomaticSize.X,
		Font = Enum.Font.GothamBold, Text = Name, TextColor3 = Window.Theme.Text, TextSize = TitleS, TextXAlignment = Enum.TextXAlignment.Left
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
	local MiniScale = Create("UIScale", {Parent = MiniButton, Scale = 0})

	local MiniClick = Create("TextButton", {
		Parent = MiniButton, Size = UDim2.fromScale(1,1), BackgroundTransparency = 1, Text = ""
	})
	Create("UICorner", {Parent = MiniButton, CornerRadius = UDim.new(0, 10)})
	Create("UIStroke", {Parent = MiniButton, Color = Window.Theme.Stroke, Thickness = 1})
	
	local MiniIcon = Create("ImageLabel", {
		Parent = MiniButton, BackgroundTransparency = 1, Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5), Image = "rbxthumb://type=Asset&id="..LOGO_WHITE.."&w=150&h=150", ImageColor3 = Window.Theme.Accent
	})
	
	Dragify(MiniClick, MiniButton)
	
	-- Restore logic
	MiniClick.MouseButton1Click:Connect(function()
		Tween(MiniScale, {Scale = 0}, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		Tween(MiniButton, {GroupTransparency = 1}, 0.3).Completed:Wait()
		
		MiniButton.Visible = false
		MainFrame.Visible = true
		
		-- Pop Main Window (0 -> 1)
		MainScale.Scale = 0
		ContentWindow.GroupTransparency = 1
		local D = MainFrame:FindFirstChild("Dock")
		if D and D:IsA("CanvasGroup") then D.GroupTransparency = 1 end
		
		Tween(MainScale, {Scale = 1}, 0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		Tween(ContentWindow, {GroupTransparency = 0}, 0.4)
		if D and D:IsA("CanvasGroup") then Tween(D, {GroupTransparency = 0}, 0.4) end
	end)
	
	-- Minimize logic
	MinBtn.MouseButton1Click:Connect(function()
		-- Shrink Main Window (1 -> 0)
		Tween(MainScale, {Scale = 0}, 0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		Tween(ContentWindow, {GroupTransparency = 1}, 0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		
		local D = MainFrame:FindFirstChild("Dock")
		if D and D:IsA("CanvasGroup") then Tween(D, {GroupTransparency = 1}, 0.4) end
		
		task.wait(0.3)
		MainFrame.Visible = false
		
		MiniButton.Visible = true
		MiniButton.GroupTransparency = 1
		MiniScale.Scale = 0
		Tween(MiniButton, {GroupTransparency = 0}, 0.3)
		Tween(MiniScale, {Scale = 1}, 0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	end)
	
	local NotifHolder = Create("Frame", {
		Parent = ScreenGui, BackgroundTransparency = 1, Size = UDim2.new(0, 300, 1, -20), 
		Position = UDim2.new(1, -320, 0, 20), AnchorPoint = Vector2.new(0, 0)
	})
	Create("UIListLayout", {Parent = NotifHolder, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10), VerticalAlignment = Enum.VerticalAlignment.Bottom})
	
	function Window:Notify(Cfg)
		local Title = Cfg.Title or "Notification"
		local Content = Cfg.Content or ""
		local Duration = Cfg.Duration or 3
		
		-- Wrapper for layout spacing
		local Wrapper = Create("Frame", {
			Parent = NotifHolder, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), ClipsDescendants = true
		})
		
		-- Actual Notification Card
		local F = Create("Frame", {
			Parent = Wrapper, BackgroundColor3 = Window.Theme.Secondary, 
			Size = UDim2.new(1, -4, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
			Position = UDim2.new(1.5, 0, 0, 0) -- Start off-screen right
		})
		
		Create("UICorner", {Parent = F, CornerRadius = UDim.new(0, 6)})
		Create("UIStroke", {Parent = F, Color = Window.Theme.Stroke, Thickness = 1})
		
		-- Accent Bar (Left Side)
		local Accent = Create("Frame", {
			Parent = F, BackgroundColor3 = Window.Theme.Accent,
			Size = UDim2.new(0, 3, 1, -12), Position = UDim2.new(0, 6, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5)
		})
		Create("UICorner", {Parent = Accent, CornerRadius = UDim.new(1, 0)})
		
		-- Layout inside card
		local ContentPad = Create("Frame", {
			Parent = F, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 16, 0, 0)
		})
		Create("UIListLayout", {Parent = ContentPad, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)})
		Create("UIPadding", {Parent = ContentPad, PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)})

		Create("TextLabel", {
			Parent = ContentPad, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16), Text = Title,
			Font = Enum.Font.GothamBold, TextColor3 = Window.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
		})
		Create("TextLabel", {
			Parent = ContentPad, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
			Text = Content, Font = Enum.Font.Gotham, TextColor3 = Window.Theme.TextDark, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true
		})
		
		-- Animation Logic
		task.spawn(function()
			-- 1. Expand Wrapper Height
			local TargetSize = F.AbsoluteSize.Y
			if TargetSize < 40 then TargetSize = 60 end -- Fallback
			Tween(Wrapper, {Size = UDim2.new(1, 0, 0, TargetSize + 6)}, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			
			-- 2. Slide In (from Right)
			Tween(F, {Position = UDim2.new(0, 2, 0, 0)}, 0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		end)
		
		task.delay(Duration, function()
			-- 3. Slide Out (to Right)
			Tween(F, {Position = UDim2.new(1.5, 0, 0, 0)}, 0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
			
			-- 4. Collapse Wrapper
			task.wait(0.2)
			Tween(Wrapper, {Size = UDim2.new(1, 0, 0, 0)}, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out).Completed:Wait()
			Wrapper:Destroy()
		end)
	end
	
	function Window:OpenDropdownModal(Config, Callback)
		local Options = Config.Options or {}
		local Multi = Config.Multi or false
		local Current = Config.CurrentValue or (Multi and {} or Options[1])
		
		-- Blur Effect
		local Blur = game:GetService("Lighting"):FindFirstChild("EnvielBlur") or Instance.new("BlurEffect", game:GetService("Lighting"))
		Blur.Name = "EnvielBlur"
		Blur.Enabled = true
		Blur.Size = 0
		
		-- Overlay
		local Overlay = Create("TextButton", {
			Name = "ModalOverlay", Parent = ContentWindow, BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1), AutoButtonColor = false, Text = "", ZIndex = 50
		})
		
		local Container = Create("Frame", {
			Name = "DropdownModal", Parent = Overlay, BackgroundColor3 = Window.Theme.Main,
			Size = UDim2.new(0.5, 0, 0, IsMobile and 250 or 300), Position = UDim2.new(0.5, 0, 1.5, 0), -- Start below
			AnchorPoint = Vector2.new(0.5, 1), ZIndex = 10, BorderSizePixel = 0
		})
		Create("UICorner", {Parent = Container, CornerRadius = UDim.new(0, 16)})
		-- Patch for square bottom corners
		local Patch = Create("Frame", {
			Parent = Container, BackgroundColor3 = Window.Theme.Main, Size = UDim2.new(1, 0, 0, 20),
			Position = UDim2.new(0, 0, 1, -10), ZIndex = 9, BorderSizePixel = 0
		})
		
		-- Header
		local Header = Create("Frame", {
			Parent = Container, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 90) -- Increased Height
		})
		Create("UIPadding", {Parent = Header, PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16), PaddingTop = UDim.new(0, 12)})
		
		Create("TextLabel", {
			Parent = Header, BackgroundTransparency = 1, Size = UDim2.new(1, -40, 0, 20), -- -40 to account for padding & close btn
			Text = Config.Name or "Select Option", Font = Enum.Font.GothamBold, TextColor3 = Window.Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left
		})
		
		local CloseBtn = Create("ImageButton", {
			Parent = Header, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.fromOffset(20, 20),
			BackgroundTransparency = 1, Image = GetIcon("x") or "rbxassetid://6031094678", ImageColor3 = Window.Theme.TextDark
		})
		
		-- Search Bar
		local SearchBg = Create("Frame", {
			Parent = Header, BackgroundColor3 = Window.Theme.Secondary, Size = UDim2.new(1, -32, 0, 36), -- -32 for padding
			Position = UDim2.new(0, 0, 0, 36) -- Moved down for spacing
		})
		Create("UICorner", {Parent = SearchBg, CornerRadius = UDim.new(0, 10)})
		Create("UIStroke", {Parent = SearchBg, Color = Window.Theme.Stroke, Thickness = 1})
		
		local SearchIcon = Create("ImageLabel", {
			Parent = SearchBg, BackgroundTransparency = 1, Size = UDim2.fromOffset(16, 16), Position = UDim2.new(0, 12, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5), Image = GetIcon("search") or "rbxassetid://6031154871", ImageColor3 = Window.Theme.TextDark
		})
		
		local SearchInput = Create("TextBox", {
			Parent = SearchBg, BackgroundTransparency = 1, Size = UDim2.new(1, -44, 1, 0), Position = UDim2.new(0, 38, 0, 0),
			Text = "", PlaceholderText = "Search...", Font = Enum.Font.Gotham, TextSize = 13,
			TextColor3 = Window.Theme.Text, PlaceholderColor3 = Window.Theme.TextDark, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false
		})

		-- Content List
		local List = Create("ScrollingFrame", {
			Parent = Container, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, -100), Position = UDim2.new(0, 0, 0, 100),
			ScrollBarThickness = 2, ScrollBarImageColor3 = Window.Theme.Stroke, CanvasSize = UDim2.new(0, 0, 0, 0)
		})
		Create("UIListLayout", {Parent = List, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6)})
		Create("UIPadding", {Parent = List, PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingBottom = UDim.new(0, 20)})
		
		local function Close()
			Tween(Container, {Position = UDim2.new(0.5, 0, 1.5, 0)}, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
			Tween(Overlay, {BackgroundTransparency = 1}, 0.3).Completed:Wait()
			Overlay:Destroy()
		end
		
		CloseBtn.MouseButton1Click:Connect(Close)
		Overlay.MouseButton1Click:Connect(Close) -- Click outside to close
		
		local tempSelected = Multi and {unpack(Current)} or Current

		local function Refresh(Query)
			for _, v in pairs(List:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
			
			local filtered = {}
			for _, opt in pairs(Options) do
				if not Query or string.find(tostring(opt):lower(), Query:lower()) then
					table.insert(filtered, opt)
				end
			end
			
			for _, opt in pairs(filtered) do
				local isSelected = false
				if Multi then
					for _, s in pairs(tempSelected) do if s == opt then isSelected = true break end end
				else
					isSelected = (tempSelected == opt)
				end
				
				local Item = Create("TextButton", {
					Parent = List, BackgroundColor3 = isSelected and Window.Theme.Secondary or Window.Theme.Main,
					Size = UDim2.new(1, 0, 0, 42), Text = "  "..tostring(opt), Font = Enum.Font.Gotham,
					TextColor3 = isSelected and Window.Theme.Accent or Window.Theme.TextDark, TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false,
					BorderSizePixel = 0
				})
				Create("UICorner", {Parent = Item, CornerRadius = UDim.new(0, 8)})
				if isSelected then Create("UIStroke", {Parent = Item, Color = Window.Theme.Stroke, Thickness = 1}) end
				
				Item.MouseButton1Click:Connect(function()
					if Multi then
						local idx = table.find(tempSelected, opt)
						if idx then table.remove(tempSelected, idx) else table.insert(tempSelected, opt) end
						Callback(tempSelected)
						Refresh(SearchInput.Text)
					else
						Callback(opt)
						Close()
					end
				end)
			end
			
			-- Dynamic Weight Calculation
			local RowHeight = 48 -- 42 Item + 6 Padding
			local ContentHeight = #filtered * RowHeight + 20 -- + PaddingBottom
			local MinH = 180
			local MaxH = IsMobile and 350 or 400
			local TargetH = math.clamp(ContentHeight + 100, MinH, MaxH) -- + Header/Search Height
			
			List.CanvasSize = UDim2.new(0, 0, 0, ContentHeight)
			Tween(Container, {Size = UDim2.new(0.5, 0, 0, TargetH)}, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		end
		
		SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
			Refresh(SearchInput.Text)
		end)
		
		Refresh()
		
		-- Animate In (No 3D Blur, just Dark Overlay)
		Tween(Overlay, {BackgroundTransparency = 0.1}, 0.3)
		Tween(Container, {Position = UDim2.new(0.5, 0, 1, 0)}, 0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	end

	
	local ContentHolder = Create("CanvasGroup", {
		Parent = ContentWindow, BackgroundTransparency = 1, Size = UDim2.new(1, -40, 1, -(HdrH + 30)), Position = UDim2.new(0, 20, 0, HdrH + 10), 
		GroupTransparency = 0, BorderSizePixel = 0
	})
	
	local NavH = IsMobile and 30 or 40
	local NavP = IsMobile and 4 or 12
	local Dock = Create("CanvasGroup", {
		Name = "Dock", Parent = MainFrame, BackgroundColor3 = Window.Theme.Secondary, 
		Size = UDim2.new(0, 0, 0, NavH), Position = UDim2.new(0.5, 0, 1, NavP),
		AnchorPoint = Vector2.new(0.5, 0), AutomaticSize = Enum.AutomaticSize.X,
		GroupTransparency = 0, BorderSizePixel = 0
	})
	
	-- In Animation for Dock
	task.spawn(function()
		Dock.GroupTransparency = 1
		Tween(Dock, {GroupTransparency = 0}, 0.4)
	end)
	Create("UICorner", {Parent = Dock, CornerRadius = UDim.new(1, 0)})

	

	local DockList = Create("Frame", {Parent = Dock, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0)})
	Create("UIListLayout", {Parent = DockList, FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 10), HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center})
	Create("UIPadding", {Parent = DockList, PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6)})
	
	local ActiveIndicator = Create("Frame", {
		Parent = Dock, BackgroundColor3 = Window.Theme.Accent, Size = UDim2.new(0, 0, 1, -8), Position = UDim2.new(0, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 0
	})
	Create("UICorner", {Parent = ActiveIndicator, CornerRadius = UDim.new(1, 0)})

	function Window:SelectTab(TabId)
		-- Fade Out Current
		Tween(ContentHolder, {GroupTransparency = 1}, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out).Completed:Wait()

		for _, p in pairs(ContentHolder:GetChildren()) do 
			if p:IsA("ScrollingFrame") then p.Visible = false end 
		end
		
		local Page = ContentHolder:FindFirstChild(TabId)
		if Page then
			Page.Visible = true
			
			local Btn = DockList:FindFirstChild(TabId.."Btn")
			if Btn then
				task.spawn(function()
					local CenterX = (Btn.AbsolutePosition.X - Dock.AbsolutePosition.X) + (Btn.AbsoluteSize.X / 2)
					
					Tween(ActiveIndicator, {
						Size = UDim2.new(0, Btn.AbsoluteSize.X, 1, -8), 
						Position = UDim2.new(0, CenterX, 0.5, 0)
					}, 0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
				end)

				for _, b in pairs(DockList:GetChildren()) do
					if b:IsA("TextButton") then
						local TargetColor = (b == Btn) and Color3.new(0,0,0) or Window.Theme.TextDark
						Tween(b, {TextColor3 = TargetColor}, 0.3)
					end
				end
			end
			-- Fade In New
			Tween(ContentHolder, {GroupTransparency = 0}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		end
	end

	function Window:CreateTab(Config)
		local TabName = (type(Config) == "table" and Config.Name) or Config
		local TabId = "Tab_"..TabName:gsub(" ", "")
		
		local Btn = Create("TextButton", {
			Name = TabId.."Btn", Parent = DockList, BackgroundTransparency = 1, Text = TabName, Font = Enum.Font.GothamBold,
			TextColor3 = Window.Theme.TextDark, TextSize = TextS + 1, Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, ZIndex = 2,
			TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Center
		})
		Create("UIPadding", {Parent = Btn, PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16)})
		Btn.MouseButton1Click:Connect(function() Window:SelectTab(TabId) end)
		
		local Page = Create("ScrollingFrame", {
			Name = TabId, Parent = ContentHolder, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Visible = false,
			ScrollBarThickness = 0, ScrollBarImageColor3 = Window.Theme.Stroke, CanvasSize = UDim2.new(0, 0, 0, 0)
		})

		-- Auto Select First Tab
		local TabCount = 0
		for _, v in pairs(DockList:GetChildren()) do
			if v:IsA("TextButton") then TabCount += 1 end
		end
		if TabCount == 1 then
			task.spawn(function()
				task.wait()
				Window:SelectTab(TabId)
			end)
		end
		Create("UIListLayout", {Parent = Page, Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder})
		Create("UIPadding", {Parent = Page, PaddingBottom = UDim.new(0, 10)})
		Page.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() 
			Page.CanvasSize = UDim2.new(0, 0, 0, Page.UIListLayout.AbsoluteContentSize.Y + 20) 
		end)
		
		local Elements = {}
		
		function Elements:CreateSection(Text)
			Create("TextLabel", {
				Parent = Page, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24), Text = Text,
				Font = Enum.Font.GothamBold, TextColor3 = Window.Theme.Text, TextSize = TextS + 1, TextXAlignment = Enum.TextXAlignment.Left
			})
		end

		function Elements:CreateGroup(Config)
			local Text = (type(Config) == "table" and Config.Name) or Config
			Elements:CreateSection(Text)
			return Elements
		end
		
		function Elements:CreateParagraph(Cfg)
			local F = Create("Frame", {Parent = Page, BackgroundColor3 = Window.Theme.Secondary, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y})
			Create("UICorner", {Parent = F, CornerRadius = UDim.new(0, 8)})

			Create("UIPadding", {Parent = F, PaddingTop = UDim.new(0,10), PaddingBottom = UDim.new(0,10), PaddingLeft = UDim.new(0,12), PaddingRight = UDim.new(0,12)})
			Create("TextLabel", {Parent = F, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,18), Text = Cfg.Title or "Header", Font = Enum.Font.GothamBold, TextColor3 = Window.Theme.Text, TextSize=13, TextXAlignment=Enum.TextXAlignment.Left})
			Create("TextLabel", {Parent = F, BackgroundTransparency = 1, Position=UDim2.new(0,0,0,20), Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y, Text = Cfg.Content or "", Font = Enum.Font.Gotham, TextColor3 = Window.Theme.TextDark, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true})
		end

		function Elements:CreateButton(Config)
			local F = Create("Frame", {Parent = Page, BackgroundColor3 = Window.Theme.Secondary, Size = UDim2.new(1, 0, 0, ItemH)})
			Create("UICorner", {Parent = F, CornerRadius = UDim.new(0, 8)})

			
			local B = Create("TextButton", {
				Parent = F, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
				Font = Enum.Font.GothamBold, Text = Config.Name or "Button", TextColor3 = Window.Theme.Text, TextSize = TextS,
				TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false
			})
			
			local B = Create("TextButton", {
				Parent = F, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.new(0, 80, 0, 28),
				BackgroundColor3 = Window.Theme.Text, Text = Config.Text or "Interact", Font = Enum.Font.GothamBold, TextColor3 = Color3.new(0,0,0), TextSize = 11, AutoButtonColor=false
			})
			Create("UICorner", {Parent = B, CornerRadius = UDim.new(0, 6)})
			
			local BScale = Create("UIScale", {Parent = B, Scale = 1})

			B.MouseButton1Click:Connect(function()
				Tween(BScale, {Scale = 0.95}, 0.05).Completed:Wait()
				Tween(BScale, {Scale = 1}, 0.1, Enum.EasingStyle.Quint)
				if Config.Callback then Config.Callback() end
			end)
		end

		function Elements:CreateToggle(Config)
			local F = Create("Frame", {Parent = Page, BackgroundColor3 = Window.Theme.Secondary, Size = UDim2.new(1, 0, 0, ItemH)})
			Create("UICorner", {Parent = F, CornerRadius = UDim.new(0, 8)})

			Create("TextLabel", {
				Parent = F, BackgroundTransparency = 1, Size = UDim2.new(1, -50, 1, 0), Position = UDim2.new(0, 12, 0, 0),
				Text = Config.Name or "Toggle", Font = Enum.Font.GothamBold, TextColor3 = Window.Theme.Text, TextSize = TextS, TextXAlignment = Enum.TextXAlignment.Left
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
			local F = Create("Frame", {Parent = Page, BackgroundColor3 = Window.Theme.Secondary, Size = UDim2.new(1, 0, 0, ItemH + 8)})
			Create("UICorner", {Parent = F, CornerRadius = UDim.new(0, 8)})

			Create("TextLabel", {
				Parent = F, BackgroundTransparency = 1, Size = UDim2.new(1, -24, 0, 24), Position = UDim2.new(0, 12, 0, 4),
				Text = Config.Name or "Slider", Font = Enum.Font.GothamBold, TextColor3 = Window.Theme.Text, TextSize = TextS, TextXAlignment = Enum.TextXAlignment.Left
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
			Track.InputBegan:Connect(function(i) 
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
			return {Set = function(self, v) 
				Val = math.clamp(v, Min, Max) 
				local Pct = (Val-Min)/(Max-Min)
				Fill.Size = UDim2.new(Pct, 0, 1, 0) 
				Thumb.Position = UDim2.new(Pct, -8, 0.5, -8)
				ValLbl.Text = tostring(Val) 
			end}
		end

		function Elements:CreateInput(Config)
			local F = Create("Frame", {Parent = Page, BackgroundColor3 = Window.Theme.Secondary, Size = UDim2.new(1, 0, 0, ItemH + 4)})
			Create("UICorner", {Parent = F, CornerRadius = UDim.new(0, 8)})

			Create("TextLabel", {
				Parent = F, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -24, 0, ItemH - 18),
				Text = Config.Name or "Input", Font = Enum.Font.GothamBold, TextColor3 = Window.Theme.Text, TextSize = TextS, TextXAlignment = Enum.TextXAlignment.Left
			})
			local Box = Create("TextBox", {
				Parent = F, BackgroundColor3 = Window.Theme.Main, Position = UDim2.new(0, 12, 0, ItemH - 18), Size = UDim2.new(1, -24, 0, 16),
				Text = "", PlaceholderText = Config.PlaceholderText or "...", Font = Enum.Font.Gotham, TextColor3 = Window.Theme.TextDark, 
				PlaceholderColor3 = Color3.fromRGB(80, 80, 80), TextSize = TextS, TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, ClearTextOnFocus = false
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
			local Multi = Config.Multi or false
			
			local F = Create("Frame", {Parent = Page, BackgroundColor3 = Window.Theme.Secondary, Size = UDim2.new(1, 0, 0, ItemH)})
			Create("UICorner", {Parent = F, CornerRadius = UDim.new(0, 8)})
			
			local Top = Create("TextButton", {Parent = F, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, ItemH), Text = "", AutoButtonColor = false})
			Create("TextLabel", {Parent = Top, BackgroundTransparency=1, Position=UDim2.new(0,12,0,0), Size=UDim2.new(1,-40,0,ItemH), Text = Config.Name or "Dropdown", Font = Enum.Font.GothamBold, TextColor3 = Window.Theme.Text, TextSize=TextS, TextXAlignment=Enum.TextXAlignment.Left})
			
			local Current = Create("TextLabel", {Parent = Top, BackgroundTransparency=1, Position=UDim2.new(0.5,0,0,0), Size=UDim2.new(0.5,-30,0,ItemH), Text = "", Font = Enum.Font.Gotham, TextColor3 = Window.Theme.TextDark, TextSize=TextS, TextXAlignment=Enum.TextXAlignment.Right})
			
			local function UpdateText(Val)
				local DisplayText = Val
				if type(Val) == "table" then
					if #Val > 0 then DisplayText = table.concat(Val, ", ") else DisplayText = "Select..." end
				end
				Current.Text = tostring(DisplayText).." >"
			end
			
			UpdateText(Default)
			
			Top.MouseButton1Click:Connect(function()
				Config.CurrentValue = Default -- Pass current state
				Window:OpenDropdownModal(Config, function(NewVal)
					Default = NewVal
					UpdateText(NewVal)
					if Config.Flag then Window.Flags[Config.Flag] = NewVal end
					if Config.Callback then Config.Callback(NewVal) end
				end)
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
		
		-- Changed Parent to MainFrame to keep it inside the window
		local Blur = Create("Frame", {
			Parent = MainFrame, BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 1, Size = UDim2.fromScale(1,1), Name = "AlertBlur", ZIndex = 100
		})
		Create("UICorner", {Parent = Blur, CornerRadius = UDim.new(0, 14)}) -- Match ContentWindow corner

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
				Tween(AlertFrame, {GroupTransparency = 1, Size = UDim2.fromOffset(280, 140)}, 0.2, Enum.EasingStyle.Quint)
				Tween(Blur, {BackgroundTransparency = 1}, 0.2).Completed:Wait()
				Blur:Destroy()
			end)
		end
		
		Tween(Blur, {BackgroundTransparency = 0.4}, 0.3)
		Tween(AlertFrame, {GroupTransparency = 0, Size = UDim2.fromOffset(300, 160)}, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
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