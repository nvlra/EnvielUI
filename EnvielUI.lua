if task and task.synchronize then pcall(task.synchronize) end
local EnvielUI = {}
EnvielUI.__index = EnvielUI

local LOGO_WHITE = "94854804824909"
local LOGO_BLACK = "120261170817156"

local LibraryConfig = {
    Transparency = 0.1,
    CornerRadius = {
        Window = 14,
        Group = 12,
        Element = 8,
        Inner = 6
    },
    Colors = {
        Main = Color3.fromHex("2B2B2B"),
        Secondary = Color3.fromHex("1D1D1D"),
        Stroke = Color3.fromHex("787878"),
        Text = Color3.fromHex("FFFFFF"),
        TextDark = Color3.fromHex("888888"),
        Accent = Color3.fromHex("FFFFFF"),
        Element = Color3.fromHex("1D1D1D"),
        ToggleActive = Color3.fromHex("D4D4D4"),
        ToggleInactive = Color3.fromHex("676767"),
        Input = Color3.fromHex("414141"),
        Button = Color3.fromHex("FFFFFF"),
        ButtonText = Color3.fromHex("000000"),
    },
    Sizes = {
        HeaderHeight = {PC = 50, Mobile = 34},
        NavHeight = {PC = 44, Mobile = 32},
        NavPadding = {PC = 20, Mobile = 10},
        ItemHeight = {PC = 42, Mobile = 32},
        TextSize = {PC = 13, Mobile = 10},
        TitleSize = {PC = 18, Mobile = 14}
    },
    Animation = {
        TweenSpeed = 0.25,
        SpringSpeed = 0.4
    }
}

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
	if not IconLib then return "" end
	
	local s, i = pcall(function() return IconLib.GetIcon(Name) end)
	return (s and i) or ""
end

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

local function Lighten(Color, Amount)
	local H, S, V = Color:ToHSV()
	V = math.clamp(V + Amount, 0, 1)
	return Color3.fromHSV(H, S, V)
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

function EnvielUI:GetIcon(Name)
	return GetIcon(Name)
end

