local EnvielUI = {}
EnvielUI.__index = EnvielUI
EnvielUI.Version = "V1"
EnvielUI.Flags = {}

-- [Enviel Constants]
local LOGO_WHITE = "94854804824909"
local LOGO_BLACK = "120261170817156"
local DEFAULT_WINDOW_WIDTH = 500
local DEFAULT_WINDOW_HEIGHT = 350
local MOBILE_WIDTH_SCALE = 0.55
local NAVBAR_HEIGHT = 65
local SEARCH_DEBOUNCE_TIME = 0.15

local function SafeCallback(Callback, ...)
	if not Callback then return end
	local Success, Err = pcall(Callback, ...)
	if not Success then
		warn("[EnvielUI] Callback Error:", Err)
	end
end

local Validator = {}
function Validator.IsTable(value, name)
	if type(value) ~= "table" then
		warn(string.format("[EnvielUI] %s must be a table, got %s", name or "Parameter", type(value)))
		return false
	end
	return true
end
function Validator.IsFunction(value, name)
	if value and type(value) ~= "function" then
		warn(string.format("[EnvielUI] %s must be a function, got %s", name or "Callback", type(value)))
		return false
	end
	return true
end
function Validator.IsNumber(value, name, min, max)
	local num = tonumber(value)
	if not num then
		warn(string.format("[EnvielUI] %s must be a number, got %s", name or "Parameter", type(value)))
		return false, nil
	end
	if min and num < min then return false, nil end
	if max and num > max then return false, nil end
	return true, num
end

local cloneref = (cloneref or clonereference or function(instance) return instance end)
local function GetService(Name)
	return cloneref(game:GetService(Name))
end

local RunService = GetService("RunService")
local TweenService = GetService("TweenService")
local UserInputService = GetService("UserInputService")
local Players = GetService("Players")
local CoreGui = GetService("CoreGui")
local Stats = GetService("Stats")
local VirtualUser = GetService("VirtualUser")
local HttpService = GetService("HttpService")

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
		TabActive = Color3.fromHex("2A2A2A"),
		TabHover = Color3.fromHex("222222"),
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
		TabActive = Color3.fromHex("E0E0E0"),
		TabHover = Color3.fromHex("EBEBEB"),
	}
}

local FontRegular = Enum.Font.Gotham
local FontMedium = Enum.Font.GothamMedium
local FontBold = Enum.Font.GothamBold

local IconLib
local SuccessIcon, ErrIcon = pcall(function()
	IconLib = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Footagesus/Icons/main/Main-v2.lua"))()
	IconLib.SetIconsType("lucide")
end)

if not SuccessIcon then
	warn("[EnvielUI] Failed to load IconLib:", ErrIcon)
	IconLib = { GetIcon = function(...) return "" end }
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

local TweenManager = {
	activeTweens = {}
}

function TweenManager:SmartTween(instance, properties, duration, style, direction)
	if not instance then 
		warn("EnvielUI: Tween called with nil instance")
		return 
	end
	
	local key = tostring(instance)
	if self.activeTweens[key] then
		self.activeTweens[key]:Cancel()
	end
	
	local info = TweenInfo.new(
		duration or 0.3, 
		style or Enum.EasingStyle.Quart, 
		direction or Enum.EasingDirection.Out
	)
	local tween = TweenService:Create(instance, info, properties)
	
	self.activeTweens[key] = tween
	
	tween.Completed:Connect(function()
		if self.activeTweens[key] == tween then
			self.activeTweens[key] = nil
		end
	end)
	
	tween:Play()
	return tween
end

function TweenManager:CancelAll()
	for _, tween in pairs(self.activeTweens) do
		tween:Cancel()
	end
	self.activeTweens = {}
end

local function Tween(instance, properties, duration, style, direction)
	return TweenManager:SmartTween(instance, properties, duration, style, direction)
end

