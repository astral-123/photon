-- By EchoLabs — Reskin style Photon
local library = { 
	flags = { }, 
	items = { } 
}

-- Services
local players = game:GetService("Players")
local uis = game:GetService("UserInputService")
local runservice = game:GetService("RunService")
local tweenservice = game:GetService("TweenService")
local marketplaceservice = game:GetService("MarketplaceService")
local textservice = game:GetService("TextService")
local coregui = game:GetService("CoreGui")
local httpservice = game:GetService("HttpService")

local player = players.LocalPlayer
local mouse = player:GetMouse()
local camera = game.Workspace.CurrentCamera

-- ============================================================
-- KEYBIND HELPERS
-- ============================================================
local shorter_keycodes = {
	["LeftShift"]    = "LSHIFT",
	["RightShift"]   = "RSHIFT",
	["LeftControl"]  = "LCTRL",
	["RightControl"] = "RCTRL",
	["LeftAlt"]      = "LALT",
	["RightAlt"]     = "RALT",
}

local mouse_buttons = {
	[Enum.UserInputType.MouseButton1] = "MB1",
	[Enum.UserInputType.MouseButton2] = "MB2",
	[Enum.UserInputType.MouseButton3] = "MB3",
}

local function keybindToText(value)
	if value == "None" or value == nil then return "[None]" end
	if mouse_buttons[value] then return "[" .. mouse_buttons[value] .. "]" end
	if typeof(value) == "EnumItem" then return "[" .. (shorter_keycodes[value.Name] or value.Name) .. "]" end
	return "[" .. tostring(value) .. "]"
end

local function inputMatchesKeybind(input, value)
	if value == "None" or value == nil then return false end
	if mouse_buttons[value] then return input.UserInputType == value end
	if typeof(value) == "EnumItem" then
		return input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == value
	end
	return false
end

local function inputToKeybindValue(input)
	if mouse_buttons[input.UserInputType] then return input.UserInputType
	elseif input.UserInputType == Enum.UserInputType.Keyboard then return input.KeyCode
	end
	return "None"
end

-- ============================================================
-- THÈME PHOTON
-- ============================================================
library.theme = {
	fontsize        = 13,
	titlesize       = 15,
	font            = Enum.Font.GothamBold,
	background      = "",
	tilesize        = 90,
	backgroundcolor = Color3.fromRGB(18, 18, 18),    -- fond principal très sombre
	tabstextcolor   = Color3.fromRGB(180, 180, 180),
	bordercolor     = Color3.fromRGB(40, 40, 40),
	accentcolor     = Color3.fromRGB(232, 51, 58),   -- rouge Photon
	accentcolor2    = Color3.fromRGB(160, 25, 30),   -- rouge foncé
	outlinecolor    = Color3.fromRGB(45, 45, 45),
	outlinecolor2   = Color3.fromRGB(10, 10, 10),
	sectorcolor     = Color3.fromRGB(26, 26, 26),    -- card légèrement plus clair
	toptextcolor    = Color3.fromRGB(255, 255, 255),
	topheight       = 38,
	topcolor        = Color3.fromRGB(20, 20, 20),
	topcolor2       = Color3.fromRGB(16, 16, 16),
	buttoncolor     = Color3.fromRGB(38, 38, 38),
	buttoncolor2    = Color3.fromRGB(28, 28, 28),
	itemscolor      = Color3.fromRGB(190, 190, 190),
	itemscolor2     = Color3.fromRGB(220, 220, 220),
	-- Spécifique Photon
	tabbarcolor     = Color3.fromRGB(14, 14, 14),    -- barre onglets en bas
	tabbarheight    = 48,
	cardradius      = 4,
}

-- ============================================================
-- WATERMARK
-- ============================================================
function library:CreateWatermark(name, position)
	local gamename = marketplaceservice:GetProductInfo(game.PlaceId).Name
	local watermark = { }
	watermark.Visible = true
	watermark.text = " " .. name:gsub("{game}", gamename):gsub("{fps}", "0 FPS") .. " "

	watermark.main = Instance.new("ScreenGui", coregui)
	watermark.main.Name = "Watermark"
	if syn then syn.protect_gui(watermark.main) end

	if getgenv().watermark then getgenv().watermark:Remove() end
	getgenv().watermark = watermark.main

	watermark.mainbar = Instance.new("Frame", watermark.main)
	watermark.mainbar.Name = "Main"
	watermark.mainbar.BorderSizePixel = 0
	watermark.mainbar.ZIndex = 5
	watermark.mainbar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	watermark.mainbar.Position = UDim2.new(0, position and position.X or 10, 0, position and position.Y or 10)
	watermark.mainbar.Size = UDim2.new(0, 0, 0, 24)

	local corner = Instance.new("UICorner", watermark.mainbar)
	corner.CornerRadius = UDim.new(0, 3)

	watermark.Outline = Instance.new("Frame", watermark.mainbar)
	watermark.Outline.ZIndex = 4 ; watermark.Outline.BorderSizePixel = 0
	watermark.Outline.BackgroundColor3 = library.theme.outlinecolor
	watermark.Outline.Position = UDim2.fromOffset(-1, -1)
	watermark.Outline.Size = watermark.mainbar.Size + UDim2.fromOffset(2, 2)
	local c2 = Instance.new("UICorner", watermark.Outline) ; c2.CornerRadius = UDim.new(0, 4)

	watermark.label = Instance.new("TextLabel", watermark.mainbar)
	watermark.label.BackgroundTransparency = 1
	watermark.label.Position = UDim2.new(0, 0, 0, 0)
	watermark.label.Font = Enum.Font.GothamBold
	watermark.label.ZIndex = 6
	watermark.label.Text = watermark.text
	watermark.label.TextColor3 = Color3.fromRGB(255, 255, 255)
	watermark.label.TextSize = 13
	watermark.label.TextStrokeTransparency = 1
	watermark.label.TextXAlignment = Enum.TextXAlignment.Left
	watermark.label.Size = UDim2.new(0, watermark.label.TextBounds.X + 10, 0, 24)

	watermark.topbar = Instance.new("Frame", watermark.mainbar)
	watermark.topbar.ZIndex = 6
	watermark.topbar.BackgroundColor3 = library.theme.accentcolor
	watermark.topbar.BorderSizePixel = 0
	watermark.topbar.Size = UDim2.new(0, 0, 0, 2)

	watermark.mainbar.Size = UDim2.new(0, watermark.label.TextBounds.X + 4, 0, 24)
	watermark.topbar.Size = UDim2.new(0, watermark.label.TextBounds.X + 4, 0, 2)
	watermark.Outline.Size = watermark.mainbar.Size + UDim2.fromOffset(2, 2)

	local startTime, counter, oldfps = os.clock(), 0, nil
	runservice.Heartbeat:Connect(function()
		watermark.label.Visible = watermark.Visible
		watermark.mainbar.Visible = watermark.Visible
		watermark.topbar.Visible = watermark.Visible

		if name:find("{fps}") then
			local currentTime = os.clock()
			counter = counter + 1
			if currentTime - startTime >= 1 then
				local fps = math.floor(counter / (currentTime - startTime))
				counter = 0 ; startTime = currentTime
				if fps ~= oldfps then
					watermark.label.Text = " " .. name:gsub("{game}", gamename):gsub("{fps}", fps .. " FPS") .. " "
					watermark.label.Size = UDim2.new(0, watermark.label.TextBounds.X + 10, 0, 24)
					watermark.mainbar.Size = UDim2.new(0, watermark.label.TextBounds.X, 0, 24)
					watermark.topbar.Size = UDim2.new(0, watermark.label.TextBounds.X, 0, 2)
					watermark.Outline.Size = watermark.mainbar.Size + UDim2.fromOffset(2, 2)
				end
				oldfps = fps
			end
		end
	end)

	watermark.mainbar.MouseEnter:Connect(function()
		tweenservice:Create(watermark.mainbar, TweenInfo.new(0.15), {BackgroundTransparency=1}):Play()
		tweenservice:Create(watermark.label,   TweenInfo.new(0.15), {TextTransparency=1}):Play()
	end)
	watermark.mainbar.MouseLeave:Connect(function()
		tweenservice:Create(watermark.mainbar, TweenInfo.new(0.15), {BackgroundTransparency=0}):Play()
		tweenservice:Create(watermark.label,   TweenInfo.new(0.15), {TextTransparency=0}):Play()
	end)

	function watermark:UpdateTheme(theme)
		theme = theme or library.theme
		watermark.Outline.BackgroundColor3 = theme.outlinecolor
		watermark.label.Font              = theme.font
		watermark.topbar.BackgroundColor3 = theme.accentcolor
	end

	return watermark
end