function EnvielUI:CreateWindow(Config)
	Config = Validate(Config, {
		Name = "Enviel UI",
        Transparency = LibraryConfig.Transparency,
		Theme = LibraryConfig.Colors
	})

	local Window = {
		Flags = {}, 
		Theme = Config.Theme,
		Connections = {},
        OnCloseCallbacks = {}
	}
	
	function Window:OnClose(Callback)
        if type(Callback) == "function" then
            table.insert(Window.OnCloseCallbacks, Callback)
        end
    end

	function Window:SafeConnect(Signal, Callback)
		local Conn = Signal:Connect(Callback)
		table.insert(Window.Connections, Conn)
		return Conn
	end
	
	local Name = Config.Name
    local WindowTransparency = Config.Transparency
	
	local Parent = game:GetService("CoreGui")
	if not pcall(function() return Parent.Name end) then Parent = Players.LocalPlayer.PlayerGui end
	
	local ScreenGui = Create("ScreenGui", {
		Name = "EnvielUI", Parent = Parent, 
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling, ResetOnSpawn = false,
		IgnoreGuiInset = true, DisplayOrder = 1000000
	})
	
	local MainFrame = Create("Frame", {
		Name = "MainFrame", Parent = ScreenGui, BackgroundTransparency = 1,
		Size = UDim2.fromOffset(580, 380), Position = UDim2.fromScale(0.5, 0.45),
		AnchorPoint = Vector2.new(0.5, 0.5), Active = true
	})
	Window.MainFrame = MainFrame
	
	local MainScale = Create("UIScale", {Parent = MainFrame, Scale = 0.9})
	
    local Camera = workspace.CurrentCamera
	local IsMobile = Camera.ViewportSize.X < 800
    
    local function AddHover(Obj, NormalColor)
        if IsMobile then return end
        if not Obj then return end
        Obj.MouseEnter:Connect(function()
            Tween(Obj, {BackgroundColor3 = Lighten(NormalColor, 0.1)}, 0.2)
        end)
        Obj.MouseLeave:Connect(function()
            Tween(Obj, {BackgroundColor3 = NormalColor}, 0.2)
        end)
    end
	
	local ContentWindow = Create("CanvasGroup", {
		Name = "ContentWindow", Parent = MainFrame, BackgroundColor3 = Window.Theme.Main,
		Size = UDim2.new(1, 0, 1, 0), BorderSizePixel = 0, GroupTransparency = 1, BackgroundTransparency = Config.Transparency
	})
	
	local ItemH = IsMobile and LibraryConfig.Sizes.ItemHeight.Mobile or LibraryConfig.Sizes.ItemHeight.PC
	local TextS = IsMobile and LibraryConfig.Sizes.TextSize.Mobile or LibraryConfig.Sizes.TextSize.PC
	local TitleS = IsMobile and LibraryConfig.Sizes.TitleSize.Mobile or LibraryConfig.Sizes.TitleSize.PC
	local HdrH = IsMobile and LibraryConfig.Sizes.HeaderHeight.Mobile or LibraryConfig.Sizes.HeaderHeight.PC

    local ViewportSize = Camera.ViewportSize
    local MinHeight = IsMobile and 130 or 320
    
	if IsMobile then 
		MainFrame.Size = UDim2.fromScale(0.55, 0)
		MainFrame.Position = UDim2.fromScale(0.5, 0.45)
        MainFrame.AutomaticSize = Enum.AutomaticSize.Y
        
        local MaxHeight = math.floor(ViewportSize.Y * 0.8)
        
        Create("UISizeConstraint", {
            Parent = MainFrame,
            MinSize = Vector2.new(0, MinHeight),
            MaxSize = Vector2.new(9999, math.min(450, MaxHeight))
        })
	else
		MainFrame.Size = UDim2.fromOffset(650, 450)
		MainFrame.Position = UDim2.fromScale(0.5, 0.5)
	end
	
	Create("UICorner", {Parent = ContentWindow, CornerRadius = UDim.new(0, 14)})

	task.spawn(function()
		ContentWindow.GroupTransparency = 1
		Tween(MainScale, {Scale = 1}, 0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		Tween(ContentWindow, {GroupTransparency = 0}, 0.4)
	end)
	
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
		Text = "Made By Enviel", Font = Enum.Font.Gotham, TextColor3 = Color3.fromHex("FFFFFF"), TextTransparency = 0.55, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right, BackgroundTransparency = 1
	})
	
	local CloseBtn = Create("ImageButton", {
		Parent = Controls, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(20, 20),
		BackgroundTransparency = 1, Image = GetIcon("x") or "", ImageColor3 = Window.Theme.TextDark
	})
    
    if not IsMobile then
        CloseBtn.MouseEnter:Connect(function() Tween(CloseBtn, {ImageColor3 = Window.Theme.Text}, 0.2) end)
        CloseBtn.MouseLeave:Connect(function() Tween(CloseBtn, {ImageColor3 = Window.Theme.TextDark}, 0.2) end)
    end

	CloseBtn.MouseButton1Click:Connect(function() 
		Window:Prompt({
			Title = "Close Interface?",
			Content = "Are you sure you want to close Enviel UI?",
			Actions = {
				{Text = "Cancel", Callback = function() end}, 
				{Text = "Confirm", Callback = function() 
					ScreenGui:Destroy() 
                    for _, cb in pairs(Window.OnCloseCallbacks) do task.spawn(cb) end
					for _, c in pairs(Window.Connections) do c:Disconnect() end
					Window.Connections = {}
				end}
			}
		})
	end)

	local MinBtn = Create("ImageButton", {
		Parent = Controls, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -30, 0.5, 0), Size = UDim2.fromOffset(18, 18),
		BackgroundTransparency = 1, Image = GetIcon("minimize") or "", ImageColor3 = Window.Theme.TextDark
	})
    if not IsMobile then
        MinBtn.MouseEnter:Connect(function() Tween(MinBtn, {ImageColor3 = Window.Theme.Text}, 0.2) end)
        MinBtn.MouseLeave:Connect(function() Tween(MinBtn, {ImageColor3 = Window.Theme.TextDark}, 0.2) end)
    end
	
	
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
		Parent = MiniButton, BackgroundTransparency = 1, Size = UDim2.new(0, 28, 0, 28), Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5), Image = "rbxthumb://type=Asset&id="..LOGO_WHITE.."&w=150&h=150", ImageColor3 = Window.Theme.Accent
	})
	
	Dragify(MiniClick, MiniButton)
	
	MiniClick.MouseButton1Click:Connect(function()
		Tween(MiniScale, {Scale = 0}, 0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		Tween(MiniButton, {GroupTransparency = 1}, 0.15).Completed:Wait()
		
		MiniButton.Visible = false
		MainFrame.Visible = true
		
		MainScale.Scale = 0
		ContentWindow.GroupTransparency = 1
		local D = MainFrame:FindFirstChild("Dock")
		if D and D:IsA("CanvasGroup") then D.GroupTransparency = 1 end
		
		Tween(MainScale, {Scale = 1}, 0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		Tween(ContentWindow, {GroupTransparency = 0}, 0.2)
		if D then
            if D:IsA("CanvasGroup") then Tween(D, {GroupTransparency = 0}, 0.2) else Tween(D, {BackgroundTransparency = 0.25}, 0.2) end
        end
	end)
	
	MinBtn.MouseButton1Click:Connect(function()
		Tween(MainScale, {Scale = 0}, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In)
		Tween(ContentWindow, {GroupTransparency = 1}, 0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		
		local D = MainFrame:FindFirstChild("Dock")
		if D then
            if D:IsA("CanvasGroup") then Tween(D, {GroupTransparency = 1}, 0.15) else Tween(D, {BackgroundTransparency = 1}, 0.15) end
        end
		
		task.wait(0.2)
		MainFrame.Visible = false
		
		MiniButton.Visible = true
		MiniButton.GroupTransparency = 1
		MiniScale.Scale = 0
		Tween(MiniButton, {GroupTransparency = 0}, 0.2)
		Tween(MiniScale, {Scale = 1}, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	end)
	
	local NotifHolder = Create("Frame", {
		Parent = ScreenGui, BackgroundTransparency = 1, Size = IsMobile and UDim2.new(0, 180, 1, -20) or UDim2.new(0, 360, 1, -20),
		Position = IsMobile and UDim2.new(1, -190, 0, 20) or UDim2.new(1, -380, 0, 20), AnchorPoint = Vector2.new(0, 0)
	})
	Create("UIListLayout", {Parent = NotifHolder, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2), VerticalAlignment = Enum.VerticalAlignment.Bottom})
	
	function Window:Notify(Cfg)
		local Title = Cfg.Title or "Notification"
		local Content = Cfg.Content or ""
		local Duration = Cfg.Duration or 3
		
		local Wrapper = Create("Frame", {
			Parent = NotifHolder, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), ClipsDescendants = true
		})
		
		local F = Create("Frame", {
			Parent = Wrapper, BackgroundColor3 = Window.Theme.Main, 
			Size = UDim2.new(1, -4, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
			Position = UDim2.new(1.5, 0, 0, 0),
            BackgroundTransparency = 0.05
		})
		
		Create("UICorner", {Parent = F, CornerRadius = UDim.new(0, 16)})
        Create("UISizeConstraint", {Parent = F, MinSize = IsMobile and Vector2.new(0, 50) or Vector2.new(0, 70)})

		local Accent = Create("Frame", {
			Parent = F, BackgroundColor3 = Window.Theme.Accent,
			Size = UDim2.new(0, 4, 1, -30), Position = UDim2.new(0, 8, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5)
		})
		Create("UICorner", {Parent = Accent, CornerRadius = UDim.new(1, 0)})
		
		local ContentPad = Create("Frame", {
			Parent = F, BackgroundTransparency = 1, Size = UDim2.new(1, -26, 1, 0), Position = UDim2.new(0, 24, 0, 0)
		})
		Create("UIListLayout", {Parent = ContentPad, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4), VerticalAlignment = Enum.VerticalAlignment.Center})
		Create("UIPadding", {Parent = ContentPad, PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)})

		Create("TextLabel", {
			Parent = ContentPad, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16), Text = Title,
			Font = Enum.Font.GothamBold, TextColor3 = Window.Theme.Text, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left
		})
		Create("TextLabel", {
			Parent = ContentPad, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
			Text = Content, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(230, 230, 230), TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true
		})
		
		task.spawn(function()
            RunService.RenderStepped:Wait() 
			local TargetSize = F.AbsoluteSize.Y
            local MinY = IsMobile and 50 or 70
			if TargetSize < MinY then TargetSize = MinY end
			Tween(Wrapper, {Size = UDim2.new(1, 0, 0, TargetSize + 2)}, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			
			Tween(F, {Position = UDim2.new(0, 0, 0, 0)}, 0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		end)
		
		task.delay(Duration, function()
			Tween(F, {Position = UDim2.new(1.5, 0, 0, 0)}, 0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
			
			task.wait(0.2)
			Tween(Wrapper, {Size = UDim2.new(1, 0, 0, 0)}, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out).Completed:Wait()
			Wrapper:Destroy()
		end)
	end
	
	function Window:OpenDropdownModal(Config, Callback)
		local Options = Config.Options or {}
		local Multi = Config.Multi or false
		local Current = Config.CurrentValue or (Multi and {} or Options[1])
		
		local Blur = game:GetService("Lighting"):FindFirstChild("EnvielBlur") or Instance.new("BlurEffect", game:GetService("Lighting"))
		Blur.Name = "EnvielBlur"
		Blur.Enabled = true
		Blur.Size = 0
		
		local Overlay = Create("TextButton", {
			Name = "ModalOverlay", Parent = ContentWindow, BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1), AutoButtonColor = false, Text = "", ZIndex = 50
		})
		
		local Container = Create("Frame", {
			Name = "DropdownModal", Parent = Overlay, BackgroundColor3 = Window.Theme.Main,
			Size = UDim2.new(IsMobile and 0.6 or 0.5, 0, 0, IsMobile and 250 or 300), Position = UDim2.new(0.5, 0, 1.5, 0),
			AnchorPoint = Vector2.new(0.5, 1), ZIndex = 10, BorderSizePixel = 0, BackgroundTransparency = 0.1
		})
		Create("UICorner", {Parent = Container, CornerRadius = UDim.new(0, 16)})
		local Patch = Create("Frame", {
			Parent = Container, BackgroundColor3 = Window.Theme.Main, Size = UDim2.new(1, 0, 0, 20),
			Position = UDim2.new(0, 0, 1, -10), ZIndex = 9, BorderSizePixel = 0
		})
		
		local Header = Create("Frame", {
			Parent = Container, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 90)
		})
		Create("UIPadding", {Parent = Header, PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16), PaddingTop = UDim.new(0, 12)})
		
		Create("TextLabel", {
			Parent = Header, BackgroundTransparency = 1, Size = UDim2.new(1, -40, 0, 20),
			Text = Config.Name or "Select Option", Font = Enum.Font.GothamBold, TextColor3 = Window.Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left
		})
		
		local CloseBtn = Create("ImageButton", {
			Parent = Header, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0), Size = UDim2.fromOffset(20, 20),
			BackgroundTransparency = 1, Image = GetIcon("x") or "rbxassetid://6031094678", ImageColor3 = Window.Theme.TextDark
		})
		
		local SearchBg = Create("Frame", {
			Parent = Header, BackgroundColor3 = Window.Theme.Secondary, Size = UDim2.new(1, 0, 0, 36),
			Position = UDim2.new(0, 0, 0, 36)
		})
		Create("UICorner", {Parent = SearchBg, CornerRadius = UDim.new(0, 10)})

		
		local SearchIcon = Create("ImageLabel", {
			Parent = SearchBg, BackgroundTransparency = 1, Size = UDim2.fromOffset(16, 16), Position = UDim2.new(0, 12, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5), Image = GetIcon("search") or "rbxassetid://6031154871", ImageColor3 = Window.Theme.TextDark
		})
		
		local SearchInput = Create("TextBox", {
			Parent = SearchBg, BackgroundTransparency = 1, Size = UDim2.new(1, -44, 1, 0), Position = UDim2.new(0, 38, 0, 0),
			Text = "", PlaceholderText = "Search...", Font = Enum.Font.Gotham, TextSize = 13,
			TextColor3 = Window.Theme.Text, PlaceholderColor3 = Window.Theme.TextDark, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false
		})

		local List = Create("ScrollingFrame", {
			Parent = Container, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, -100), Position = UDim2.new(0, 0, 0, 100),
			ScrollBarThickness = 0, ScrollBarImageColor3 = Window.Theme.Stroke, CanvasSize = UDim2.new(0, 0, 0, 0)
		})
		Create("UIListLayout", {Parent = List, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6)})
		Create("UIPadding", {Parent = List, PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingBottom = UDim.new(0, 20)})
		
		local function Close()
			Tween(Container, {Position = UDim2.new(0.5, 0, 1.5, 0)}, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
			Tween(Overlay, {BackgroundTransparency = 1}, 0.3).Completed:Wait()
			Overlay:Destroy()
		end
		
		CloseBtn.MouseButton1Click:Connect(Close)
		Overlay.MouseButton1Click:Connect(Close)
		
		local tempSelected = Multi and {unpack(Current)} or Current

		local function Refresh(Query)
			for _, v in pairs(List:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
			
			local filtered = {}
			for _, opt in pairs(Options) do
				if not Query or string.find(tostring(opt):lower(), Query:lower()) then
					table.insert(filtered, opt)
				end
			end
			
			
			if (not Query or Query == "") then
				local sList, uList = {}, {}
				for _, opt in pairs(filtered) do
                    local isSel = false
                    if Multi then
                        if table.find(tempSelected, opt) then isSel = true end
                    else
                        if tempSelected == opt then isSel = true end
                    end
                    
					if isSel then
						table.insert(sList, opt)
					else
						table.insert(uList, opt)
					end
				end
				local newFiltered = {}
				for _, v in pairs(sList) do table.insert(newFiltered, v) end
				for _, v in pairs(uList) do table.insert(newFiltered, v) end
				filtered = newFiltered
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
					TextColor3 = isSelected and Window.Theme.Accent or Window.Theme.TextDark, TextSize = IsMobile and 11 or 13,
					TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false,
					BorderSizePixel = 0
				})
				Create("UICorner", {Parent = Item, CornerRadius = UDim.new(0, 8)})
				if isSelected then Create("UIStroke", {Parent = Item, Color = Window.Theme.Stroke, Thickness = 1}) end
                
                if not isSelected then
                    AddHover(Item, Window.Theme.Main)
                end
				
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
			
			local RowHeight = 48
			local ContentHeight = #filtered * RowHeight + 20
			local MinH = 180
			local MaxH = math.floor(MainFrame.AbsoluteSize.Y * 0.70)
			
			if MaxH < MinH then MaxH = MinH end
			
			local TargetH = math.clamp(ContentHeight + 100, MinH, MaxH)
			
			List.CanvasSize = UDim2.new(0, 0, 0, ContentHeight)
			Tween(Container, {Size = UDim2.new(0.5, 0, 0, TargetH)}, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		end
		
		SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
			Refresh(SearchInput.Text)
		end)
		
		Refresh()
		
		Tween(Overlay, {BackgroundTransparency = 0.4}, 0.3)
		Tween(Container, {Position = UDim2.new(0.5, 0, 1, IsMobile and -20 or 0)}, 0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	end

	
	local ContentHolder = Create("Frame", {
		Parent = ContentWindow, BackgroundTransparency = 1, Size = UDim2.new(1, -40, 1, -(HdrH + 20)), Position = UDim2.new(0, 20, 0, HdrH + 10), 
		BorderSizePixel = 0
	})
	
	local NavH = IsMobile and LibraryConfig.Sizes.NavHeight.Mobile or LibraryConfig.Sizes.NavHeight.PC
	local NavP = IsMobile and LibraryConfig.Sizes.NavPadding.Mobile or LibraryConfig.Sizes.NavPadding.PC

	local Dock = Create("CanvasGroup", {
		Name = "Dock", Parent = MainFrame, BackgroundColor3 = Window.Theme.Secondary, 
		Size = UDim2.new(0, 100, 0, NavH), -- Start small
		Position = UDim2.new(0.5, 0, 1, 15),
		AnchorPoint = Vector2.new(0.5, 0), 
		GroupTransparency = 0, BorderSizePixel = 0, 
		BackgroundTransparency = 0, ZIndex = 10,
		ClipsDescendants = true -- Prevent visual overflow
	})

	task.spawn(function()
		Dock.GroupTransparency = 1
		Tween(Dock, {GroupTransparency = 0}, 0.4)
	end)

	Create("UICorner", {Parent = Dock, CornerRadius = UDim.new(1, 0)})
    Create("UISizeConstraint", {Parent = Dock, MaxSize = Vector2.new(IsMobile and 350 or 650, 50)})

	-- ScrollingFrame for horizontal scrolling (if many tabs)
	local DockList = Create("ScrollingFrame", {
		Parent = Dock, 
		BackgroundTransparency = 1, 
		Size = UDim2.new(1, 0, 1, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.None, -- CRITICAL: Manual control
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarThickness = 0, 
		ScrollingDirection = Enum.ScrollingDirection.X,
		BorderSizePixel = 0,
		ScrollBarImageTransparency = 1
	})

	local DockLayout = Create("UIListLayout", {
		Parent = DockList, 
		FillDirection = Enum.FillDirection.Horizontal, 
		Padding = UDim.new(0, 10), 
		HorizontalAlignment = Enum.HorizontalAlignment.Left, -- Left for stable anchoring
		VerticalAlignment = Enum.VerticalAlignment.Center
	})
	Create("UIPadding", {Parent = DockList, PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 0)})

	-- Safe Queue System
	local UpdateQueued = false
	local CurrentDockWidth = 100 -- Match initial Dock.Size
	local ActiveTabButton = nil -- Track active button for sync

    -- Folder to isolate Indicator from UIListLayout
    local DecorFolder = Instance.new("Folder", DockList)
    DecorFolder.Name = "Decor"

	local ActiveIndicator = Create("Frame", {
		Parent = DecorFolder, -- Parent to Folder, not DockList directly
        BackgroundColor3 = Window.Theme.Accent, 
		Size = UDim2.new(0, 0, 1, -8), 
		Position = UDim2.new(0, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5), 
		ZIndex = 0
	})
	Create("UICorner", {Parent = ActiveIndicator, CornerRadius = UDim.new(1, 0)})

	local function QueueDockUpdate()
		if UpdateQueued then return end
		UpdateQueued = true
		
		task.defer(function()
			task.wait(0.05) -- 50ms debounce
			
			local ContentW = DockLayout.AbsoluteContentSize.X + 50
			local MaxW = IsMobile and 350 or 650
			local ClampedWidth = math.clamp(ContentW, 60, MaxW)
			
			-- Only update if changed significantly (>2px threshold)
			if math.abs(ClampedWidth - CurrentDockWidth) > 2 then
				CurrentDockWidth = ClampedWidth
				
				-- Update Dock size (direct, no tween to prevent cascade)
				Dock.Size = UDim2.new(0, ClampedWidth, 0, NavH)
				
				-- Update CanvasSize for scrolling (only if content exceeds dock)
				if ContentW > ClampedWidth then
					DockList.CanvasSize = UDim2.new(0, ContentW, 0, 0)
				else
					DockList.CanvasSize = UDim2.new(0, 0, 0, 0) -- No scroll needed
				end
			end
			
			UpdateQueued = false
			
			-- Sync Indicator Position after Resize
			if ActiveTabButton then
				local CenterX = (ActiveTabButton.AbsolutePosition.X - DockList.AbsolutePosition.X + (ActiveTabButton.AbsoluteSize.X / 2) + DockList.CanvasPosition.X) - 4
				ActiveIndicator.Position = UDim2.new(0, CenterX, 0.5, 0)
			end
		end)
	end

	DockLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(QueueDockUpdate)

	function Window:SelectTab(TabId)
		for _, p in pairs(ContentHolder:GetChildren()) do 
			if p:IsA("ScrollingFrame") then p.Visible = false end 
		end
		
		local Page = ContentHolder:FindFirstChild(TabId)
		if Page then
			Page.Visible = true
			
			local Btn = DockList:FindFirstChild(TabId.."Btn")
			if Btn then
				ActiveTabButton = Btn -- Updates the tracking variable
				task.spawn(function()
					RunService.RenderStepped:Wait()
                    local CenterX = (Btn.AbsolutePosition.X - DockList.AbsolutePosition.X + (Btn.AbsoluteSize.X / 2) + DockList.CanvasPosition.X) - 4
					
					Tween(ActiveIndicator, {
						Size = UDim2.new(0, Btn.AbsoluteSize.X, 1, -8), 
						Position = UDim2.new(0, CenterX, 0.5, 0)
					}, 0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

                    -- Auto Scroll to Tab (Preserved feature)
                    local CanvasX = CenterX - (DockList.AbsoluteWindowSize.X / 2)
                    Tween(DockList, {CanvasPosition = Vector2.new(CanvasX, 0)}, 0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
				end)

				for _, b in pairs(DockList:GetChildren()) do
					if b:IsA("TextButton") then
						local TargetColor = (b == Btn) and Color3.new(0,0,0) or Window.Theme.TextDark
						Tween(b, {TextColor3 = TargetColor}, 0.3)
					end
				end
			end
			
            task.spawn(function()
                 task.wait(0.05)
                 local List = Page:FindFirstChildWhichIsA("UIListLayout")
                 if List then
                      local ContentH = List.AbsoluteContentSize.Y
                      local Padding = 60
                      local TargetH = math.clamp(ContentH + HdrH + Padding, 180, 450)
                      
                      if IsMobile then
                          Tween(MainFrame, {Size = UDim2.new(0.60, 0, 0, TargetH)}, 0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
                      else
                          Tween(MainFrame, {Size = UDim2.fromOffset(650, TargetH)}, 0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
                      end
                 end
            end)
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
		Create("UIPadding", {Parent = Btn, PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12)})
		Btn.MouseButton1Click:Connect(function() Window:SelectTab(TabId) end)
		
        task.defer(QueueDockUpdate)

		local Page = Create("ScrollingFrame", {
			Name = TabId, Parent = ContentHolder, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), Visible = false,
			ScrollBarThickness = 2, ScrollBarImageColor3 = Window.Theme.Stroke, CanvasSize = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(1, 0, 1, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, BorderSizePixel = 0, ScrollingDirection = Enum.ScrollingDirection.Y
		})
        
        if not IsMobile then
            Btn.MouseEnter:Connect(function() if Page.Visible == false then Tween(Btn, {TextColor3 = Window.Theme.Text}, 0.2) end end)
            Btn.MouseLeave:Connect(function() if Page.Visible == false then Tween(Btn, {TextColor3 = Window.Theme.TextDark}, 0.2) end end)
        end

		local TabCount = 0
		for _, v in pairs(DockList:GetChildren()) do
			if v:IsA("TextButton") then TabCount += 1 end
		end
		if TabCount == 1 then
			task.spawn(function()
                local sT = tick()
                repeat RunService.RenderStepped:Wait() until Btn.AbsoluteSize.X > 0 or (tick()-sT > 2)
                task.wait(0.5) -- Slightly increased for robustness
				Window:SelectTab(TabId)
                task.delay(0.1, QueueDockUpdate) -- Force final sync snap
			end)
		end
		
		Create("UIListLayout", {Parent = Page, Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder})
		Create("UIPadding", {
            Parent = Page, 
            PaddingBottom = UDim.new(0, 10),
            PaddingTop = UDim.new(0, 5),
            PaddingLeft = UDim.new(0, 4), 
            PaddingRight = UDim.new(0, 4)
        })
		
		local Elements = {}
		
		function Elements:CreateSection(Cfg)
            local Text = (type(Cfg) == "table" and Cfg.Name) or Cfg
            local Parent = (type(Cfg) == "table" and Cfg.Parent) or Page
            
			Create("TextLabel", {
				Parent = Parent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24), Text = Text,
				Font = Enum.Font.GothamBold, TextColor3 = Window.Theme.Text, TextSize = TextS + 1,
				TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center
			})
		end

		function Elements:CreateGroup(Cfg)
			local Text = (type(Cfg) == "table" and Cfg.Name) or Cfg
			
			local GroupContainer = Create("Frame", {
				Parent = Page, BackgroundColor3 = Window.Theme.Element, Size = UDim2.new(1, 0, 0, 0), 
				AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 0.6
			})
			Create("UICorner", {Parent = GroupContainer, CornerRadius = UDim.new(0, 12)})
			Create("UIPadding", {Parent = GroupContainer, PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)})
			Create("UIListLayout", {Parent = GroupContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})
			
			if Text and Text ~= "" then
				Create("TextLabel", {
					Parent = GroupContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 0, 0), Text = Text,
					Font = Enum.Font.GothamBold, TextColor3 = Window.Theme.Text, TextSize = 13,
					TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = -1
				})
			end

			local GroupElements = {}
			for k,v in pairs(Elements) do
				if type(v) == "function" and k ~= "CreateGroup" then
					GroupElements[k] = function(self, Config)
                        if type(Config) ~= "table" then Config = {Name = Config} end
						Config = Config or {}
						Config.Parent = GroupContainer
                        Config.InGroup = true
						return v(self, Config)
					end
				end
			end
			return GroupElements
		end
		
		function Elements:CreateParagraph(Cfg)
			local F = Create("Frame", {Parent = Cfg.Parent or Page, BackgroundColor3 = Window.Theme.Secondary, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1})
			Create("UICorner", {Parent = F, CornerRadius = UDim.new(1, 0)})
			Create("UIPadding", {Parent = F, PaddingTop = UDim.new(0,10), PaddingBottom = UDim.new(0,10), PaddingLeft = UDim.new(0,16), PaddingRight = UDim.new(0,16)})
			Create("UIStroke", {Parent = F, Color = Window.Theme.TextDark, Thickness = 1, Transparency = 0.5})
			local Title = Create("TextLabel", {Parent = F, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,18), Text = Cfg.Title or "Header", Font = Enum.Font.GothamBold, TextColor3 = Window.Theme.Text, TextSize=13, TextXAlignment=Enum.TextXAlignment.Left})
			local Content = Create("TextLabel", {Parent = F, BackgroundTransparency = 1, Position=UDim2.new(0,0,0,20), Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y, Text = Cfg.Content or "", Font = Enum.Font.GothamMedium, TextColor3 = Window.Theme.TextDark, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true})
			
			local Para = {}
			function Para:Set(Props)
				if Props.Title then Title.Text = Props.Title end
				if Props.Content then Content.Text = Props.Content end
			end
			return Para
		end

		function Elements:CreateButton(Cfg)
			local F = Create("Frame", {Parent = Cfg.Parent or Page, BackgroundColor3 = Window.Theme.Button, Size = UDim2.new(1, 0, 0, ItemH), BackgroundTransparency = Cfg.InGroup and 1 or WindowTransparency})
			if not Cfg.InGroup then Create("UICorner", {Parent = F, CornerRadius = UDim.new(1, 0)}) end
			Create("UIPadding", {Parent = F, PaddingLeft = UDim.new(0, 0), PaddingRight = UDim.new(0, 0)})

			local B = Create("TextButton", {
				Parent = F, BackgroundTransparency = 0, BackgroundColor3 = Window.Theme.Button, Size = UDim2.new(1, 0, 1, 0),
				Font = Enum.Font.GothamMedium, Text = Cfg.Name or "Button", TextColor3 = Window.Theme.ButtonText, TextSize = TextS,
				TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Center, AutoButtonColor = false
			})
			Create("UICorner", {Parent = B, CornerRadius = UDim.new(1, 0)})
			local BScale = Create("UIScale", {Parent = B, Scale = 1})
			Create("UIStroke", {Parent = B, Color = Window.Theme.Stroke, Thickness = 0, Transparency = 1}) 
            AddHover(B, Window.Theme.Button)

			B.MouseButton1Click:Connect(function()
				Tween(BScale, {Scale = 0.95}, 0.05).Completed:Wait()
				Tween(BScale, {Scale = 1}, 0.1, Enum.EasingStyle.Quint)
				if Cfg.Callback then Cfg.Callback() end
			end)
		end

		function Elements:CreateToggle(Cfg)
			local F = Create("Frame", {Parent = Cfg.Parent or Page, BackgroundColor3 = Window.Theme.Secondary, Size = UDim2.new(1, 0, 0, ItemH), BackgroundTransparency = Cfg.InGroup and 1 or WindowTransparency})
			if not Cfg.InGroup then Create("UICorner", {Parent = F, CornerRadius = UDim.new(0, 8)}) end

			Create("TextLabel", {
				Parent = F, BackgroundTransparency = 1, Size = UDim2.new(1, -50, 1, 0), Position = UDim2.new(0, 0, 0, 0),
				Text = Cfg.Name or "Toggle", Font = Enum.Font.GothamMedium, TextColor3 = Window.Theme.Text, TextSize = TextS, TextXAlignment = Enum.TextXAlignment.Left
			})
			
			local Val = Cfg.CurrentValue or Cfg.Default or false
			local Switch = Create("TextButton", {
				Parent = F, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.new(0, 44, 0, 22),
				BackgroundColor3 = Val and Window.Theme.ToggleActive or Window.Theme.ToggleInactive, Text = "", AutoButtonColor = false
			})
			Create("UICorner", {Parent = Switch, CornerRadius = UDim.new(1, 0)})
            Create("UIStroke", {Parent = Switch, Color = Window.Theme.Stroke, Thickness = 1})
			local Circle = Create("Frame", {
				Parent = Switch, BackgroundColor3 = Color3.new(1,1,1), Size = UDim2.new(0, 18, 0, 18),
				Position = Val and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
			})
			Create("UICorner", {Parent = Circle, CornerRadius = UDim.new(1, 0)})
			
			local function UpdateVisuals()
				local TargetC = Val and Window.Theme.ToggleActive or Window.Theme.ToggleInactive
				Tween(Switch, {BackgroundColor3 = TargetC}, 0.2)
				Tween(Circle, {Position = Val and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}, 0.2)
			end
			
			local function UpdateState()
				if Cfg.Flag then Window.Flags[Cfg.Flag] = Val end
				if Cfg.Callback then Cfg.Callback(Val) end
				UpdateVisuals()
			end
			Switch.MouseButton1Click:Connect(function() Val = not Val UpdateState() end)
			if Cfg.Default then UpdateState() end
			return {Set = function(self, v) Val = v UpdateState() end}
		end

		function Elements:CreateSlider(Cfg)
			local Min, Max = Cfg.Min or 0, Cfg.Max or 100
			local Val = Cfg.Default or Min
			local F = Create("Frame", {Parent = Cfg.Parent or Page, BackgroundColor3 = Window.Theme.Secondary, Size = UDim2.new(1, 0, 0, ItemH + 8), BackgroundTransparency = Cfg.InGroup and 1 or WindowTransparency})
			if not Cfg.InGroup then Create("UICorner", {Parent = F, CornerRadius = UDim.new(0, 8)}) end

			Create("TextLabel", {
				Parent = F, BackgroundTransparency = 1, Size = UDim2.new(1, -24, 0, 24), Position = UDim2.new(0, 0, 0, 4),
				Text = Cfg.Name or "Slider", Font = Enum.Font.GothamMedium, TextColor3 = Window.Theme.Text, TextSize = TextS, TextXAlignment = Enum.TextXAlignment.Left
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
            AddHover(Thumb, Window.Theme.Accent)
			
			local function Update(Input)
				local Pct = math.clamp((Input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
				Val = math.floor(Min + (Max - Min) * Pct)
				Fill.Size = UDim2.new(Pct, 0, 1, 0)
				Thumb.Position = UDim2.new(Pct, -8, 0.5, -8)
				ValLbl.Text = tostring(Val)
				if Cfg.Flag then Window.Flags[Cfg.Flag] = Val end
				if Cfg.Callback then Cfg.Callback(Val) end
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

		function Elements:CreateInput(Cfg)
			local F = Create("Frame", {Parent = Cfg.Parent or Page, BackgroundColor3 = Window.Theme.Secondary, Size = UDim2.new(1, 0, 0, ItemH), BackgroundTransparency = Cfg.InGroup and 1 or WindowTransparency})
			if not Cfg.InGroup then Create("UICorner", {Parent = F, CornerRadius = UDim.new(0, 8)}) end

			Create("TextLabel", {
				Parent = F, BackgroundTransparency = 1, Size = UDim2.new(1, -160, 1, 0), Position = UDim2.new(0, 0, 0, 0),
				Text = Cfg.Name or "Input", Font = Enum.Font.GothamMedium, TextColor3 = Window.Theme.Text, TextSize = TextS, TextXAlignment = Enum.TextXAlignment.Left
			})
			
            local BoxContainer = Create("Frame", {
                Parent = F, BackgroundColor3 = Window.Theme.Input, 
                AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.new(0, 140, 0, 26)
            })
            Create("UICorner", {Parent = BoxContainer, CornerRadius = UDim.new(0, 6)})
            Create("UIStroke", {Parent = BoxContainer, Color = Window.Theme.Stroke, Thickness = 1})
            AddHover(BoxContainer, Window.Theme.Input)
            
			local Box = Create("TextBox", {
				Parent = BoxContainer, BackgroundTransparency = 1, Size = UDim2.new(1, -16, 1, 0), Position = UDim2.new(0, 8, 0, 0),
				Text = "", PlaceholderText = Cfg.PlaceholderText or "", Font = Enum.Font.Gotham, TextColor3 = Window.Theme.Text, 
				PlaceholderColor3 = Color3.fromRGB(180, 180, 180), TextSize = TextS, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false
			})

			Box.FocusLost:Connect(function()
				if tonumber(Box.Text) then Box.Text = tostring(tonumber(Box.Text)) end
				if Cfg.Flag then Window.Flags[Cfg.Flag] = Box.Text end
				if Cfg.Callback then Cfg.Callback(Box.Text) end
				if Cfg.RemoveTextAfterFocusLost then Box.Text = "" end
			end)
			return {Set = function(self, v) Box.Text = tostring(v) end}
		end

        function Elements:CreateDropdown(Cfg)
            local Options = Cfg.Options or {}
            local Current = Cfg.CurrentValue or (Cfg.Multi and "..." or Options[1])
            
            local F = Create("Frame", {Parent = Cfg.Parent or Page, BackgroundColor3 = Window.Theme.Secondary, Size = UDim2.new(1, 0, 0, ItemH), BackgroundTransparency = Cfg.InGroup and 1 or WindowTransparency})
            if not Cfg.InGroup then Create("UICorner", {Parent = F, CornerRadius = UDim.new(0, 8)}) end
            
            Create("TextLabel", {
                Parent = F, BackgroundTransparency = 1, Size = UDim2.new(1, -24, 1, 0), Position = UDim2.new(0, 12, 0, 0),
                Text = Cfg.Name or "Dropdown", Font = Enum.Font.GothamMedium, TextColor3 = Window.Theme.Text, TextSize = TextS, TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local Btn = Create("TextButton", {
                Parent = F, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.new(0, 120, 0, 26),
                BackgroundColor3 = Window.Theme.Input, Text = "  "..(type(Current)=="table" and table.concat(Current, ", ") or tostring(Current)),
                Font = Enum.Font.Gotham, TextColor3 = Window.Theme.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false,
				TextTruncate = Enum.TextTruncate.AtEnd
            })
            Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(0, 6)})
            Create("UIStroke", {Parent = Btn, Color = Window.Theme.Stroke, Thickness = 1})
            AddHover(Btn, Window.Theme.Input)
            
            Create("ImageLabel", {
                Parent = Btn, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.fromOffset(14, 14),
                BackgroundTransparency = 1, Image = GetIcon("chevron-down") or "rbxassetid://6031091004", ImageColor3 = Window.Theme.TextDark
            })
            
            Btn.MouseButton1Click:Connect(function()
                Window:OpenDropdownModal(Cfg, function(val)
                    Current = val
					Cfg.CurrentValue = val
                    Btn.Text = "  "..(type(Current)=="table" and table.concat(Current, ", ") or tostring(Current))
                    if Cfg.Flag then Window.Flags[Cfg.Flag] = Current end
                    if Cfg.Callback then Cfg.Callback(Current) end
                end)
            end)
            return {
                Set = function(self, v)
                     Current = v
					 Cfg.CurrentValue = v
                     Btn.Text = "  "..(type(Current)=="table" and table.concat(Current, ", ") or tostring(Current))
                end,
                Refresh = function(self, NewOptions)
                    Cfg.Options = NewOptions
                    Options = NewOptions

                    if not Cfg.Multi then
                        Current = NewOptions[1] or "..."
                    else
                         Current = {}
                    end
                    Btn.Text = "  "..(type(Current)=="table" and table.concat(Current, ", ") or tostring(Current))
                end
            }
        end

		function Elements:CreateCollapsibleGroup(Config)
			local Open = Config.DefaultOpen or false
			local GroupH = 0
			
			local ContainerStub = Create("Frame", {
				Parent = Config.Parent or Page, BackgroundColor3 = Window.Theme.Secondary, Size = UDim2.new(1, 0, 0, 36), 
				BackgroundTransparency = 0.8, ClipsDescendants = true
			})
			Create("UICorner", {Parent = ContainerStub, CornerRadius = UDim.new(0, 8)})
			
			local HeaderBtn = Create("TextButton", {
				Parent = ContainerStub, Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1, Text = "", AutoButtonColor = false
			})
			
			local Title = Create("TextLabel", {
				Parent = HeaderBtn, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -40, 1, 0),
				Text = Config.Title or "Group", Font = Enum.Font.GothamBold, TextColor3 = Window.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
			})
			
			local Arrow = Create("ImageLabel", {
				Parent = HeaderBtn, BackgroundTransparency = 1, Position = UDim2.new(1, -28, 0.5, -8), Size = UDim2.fromOffset(16, 16),
				Image = "rbxassetid://6031091004", ImageColor3 = Window.Theme.TextDark, Rotation = Open and 180 or 0
			})

			local Content = Create("Frame", {
				Parent = ContainerStub, Size = UDim2.new(1, 0, 0, Open and 0 or 0), Position = UDim2.new(0, 0, 0, 36),
				BackgroundTransparency = 1, ClipsDescendants = true, Visible = true
			})
			
			local Layout = Create("UIListLayout", {
				Parent = Content, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)
			})
			Create("UIPadding", {Parent = Content, PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingBottom = UDim.new(0, 10)})
			
			local function UpdateHeight()
				GroupH = Layout.AbsoluteContentSize.Y + 10
				if Open then
					ContainerStub.Size = UDim2.new(1, 0, 0, 36 + GroupH)
					Content.Size = UDim2.new(1, 0, 0, GroupH)
				else
					ContainerStub.Size = UDim2.new(1, 0, 0, 36)
					Content.Size = UDim2.new(1, 0, 0, 0)
				end
			end

			Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateHeight)
			
			HeaderBtn.MouseButton1Click:Connect(function()
				Open = not Open
				Tween(Arrow, {Rotation = Open and 180 or 0}, 0.2)
				
				local TargetH = Open and (36 + GroupH) or 36
				local ContentTargetH = Open and GroupH or 0

				Tween(ContainerStub, {Size = UDim2.new(1, 0, 0, TargetH)}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
				
				Tween(Content, {Size = UDim2.new(1, 0, 0, ContentTargetH)}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
			end)

			local GroupMethods = {}
			for k, v in pairs(Elements) do
				GroupMethods[k] = function(self, ChildConfig)
					ChildConfig.Parent = Content
                    ChildConfig.InGroup = true
					return Elements[k](Elements, ChildConfig)
				end
			end
			GroupMethods.CreateCollapsibleGroup = nil 
			GroupMethods.CreateGroup = GroupMethods.CreateCollapsibleGroup
			
			return GroupMethods
		end

		function Elements:CreateColorPicker(Config)
			local Flag = Config.Flag or Config.Name
			local Val = Config.Default or Color3.fromRGB(255, 255, 255)
			local Expanded = false
			
			local BaseH = 42
			local ExpandH = 42 + 60
			
			local F = Create("Frame", {Parent = Page, BackgroundColor3 = Window.Theme.Secondary, Size = UDim2.new(1, 0, 0, BaseH), ClipsDescendants = true, BackgroundTransparency = Config.InGroup and 1 or 0})
			if not Config.InGroup then Create("UICorner", {Parent = F, CornerRadius = UDim.new(0, 8)}) end

			
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

            return {Set = function(self, v)
                Val = v
                Preview.BackgroundColor3 = Val
                RS.UpdateFill() GS.UpdateFill() BS.UpdateFill()
            end}
		end

		return Elements
	end
	
	function Window:Prompt(Config)
		local Title = Config.Title or "Alert"
		local Content = Config.Content or "Are you sure?"
		local Actions = Config.Actions or {{Text = "OK", Callback = function() end}}
		
		local Blur = Create("TextButton", { -- Changed to TextButton to capture input (Modal)
			Parent = MainFrame, BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 1, Size = UDim2.fromScale(1,1), 
            Name = "AlertBlur", ZIndex = 100, AutoButtonColor = false, Text = ""
		})
		Create("UICorner", {Parent = Blur, CornerRadius = UDim.new(0, 14)})

		local AlertFrame = Create("CanvasGroup", {
			Parent = Blur, Size = UDim2.fromOffset(300, 160), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
			BackgroundColor3 = Window.Theme.Secondary, GroupTransparency = 1, Active = true
		})
		
		Create("UICorner", {Parent = AlertFrame, CornerRadius = UDim.new(0, 16)})
		
		Create("TextLabel", {
			Parent = AlertFrame, Size = UDim2.new(1, 0, 0, 40), Position = UDim2.new(0, 0, 0, 15), BackgroundTransparency = 1,
			Text = Title, Font = Enum.Font.GothamBold, TextColor3 = Window.Theme.Text, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Center
		})
		
		Create("TextLabel", {
			Parent = AlertFrame, Size = UDim2.new(1, -40, 0, 40), Position = UDim2.new(0, 20, 0, 50), BackgroundTransparency = 1,
			Text = Content, Font = Enum.Font.Gotham, TextColor3 = Window.Theme.TextDark, TextSize = 13, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Center
		})
		
		local BtnContainer = Create("Frame", {
			Parent = AlertFrame, Size = UDim2.new(1, -40, 0, 36), Position = UDim2.new(0, 20, 1, -25), AnchorPoint = Vector2.new(0, 1), BackgroundTransparency = 1
		})
		Create("UIListLayout", {Parent = BtnContainer, FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 12), HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder})
		
		for i, Action in pairs(Actions) do
            -- Smart detection: If explicitly Primary OR text is Confirm/Yes/OK -> Primary logic
            local IsPrimary = Action.Primary or (Action.Text:lower() == "yes" or Action.Text:lower() == "confirm" or Action.Text:lower() == "ok")
            
			local Btn = Create("TextButton", {
				Parent = BtnContainer, Size = UDim2.new(0.5, -6, 1, 0), 
                BackgroundColor3 = IsPrimary and Window.Theme.Text or Color3.new(0,0,0),
                BackgroundTransparency = IsPrimary and 0 or 1,
				Text = Action.Text, Font = Enum.Font.GothamBold, 
                TextColor3 = IsPrimary and Window.Theme.Main or Window.Theme.Text, 
                TextSize = 13, AutoButtonColor = false,
                LayoutOrder = IsPrimary and 2 or 1 -- Primary always on Right
			})
			Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(1, 0)})
            
            if not IsPrimary then
                Create("UIStroke", {
                    Parent = Btn, 
                    Color = Window.Theme.Text, 
                    Thickness = 1,
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                })
            end

			Btn.MouseButton1Click:Connect(function()
				if Action.Callback then Action.Callback() end
                if AlertFrame:IsA("CanvasGroup") then
				    Tween(AlertFrame, {GroupTransparency = 1, Size = UDim2.fromOffset(280, 140)}, 0.2, Enum.EasingStyle.Quint)
                else
                    Tween(AlertFrame, {BackgroundTransparency = 1, Size = UDim2.fromOffset(280, 140)}, 0.2, Enum.EasingStyle.Quint)
                end
				Tween(Blur, {BackgroundTransparency = 1}, 0.2).Completed:Wait()
				Blur:Destroy()
			end)
		end
		
		Tween(Blur, {BackgroundTransparency = 0.4}, 0.3)
		Tween(Blur, {BackgroundTransparency = 0.4}, 0.3)
        if AlertFrame:IsA("CanvasGroup") then
		    Tween(AlertFrame, {GroupTransparency = 0, Size = UDim2.fromOffset(300, 160)}, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        else
            Tween(AlertFrame, {BackgroundTransparency = 0, Size = UDim2.fromOffset(300, 160)}, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        end
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