local function Dragify(Frame, ClickCallback)
	local Dragging, DragInput, DragStart, StartPos
	local HasMoved = false
	local dragConnection = nil
	
	local function Update(input)
		local Delta = input.Position - DragStart
		HasMoved = true
		
		local TargetPos = UDim2.new(
			StartPos.X.Scale, 
			StartPos.X.Offset + Delta.X, 
			StartPos.Y.Scale, 
			StartPos.Y.Offset + Delta.Y
		)
		local DragTween = TweenService:Create(Frame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = TargetPos})
		DragTween:Play()
	end
	
	local function stopDragging()
		Dragging = false
		if dragConnection then
			dragConnection:Disconnect()
			dragConnection = nil
		end
	end
	
	Frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			Dragging = true
			HasMoved = false
			DragStart = input.Position
			StartPos = Frame.Position
			
			-- Only connect when actually dragging
			dragConnection = UserInputService.InputChanged:Connect(function(changeInput)
				if changeInput.UserInputType == Enum.UserInputType.MouseMovement or changeInput.UserInputType == Enum.UserInputType.Touch then
					if Dragging then
						Update(changeInput)
					end
				end
			end)
			
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					stopDragging()
					if not HasMoved and ClickCallback then
						ClickCallback()
					end
				end
			end)
		end
	end)
	
	Frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			DragInput = input
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
	
	-- Connection Manager (Memory Leak Fix)
	local ConnectionManager = {
		connections = {},
		tweens = {},
		timers = {}
	}
	
	function ConnectionManager:Add(connection)
		table.insert(self.connections, connection)
		return connection
	end
	
	function ConnectionManager:AddTween(tween)
		table.insert(self.tweens, tween)
		return tween
	end
	
	function ConnectionManager:AddTimer(timer)
		table.insert(self.timers, timer)
		return timer
	end
	
	function ConnectionManager:DisconnectAll()
		for _, conn in ipairs(self.connections) do
			if conn and conn.Connected then conn:Disconnect() end
		end
		for _, tween in ipairs(self.tweens) do
			if tween then tween:Cancel() end
		end
		for _, timer in ipairs(self.timers) do
			if timer then task.cancel(timer) end
		end
		self.connections = {}
		self.tweens = {}
		self.timers = {}
	end
	

	-- Theme Registry (Optimization)
	local ThemeRegistry = {
		objects = {}
	}
	
	function ThemeRegistry:Register(object, config)
		self.objects[object] = config
	end
	
	function ThemeRegistry:Unregister(object)
		self.objects[object] = nil
	end
	
	function ThemeRegistry:UpdateAll(theme)
		for object, config in pairs(self.objects) do
			if object and object.Parent then
				if config.type == "Element" then
					Tween(object, {BackgroundColor3 = theme.Element}, 0.3)
				elseif config.type == "Text" then
					Tween(object, {TextColor3 = theme.Text}, 0.3)
				elseif config.type == "Secondary" then
					Tween(object, {BackgroundColor3 = theme.Secondary}, 0.3)
				elseif config.type == "Stroke" then
					Tween(object, {Color = theme.Stroke}, 0.3)
				end
				
				if config.properties then
					local props = {}
					for prop, getter in pairs(config.properties) do
						props[prop] = getter(theme)
					end
					Tween(object, props, 0.3)
				end
				
				if object:FindFirstChild("UIStroke") and config.updateStroke then
					Tween(object.UIStroke, {Color = theme.Stroke}, 0.3)
				end
			else
				self.objects[object] = nil
			end
		end
	end
	
	if Themes[Theme] then 
		self.Theme = Themes[Theme] 
	else
		self.Theme = Themes.Dark
	end
	
	
	if not self.Flags then
		self.Flags = {}
	end
	
	for key, val in pairs(Themes.Dark) do
		if self.Theme[key] == nil then
			self.Theme[key] = val
		end
	end
	
	local function GetCorrectParent()
		local Success, Parent = pcall(function() return gethui() end)
		if Success and Parent then 
			
			return cloneref(Parent)
		end
		
		if CoreGui then 
			
			return CoreGui 
		end
		
		
		return Players.LocalPlayer:WaitForChild("PlayerGui")
	end
	
	local ParentTarget = GetCorrectParent()
	
	
	local function RandomString(length)
		local str = ""
		for i = 1, length do
			str = str .. string.char(math.random(97, 122))
		end
		return str
	end

	
	for _, child in pairs(ParentTarget:GetChildren()) do
		if child:GetAttribute("EnvielID") == "MainInstance" then
			child:Destroy()
		end
	end
	
	
	local ScreenGui = Create("ScreenGui", {
		Name = RandomString(10),
		Parent = ParentTarget,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		ResetOnSpawn = false
	})
	ScreenGui:SetAttribute("EnvielID", "MainInstance")
	
	local Minimized = false
	local WindowWidth = Config.Width or DEFAULT_WINDOW_WIDTH
	local OpenSize
	
	if UserInputService.TouchEnabled then
		OpenSize = UDim2.new(MOBILE_WIDTH_SCALE, 0, 0, DEFAULT_WINDOW_HEIGHT)
	else
		-- [Enviel PC] Use Fixed Pixel used for precision
		OpenSize = UDim2.new(0, WindowWidth, 0, DEFAULT_WINDOW_HEIGHT)
	end
	
	
	local MainFrame = Create("Frame", {
		Name = "MainFrame",
		Parent = ScreenGui,
		BackgroundColor3 = self.Theme.Main,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Active = true
	})
	

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
		BackgroundTransparency = 0.1
	}, 0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	
	local OpenBtn = Create("TextButton", {
		Name = "OpenButton",
		Parent = ScreenGui,
		BackgroundColor3 = self.Theme.Element,
		Position = UDim2.new(0, 30, 0.5, -25),
		Size = UDim2.new(0, 50, 0, 50),
		Text = "",
		Visible = false,
		AutoButtonColor = false
	})
	Create("UICorner", {Parent = OpenBtn, CornerRadius = UDim.new(0, 12)})
	Create("UIStroke", {Parent = OpenBtn, Color = self.Theme.Accent, Thickness = 2})
	local WhiteLogo = "94854804824909"
	local BlackLogo = "120261170817156"
	local InitialLogo = (Theme == "Light") and BlackLogo or WhiteLogo

	local OpenIcon = Create("ImageLabel", {
		Parent = OpenBtn,
		BackgroundTransparency = 1,
		Position = UDim2.new(0.5, -16, 0.5, -16),
		Size = UDim2.new(0, 32, 0, 32),
		Image = "rbxthumb://type=Asset&id="..((self.Theme == Themes.Light) and LOGO_BLACK or LOGO_WHITE).."&w=150&h=150",
		ScaleType = Enum.ScaleType.Fit
	})
	local function ToggleMinimize()
		Minimized = not Minimized
		if Minimized then
			local CloseTween = Tween(MainFrame, {Size = UDim2.new(0,0,0,0)}, 0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
			
			task.delay(0.1, function()
				OpenBtn.Visible = true
				OpenBtn.Size = UDim2.new(0, 0, 0, 0)
				Tween(OpenBtn, {Size = UDim2.new(0, 50, 0, 50)}, 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			end)
			
			CloseTween.Completed:Wait()
			MainFrame.Visible = false
		else
			OpenBtn.Visible = false
			MainFrame.Visible = true
			MainFrame.Size = UDim2.new(0,0,0,0)

			Tween(MainFrame, {Size = OpenSize}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out) 
		end
	end

	local WasDragged = false
	
	local function EnableOpenBtnDrag()
		local Dragging, DragInput, DragStart, StartPos

		OpenBtn.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				Dragging = true
				WasDragged = false
				DragStart = input.Position
				StartPos = OpenBtn.Position
				
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						Dragging = false
					end
				end)
			end
		end)

		OpenBtn.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				DragInput = input
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if input == DragInput and Dragging then
				local Delta = input.Position - DragStart
				if Delta.Magnitude > 2 then WasDragged = true end 
				
				local ViewPort = ScreenGui.AbsoluteSize
				local BtnSize = OpenBtn.AbsoluteSize
				
				local TargetX = StartPos.X.Offset + Delta.X
				local TargetY = StartPos.Y.Offset + Delta.Y
				
				local AbsX = (ViewPort.X * StartPos.X.Scale) + TargetX
				local AbsY = (ViewPort.Y * StartPos.Y.Scale) + TargetY
				
				AbsX = math.clamp(AbsX, 0, ViewPort.X - BtnSize.X)
				AbsY = math.clamp(AbsY, 0, ViewPort.Y - BtnSize.Y)
				
				local NewOffX = AbsX - (ViewPort.X * StartPos.X.Scale)
				local NewOffY = AbsY - (ViewPort.Y * StartPos.Y.Scale)
				
				local TargetPos = UDim2.new(
					StartPos.X.Scale, 
					NewOffX, 
					StartPos.Y.Scale, 
					NewOffY
				)
				OpenBtn.Position = TargetPos
			end
		end)
	end
	EnableOpenBtnDrag()
	
	OpenBtn.MouseButton1Click:Connect(function()
		if not WasDragged then
			ToggleMinimize()
		end
	end)
	
	local ToggleKey = Config.Keybind or Enum.KeyCode.RightControl
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and input.KeyCode == ToggleKey then
			if ScreenGui.Enabled then
				if not Minimized then
					Tween(MainFrame, {Size = UDim2.new(0,0,0,0)}, 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In).Completed:Wait()
				end
				ScreenGui.Enabled = false
			else
				ScreenGui.Enabled = true
				if not Minimized then
					MainFrame.Size = UDim2.new(0,0,0,0)
					Tween(MainFrame, {Size = OpenSize}, 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
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
	
	local TitleContainer = Create("Frame", {
		Parent = Header, BackgroundTransparency = 1, Size = UDim2.new(1, -120, 1, 0), Position = UDim2.new(0, 15, 0, 0)
	})
	Create("UIListLayout", {Parent = TitleContainer, FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 8)})

	
	local CurrentLogo = (Theme == "Light") and LOGO_BLACK or LOGO_WHITE

	local Logo = Create("ImageLabel", {
		Name = "Logo", Parent = TitleContainer, BackgroundTransparency = 1, Size = UDim2.new(0, 24, 0, 24),
		Image = "rbxthumb://type=Asset&id="..CurrentLogo.."&w=150&h=150", ScaleType = Enum.ScaleType.Fit, LayoutOrder = 1
	})
	
	local Title = Create("TextLabel", {
		Name = "Title",
		Parent = TitleContainer,
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 1, 0),
		Font = FontBold,
		Text = Config.Name or "Enviel UI",
		TextColor3 = self.Theme.Text,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = 2
	})
	
	local Controls = Create("Frame", {
		Name = "Controls",
		Parent = Header,
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -70, 0, 0),
		Size = UDim2.new(0, 60, 1, 0)
	})
	
	local CloseBtn = Create("ImageButton", {
		Parent = Controls,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -5, 0.5, 0),
		Size = UDim2.new(0, 24, 0, 24),
		Image = GetIcon("x"),
		ImageColor3 = self.Theme.TextSec,
		AutoButtonColor = false
	})
	CloseBtn.MouseButton1Click:Connect(function()
		Tween(MainFrame, {Size = UDim2.new(0,0,0,0)}, 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In).Completed:Wait()
		ScreenGui.Enabled = false
	end)
	
	local MinBtn = Create("ImageButton", {
		Parent = Controls,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -34, 0.5, 0),
		Size = UDim2.new(0, 18, 0, 18),
		Image = GetIcon("minimize"),
		ImageColor3 = self.Theme.TextSec,
		AutoButtonColor = false
	})
	MinBtn.MouseButton1Click:Connect(ToggleMinimize)
	
	for _, btn in pairs({CloseBtn, MinBtn}) do
		btn.MouseEnter:Connect(function() Tween(btn, {ImageColor3 = self.Theme.Accent}, 0.2) end)
		btn.MouseLeave:Connect(function() Tween(btn, {ImageColor3 = self.Theme.TextSec}, 0.2) end)
	end

	local ContentContainer = Create("Frame", {
		Name = "ContentContainer",
		Parent = MainFrame,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, -50),
		Position = UDim2.new(0, 0, 0, 50)
	})
	
	local Footer = Create("TextLabel", {
		Name = "Footer", Parent = MainFrame, BackgroundTransparency = 1,
		Size = UDim2.new(0, 100, 0, 20), Position = UDim2.new(1, -60, 0, 15), AnchorPoint = Vector2.new(1, 0),
		Text = "Made by Enviel", TextSize = 10, Font = FontBold, TextColor3 = self.Theme.TextSec, TextTransparency = 0.5,
		TextXAlignment = Enum.TextXAlignment.Right
	})
	
	local SearchBar = Create("TextBox", {
		Name = "SearchBar",
		Parent = ContentContainer,
		BackgroundColor3 = self.Theme.Element,
		Position = UDim2.new(0, 20, 0, 10),
		Size = UDim2.new(0, 160, 0, 30),
		Font = FontBold,
		Text = "",
		PlaceholderText = "Search...",
		TextColor3 = self.Theme.Text,
		PlaceholderColor3 = self.Theme.TextSec,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	Create("UICorner", {Parent = SearchBar, CornerRadius = UDim.new(0, 6)})
	Create("UIPadding", {Parent = SearchBar, PaddingLeft = UDim.new(0, 10)})
	Create("UIStroke", {Parent = SearchBar, Color = self.Theme.Stroke, Thickness = 1, Transparency = 0.5})

	-- Fixed Layout: Always show Floating Navbar
	
	local NavbarHeight = 55 -- Reduced height
	
	-- Navbar Container (Floating Dock Style)
	local Navbar = Create("Frame", {
		Name = "Navbar",
		Parent = ContentContainer,
		BackgroundColor3 = self.Theme.Secondary, 
		Position = UDim2.new(0.5, 0, 1, -25), -- Floats higher
		Size = UDim2.new(1, -30, 0, NavbarHeight), -- Width with margin
		AnchorPoint = Vector2.new(0.5, 1),
		BorderSizePixel = 0,
		Visible = true, -- Always Visible
		ZIndex = 20
	})
	Create("UICorner", {Parent = Navbar, CornerRadius = UDim.new(0, 16)})
	Create("UIStroke", {Parent = Navbar, Color = self.Theme.Stroke, Thickness = 1, Transparency = 0.5})
	
	-- Navbar Shadow for Depth
	local NavbarShadow = Create("ImageLabel", {
		Name = "Shadow", Parent = Navbar, BackgroundTransparency = 1,
		Position = UDim2.new(0, -15, 0, -15), Size = UDim2.new(1, 30, 1, 30),
		Image = "rbxassetid://5554236805", ImageColor3 = Color3.new(0,0,0), ImageTransparency = 0.6,
		ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(23,23,277,277), ZIndex = 19
	})
	
	-- Inner Container (Scrolling)
	local NavbarInner = Create("ScrollingFrame", {
		Name = "NavbarInner",
		Parent = Navbar,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.X,
		ScrollBarThickness = 0,
		ScrollingDirection = Enum.ScrollingDirection.X
	})
	-- Add padding to keep buttons away from edges
	Create("UIPadding", {Parent = NavbarInner, PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)})
	
	-- Horizontal Layout for Dock Items
	Create("UIListLayout", {
		Parent = NavbarInner,
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 5),
		SortOrder = Enum.SortOrder.LayoutOrder
	})
	
	local searchCache = {}
	local searchDebounce = nil
	
	local function performSearch(input)
		local lowerInput = input:lower()
		if lowerInput == "" then
			for _, data in ipairs(searchCache) do
				if data.frame then data.frame.Visible = true end
			end
			return
		end
		
		for _, data in ipairs(searchCache) do
			if data.frame then
				data.frame.Visible = data.searchText:find(lowerInput, 1, true) ~= nil
			end
		end
	end
	
	SearchBar:GetPropertyChangedSignal("Text"):Connect(function()
		if searchDebounce then task.cancel(searchDebounce) end
		searchDebounce = task.delay(SEARCH_DEBOUNCE_TIME, function()
			performSearch(SearchBar.Text)
			searchDebounce = nil
		end)
	end)
	
	local Pages = Create("Frame", {
		Name = "Pages",
		Parent = ContentContainer,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 20, 0, 45), -- Start below Header
		-- Content ends BEFORE the dock starts
		Size = UDim2.new(1, -40, 1, -(NavbarHeight + 55)) -- Leave room for Dock + Header
	})
	
	local Window = {
		Tabs = {},
		Groups = {},
		Instance = self,
		MainFrame = MainFrame,
		Navbar = Navbar, -- Renamed from Sidebar to Navbar
		Pages = Pages,
		TitleLabel = Title,
		Search = SearchBar,
		Logo = Logo,
		Footer = Footer,
		OpenIcon = OpenIcon,
		ActiveTab = nil,
		ActiveTab = nil,
		ConnectionManager = ConnectionManager,
		ThemeRegistry = ThemeRegistry
	}
	
	function Window:Destroy()
		self.ConnectionManager:DisconnectAll()
		TweenManager:CancelAll()
		if ScreenGui then ScreenGui:Destroy() end
		setmetatable(self, nil)
		print("[EnvielUI] Window Destroyed")
	end
	
	function Window:RegisterSearchable(frame, text)
		table.insert(searchCache, { frame = frame, searchText = text:lower() })
	end
	
	function Window:SetTheme(ThemeName)
		if not Themes[ThemeName] then warn("Theme not found: " .. tostring(ThemeName)) return end
		self.Instance.Theme = Themes[ThemeName]
		local T = self.Instance.Theme
		
		local TargetLogo = (ThemeName == "Light") and LOGO_BLACK or LOGO_WHITE
		if self.Logo then self.Logo.Image = "rbxthumb://type=Asset&id="..TargetLogo.."&w=150&h=150" end
		if self.OpenIcon then self.OpenIcon.Image = "rbxthumb://type=Asset&id="..TargetLogo.."&w=150&h=150" end
		
		Tween(MainFrame, {BackgroundColor3 = T.Main}, 0.3)
		Tween(MainFrame.UIStroke, {Color = T.Stroke}, 0.3)
		Tween(Title, {TextColor3 = T.Text}, 0.3)
		if self.Footer then Tween(self.Footer, {TextColor3 = T.TextSec}, 0.3) end
		
		if OpenBtn then
			Tween(OpenBtn, {BackgroundColor3 = T.Element}, 0.3)
			if OpenBtn:FindFirstChild("UIStroke") then Tween(OpenBtn.UIStroke, {Color = T.Accent}, 0.3) end
			if OpenBtn:FindFirstChild("ImageLabel") then Tween(OpenBtn.ImageLabel, {ImageColor3 = T.Accent}, 0.3) end
		end
		
		
		local WM = MainFrame:FindFirstChild("Watermark")
		if WM then
			Tween(WM, {BackgroundColor3 = T.Stroke}, 0.3)
			if WM:FindFirstChild("UIStroke") then Tween(WM.UIStroke, {Color = T.Stroke}, 0.3) end
			local WMText = WM:FindFirstChild("WatermarkText")
			if WMText then Tween(WMText, {TextColor3 = T.Text}, 0.3) end
		end
		
		if self.Search then
			Tween(self.Search, {BackgroundColor3 = T.Element}, 0.3)
			Tween(self.Search, {TextColor3 = T.Text}, 0.3)
			Tween(self.Search, {PlaceholderColor3 = T.TextSec}, 0.3)
			if self.Search:FindFirstChild("UIStroke") then Tween(self.Search.UIStroke, {Color = T.Stroke}, 0.3) end
		end
		
		-- Update Navbar Theme
		Tween(Navbar, {BackgroundColor3 = T.Secondary}, 0.3)
		if Navbar:FindFirstChild("UIStroke") then Tween(Navbar.UIStroke, {Color = T.Stroke}, 0.3) end
		
		for _, btn in pairs(NavbarInner:GetChildren()) do
			if btn:IsA("TextButton") then
				local label = btn:FindFirstChild("Label")
				local icon = btn:FindFirstChild("ImageLabel")
				local bar = btn:FindFirstChild("ActiveBar")
				
				if Window.ActiveTab and btn.Name == Window.ActiveTab.."Btn" then
					if label then Tween(label, {TextColor3 = T.AccentText}, 0.3) end
					if icon then Tween(icon, {ImageColor3 = T.AccentText}, 0.3) end
					if bar then 
						Tween(bar, {BackgroundColor3 = T.AccentText}, 0.3) 
						Tween(bar, {Size = UDim2.new(0, 20, 0, 3)}, 0.3) -- Active Width
					end
				else
					Tween(btn, {BackgroundTransparency = 1}, 0.3)
					if label then Tween(label, {TextColor3 = T.TextSec}, 0.3) end
					if icon then Tween(icon, {ImageColor3 = T.TextSec}, 0.3) end
					if bar then 
						Tween(bar, {BackgroundColor3 = T.Secondary}, 0.3) 
						Tween(bar, {Size = UDim2.new(0, 0, 0, 3)}, 0.3) -- Inactive Width
					end
				end
			end
		end
		
		for _, page in pairs(Pages:GetChildren()) do
			if page:IsA("ScrollingFrame") then
				page.ScrollBarImageColor3 = T.Stroke
			end
		end
		
		ThemeRegistry:UpdateAll(T)

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
		
		-- Reset all tab buttons in Navbar
		for _, btn in pairs(NavbarInner:GetChildren()) do
			if btn:IsA("TextButton") and btn.Name ~= TabId.."Btn" then
				-- Inactive State (Transparent Background, Gray Text/Icon)
				Tween(btn, {BackgroundTransparency = 1, BackgroundColor3 = self.Instance.Theme.Secondary}, 0.3)
				
				local label = btn:FindFirstChild("Label")
				local icon = btn:FindFirstChild("ImageLabel")
				
				if label then Tween(label, {TextColor3 = self.Instance.Theme.TextSec}, 0.3) end
				if icon then Tween(icon, {ImageColor3 = self.Instance.Theme.TextSec}, 0.3) end
			end
		end
		
		if Pages:FindFirstChild(TabId) then Pages[TabId].Visible = true end
		
			local btn = NavbarInner[TabId.."Btn"]
			local label = btn:FindFirstChild("Label")
			local icon = btn:FindFirstChild("ImageLabel")
			local bar = btn:FindFirstChild("ActiveBar")
			
			-- Active State (Underline Style)
			Tween(btn, {BackgroundTransparency = 1}, 0.3) -- No background fill
			
			if label then Tween(label, {TextColor3 = self.Instance.Theme.Accent}, 0.3) end
			if icon then Tween(icon, {ImageColor3 = self.Instance.Theme.Accent}, 0.3) end
			if bar then 
				Tween(bar, {Size = UDim2.new(0, 20, 0, 3)}, 0.3) -- Expand bar
				Tween(bar, {BackgroundColor3 = self.Instance.Theme.Accent}, 0.3)
			end

		Window.ActiveTab = TabId
	end
	
	function Window:CreateTab(Config)
		local Name = Config.Name or "Tab"
		local IconName = Config.Icon or "layout-grid" -- Default icon if none provided
		local TabId = "Tab"..tostring(#Window.Tabs + 1)
		
		local IconAsset = GetIcon(IconName)
		
		-- Dock Button (Square-ish ratio)
		local TabBtn = Create("TextButton", {
			Name = TabId.."Btn",
			Parent = NavbarInner,
			BackgroundColor3 = self.Instance.Theme.Accent,
			BackgroundTransparency = 1, 
			Size = UDim2.new(0, 60, 0, 50), -- Fixed width for dock items
			Text = "",
			AutoButtonColor = false
		})
		
		Create("UICorner", {Parent = TabBtn, CornerRadius = UDim.new(0, 12)}) -- Pill/Rounded shape
		
		-- Icon (Top)
		local IconLabel = Create("ImageLabel", {
			Parent = TabBtn,
			BackgroundTransparency = 1,
			Position = UDim2.new(0.5, -12, 0.2, 0), -- Shifted up
			Size = UDim2.new(0, 24, 0, 24),
			Image = IconAsset,
			ImageColor3 = self.Instance.Theme.TextSec
		})
		
		-- Text (Bottom)
		local TextLabel = Create("TextLabel", {
			Name = "Label",
			Parent = TabBtn,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 0, 0.65, 0), -- Bottom position
			Size = UDim2.new(1, 0, 0.3, 0),
			Text = Name,
			Font = FontMedium,
			TextSize = 10, -- Smaller text for dock
			TextColor3 = self.Instance.Theme.TextSec
		})
		
		-- Active Bar (Underline)
		local ActiveBar = Create("Frame", {
			Name = "ActiveBar",
			Parent = TabBtn,
			BackgroundColor3 = self.Instance.Theme.Accent,
			Position = UDim2.new(0.5, 0, 1, -4), -- Bottom Center
			Size = UDim2.new(0, 0, 0, 3), -- Start invisible
			AnchorPoint = Vector2.new(0.5, 1),
			BorderSizePixel = 0
		})
		Create("UICorner", {Parent = ActiveBar, CornerRadius = UDim.new(1, 0)})
		
		TabBtn.MouseEnter:Connect(function()
			if Window.ActiveTab ~= TabId then
				Tween(TabBtn, {BackgroundTransparency = 1}, 0.2) -- No bg change on hover
				if TextLabel then Tween(TextLabel, {TextColor3 = self.Instance.Theme.Accent}, 0.2) end
				if IconLabel then Tween(IconLabel, {ImageColor3 = self.Instance.Theme.Accent}, 0.2) end
			end
		end)
		
		TabBtn.MouseLeave:Connect(function()
			if Window.ActiveTab ~= TabId then
				Tween(TabBtn, {BackgroundTransparency = 1}, 0.2)
				if TextLabel then Tween(TextLabel, {TextColor3 = self.Instance.Theme.TextSec}, 0.2) end
				if IconLabel then Tween(IconLabel, {ImageColor3 = self.Instance.Theme.TextSec}, 0.2) end
			end
		end)
		
		TabBtn.MouseButton1Click:Connect(function()
			Window:SelectTab(TabId)
		end)
		
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
				Parent = Config.Parent or Page,
				BackgroundColor3 = self.Instance.Theme.Element,
				Size = UDim2.new(1, 0, 0, 42),
				BackgroundTransparency = 0,
			})
			Frame:SetAttribute("EnvielTheme", "Element")
			Create("UICorner", {Parent = Frame, CornerRadius = UDim.new(0, 8)})
			Create("UIStroke", {Parent = Frame, Color = self.Instance.Theme.Stroke, Thickness = 1, Transparency = 0.5})

			Create("TextLabel", {
				Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0,15,0,0), Size = UDim2.new(1,-120,1,0),
				Font = FontBold,
				Text = Name, TextColor3 = self.Instance.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
			})
			
			local Btn = Create("TextButton", {
				Parent = Frame, BackgroundColor3 = self.Instance.Theme.Accent, Position = UDim2.new(1,-95,0.5,-13), Size = UDim2.new(0,80,0,26), -- Adjusted sizing/pos
				Font = FontBold,
				Text = Config.ButtonText or "Interact", TextColor3 = self.Instance.Theme.AccentText, TextSize = 11, AutoButtonColor = false,
				TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Center
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
				SafeCallback(Callback)
			end)
			
			-- Registry
			Window.ThemeRegistry:Register(Frame, { type = "Element", updateStroke = true })
			Window.ThemeRegistry:Register(Create("TextLabel", {Parent=Frame}), { type = "Text" }) -- Placeholder fix
			Window.ThemeRegistry:Register(Btn, { 
				properties = { 
					BackgroundColor3 = function(t) return t.Accent end, 
					TextColor3 = function(t) return t.AccentText end 
				} 
			})
			Window:RegisterSearchable(Frame, Name)
			
			return {
				SetText = function(self, newText)
					Btn.Text = newText
				end,
				Instance = Btn
			}
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
				Parent = Config.Parent or Page, BackgroundColor3 = self.Instance.Theme.Element, Size = UDim2.new(1,0,0,44), BackgroundTransparency = 0
			})
			Frame:SetAttribute("EnvielTheme", "Element")
			Create("UICorner", {Parent = Frame, CornerRadius = UDim.new(0, 8)})
			Create("UIStroke", {Parent = Frame, Color = self.Instance.Theme.Stroke, Thickness = 1, Transparency = 0.5})

			Create("TextLabel", {
				Parent = Frame, BackgroundTransparency=1, Position=UDim2.new(0,15,0,0), Size=UDim2.new(1,-70,1,0),
				Font = FontBold,
				Text=Name, TextColor3=self.Instance.Theme.Text, TextSize=13, TextXAlignment=Enum.TextXAlignment.Left
			})
			
			local Switch = Create("TextButton", {
				Parent=Frame, BackgroundColor3 = Value and self.Instance.Theme.Accent or self.Instance.Theme.Stroke,
				Position=UDim2.new(1,-55,0.5,-12), Size=UDim2.new(0,44,0,24), Text="", AutoButtonColor=false
			})
			Create("UICorner", {Parent=Switch, CornerRadius=UDim.new(0,12)})
			
			-- Registry
			Window.ThemeRegistry:Register(Frame, { type = "Element", updateStroke = true })
			Window.ThemeRegistry:Register(Switch, {
				properties = {
					BackgroundColor3 = function(t) return self.Instance.Flags[Flag] and t.Accent or t.Stroke end
				}
			})
			Window:RegisterSearchable(Frame, Name)
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
				SafeCallback(Callback, Value)
				Tween(Switch, {BackgroundColor3=Value and self.Instance.Theme.Accent or self.Instance.Theme.Stroke}, 0.2)
				Tween(Circle, {Position=Value and UDim2.new(1,-22,0.5,-9) or UDim2.new(0,2,0.5,-9)}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
			end)
			
			return {
				Set = function(self, NewVal)
					if type(NewVal) == "boolean" then
						Value = NewVal
						self.Instance.Flags[Flag] = Value
						Callback(Value)
						Tween(Switch, {BackgroundColor3=Value and self.Instance.Theme.Accent or self.Instance.Theme.Stroke}, 0.2)
						Tween(Circle, {Position=Value and UDim2.new(1,-22,0.5,-9) or UDim2.new(0,2,0.5,-9)}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
					end
				end
			}
		end
		
		function Elements:CreateSlider(Config)
			if not Validator.IsTable(Config, "CreateSlider Config") then Config = {} end
			local Name = Config.Name or "Slider"
			local Flag = Config.Flag or Name
			local Min, Max = 0, 100
			
			if Config.Range and type(Config.Range) == "table" then
				Min = Config.Range[1] or 0
				Max = Config.Range[2] or 100
			elseif Config.Min and Config.Max then
				Min = Config.Min
				Max = Config.Max
			end
			
			local Default = Config.Default or Config.CurrentValue or Min
			local Increment = Config.Increment or 1
			local Callback = Config.Callback or function() end
			
			if self.Instance.Flags[Flag] ~= nil then Default = self.Instance.Flags[Flag] end
			local Value = math.clamp(Default, Min, Max)
			self.Instance.Flags[Flag] = Value
			
			local Frame = Create("Frame", {
				Parent = Config.Parent or Page, BackgroundColor3 = self.Instance.Theme.Element, Size = UDim2.new(1,0,0,60), BackgroundTransparency = 0
			})
			Frame:SetAttribute("EnvielTheme", "Element")
			Create("UICorner", {Parent = Frame, CornerRadius = UDim.new(0, 8)})
			Create("UIStroke", {Parent = Frame, Color = self.Instance.Theme.Stroke, Thickness = 1, Transparency = 0.5})

			local Label = Create("TextLabel", {
				Parent = Frame, BackgroundTransparency=1, Position=UDim2.new(0,15,0,8), Size=UDim2.new(1,-30,0,20),
				Font = FontBold,
				Text=Name, TextColor3=self.Instance.Theme.Text, TextSize=13, TextXAlignment=Enum.TextXAlignment.Left
			})
			local ValueLabel = Create("TextLabel", {
				Parent = Frame, BackgroundTransparency=1, Position=UDim2.new(1,-65,0,8), Size=UDim2.new(0,50,0,20),
				Font = FontBold,
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
				Parent = Track, BackgroundColor3 = self.Instance.Theme.AccentText, Position = UDim2.new((Value - Min)/(Max - Min), -7, 0.5, -7), Size = UDim2.new(0,14,0,14)
			})
			Create("UICorner", {Parent=Thumb, CornerRadius=UDim.new(1,0)})
			Create("UIStroke", {Parent=Thumb, Color=self.Instance.Theme.Accent, Thickness=2})
			
			-- Registry
			Window.ThemeRegistry:Register(Frame, { type = "Element", updateStroke = true })
			Window.ThemeRegistry:Register(Label, { type = "Text" })
			Window.ThemeRegistry:Register(ValueLabel, { type = "Text" }) 
			Window.ThemeRegistry:Register(Fill, { properties = { BackgroundColor3 = function(t) return t.Accent end } })
			
			-- Fix: Register Thumb and Stroke Separately
			Window.ThemeRegistry:Register(Thumb, { properties = { BackgroundColor3 = function(t) return t.AccentText end } })
			Window.ThemeRegistry:Register(Thumb:FindFirstChild("UIStroke"), { type = "Stroke", properties = { Color = function(t) return t.Accent end } })
			
			Window:RegisterSearchable(Frame, Name)

			local function UpdateSlider(Input)
				local SizeX = Track.AbsoluteSize.X
				local PosX = Input.Position.X - Track.AbsolutePosition.X
				local Percent = math.clamp(PosX / SizeX, 0, 1)
				local RawValue = Min + ((Max - Min) * Percent)
				local SteppedValue = math.floor(RawValue / Increment + 0.5) * Increment
				Value = math.clamp(SteppedValue, Min, Max)
				
				local Decimals = 0
				if Increment < 1 then
					local s = tostring(Increment)
					if s:find("%.") then Decimals = s:match("%.(%d+)"):len() end
				end
				ValueLabel.Text = string.format("%."..Decimals.."f", Value)
				
				Fill.Size = UDim2.new(Percent, 0, 1, 0)
				Thumb.Position = UDim2.new(Percent, -7, 0.5, -7)
				self.Instance.Flags[Flag] = Value
				SafeCallback(Callback, Value)
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
			local Multi = Config.Multi or false
			local Default
			if Multi then
				Default = Config.Default or {}
			else
				Default = Config.Default or Options[1]
			end
			local Callback = Config.Callback or function() end
			
			if self.Instance.Flags[Flag] ~= nil then
				Default = self.Instance.Flags[Flag]
			end
			
			self.Instance.Flags[Flag] = Default
			
			local Search = Config.Search or false
			
			local Expanded = false
			local DropHeight = 60 -- Increased height for 2-line display
			local OptionHeight = 32
			local TotalOptionsHeight = math.min(#Options, 6) * OptionHeight
			local ExpandedHeight = DropHeight + TotalOptionsHeight + (Search and 35 or 0)
			
			local Frame = Create("Frame", {
				Parent = Config.Parent or Page, BackgroundColor3 = self.Instance.Theme.Element, Size = UDim2.new(1,0,0,DropHeight), BackgroundTransparency = 0, ClipsDescendants = true
			})
			Frame:SetAttribute("EnvielTheme", "Element")
			Create("UICorner", {Parent = Frame, CornerRadius = UDim.new(0, 8)})
			Create("UIStroke", {Parent = Frame, Color = self.Instance.Theme.Stroke, Thickness = 1, Transparency = 0.5})
			
			local function GetValueText()
				if Multi then
					if #Default == 0 then return "Selected : None" end
					return "Selected : " .. table.concat(Default, ", ")
				else
					return "Selected : " .. tostring(Default)
				end
			end

			local TitleLabel = Create("TextLabel", {
				Parent = Frame, BackgroundTransparency=1, Position=UDim2.new(0,15,0,10), Size=UDim2.new(1,-50,0,20),
				Font = FontBold,
				Text = Name,
				TextColor3 = self.Instance.Theme.Text, TextSize=14, TextXAlignment=Enum.TextXAlignment.Left
			})
			
			local ValueLabel = Create("TextLabel", {
				Parent = Frame, BackgroundTransparency=1, Position=UDim2.new(0,15,0,30), Size=UDim2.new(1,-50,0,20),
				Font = FontBold,
				Text = GetValueText(),
				TextColor3 = self.Instance.Theme.TextSec, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd
			})
			
			local Arrow = Create("ImageLabel", {
				Parent = Frame, BackgroundTransparency=1, Position=UDim2.new(1,-35,0,20), Size=UDim2.new(0,20,0,20),
				Image = "rbxassetid://6034818372", ImageColor3 = self.Instance.Theme.TextSec 
			})
			
			local Trigger = Create("TextButton", {
				Parent = Frame, BackgroundTransparency=1, Size=UDim2.new(1,0,0,DropHeight), Text=""
			})
			
			local SearchBar
			local SearchText = ""
			
			if Search then
				SearchBar = Create("TextBox", {
					Parent = Frame, BackgroundColor3 = self.Instance.Theme.Main, Position = UDim2.new(0, 10, 0, DropHeight + 5), Size = UDim2.new(1, -20, 0, 25),
					Font = FontBold, Text = "", PlaceholderText = "Search...", TextColor3 = self.Instance.Theme.Text, PlaceholderColor3 = self.Instance.Theme.TextSec,
					TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false
				})
				Create("UICorner", {Parent = SearchBar, CornerRadius = UDim.new(0, 6)})
				Create("UIPadding", {Parent = SearchBar, PaddingLeft = UDim.new(0, 8)})
				
				SearchBar:GetPropertyChangedSignal("Text"):Connect(function()
					SearchText = SearchBar.Text:lower()
					RefreshOptions()
				end)
			end
			
			local ListOffsetY = DropHeight + (Search and 35 or 0)
			
			local OptionContainer = Create("ScrollingFrame", {
				Parent = Frame, BackgroundTransparency=1, Position=UDim2.new(0,0,0,ListOffsetY), Size=UDim2.new(1,0,0,TotalOptionsHeight),
				ScrollBarThickness=2, ScrollBarImageColor3=self.Instance.Theme.Accent, CanvasSize=UDim2.new(0,0,0,0)
			})
			Create("UIListLayout", {Parent=OptionContainer, SortOrder=Enum.SortOrder.LayoutOrder})
			
			local DropdownConnections = {} -- Store connections for cleanup

			local function RefreshOptions()
				-- Cleanup old connections
				for _, conn in pairs(DropdownConnections) do
					if conn and conn.Connected then conn:Disconnect() end
				end
				table.clear(DropdownConnections)
				
				for _, v in pairs(OptionContainer:GetChildren()) do
					if v:IsA("TextButton") then v:Destroy() end
				end
				
				local FilteredOptions = {}
				for _, opt in pairs(Options) do
					if SearchText == "" or tostring(opt):lower():find(SearchText) then
						table.insert(FilteredOptions, opt)
					end
				end
				
				OptionContainer.CanvasSize = UDim2.new(0,0,0,#FilteredOptions * OptionHeight)
				
				for _, opt in pairs(FilteredOptions) do
					local IsSelected
					if Multi then
						IsSelected = table.find(Default, opt)
					else
						IsSelected = (opt == Default)
					end

					local Btn = Create("TextButton", {
						Parent=OptionContainer, BackgroundTransparency=0, BackgroundColor3=self.Instance.Theme.Element,
						Size=UDim2.new(1,0,0,OptionHeight), Text="    "..tostring(opt),
						Font = FontBold,
						TextColor3 = IsSelected and self.Instance.Theme.Accent or self.Instance.Theme.TextSec,
						TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, AutoButtonColor=false,
						BorderSizePixel = 0
					})
					Btn:SetAttribute("EnvielType", "DropdownOption")
					Btn:SetAttribute("EnvielSelected", IsSelected)
					
					table.insert(DropdownConnections, Btn.MouseEnter:Connect(function() 
						Tween(Btn, {BackgroundColor3 = self.Instance.Theme.Hover}, 0.2)
					end))
					
					table.insert(DropdownConnections, Btn.MouseLeave:Connect(function() 
						Tween(Btn, {BackgroundColor3 = self.Instance.Theme.Element}, 0.2)
					end))
					
					table.insert(DropdownConnections, Btn.MouseButton1Click:Connect(function()
						if Multi then
							if table.find(Default, opt) then
								table.remove(Default, table.find(Default, opt))
							else
								table.insert(Default, opt)
							end
							self.Instance.Flags[Flag] = Default
							SafeCallback(Callback, Default)
							ValueLabel.Text = GetValueText()
							RefreshOptions()
						else
							Default = opt
							self.Instance.Flags[Flag] = Default
							SafeCallback(Callback, Default)
							ValueLabel.Text = GetValueText()
							Expanded = false
							Tween(Frame, {Size=UDim2.new(1,0,0,DropHeight)}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
							Tween(Arrow, {Rotation=0}, 0.3)
							RefreshOptions()
						end
					end))
				end
			end
			
			RefreshOptions()
			
			local function CloseDropdown()
				if not Expanded then return end
				Expanded = false
				Tween(Frame, {Size = UDim2.new(1,0,0,DropHeight)}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
				Tween(Arrow, {Rotation = 0}, 0.3)
				if self.Instance.ActiveDropdown == CloseDropdown then
					self.Instance.ActiveDropdown = nil
				end
			end

			Trigger.MouseButton1Click:Connect(function()
				if Expanded then
					CloseDropdown()
				else
					if self.Instance.ActiveDropdown and type(self.Instance.ActiveDropdown) == "function" then
						self.Instance.ActiveDropdown()
					end
					Expanded = true
					self.Instance.ActiveDropdown = CloseDropdown
					Tween(Frame, {Size = UDim2.new(1,0,0,ExpandedHeight)}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
					Tween(Arrow, {Rotation = 180}, 0.3)
				end
			end)
			
			-- Registry
			Window.ThemeRegistry:Register(Frame, { type = "Element", updateStroke = true })
			Window.ThemeRegistry:Register(TitleLabel, { type = "Text" })
			Window.ThemeRegistry:Register(ValueLabel, { type = "Text", properties = { TextColor3 = function(t) return t.TextSec end } })
			Window:RegisterSearchable(Frame, Name)
			
			return {
				Refresh = function(self, NewOptions)
					Options = NewOptions
					TotalOptionsHeight = math.min(#Options, 6) * OptionHeight
                    OptionContainer.Size = UDim2.new(1,0,0,TotalOptionsHeight)
					ExpandedHeight = DropHeight + TotalOptionsHeight + (Search and 35 or 0)
					RefreshOptions()
				end,
				Set = function(self, NewVal)
					if Multi then Default = NewVal else Default = NewVal end
					self.Instance.Flags[Flag] = Default
					Callback(Default)
					ValueLabel.Text = GetValueText()
					RefreshOptions()
				end
			}
		end
		
		function Elements:CreateSection(Name)
			local SectionFrame = Create("Frame", {
				Parent = Config.Parent or Page, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,30)
			})
			local Label = Create("TextLabel", {
				Parent = SectionFrame, BackgroundTransparency=1, Position=UDim2.new(0,5,0,0), Size=UDim2.new(1,-10,1,0),
				Font=Enum.Font.GothamBold, Text=Name, TextColor3=self.Instance.Theme.TextSec, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left
			})
			Window.ThemeRegistry:Register(Label, { type = "Text", properties = { TextColor3 = function(t) return t.TextSec end } })
			return Label
		end

		function Elements:CreateInput(Config)
			if not Validator.IsTable(Config, "CreateInput Config") then Config = {} end
			local Name = Config.Name or "Input"
			local Flag = Config.Flag or Name
			local Placeholder = Config.PlaceholderText or Config.Placeholder or "Type here..."
			local Callback = Config.Callback or function() end
			local RemoveTextAfterFocusLost = Config.RemoveTextAfterFocusLost or false
			
			local Frame = Create("Frame", {
				Parent = Config.Parent or Page, BackgroundColor3 = self.Instance.Theme.Element, Size = UDim2.new(1,0,0,44), BackgroundTransparency = 0
			})
			Frame:SetAttribute("EnvielTheme", "Element")
			Create("UICorner", {Parent = Frame, CornerRadius = UDim.new(0, 8)})
			Create("UIStroke", {Parent = Frame, Color = self.Instance.Theme.Stroke, Thickness = 1, Transparency = 0.5})
			
			local Label = Create("TextLabel", {
				Parent = Frame, BackgroundTransparency=1, Position=UDim2.new(0,15,0,0), Size=UDim2.new(1,-15,0,20),
				Font = FontBold,
				Text = Name, TextColor3 = self.Instance.Theme.Text, TextSize=13, TextXAlignment=Enum.TextXAlignment.Left
			})
			
			local InputBox = Create("TextBox", {
				Parent = Frame, BackgroundTransparency=1, Position=UDim2.new(0,15,0,22), Size=UDim2.new(1,-30,0,18),
				Font = FontBold,
				Text = "", PlaceholderText = Placeholder, TextColor3 = self.Instance.Theme.Accent, PlaceholderColor3 = self.Instance.Theme.TextSec,
				TextSize = 13, TextXAlignment=Enum.TextXAlignment.Left, ClearTextOnFocus = false
			})
			
			InputBox.FocusLost:Connect(function(enterPressed)
				local Text = InputBox.Text
				if RemoveTextAfterFocusLost then InputBox.Text = "" end
				self.Instance.Flags[Flag] = Text
				SafeCallback(Callback, Text)
			end)
			
			-- Registry
			Window.ThemeRegistry:Register(Frame, { type = "Element", updateStroke = true })
			Window.ThemeRegistry:Register(Label, { type = "Text" })
			Window.ThemeRegistry:Register(InputBox, { properties = { TextColor3 = function(t) return t.Accent end, PlaceholderColor3 = function(t) return t.TextSec end } })
			Window:RegisterSearchable(Frame, Name)
			
			return {
				Set = function(self, NewVal)
					if type(NewVal) == "table" and NewVal.Text then NewVal = NewVal.Text end
					InputBox.Text = tostring(NewVal)
					self.Instance.Flags[Flag] = tostring(NewVal)
				end
			}
		end
		
		function Elements:CreateParagraph(Config)
			local Title = Config.Title or "Paragraph"
			local Content = Config.Content or "Content"
			
			local Frame = Create("Frame", {
				Parent = Config.Parent or Page, BackgroundColor3 = self.Instance.Theme.Element, Size = UDim2.new(1,0,0,0), BackgroundTransparency = 0, AutomaticSize = Enum.AutomaticSize.Y
			})
			Frame:SetAttribute("EnvielTheme", "Element")
			Create("UICorner", {Parent = Frame, CornerRadius = UDim.new(0, 8)})
			Create("UIStroke", {Parent = Frame, Color = self.Instance.Theme.Stroke, Thickness = 1, Transparency = 0.5})
			Create("UIPadding", {Parent = Frame, PaddingTop=UDim.new(0,10), PaddingBottom=UDim.new(0,10), PaddingLeft=UDim.new(0,15), PaddingRight=UDim.new(0,15)})
			
			local TitleLabel = Create("TextLabel", {
				Parent = Frame, BackgroundTransparency=1, Size=UDim2.new(1,0,0,16),
				Font = FontBold,
				Text = Title, TextColor3 = self.Instance.Theme.Text, TextSize=14, TextXAlignment=Enum.TextXAlignment.Left
			})
			
			local ContentLabel = Create("TextLabel", {
				Parent = Frame, BackgroundTransparency=1, Size=UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y,
				Font = FontBold,
				Text = Content, TextColor3 = self.Instance.Theme.Description, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, TextWrapped = true
			})
			Create("UIListLayout", {Parent = Frame, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
			
			return {
				Set = function(self, Properties)
					if type(Properties) == "table" then
						if Properties.Title then TitleLabel.Text = Properties.Title end
						if Properties.Content then ContentLabel.Text = Properties.Content end
						if Properties.Visible ~= nil then Frame.Visible = Properties.Visible end
					end
				end
			}
		end

		function Elements:CreateClickableList(Config)
			local Title = Config.Title or "List"
			local Flag = Config.Flag or (Title .. "List")
			local Callback = Config.Callback or function() end
			local Height = Config.Height or UDim2.new(1, 0, 0, 200)
			
			local Content = Config.Content or {}
			
			local Frame = Create("Frame", {
				Parent = Config.Parent or Page, BackgroundColor3 = self.Instance.Theme.Element, Size = Height, BackgroundTransparency = 0.25
			})
			Frame:SetAttribute("EnvielTheme", "Element")
			Create("UICorner", {Parent = Frame, CornerRadius = UDim.new(0, 8)})
			Create("UIStroke", {Parent = Frame, Color = self.Instance.Theme.Stroke, Thickness = 1, Transparency = 0.5})
			
			local Header = Create("TextLabel", {
				Parent = Frame, BackgroundTransparency=1, Position=UDim2.new(0,15,0,5), Size=UDim2.new(1,-30,0,20),
				Font = FontBold,
				Text = Title, TextColor3 = self.Instance.Theme.Text, TextSize=14, TextXAlignment=Enum.TextXAlignment.Left
			})
			
			local ListContainer = Create("ScrollingFrame", {
				Parent = Frame, BackgroundTransparency=1, Position=UDim2.new(0,10,0,30), Size=UDim2.new(1,-20,1,-40),
				ScrollBarThickness=4, ScrollBarImageColor3=self.Instance.Theme.Stroke, CanvasSize=UDim2.new(0,0,0,0)
			})
			Create("UIListLayout", {Parent = ListContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4)})
			
			local function Refresh(NewList)
				for _, v in pairs(ListContainer:GetChildren()) do
					if v:IsA("TextButton") then v:Destroy() end
				end
				
				for i, itemText in ipairs(NewList) do
					local Btn = Create("TextButton", {
						Name = "Item_"..i,
						Parent = ListContainer, BackgroundColor3 = self.Instance.Theme.Main, BackgroundTransparency=0.5,
						Size = UDim2.new(1, 0, 0, 24), Text = "  " .. tostring(itemText),
						Font = FontBold,
						TextColor3 = self.Instance.Theme.TextSec, TextSize = 12, TextXAlignment=Enum.TextXAlignment.Left, AutoButtonColor = false
					})
					Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(0, 4)})
					
					Btn.MouseEnter:Connect(function() Tween(Btn, {BackgroundColor3 = self.Instance.Theme.Hover, TextColor3 = self.Instance.Theme.Text}, 0.2) end)
					Btn.MouseLeave:Connect(function() Tween(Btn, {BackgroundColor3 = self.Instance.Theme.Main, TextColor3 = self.Instance.Theme.TextSec}, 0.2) end)
					
					Btn.MouseButton1Click:Connect(function()
						Callback(itemText)
					end)
				end
				
				ListContainer.CanvasSize = UDim2.new(0, 0, 0, #NewList * 28)
			end
			
			Refresh(Content)
			
			return {
				Refresh = function(self, NewList)
					Refresh(NewList)
				end
			}
		end


		
		function Elements:CreateColorPicker(Config)
			local Name = Config.Name or "Color Picker"
			local Default = Config.CurrentValue or Color3.fromRGB(255, 255, 255)
			local Callback = Config.Callback or function() end
			
			local Value = Default
			local Expanded = false
			
			local Frame = Create("Frame", {
				Parent = Config.Parent or Page, BackgroundColor3 = self.Instance.Theme.Secondary, Size = UDim2.new(1,0,0,46), BackgroundTransparency = 0, ClipsDescendants = true
			})
			Frame:SetAttribute("EnvielTheme", "Secondary")
			Create("UICorner", {Parent=Frame, CornerRadius=UDim.new(0,8)})
			Create("UIStroke", {Parent=Frame, Color=self.Instance.Theme.Stroke, Thickness=1, Transparency=0.5})

			Create("TextLabel", {
				Parent=Frame, BackgroundTransparency=1, Position=UDim2.new(0,15,0,0), Size=UDim2.new(1,-60,0,46),
				Font = FontBold, Text=Name, TextColor3=self.Instance.Theme.Text, TextSize=14, TextXAlignment=Enum.TextXAlignment.Left
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
				SafeCallback(Callback, Value)
			end
			
			local function makeSlider(yPos, Text, InitialVal, UpdateVal)
				local Label = Create("TextLabel", {
					Parent=PickerFrame, Text=Text, TextColor3=self.Instance.Theme.Text, 
					BackgroundTransparency=1, Position=UDim2.new(0,0,0,yPos), Size=UDim2.new(0,15,0,20),
					Font = FontBold, TextSize = 12
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
				
				local function update(input)
					local SizeX = Track.AbsoluteSize.X
					local PosX = input.Position.X - Track.AbsolutePosition.X
					local Percent = math.clamp(PosX / SizeX, 0, 1)
					Tween(Fill, {Size=UDim2.new(Percent,0,1,0)}, 0.05)
					UpdateVal(math.floor(Percent*255))
					UpdateColor()
				end
				
				Track.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						Sliding = true
						update(input)
					end
				end)
				
				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						Sliding = false
					end
				end)
				
				UserInputService.InputChanged:Connect(function(input)
					if Sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
						update(input)
					end
				end)
			end
			
			makeSlider(20, "R", r, function(v) r = v end)
			makeSlider(50, "G", g, function(v) g = v end)
			makeSlider(80, "B", b, function(v) b = v end)
			
			-- Toggle Picker
			ColorDisplay.MouseButton1Click:Connect(function()
				Expanded = not Expanded
				if Expanded then
					Tween(Frame, {Size=UDim2.new(1,0,0,165)}, 0.3)
				else
					Tween(Frame, {Size=UDim2.new(1,0,0,46)}, 0.3)
				end
			end)
			
			local function startHueSliding()
				if hueConnection then return end
				
				hueConnection = RunService.RenderStepped:Connect(function()
					if not HueSliding then
						if hueConnection then
							hueConnection:Disconnect()
							hueConnection = nil
						end
						return
					end
					
					local mouse = UserInputService:GetMouseLocation().X
					local rel = math.clamp((mouse - HueBar.AbsolutePosition.X)/HueBar.AbsoluteSize.X, 0, 1)
					local HueColor = Color3.fromHSV(rel, 1, 1)
					r, g, b = math.floor(HueColor.R*255), math.floor(HueColor.G*255), math.floor(HueColor.B*255)
					
					fillR.Size = UDim2.new(r/255, 0, 1, 0)
					fillG.Size = UDim2.new(g/255, 0, 1, 0)
					fillB.Size = UDim2.new(b/255, 0, 1, 0)
					
					UpdateColor()
				end)
			end
			
			HueBar.InputBegan:Connect(function(i) 
				if i.UserInputType == Enum.UserInputType.MouseButton1 then 
					HueSliding = true
					startHueSliding()
				end 
			end)
			
			UserInputService.InputEnded:Connect(function(i) 
				if i.UserInputType == Enum.UserInputType.MouseButton1 then 
					HueSliding = false
				end 
			end)
			
			ColorDisplay.MouseButton1Click:Connect(function()
				Expanded = not Expanded
				Tween(Frame, {Size = Expanded and UDim2.new(1,0,0,170) or UDim2.new(1,0,0,46)}, 0.3)
			end)
			
			-- Registry
			Window.ThemeRegistry:Register(Frame, { type = "Secondary", updateStroke = true })
			Window:RegisterSearchable(Frame, Name)
		end
		
		function Elements:CreateGroup(Config)
			local Title = Config.Title or Config.Name or "Group"
			local GroupConfig = {
				Name = Title,
				Parent = Config.Parent or Page,
				BackgroundColor3 = self.Instance.Theme.Element,
				BackgroundTransparency = 0.25,
				Size = UDim2.new(1, 0, 0, 32),
				AutomaticSize = Enum.AutomaticSize.Y,
				ClipsDescendants = true
			}
			
			local GroupFrame = Create("Frame", GroupConfig)
			GroupFrame:SetAttribute("EnvielTheme", "Element")
			Create("UICorner", {Parent = GroupFrame, CornerRadius = UDim.new(0, 8)})
			Create("UIStroke", {Parent = GroupFrame, Color = self.Instance.Theme.Stroke, Thickness = 1, Transparency = 0.5})
			
			local HeaderBtn = Create("TextButton", {
				Parent = GroupFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 32), Text = "", AutoButtonColor = false
			})
			
			local IconAsset = GetIcon(Config.Icon)
			local TitleX = 15
			local TitleW = -40
			
			if IconAsset ~= "" then
				Create("ImageLabel", {
					Parent = HeaderBtn, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0.5, -7), Size = UDim2.new(0, 14, 0, 14),
					Image = IconAsset, ImageColor3 = self.Instance.Theme.Accent
				})
				TitleX = 35 -- Adjusted Title Position
				TitleW = -60
			end
			
			local TitleLbl = Create("TextLabel", {
				Parent = HeaderBtn, BackgroundTransparency = 1, Size = UDim2.new(1, TitleW, 1, 0), Position = UDim2.new(0, TitleX, 0, 0),
				Text = Title, Font = FontBold, TextSize = 13, TextColor3 = self.Instance.Theme.Text, TextXAlignment = Enum.TextXAlignment.Left
			})
			
			local Arrow = Create("ImageLabel", {
				Parent = HeaderBtn, BackgroundTransparency = 1, Position = UDim2.new(1, -28, 0.5, -8), Size = UDim2.new(0, 16, 0, 16),
				Image = GetIcon("chevron-down"), ImageColor3 = self.Instance.Theme.TextSec
			})
			
			local GroupContent = Create("Frame", {
				Parent = GroupFrame, BackgroundTransparency = 1, 
				Size = UDim2.new(1, 0, 0, 0), Position = UDim2.new(0, 0, 0, 32),
				AutomaticSize = Enum.AutomaticSize.Y, Visible = false
			})
			Create("UIListLayout", {Parent = GroupContent, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
			Create("UIPadding", {Parent = GroupContent, PaddingTop=UDim.new(0,5), PaddingBottom=UDim.new(0,10), PaddingLeft=UDim.new(0,10), PaddingRight=UDim.new(0,10)})
			
			local Expanded = false

			local GroupElements = setmetatable({}, Elements)
			
			function GroupElements:Collapse()
				if not Expanded then return end
				Expanded = false
				GroupContent.Visible = false
				Tween(Arrow, {Rotation = 0}, 0.2)
			end
			
			function GroupElements:Expand()
				if Expanded then return end
				for _, g in pairs(Window.Groups) do
					if g.ParentPage == Page and g ~= GroupElements then
						g:Collapse()
					end
				end
				
				Expanded = true
				GroupContent.Visible = true
				Tween(Arrow, {Rotation = 180}, 0.2)
			end

			HeaderBtn.MouseButton1Click:Connect(function()
				if Expanded then
					GroupElements:Collapse()
				else
					GroupElements:Expand()
				end
			end)
			
			table.insert(Window.Groups, GroupElements)
			GroupElements.Instance = self.Instance 
			GroupElements.ParentPage = Page
			
			function GroupElements:CreateButton(Cfg) Cfg.Parent = GroupContent return Elements:CreateButton(Cfg) end
			function GroupElements:CreateToggle(Cfg) Cfg.Parent = GroupContent return Elements:CreateToggle(Cfg) end
			function GroupElements:CreateSlider(Cfg) Cfg.Parent = GroupContent return Elements:CreateSlider(Cfg) end
			function GroupElements:CreateDropdown(Cfg) Cfg.Parent = GroupContent return Elements:CreateDropdown(Cfg) end
			function GroupElements:CreateInput(Cfg) Cfg.Parent = GroupContent return Elements:CreateInput(Cfg) end
			function GroupElements:CreateColorPicker(Cfg) Cfg.Parent = GroupContent return Elements:CreateColorPicker(Cfg) end
			function GroupElements:CreateClickableList(Cfg) Cfg.Parent = GroupContent return Elements:CreateClickableList(Cfg) end
			function GroupElements:CreateParagraph(Cfg) Cfg.Parent = GroupContent return Elements:CreateParagraph(Cfg) end
			function GroupElements:CreateSection(Name) return Elements:CreateSection(Name) end 
			
			return GroupElements
		end
		
		return Elements
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
		local TitleText = Config.Title or "Enviel System"
		local ContentText = Config.Content or Config.Description or "Message"
		local Duration = Config.Duration or 3
		local Image = GetIcon("megaphone")
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
			Position = UDim2.new(0, 17, 0, 17), Size = UDim2.new(0, 36, 0, 36),
			Image = Image, ImageColor3 = self.Instance.Theme.Text
		})
		Create("UICorner", {Parent = Icon, CornerRadius = UDim.new(0, 8)})
		
		local TitleLabel = Create("TextLabel", {
			Parent = NotifFrame, BackgroundTransparency = 1,
			Position = UDim2.new(0, 70, 0, 10), Size = UDim2.new(1, -80, 0, 20),
			Font = FontBold, Text = TitleText, TextColor3 = self.Instance.Theme.Text,
			TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left
		})
		
		local ContentLabel = Create("TextLabel", {
			Parent = NotifFrame, BackgroundTransparency = 1,
			Position = UDim2.new(0, 70, 0, 30), Size = UDim2.new(1, -80, 0, 30),
			Font = FontBold, Text = ContentText, TextColor3 = self.Instance.Theme.TextSec,
			TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true
		})
		
		NotifFrame.Position = UDim2.new(1, 50, 0, 0)
		NotifFrame.BackgroundTransparency = 1
		Icon.ImageTransparency = 1
		TitleLabel.TextTransparency = 0
		ContentLabel.TextTransparency = 0
		TitleLabel.ZIndex = 2
		ContentLabel.ZIndex = 2

		Tween(NotifFrame, {Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0.2}, 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		Tween(Icon, {ImageTransparency = 0}, 0.5)
		Tween(TitleLabel, {TextTransparency = 0}, 0.5)
		Tween(ContentLabel, {TextTransparency = 0}, 0.5)
		
		task.delay(Duration, function()
			Tween(NotifFrame, {Position = UDim2.new(1, 50, 0, 0), BackgroundTransparency = 1}, 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
			Tween(Icon, {ImageTransparency = 1}, 0.5)
			Tween(TitleLabel, {TextTransparency = 1}, 0.5)
			Tween(ContentLabel, {TextTransparency = 1}, 0.5).Completed:Wait()
			NotifFrame:Destroy()
		end)
	end

	function Window:Watermark(Config)
		
		local WatermarkFrame = Create("Frame", {
			Parent = MainFrame, Name = "Watermark", BackgroundColor3 = self.Instance.Theme.Stroke,
			Size = UDim2.new(0, 0, 0, 22),
			Position = UDim2.new(0, 15, 1, -85), -- Fixed position above Floating Dock
			Visible = true,
			ZIndex = 2
		})
		Create("UICorner", {Parent = WatermarkFrame, CornerRadius = UDim.new(0, 4)})
		Create("UIStroke", {Parent = WatermarkFrame, Color = self.Instance.Theme.Stroke, Thickness = 1})
		
		local Text = Create("TextLabel", {
			Parent = WatermarkFrame, Name = "WatermarkText", BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0),
			Font = FontBold, TextSize = 11, TextColor3 = self.Instance.Theme.Text,
			Text = Config.Title or Config.Text or "Enviel UI",
			TextXAlignment = Enum.TextXAlignment.Center
		})
		

		WatermarkFrame.Size = UDim2.new(0, Text.TextBounds.X + 16, 0, 22)
	end

	function Window:Prompt(Config)
		local Title = Config.Title or "Alert"
		local Content = Config.Content or "Are you sure?"
		local Actions = Config.Actions or {
			{Text = "OK", Callback = function() end}
		}
		
		local Overlay = Create("Frame", {
			Parent = ScreenGui, Name = "PromptOverlay", BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0), ZIndex = 2000
		})
		
		local PromptFrame = Create("Frame", {
			Parent = Overlay, Name = "Content", BackgroundColor3 = self.Instance.Theme.Main,
			Size = UDim2.new(0, 320, 0, 0), Position = UDim2.new(0.5, -160, 0.5, -50),
			AutomaticSize = Enum.AutomaticSize.Y
		})
		Create("UICorner", {Parent = PromptFrame, CornerRadius = UDim.new(0, 10)})
		Create("UIStroke", {Parent = PromptFrame, Color = self.Instance.Theme.Stroke, Thickness = 2})
		Create("UIPadding", {Parent = PromptFrame, PaddingTop=UDim.new(0,20), PaddingBottom=UDim.new(0,20), PaddingLeft=UDim.new(0,20), PaddingRight=UDim.new(0,20)})
		
		local TitleLbl = Create("TextLabel", {
			Parent = PromptFrame, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,24),
			Text = Title, Font = FontBold, TextSize = 18, TextColor3 = self.Instance.Theme.Text
		})
		
		local ContentLbl = Create("TextLabel", {
			Parent = PromptFrame, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,0), Position = UDim2.new(0,0,0,30),
			Text = Content, Font = FontBold, TextSize = 14, TextColor3 = self.Instance.Theme.TextSec,
			TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y
		})
		
		local ButtonContainer = Create("Frame", {
			Parent = PromptFrame, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,30), Position = UDim2.new(0,0,0, ContentLbl.AbsoluteSize.Y + 45),
			AutomaticSize = Enum.AutomaticSize.Y
		})
		Create("UIListLayout", {Parent = ButtonContainer, FillDirection=Enum.FillDirection.Horizontal, HorizontalAlignment=Enum.HorizontalAlignment.Center, Padding=UDim.new(0,10)})
		
		ContentLbl:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			ButtonContainer.Position = UDim2.new(0,0,0, ContentLbl.AbsoluteSize.Y + 45)
		end)

		local Scale = Create("UIScale", {Parent = PromptFrame, Scale = 0.8})
		local Closing = false

		for _, Action in pairs(Actions) do
			local Btn = Create("TextButton", {
				Parent = ButtonContainer, BackgroundColor3 = self.Instance.Theme.Accent, Size = UDim2.new(0, 100, 0, 32),
				Text = Action.Text, Font = FontBold, TextSize = 13, TextColor3 = self.Instance.Theme.AccentText,
				AutoButtonColor = false
			})
			Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(0, 6)})
			
			Btn.MouseButton1Click:Connect(function()
				if Closing then return end
				Closing = true
				
				if Action.Callback then Action.Callback() end
				if Overlay then Tween(Overlay, {BackgroundTransparency = 1}, 0.2) end
				if PromptFrame then Tween(PromptFrame, {BackgroundTransparency = 1}, 0.2) end
				if Scale then Tween(Scale, {Scale = 0.8}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In) end
				
				task.delay(0.2, function()
					if Overlay then Overlay:Destroy() end
				end)
			end)
		end
		
		Tween(Overlay, {BackgroundTransparency = 0.6}, 0.3)
		PromptFrame.BackgroundTransparency = 1
		Tween(PromptFrame, {BackgroundTransparency = 0}, 0.3)
		Scale.Scale = 0.8 
		Tween(Scale, {Scale = 1}, 0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		PromptFrame.Size = UDim2.new(0, 320, 0, 150 + ContentLbl.AbsoluteSize.Y)
	end
	
	return Window
end

return EnvielUI