-- ============================================================
-- WINDOW — style Photon
-- ============================================================
function library:CreateWindow(name, size, hidebutton)
	local window = { }
	window.name      = name or ""
	window.size      = UDim2.fromOffset(size.X, size.Y) or UDim2.fromOffset(900, 560)
	window.hidebutton = hidebutton or Enum.KeyCode.RightShift
	window.hidekey   = window.hidebutton
	window.theme     = library.theme

	local updateevent = Instance.new("BindableEvent")
	function window:UpdateTheme(theme)
		updateevent:Fire(theme or library.theme)
		window.theme = (theme or library.theme)
	end

	window.Main = Instance.new("ScreenGui", coregui)
	window.Main.Name = name
	window.Main.DisplayOrder = 15
	if syn then syn.protect_gui(window.Main) end

	if getgenv().uilib then getgenv().uilib:Remove() end
	getgenv().uilib = window.Main

	-- Drag
	local dragging, dragInput, dragStart, startPos
	uis.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			window.Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	local function dragstart(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true ; dragStart = input.Position ; startPos = window.Frame.Position
			input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
		end
	end
	local function dragend(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end

	-- ── Frame principal
	window.Frame = Instance.new("TextButton", window.Main)
	window.Frame.Name = "main"
	window.Frame.Position = UDim2.fromScale(0.5, 0.5)
	window.Frame.BorderSizePixel = 0
	window.Frame.Size = window.size
	window.Frame.AutoButtonColor = false
	window.Frame.Text = ""
	window.Frame.BackgroundColor3 = window.theme.backgroundcolor
	window.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
	window.Frame.ClipsDescendants = true
	local frameCorner = Instance.new("UICorner", window.Frame)
	frameCorner.CornerRadius = UDim.new(0, 6)
	updateevent.Event:Connect(function(theme) window.Frame.BackgroundColor3 = theme.backgroundcolor end)

	-- Outline
	window.Outline = Instance.new("Frame", window.Frame)
	window.Outline.ZIndex = 0 ; window.Outline.BorderSizePixel = 0
	window.Outline.Size = window.size + UDim2.fromOffset(2, 2)
	window.Outline.BackgroundColor3 = window.theme.outlinecolor
	window.Outline.Position = UDim2.fromOffset(-1, -1)
	local oc = Instance.new("UICorner", window.Outline) ; oc.CornerRadius = UDim.new(0, 7)
	updateevent.Event:Connect(function(theme) window.Outline.BackgroundColor3 = theme.outlinecolor end)

	window.BlackOutline = Instance.new("Frame", window.Frame)
	window.BlackOutline.ZIndex = -1 ; window.BlackOutline.BorderSizePixel = 0
	window.BlackOutline.Size = window.size + UDim2.fromOffset(4, 4)
	window.BlackOutline.BackgroundColor3 = window.theme.outlinecolor2
	window.BlackOutline.Position = UDim2.fromOffset(-2, -2)
	local boc = Instance.new("UICorner", window.BlackOutline) ; boc.CornerRadius = UDim.new(0, 8)
	updateevent.Event:Connect(function(theme) window.BlackOutline.BackgroundColor3 = theme.outlinecolor2 end)

	uis.InputBegan:Connect(function(key)
		if key.KeyCode == window.hidekey then window.Frame.Visible = not window.Frame.Visible end
	end)

	-- ── TopBar (style Photon : fin, nom à gauche, boutons à droite)
	window.TopBar = Instance.new("Frame", window.Frame)
	window.TopBar.Name = "top"
	window.TopBar.Size = UDim2.fromOffset(window.size.X.Offset, window.theme.topheight)
	window.TopBar.BorderSizePixel = 0
	window.TopBar.BackgroundColor3 = window.theme.topcolor
	window.TopBar.ZIndex = 2
	window.TopBar.InputBegan:Connect(dragstart)
	window.TopBar.InputChanged:Connect(dragend)
	updateevent.Event:Connect(function(theme)
		window.TopBar.Size = UDim2.fromOffset(window.size.X.Offset, theme.topheight)
		window.TopBar.BackgroundColor3 = theme.topcolor
	end)

	-- Ligne rouge sous le topbar
	window.TopAccentLine = Instance.new("Frame", window.Frame)
	window.TopAccentLine.Name = "accentline"
	window.TopAccentLine.ZIndex = 3
	window.TopAccentLine.BorderSizePixel = 0
	window.TopAccentLine.BackgroundColor3 = window.theme.accentcolor
	window.TopAccentLine.Size = UDim2.fromOffset(window.size.X.Offset, 2)
	window.TopAccentLine.Position = UDim2.fromOffset(0, window.theme.topheight)
	updateevent.Event:Connect(function(theme)
		window.TopAccentLine.BackgroundColor3 = theme.accentcolor
		window.TopAccentLine.Position = UDim2.fromOffset(0, theme.topheight)
		window.TopAccentLine.Size = UDim2.fromOffset(window.size.X.Offset, 2)
	end)

	-- Nom (style Photon : minuscule, fonte légère)
	window.NameLabel = Instance.new("TextLabel", window.TopBar)
	window.NameLabel.TextColor3 = window.theme.toptextcolor
	window.NameLabel.Text = window.name:lower()
	window.NameLabel.TextXAlignment = Enum.TextXAlignment.Left
	window.NameLabel.Font = Enum.Font.GothamBold
	window.NameLabel.Name = "title"
	window.NameLabel.Position = UDim2.fromOffset(14, 0)
	window.NameLabel.BackgroundTransparency = 1
	window.NameLabel.Size = UDim2.fromOffset(200, window.theme.topheight)
	window.NameLabel.TextSize = 16
	window.NameLabel.ZIndex = 5
	updateevent.Event:Connect(function(theme)
		window.NameLabel.TextColor3 = theme.toptextcolor
		window.NameLabel.TextSize = theme.titlesize + 1
	end)

	-- Bouton Close
	window.CloseBtn = Instance.new("TextButton", window.TopBar)
	window.CloseBtn.Text = "✕"
	window.CloseBtn.Font = Enum.Font.GothamBold
	window.CloseBtn.TextSize = 12
	window.CloseBtn.TextColor3 = Color3.fromRGB(140, 140, 140)
	window.CloseBtn.BackgroundTransparency = 1
	window.CloseBtn.BorderSizePixel = 0
	window.CloseBtn.Size = UDim2.fromOffset(28, 28)
	window.CloseBtn.Position = UDim2.new(1, -32, 0, 5)
	window.CloseBtn.ZIndex = 10
	window.CloseBtn.AutoButtonColor = false

	window.CloseBtn.MouseButton1Down:Connect(function()
		for i, v in pairs(library.items) do
			pcall(function()
				if v.Set and type(v.value) == "boolean" and v.value == true then v:Set(false) end
			end)
		end
		for i, v in pairs(library.flags) do library.flags[i] = nil end
		for i, v in pairs(window.OpenedColorPickers) do
			if v then pcall(function() i.Visible = false ; window.OpenedColorPickers[i] = false end) end
		end
		for _, gui in pairs(coregui:GetChildren()) do
			if gui.Name == "Watermark" or gui.Name == "EchoNotif" then gui:Destroy() end
		end
		window.Main:Destroy()
	end)
	window.CloseBtn.MouseEnter:Connect(function()
		tweenservice:Create(window.CloseBtn, TweenInfo.new(0.1), {TextColor3 = library.theme.accentcolor}):Play()
	end)
	window.CloseBtn.MouseLeave:Connect(function()
		tweenservice:Create(window.CloseBtn, TweenInfo.new(0.1), {TextColor3 = Color3.fromRGB(140,140,140)}):Play()
	end)

	-- Bouton Minimize
	window.MinimizeBtn = Instance.new("TextButton", window.TopBar)
	window.MinimizeBtn.Text = "─"
	window.MinimizeBtn.Font = Enum.Font.GothamBold
	window.MinimizeBtn.TextSize = 12
	window.MinimizeBtn.TextColor3 = Color3.fromRGB(140, 140, 140)
	window.MinimizeBtn.BackgroundTransparency = 1
	window.MinimizeBtn.BorderSizePixel = 0
	window.MinimizeBtn.Size = UDim2.fromOffset(28, 28)
	window.MinimizeBtn.Position = UDim2.new(1, -60, 0, 5)
	window.MinimizeBtn.ZIndex = 10
	window.MinimizeBtn.AutoButtonColor = false

	local minimized = false
	window.MinimizeBtn.MouseButton1Down:Connect(function()
		minimized = not minimized
		if minimized then
			window.Frame:TweenSize(UDim2.fromOffset(window.size.X.Offset, window.theme.topheight + 2), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.15)
		else
			window.Frame:TweenSize(window.size, Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.15)
		end
	end)
	window.MinimizeBtn.MouseEnter:Connect(function()
		tweenservice:Create(window.MinimizeBtn, TweenInfo.new(0.1), {TextColor3 = Color3.fromRGB(255,255,255)}):Play()
	end)
	window.MinimizeBtn.MouseLeave:Connect(function()
		tweenservice:Create(window.MinimizeBtn, TweenInfo.new(0.1), {TextColor3 = Color3.fromRGB(140,140,140)}):Play()
	end)

	-- ── Zone de contenu (entre topbar et tabbar)
	local contentTop = window.theme.topheight + 2
	local tabBarHeight = window.theme.tabbarheight

	window.ContentArea = Instance.new("Frame", window.Frame)
	window.ContentArea.Name = "content"
	window.ContentArea.BackgroundTransparency = 1
	window.ContentArea.BorderSizePixel = 0
	window.ContentArea.Position = UDim2.fromOffset(0, contentTop)
	window.ContentArea.Size = UDim2.fromOffset(window.size.X.Offset, window.size.Y.Offset - contentTop - tabBarHeight)
	window.ContentArea.ZIndex = 2
	window.ContentArea.ClipsDescendants = true

	-- ── Tab bar EN BAS (style Photon)
	window.TabBar = Instance.new("Frame", window.Frame)
	window.TabBar.Name = "tabbar"
	window.TabBar.BackgroundColor3 = window.theme.tabbarcolor
	window.TabBar.BorderSizePixel = 0
	window.TabBar.Size = UDim2.fromOffset(window.size.X.Offset, tabBarHeight)
	window.TabBar.Position = UDim2.fromOffset(0, window.size.Y.Offset - tabBarHeight)
	window.TabBar.ZIndex = 5

	-- Ligne séparatrice au dessus de la tabbar
	window.TabBarLine = Instance.new("Frame", window.Frame)
	window.TabBarLine.BorderSizePixel = 0
	window.TabBarLine.BackgroundColor3 = window.theme.outlinecolor
	window.TabBarLine.Size = UDim2.fromOffset(window.size.X.Offset, 1)
	window.TabBarLine.Position = UDim2.fromOffset(0, window.size.Y.Offset - tabBarHeight - 1)
	window.TabBarLine.ZIndex = 4

	window.TabBarLayout = Instance.new("UIListLayout", window.TabBar)
	window.TabBarLayout.FillDirection = Enum.FillDirection.Horizontal
	window.TabBarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	window.TabBarLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	window.TabBarLayout.SortOrder = Enum.SortOrder.LayoutOrder
	window.TabBarLayout.Padding = UDim.new(0, 0)

	-- Indicateur de tab sélectionné (ligne rouge en haut du bouton tab)
	window.TabIndicator = Instance.new("Frame", window.TabBar)
	window.TabIndicator.Name = "indicator"
	window.TabIndicator.ZIndex = 8
	window.TabIndicator.BorderSizePixel = 0
	window.TabIndicator.BackgroundColor3 = window.theme.accentcolor
	window.TabIndicator.Size = UDim2.fromOffset(60, 2)
	window.TabIndicator.AnchorPoint = Vector2.new(0, 0)
	window.TabIndicator.Position = UDim2.fromOffset(0, 0)
	updateevent.Event:Connect(function(theme) window.TabIndicator.BackgroundColor3 = theme.accentcolor end)

	-- Resize handle
	local minWidth, minHeight = 400, 300
	local resizing = false
	local resizeStart, resizeStartSize = nil, nil

	window.ResizeHandle = Instance.new("TextButton", window.Frame)
	window.ResizeHandle.Text = "" ; window.ResizeHandle.BackgroundTransparency = 1
	window.ResizeHandle.BorderSizePixel = 0
	window.ResizeHandle.Size = UDim2.fromOffset(14, 14)
	window.ResizeHandle.Position = UDim2.new(1, -14, 1, -14)
	window.ResizeHandle.ZIndex = 20 ; window.ResizeHandle.AutoButtonColor = false

	window.ResizeHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			resizing = true
			resizeStart = Vector2.new(input.Position.X, input.Position.Y)
			resizeStartSize = Vector2.new(window.Frame.AbsoluteSize.X, window.Frame.AbsoluteSize.Y)
		end
	end)
	uis.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then resizing = false end
	end)
	uis.InputChanged:Connect(function(input)
		if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = Vector2.new(input.Position.X - resizeStart.X, input.Position.Y - resizeStart.Y)
			local newW = math.max(minWidth,  resizeStartSize.X + delta.X)
			local newH = math.max(minHeight, resizeStartSize.Y + delta.Y)
			window.size = UDim2.fromOffset(newW, newH)
			window.Frame.Size = window.size
			window.Outline.Size = window.size + UDim2.fromOffset(2,2)
			window.BlackOutline.Size = window.size + UDim2.fromOffset(4,4)
			window.TopBar.Size = UDim2.fromOffset(newW, window.theme.topheight)
			window.TopAccentLine.Size = UDim2.fromOffset(newW, 2)
			window.ContentArea.Size = UDim2.fromOffset(newW, newH - contentTop - tabBarHeight)
			window.TabBar.Size = UDim2.fromOffset(newW, tabBarHeight)
			window.TabBar.Position = UDim2.fromOffset(0, newH - tabBarHeight)
			window.TabBarLine.Size = UDim2.fromOffset(newW, 1)
			window.TabBarLine.Position = UDim2.fromOffset(0, newH - tabBarHeight - 1)
			for _, tab in pairs(window.Tabs) do
				tab.Container.Size = UDim2.fromOffset(newW, newH - contentTop - tabBarHeight)
				tab.Left.Size  = UDim2.fromOffset(newW / 2, newH - contentTop - tabBarHeight)
				tab.Right.Size = UDim2.fromOffset(newW / 2, newH - contentTop - tabBarHeight)
				tab.Right.Position = tab.Left.Position + UDim2.fromOffset(newW / 2, 0)
				for _, sector in pairs(tab.SectorsLeft) do
					sector.Main.Size = UDim2.fromOffset(newW / 2 - 20, sector.ListLayout.AbsoluteContentSize.Y + 26)
				end
				for _, sector in pairs(tab.SectorsRight) do
					sector.Main.Size = UDim2.fromOffset(newW / 2 - 20, sector.ListLayout.AbsoluteContentSize.Y + 26)
				end
			end
		end
	end)

	window.OpenedColorPickers = { }
	window.Tabs = { }

	-- ============================================================
	-- CreateTab
	-- ============================================================
	function window:CreateTab(name, icon)
		local tab = { }
		tab.name = name or ""
		tab.icon = icon or ""

		-- Bouton tab (en bas, style Photon : icône + texte)
		local tabBtnW = math.max(70, textservice:GetTextSize(tab.name, 12, Enum.Font.Gotham, Vector2.new(200,300)).X + 30)

		tab.TabButton = Instance.new("TextButton", window.TabBar)
		tab.TabButton.BackgroundTransparency = 1
		tab.TabButton.BorderSizePixel = 0
		tab.TabButton.Size = UDim2.fromOffset(tabBtnW, tabBarHeight)
		tab.TabButton.AutoButtonColor = false
		tab.TabButton.ZIndex = 6
		tab.TabButton.Text = ""
		tab.TabButton.Name = tab.name

		-- Icône (optionnelle, affichée en haut du bouton)
		if tab.icon ~= "" then
			tab.TabIcon = Instance.new("ImageLabel", tab.TabButton)
			tab.TabIcon.BackgroundTransparency = 1
			tab.TabIcon.Size = UDim2.fromOffset(18, 18)
			tab.TabIcon.Position = UDim2.new(0.5, -9, 0, 6)
			tab.TabIcon.Image = tab.icon
			tab.TabIcon.ImageColor3 = Color3.fromRGB(140, 140, 140)
			tab.TabIcon.ZIndex = 7
		end

		tab.TabLabel = Instance.new("TextLabel", tab.TabButton)
		tab.TabLabel.BackgroundTransparency = 1
		tab.TabLabel.Font = Enum.Font.Gotham
		tab.TabLabel.TextSize = 11
		tab.TabLabel.TextColor3 = Color3.fromRGB(130, 130, 130)
		tab.TabLabel.Text = tab.name
		tab.TabLabel.ZIndex = 7
		tab.TabLabel.TextXAlignment = Enum.TextXAlignment.Center
		if tab.icon ~= "" then
			tab.TabLabel.Size = UDim2.fromOffset(tabBtnW, 16)
			tab.TabLabel.Position = UDim2.new(0, 0, 1, -18)
		else
			tab.TabLabel.Size = UDim2.fromOffset(tabBtnW, tabBarHeight)
			tab.TabLabel.Position = UDim2.fromOffset(0, 0)
		end

		-- Container du contenu de cet onglet
		tab.Container = Instance.new("Frame", window.ContentArea)
		tab.Container.BackgroundTransparency = 1
		tab.Container.BorderSizePixel = 0
		tab.Container.Size = window.ContentArea.Size
		tab.Container.Position = UDim2.fromOffset(0, 0)
		tab.Container.Visible = false
		tab.Container.ClipsDescendants = true

		-- Colonnes gauche/droite
		tab.Left = Instance.new("ScrollingFrame", tab.Container)
		tab.Left.Name = "leftside"
		tab.Left.BorderSizePixel = 0
		tab.Left.Size = UDim2.fromOffset(window.ContentArea.AbsoluteSize.X / 2, window.ContentArea.AbsoluteSize.Y)
		tab.Left.BackgroundTransparency = 1
		tab.Left.Visible = true
		tab.Left.ScrollBarThickness = 0
		tab.Left.ScrollingDirection = "Y"
		tab.Left.Position = UDim2.fromOffset(0, 0)

		tab.LeftListLayout = Instance.new("UIListLayout", tab.Left)
		tab.LeftListLayout.FillDirection = Enum.FillDirection.Vertical
		tab.LeftListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		tab.LeftListLayout.Padding = UDim.new(0, 10)

		tab.LeftPadding = Instance.new("UIPadding", tab.Left)
		tab.LeftPadding.PaddingTop   = UDim.new(0, 12)
		tab.LeftPadding.PaddingLeft  = UDim.new(0, 12)
		tab.LeftPadding.PaddingRight = UDim.new(0, 8)

		tab.Right = Instance.new("ScrollingFrame", tab.Container)
		tab.Right.Name = "rightside"
		tab.Right.BorderSizePixel = 0
		tab.Right.ScrollBarThickness = 0
		tab.Right.ScrollingDirection = "Y"
		tab.Right.Visible = true
		tab.Right.Size = UDim2.fromOffset(window.ContentArea.AbsoluteSize.X / 2, window.ContentArea.AbsoluteSize.Y)
		tab.Right.BackgroundTransparency = 1
		tab.Right.Position = tab.Left.Position + UDim2.fromOffset(window.ContentArea.AbsoluteSize.X / 2, 0)

		tab.RightListLayout = Instance.new("UIListLayout", tab.Right)
		tab.RightListLayout.FillDirection = Enum.FillDirection.Vertical
		tab.RightListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		tab.RightListLayout.Padding = UDim.new(0, 10)

		tab.RightPadding = Instance.new("UIPadding", tab.Right)
		tab.RightPadding.PaddingTop   = UDim.new(0, 12)
		tab.RightPadding.PaddingLeft  = UDim.new(0, 8)
		tab.RightPadding.PaddingRight = UDim.new(0, 12)

		tab.SectorsLeft  = { }
		tab.SectorsRight = { }

		local block = false
		function tab:SelectTab()
			repeat wait() until not block
			block = true
			for _, v in pairs(window.Tabs) do
				if v ~= tab then
					v.Container.Visible = false
					v.TabLabel.TextColor3 = Color3.fromRGB(130, 130, 130)
					v.TabLabel.Font = Enum.Font.Gotham
					if v.TabIcon then v.TabIcon.ImageColor3 = Color3.fromRGB(130, 130, 130) end
				end
			end
			tab.Container.Visible = true
			tab.TabLabel.TextColor3 = window.theme.accentcolor
			tab.TabLabel.Font = Enum.Font.GothamBold
			if tab.TabIcon then tab.TabIcon.ImageColor3 = window.theme.accentcolor end

			-- Déplace l'indicateur rouge sous le bouton sélectionné
			local btnPos = tab.TabButton.AbsolutePosition.X - window.TabBar.AbsolutePosition.X
			local btnW   = tab.TabButton.AbsoluteSize.X
			tweenservice:Create(window.TabIndicator, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Position = UDim2.fromOffset(btnPos, 0),
				Size     = UDim2.fromOffset(btnW, 2)
			}):Play()
			wait(0.15)
			block = false
		end

		if #window.Tabs == 0 then tab:SelectTab() end
		tab.TabButton.MouseButton1Down:Connect(function() tab:SelectTab() end)

		-- ============================================================
		-- CreateSector — style Photon (card avec coin arrondi + bord rouge en haut)
		-- ============================================================
		function tab:CreateSector(name, side)
			local sector = { }
			sector.name = name or ""
			sector.side = side:lower() or "left"

			local parentFrame = sector.side == "left" and tab.Left or tab.Right
			local sectorW = (window.ContentArea.AbsoluteSize.X / 2) - 20

			sector.Main = Instance.new("Frame", parentFrame)
			sector.Main.Name = sector.name:gsub(" ", "") .. "Sector"
			sector.Main.BorderSizePixel = 0
			sector.Main.ZIndex = 4
			sector.Main.Size = UDim2.fromOffset(sectorW, 20)
			sector.Main.BackgroundColor3 = window.theme.sectorcolor
			local mc = Instance.new("UICorner", sector.Main) ; mc.CornerRadius = UDim.new(0, 5)
			updateevent.Event:Connect(function(theme) sector.Main.BackgroundColor3 = theme.sectorcolor end)

			-- Outline de la card
			sector.CardOutline = Instance.new("UIStroke", sector.Main)
			sector.CardOutline.Color = Color3.fromRGB(40, 40, 40)
			sector.CardOutline.Thickness = 1
			sector.CardOutline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

			-- Ligne rouge en haut de la card (header)
			sector.TopLine = Instance.new("Frame", sector.Main)
			sector.TopLine.Name = "topline"
			sector.TopLine.ZIndex = 6
			sector.TopLine.BorderSizePixel = 0
			sector.TopLine.BackgroundColor3 = window.theme.accentcolor
			sector.TopLine.Size = UDim2.fromOffset(sectorW, 2)
			sector.TopLine.Position = UDim2.fromOffset(0, 0)
			local tlc = Instance.new("UICorner", sector.TopLine)
			tlc.CornerRadius = UDim.new(0, 5)
			updateevent.Event:Connect(function(theme) sector.TopLine.BackgroundColor3 = theme.accentcolor end)

			-- Header avec le titre de la sector
			sector.Header = Instance.new("Frame", sector.Main)
			sector.Header.Name = "header"
			sector.Header.ZIndex = 5
			sector.Header.BorderSizePixel = 0
			sector.Header.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
			sector.Header.Size = UDim2.fromOffset(sectorW, 22)
			sector.Header.Position = UDim2.fromOffset(0, 0)
			local hc = Instance.new("UICorner", sector.Header) ; hc.CornerRadius = UDim.new(0, 5)

			-- Sous-frame pour cacher les coins du bas de l'header
			local headerFix = Instance.new("Frame", sector.Header)
			headerFix.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
			headerFix.BorderSizePixel = 0
			headerFix.Size = UDim2.fromOffset(sectorW, 11)
			headerFix.Position = UDim2.new(0, 0, 1, -11)
			headerFix.ZIndex = 5

			sector.Label = Instance.new("TextLabel", sector.Header)
			sector.Label.AnchorPoint = Vector2.new(0, 0.5)
			sector.Label.Position = UDim2.new(0, 10, 0.5, 1)
			sector.Label.BackgroundTransparency = 1
			sector.Label.BorderSizePixel = 0
			sector.Label.ZIndex = 6
			sector.Label.Text = sector.name:upper()
			sector.Label.TextColor3 = Color3.fromRGB(255, 255, 255)
			sector.Label.TextStrokeTransparency = 1
			sector.Label.Font = Enum.Font.GothamBold
			sector.Label.TextSize = 11
			sector.Label.Size = UDim2.fromOffset(sectorW - 20, 22)

			sector.Items = Instance.new("Frame", sector.Main)
			sector.Items.Name = "items"
			sector.Items.ZIndex = 5
			sector.Items.BackgroundTransparency = 1
			sector.Items.AutomaticSize = Enum.AutomaticSize.Y
			sector.Items.BorderSizePixel = 0
			sector.Items.Size = UDim2.fromOffset(sectorW, 0)
			sector.Items.Position = UDim2.fromOffset(0, 24)

			sector.ListLayout = Instance.new("UIListLayout", sector.Items)
			sector.ListLayout.FillDirection = Enum.FillDirection.Vertical
			sector.ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			sector.ListLayout.Padding = UDim.new(0, 8)

			sector.ListPadding = Instance.new("UIPadding", sector.Items)
			sector.ListPadding.PaddingTop    = UDim.new(0, 10)
			sector.ListPadding.PaddingLeft   = UDim.new(0, 10)
			sector.ListPadding.PaddingRight  = UDim.new(0, 10)
			sector.ListPadding.PaddingBottom = UDim.new(0, 10)

			table.insert(sector.side == "left" and tab.SectorsLeft or tab.SectorsRight, sector)

			function sector:FixSize()
				sector.Main.Size = UDim2.fromOffset(sectorW, sector.ListLayout.AbsoluteContentSize.Y + 26 + 14)
				sector.TopLine.Size = UDim2.fromOffset(sectorW, 2)
				local sizeleft, sizeright = 0, 0
				for _, v in pairs(tab.SectorsLeft)  do sizeleft  = sizeleft  + v.Main.AbsoluteSize.Y end
				for _, v in pairs(tab.SectorsRight) do sizeright = sizeright + v.Main.AbsoluteSize.Y end
				tab.Left.CanvasSize  = UDim2.fromOffset(0, sizeleft  + (#tab.SectorsLeft  * 22))
				tab.Right.CanvasSize = UDim2.fromOffset(0, sizeright + (#tab.SectorsRight * 22))
			end

			-- ── Helpers internes pour créer les éléments UI Photon-style ──

			local function makeItemContainer(parent, height)
				local f = Instance.new("Frame", parent)
				f.BackgroundTransparency = 1 ; f.BorderSizePixel = 0
				f.ZIndex = 5 ; f.Size = UDim2.fromOffset(sectorW - 20, height)
				return f
			end

			local function makeLabel(parent, text, xAlign, color, size, font, zindex)
				local l = Instance.new("TextLabel", parent)
				l.BackgroundTransparency = 1 ; l.BorderSizePixel = 0
				l.Font = font or Enum.Font.Gotham
				l.Text = text or ""
				l.TextColor3 = color or window.theme.itemscolor
				l.TextSize = size or 12
				l.TextStrokeTransparency = 1
				l.ZIndex = zindex or 6
				l.TextXAlignment = xAlign or Enum.TextXAlignment.Left
				return l
			end

			-- ================================================================
			-- AddLabel
			-- ================================================================
			function sector:AddLabel(text, color, centered)
				local label = { }
				label._color = color

				local container = makeItemContainer(sector.Items, 16)
				label.Main = container

				-- Petite barre accent à gauche
				label.AccentBar = Instance.new("Frame", container)
				label.AccentBar.BackgroundColor3 = window.theme.accentcolor
				label.AccentBar.BorderSizePixel = 0
				label.AccentBar.ZIndex = 6
				label.AccentBar.Size = UDim2.fromOffset(2, 14)
				label.AccentBar.Position = UDim2.fromOffset(0, 1)
				updateevent.Event:Connect(function(theme) label.AccentBar.BackgroundColor3 = theme.accentcolor end)

				label.Text = makeLabel(container, text, centered and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left, color or window.theme.itemscolor, 12)
				label.Text.Position = UDim2.fromOffset(8, 0)
				label.Text.Size = UDim2.fromOffset(sectorW - 28, 16)
				label.Text.TextWrapped = true
				label.Text.AutomaticSize = Enum.AutomaticSize.Y
				updateevent.Event:Connect(function(theme)
					label.Text.Font = theme.font
					if not label._color then label.Text.TextColor3 = theme.itemscolor end
				end)

				function label:Set(value)   label.Text.Text = tostring(value) ; sector:FixSize() end
				function label:Get()        return label.Text.Text end
				function label:SetColor(c)  label._color = c ; label.Text.TextColor3 = c end
				function label:SetVisible(v) label.Main.Visible = v ; sector:FixSize() end

				sector:FixSize() ; return label
			end

			-- ================================================================
			-- AddButton — style Photon (fond sombre, bord gris, hover rouge)
			-- ================================================================
			function sector:AddButton(text, callback)
				local button = { }
				button.text = text or "" ; button.callback = callback or function() end

				local container = makeItemContainer(sector.Items, 26)
				button.Main = Instance.new("TextButton", container)
				button.Main.Name = "button"
				button.Main.BorderSizePixel = 0
				button.Main.Text = ""
				button.Main.AutoButtonColor = false
				button.Main.ZIndex = 6
				button.Main.Size = UDim2.fromOffset(sectorW - 20, 26)
				button.Main.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
				local bc = Instance.new("UICorner", button.Main) ; bc.CornerRadius = UDim.new(0, 4)
				local bstroke = Instance.new("UIStroke", button.Main)
				bstroke.Color = Color3.fromRGB(50, 50, 50) ; bstroke.Thickness = 1

				button.Label = makeLabel(button.Main, button.text, Enum.TextXAlignment.Center, window.theme.itemscolor2, 12, Enum.Font.GothamBold, 7)
				button.Label.Size = UDim2.fromScale(1, 1)
				updateevent.Event:Connect(function(theme)
					button.Label.Font = theme.font
					button.Label.TextColor3 = theme.itemscolor2
				end)

				button.Main.MouseButton1Down:Connect(button.callback)
				button.Main.MouseEnter:Connect(function()
					tweenservice:Create(button.Main, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(45,45,45)}):Play()
					bstroke.Color = window.theme.accentcolor
				end)
				button.Main.MouseLeave:Connect(function()
					tweenservice:Create(button.Main, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(32,32,32)}):Play()
					bstroke.Color = Color3.fromRGB(50, 50, 50)
				end)
				button.Main.MouseButton1Down:Connect(function()
					tweenservice:Create(button.Main, TweenInfo.new(0.05), {BackgroundColor3 = window.theme.accentcolor}):Play()
					task.delay(0.1, function()
						tweenservice:Create(button.Main, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(32,32,32)}):Play()
					end)
				end)

				sector:FixSize() ; return button
			end

			-- ================================================================
			-- AddToggle — style Photon (checkbox carré rouge)
			-- ================================================================
			function sector:AddToggle(text, default, callback, flag)
				local toggle = { }
				toggle.text     = text or ""
				toggle.default  = default or false
				toggle.callback = callback or function() end
				toggle.flag     = flag or text or ""
				toggle.value    = toggle.default

				local container = makeItemContainer(sector.Items, 16)
				toggle.Main = container

				-- Checkbox
				toggle.Box = Instance.new("TextButton", container)
				toggle.Box.Name = "toggle"
				toggle.Box.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
				toggle.Box.BorderSizePixel = 0
				toggle.Box.Size = UDim2.fromOffset(14, 14)
				toggle.Box.Position = UDim2.fromOffset(0, 1)
				toggle.Box.AutoButtonColor = false
				toggle.Box.ZIndex = 6
				toggle.Box.Text = ""
				local boxCorner = Instance.new("UICorner", toggle.Box) ; boxCorner.CornerRadius = UDim.new(0, 3)
				local boxStroke = Instance.new("UIStroke", toggle.Box)
				boxStroke.Color = Color3.fromRGB(60, 60, 60) ; boxStroke.Thickness = 1

				-- Coche intérieure
				toggle.Check = Instance.new("Frame", toggle.Box)
				toggle.Check.BackgroundColor3 = window.theme.accentcolor
				toggle.Check.BorderSizePixel = 0
				toggle.Check.ZIndex = 7
				toggle.Check.Size = UDim2.fromOffset(8, 8)
				toggle.Check.Position = UDim2.fromOffset(3, 3)
				toggle.Check.Visible = false
				local cc = Instance.new("UICorner", toggle.Check) ; cc.CornerRadius = UDim.new(0, 2)
				updateevent.Event:Connect(function(theme) toggle.Check.BackgroundColor3 = theme.accentcolor end)

				toggle.Label = Instance.new("TextButton", container)
				toggle.Label.AutoButtonColor = false
				toggle.Label.BackgroundTransparency = 1
				toggle.Label.Position = UDim2.fromOffset(22, 0)
				toggle.Label.Size = UDim2.fromOffset(sectorW - 80, 16)
				toggle.Label.Font = Enum.Font.Gotham
				toggle.Label.ZIndex = 6
				toggle.Label.Text = toggle.text
				toggle.Label.TextColor3 = window.theme.itemscolor
				toggle.Label.TextSize = 12
				toggle.Label.TextStrokeTransparency = 1
				toggle.Label.TextXAlignment = Enum.TextXAlignment.Left
				updateevent.Event:Connect(function(theme)
					toggle.Label.TextColor3 = toggle.value and theme.itemscolor2 or theme.itemscolor
					toggle.Label.Font = theme.font
				end)

				toggle.Items = Instance.new("Frame", container)
				toggle.Items.Name = "items"
				toggle.Items.ZIndex = 5
				toggle.Items.Size = UDim2.fromOffset(60, 16)
				toggle.Items.BackgroundTransparency = 1
				toggle.Items.BorderSizePixel = 0
				toggle.Items.Position = UDim2.fromOffset(sectorW - 20 - 60, 0)

				toggle.ListLayout = Instance.new("UIListLayout", toggle.Items)
				toggle.ListLayout.FillDirection = Enum.FillDirection.Horizontal
				toggle.ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
				toggle.ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
				toggle.ListLayout.Padding = UDim.new(0, 4)

				if toggle.flag and toggle.flag ~= "" then library.flags[toggle.flag] = toggle.default end

				function toggle:Set(value)
					toggle.value = value
					toggle.Check.Visible = value
					if value then
						boxStroke.Color = window.theme.accentcolor
					else
						boxStroke.Color = Color3.fromRGB(60, 60, 60)
					end
					toggle.Label.TextColor3 = value and window.theme.itemscolor2 or window.theme.itemscolor
					if toggle.flag and toggle.flag ~= "" then library.flags[toggle.flag] = value end
					pcall(toggle.callback, value)
				end
				function toggle:Get() return toggle.value end
				toggle:Set(toggle.default)

				local function clickToggle()
					toggle:Set(not toggle.value)
				end
				toggle.Box.MouseButton1Down:Connect(clickToggle)
				toggle.Label.InputBegan:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 then clickToggle() end
				end)

				-- ── toggle:AddKeybind ──
				function toggle:AddKeybind(default, flag)
					local keybind = { }
					keybind.default = default or "None" ; keybind.value = keybind.default
					keybind.flag    = flag or ((toggle.text or "") .. tostring(#toggle.Items:GetChildren()))

					local displayText = keybindToText(keybind.default)
					keybind.Main = Instance.new("TextButton", toggle.Items)
					keybind.Main.BackgroundTransparency = 1 ; keybind.Main.BorderSizePixel = 0
					keybind.Main.ZIndex = 6
					keybind.Main.Text = displayText
					keybind.Main.Font = Enum.Font.Gotham
					keybind.Main.TextColor3 = Color3.fromRGB(100, 100, 100)
					keybind.Main.TextSize = 11
					keybind.Main.TextXAlignment = Enum.TextXAlignment.Right
					keybind.Main.Size = UDim2.fromOffset(54, 16)
					keybind.Main.MouseButton1Down:Connect(function()
						keybind.Main.Text = "[...]"
						keybind.Main.TextColor3 = window.theme.accentcolor
					end)

					if keybind.flag and keybind.flag ~= "" then library.flags[keybind.flag] = keybind.default end
					function keybind:Set(value)
						keybind.value = value ; keybind.Main.Text = keybindToText(value)
						if keybind.flag and keybind.flag ~= "" then library.flags[keybind.flag] = value end
					end
					function keybind:Get() return keybind.value end

					uis.InputBegan:Connect(function(input, gp)
						if not gp then
							if keybind.Main.Text == "[...]" then
								keybind.Main.TextColor3 = Color3.fromRGB(100,100,100)
								keybind:Set(inputToKeybindValue(input))
							else
								if inputMatchesKeybind(input, keybind.value) then toggle:Set(not toggle.value) end
							end
						end
					end)
					table.insert(library.items, keybind) ; return keybind
				end

				-- ── toggle:AddColorpicker (inline, style Photon : petit carré de couleur) ──
				function toggle:AddColorpicker(default, callback, flag)
					local cp = { }
					cp.callback = callback or function() end
					cp.default  = default or Color3.fromRGB(255, 255, 255)
					cp.value    = cp.default
					cp.flag     = flag or ((toggle.text or "") .. tostring(#toggle.Items:GetChildren()))

					cp.Swatch = Instance.new("TextButton", toggle.Items)
					cp.Swatch.BorderSizePixel = 0
					cp.Swatch.BackgroundColor3 = cp.default
					cp.Swatch.ZIndex = 6
					cp.Swatch.Size = UDim2.fromOffset(14, 14)
					cp.Swatch.Position = UDim2.fromOffset(0, 1)
					cp.Swatch.Text = ""
					cp.Swatch.AutoButtonColor = false
					local sc = Instance.new("UICorner", cp.Swatch) ; sc.CornerRadius = UDim.new(0, 3)
					local ss = Instance.new("UIStroke", cp.Swatch) ; ss.Color = Color3.fromRGB(60,60,60) ; ss.Thickness = 1

					-- Picker popup
					cp.Picker = Instance.new("TextButton", cp.Swatch)
					cp.Picker.Name = "picker" ; cp.Picker.ZIndex = 100
					cp.Picker.Visible = false ; cp.Picker.AutoButtonColor = false
					cp.Picker.Text = "" ; cp.Picker.Size = UDim2.fromOffset(180, 196)
					cp.Picker.BorderSizePixel = 0
					cp.Picker.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
					cp.Picker.Position = UDim2.fromOffset(-180 + 14, 18)
					local pc = Instance.new("UICorner", cp.Picker) ; pc.CornerRadius = UDim.new(0, 5)
					local ps = Instance.new("UIStroke", cp.Picker) ; ps.Color = Color3.fromRGB(50,50,50) ; ps.Thickness = 1
					window.OpenedColorPickers[cp.Picker] = false

					cp.hue = Instance.new("ImageLabel", cp.Picker)
					cp.hue.ZIndex = 101 ; cp.hue.Position = UDim2.new(0,5,0,5)
					cp.hue.Size = UDim2.new(0,170,0,170)
					cp.hue.Image = "rbxassetid://4155801252"
					cp.hue.ScaleType = Enum.ScaleType.Stretch
					cp.hue.BackgroundColor3 = Color3.new(1,0,0)
					cp.hue.BorderSizePixel = 0

					cp.hueselectorpointer = Instance.new("ImageLabel", cp.Picker)
					cp.hueselectorpointer.ZIndex = 102 ; cp.hueselectorpointer.BackgroundTransparency = 1
					cp.hueselectorpointer.BorderSizePixel = 0 ; cp.hueselectorpointer.Size = UDim2.fromOffset(7,7)
					cp.hueselectorpointer.Image = "rbxassetid://6885856475"

					cp.selector = Instance.new("TextLabel", cp.Picker)
					cp.selector.ZIndex = 100 ; cp.selector.Position = UDim2.new(0,5,0,181)
					cp.selector.Size = UDim2.new(0,170,0,10)
					cp.selector.BackgroundColor3 = Color3.fromRGB(255,255,255)
					cp.selector.BorderSizePixel = 0 ; cp.selector.Text = ""
					local sc2 = Instance.new("UICorner", cp.selector) ; sc2.CornerRadius = UDim.new(0, 2)

					cp.gradient = Instance.new("UIGradient", cp.selector)
					cp.gradient.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0,    Color3.new(1,0,0)),
						ColorSequenceKeypoint.new(0.17, Color3.new(1,0,1)),
						ColorSequenceKeypoint.new(0.33, Color3.new(0,0,1)),
						ColorSequenceKeypoint.new(0.5,  Color3.new(0,1,1)),
						ColorSequenceKeypoint.new(0.67, Color3.new(0,1,0)),
						ColorSequenceKeypoint.new(0.83, Color3.new(1,1,0)),
						ColorSequenceKeypoint.new(1,    Color3.new(1,0,0))
					})

					cp.pointer = Instance.new("Frame", cp.selector)
					cp.pointer.ZIndex = 101 ; cp.pointer.BackgroundColor3 = Color3.fromRGB(255,255,255)
					cp.pointer.Position = UDim2.new(0,0,0,0) ; cp.pointer.Size = UDim2.new(0,2,0,10)
					cp.pointer.BorderSizePixel = 0

					if cp.flag and cp.flag ~= "" then library.flags[cp.flag] = cp.default end

					function cp:RefreshHue()
						local x = (mouse.X - cp.hue.AbsolutePosition.X) / cp.hue.AbsoluteSize.X
						local y = (mouse.Y - cp.hue.AbsolutePosition.Y) / cp.hue.AbsoluteSize.Y
						cp.hueselectorpointer:TweenPosition(UDim2.new(math.clamp(x,0,0.95),0,math.clamp(y,0,0.88),0),Enum.EasingDirection.In,Enum.EasingStyle.Sine,0.05)
						cp:Set(Color3.fromHSV(cp.color or 0, math.clamp(x,0,1), 1 - math.clamp(y,0,1)))
					end
					function cp:RefreshSelector()
						local pos = math.clamp((mouse.X - cp.selector.AbsolutePosition.X) / cp.selector.AbsoluteSize.X, 0, 1)
						cp.color = 1 - pos
						cp.pointer:TweenPosition(UDim2.new(pos,0,0,0),Enum.EasingDirection.In,Enum.EasingStyle.Sine,0.05)
						cp.hue.BackgroundColor3 = Color3.fromHSV(1-pos,1,1)
					end
					function cp:Set(value)
						local color = Color3.new(math.clamp(value.r,0,1),math.clamp(value.g,0,1),math.clamp(value.b,0,1))
						cp.value = color
						cp.Swatch.BackgroundColor3 = color
						if cp.flag and cp.flag ~= "" then library.flags[cp.flag] = color end
						pcall(cp.callback, color)
					end
					function cp:Get() return cp.value end
					cp:Set(cp.default)

					local dh, ds = false, false
					cp.selector.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then ds=true;cp:RefreshSelector() end end)
					cp.selector.InputEnded:Connect(function(i)  if i.UserInputType==Enum.UserInputType.MouseButton1 then ds=false end end)
					cp.hue.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dh=true;cp:RefreshHue() end end)
					cp.hue.InputEnded:Connect(function(i)  if i.UserInputType==Enum.UserInputType.MouseButton1 then dh=false end end)
					uis.InputChanged:Connect(function(i)
						if ds and i.UserInputType==Enum.UserInputType.MouseMovement then cp:RefreshSelector() end
						if dh and i.UserInputType==Enum.UserInputType.MouseMovement then cp:RefreshHue() end
					end)

					local function openPicker(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 then
							for i,v in pairs(window.OpenedColorPickers) do
								if v and i ~= cp.Picker then i.Visible=false;window.OpenedColorPickers[i]=false end
							end
							cp.Picker.Visible = not cp.Picker.Visible
							window.OpenedColorPickers[cp.Picker] = cp.Picker.Visible
							ss.Color = cp.Picker.Visible and window.theme.accentcolor or Color3.fromRGB(60,60,60)
						end
					end
					cp.Swatch.InputBegan:Connect(openPicker)
					table.insert(library.items, cp) ; return cp
				end

				-- ── toggle:AddSlider ──
				function toggle:AddSlider(min, default, max, decimals, callback, flag)
					local slider = { }
					slider.callback = callback or function() end
					slider.min = min or 0 ; slider.max = max or 100
					slider.decimals = decimals or 1 ; slider.default = default or min or 0
					slider.flag = flag or ((toggle.text or "") .. tostring(#toggle.Items:GetChildren()))
					slider.value = slider.default
					local dragging = false

					slider.Main = Instance.new("TextButton", sector.Items)
					slider.Main.Name = "slider" ; slider.Main.BackgroundColor3 = Color3.fromRGB(28,28,28)
					slider.Main.BorderSizePixel = 0 ; slider.Main.AutoButtonColor = false
					slider.Main.Text = "" ; slider.Main.ZIndex = 6
					slider.Main.Size = UDim2.fromOffset(sectorW-20, 16)
					local slc = Instance.new("UICorner", slider.Main) ; slc.CornerRadius = UDim.new(0,3)

					slider.Fill = Instance.new("Frame", slider.Main)
					slider.Fill.BackgroundColor3 = window.theme.accentcolor
					slider.Fill.BorderSizePixel = 0 ; slider.Fill.ZIndex = 7
					slider.Fill.Size = UDim2.fromOffset(0, 16)
					local sfc = Instance.new("UICorner", slider.Fill) ; sfc.CornerRadius = UDim.new(0,3)
					updateevent.Event:Connect(function(theme) slider.Fill.BackgroundColor3 = theme.accentcolor end)

					slider.InputLabel = makeLabel(slider.Main, "0", Enum.TextXAlignment.Center, Color3.fromRGB(220,220,220), 11, Enum.Font.GothamBold, 8)
					slider.InputLabel.Size = UDim2.fromScale(1,1) ; slider.InputLabel.Selectable = false

					if slider.flag and slider.flag ~= "" then library.flags[slider.flag] = slider.default end
					function slider:Set(value)
						slider.value = math.clamp(math.round(value * slider.decimals) / slider.decimals, slider.min, slider.max)
						local pct = (slider.value - slider.min) / (slider.max - slider.min)
						slider.Fill:TweenSize(UDim2.fromOffset(pct * slider.Main.AbsoluteSize.X, 16), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.05)
						slider.InputLabel.Text = slider.value
						if slider.flag and slider.flag ~= "" then library.flags[slider.flag] = slider.value end
						pcall(slider.callback, slider.value)
					end
					function slider:Get() return slider.value end
					slider:Set(slider.default)

					local function refresh()
						local pct = math.clamp((mouse.X - slider.Main.AbsolutePosition.X) / slider.Main.AbsoluteSize.X, 0, 1)
						slider:Set(slider.min + (slider.max - slider.min) * pct)
					end
					slider.Main.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true;refresh() end end)
					slider.Main.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
					uis.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then refresh() end end)

					sector:FixSize() ; table.insert(library.items, slider) ; return slider
				end

				-- ── toggle:AddDropdown ──
				function toggle:AddDropdown(items, default, multichoice, callback, flag)
					-- Réutilise sector:AddDropdown mais sans label séparé
					local dd = sector:AddDropdown(toggle.text, items, default, multichoice, callback, flag)
					return dd
				end

				sector:FixSize() ; table.insert(library.items, toggle) ; return toggle
			end

			-- ================================================================
			-- AddSlider (sector level) — Photon style
			-- ================================================================
			function sector:AddSlider(text, min, default, max, decimals, callback, flag)
				local slider = { }
				slider.text = text or "" ; slider.callback = callback or function() end
				slider.min = min or 0 ; slider.max = max or 100
				slider.decimals = decimals or 1 ; slider.default = default or min or 0
				slider.flag = flag or text or "" ; slider.value = slider.default
				local dragging = false

				local container = makeItemContainer(sector.Items, 32)
				slider.MainBack = container

				slider.LabelRow = Instance.new("Frame", container)
				slider.LabelRow.BackgroundTransparency = 1 ; slider.LabelRow.BorderSizePixel = 0
				slider.LabelRow.ZIndex = 5
				slider.LabelRow.Size = UDim2.fromOffset(sectorW - 20, 14)
				slider.LabelRow.Position = UDim2.fromOffset(0, 0)

				slider.Label = makeLabel(slider.LabelRow, slider.text, Enum.TextXAlignment.Left, window.theme.itemscolor, 12, Enum.Font.Gotham)
				slider.Label.Size = UDim2.fromScale(0.7, 1) ; slider.Label.Position = UDim2.fromOffset(0, 0)

				slider.ValLabel = makeLabel(slider.LabelRow, tostring(slider.default), Enum.TextXAlignment.Right, window.theme.accentcolor, 12, Enum.Font.GothamBold)
				slider.ValLabel.Size = UDim2.fromScale(1, 1) ; slider.ValLabel.Position = UDim2.fromOffset(0, 0)
				updateevent.Event:Connect(function(theme) slider.ValLabel.TextColor3 = theme.accentcolor end)

				slider.Main = Instance.new("TextButton", container)
				slider.Main.Name = "slider" ; slider.Main.BackgroundColor3 = Color3.fromRGB(28,28,28)
				slider.Main.BorderSizePixel = 0 ; slider.Main.AutoButtonColor = false
				slider.Main.Text = "" ; slider.Main.ZIndex = 6
				slider.Main.Size = UDim2.fromOffset(sectorW - 20, 6)
				slider.Main.Position = UDim2.fromOffset(0, 18)
				local slc = Instance.new("UICorner", slider.Main) ; slc.CornerRadius = UDim.new(0, 3)

				slider.Fill = Instance.new("Frame", slider.Main)
				slider.Fill.BackgroundColor3 = window.theme.accentcolor
				slider.Fill.BorderSizePixel = 0 ; slider.Fill.ZIndex = 7
				slider.Fill.Size = UDim2.fromOffset(0, 6)
				local sfc = Instance.new("UICorner", slider.Fill) ; sfc.CornerRadius = UDim.new(0, 3)
				updateevent.Event:Connect(function(theme) slider.Fill.BackgroundColor3 = theme.accentcolor end)

				-- Thumb
				slider.Thumb = Instance.new("Frame", slider.Main)
				slider.Thumb.BackgroundColor3 = Color3.fromRGB(220,220,220)
				slider.Thumb.BorderSizePixel = 0 ; slider.Thumb.ZIndex = 8
				slider.Thumb.Size = UDim2.fromOffset(8, 8)
				slider.Thumb.Position = UDim2.fromOffset(-4, -1)
				local tc = Instance.new("UICorner", slider.Thumb) ; tc.CornerRadius = UDim.new(1, 0)

				if slider.flag and slider.flag ~= "" then library.flags[slider.flag] = slider.default end

				function slider:Set(value)
					slider.value = math.clamp(math.round(value * slider.decimals) / slider.decimals, slider.min, slider.max)
					local pct = (slider.value - slider.min) / (slider.max - slider.min)
					local px = pct * slider.Main.AbsoluteSize.X
					slider.Fill:TweenSize(UDim2.fromOffset(px, 6), Enum.EasingDirection.In, Enum.EasingStyle.Linear, 0.04)
					slider.Thumb:TweenPosition(UDim2.fromOffset(px - 4, -1), Enum.EasingDirection.In, Enum.EasingStyle.Linear, 0.04)
					slider.ValLabel.Text = slider.value
					if slider.flag and slider.flag ~= "" then library.flags[slider.flag] = slider.value end
					pcall(slider.callback, slider.value)
				end
				function slider:Get() return slider.value end
				slider:Set(slider.default)

				local function refresh()
					local pct = math.clamp((mouse.X - slider.Main.AbsolutePosition.X) / slider.Main.AbsoluteSize.X, 0, 1)
					slider:Set(slider.min + (slider.max - slider.min) * pct)
				end
				slider.Main.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true;refresh() end end)
				slider.Main.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
				uis.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then refresh() end end)

				sector:FixSize() ; table.insert(library.items, slider) ; return slider
			end

			-- ================================================================
			-- AddColorpicker (sector level)
			-- ================================================================
			function sector:AddColorpicker(text, default, callback, flag)
				local cp = { }
				cp.text = text or "" ; cp.callback = callback or function() end
				cp.default = default or Color3.fromRGB(255,255,255)
				cp.value = cp.default ; cp.flag = flag or text or ""

				local container = makeItemContainer(sector.Items, 16)
				cp.Main = container

				cp.Label = makeLabel(container, cp.text, Enum.TextXAlignment.Left, window.theme.itemscolor, 12, Enum.Font.Gotham)
				cp.Label.Size = UDim2.fromOffset(sectorW - 50, 16)
				updateevent.Event:Connect(function(theme) cp.Label.TextColor3 = theme.itemscolor ; cp.Label.Font = theme.font end)

				cp.Swatch = Instance.new("TextButton", container)
				cp.Swatch.BorderSizePixel = 0 ; cp.Swatch.BackgroundColor3 = cp.default
				cp.Swatch.ZIndex = 6 ; cp.Swatch.Size = UDim2.fromOffset(28, 14)
				cp.Swatch.Position = UDim2.fromOffset(sectorW - 20 - 28, 1)
				cp.Swatch.Text = "" ; cp.Swatch.AutoButtonColor = false
				local sc = Instance.new("UICorner", cp.Swatch) ; sc.CornerRadius = UDim.new(0, 3)
				local ss = Instance.new("UIStroke", cp.Swatch) ; ss.Color = Color3.fromRGB(60,60,60) ; ss.Thickness = 1

				cp.Picker = Instance.new("TextButton", cp.Swatch)
				cp.Picker.Name = "picker" ; cp.Picker.ZIndex = 100
				cp.Picker.Visible = false ; cp.Picker.AutoButtonColor = false
				cp.Picker.Text = "" ; cp.Picker.Size = UDim2.fromOffset(180, 196)
				cp.Picker.BorderSizePixel = 0 ; cp.Picker.BackgroundColor3 = Color3.fromRGB(30,30,30)
				cp.Picker.Position = UDim2.fromOffset(-180 + 28, 18)
				local pc = Instance.new("UICorner", cp.Picker) ; pc.CornerRadius = UDim.new(0, 5)
				local ps = Instance.new("UIStroke", cp.Picker) ; ps.Color = Color3.fromRGB(50,50,50) ; ps.Thickness = 1
				window.OpenedColorPickers[cp.Picker] = false

				cp.hue = Instance.new("ImageLabel", cp.Picker)
				cp.hue.ZIndex = 101 ; cp.hue.Position = UDim2.new(0,5,0,5)
				cp.hue.Size = UDim2.new(0,170,0,170)
				cp.hue.Image = "rbxassetid://4155801252"
				cp.hue.ScaleType = Enum.ScaleType.Stretch
				cp.hue.BackgroundColor3 = Color3.new(1,0,0) ; cp.hue.BorderSizePixel = 0

				cp.hueselectorpointer = Instance.new("ImageLabel", cp.Picker)
				cp.hueselectorpointer.ZIndex = 102 ; cp.hueselectorpointer.BackgroundTransparency = 1
				cp.hueselectorpointer.BorderSizePixel = 0 ; cp.hueselectorpointer.Size = UDim2.fromOffset(7,7)
				cp.hueselectorpointer.Image = "rbxassetid://6885856475"

				cp.selector = Instance.new("TextLabel", cp.Picker)
				cp.selector.ZIndex = 100 ; cp.selector.Position = UDim2.new(0,5,0,181)
				cp.selector.Size = UDim2.new(0,170,0,10)
				cp.selector.BackgroundColor3 = Color3.fromRGB(255,255,255)
				cp.selector.BorderSizePixel = 0 ; cp.selector.Text = ""
				local sc2 = Instance.new("UICorner", cp.selector) ; sc2.CornerRadius = UDim.new(0,2)

				cp.gradient = Instance.new("UIGradient", cp.selector)
				cp.gradient.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.new(1,0,0)), ColorSequenceKeypoint.new(0.17, Color3.new(1,0,1)),
					ColorSequenceKeypoint.new(0.33, Color3.new(0,0,1)), ColorSequenceKeypoint.new(0.5, Color3.new(0,1,1)),
					ColorSequenceKeypoint.new(0.67, Color3.new(0,1,0)), ColorSequenceKeypoint.new(0.83, Color3.new(1,1,0)),
					ColorSequenceKeypoint.new(1, Color3.new(1,0,0))
				})

				cp.pointer = Instance.new("Frame", cp.selector)
				cp.pointer.ZIndex = 101 ; cp.pointer.BackgroundColor3 = Color3.fromRGB(255,255,255)
				cp.pointer.Position = UDim2.new(0,0,0,0) ; cp.pointer.Size = UDim2.new(0,2,0,10)
				cp.pointer.BorderSizePixel = 0

				if cp.flag and cp.flag ~= "" then library.flags[cp.flag] = cp.default end

				function cp:RefreshHue()
					local x = (mouse.X - cp.hue.AbsolutePosition.X) / cp.hue.AbsoluteSize.X
					local y = (mouse.Y - cp.hue.AbsolutePosition.Y) / cp.hue.AbsoluteSize.Y
					cp.hueselectorpointer:TweenPosition(UDim2.new(math.clamp(x,0,0.95),0,math.clamp(y,0,0.88),0),Enum.EasingDirection.In,Enum.EasingStyle.Sine,0.05)
					cp:Set(Color3.fromHSV(cp.color or 0, math.clamp(x,0,1), 1 - math.clamp(y,0,1)))
				end
				function cp:RefreshSelector()
					local pos = math.clamp((mouse.X - cp.selector.AbsolutePosition.X) / cp.selector.AbsoluteSize.X, 0, 1)
					cp.color = 1 - pos
					cp.pointer:TweenPosition(UDim2.new(pos,0,0,0),Enum.EasingDirection.In,Enum.EasingStyle.Sine,0.05)
					cp.hue.BackgroundColor3 = Color3.fromHSV(1-pos,1,1)
				end
				function cp:Set(value)
					local color = Color3.new(math.clamp(value.r,0,1),math.clamp(value.g,0,1),math.clamp(value.b,0,1))
					cp.value = color ; cp.Swatch.BackgroundColor3 = color
					if cp.flag and cp.flag ~= "" then library.flags[cp.flag] = color end
					pcall(cp.callback, color)
				end
				function cp:Get() return cp.value end
				cp:Set(cp.default)

				local dh, ds = false, false
				cp.selector.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then ds=true;cp:RefreshSelector() end end)
				cp.selector.InputEnded:Connect(function(i)  if i.UserInputType==Enum.UserInputType.MouseButton1 then ds=false end end)
				cp.hue.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dh=true;cp:RefreshHue() end end)
				cp.hue.InputEnded:Connect(function(i)  if i.UserInputType==Enum.UserInputType.MouseButton1 then dh=false end end)
				uis.InputChanged:Connect(function(i)
					if ds and i.UserInputType==Enum.UserInputType.MouseMovement then cp:RefreshSelector() end
					if dh and i.UserInputType==Enum.UserInputType.MouseMovement then cp:RefreshHue() end
				end)
				local function openPicker(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						for i,v in pairs(window.OpenedColorPickers) do
							if v and i ~= cp.Picker then i.Visible=false;window.OpenedColorPickers[i]=false end
						end
						cp.Picker.Visible = not cp.Picker.Visible
						window.OpenedColorPickers[cp.Picker] = cp.Picker.Visible
						ss.Color = cp.Picker.Visible and window.theme.accentcolor or Color3.fromRGB(60,60,60)
					end
				end
				cp.Swatch.InputBegan:Connect(openPicker)
				sector:FixSize() ; table.insert(library.items, cp) ; return cp
			end

			-- ================================================================
			-- AddKeybind (sector level)
			-- ================================================================
			function sector:AddKeybind(text, default, newkeycallback, callback, flag)
				local keybind = { }
				keybind.text = text or "" ; keybind.default = default or "None"
				keybind.callback = callback or function() end
				keybind.newkeycallback = newkeycallback or function() end
				keybind.flag = flag or text or "" ; keybind.value = keybind.default

				local container = makeItemContainer(sector.Items, 16)
				keybind.Main = container

				keybind.Label = makeLabel(container, keybind.text, Enum.TextXAlignment.Left, window.theme.itemscolor, 12, Enum.Font.Gotham)
				keybind.Label.Size = UDim2.fromOffset(sectorW - 80, 16)
				updateevent.Event:Connect(function(theme) keybind.Label.TextColor3 = theme.itemscolor ; keybind.Label.Font = theme.font end)

				keybind.Bind = Instance.new("TextButton", container)
				keybind.Bind.BackgroundColor3 = Color3.fromRGB(28,28,28)
				keybind.Bind.BorderSizePixel = 0 ; keybind.Bind.ZIndex = 6
				keybind.Bind.Font = Enum.Font.GothamBold ; keybind.Bind.TextColor3 = Color3.fromRGB(180,180,180)
				keybind.Bind.TextSize = 11
				keybind.Bind.Text = keybindToText(keybind.default)
				keybind.Bind.AutoButtonColor = false
				keybind.Bind.Size = UDim2.fromOffset(60, 16)
				keybind.Bind.Position = UDim2.fromOffset(sectorW - 20 - 60, 0)
				local kbc = Instance.new("UICorner", keybind.Bind) ; kbc.CornerRadius = UDim.new(0,3)
				local kbs = Instance.new("UIStroke", keybind.Bind) ; kbs.Color = Color3.fromRGB(50,50,50) ; kbs.Thickness = 1

				keybind.Bind.MouseButton1Down:Connect(function()
					keybind.Bind.Text = "[...]"
					keybind.Bind.TextColor3 = window.theme.accentcolor
				end)

				if keybind.flag and keybind.flag ~= "" then library.flags[keybind.flag] = keybind.default end
				function keybind:Set(value)
					keybind.value = value ; keybind.Bind.Text = keybindToText(value)
					keybind.Bind.TextColor3 = Color3.fromRGB(180,180,180)
					if keybind.flag and keybind.flag ~= "" then library.flags[keybind.flag] = value end
					pcall(keybind.newkeycallback, value)
				end
				function keybind:Get() return keybind.value end
				keybind:Set(keybind.default)

				uis.InputBegan:Connect(function(input, gp)
					if not gp then
						if keybind.Bind.Text == "[...]" then
							keybind:Set(inputToKeybindValue(input))
						else
							if inputMatchesKeybind(input, keybind.value) then pcall(keybind.callback) end
						end
					end
				end)
				sector:FixSize() ; table.insert(library.items, keybind) ; return keybind
			end

			-- ================================================================
			-- AddDropdown (sector level) — Photon style
			-- ================================================================
			function sector:AddDropdown(text, items, default, multichoice, callback, flag)
				local dropdown = { }
				dropdown.text = text or "" ; dropdown.defaultitems = items or {}
				dropdown.default = default ; dropdown.callback = callback or function() end
				dropdown.multichoice = multichoice or false ; dropdown.values = {}
				dropdown.flag = flag or text or ""

				local container = makeItemContainer(sector.Items, 32)
				dropdown.MainBack = container

				dropdown.Label = makeLabel(container, dropdown.text, Enum.TextXAlignment.Left, window.theme.itemscolor, 12, Enum.Font.Gotham)
				dropdown.Label.Size = UDim2.fromOffset(sectorW - 20, 14)
				dropdown.Label.Position = UDim2.fromOffset(0, 0)
				updateevent.Event:Connect(function(theme) dropdown.Label.TextColor3 = theme.itemscolor ; dropdown.Label.Font = theme.font end)

				dropdown.Main = Instance.new("TextButton", container)
				dropdown.Main.BackgroundColor3 = Color3.fromRGB(28,28,28)
				dropdown.Main.BorderSizePixel = 0 ; dropdown.Main.AutoButtonColor = false
				dropdown.Main.Text = "" ; dropdown.Main.ZIndex = 6
				dropdown.Main.Size = UDim2.fromOffset(sectorW - 20, 18)
				dropdown.Main.Position = UDim2.fromOffset(0, 16)
				local ddc = Instance.new("UICorner", dropdown.Main) ; ddc.CornerRadius = UDim.new(0, 4)
				local dds = Instance.new("UIStroke", dropdown.Main) ; dds.Color = Color3.fromRGB(50,50,50) ; dds.Thickness = 1

				dropdown.SelectedLabel = makeLabel(dropdown.Main, dropdown.text, Enum.TextXAlignment.Left, Color3.fromRGB(180,180,180), 11, Enum.Font.Gotham, 7)
				dropdown.SelectedLabel.Size = UDim2.fromOffset(sectorW - 55, 18)
				dropdown.SelectedLabel.Position = UDim2.fromOffset(8, 0)

				dropdown.Arrow = Instance.new("TextLabel", dropdown.Main)
				dropdown.Arrow.BackgroundTransparency = 1 ; dropdown.Arrow.BorderSizePixel = 0
				dropdown.Arrow.ZIndex = 7 ; dropdown.Arrow.Text = "▾"
				dropdown.Arrow.Font = Enum.Font.GothamBold ; dropdown.Arrow.TextSize = 12
				dropdown.Arrow.TextColor3 = Color3.fromRGB(140,140,140)
				dropdown.Arrow.Size = UDim2.fromOffset(16, 18)
				dropdown.Arrow.Position = UDim2.new(1, -20, 0, 0)
				dropdown.Arrow.TextXAlignment = Enum.TextXAlignment.Center

				dropdown.ItemsFrame = Instance.new("ScrollingFrame", dropdown.Main)
				dropdown.ItemsFrame.BackgroundColor3 = Color3.fromRGB(24,24,24)
				dropdown.ItemsFrame.BorderSizePixel = 0 ; dropdown.ItemsFrame.ZIndex = 12
				dropdown.ItemsFrame.ScrollBarThickness = 2
				dropdown.ItemsFrame.ScrollingDirection = "Y"
				dropdown.ItemsFrame.Visible = false
				dropdown.ItemsFrame.Position = UDim2.fromOffset(0, 22)
				dropdown.ItemsFrame.Size = UDim2.fromOffset(0, 0)
				dropdown.ItemsFrame.CanvasSize = UDim2.fromOffset(0, 0)
				local dfc = Instance.new("UICorner", dropdown.ItemsFrame) ; dfc.CornerRadius = UDim.new(0,4)
				local dfs = Instance.new("UIStroke", dropdown.ItemsFrame) ; dfs.Color = Color3.fromRGB(50,50,50) ; dfs.Thickness = 1

				dropdown.ListLayout = Instance.new("UIListLayout", dropdown.ItemsFrame)
				dropdown.ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
				local dlp = Instance.new("UIPadding", dropdown.ItemsFrame)
				dlp.PaddingTop = UDim.new(0,3) ; dlp.PaddingBottom = UDim.new(0,3)
				dlp.PaddingLeft = UDim.new(0,3) ; dlp.PaddingRight = UDim.new(0,3)

				if dropdown.flag and dropdown.flag ~= "" then
					library.flags[dropdown.flag] = dropdown.multichoice and {dropdown.default or dropdown.defaultitems[1] or ""} or (dropdown.default or dropdown.defaultitems[1] or "")
				end

				dropdown.Changed = Instance.new("BindableEvent")
				function dropdown:isSelected(item) for _,v in pairs(dropdown.values) do if v==item then return true end end return false end
				function dropdown:updateText(text)
					if #text >= 25 then text = text:sub(1,23) .. ".." end
					dropdown.SelectedLabel.Text = text
				end
				function dropdown:Set(value)
					if type(value)=="table" then
						dropdown.values=value ; dropdown:updateText(table.concat(value,", ")) ; pcall(dropdown.callback,value)
					else
						dropdown:updateText(value) ; dropdown.values={value} ; pcall(dropdown.callback,value)
					end
					dropdown.Changed:Fire(value)
					if dropdown.flag and dropdown.flag~="" then
						library.flags[dropdown.flag]=dropdown.multichoice and dropdown.values or dropdown.values[1]
					end
				end
				function dropdown:Get() return dropdown.multichoice and dropdown.values or dropdown.values[1] end

				dropdown.items = {}
				function dropdown:Add(v)
					local Item = Instance.new("TextButton", dropdown.ItemsFrame)
					Item.BackgroundColor3 = Color3.fromRGB(28,28,28) ; Item.TextColor3 = Color3.fromRGB(180,180,180)
					Item.BorderSizePixel=0 ; Item.Size=UDim2.fromOffset(sectorW-26,18)
					Item.ZIndex=13 ; Item.Text=v ; Item.Name=v ; Item.AutoButtonColor=false
					Item.Font=Enum.Font.Gotham ; Item.TextSize=11 ; Item.TextXAlignment=Enum.TextXAlignment.Left
					local ic = Instance.new("UICorner", Item) ; ic.CornerRadius = UDim.new(0,3)

					Item.MouseButton1Down:Connect(function()
						if dropdown.multichoice then
							if dropdown:isSelected(v) then
								for i2,v2 in pairs(dropdown.values) do if v2==v then table.remove(dropdown.values,i2) end end
								dropdown:Set(dropdown.values)
							else table.insert(dropdown.values,v) ; dropdown:Set(dropdown.values) end
							return
						else
							dropdown.Arrow.Text = "▾"
							dropdown.ItemsFrame.Visible=false
						end
						dropdown:Set(v)
					end)

					runservice.RenderStepped:Connect(function()
						if (dropdown.multichoice and dropdown:isSelected(v)) or dropdown.values[1]==v then
							Item.BackgroundColor3=Color3.fromRGB(40,40,40) ; Item.TextColor3=window.theme.accentcolor
						else
							Item.BackgroundColor3=Color3.fromRGB(28,28,28) ; Item.TextColor3=Color3.fromRGB(180,180,180)
						end
					end)

					table.insert(dropdown.items, v)
					local itemH = 18
					dropdown.ItemsFrame.Size = UDim2.fromOffset(sectorW-20, math.clamp(#dropdown.items*itemH, itemH, 120) + 6)
					dropdown.ItemsFrame.CanvasSize = UDim2.fromOffset(0, #dropdown.items*itemH+6)
					-- Mettre à jour la taille du container
					container.Size = UDim2.fromOffset(sectorW-20, 34 + (dropdown.ItemsFrame.Visible and dropdown.ItemsFrame.Size.Y.Offset or 0))
				end

				function dropdown:Remove(value)
					local item = dropdown.ItemsFrame:FindFirstChild(value)
					if item then
						for i,v in pairs(dropdown.items) do if v==value then table.remove(dropdown.items,i) end end
						local itemH = 18
						dropdown.ItemsFrame.Size = UDim2.fromOffset(sectorW-20, math.clamp(#dropdown.items*itemH,itemH,120)+6)
						dropdown.ItemsFrame.CanvasSize = UDim2.fromOffset(0, #dropdown.items*itemH+6)
						item:Destroy()
					end
				end

				local function toggleDropdown()
					dropdown.ItemsFrame.Visible = not dropdown.ItemsFrame.Visible
					dropdown.Arrow.Text = dropdown.ItemsFrame.Visible and "▴" or "▾"
					container.Size = UDim2.fromOffset(sectorW-20, 34 + (dropdown.ItemsFrame.Visible and dropdown.ItemsFrame.Size.Y.Offset or 0))
					sector:FixSize()
				end

				dropdown.Main.MouseButton1Down:Connect(toggleDropdown)
				dropdown.Main.MouseEnter:Connect(function() dds.Color = window.theme.accentcolor end)
				dropdown.Main.MouseLeave:Connect(function() dds.Color = Color3.fromRGB(50,50,50) end)

				for _,v in pairs(dropdown.defaultitems) do dropdown:Add(v) end
				if dropdown.default then dropdown:Set(dropdown.default) end

				sector:FixSize() ; table.insert(library.items, dropdown) ; return dropdown
			end

			-- ================================================================
			-- AddTextbox (sector level)
			-- ================================================================
			function sector:AddTextbox(text, default, callback, flag)
				local textbox = { }
				textbox.text = text or "" ; textbox.callback = callback or function() end
				textbox.default = default ; textbox.value = "" ; textbox.flag = flag or text or ""

				local container = makeItemContainer(sector.Items, 32)

				textbox.Label = makeLabel(container, textbox.text, Enum.TextXAlignment.Left, window.theme.itemscolor, 12, Enum.Font.Gotham)
				textbox.Label.Size = UDim2.fromOffset(sectorW-20, 14)
				textbox.Label.Position = UDim2.fromOffset(0, 0)
				updateevent.Event:Connect(function(theme) textbox.Label.TextColor3 = theme.itemscolor ; textbox.Label.Font = theme.font end)

				textbox.Box = Instance.new("TextBox", container)
				textbox.Box.BackgroundColor3 = Color3.fromRGB(28,28,28)
				textbox.Box.BorderSizePixel = 0 ; textbox.Box.Text = "" ; textbox.Box.ZIndex = 6
				textbox.Box.PlaceholderText = textbox.text ; textbox.Box.PlaceholderColor3 = Color3.fromRGB(90,90,90)
				textbox.Box.Font = Enum.Font.Gotham ; textbox.Box.TextSize = 11
				textbox.Box.TextColor3 = Color3.fromRGB(200,200,200)
				textbox.Box.ClearTextOnFocus = false ; textbox.Box.MultiLine = false
				textbox.Box.TextXAlignment = Enum.TextXAlignment.Left
				textbox.Box.Size = UDim2.fromOffset(sectorW-20, 18)
				textbox.Box.Position = UDim2.fromOffset(0, 16)
				local tbc = Instance.new("UICorner", textbox.Box) ; tbc.CornerRadius = UDim.new(0,4)
				local tbs = Instance.new("UIStroke", textbox.Box) ; tbs.Color = Color3.fromRGB(50,50,50) ; tbs.Thickness = 1
				local tbp = Instance.new("UIPadding", textbox.Box) ; tbp.PaddingLeft = UDim.new(0,6)

				textbox.Box.Focused:Connect(function() tbs.Color = window.theme.accentcolor end)
				textbox.Box.FocusLost:Connect(function()
					tbs.Color = Color3.fromRGB(50,50,50)
					textbox:Set(textbox.Box.Text)
				end)

				if textbox.flag and textbox.flag ~= "" then library.flags[textbox.flag] = textbox.default or "" end
				function textbox:Set(t) textbox.value=t ; textbox.Box.Text=t ; if textbox.flag~="" then library.flags[textbox.flag]=t end ; pcall(textbox.callback,t) end
				function textbox:Get() return textbox.value end
				if textbox.default then textbox:Set(textbox.default) end

				sector:FixSize() ; table.insert(library.items, textbox) ; return textbox
			end

			-- ================================================================
			-- AddSeperator
			-- ================================================================
			function sector:AddSeperator(text)
				local sep = {}
				local container = makeItemContainer(sector.Items, 12)
				sep.main = container

				sep.line = Instance.new("Frame", container)
				sep.line.BackgroundColor3 = Color3.fromRGB(50,50,50)
				sep.line.BorderSizePixel = 0 ; sep.line.ZIndex = 6
				sep.line.Size = UDim2.fromOffset(sectorW-20, 1)
				sep.line.Position = UDim2.fromOffset(0, 6)

				if text and text ~= "" then
					local ts = textservice:GetTextSize(text, 11, Enum.Font.GothamBold, Vector2.new(2000,2000))
					local bg = Instance.new("Frame", sep.line)
					bg.BackgroundColor3 = window.theme.sectorcolor ; bg.BorderSizePixel=0 ; bg.ZIndex=7
					bg.Size = UDim2.fromOffset(ts.X+10, 12)
					bg.Position = UDim2.new(0.5,-ts.X/2-5,-6,0)
					updateevent.Event:Connect(function(theme) bg.BackgroundColor3 = theme.sectorcolor end)

					local l = makeLabel(bg, text, Enum.TextXAlignment.Center, Color3.fromRGB(140,140,140), 11, Enum.Font.GothamBold, 8)
					l.Size = UDim2.fromScale(1,1)
				end

				sector:FixSize() ; return sep
			end

			return sector
		end

		table.insert(window.Tabs, tab)
		return tab
	end

	-- ================================================================
	-- Onglet ⚙ settings automatique
	-- ================================================================
	local settingsTab = window:CreateTab("⚙ Settings")
	local settingsSector = settingsTab:CreateSector("Keybind", "left")
	settingsSector:AddKeybind("Hide/Show", window.hidekey,
		function(newKey) if newKey ~= "None" then window.hidekey = newKey end end,
		function() end, "settings_hide_key"
	)
	local colorSectorL = settingsTab:CreateSector("Interface Colors", "left")
	colorSectorL:AddColorpicker("Accent Color",  window.theme.accentcolor,     function(c) window.theme.accentcolor=c     ; window:UpdateTheme(window.theme) end, "settings_accentcolor")
	colorSectorL:AddColorpicker("Accent 2",      window.theme.accentcolor2,    function(c) window.theme.accentcolor2=c    ; window:UpdateTheme(window.theme) end, "settings_accentcolor2")
	colorSectorL:AddColorpicker("Background",    window.theme.backgroundcolor, function(c) window.theme.backgroundcolor=c ; window:UpdateTheme(window.theme) end, "settings_backgroundcolor")
	colorSectorL:AddColorpicker("Sector Color",  window.theme.sectorcolor,     function(c) window.theme.sectorcolor=c    ; window:UpdateTheme(window.theme) end, "settings_sectorcolor")
	local colorSectorR = settingsTab:CreateSector("Text Colors", "right")
	colorSectorR:AddColorpicker("Items Text",    window.theme.itemscolor,    function(c) window.theme.itemscolor=c    ; window:UpdateTheme(window.theme) end, "settings_itemscolor")
	colorSectorR:AddColorpicker("Title Text",    window.theme.toptextcolor,  function(c) window.theme.toptextcolor=c  ; window:UpdateTheme(window.theme) end, "settings_toptextcolor")
	colorSectorR:AddColorpicker("Tab Text",      window.theme.tabstextcolor, function(c) window.theme.tabstextcolor=c ; window:UpdateTheme(window.theme) end, "settings_tabstextcolor")

	return window
end

-- ================================================================
-- NOTIFY SYSTEM — style Photon
-- ================================================================
function library:Notify(title, description, duration)
	if type(description) == "number" then duration = description ; description = nil end
	duration = duration or 5

	local notifGui = Instance.new("ScreenGui", coregui)
	notifGui.Name = "EchoNotif" ; notifGui.DisplayOrder = 20
	if syn then pcall(function() syn.protect_gui(notifGui) end) end

	local notifFrame = Instance.new("Frame", notifGui)
	notifFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
	notifFrame.BorderSizePixel = 0
	notifFrame.Size = UDim2.fromOffset(260, description and 58 or 38)
	notifFrame.Position = UDim2.new(1, 270, 0, 60)
	notifFrame.ClipsDescendants = false
	local nfc = Instance.new("UICorner", notifFrame) ; nfc.CornerRadius = UDim.new(0, 6)
	local nfs = Instance.new("UIStroke", notifFrame) ; nfs.Color = Color3.fromRGB(45,45,45) ; nfs.Thickness = 1

	-- Barre rouge à gauche
	local leftBar = Instance.new("Frame", notifFrame)
	leftBar.BackgroundColor3 = library.theme.accentcolor
	leftBar.BorderSizePixel = 0 ; leftBar.ZIndex = 4
	leftBar.Size = UDim2.fromOffset(3, notifFrame.Size.Y.Offset)
	leftBar.Position = UDim2.fromOffset(0, 0)
	local lbc = Instance.new("UICorner", leftBar) ; lbc.CornerRadius = UDim.new(0, 3)

	local titleLabel = Instance.new("TextLabel", notifFrame)
	titleLabel.BackgroundTransparency = 1 ; titleLabel.ZIndex = 5
	titleLabel.Font = Enum.Font.GothamBold ; titleLabel.Text = title or ""
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255) ; titleLabel.TextSize = 13
	titleLabel.TextStrokeTransparency = 1 ; titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Position = UDim2.fromOffset(14, description and 8 or 12)
	titleLabel.Size = UDim2.fromOffset(236, 16)

	if description then
		local descLabel = Instance.new("TextLabel", notifFrame)
		descLabel.BackgroundTransparency = 1 ; descLabel.ZIndex = 5
		descLabel.Font = Enum.Font.Gotham ; descLabel.Text = description
		descLabel.TextColor3 = Color3.fromRGB(140, 140, 140) ; descLabel.TextSize = 11
		descLabel.TextStrokeTransparency = 1 ; descLabel.TextXAlignment = Enum.TextXAlignment.Left
		descLabel.TextWrapped = true ; descLabel.Position = UDim2.fromOffset(14, 27)
		descLabel.Size = UDim2.fromOffset(236, 22)
	end

	-- Progress bar
	local pbg = Instance.new("Frame", notifFrame)
	pbg.BackgroundColor3 = Color3.fromRGB(35,35,35) ; pbg.BorderSizePixel = 0 ; pbg.ZIndex = 4
	pbg.Size = UDim2.fromOffset(260, 2) ; pbg.Position = UDim2.new(0, 0, 1, -2)
	local pbgc = Instance.new("UICorner", pbg) ; pbgc.CornerRadius = UDim.new(0,1)

	local pb = Instance.new("Frame", pbg)
	pb.BackgroundColor3 = library.theme.accentcolor ; pb.BorderSizePixel = 0 ; pb.ZIndex = 5
	pb.Size = UDim2.fromScale(1, 1)
	local pbc = Instance.new("UICorner", pb) ; pbc.CornerRadius = UDim.new(0,1)

	tweenservice:Create(notifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Position = UDim2.new(1, -272, 0, 60)
	}):Play()
	wait(0.35)
	tweenservice:Create(pb, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.fromScale(0,1)}):Play()
	delay(duration, function()
		tweenservice:Create(notifFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
			Position = UDim2.new(1, 270, 0, 60)
		}):Play()
		wait(0.3) ; notifGui:Destroy()
	end)

	return notifFrame
end

return library-- By EchoLabs — Reskin style Photon
local library = { 
	flags = { }, 
	items = { } 
}

-- Services
local players = game:GetService("Players")
local uis = game:GetService("UserInputService")
local runservice = game:GetService("RunService")
local tweenservice = game:GetService("TweenService")
local marketplaceservice = game:GetService("MarketplaceService")
local textservice = game:GetService("TextService")
local coregui = game:GetService("CoreGui")
local httpservice = game:GetService("HttpService")

local player = players.LocalPlayer
local mouse = player:GetMouse()
local camera = game.Workspace.CurrentCamera

-- ============================================================
-- KEYBIND HELPERS
-- ============================================================
local shorter_keycodes = {
	["LeftShift"]    = "LSHIFT",
	["RightShift"]   = "RSHIFT",
	["LeftControl"]  = "LCTRL",
	["RightControl"] = "RCTRL",
	["LeftAlt"]      = "LALT",
	["RightAlt"]     = "RALT",
}

local mouse_buttons = {
	[Enum.UserInputType.MouseButton1] = "MB1",
	[Enum.UserInputType.MouseButton2] = "MB2",
	[Enum.UserInputType.MouseButton3] = "MB3",
}

local function keybindToText(value)
	if value == "None" or value == nil then return "[None]" end
	if mouse_buttons[value] then return "[" .. mouse_buttons[value] .. "]" end
	if typeof(value) == "EnumItem" then return "[" .. (shorter_keycodes[value.Name] or value.Name) .. "]" end
	return "[" .. tostring(value) .. "]"
end

local function inputMatchesKeybind(input, value)
	if value == "None" or value == nil then return false end
	if mouse_buttons[value] then return input.UserInputType == value end
	if typeof(value) == "EnumItem" then
		return input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == value
	end
	return false
end

local function inputToKeybindValue(input)
	if mouse_buttons[input.UserInputType] then return input.UserInputType
	elseif input.UserInputType == Enum.UserInputType.Keyboard then return input.KeyCode
	end
	return "None"
end

-- ============================================================
-- THÈME PHOTON
-- ============================================================
library.theme = {
	fontsize        = 13,
	titlesize       = 15,
	font            = Enum.Font.GothamBold,
	background      = "",
	tilesize        = 90,
	backgroundcolor = Color3.fromRGB(18, 18, 18),    -- fond principal très sombre
	tabstextcolor   = Color3.fromRGB(180, 180, 180),
	bordercolor     = Color3.fromRGB(40, 40, 40),
	accentcolor     = Color3.fromRGB(232, 51, 58),   -- rouge Photon
	accentcolor2    = Color3.fromRGB(160, 25, 30),   -- rouge foncé
	outlinecolor    = Color3.fromRGB(45, 45, 45),
	outlinecolor2   = Color3.fromRGB(10, 10, 10),
	sectorcolor     = Color3.fromRGB(26, 26, 26),    -- card légèrement plus clair
	toptextcolor    = Color3.fromRGB(255, 255, 255),
	topheight       = 38,
	topcolor        = Color3.fromRGB(20, 20, 20),
	topcolor2       = Color3.fromRGB(16, 16, 16),
	buttoncolor     = Color3.fromRGB(38, 38, 38),
	buttoncolor2    = Color3.fromRGB(28, 28, 28),
	itemscolor      = Color3.fromRGB(190, 190, 190),
	itemscolor2     = Color3.fromRGB(220, 220, 220),
	-- Spécifique Photon
	tabbarcolor     = Color3.fromRGB(14, 14, 14),    -- barre onglets en bas
	tabbarheight    = 48,
	cardradius      = 4,
}

-- ============================================================
-- WATERMARK
-- ============================================================
function library:CreateWatermark(name, position)
	local gamename = marketplaceservice:GetProductInfo(game.PlaceId).Name
	local watermark = { }
	watermark.Visible = true
	watermark.text = " " .. name:gsub("{game}", gamename):gsub("{fps}", "0 FPS") .. " "

	watermark.main = Instance.new("ScreenGui", coregui)
	watermark.main.Name = "Watermark"
	if syn then syn.protect_gui(watermark.main) end

	if getgenv().watermark then getgenv().watermark:Remove() end
	getgenv().watermark = watermark.main

	watermark.mainbar = Instance.new("Frame", watermark.main)
	watermark.mainbar.Name = "Main"
	watermark.mainbar.BorderSizePixel = 0
	watermark.mainbar.ZIndex = 5
	watermark.mainbar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	watermark.mainbar.Position = UDim2.new(0, position and position.X or 10, 0, position and position.Y or 10)
	watermark.mainbar.Size = UDim2.new(0, 0, 0, 24)

	local corner = Instance.new("UICorner", watermark.mainbar)
	corner.CornerRadius = UDim.new(0, 3)

	watermark.Outline = Instance.new("Frame", watermark.mainbar)
	watermark.Outline.ZIndex = 4 ; watermark.Outline.BorderSizePixel = 0
	watermark.Outline.BackgroundColor3 = library.theme.outlinecolor
	watermark.Outline.Position = UDim2.fromOffset(-1, -1)
	watermark.Outline.Size = watermark.mainbar.Size + UDim2.fromOffset(2, 2)
	local c2 = Instance.new("UICorner", watermark.Outline) ; c2.CornerRadius = UDim.new(0, 4)

	watermark.label = Instance.new("TextLabel", watermark.mainbar)
	watermark.label.BackgroundTransparency = 1
	watermark.label.Position = UDim2.new(0, 0, 0, 0)
	watermark.label.Font = Enum.Font.GothamBold
	watermark.label.ZIndex = 6
	watermark.label.Text = watermark.text
	watermark.label.TextColor3 = Color3.fromRGB(255, 255, 255)
	watermark.label.TextSize = 13
	watermark.label.TextStrokeTransparency = 1
	watermark.label.TextXAlignment = Enum.TextXAlignment.Left
	watermark.label.Size = UDim2.new(0, watermark.label.TextBounds.X + 10, 0, 24)

	watermark.topbar = Instance.new("Frame", watermark.mainbar)
	watermark.topbar.ZIndex = 6
	watermark.topbar.BackgroundColor3 = library.theme.accentcolor
	watermark.topbar.BorderSizePixel = 0
	watermark.topbar.Size = UDim2.new(0, 0, 0, 2)

	watermark.mainbar.Size = UDim2.new(0, watermark.label.TextBounds.X + 4, 0, 24)
	watermark.topbar.Size = UDim2.new(0, watermark.label.TextBounds.X + 4, 0, 2)
	watermark.Outline.Size = watermark.mainbar.Size + UDim2.fromOffset(2, 2)

	local startTime, counter, oldfps = os.clock(), 0, nil
	runservice.Heartbeat:Connect(function()
		watermark.label.Visible = watermark.Visible
		watermark.mainbar.Visible = watermark.Visible
		watermark.topbar.Visible = watermark.Visible

		if name:find("{fps}") then
			local currentTime = os.clock()
			counter = counter + 1
			if currentTime - startTime >= 1 then
				local fps = math.floor(counter / (currentTime - startTime))
				counter = 0 ; startTime = currentTime
				if fps ~= oldfps then
					watermark.label.Text = " " .. name:gsub("{game}", gamename):gsub("{fps}", fps .. " FPS") .. " "
					watermark.label.Size = UDim2.new(0, watermark.label.TextBounds.X + 10, 0, 24)
					watermark.mainbar.Size = UDim2.new(0, watermark.label.TextBounds.X, 0, 24)
					watermark.topbar.Size = UDim2.new(0, watermark.label.TextBounds.X, 0, 2)
					watermark.Outline.Size = watermark.mainbar.Size + UDim2.fromOffset(2, 2)
				end
				oldfps = fps
			end
		end
	end)

	watermark.mainbar.MouseEnter:Connect(function()
		tweenservice:Create(watermark.mainbar, TweenInfo.new(0.15), {BackgroundTransparency=1}):Play()
		tweenservice:Create(watermark.label,   TweenInfo.new(0.15), {TextTransparency=1}):Play()
	end)
	watermark.mainbar.MouseLeave:Connect(function()
		tweenservice:Create(watermark.mainbar, TweenInfo.new(0.15), {BackgroundTransparency=0}):Play()
		tweenservice:Create(watermark.label,   TweenInfo.new(0.15), {TextTransparency=0}):Play()
	end)

	function watermark:UpdateTheme(theme)
		theme = theme or library.theme
		watermark.Outline.BackgroundColor3 = theme.outlinecolor
		watermark.label.Font              = theme.font
		watermark.topbar.BackgroundColor3 = theme.accentcolor
	end

	return watermark
end

-- ============================================================
-- WINDOW — style Photon
-- ============================================================
function library:CreateWindow(name, size, hidebutton)
	local window = { }
	window.name      = name or ""
	window.size      = UDim2.fromOffset(size.X, size.Y) or UDim2.fromOffset(900, 560)
	window.hidebutton = hidebutton or Enum.KeyCode.RightShift
	window.hidekey   = window.hidebutton
	window.theme     = library.theme

	local updateevent = Instance.new("BindableEvent")
	function window:UpdateTheme(theme)
		updateevent:Fire(theme or library.theme)
		window.theme = (theme or library.theme)
	end

	window.Main = Instance.new("ScreenGui", coregui)
	window.Main.Name = name
	window.Main.DisplayOrder = 15
	if syn then syn.protect_gui(window.Main) end

	if getgenv().uilib then getgenv().uilib:Remove() end
	getgenv().uilib = window.Main

	-- Drag
	local dragging, dragInput, dragStart, startPos
	uis.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			window.Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	local function dragstart(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true ; dragStart = input.Position ; startPos = window.Frame.Position
			input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
		end
	end
	local function dragend(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end

	-- ── Frame principal
	window.Frame = Instance.new("TextButton", window.Main)
	window.Frame.Name = "main"
	window.Frame.Position = UDim2.fromScale(0.5, 0.5)
	window.Frame.BorderSizePixel = 0
	window.Frame.Size = window.size
	window.Frame.AutoButtonColor = false
	window.Frame.Text = ""
	window.Frame.BackgroundColor3 = window.theme.backgroundcolor
	window.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
	window.Frame.ClipsDescendants = true
	local frameCorner = Instance.new("UICorner", window.Frame)
	frameCorner.CornerRadius = UDim.new(0, 6)
	updateevent.Event:Connect(function(theme) window.Frame.BackgroundColor3 = theme.backgroundcolor end)

	-- Outline
	window.Outline = Instance.new("Frame", window.Frame)
	window.Outline.ZIndex = 0 ; window.Outline.BorderSizePixel = 0
	window.Outline.Size = window.size + UDim2.fromOffset(2, 2)
	window.Outline.BackgroundColor3 = window.theme.outlinecolor
	window.Outline.Position = UDim2.fromOffset(-1, -1)
	local oc = Instance.new("UICorner", window.Outline) ; oc.CornerRadius = UDim.new(0, 7)
	updateevent.Event:Connect(function(theme) window.Outline.BackgroundColor3 = theme.outlinecolor end)

	window.BlackOutline = Instance.new("Frame", window.Frame)
	window.BlackOutline.ZIndex = -1 ; window.BlackOutline.BorderSizePixel = 0
	window.BlackOutline.Size = window.size + UDim2.fromOffset(4, 4)
	window.BlackOutline.BackgroundColor3 = window.theme.outlinecolor2
	window.BlackOutline.Position = UDim2.fromOffset(-2, -2)
	local boc = Instance.new("UICorner", window.BlackOutline) ; boc.CornerRadius = UDim.new(0, 8)
	updateevent.Event:Connect(function(theme) window.BlackOutline.BackgroundColor3 = theme.outlinecolor2 end)

	uis.InputBegan:Connect(function(key)
		if key.KeyCode == window.hidekey then window.Frame.Visible = not window.Frame.Visible end
	end)

	-- ── TopBar (style Photon : fin, nom à gauche, boutons à droite)
	window.TopBar = Instance.new("Frame", window.Frame)
	window.TopBar.Name = "top"
	window.TopBar.Size = UDim2.fromOffset(window.size.X.Offset, window.theme.topheight)
	window.TopBar.BorderSizePixel = 0
	window.TopBar.BackgroundColor3 = window.theme.topcolor
	window.TopBar.ZIndex = 2
	window.TopBar.InputBegan:Connect(dragstart)
	window.TopBar.InputChanged:Connect(dragend)
	updateevent.Event:Connect(function(theme)
		window.TopBar.Size = UDim2.fromOffset(window.size.X.Offset, theme.topheight)
		window.TopBar.BackgroundColor3 = theme.topcolor
	end)

	-- Ligne rouge sous le topbar
	window.TopAccentLine = Instance.new("Frame", window.Frame)
	window.TopAccentLine.Name = "accentline"
	window.TopAccentLine.ZIndex = 3
	window.TopAccentLine.BorderSizePixel = 0
	window.TopAccentLine.BackgroundColor3 = window.theme.accentcolor
	window.TopAccentLine.Size = UDim2.fromOffset(window.size.X.Offset, 2)
	window.TopAccentLine.Position = UDim2.fromOffset(0, window.theme.topheight)
	updateevent.Event:Connect(function(theme)
		window.TopAccentLine.BackgroundColor3 = theme.accentcolor
		window.TopAccentLine.Position = UDim2.fromOffset(0, theme.topheight)
		window.TopAccentLine.Size = UDim2.fromOffset(window.size.X.Offset, 2)
	end)

	-- Nom (style Photon : minuscule, fonte légère)
	window.NameLabel = Instance.new("TextLabel", window.TopBar)
	window.NameLabel.TextColor3 = window.theme.toptextcolor
	window.NameLabel.Text = window.name:lower()
	window.NameLabel.TextXAlignment = Enum.TextXAlignment.Left
	window.NameLabel.Font = Enum.Font.GothamBold
	window.NameLabel.Name = "title"
	window.NameLabel.Position = UDim2.fromOffset(14, 0)
	window.NameLabel.BackgroundTransparency = 1
	window.NameLabel.Size = UDim2.fromOffset(200, window.theme.topheight)
	window.NameLabel.TextSize = 16
	window.NameLabel.ZIndex = 5
	updateevent.Event:Connect(function(theme)
		window.NameLabel.TextColor3 = theme.toptextcolor
		window.NameLabel.TextSize = theme.titlesize + 1
	end)

	-- Bouton Close
	window.CloseBtn = Instance.new("TextButton", window.TopBar)
	window.CloseBtn.Text = "✕"
	window.CloseBtn.Font = Enum.Font.GothamBold
	window.CloseBtn.TextSize = 12
	window.CloseBtn.TextColor3 = Color3.fromRGB(140, 140, 140)
	window.CloseBtn.BackgroundTransparency = 1
	window.CloseBtn.BorderSizePixel = 0
	window.CloseBtn.Size = UDim2.fromOffset(28, 28)
	window.CloseBtn.Position = UDim2.new(1, -32, 0, 5)
	window.CloseBtn.ZIndex = 10
	window.CloseBtn.AutoButtonColor = false

	window.CloseBtn.MouseButton1Down:Connect(function()
		for i, v in pairs(library.items) do
			pcall(function()
				if v.Set and type(v.value) == "boolean" and v.value == true then v:Set(false) end
			end)
		end
		for i, v in pairs(library.flags) do library.flags[i] = nil end
		for i, v in pairs(window.OpenedColorPickers) do
			if v then pcall(function() i.Visible = false ; window.OpenedColorPickers[i] = false end) end
		end
		for _, gui in pairs(coregui:GetChildren()) do
			if gui.Name == "Watermark" or gui.Name == "EchoNotif" then gui:Destroy() end
		end
		window.Main:Destroy()
	end)
	window.CloseBtn.MouseEnter:Connect(function()
		tweenservice:Create(window.CloseBtn, TweenInfo.new(0.1), {TextColor3 = library.theme.accentcolor}):Play()
	end)
	window.CloseBtn.MouseLeave:Connect(function()
		tweenservice:Create(window.CloseBtn, TweenInfo.new(0.1), {TextColor3 = Color3.fromRGB(140,140,140)}):Play()
	end)

	-- Bouton Minimize
	window.MinimizeBtn = Instance.new("TextButton", window.TopBar)
	window.MinimizeBtn.Text = "─"
	window.MinimizeBtn.Font = Enum.Font.GothamBold
	window.MinimizeBtn.TextSize = 12
	window.MinimizeBtn.TextColor3 = Color3.fromRGB(140, 140, 140)
	window.MinimizeBtn.BackgroundTransparency = 1
	window.MinimizeBtn.BorderSizePixel = 0
	window.MinimizeBtn.Size = UDim2.fromOffset(28, 28)
	window.MinimizeBtn.Position = UDim2.new(1, -60, 0, 5)
	window.MinimizeBtn.ZIndex = 10
	window.MinimizeBtn.AutoButtonColor = false

	local minimized = false
	window.MinimizeBtn.MouseButton1Down:Connect(function()
		minimized = not minimized
		if minimized then
			window.Frame:TweenSize(UDim2.fromOffset(window.size.X.Offset, window.theme.topheight + 2), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.15)
		else
			window.Frame:TweenSize(window.size, Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.15)
		end
	end)
	window.MinimizeBtn.MouseEnter:Connect(function()
		tweenservice:Create(window.MinimizeBtn, TweenInfo.new(0.1), {TextColor3 = Color3.fromRGB(255,255,255)}):Play()
	end)
	window.MinimizeBtn.MouseLeave:Connect(function()
		tweenservice:Create(window.MinimizeBtn, TweenInfo.new(0.1), {TextColor3 = Color3.fromRGB(140,140,140)}):Play()
	end)

	-- ── Zone de contenu (entre topbar et tabbar)
	local contentTop = window.theme.topheight + 2
	local tabBarHeight = window.theme.tabbarheight

	window.ContentArea = Instance.new("Frame", window.Frame)
	window.ContentArea.Name = "content"
	window.ContentArea.BackgroundTransparency = 1
	window.ContentArea.BorderSizePixel = 0
	window.ContentArea.Position = UDim2.fromOffset(0, contentTop)
	window.ContentArea.Size = UDim2.fromOffset(window.size.X.Offset, window.size.Y.Offset - contentTop - tabBarHeight)
	window.ContentArea.ZIndex = 2
	window.ContentArea.ClipsDescendants = true

	-- ── Tab bar EN BAS (style Photon)
	window.TabBar = Instance.new("Frame", window.Frame)
	window.TabBar.Name = "tabbar"
	window.TabBar.BackgroundColor3 = window.theme.tabbarcolor
	window.TabBar.BorderSizePixel = 0
	window.TabBar.Size = UDim2.fromOffset(window.size.X.Offset, tabBarHeight)
	window.TabBar.Position = UDim2.fromOffset(0, window.size.Y.Offset - tabBarHeight)
	window.TabBar.ZIndex = 5

	-- Ligne séparatrice au dessus de la tabbar
	window.TabBarLine = Instance.new("Frame", window.Frame)
	window.TabBarLine.BorderSizePixel = 0
	window.TabBarLine.BackgroundColor3 = window.theme.outlinecolor
	window.TabBarLine.Size = UDim2.fromOffset(window.size.X.Offset, 1)
	window.TabBarLine.Position = UDim2.fromOffset(0, window.size.Y.Offset - tabBarHeight - 1)
	window.TabBarLine.ZIndex = 4

	window.TabBarLayout = Instance.new("UIListLayout", window.TabBar)
	window.TabBarLayout.FillDirection = Enum.FillDirection.Horizontal
	window.TabBarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	window.TabBarLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	window.TabBarLayout.SortOrder = Enum.SortOrder.LayoutOrder
	window.TabBarLayout.Padding = UDim.new(0, 0)

	-- Indicateur de tab sélectionné (ligne rouge en haut du bouton tab)
	window.TabIndicator = Instance.new("Frame", window.TabBar)
	window.TabIndicator.Name = "indicator"
	window.TabIndicator.ZIndex = 8
	window.TabIndicator.BorderSizePixel = 0
	window.TabIndicator.BackgroundColor3 = window.theme.accentcolor
	window.TabIndicator.Size = UDim2.fromOffset(60, 2)
	window.TabIndicator.AnchorPoint = Vector2.new(0, 0)
	window.TabIndicator.Position = UDim2.fromOffset(0, 0)
	updateevent.Event:Connect(function(theme) window.TabIndicator.BackgroundColor3 = theme.accentcolor end)

	-- Resize handle
	local minWidth, minHeight = 400, 300
	local resizing = false
	local resizeStart, resizeStartSize = nil, nil

	window.ResizeHandle = Instance.new("TextButton", window.Frame)
	window.ResizeHandle.Text = "" ; window.ResizeHandle.BackgroundTransparency = 1
	window.ResizeHandle.BorderSizePixel = 0
	window.ResizeHandle.Size = UDim2.fromOffset(14, 14)
	window.ResizeHandle.Position = UDim2.new(1, -14, 1, -14)
	window.ResizeHandle.ZIndex = 20 ; window.ResizeHandle.AutoButtonColor = false

	window.ResizeHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			resizing = true
			resizeStart = Vector2.new(input.Position.X, input.Position.Y)
			resizeStartSize = Vector2.new(window.Frame.AbsoluteSize.X, window.Frame.AbsoluteSize.Y)
		end
	end)
	uis.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then resizing = false end
	end)
	uis.InputChanged:Connect(function(input)
		if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = Vector2.new(input.Position.X - resizeStart.X, input.Position.Y - resizeStart.Y)
			local newW = math.max(minWidth,  resizeStartSize.X + delta.X)
			local newH = math.max(minHeight, resizeStartSize.Y + delta.Y)
			window.size = UDim2.fromOffset(newW, newH)
			window.Frame.Size = window.size
			window.Outline.Size = window.size + UDim2.fromOffset(2,2)
			window.BlackOutline.Size = window.size + UDim2.fromOffset(4,4)
			window.TopBar.Size = UDim2.fromOffset(newW, window.theme.topheight)
			window.TopAccentLine.Size = UDim2.fromOffset(newW, 2)
			window.ContentArea.Size = UDim2.fromOffset(newW, newH - contentTop - tabBarHeight)
			window.TabBar.Size = UDim2.fromOffset(newW, tabBarHeight)
			window.TabBar.Position = UDim2.fromOffset(0, newH - tabBarHeight)
			window.TabBarLine.Size = UDim2.fromOffset(newW, 1)
			window.TabBarLine.Position = UDim2.fromOffset(0, newH - tabBarHeight - 1)
			for _, tab in pairs(window.Tabs) do
				tab.Container.Size = UDim2.fromOffset(newW, newH - contentTop - tabBarHeight)
				tab.Left.Size  = UDim2.fromOffset(newW / 2, newH - contentTop - tabBarHeight)
				tab.Right.Size = UDim2.fromOffset(newW / 2, newH - contentTop - tabBarHeight)
				tab.Right.Position = tab.Left.Position + UDim2.fromOffset(newW / 2, 0)
				for _, sector in pairs(tab.SectorsLeft) do
					sector.Main.Size = UDim2.fromOffset(newW / 2 - 20, sector.ListLayout.AbsoluteContentSize.Y + 26)
				end
				for _, sector in pairs(tab.SectorsRight) do
					sector.Main.Size = UDim2.fromOffset(newW / 2 - 20, sector.ListLayout.AbsoluteContentSize.Y + 26)
				end
			end
		end
	end)

	window.OpenedColorPickers = { }
	window.Tabs = { }

	-- ============================================================
	-- CreateTab
	-- ============================================================
	function window:CreateTab(name, icon)
		local tab = { }
		tab.name = name or ""
		tab.icon = icon or ""

		-- Bouton tab (en bas, style Photon : icône + texte)
		local tabBtnW = math.max(70, textservice:GetTextSize(tab.name, 12, Enum.Font.Gotham, Vector2.new(200,300)).X + 30)

		tab.TabButton = Instance.new("TextButton", window.TabBar)
		tab.TabButton.BackgroundTransparency = 1
		tab.TabButton.BorderSizePixel = 0
		tab.TabButton.Size = UDim2.fromOffset(tabBtnW, tabBarHeight)
		tab.TabButton.AutoButtonColor = false
		tab.TabButton.ZIndex = 6
		tab.TabButton.Text = ""
		tab.TabButton.Name = tab.name

		-- Icône (optionnelle, affichée en haut du bouton)
		if tab.icon ~= "" then
			tab.TabIcon = Instance.new("ImageLabel", tab.TabButton)
			tab.TabIcon.BackgroundTransparency = 1
			tab.TabIcon.Size = UDim2.fromOffset(18, 18)
			tab.TabIcon.Position = UDim2.new(0.5, -9, 0, 6)
			tab.TabIcon.Image = tab.icon
			tab.TabIcon.ImageColor3 = Color3.fromRGB(140, 140, 140)
			tab.TabIcon.ZIndex = 7
		end

		tab.TabLabel = Instance.new("TextLabel", tab.TabButton)
		tab.TabLabel.BackgroundTransparency = 1
		tab.TabLabel.Font = Enum.Font.Gotham
		tab.TabLabel.TextSize = 11
		tab.TabLabel.TextColor3 = Color3.fromRGB(130, 130, 130)
		tab.TabLabel.Text = tab.name
		tab.TabLabel.ZIndex = 7
		tab.TabLabel.TextXAlignment = Enum.TextXAlignment.Center
		if tab.icon ~= "" then
			tab.TabLabel.Size = UDim2.fromOffset(tabBtnW, 16)
			tab.TabLabel.Position = UDim2.new(0, 0, 1, -18)
		else
			tab.TabLabel.Size = UDim2.fromOffset(tabBtnW, tabBarHeight)
			tab.TabLabel.Position = UDim2.fromOffset(0, 0)
		end

		-- Container du contenu de cet onglet
		tab.Container = Instance.new("Frame", window.ContentArea)
		tab.Container.BackgroundTransparency = 1
		tab.Container.BorderSizePixel = 0
		tab.Container.Size = window.ContentArea.Size
		tab.Container.Position = UDim2.fromOffset(0, 0)
		tab.Container.Visible = false
		tab.Container.ClipsDescendants = true

		-- Colonnes gauche/droite
		tab.Left = Instance.new("ScrollingFrame", tab.Container)
		tab.Left.Name = "leftside"
		tab.Left.BorderSizePixel = 0
		tab.Left.Size = UDim2.fromOffset(window.ContentArea.AbsoluteSize.X / 2, window.ContentArea.AbsoluteSize.Y)
		tab.Left.BackgroundTransparency = 1
		tab.Left.Visible = true
		tab.Left.ScrollBarThickness = 0
		tab.Left.ScrollingDirection = "Y"
		tab.Left.Position = UDim2.fromOffset(0, 0)

		tab.LeftListLayout = Instance.new("UIListLayout", tab.Left)
		tab.LeftListLayout.FillDirection = Enum.FillDirection.Vertical
		tab.LeftListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		tab.LeftListLayout.Padding = UDim.new(0, 10)

		tab.LeftPadding = Instance.new("UIPadding", tab.Left)
		tab.LeftPadding.PaddingTop   = UDim.new(0, 12)
		tab.LeftPadding.PaddingLeft  = UDim.new(0, 12)
		tab.LeftPadding.PaddingRight = UDim.new(0, 8)

		tab.Right = Instance.new("ScrollingFrame", tab.Container)
		tab.Right.Name = "rightside"
		tab.Right.BorderSizePixel = 0
		tab.Right.ScrollBarThickness = 0
		tab.Right.ScrollingDirection = "Y"
		tab.Right.Visible = true
		tab.Right.Size = UDim2.fromOffset(window.ContentArea.AbsoluteSize.X / 2, window.ContentArea.AbsoluteSize.Y)
		tab.Right.BackgroundTransparency = 1
		tab.Right.Position = tab.Left.Position + UDim2.fromOffset(window.ContentArea.AbsoluteSize.X / 2, 0)

		tab.RightListLayout = Instance.new("UIListLayout", tab.Right)
		tab.RightListLayout.FillDirection = Enum.FillDirection.Vertical
		tab.RightListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		tab.RightListLayout.Padding = UDim.new(0, 10)

		tab.RightPadding = Instance.new("UIPadding", tab.Right)
		tab.RightPadding.PaddingTop   = UDim.new(0, 12)
		tab.RightPadding.PaddingLeft  = UDim.new(0, 8)
		tab.RightPadding.PaddingRight = UDim.new(0, 12)

		tab.SectorsLeft  = { }
		tab.SectorsRight = { }

		local block = false
		function tab:SelectTab()
			repeat wait() until not block
			block = true
			for _, v in pairs(window.Tabs) do
				if v ~= tab then
					v.Container.Visible = false
					v.TabLabel.TextColor3 = Color3.fromRGB(130, 130, 130)
					v.TabLabel.Font = Enum.Font.Gotham
					if v.TabIcon then v.TabIcon.ImageColor3 = Color3.fromRGB(130, 130, 130) end
				end
			end
			tab.Container.Visible = true
			tab.TabLabel.TextColor3 = window.theme.accentcolor
			tab.TabLabel.Font = Enum.Font.GothamBold
			if tab.TabIcon then tab.TabIcon.ImageColor3 = window.theme.accentcolor end

			-- Déplace l'indicateur rouge sous le bouton sélectionné
			local btnPos = tab.TabButton.AbsolutePosition.X - window.TabBar.AbsolutePosition.X
			local btnW   = tab.TabButton.AbsoluteSize.X
			tweenservice:Create(window.TabIndicator, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Position = UDim2.fromOffset(btnPos, 0),
				Size     = UDim2.fromOffset(btnW, 2)
			}):Play()
			wait(0.15)
			block = false
		end

		if #window.Tabs == 0 then tab:SelectTab() end
		tab.TabButton.MouseButton1Down:Connect(function() tab:SelectTab() end)

		-- ============================================================
		-- CreateSector — style Photon (card avec coin arrondi + bord rouge en haut)
		-- ============================================================
		function tab:CreateSector(name, side)
			local sector = { }
			sector.name = name or ""
			sector.side = side:lower() or "left"

			local parentFrame = sector.side == "left" and tab.Left or tab.Right
			local sectorW = (window.ContentArea.AbsoluteSize.X / 2) - 20

			sector.Main = Instance.new("Frame", parentFrame)
			sector.Main.Name = sector.name:gsub(" ", "") .. "Sector"
			sector.Main.BorderSizePixel = 0
			sector.Main.ZIndex = 4
			sector.Main.Size = UDim2.fromOffset(sectorW, 20)
			sector.Main.BackgroundColor3 = window.theme.sectorcolor
			local mc = Instance.new("UICorner", sector.Main) ; mc.CornerRadius = UDim.new(0, 5)
			updateevent.Event:Connect(function(theme) sector.Main.BackgroundColor3 = theme.sectorcolor end)

			-- Outline de la card
			sector.CardOutline = Instance.new("UIStroke", sector.Main)
			sector.CardOutline.Color = Color3.fromRGB(40, 40, 40)
			sector.CardOutline.Thickness = 1
			sector.CardOutline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

			-- Ligne rouge en haut de la card (header)
			sector.TopLine = Instance.new("Frame", sector.Main)
			sector.TopLine.Name = "topline"
			sector.TopLine.ZIndex = 6
			sector.TopLine.BorderSizePixel = 0
			sector.TopLine.BackgroundColor3 = window.theme.accentcolor
			sector.TopLine.Size = UDim2.fromOffset(sectorW, 2)
			sector.TopLine.Position = UDim2.fromOffset(0, 0)
			local tlc = Instance.new("UICorner", sector.TopLine)
			tlc.CornerRadius = UDim.new(0, 5)
			updateevent.Event:Connect(function(theme) sector.TopLine.BackgroundColor3 = theme.accentcolor end)

			-- Header avec le titre de la sector
			sector.Header = Instance.new("Frame", sector.Main)
			sector.Header.Name = "header"
			sector.Header.ZIndex = 5
			sector.Header.BorderSizePixel = 0
			sector.Header.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
			sector.Header.Size = UDim2.fromOffset(sectorW, 22)
			sector.Header.Position = UDim2.fromOffset(0, 0)
			local hc = Instance.new("UICorner", sector.Header) ; hc.CornerRadius = UDim.new(0, 5)

			-- Sous-frame pour cacher les coins du bas de l'header
			local headerFix = Instance.new("Frame", sector.Header)
			headerFix.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
			headerFix.BorderSizePixel = 0
			headerFix.Size = UDim2.fromOffset(sectorW, 11)
			headerFix.Position = UDim2.new(0, 0, 1, -11)
			headerFix.ZIndex = 5

			sector.Label = Instance.new("TextLabel", sector.Header)
			sector.Label.AnchorPoint = Vector2.new(0, 0.5)
			sector.Label.Position = UDim2.new(0, 10, 0.5, 1)
			sector.Label.BackgroundTransparency = 1
			sector.Label.BorderSizePixel = 0
			sector.Label.ZIndex = 6
			sector.Label.Text = sector.name:upper()
			sector.Label.TextColor3 = Color3.fromRGB(255, 255, 255)
			sector.Label.TextStrokeTransparency = 1
			sector.Label.Font = Enum.Font.GothamBold
			sector.Label.TextSize = 11
			sector.Label.Size = UDim2.fromOffset(sectorW - 20, 22)

			sector.Items = Instance.new("Frame", sector.Main)
			sector.Items.Name = "items"
			sector.Items.ZIndex = 5
			sector.Items.BackgroundTransparency = 1
			sector.Items.AutomaticSize = Enum.AutomaticSize.Y
			sector.Items.BorderSizePixel = 0
			sector.Items.Size = UDim2.fromOffset(sectorW, 0)
			sector.Items.Position = UDim2.fromOffset(0, 24)

			sector.ListLayout = Instance.new("UIListLayout", sector.Items)
			sector.ListLayout.FillDirection = Enum.FillDirection.Vertical
			sector.ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			sector.ListLayout.Padding = UDim.new(0, 8)

			sector.ListPadding = Instance.new("UIPadding", sector.Items)
			sector.ListPadding.PaddingTop    = UDim.new(0, 10)
			sector.ListPadding.PaddingLeft   = UDim.new(0, 10)
			sector.ListPadding.PaddingRight  = UDim.new(0, 10)
			sector.ListPadding.PaddingBottom = UDim.new(0, 10)

			table.insert(sector.side == "left" and tab.SectorsLeft or tab.SectorsRight, sector)

			function sector:FixSize()
				sector.Main.Size = UDim2.fromOffset(sectorW, sector.ListLayout.AbsoluteContentSize.Y + 26 + 14)
				sector.TopLine.Size = UDim2.fromOffset(sectorW, 2)
				local sizeleft, sizeright = 0, 0
				for _, v in pairs(tab.SectorsLeft)  do sizeleft  = sizeleft  + v.Main.AbsoluteSize.Y end
				for _, v in pairs(tab.SectorsRight) do sizeright = sizeright + v.Main.AbsoluteSize.Y end
				tab.Left.CanvasSize  = UDim2.fromOffset(0, sizeleft  + (#tab.SectorsLeft  * 22))
				tab.Right.CanvasSize = UDim2.fromOffset(0, sizeright + (#tab.SectorsRight * 22))
			end

			-- ── Helpers internes pour créer les éléments UI Photon-style ──

			local function makeItemContainer(parent, height)
				local f = Instance.new("Frame", parent)
				f.BackgroundTransparency = 1 ; f.BorderSizePixel = 0
				f.ZIndex = 5 ; f.Size = UDim2.fromOffset(sectorW - 20, height)
				return f
			end

			local function makeLabel(parent, text, xAlign, color, size, font, zindex)
				local l = Instance.new("TextLabel", parent)
				l.BackgroundTransparency = 1 ; l.BorderSizePixel = 0
				l.Font = font or Enum.Font.Gotham
				l.Text = text or ""
				l.TextColor3 = color or window.theme.itemscolor
				l.TextSize = size or 12
				l.TextStrokeTransparency = 1
				l.ZIndex = zindex or 6
				l.TextXAlignment = xAlign or Enum.TextXAlignment.Left
				return l
			end

			-- ================================================================
			-- AddLabel
			-- ================================================================
			function sector:AddLabel(text, color, centered)
				local label = { }
				label._color = color

				local container = makeItemContainer(sector.Items, 16)
				label.Main = container

				-- Petite barre accent à gauche
				label.AccentBar = Instance.new("Frame", container)
				label.AccentBar.BackgroundColor3 = window.theme.accentcolor
				label.AccentBar.BorderSizePixel = 0
				label.AccentBar.ZIndex = 6
				label.AccentBar.Size = UDim2.fromOffset(2, 14)
				label.AccentBar.Position = UDim2.fromOffset(0, 1)
				updateevent.Event:Connect(function(theme) label.AccentBar.BackgroundColor3 = theme.accentcolor end)

				label.Text = makeLabel(container, text, centered and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left, color or window.theme.itemscolor, 12)
				label.Text.Position = UDim2.fromOffset(8, 0)
				label.Text.Size = UDim2.fromOffset(sectorW - 28, 16)
				label.Text.TextWrapped = true
				label.Text.AutomaticSize = Enum.AutomaticSize.Y
				updateevent.Event:Connect(function(theme)
					label.Text.Font = theme.font
					if not label._color then label.Text.TextColor3 = theme.itemscolor end
				end)

				function label:Set(value)   label.Text.Text = tostring(value) ; sector:FixSize() end
				function label:Get()        return label.Text.Text end
				function label:SetColor(c)  label._color = c ; label.Text.TextColor3 = c end
				function label:SetVisible(v) label.Main.Visible = v ; sector:FixSize() end

				sector:FixSize() ; return label
			end

			-- ================================================================
			-- AddButton — style Photon (fond sombre, bord gris, hover rouge)
			-- ================================================================
			function sector:AddButton(text, callback)
				local button = { }
				button.text = text or "" ; button.callback = callback or function() end

				local container = makeItemContainer(sector.Items, 26)
				button.Main = Instance.new("TextButton", container)
				button.Main.Name = "button"
				button.Main.BorderSizePixel = 0
				button.Main.Text = ""
				button.Main.AutoButtonColor = false
				button.Main.ZIndex = 6
				button.Main.Size = UDim2.fromOffset(sectorW - 20, 26)
				button.Main.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
				local bc = Instance.new("UICorner", button.Main) ; bc.CornerRadius = UDim.new(0, 4)
				local bstroke = Instance.new("UIStroke", button.Main)
				bstroke.Color = Color3.fromRGB(50, 50, 50) ; bstroke.Thickness = 1

				button.Label = makeLabel(button.Main, button.text, Enum.TextXAlignment.Center, window.theme.itemscolor2, 12, Enum.Font.GothamBold, 7)
				button.Label.Size = UDim2.fromScale(1, 1)
				updateevent.Event:Connect(function(theme)
					button.Label.Font = theme.font
					button.Label.TextColor3 = theme.itemscolor2
				end)

				button.Main.MouseButton1Down:Connect(button.callback)
				button.Main.MouseEnter:Connect(function()
					tweenservice:Create(button.Main, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(45,45,45)}):Play()
					bstroke.Color = window.theme.accentcolor
				end)
				button.Main.MouseLeave:Connect(function()
					tweenservice:Create(button.Main, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(32,32,32)}):Play()
					bstroke.Color = Color3.fromRGB(50, 50, 50)
				end)
				button.Main.MouseButton1Down:Connect(function()
					tweenservice:Create(button.Main, TweenInfo.new(0.05), {BackgroundColor3 = window.theme.accentcolor}):Play()
					task.delay(0.1, function()
						tweenservice:Create(button.Main, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(32,32,32)}):Play()
					end)
				end)

				sector:FixSize() ; return button
			end

			-- ================================================================
			-- AddToggle — style Photon (checkbox carré rouge)
			-- ================================================================
			function sector:AddToggle(text, default, callback, flag)
				local toggle = { }
				toggle.text     = text or ""
				toggle.default  = default or false
				toggle.callback = callback or function() end
				toggle.flag     = flag or text or ""
				toggle.value    = toggle.default

				local container = makeItemContainer(sector.Items, 16)
				toggle.Main = container

				-- Checkbox
				toggle.Box = Instance.new("TextButton", container)
				toggle.Box.Name = "toggle"
				toggle.Box.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
				toggle.Box.BorderSizePixel = 0
				toggle.Box.Size = UDim2.fromOffset(14, 14)
				toggle.Box.Position = UDim2.fromOffset(0, 1)
				toggle.Box.AutoButtonColor = false
				toggle.Box.ZIndex = 6
				toggle.Box.Text = ""
				local boxCorner = Instance.new("UICorner", toggle.Box) ; boxCorner.CornerRadius = UDim.new(0, 3)
				local boxStroke = Instance.new("UIStroke", toggle.Box)
				boxStroke.Color = Color3.fromRGB(60, 60, 60) ; boxStroke.Thickness = 1

				-- Coche intérieure
				toggle.Check = Instance.new("Frame", toggle.Box)
				toggle.Check.BackgroundColor3 = window.theme.accentcolor
				toggle.Check.BorderSizePixel = 0
				toggle.Check.ZIndex = 7
				toggle.Check.Size = UDim2.fromOffset(8, 8)
				toggle.Check.Position = UDim2.fromOffset(3, 3)
				toggle.Check.Visible = false
				local cc = Instance.new("UICorner", toggle.Check) ; cc.CornerRadius = UDim.new(0, 2)
				updateevent.Event:Connect(function(theme) toggle.Check.BackgroundColor3 = theme.accentcolor end)

				toggle.Label = Instance.new("TextButton", container)
				toggle.Label.AutoButtonColor = false
				toggle.Label.BackgroundTransparency = 1
				toggle.Label.Position = UDim2.fromOffset(22, 0)
				toggle.Label.Size = UDim2.fromOffset(sectorW - 80, 16)
				toggle.Label.Font = Enum.Font.Gotham
				toggle.Label.ZIndex = 6
				toggle.Label.Text = toggle.text
				toggle.Label.TextColor3 = window.theme.itemscolor
				toggle.Label.TextSize = 12
				toggle.Label.TextStrokeTransparency = 1
				toggle.Label.TextXAlignment = Enum.TextXAlignment.Left
				updateevent.Event:Connect(function(theme)
					toggle.Label.TextColor3 = toggle.value and theme.itemscolor2 or theme.itemscolor
					toggle.Label.Font = theme.font
				end)

				toggle.Items = Instance.new("Frame", container)
				toggle.Items.Name = "items"
				toggle.Items.ZIndex = 5
				toggle.Items.Size = UDim2.fromOffset(60, 16)
				toggle.Items.BackgroundTransparency = 1
				toggle.Items.BorderSizePixel = 0
				toggle.Items.Position = UDim2.fromOffset(sectorW - 20 - 60, 0)

				toggle.ListLayout = Instance.new("UIListLayout", toggle.Items)
				toggle.ListLayout.FillDirection = Enum.FillDirection.Horizontal
				toggle.ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
				toggle.ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
				toggle.ListLayout.Padding = UDim.new(0, 4)

				if toggle.flag and toggle.flag ~= "" then library.flags[toggle.flag] = toggle.default end

				function toggle:Set(value)
					toggle.value = value
					toggle.Check.Visible = value
					if value then
						boxStroke.Color = window.theme.accentcolor
					else
						boxStroke.Color = Color3.fromRGB(60, 60, 60)
					end
					toggle.Label.TextColor3 = value and window.theme.itemscolor2 or window.theme.itemscolor
					if toggle.flag and toggle.flag ~= "" then library.flags[toggle.flag] = value end
					pcall(toggle.callback, value)
				end
				function toggle:Get() return toggle.value end
				toggle:Set(toggle.default)

				local function clickToggle()
					toggle:Set(not toggle.value)
				end
				toggle.Box.MouseButton1Down:Connect(clickToggle)
				toggle.Label.InputBegan:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 then clickToggle() end
				end)

				-- ── toggle:AddKeybind ──
				function toggle:AddKeybind(default, flag)
					local keybind = { }
					keybind.default = default or "None" ; keybind.value = keybind.default
					keybind.flag    = flag or ((toggle.text or "") .. tostring(#toggle.Items:GetChildren()))

					local displayText = keybindToText(keybind.default)
					keybind.Main = Instance.new("TextButton", toggle.Items)
					keybind.Main.BackgroundTransparency = 1 ; keybind.Main.BorderSizePixel = 0
					keybind.Main.ZIndex = 6
					keybind.Main.Text = displayText
					keybind.Main.Font = Enum.Font.Gotham
					keybind.Main.TextColor3 = Color3.fromRGB(100, 100, 100)
					keybind.Main.TextSize = 11
					keybind.Main.TextXAlignment = Enum.TextXAlignment.Right
					keybind.Main.Size = UDim2.fromOffset(54, 16)
					keybind.Main.MouseButton1Down:Connect(function()
						keybind.Main.Text = "[...]"
						keybind.Main.TextColor3 = window.theme.accentcolor
					end)

					if keybind.flag and keybind.flag ~= "" then library.flags[keybind.flag] = keybind.default end
					function keybind:Set(value)
						keybind.value = value ; keybind.Main.Text = keybindToText(value)
						if keybind.flag and keybind.flag ~= "" then library.flags[keybind.flag] = value end
					end
					function keybind:Get() return keybind.value end

					uis.InputBegan:Connect(function(input, gp)
						if not gp then
							if keybind.Main.Text == "[...]" then
								keybind.Main.TextColor3 = Color3.fromRGB(100,100,100)
								keybind:Set(inputToKeybindValue(input))
							else
								if inputMatchesKeybind(input, keybind.value) then toggle:Set(not toggle.value) end
							end
						end
					end)
					table.insert(library.items, keybind) ; return keybind
				end

				-- ── toggle:AddColorpicker (inline, style Photon : petit carré de couleur) ──
				function toggle:AddColorpicker(default, callback, flag)
					local cp = { }
					cp.callback = callback or function() end
					cp.default  = default or Color3.fromRGB(255, 255, 255)
					cp.value    = cp.default
					cp.flag     = flag or ((toggle.text or "") .. tostring(#toggle.Items:GetChildren()))

					cp.Swatch = Instance.new("TextButton", toggle.Items)
					cp.Swatch.BorderSizePixel = 0
					cp.Swatch.BackgroundColor3 = cp.default
					cp.Swatch.ZIndex = 6
					cp.Swatch.Size = UDim2.fromOffset(14, 14)
					cp.Swatch.Position = UDim2.fromOffset(0, 1)
					cp.Swatch.Text = ""
					cp.Swatch.AutoButtonColor = false
					local sc = Instance.new("UICorner", cp.Swatch) ; sc.CornerRadius = UDim.new(0, 3)
					local ss = Instance.new("UIStroke", cp.Swatch) ; ss.Color = Color3.fromRGB(60,60,60) ; ss.Thickness = 1

					-- Picker popup
					cp.Picker = Instance.new("TextButton", cp.Swatch)
					cp.Picker.Name = "picker" ; cp.Picker.ZIndex = 100
					cp.Picker.Visible = false ; cp.Picker.AutoButtonColor = false
					cp.Picker.Text = "" ; cp.Picker.Size = UDim2.fromOffset(180, 196)
					cp.Picker.BorderSizePixel = 0
					cp.Picker.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
					cp.Picker.Position = UDim2.fromOffset(-180 + 14, 18)
					local pc = Instance.new("UICorner", cp.Picker) ; pc.CornerRadius = UDim.new(0, 5)
					local ps = Instance.new("UIStroke", cp.Picker) ; ps.Color = Color3.fromRGB(50,50,50) ; ps.Thickness = 1
					window.OpenedColorPickers[cp.Picker] = false

					cp.hue = Instance.new("ImageLabel", cp.Picker)
					cp.hue.ZIndex = 101 ; cp.hue.Position = UDim2.new(0,5,0,5)
					cp.hue.Size = UDim2.new(0,170,0,170)
					cp.hue.Image = "rbxassetid://4155801252"
					cp.hue.ScaleType = Enum.ScaleType.Stretch
					cp.hue.BackgroundColor3 = Color3.new(1,0,0)
					cp.hue.BorderSizePixel = 0

					cp.hueselectorpointer = Instance.new("ImageLabel", cp.Picker)
					cp.hueselectorpointer.ZIndex = 102 ; cp.hueselectorpointer.BackgroundTransparency = 1
					cp.hueselectorpointer.BorderSizePixel = 0 ; cp.hueselectorpointer.Size = UDim2.fromOffset(7,7)
					cp.hueselectorpointer.Image = "rbxassetid://6885856475"

					cp.selector = Instance.new("TextLabel", cp.Picker)
					cp.selector.ZIndex = 100 ; cp.selector.Position = UDim2.new(0,5,0,181)
					cp.selector.Size = UDim2.new(0,170,0,10)
					cp.selector.BackgroundColor3 = Color3.fromRGB(255,255,255)
					cp.selector.BorderSizePixel = 0 ; cp.selector.Text = ""
					local sc2 = Instance.new("UICorner", cp.selector) ; sc2.CornerRadius = UDim.new(0, 2)

					cp.gradient = Instance.new("UIGradient", cp.selector)
					cp.gradient.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0,    Color3.new(1,0,0)),
						ColorSequenceKeypoint.new(0.17, Color3.new(1,0,1)),
						ColorSequenceKeypoint.new(0.33, Color3.new(0,0,1)),
						ColorSequenceKeypoint.new(0.5,  Color3.new(0,1,1)),
						ColorSequenceKeypoint.new(0.67, Color3.new(0,1,0)),
						ColorSequenceKeypoint.new(0.83, Color3.new(1,1,0)),
						ColorSequenceKeypoint.new(1,    Color3.new(1,0,0))
					})

					cp.pointer = Instance.new("Frame", cp.selector)
					cp.pointer.ZIndex = 101 ; cp.pointer.BackgroundColor3 = Color3.fromRGB(255,255,255)
					cp.pointer.Position = UDim2.new(0,0,0,0) ; cp.pointer.Size = UDim2.new(0,2,0,10)
					cp.pointer.BorderSizePixel = 0

					if cp.flag and cp.flag ~= "" then library.flags[cp.flag] = cp.default end

					function cp:RefreshHue()
						local x = (mouse.X - cp.hue.AbsolutePosition.X) / cp.hue.AbsoluteSize.X
						local y = (mouse.Y - cp.hue.AbsolutePosition.Y) / cp.hue.AbsoluteSize.Y
						cp.hueselectorpointer:TweenPosition(UDim2.new(math.clamp(x,0,0.95),0,math.clamp(y,0,0.88),0),Enum.EasingDirection.In,Enum.EasingStyle.Sine,0.05)
						cp:Set(Color3.fromHSV(cp.color or 0, math.clamp(x,0,1), 1 - math.clamp(y,0,1)))
					end
					function cp:RefreshSelector()
						local pos = math.clamp((mouse.X - cp.selector.AbsolutePosition.X) / cp.selector.AbsoluteSize.X, 0, 1)
						cp.color = 1 - pos
						cp.pointer:TweenPosition(UDim2.new(pos,0,0,0),Enum.EasingDirection.In,Enum.EasingStyle.Sine,0.05)
						cp.hue.BackgroundColor3 = Color3.fromHSV(1-pos,1,1)
					end
					function cp:Set(value)
						local color = Color3.new(math.clamp(value.r,0,1),math.clamp(value.g,0,1),math.clamp(value.b,0,1))
						cp.value = color
						cp.Swatch.BackgroundColor3 = color
						if cp.flag and cp.flag ~= "" then library.flags[cp.flag] = color end
						pcall(cp.callback, color)
					end
					function cp:Get() return cp.value end
					cp:Set(cp.default)

					local dh, ds = false, false
					cp.selector.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then ds=true;cp:RefreshSelector() end end)
					cp.selector.InputEnded:Connect(function(i)  if i.UserInputType==Enum.UserInputType.MouseButton1 then ds=false end end)
					cp.hue.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dh=true;cp:RefreshHue() end end)
					cp.hue.InputEnded:Connect(function(i)  if i.UserInputType==Enum.UserInputType.MouseButton1 then dh=false end end)
					uis.InputChanged:Connect(function(i)
						if ds and i.UserInputType==Enum.UserInputType.MouseMovement then cp:RefreshSelector() end
						if dh and i.UserInputType==Enum.UserInputType.MouseMovement then cp:RefreshHue() end
					end)

					local function openPicker(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 then
							for i,v in pairs(window.OpenedColorPickers) do
								if v and i ~= cp.Picker then i.Visible=false;window.OpenedColorPickers[i]=false end
							end
							cp.Picker.Visible = not cp.Picker.Visible
							window.OpenedColorPickers[cp.Picker] = cp.Picker.Visible
							ss.Color = cp.Picker.Visible and window.theme.accentcolor or Color3.fromRGB(60,60,60)
						end
					end
					cp.Swatch.InputBegan:Connect(openPicker)
					table.insert(library.items, cp) ; return cp
				end

				-- ── toggle:AddSlider ──
				function toggle:AddSlider(min, default, max, decimals, callback, flag)
					local slider = { }
					slider.callback = callback or function() end
					slider.min = min or 0 ; slider.max = max or 100
					slider.decimals = decimals or 1 ; slider.default = default or min or 0
					slider.flag = flag or ((toggle.text or "") .. tostring(#toggle.Items:GetChildren()))
					slider.value = slider.default
					local dragging = false

					slider.Main = Instance.new("TextButton", sector.Items)
					slider.Main.Name = "slider" ; slider.Main.BackgroundColor3 = Color3.fromRGB(28,28,28)
					slider.Main.BorderSizePixel = 0 ; slider.Main.AutoButtonColor = false
					slider.Main.Text = "" ; slider.Main.ZIndex = 6
					slider.Main.Size = UDim2.fromOffset(sectorW-20, 16)
					local slc = Instance.new("UICorner", slider.Main) ; slc.CornerRadius = UDim.new(0,3)

					slider.Fill = Instance.new("Frame", slider.Main)
					slider.Fill.BackgroundColor3 = window.theme.accentcolor
					slider.Fill.BorderSizePixel = 0 ; slider.Fill.ZIndex = 7
					slider.Fill.Size = UDim2.fromOffset(0, 16)
					local sfc = Instance.new("UICorner", slider.Fill) ; sfc.CornerRadius = UDim.new(0,3)
					updateevent.Event:Connect(function(theme) slider.Fill.BackgroundColor3 = theme.accentcolor end)

					slider.InputLabel = makeLabel(slider.Main, "0", Enum.TextXAlignment.Center, Color3.fromRGB(220,220,220), 11, Enum.Font.GothamBold, 8)
					slider.InputLabel.Size = UDim2.fromScale(1,1) ; slider.InputLabel.Selectable = false

					if slider.flag and slider.flag ~= "" then library.flags[slider.flag] = slider.default end
					function slider:Set(value)
						slider.value = math.clamp(math.round(value * slider.decimals) / slider.decimals, slider.min, slider.max)
						local pct = (slider.value - slider.min) / (slider.max - slider.min)
						slider.Fill:TweenSize(UDim2.fromOffset(pct * slider.Main.AbsoluteSize.X, 16), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 0.05)
						slider.InputLabel.Text = slider.value
						if slider.flag and slider.flag ~= "" then library.flags[slider.flag] = slider.value end
						pcall(slider.callback, slider.value)
					end
					function slider:Get() return slider.value end
					slider:Set(slider.default)

					local function refresh()
						local pct = math.clamp((mouse.X - slider.Main.AbsolutePosition.X) / slider.Main.AbsoluteSize.X, 0, 1)
						slider:Set(slider.min + (slider.max - slider.min) * pct)
					end
					slider.Main.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true;refresh() end end)
					slider.Main.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
					uis.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then refresh() end end)

					sector:FixSize() ; table.insert(library.items, slider) ; return slider
				end

				-- ── toggle:AddDropdown ──
				function toggle:AddDropdown(items, default, multichoice, callback, flag)
					-- Réutilise sector:AddDropdown mais sans label séparé
					local dd = sector:AddDropdown(toggle.text, items, default, multichoice, callback, flag)
					return dd
				end

				sector:FixSize() ; table.insert(library.items, toggle) ; return toggle
			end

			-- ================================================================
			-- AddSlider (sector level) — Photon style
			-- ================================================================
			function sector:AddSlider(text, min, default, max, decimals, callback, flag)
				local slider = { }
				slider.text = text or "" ; slider.callback = callback or function() end
				slider.min = min or 0 ; slider.max = max or 100
				slider.decimals = decimals or 1 ; slider.default = default or min or 0
				slider.flag = flag or text or "" ; slider.value = slider.default
				local dragging = false

				local container = makeItemContainer(sector.Items, 32)
				slider.MainBack = container

				slider.LabelRow = Instance.new("Frame", container)
				slider.LabelRow.BackgroundTransparency = 1 ; slider.LabelRow.BorderSizePixel = 0
				slider.LabelRow.ZIndex = 5
				slider.LabelRow.Size = UDim2.fromOffset(sectorW - 20, 14)
				slider.LabelRow.Position = UDim2.fromOffset(0, 0)

				slider.Label = makeLabel(slider.LabelRow, slider.text, Enum.TextXAlignment.Left, window.theme.itemscolor, 12, Enum.Font.Gotham)
				slider.Label.Size = UDim2.fromScale(0.7, 1) ; slider.Label.Position = UDim2.fromOffset(0, 0)

				slider.ValLabel = makeLabel(slider.LabelRow, tostring(slider.default), Enum.TextXAlignment.Right, window.theme.accentcolor, 12, Enum.Font.GothamBold)
				slider.ValLabel.Size = UDim2.fromScale(1, 1) ; slider.ValLabel.Position = UDim2.fromOffset(0, 0)
				updateevent.Event:Connect(function(theme) slider.ValLabel.TextColor3 = theme.accentcolor end)

				slider.Main = Instance.new("TextButton", container)
				slider.Main.Name = "slider" ; slider.Main.BackgroundColor3 = Color3.fromRGB(28,28,28)
				slider.Main.BorderSizePixel = 0 ; slider.Main.AutoButtonColor = false
				slider.Main.Text = "" ; slider.Main.ZIndex = 6
				slider.Main.Size = UDim2.fromOffset(sectorW - 20, 6)
				slider.Main.Position = UDim2.fromOffset(0, 18)
				local slc = Instance.new("UICorner", slider.Main) ; slc.CornerRadius = UDim.new(0, 3)

				slider.Fill = Instance.new("Frame", slider.Main)
				slider.Fill.BackgroundColor3 = window.theme.accentcolor
				slider.Fill.BorderSizePixel = 0 ; slider.Fill.ZIndex = 7
				slider.Fill.Size = UDim2.fromOffset(0, 6)
				local sfc = Instance.new("UICorner", slider.Fill) ; sfc.CornerRadius = UDim.new(0, 3)
				updateevent.Event:Connect(function(theme) slider.Fill.BackgroundColor3 = theme.accentcolor end)

				-- Thumb
				slider.Thumb = Instance.new("Frame", slider.Main)
				slider.Thumb.BackgroundColor3 = Color3.fromRGB(220,220,220)
				slider.Thumb.BorderSizePixel = 0 ; slider.Thumb.ZIndex = 8
				slider.Thumb.Size = UDim2.fromOffset(8, 8)
				slider.Thumb.Position = UDim2.fromOffset(-4, -1)
				local tc = Instance.new("UICorner", slider.Thumb) ; tc.CornerRadius = UDim.new(1, 0)

				if slider.flag and slider.flag ~= "" then library.flags[slider.flag] = slider.default end

				function slider:Set(value)
					slider.value = math.clamp(math.round(value * slider.decimals) / slider.decimals, slider.min, slider.max)
					local pct = (slider.value - slider.min) / (slider.max - slider.min)
					local px = pct * slider.Main.AbsoluteSize.X
					slider.Fill:TweenSize(UDim2.fromOffset(px, 6), Enum.EasingDirection.In, Enum.EasingStyle.Linear, 0.04)
					slider.Thumb:TweenPosition(UDim2.fromOffset(px - 4, -1), Enum.EasingDirection.In, Enum.EasingStyle.Linear, 0.04)
					slider.ValLabel.Text = slider.value
					if slider.flag and slider.flag ~= "" then library.flags[slider.flag] = slider.value end
					pcall(slider.callback, slider.value)
				end
				function slider:Get() return slider.value end
				slider:Set(slider.default)

				local function refresh()
					local pct = math.clamp((mouse.X - slider.Main.AbsolutePosition.X) / slider.Main.AbsoluteSize.X, 0, 1)
					slider:Set(slider.min + (slider.max - slider.min) * pct)
				end
				slider.Main.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true;refresh() end end)
				slider.Main.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
				uis.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then refresh() end end)

				sector:FixSize() ; table.insert(library.items, slider) ; return slider
			end

			-- ================================================================
			-- AddColorpicker (sector level)
			-- ================================================================
			function sector:AddColorpicker(text, default, callback, flag)
				local cp = { }
				cp.text = text or "" ; cp.callback = callback or function() end
				cp.default = default or Color3.fromRGB(255,255,255)
				cp.value = cp.default ; cp.flag = flag or text or ""

				local container = makeItemContainer(sector.Items, 16)
				cp.Main = container

				cp.Label = makeLabel(container, cp.text, Enum.TextXAlignment.Left, window.theme.itemscolor, 12, Enum.Font.Gotham)
				cp.Label.Size = UDim2.fromOffset(sectorW - 50, 16)
				updateevent.Event:Connect(function(theme) cp.Label.TextColor3 = theme.itemscolor ; cp.Label.Font = theme.font end)

				cp.Swatch = Instance.new("TextButton", container)
				cp.Swatch.BorderSizePixel = 0 ; cp.Swatch.BackgroundColor3 = cp.default
				cp.Swatch.ZIndex = 6 ; cp.Swatch.Size = UDim2.fromOffset(28, 14)
				cp.Swatch.Position = UDim2.fromOffset(sectorW - 20 - 28, 1)
				cp.Swatch.Text = "" ; cp.Swatch.AutoButtonColor = false
				local sc = Instance.new("UICorner", cp.Swatch) ; sc.CornerRadius = UDim.new(0, 3)
				local ss = Instance.new("UIStroke", cp.Swatch) ; ss.Color = Color3.fromRGB(60,60,60) ; ss.Thickness = 1

				cp.Picker = Instance.new("TextButton", cp.Swatch)
				cp.Picker.Name = "picker" ; cp.Picker.ZIndex = 100
				cp.Picker.Visible = false ; cp.Picker.AutoButtonColor = false
				cp.Picker.Text = "" ; cp.Picker.Size = UDim2.fromOffset(180, 196)
				cp.Picker.BorderSizePixel = 0 ; cp.Picker.BackgroundColor3 = Color3.fromRGB(30,30,30)
				cp.Picker.Position = UDim2.fromOffset(-180 + 28, 18)
				local pc = Instance.new("UICorner", cp.Picker) ; pc.CornerRadius = UDim.new(0, 5)
				local ps = Instance.new("UIStroke", cp.Picker) ; ps.Color = Color3.fromRGB(50,50,50) ; ps.Thickness = 1
				window.OpenedColorPickers[cp.Picker] = false

				cp.hue = Instance.new("ImageLabel", cp.Picker)
				cp.hue.ZIndex = 101 ; cp.hue.Position = UDim2.new(0,5,0,5)
				cp.hue.Size = UDim2.new(0,170,0,170)
				cp.hue.Image = "rbxassetid://4155801252"
				cp.hue.ScaleType = Enum.ScaleType.Stretch
				cp.hue.BackgroundColor3 = Color3.new(1,0,0) ; cp.hue.BorderSizePixel = 0

				cp.hueselectorpointer = Instance.new("ImageLabel", cp.Picker)
				cp.hueselectorpointer.ZIndex = 102 ; cp.hueselectorpointer.BackgroundTransparency = 1
				cp.hueselectorpointer.BorderSizePixel = 0 ; cp.hueselectorpointer.Size = UDim2.fromOffset(7,7)
				cp.hueselectorpointer.Image = "rbxassetid://6885856475"

				cp.selector = Instance.new("TextLabel", cp.Picker)
				cp.selector.ZIndex = 100 ; cp.selector.Position = UDim2.new(0,5,0,181)
				cp.selector.Size = UDim2.new(0,170,0,10)
				cp.selector.BackgroundColor3 = Color3.fromRGB(255,255,255)
				cp.selector.BorderSizePixel = 0 ; cp.selector.Text = ""
				local sc2 = Instance.new("UICorner", cp.selector) ; sc2.CornerRadius = UDim.new(0,2)

				cp.gradient = Instance.new("UIGradient", cp.selector)
				cp.gradient.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.new(1,0,0)), ColorSequenceKeypoint.new(0.17, Color3.new(1,0,1)),
					ColorSequenceKeypoint.new(0.33, Color3.new(0,0,1)), ColorSequenceKeypoint.new(0.5, Color3.new(0,1,1)),
					ColorSequenceKeypoint.new(0.67, Color3.new(0,1,0)), ColorSequenceKeypoint.new(0.83, Color3.new(1,1,0)),
					ColorSequenceKeypoint.new(1, Color3.new(1,0,0))
				})

				cp.pointer = Instance.new("Frame", cp.selector)
				cp.pointer.ZIndex = 101 ; cp.pointer.BackgroundColor3 = Color3.fromRGB(255,255,255)
				cp.pointer.Position = UDim2.new(0,0,0,0) ; cp.pointer.Size = UDim2.new(0,2,0,10)
				cp.pointer.BorderSizePixel = 0

				if cp.flag and cp.flag ~= "" then library.flags[cp.flag] = cp.default end

				function cp:RefreshHue()
					local x = (mouse.X - cp.hue.AbsolutePosition.X) / cp.hue.AbsoluteSize.X
					local y = (mouse.Y - cp.hue.AbsolutePosition.Y) / cp.hue.AbsoluteSize.Y
					cp.hueselectorpointer:TweenPosition(UDim2.new(math.clamp(x,0,0.95),0,math.clamp(y,0,0.88),0),Enum.EasingDirection.In,Enum.EasingStyle.Sine,0.05)
					cp:Set(Color3.fromHSV(cp.color or 0, math.clamp(x,0,1), 1 - math.clamp(y,0,1)))
				end
				function cp:RefreshSelector()
					local pos = math.clamp((mouse.X - cp.selector.AbsolutePosition.X) / cp.selector.AbsoluteSize.X, 0, 1)
					cp.color = 1 - pos
					cp.pointer:TweenPosition(UDim2.new(pos,0,0,0),Enum.EasingDirection.In,Enum.EasingStyle.Sine,0.05)
					cp.hue.BackgroundColor3 = Color3.fromHSV(1-pos,1,1)
				end
				function cp:Set(value)
					local color = Color3.new(math.clamp(value.r,0,1),math.clamp(value.g,0,1),math.clamp(value.b,0,1))
					cp.value = color ; cp.Swatch.BackgroundColor3 = color
					if cp.flag and cp.flag ~= "" then library.flags[cp.flag] = color end
					pcall(cp.callback, color)
				end
				function cp:Get() return cp.value end
				cp:Set(cp.default)

				local dh, ds = false, false
				cp.selector.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then ds=true;cp:RefreshSelector() end end)
				cp.selector.InputEnded:Connect(function(i)  if i.UserInputType==Enum.UserInputType.MouseButton1 then ds=false end end)
				cp.hue.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dh=true;cp:RefreshHue() end end)
				cp.hue.InputEnded:Connect(function(i)  if i.UserInputType==Enum.UserInputType.MouseButton1 then dh=false end end)
				uis.InputChanged:Connect(function(i)
					if ds and i.UserInputType==Enum.UserInputType.MouseMovement then cp:RefreshSelector() end
					if dh and i.UserInputType==Enum.UserInputType.MouseMovement then cp:RefreshHue() end
				end)
				local function openPicker(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						for i,v in pairs(window.OpenedColorPickers) do
							if v and i ~= cp.Picker then i.Visible=false;window.OpenedColorPickers[i]=false end
						end
						cp.Picker.Visible = not cp.Picker.Visible
						window.OpenedColorPickers[cp.Picker] = cp.Picker.Visible
						ss.Color = cp.Picker.Visible and window.theme.accentcolor or Color3.fromRGB(60,60,60)
					end
				end
				cp.Swatch.InputBegan:Connect(openPicker)
				sector:FixSize() ; table.insert(library.items, cp) ; return cp
			end

			-- ================================================================
			-- AddKeybind (sector level)
			-- ================================================================
			function sector:AddKeybind(text, default, newkeycallback, callback, flag)
				local keybind = { }
				keybind.text = text or "" ; keybind.default = default or "None"
				keybind.callback = callback or function() end
				keybind.newkeycallback = newkeycallback or function() end
				keybind.flag = flag or text or "" ; keybind.value = keybind.default

				local container = makeItemContainer(sector.Items, 16)
				keybind.Main = container

				keybind.Label = makeLabel(container, keybind.text, Enum.TextXAlignment.Left, window.theme.itemscolor, 12, Enum.Font.Gotham)
				keybind.Label.Size = UDim2.fromOffset(sectorW - 80, 16)
				updateevent.Event:Connect(function(theme) keybind.Label.TextColor3 = theme.itemscolor ; keybind.Label.Font = theme.font end)

				keybind.Bind = Instance.new("TextButton", container)
				keybind.Bind.BackgroundColor3 = Color3.fromRGB(28,28,28)
				keybind.Bind.BorderSizePixel = 0 ; keybind.Bind.ZIndex = 6
				keybind.Bind.Font = Enum.Font.GothamBold ; keybind.Bind.TextColor3 = Color3.fromRGB(180,180,180)
				keybind.Bind.TextSize = 11
				keybind.Bind.Text = keybindToText(keybind.default)
				keybind.Bind.AutoButtonColor = false
				keybind.Bind.Size = UDim2.fromOffset(60, 16)
				keybind.Bind.Position = UDim2.fromOffset(sectorW - 20 - 60, 0)
				local kbc = Instance.new("UICorner", keybind.Bind) ; kbc.CornerRadius = UDim.new(0,3)
				local kbs = Instance.new("UIStroke", keybind.Bind) ; kbs.Color = Color3.fromRGB(50,50,50) ; kbs.Thickness = 1

				keybind.Bind.MouseButton1Down:Connect(function()
					keybind.Bind.Text = "[...]"
					keybind.Bind.TextColor3 = window.theme.accentcolor
				end)

				if keybind.flag and keybind.flag ~= "" then library.flags[keybind.flag] = keybind.default end
				function keybind:Set(value)
					keybind.value = value ; keybind.Bind.Text = keybindToText(value)
					keybind.Bind.TextColor3 = Color3.fromRGB(180,180,180)
					if keybind.flag and keybind.flag ~= "" then library.flags[keybind.flag] = value end
					pcall(keybind.newkeycallback, value)
				end
				function keybind:Get() return keybind.value end
				keybind:Set(keybind.default)

				uis.InputBegan:Connect(function(input, gp)
					if not gp then
						if keybind.Bind.Text == "[...]" then
							keybind:Set(inputToKeybindValue(input))
						else
							if inputMatchesKeybind(input, keybind.value) then pcall(keybind.callback) end
						end
					end
				end)
				sector:FixSize() ; table.insert(library.items, keybind) ; return keybind
			end

			-- ================================================================
			-- AddDropdown (sector level) — Photon style
			-- ================================================================
			function sector:AddDropdown(text, items, default, multichoice, callback, flag)
				local dropdown = { }
				dropdown.text = text or "" ; dropdown.defaultitems = items or {}
				dropdown.default = default ; dropdown.callback = callback or function() end
				dropdown.multichoice = multichoice or false ; dropdown.values = {}
				dropdown.flag = flag or text or ""

				local container = makeItemContainer(sector.Items, 32)
				dropdown.MainBack = container

				dropdown.Label = makeLabel(container, dropdown.text, Enum.TextXAlignment.Left, window.theme.itemscolor, 12, Enum.Font.Gotham)
				dropdown.Label.Size = UDim2.fromOffset(sectorW - 20, 14)
				dropdown.Label.Position = UDim2.fromOffset(0, 0)
				updateevent.Event:Connect(function(theme) dropdown.Label.TextColor3 = theme.itemscolor ; dropdown.Label.Font = theme.font end)

				dropdown.Main = Instance.new("TextButton", container)
				dropdown.Main.BackgroundColor3 = Color3.fromRGB(28,28,28)
				dropdown.Main.BorderSizePixel = 0 ; dropdown.Main.AutoButtonColor = false
				dropdown.Main.Text = "" ; dropdown.Main.ZIndex = 6
				dropdown.Main.Size = UDim2.fromOffset(sectorW - 20, 18)
				dropdown.Main.Position = UDim2.fromOffset(0, 16)
				local ddc = Instance.new("UICorner", dropdown.Main) ; ddc.CornerRadius = UDim.new(0, 4)
				local dds = Instance.new("UIStroke", dropdown.Main) ; dds.Color = Color3.fromRGB(50,50,50) ; dds.Thickness = 1

				dropdown.SelectedLabel = makeLabel(dropdown.Main, dropdown.text, Enum.TextXAlignment.Left, Color3.fromRGB(180,180,180), 11, Enum.Font.Gotham, 7)
				dropdown.SelectedLabel.Size = UDim2.fromOffset(sectorW - 55, 18)
				dropdown.SelectedLabel.Position = UDim2.fromOffset(8, 0)

				dropdown.Arrow = Instance.new("TextLabel", dropdown.Main)
				dropdown.Arrow.BackgroundTransparency = 1 ; dropdown.Arrow.BorderSizePixel = 0
				dropdown.Arrow.ZIndex = 7 ; dropdown.Arrow.Text = "▾"
				dropdown.Arrow.Font = Enum.Font.GothamBold ; dropdown.Arrow.TextSize = 12
				dropdown.Arrow.TextColor3 = Color3.fromRGB(140,140,140)
				dropdown.Arrow.Size = UDim2.fromOffset(16, 18)
				dropdown.Arrow.Position = UDim2.new(1, -20, 0, 0)
				dropdown.Arrow.TextXAlignment = Enum.TextXAlignment.Center

				dropdown.ItemsFrame = Instance.new("ScrollingFrame", dropdown.Main)
				dropdown.ItemsFrame.BackgroundColor3 = Color3.fromRGB(24,24,24)
				dropdown.ItemsFrame.BorderSizePixel = 0 ; dropdown.ItemsFrame.ZIndex = 12
				dropdown.ItemsFrame.ScrollBarThickness = 2
				dropdown.ItemsFrame.ScrollingDirection = "Y"
				dropdown.ItemsFrame.Visible = false
				dropdown.ItemsFrame.Position = UDim2.fromOffset(0, 22)
				dropdown.ItemsFrame.Size = UDim2.fromOffset(0, 0)
				dropdown.ItemsFrame.CanvasSize = UDim2.fromOffset(0, 0)
				local dfc = Instance.new("UICorner", dropdown.ItemsFrame) ; dfc.CornerRadius = UDim.new(0,4)
				local dfs = Instance.new("UIStroke", dropdown.ItemsFrame) ; dfs.Color = Color3.fromRGB(50,50,50) ; dfs.Thickness = 1

				dropdown.ListLayout = Instance.new("UIListLayout", dropdown.ItemsFrame)
				dropdown.ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
				local dlp = Instance.new("UIPadding", dropdown.ItemsFrame)
				dlp.PaddingTop = UDim.new(0,3) ; dlp.PaddingBottom = UDim.new(0,3)
				dlp.PaddingLeft = UDim.new(0,3) ; dlp.PaddingRight = UDim.new(0,3)

				if dropdown.flag and dropdown.flag ~= "" then
					library.flags[dropdown.flag] = dropdown.multichoice and {dropdown.default or dropdown.defaultitems[1] or ""} or (dropdown.default or dropdown.defaultitems[1] or "")
				end

				dropdown.Changed = Instance.new("BindableEvent")
				function dropdown:isSelected(item) for _,v in pairs(dropdown.values) do if v==item then return true end end return false end
				function dropdown:updateText(text)
					if #text >= 25 then text = text:sub(1,23) .. ".." end
					dropdown.SelectedLabel.Text = text
				end
				function dropdown:Set(value)
					if type(value)=="table" then
						dropdown.values=value ; dropdown:updateText(table.concat(value,", ")) ; pcall(dropdown.callback,value)
					else
						dropdown:updateText(value) ; dropdown.values={value} ; pcall(dropdown.callback,value)
					end
					dropdown.Changed:Fire(value)
					if dropdown.flag and dropdown.flag~="" then
						library.flags[dropdown.flag]=dropdown.multichoice and dropdown.values or dropdown.values[1]
					end
				end
				function dropdown:Get() return dropdown.multichoice and dropdown.values or dropdown.values[1] end

				dropdown.items = {}
				function dropdown:Add(v)
					local Item = Instance.new("TextButton", dropdown.ItemsFrame)
					Item.BackgroundColor3 = Color3.fromRGB(28,28,28) ; Item.TextColor3 = Color3.fromRGB(180,180,180)
					Item.BorderSizePixel=0 ; Item.Size=UDim2.fromOffset(sectorW-26,18)
					Item.ZIndex=13 ; Item.Text=v ; Item.Name=v ; Item.AutoButtonColor=false
					Item.Font=Enum.Font.Gotham ; Item.TextSize=11 ; Item.TextXAlignment=Enum.TextXAlignment.Left
					local ic = Instance.new("UICorner", Item) ; ic.CornerRadius = UDim.new(0,3)

					Item.MouseButton1Down:Connect(function()
						if dropdown.multichoice then
							if dropdown:isSelected(v) then
								for i2,v2 in pairs(dropdown.values) do if v2==v then table.remove(dropdown.values,i2) end end
								dropdown:Set(dropdown.values)
							else table.insert(dropdown.values,v) ; dropdown:Set(dropdown.values) end
							return
						else
							dropdown.Arrow.Text = "▾"
							dropdown.ItemsFrame.Visible=false
						end
						dropdown:Set(v)
					end)

					runservice.RenderStepped:Connect(function()
						if (dropdown.multichoice and dropdown:isSelected(v)) or dropdown.values[1]==v then
							Item.BackgroundColor3=Color3.fromRGB(40,40,40) ; Item.TextColor3=window.theme.accentcolor
						else
							Item.BackgroundColor3=Color3.fromRGB(28,28,28) ; Item.TextColor3=Color3.fromRGB(180,180,180)
						end
					end)

					table.insert(dropdown.items, v)
					local itemH = 18
					dropdown.ItemsFrame.Size = UDim2.fromOffset(sectorW-20, math.clamp(#dropdown.items*itemH, itemH, 120) + 6)
					dropdown.ItemsFrame.CanvasSize = UDim2.fromOffset(0, #dropdown.items*itemH+6)
					-- Mettre à jour la taille du container
					container.Size = UDim2.fromOffset(sectorW-20, 34 + (dropdown.ItemsFrame.Visible and dropdown.ItemsFrame.Size.Y.Offset or 0))
				end

				function dropdown:Remove(value)
					local item = dropdown.ItemsFrame:FindFirstChild(value)
					if item then
						for i,v in pairs(dropdown.items) do if v==value then table.remove(dropdown.items,i) end end
						local itemH = 18
						dropdown.ItemsFrame.Size = UDim2.fromOffset(sectorW-20, math.clamp(#dropdown.items*itemH,itemH,120)+6)
						dropdown.ItemsFrame.CanvasSize = UDim2.fromOffset(0, #dropdown.items*itemH+6)
						item:Destroy()
					end
				end

				local function toggleDropdown()
					dropdown.ItemsFrame.Visible = not dropdown.ItemsFrame.Visible
					dropdown.Arrow.Text = dropdown.ItemsFrame.Visible and "▴" or "▾"
					container.Size = UDim2.fromOffset(sectorW-20, 34 + (dropdown.ItemsFrame.Visible and dropdown.ItemsFrame.Size.Y.Offset or 0))
					sector:FixSize()
				end

				dropdown.Main.MouseButton1Down:Connect(toggleDropdown)
				dropdown.Main.MouseEnter:Connect(function() dds.Color = window.theme.accentcolor end)
				dropdown.Main.MouseLeave:Connect(function() dds.Color = Color3.fromRGB(50,50,50) end)

				for _,v in pairs(dropdown.defaultitems) do dropdown:Add(v) end
				if dropdown.default then dropdown:Set(dropdown.default) end

				sector:FixSize() ; table.insert(library.items, dropdown) ; return dropdown
			end

			-- ================================================================
			-- AddTextbox (sector level)
			-- ================================================================
			function sector:AddTextbox(text, default, callback, flag)
				local textbox = { }
				textbox.text = text or "" ; textbox.callback = callback or function() end
				textbox.default = default ; textbox.value = "" ; textbox.flag = flag or text or ""

				local container = makeItemContainer(sector.Items, 32)

				textbox.Label = makeLabel(container, textbox.text, Enum.TextXAlignment.Left, window.theme.itemscolor, 12, Enum.Font.Gotham)
				textbox.Label.Size = UDim2.fromOffset(sectorW-20, 14)
				textbox.Label.Position = UDim2.fromOffset(0, 0)
				updateevent.Event:Connect(function(theme) textbox.Label.TextColor3 = theme.itemscolor ; textbox.Label.Font = theme.font end)

				textbox.Box = Instance.new("TextBox", container)
				textbox.Box.BackgroundColor3 = Color3.fromRGB(28,28,28)
				textbox.Box.BorderSizePixel = 0 ; textbox.Box.Text = "" ; textbox.Box.ZIndex = 6
				textbox.Box.PlaceholderText = textbox.text ; textbox.Box.PlaceholderColor3 = Color3.fromRGB(90,90,90)
				textbox.Box.Font = Enum.Font.Gotham ; textbox.Box.TextSize = 11
				textbox.Box.TextColor3 = Color3.fromRGB(200,200,200)
				textbox.Box.ClearTextOnFocus = false ; textbox.Box.MultiLine = false
				textbox.Box.TextXAlignment = Enum.TextXAlignment.Left
				textbox.Box.Size = UDim2.fromOffset(sectorW-20, 18)
				textbox.Box.Position = UDim2.fromOffset(0, 16)
				local tbc = Instance.new("UICorner", textbox.Box) ; tbc.CornerRadius = UDim.new(0,4)
				local tbs = Instance.new("UIStroke", textbox.Box) ; tbs.Color = Color3.fromRGB(50,50,50) ; tbs.Thickness = 1
				local tbp = Instance.new("UIPadding", textbox.Box) ; tbp.PaddingLeft = UDim.new(0,6)

				textbox.Box.Focused:Connect(function() tbs.Color = window.theme.accentcolor end)
				textbox.Box.FocusLost:Connect(function()
					tbs.Color = Color3.fromRGB(50,50,50)
					textbox:Set(textbox.Box.Text)
				end)

				if textbox.flag and textbox.flag ~= "" then library.flags[textbox.flag] = textbox.default or "" end
				function textbox:Set(t) textbox.value=t ; textbox.Box.Text=t ; if textbox.flag~="" then library.flags[textbox.flag]=t end ; pcall(textbox.callback,t) end
				function textbox:Get() return textbox.value end
				if textbox.default then textbox:Set(textbox.default) end

				sector:FixSize() ; table.insert(library.items, textbox) ; return textbox
			end

			-- ================================================================
			-- AddSeperator
			-- ================================================================
			function sector:AddSeperator(text)
				local sep = {}
				local container = makeItemContainer(sector.Items, 12)
				sep.main = container

				sep.line = Instance.new("Frame", container)
				sep.line.BackgroundColor3 = Color3.fromRGB(50,50,50)
				sep.line.BorderSizePixel = 0 ; sep.line.ZIndex = 6
				sep.line.Size = UDim2.fromOffset(sectorW-20, 1)
				sep.line.Position = UDim2.fromOffset(0, 6)

				if text and text ~= "" then
					local ts = textservice:GetTextSize(text, 11, Enum.Font.GothamBold, Vector2.new(2000,2000))
					local bg = Instance.new("Frame", sep.line)
					bg.BackgroundColor3 = window.theme.sectorcolor ; bg.BorderSizePixel=0 ; bg.ZIndex=7
					bg.Size = UDim2.fromOffset(ts.X+10, 12)
					bg.Position = UDim2.new(0.5,-ts.X/2-5,-6,0)
					updateevent.Event:Connect(function(theme) bg.BackgroundColor3 = theme.sectorcolor end)

					local l = makeLabel(bg, text, Enum.TextXAlignment.Center, Color3.fromRGB(140,140,140), 11, Enum.Font.GothamBold, 8)
					l.Size = UDim2.fromScale(1,1)
				end

				sector:FixSize() ; return sep
			end

			return sector
		end

		table.insert(window.Tabs, tab)
		return tab
	end

	-- ================================================================
	-- Onglet ⚙ settings automatique
	-- ================================================================
	local settingsTab = window:CreateTab("⚙ Settings")
	local settingsSector = settingsTab:CreateSector("Keybind", "left")
	settingsSector:AddKeybind("Hide/Show", window.hidekey,
		function(newKey) if newKey ~= "None" then window.hidekey = newKey end end,
		function() end, "settings_hide_key"
	)
	local colorSectorL = settingsTab:CreateSector("Interface Colors", "left")
	colorSectorL:AddColorpicker("Accent Color",  window.theme.accentcolor,     function(c) window.theme.accentcolor=c     ; window:UpdateTheme(window.theme) end, "settings_accentcolor")
	colorSectorL:AddColorpicker("Accent 2",      window.theme.accentcolor2,    function(c) window.theme.accentcolor2=c    ; window:UpdateTheme(window.theme) end, "settings_accentcolor2")
	colorSectorL:AddColorpicker("Background",    window.theme.backgroundcolor, function(c) window.theme.backgroundcolor=c ; window:UpdateTheme(window.theme) end, "settings_backgroundcolor")
	colorSectorL:AddColorpicker("Sector Color",  window.theme.sectorcolor,     function(c) window.theme.sectorcolor=c    ; window:UpdateTheme(window.theme) end, "settings_sectorcolor")
	local colorSectorR = settingsTab:CreateSector("Text Colors", "right")
	colorSectorR:AddColorpicker("Items Text",    window.theme.itemscolor,    function(c) window.theme.itemscolor=c    ; window:UpdateTheme(window.theme) end, "settings_itemscolor")
	colorSectorR:AddColorpicker("Title Text",    window.theme.toptextcolor,  function(c) window.theme.toptextcolor=c  ; window:UpdateTheme(window.theme) end, "settings_toptextcolor")
	colorSectorR:AddColorpicker("Tab Text",      window.theme.tabstextcolor, function(c) window.theme.tabstextcolor=c ; window:UpdateTheme(window.theme) end, "settings_tabstextcolor")

	return window
end

-- ================================================================
-- NOTIFY SYSTEM — style Photon
-- ================================================================
function library:Notify(title, description, duration)
	if type(description) == "number" then duration = description ; description = nil end
	duration = duration or 5

	local notifGui = Instance.new("ScreenGui", coregui)
	notifGui.Name = "EchoNotif" ; notifGui.DisplayOrder = 20
	if syn then pcall(function() syn.protect_gui(notifGui) end) end

	local notifFrame = Instance.new("Frame", notifGui)
	notifFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
	notifFrame.BorderSizePixel = 0
	notifFrame.Size = UDim2.fromOffset(260, description and 58 or 38)
	notifFrame.Position = UDim2.new(1, 270, 0, 60)
	notifFrame.ClipsDescendants = false
	local nfc = Instance.new("UICorner", notifFrame) ; nfc.CornerRadius = UDim.new(0, 6)
	local nfs = Instance.new("UIStroke", notifFrame) ; nfs.Color = Color3.fromRGB(45,45,45) ; nfs.Thickness = 1

	-- Barre rouge à gauche
	local leftBar = Instance.new("Frame", notifFrame)
	leftBar.BackgroundColor3 = library.theme.accentcolor
	leftBar.BorderSizePixel = 0 ; leftBar.ZIndex = 4
	leftBar.Size = UDim2.fromOffset(3, notifFrame.Size.Y.Offset)
	leftBar.Position = UDim2.fromOffset(0, 0)
	local lbc = Instance.new("UICorner", leftBar) ; lbc.CornerRadius = UDim.new(0, 3)

	local titleLabel = Instance.new("TextLabel", notifFrame)
	titleLabel.BackgroundTransparency = 1 ; titleLabel.ZIndex = 5
	titleLabel.Font = Enum.Font.GothamBold ; titleLabel.Text = title or ""
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255) ; titleLabel.TextSize = 13
	titleLabel.TextStrokeTransparency = 1 ; titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Position = UDim2.fromOffset(14, description and 8 or 12)
	titleLabel.Size = UDim2.fromOffset(236, 16)

	if description then
		local descLabel = Instance.new("TextLabel", notifFrame)
		descLabel.BackgroundTransparency = 1 ; descLabel.ZIndex = 5
		descLabel.Font = Enum.Font.Gotham ; descLabel.Text = description
		descLabel.TextColor3 = Color3.fromRGB(140, 140, 140) ; descLabel.TextSize = 11
		descLabel.TextStrokeTransparency = 1 ; descLabel.TextXAlignment = Enum.TextXAlignment.Left
		descLabel.TextWrapped = true ; descLabel.Position = UDim2.fromOffset(14, 27)
		descLabel.Size = UDim2.fromOffset(236, 22)
	end

	-- Progress bar
	local pbg = Instance.new("Frame", notifFrame)
	pbg.BackgroundColor3 = Color3.fromRGB(35,35,35) ; pbg.BorderSizePixel = 0 ; pbg.ZIndex = 4
	pbg.Size = UDim2.fromOffset(260, 2) ; pbg.Position = UDim2.new(0, 0, 1, -2)
	local pbgc = Instance.new("UICorner", pbg) ; pbgc.CornerRadius = UDim.new(0,1)

	local pb = Instance.new("Frame", pbg)
	pb.BackgroundColor3 = library.theme.accentcolor ; pb.BorderSizePixel = 0 ; pb.ZIndex = 5
	pb.Size = UDim2.fromScale(1, 1)
	local pbc = Instance.new("UICorner", pb) ; pbc.CornerRadius = UDim.new(0,1)

	tweenservice:Create(notifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Position = UDim2.new(1, -272, 0, 60)
	}):Play()
	wait(0.35)
	tweenservice:Create(pb, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.fromScale(0,1)}):Play()
	delay(duration, function()
		tweenservice:Create(notifFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
			Position = UDim2.new(1, 270, 0, 60)
		}):Play()
		wait(0.3) ; notifGui:Destroy()
	end)

	return notifFrame
end

return library
