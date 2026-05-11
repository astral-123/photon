-- ================================================================
-- PHOTON LIBRARY — Style External Photon
-- ================================================================
local library = { flags={}, items={} }

local players      = game:GetService("Players")
local uis          = game:GetService("UserInputService")
local runservice   = game:GetService("RunService")
local tweenservice = game:GetService("TweenService")
local textservice  = game:GetService("TextService")
local coregui      = game:GetService("CoreGui")

local player = players.LocalPlayer
local mouse  = player:GetMouse()

-- ── Thème
local T = {
	bg          = Color3.fromRGB(15, 15, 15),
	sidebar     = Color3.fromRGB(20, 20, 20),
	card        = Color3.fromRGB(26, 26, 26),
	cardheader  = Color3.fromRGB(22, 22, 22),
	topbar      = Color3.fromRGB(18, 18, 18),
	tabbar      = Color3.fromRGB(14, 14, 14),
	accent      = Color3.fromRGB(232, 51, 58),
	outline     = Color3.fromRGB(40, 40, 40),
	outline2    = Color3.fromRGB(10, 10, 10),
	text        = Color3.fromRGB(210, 210, 210),
	textdim     = Color3.fromRGB(130, 130, 130),
	textactive  = Color3.fromRGB(255, 255, 255),
	slider      = Color3.fromRGB(35, 35, 35),
	item        = Color3.fromRGB(30, 30, 30),
}

-- ── Keybind helpers
local knames = {LeftShift="LSHIFT",RightShift="RSHIFT",LeftControl="LCTRL",RightControl="RCTRL",LeftAlt="LALT",RightAlt="RALT"}
local mbtns  = {[Enum.UserInputType.MouseButton1]="MB1",[Enum.UserInputType.MouseButton2]="MB2",[Enum.UserInputType.MouseButton3]="MB3"}
local function kbText(v)
	if v=="None" or v==nil then return "[None]" end
	if mbtns[v] then return "["..mbtns[v].."]" end
	if typeof(v)=="EnumItem" then return "["..(knames[v.Name] or v.Name).."]" end
	return "["..tostring(v).."]"
end
local function kbMatch(input,v)
	if v=="None" or v==nil then return false end
	if mbtns[v] then return input.UserInputType==v end
	if typeof(v)=="EnumItem" then return input.UserInputType==Enum.UserInputType.Keyboard and input.KeyCode==v end
	return false
end
local function kbFromInput(input)
	if mbtns[input.UserInputType] then return input.UserInputType
	elseif input.UserInputType==Enum.UserInputType.Keyboard then return input.KeyCode end
	return "None"
end

-- ── UI helpers
local function newInst(cls, props, parent)
	local i = Instance.new(cls)
	for k,v in pairs(props or {}) do i[k]=v end
	if parent then i.Parent=parent end
	return i
end
local function corner(r, parent)
	return newInst("UICorner",{CornerRadius=UDim.new(0,r)},parent)
end
local function stroke(c, t, parent)
	return newInst("UIStroke",{Color=c,Thickness=t,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},parent)
end
local function tween(obj, props, t)
	tweenservice:Create(obj, TweenInfo.new(t or 0.12), props):Play()
end

-- ================================================================
-- CreateWindow
-- ================================================================
function library:CreateWindow(name, size, hidekey)
	local W = {}
	W.name    = name or "photon"
	W.size    = Vector2.new(size and size.X or 960, size and size.Y or 580)
	W.hidekey = hidekey or Enum.KeyCode.RightShift
	W.tabs    = {}
	W.openedPickers = {}

	-- ScreenGui
	W.gui = newInst("ScreenGui",{Name=name,DisplayOrder=20,ResetOnSpawn=false},coregui)
	if syn then pcall(function() syn.protect_gui(W.gui) end) end
	if getgenv and getgenv().uilib then pcall(function() getgenv().uilib:Destroy() end) end
	if getgenv then getgenv().uilib = W.gui end

	-- Main frame
	W.frame = newInst("TextButton",{
		Name="Window", Size=UDim2.fromOffset(W.size.X, W.size.Y),
		Position=UDim2.fromScale(0.5,0.5), AnchorPoint=Vector2.new(0.5,0.5),
		BackgroundColor3=T.bg, BorderSizePixel=0, AutoButtonColor=false,
		Text="", ClipsDescendants=false,
	}, W.gui)
	corner(8, W.frame)
	stroke(T.outline, 1, W.frame)
	-- outer glow
	newInst("UIStroke",{Color=T.outline2,Thickness=3,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},W.frame)

	-- Drag
	local dragging, dstart, dpos
	W.frame.InputBegan:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 then
			dragging=true ; dstart=i.Position ; dpos=W.frame.Position
			i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dragging=false end end)
		end
	end)
	uis.InputChanged:Connect(function(i)
		if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
			local d=i.Position-dstart
			W.frame.Position=UDim2.new(dpos.X.Scale,dpos.X.Offset+d.X,dpos.Y.Scale,dpos.Y.Offset+d.Y)
		end
	end)
	uis.InputBegan:Connect(function(k)
		if k.KeyCode==W.hidekey then W.frame.Visible=not W.frame.Visible end
	end)

	-- ── TOPBAR
	local TOPBAR_H = 36
	W.topbar = newInst("Frame",{
		Name="TopBar", Size=UDim2.fromOffset(W.size.X, TOPBAR_H),
		BackgroundColor3=T.topbar, BorderSizePixel=0, ZIndex=5,
	}, W.frame)
	corner(8, W.topbar)
	-- fix bottom corners
	newInst("Frame",{
		Size=UDim2.fromOffset(W.size.X, 8), Position=UDim2.new(0,0,1,-8),
		BackgroundColor3=T.topbar, BorderSizePixel=0, ZIndex=5,
	}, W.topbar)
	-- red accent line under topbar
	newInst("Frame",{
		Size=UDim2.fromOffset(W.size.X,2), Position=UDim2.fromOffset(0,TOPBAR_H),
		BackgroundColor3=T.accent, BorderSizePixel=0, ZIndex=4,
	}, W.frame)
	-- Title "photon" in red
	newInst("TextLabel",{
		Text=W.name:lower(), Font=Enum.Font.GothamBold, TextSize=16,
		TextColor3=T.accent, BackgroundTransparency=1,
		Position=UDim2.fromOffset(14,0), Size=UDim2.fromOffset(200,TOPBAR_H),
		TextXAlignment=Enum.TextXAlignment.Left, ZIndex=6,
	}, W.topbar)
	-- Close button
	local closeBtn = newInst("TextButton",{
		Text="✕", Font=Enum.Font.GothamBold, TextSize=12,
		TextColor3=T.textdim, BackgroundTransparency=1, BorderSizePixel=0,
		Size=UDim2.fromOffset(28,28), Position=UDim2.new(1,-34,0,4), ZIndex=10,
		AutoButtonColor=false,
	}, W.topbar)
	closeBtn.MouseEnter:Connect(function() tween(closeBtn,{TextColor3=T.accent}) end)
	closeBtn.MouseLeave:Connect(function() tween(closeBtn,{TextColor3=T.textdim}) end)
	closeBtn.MouseButton1Down:Connect(function() W.gui:Destroy() end)
	-- Minimize button
	local minBtn = newInst("TextButton",{
		Text="─", Font=Enum.Font.GothamBold, TextSize=12,
		TextColor3=T.textdim, BackgroundTransparency=1, BorderSizePixel=0,
		Size=UDim2.fromOffset(28,28), Position=UDim2.new(1,-62,0,4), ZIndex=10,
		AutoButtonColor=false,
	}, W.topbar)
	minBtn.MouseEnter:Connect(function() tween(minBtn,{TextColor3=T.textactive}) end)
	minBtn.MouseLeave:Connect(function() tween(minBtn,{TextColor3=T.textdim}) end)
	local minimized=false
	minBtn.MouseButton1Down:Connect(function()
		minimized=not minimized
		W.frame:TweenSize(UDim2.fromOffset(W.size.X, minimized and TOPBAR_H+2 or W.size.Y),
			Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.2)
	end)

	-- ── BOTTOM TAB BAR
	local TABBAR_H = 52
	local CONTENT_TOP = TOPBAR_H + 2
	local CONTENT_H   = W.size.Y - CONTENT_TOP - TABBAR_H

	W.tabbar = newInst("Frame",{
		Name="TabBar", Size=UDim2.fromOffset(W.size.X, TABBAR_H),
		Position=UDim2.fromOffset(0, W.size.Y - TABBAR_H),
		BackgroundColor3=T.tabbar, BorderSizePixel=0, ZIndex=5,
	}, W.frame)
	corner(8, W.tabbar)
	newInst("Frame",{
		Size=UDim2.fromOffset(W.size.X,8), BackgroundColor3=T.tabbar,
		BorderSizePixel=0, ZIndex=5,
	}, W.tabbar)
	-- separator line above tabbar
	newInst("Frame",{
		Size=UDim2.fromOffset(W.size.X,1),
		Position=UDim2.fromOffset(0, W.size.Y - TABBAR_H - 1),
		BackgroundColor3=T.outline, BorderSizePixel=0, ZIndex=4,
	}, W.frame)

	local tabLayout = newInst("UIListLayout",{
		FillDirection=Enum.FillDirection.Horizontal,
		HorizontalAlignment=Enum.HorizontalAlignment.Center,
		VerticalAlignment=Enum.VerticalAlignment.Center,
		SortOrder=Enum.SortOrder.LayoutOrder,
		Padding=UDim.new(0,2),
	}, W.tabbar)

	-- Tab indicator (red line on top of active tab)
	W.tabIndicator = newInst("Frame",{
		Size=UDim2.fromOffset(60,2), Position=UDim2.fromOffset(0,0),
		BackgroundColor3=T.accent, BorderSizePixel=0, ZIndex=8,
		AnchorPoint=Vector2.new(0,0),
	}, W.tabbar)

	-- ── CONTENT AREA
	W.content = newInst("Frame",{
		Name="Content", Size=UDim2.fromOffset(W.size.X, CONTENT_H),
		Position=UDim2.fromOffset(0, CONTENT_TOP),
		BackgroundTransparency=1, BorderSizePixel=0, ZIndex=2,
		ClipsDescendants=true,
	}, W.frame)

	-- ── SIDEBAR (left, for sub-tabs)
	local SIDEBAR_W = 170
	W.sidebar = newInst("Frame",{
		Name="Sidebar", Size=UDim2.fromOffset(SIDEBAR_W, CONTENT_H),
		BackgroundColor3=T.sidebar, BorderSizePixel=0, ZIndex=3,
	}, W.content)
	-- sidebar right border
	newInst("Frame",{
		Size=UDim2.fromOffset(1, CONTENT_H), Position=UDim2.new(1,-1,0,0),
		BackgroundColor3=T.outline, BorderSizePixel=0, ZIndex=4,
	}, W.sidebar)
	W.sidebarLayout = newInst("UIListLayout",{
		FillDirection=Enum.FillDirection.Vertical,
		SortOrder=Enum.SortOrder.LayoutOrder,
		Padding=UDim.new(0,2),
	}, W.sidebar)
	newInst("UIPadding",{PaddingTop=UDim.new(0,8),PaddingLeft=UDim.new(0,6),PaddingRight=UDim.new(0,6)}, W.sidebar)

	-- ── MAIN PANEL (right of sidebar)
	W.panel = newInst("ScrollingFrame",{
		Name="Panel",
		Size=UDim2.fromOffset(W.size.X - SIDEBAR_W, CONTENT_H),
		Position=UDim2.fromOffset(SIDEBAR_W, 0),
		BackgroundTransparency=1, BorderSizePixel=0, ZIndex=2,
		ScrollBarThickness=3, ScrollingDirection=Enum.ScrollingDirection.Y,
		ScrollBarImageColor3=T.accent, AutomaticCanvasSize=Enum.AutomaticSize.Y,
		CanvasSize=UDim2.fromOffset(0,0),
	}, W.content)
	newInst("UIPadding",{PaddingTop=UDim.new(0,10),PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,10),PaddingBottom=UDim.new(0,10)}, W.panel)

	-- ================================================================
	-- CreateTab
	-- ================================================================
	function W:CreateTab(name, icon)
		local tab = {name=name, subtabs={}, sectors={}}
		local btnW = math.max(70, textservice:GetTextSize(name,11,Enum.Font.Gotham,Vector2.new(300,50)).X + 36)

		-- Bottom tab button
		tab.btn = newInst("TextButton",{
			Name=name, Size=UDim2.fromOffset(btnW, TABBAR_H),
			BackgroundTransparency=1, BorderSizePixel=0,
			AutoButtonColor=false, ZIndex=6, Text="",
			LayoutOrder=#W.tabs+1,
		}, W.tabbar)

		-- Icon (optional)
		if icon and icon~="" then
			newInst("ImageLabel",{
				Image=icon, Size=UDim2.fromOffset(20,20),
				Position=UDim2.new(0.5,-10,0,6),
				BackgroundTransparency=1, ImageColor3=T.textdim, ZIndex=7,
			}, tab.btn)
		end

		tab.btnLabel = newInst("TextLabel",{
			Text=name, Font=Enum.Font.Gotham, TextSize=11,
			TextColor3=T.textdim, BackgroundTransparency=1,
			ZIndex=7, TextXAlignment=Enum.TextXAlignment.Center,
			Size=UDim2.fromOffset(btnW, TABBAR_H),
		}, tab.btn)

		-- Container (full content area, hidden by default)
		tab.container = newInst("Frame",{
			Size=UDim2.fromScale(1,1), BackgroundTransparency=1,
			Visible=false, ZIndex=2,
		}, W.content)

		-- Sidebar for this tab
		tab.sideFrame = newInst("Frame",{
			Size=UDim2.fromOffset(SIDEBAR_W, CONTENT_H),
			BackgroundTransparency=1, ZIndex=3,
		}, tab.container)
		tab.sideLayout = newInst("UIListLayout",{
			FillDirection=Enum.FillDirection.Vertical,
			SortOrder=Enum.SortOrder.LayoutOrder,
			Padding=UDim.new(0,2),
		}, tab.sideFrame)
		newInst("UIPadding",{PaddingTop=UDim.new(0,8),PaddingLeft=UDim.new(0,6),PaddingRight=UDim.new(0,6)}, tab.sideFrame)

		-- Panel for this tab (cards area)
		tab.panel = newInst("ScrollingFrame",{
			Size=UDim2.fromOffset(W.size.X - SIDEBAR_W, CONTENT_H),
			Position=UDim2.fromOffset(SIDEBAR_W,0),
			BackgroundTransparency=1, BorderSizePixel=0, ZIndex=2,
			ScrollBarThickness=3, ScrollingDirection=Enum.ScrollingDirection.Y,
			ScrollBarImageColor3=T.accent, AutomaticCanvasSize=Enum.AutomaticSize.Y,
			CanvasSize=UDim2.fromOffset(0,0),
		}, tab.container)

		-- Grid layout for cards
		tab.gridLayout = newInst("UIGridLayout",{
			CellSize=UDim2.fromOffset(math.floor((W.size.X - SIDEBAR_W - 30)/2), 1),
			CellPadding=UDim2.fromOffset(8,8),
			SortOrder=Enum.SortOrder.LayoutOrder,
			StartCorner=Enum.StartCorner.TopLeft,
			FillDirectionMaxCells=2,
		}, tab.panel)
		newInst("UIPadding",{PaddingTop=UDim.new(0,8),PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8),PaddingBottom=UDim.new(0,8)}, tab.panel)

		-- Select tab logic
		local block=false
		function tab:Select()
			if block then return end ; block=true
			for _,t in pairs(W.tabs) do
				t.container.Visible=false
				tween(t.btnLabel,{TextColor3=T.textdim})
			end
			tab.container.Visible=true
			tween(tab.btnLabel,{TextColor3=T.accent})
			tab.btnLabel.Font=Enum.Font.GothamBold

			-- Move indicator
			local bx=tab.btn.AbsolutePosition.X - W.tabbar.AbsolutePosition.X
			tween(W.tabIndicator,{Position=UDim2.fromOffset(bx,0), Size=UDim2.fromOffset(tab.btn.AbsoluteSize.X,2)},0.15)

			-- Auto-select first subtab
			if tab.subtabs[1] then tab.subtabs[1]:Select() end
			task.wait(0.15) ; block=false
		end

		tab.btn.MouseButton1Down:Connect(function() tab:Select() end)
		if #W.tabs==0 then task.defer(function() tab:Select() end) end
		table.insert(W.tabs, tab)

		-- ================================================================
		-- CreateSubTab  (sidebar entry)
		-- ================================================================
		function tab:CreateSubTab(name)
			local st = {name=name, sectors={}}

			st.btn = newInst("TextButton",{
				Name=name, Size=UDim2.new(1,0,0,30),
				BackgroundColor3=Color3.fromRGB(30,30,30),
				BackgroundTransparency=1,
				BorderSizePixel=0, AutoButtonColor=false,
				ZIndex=6, Text="", LayoutOrder=#tab.subtabs+1,
			}, tab.sideFrame)
			corner(5, st.btn)

			-- Accent bar left
			st.accentBar = newInst("Frame",{
				Size=UDim2.fromOffset(3,16), Position=UDim2.new(0,0,0.5,-8),
				BackgroundColor3=T.accent, BorderSizePixel=0, ZIndex=7,
				Visible=false,
			}, st.btn)
			corner(2, st.accentBar)

			st.label = newInst("TextLabel",{
				Text=name, Font=Enum.Font.Gotham, TextSize=12,
				TextColor3=T.textdim, BackgroundTransparency=1,
				Size=UDim2.fromScale(1,1), ZIndex=7,
				TextXAlignment=Enum.TextXAlignment.Left,
			}, st.btn)
			newInst("UIPadding",{PaddingLeft=UDim.new(0,10)}, st.label)

			-- Sub-tab panel (hidden frame that contains its cards)
			st.panel = newInst("Frame",{
				Name=name.."Panel", Size=UDim2.fromOffset(W.size.X-SIDEBAR_W, CONTENT_H),
				Position=UDim2.fromOffset(SIDEBAR_W,0),
				BackgroundTransparency=1, Visible=false, ZIndex=2,
			}, tab.container)
			st.panelScroll = newInst("ScrollingFrame",{
				Size=UDim2.fromScale(1,1), BackgroundTransparency=1,
				BorderSizePixel=0, ZIndex=2, ScrollBarThickness=3,
				ScrollingDirection=Enum.ScrollingDirection.Y,
				ScrollBarImageColor3=T.accent, AutomaticCanvasSize=Enum.AutomaticSize.Y,
				CanvasSize=UDim2.fromOffset(0,0),
			}, st.panel)
			st.grid = newInst("UIGridLayout",{
				CellSize=UDim2.fromOffset(math.floor((W.size.X-SIDEBAR_W-30)/2),1),
				CellPadding=UDim2.fromOffset(8,8),
				SortOrder=Enum.SortOrder.LayoutOrder,
				FillDirectionMaxCells=2,
			}, st.panelScroll)
			newInst("UIPadding",{PaddingTop=UDim.new(0,8),PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8),PaddingBottom=UDim.new(0,8)}, st.panelScroll)

			function st:Select()
				for _,s in pairs(tab.subtabs) do
					s.panel.Visible=false
					tween(s.label,{TextColor3=T.textdim})
					s.label.Font=Enum.Font.Gotham
					tween(s.btn,{BackgroundTransparency=1})
					s.accentBar.Visible=false
				end
				st.panel.Visible=true
				tween(st.label,{TextColor3=T.textactive})
				st.label.Font=Enum.Font.GothamBold
				tween(st.btn,{BackgroundTransparency=0})
				st.accentBar.Visible=true
			end
			st.btn.MouseButton1Down:Connect(function() st:Select() end)
			st.btn.MouseEnter:Connect(function()
				if not st.panel.Visible then tween(st.btn,{BackgroundTransparency=0.7}) end
			end)
			st.btn.MouseLeave:Connect(function()
				if not st.panel.Visible then tween(st.btn,{BackgroundTransparency=1}) end
			end)

			if #tab.subtabs==0 then st:Select() end
			table.insert(tab.subtabs, st)

			-- ================================================================
			-- CreateSector  (card)
			-- ================================================================
			function st:CreateSector(name)
				local sector = {name=name, items={}}
				local CARD_W = math.floor((W.size.X - SIDEBAR_W - 30)/2)

				sector.frame = newInst("Frame",{
					Name=name.."Sector", BackgroundColor3=T.card,
					BorderSizePixel=0, ZIndex=4,
					AutomaticSize=Enum.AutomaticSize.Y,
					LayoutOrder=#st.sectors+1,
				}, st.panelScroll)
				corner(6, sector.frame)
				stroke(T.outline, 1, sector.frame)

				-- Red top line
				newInst("Frame",{
					Size=UDim2.new(1,0,0,2), Position=UDim2.fromOffset(0,0),
					BackgroundColor3=T.accent, BorderSizePixel=0, ZIndex=6,
				}, sector.frame)

				-- Header
				local header = newInst("Frame",{
					Size=UDim2.new(1,0,0,24), BackgroundColor3=T.cardheader,
					BorderSizePixel=0, ZIndex=5,
				}, sector.frame)
				corner(6, header)
				-- fix bottom corners of header
				newInst("Frame",{
					Size=UDim2.new(1,0,0,8), Position=UDim2.new(0,0,1,-8),
					BackgroundColor3=T.cardheader, BorderSizePixel=0, ZIndex=5,
				}, header)
				newInst("TextLabel",{
					Text=name:upper(), Font=Enum.Font.GothamBold, TextSize=10,
					TextColor3=T.textactive, BackgroundTransparency=1,
					Size=UDim2.new(1,-20,1,0), Position=UDim2.fromOffset(10,0),
					TextXAlignment=Enum.TextXAlignment.Left, ZIndex=6,
					TextStrokeTransparency=1,
				}, header)

				-- Items list
				sector.list = newInst("Frame",{
					Name="Items", BackgroundTransparency=1, BorderSizePixel=0,
					Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
					Position=UDim2.fromOffset(0,26), ZIndex=5,
				}, sector.frame)
				sector.listLayout = newInst("UIListLayout",{
					FillDirection=Enum.FillDirection.Vertical,
					SortOrder=Enum.SortOrder.LayoutOrder,
					Padding=UDim.new(0,6),
				}, sector.list)
				newInst("UIPadding",{
					PaddingTop=UDim.new(0,8),PaddingBottom=UDim.new(0,10),
					PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,10),
				}, sector.list)

				table.insert(st.sectors, sector)

				local function mkRow(h)
					return newInst("Frame",{
						BackgroundTransparency=1, BorderSizePixel=0, ZIndex=5,
						Size=UDim2.new(1,0,0,h),
					}, sector.list)
				end
				local function mkText(parent, txt, xa, color, size, font, zi)
					return newInst("TextLabel",{
						Text=txt or "", Font=font or Enum.Font.Gotham,
						TextSize=size or 11, TextColor3=color or T.text,
						BackgroundTransparency=1, BorderSizePixel=0,
						ZIndex=zi or 6, TextXAlignment=xa or Enum.TextXAlignment.Left,
						TextStrokeTransparency=1,
					}, parent)
				end

				-- ────────────────────────────────────────
				-- AddLabel
				-- ────────────────────────────────────────
				function sector:AddLabel(text, color)
					local row = mkRow(14)
					local bar = newInst("Frame",{
						Size=UDim2.fromOffset(2,12), Position=UDim2.new(0,0,0.5,-6),
						BackgroundColor3=T.accent, BorderSizePixel=0, ZIndex=6,
					}, row)
					corner(1,bar)
					local lbl = mkText(row, text, Enum.TextXAlignment.Left, color or T.textdim, 11)
					lbl.Position=UDim2.fromOffset(8,0)
					lbl.Size=UDim2.new(1,-8,1,0)
					lbl.TextWrapped=true
					local obj={Main=row}
					function obj:Set(v) lbl.Text=tostring(v) end
					return obj
				end

				-- ────────────────────────────────────────
				-- AddButton
				-- ────────────────────────────────────────
				function sector:AddButton(text, callback)
					local row = mkRow(26)
					local btn = newInst("TextButton",{
						Text="", BackgroundColor3=Color3.fromRGB(36,36,36),
						BorderSizePixel=0, AutoButtonColor=false, ZIndex=6,
						Size=UDim2.fromScale(1,1),
					}, row)
					corner(4, btn)
					local bs = stroke(T.outline, 1, btn)
					mkText(btn, text, Enum.TextXAlignment.Center, T.textactive, 11, Enum.Font.GothamBold, 7)
						.Size=UDim2.fromScale(1,1)
					btn.MouseEnter:Connect(function() bs.Color=T.accent ; tween(btn,{BackgroundColor3=Color3.fromRGB(42,42,42)}) end)
					btn.MouseLeave:Connect(function() bs.Color=T.outline ; tween(btn,{BackgroundColor3=Color3.fromRGB(36,36,36)}) end)
					btn.MouseButton1Down:Connect(function()
						tween(btn,{BackgroundColor3=T.accent},0.05)
						task.delay(0.12,function() tween(btn,{BackgroundColor3=Color3.fromRGB(36,36,36)},0.1) end)
						pcall(callback)
					end)
					return {Main=row}
				end

				-- ────────────────────────────────────────
				-- AddToggle
				-- ────────────────────────────────────────
				function sector:AddToggle(text, default, callback, flag)
					local toggle={value=default or false, flag=flag or text, callback=callback or function()end}
					local row = mkRow(18)

					-- Checkbox
					local box = newInst("TextButton",{
						Size=UDim2.fromOffset(15,15), Position=UDim2.new(0,0,0.5,-7),
						BackgroundColor3=Color3.fromRGB(28,28,28), BorderSizePixel=0,
						AutoButtonColor=false, ZIndex=6, Text="",
					}, row)
					corner(3, box)
					local boxS = stroke(Color3.fromRGB(60,60,60), 1, box)

					local check = newInst("Frame",{
						Size=UDim2.fromOffset(9,9), Position=UDim2.fromOffset(3,3),
						BackgroundColor3=T.accent, BorderSizePixel=0, ZIndex=7, Visible=false,
					}, box)
					corner(2, check)

					local lbl = newInst("TextButton",{
						Text=text, Font=Enum.Font.Gotham, TextSize=11,
						TextColor3=T.text, BackgroundTransparency=1, BorderSizePixel=0,
						Position=UDim2.fromOffset(22,0), Size=UDim2.new(1,-22,1,0),
						ZIndex=6, AutoButtonColor=false,
						TextXAlignment=Enum.TextXAlignment.Left,
					}, row)

					-- Right side items (keybind, etc)
					local items = newInst("Frame",{
						Size=UDim2.fromOffset(65,18), Position=UDim2.new(1,-65,0,0),
						BackgroundTransparency=1, BorderSizePixel=0, ZIndex=6,
					}, row)
					local iLayout = newInst("UIListLayout",{
						FillDirection=Enum.FillDirection.Horizontal,
						HorizontalAlignment=Enum.HorizontalAlignment.Right,
						SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,4),
					}, items)
					toggle.Items = items

					if toggle.flag~="" then library.flags[toggle.flag]=toggle.value end
					function toggle:Set(v)
						toggle.value=v ; check.Visible=v
						boxS.Color=v and T.accent or Color3.fromRGB(60,60,60)
						lbl.TextColor3=v and T.textactive or T.text
						if toggle.flag~="" then library.flags[toggle.flag]=v end
						pcall(toggle.callback,v)
					end
					function toggle:Get() return toggle.value end
					toggle:Set(toggle.value)

					local function click() toggle:Set(not toggle.value) end
					box.MouseButton1Down:Connect(click)
					lbl.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then click() end end)

					-- AddKeybind on toggle
					function toggle:AddKeybind(default, kflag)
						local kb={value=default or "None", flag=kflag or (text.."kb")}
						local kbtn = newInst("TextButton",{
							Text=kbText(kb.value), Font=Enum.Font.Gotham, TextSize=10,
							TextColor3=T.textdim, BackgroundTransparency=1, BorderSizePixel=0,
							Size=UDim2.fromOffset(55,16), ZIndex=7, AutoButtonColor=false,
							TextXAlignment=Enum.TextXAlignment.Right,
						}, toggle.Items)
						if kb.flag~="" then library.flags[kb.flag]=kb.value end
						function kb:Set(v) kb.value=v ; kbtn.Text=kbText(v) ; if kb.flag~="" then library.flags[kb.flag]=v end end
						kbtn.MouseButton1Down:Connect(function() kbtn.Text="[...]" ; kbtn.TextColor3=T.accent end)
						uis.InputBegan:Connect(function(input,gp)
							if gp then return end
							if kbtn.Text=="[...]" then kbtn.TextColor3=T.textdim ; kb:Set(kbFromInput(input))
							elseif kbMatch(input,kb.value) then click() end
						end)
						table.insert(library.items,kb) ; return kb
					end

					table.insert(library.items,toggle) ; return toggle
				end

				-- ────────────────────────────────────────
				-- AddSlider
				-- ────────────────────────────────────────
				function sector:AddSlider(text, min, default, max, decimals, callback, flag)
					local slider={min=min or 0, max=max or 100, decimals=decimals or 1,
						value=default or min or 0, flag=flag or text, callback=callback or function()end}
					local row = mkRow(34)

					-- Label row
					local labelRow = newInst("Frame",{Size=UDim2.new(1,0,0,14),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=5},row)
					mkText(labelRow, text, Enum.TextXAlignment.Left, T.text, 11).Size=UDim2.new(0.7,0,1,0)
					slider.valLabel=mkText(labelRow, tostring(slider.value), Enum.TextXAlignment.Right, T.accent, 11, Enum.Font.GothamBold)
					slider.valLabel.Size=UDim2.fromScale(1,1)

					-- Track
					local track = newInst("TextButton",{
						Size=UDim2.new(1,0,0,5), Position=UDim2.fromOffset(0,18),
						BackgroundColor3=T.slider, BorderSizePixel=0, AutoButtonColor=false,
						ZIndex=6, Text="",
					}, row)
					corner(3, track)

					local fill = newInst("Frame",{
						Size=UDim2.fromOffset(0,5), BackgroundColor3=T.accent,
						BorderSizePixel=0, ZIndex=7,
					}, track)
					corner(3, fill)

					local thumb = newInst("Frame",{
						Size=UDim2.fromOffset(10,10), Position=UDim2.fromOffset(-5,-3),
						BackgroundColor3=Color3.fromRGB(220,220,220), BorderSizePixel=0, ZIndex=8,
					}, track)
					corner(5, thumb)
					stroke(T.accent, 1, thumb)

					if slider.flag~="" then library.flags[slider.flag]=slider.value end
					function slider:Set(v)
						slider.value=math.clamp(math.round(v*slider.decimals)/slider.decimals, slider.min, slider.max)
						local pct=(slider.value-slider.min)/(slider.max-slider.min)
						local px=pct*track.AbsoluteSize.X
						fill:TweenSize(UDim2.fromOffset(px,5),Enum.EasingDirection.In,Enum.EasingStyle.Linear,0.04)
						thumb:TweenPosition(UDim2.fromOffset(px-5,-3),Enum.EasingDirection.In,Enum.EasingStyle.Linear,0.04)
						slider.valLabel.Text=slider.value
						if slider.flag~="" then library.flags[slider.flag]=slider.value end
						pcall(slider.callback,slider.value)
					end
					function slider:Get() return slider.value end
					slider:Set(slider.value)

					local dragging=false
					local function refresh()
						local pct=math.clamp((mouse.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
						slider:Set(slider.min+(slider.max-slider.min)*pct)
					end
					track.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true;refresh() end end)
					track.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
					uis.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then refresh() end end)
					track.MouseEnter:Connect(function() tween(fill,{BackgroundColor3=Color3.fromRGB(255,80,85)}) end)
					track.MouseLeave:Connect(function() tween(fill,{BackgroundColor3=T.accent}) end)

					table.insert(library.items,slider) ; return slider
				end

				-- ────────────────────────────────────────
				-- AddDropdown
				-- ────────────────────────────────────────
				function sector:AddDropdown(text, items, default, multi, callback, flag)
					local dd={values={}, items=items or {}, multi=multi or false,
						flag=flag or text, callback=callback or function()end}
					local row = mkRow(34)

					mkText(row, text, Enum.TextXAlignment.Left, T.text, 11).Size=UDim2.new(1,0,0,14)

					local main = newInst("TextButton",{
						Size=UDim2.new(1,0,0,18), Position=UDim2.fromOffset(0,16),
						BackgroundColor3=Color3.fromRGB(28,28,28), BorderSizePixel=0,
						AutoButtonColor=false, ZIndex=6, Text="",
					}, row)
					corner(4, main)
					local ms = stroke(T.outline, 1, main)

					dd.selLabel=mkText(main, default or (items[1] or ""), Enum.TextXAlignment.Left, Color3.fromRGB(180,180,180), 11)
					dd.selLabel.Size=UDim2.new(1,-22,1,0) ; dd.selLabel.Position=UDim2.fromOffset(7,0)

					local arrow=mkText(main,"▾",Enum.TextXAlignment.Center,T.textdim,11)
					arrow.Size=UDim2.fromOffset(16,18) ; arrow.Position=UDim2.new(1,-18,0,0)

					-- Dropdown list
					local list = newInst("ScrollingFrame",{
						Size=UDim2.fromOffset(0,0), Position=UDim2.fromOffset(0,22),
						BackgroundColor3=Color3.fromRGB(22,22,22), BorderSizePixel=0,
						ZIndex=20, Visible=false, ScrollBarThickness=2,
						ScrollBarImageColor3=T.accent,
					}, main)
					corner(4, list)
					stroke(T.outline, 1, list)
					local listLayout=newInst("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder},list)
					newInst("UIPadding",{PaddingTop=UDim.new(0,3),PaddingBottom=UDim.new(0,3),PaddingLeft=UDim.new(0,3),PaddingRight=UDim.new(0,3)},list)

					if dd.flag~="" then library.flags[dd.flag]=default or (items[1] or "") end
					function dd:isSelected(v) for _,x in pairs(dd.values) do if x==v then return true end end return false end
					function dd:Set(v)
						if type(v)=="table" then dd.values=v ; dd.selLabel.Text=table.concat(v,", ")
						else dd.values={v} ; dd.selLabel.Text=v end
						if dd.flag~="" then library.flags[dd.flag]=dd.multi and dd.values or dd.values[1] end
						pcall(dd.callback, dd.multi and dd.values or dd.values[1])
					end
					function dd:Get() return dd.multi and dd.values or dd.values[1] end

					-- Populate items
					for _,v in pairs(dd.items) do
						local item=newInst("TextButton",{
							Text=v, Font=Enum.Font.Gotham, TextSize=11,
							TextColor3=Color3.fromRGB(180,180,180),
							BackgroundColor3=Color3.fromRGB(28,28,28),
							BorderSizePixel=0, Size=UDim2.new(1,0,0,18),
							AutoButtonColor=false, ZIndex=21,
							TextXAlignment=Enum.TextXAlignment.Left,
						}, list)
						newInst("UIPadding",{PaddingLeft=UDim.new(0,5)},item)
						corner(3, item)
						item.MouseButton1Down:Connect(function()
							if dd.multi then
								if dd:isSelected(v) then
									for i,x in pairs(dd.values) do if x==v then table.remove(dd.values,i) end end
									dd:Set(dd.values)
								else table.insert(dd.values,v) ; dd:Set(dd.values) end
								return
							end
							arrow.Text="▾" ; list.Visible=false
							row.Size=UDim2.new(1,0,0,34)
							dd:Set(v)
						end)
						runservice.RenderStepped:Connect(function()
							if dd:isSelected(v) then item.TextColor3=T.accent ; item.BackgroundColor3=Color3.fromRGB(38,38,38)
							else item.TextColor3=Color3.fromRGB(180,180,180) ; item.BackgroundColor3=Color3.fromRGB(28,28,28) end
						end)
					end

					main.MouseButton1Down:Connect(function()
						list.Visible=not list.Visible
						arrow.Text=list.Visible and "▴" or "▾"
						ms.Color=list.Visible and T.accent or T.outline
						if list.Visible then
							local h=math.clamp(#dd.items*18+6,18,110)
							list.Size=UDim2.fromOffset(main.AbsoluteSize.X, h)
							list.CanvasSize=UDim2.fromOffset(0,#dd.items*18+6)
							row.Size=UDim2.new(1,0,0,34+h+4)
						else row.Size=UDim2.new(1,0,0,34) end
					end)
					main.MouseEnter:Connect(function() ms.Color=T.accent end)
					main.MouseLeave:Connect(function() if not list.Visible then ms.Color=T.outline end end)

					if default then dd:Set(default) end
					table.insert(library.items,dd) ; return dd
				end

				-- ────────────────────────────────────────
				-- AddColorpicker
				-- ────────────────────────────────────────
				function sector:AddColorpicker(text, default, callback, flag)
					local cp={value=default or Color3.new(1,1,1), flag=flag or text, callback=callback or function()end, color=0}
					local row=mkRow(18)
					mkText(row,text,Enum.TextXAlignment.Left,T.text,11).Size=UDim2.new(1,-40,1,0)

					local swatch=newInst("TextButton",{
						Size=UDim2.fromOffset(30,14), Position=UDim2.new(1,-30,0.5,-7),
						BackgroundColor3=cp.value, BorderSizePixel=0, ZIndex=6,
						AutoButtonColor=false, Text="",
					},row)
					corner(3,swatch)
					local ss=stroke(T.outline,1,swatch)

					local picker=newInst("TextButton",{
						Size=UDim2.fromOffset(180,196), Position=UDim2.fromOffset(-150,18),
						BackgroundColor3=Color3.fromRGB(28,28,28), BorderSizePixel=0,
						ZIndex=100, Visible=false, AutoButtonColor=false, Text="",
					},swatch)
					corner(6,picker) ; stroke(T.outline,1,picker)
					W.openedPickers[picker]=false

					local hue=newInst("ImageLabel",{Image="rbxassetid://4155801252",Size=UDim2.new(0,170,0,170),Position=UDim2.fromOffset(5,5),ZIndex=101,ScaleType=Enum.ScaleType.Stretch,BackgroundColor3=Color3.new(1,0,0),BorderSizePixel=0},picker)
					local hptr=newInst("ImageLabel",{Image="rbxassetid://6885856475",Size=UDim2.fromOffset(7,7),ZIndex=102,BackgroundTransparency=1,BorderSizePixel=0},picker)
					local sel=newInst("TextLabel",{Size=UDim2.new(0,170,0,10),Position=UDim2.fromOffset(5,181),BackgroundColor3=Color3.fromRGB(255,255,255),BorderSizePixel=0,ZIndex=100,Text=""},picker)
					corner(2,sel)
					local grad=newInst("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,0,0)),ColorSequenceKeypoint.new(0.17,Color3.new(1,0,1)),ColorSequenceKeypoint.new(0.33,Color3.new(0,0,1)),ColorSequenceKeypoint.new(0.5,Color3.new(0,1,1)),ColorSequenceKeypoint.new(0.67,Color3.new(0,1,0)),ColorSequenceKeypoint.new(0.83,Color3.new(1,1,0)),ColorSequenceKeypoint.new(1,Color3.new(1,0,0))})},sel)
					local ptr=newInst("Frame",{Size=UDim2.fromOffset(2,10),BackgroundColor3=Color3.fromRGB(255,255,255),BorderSizePixel=0,ZIndex=101},sel)

					if cp.flag~="" then library.flags[cp.flag]=cp.value end
					function cp:Set(v)
						cp.value=Color3.new(math.clamp(v.r,0,1),math.clamp(v.g,0,1),math.clamp(v.b,0,1))
						swatch.BackgroundColor3=cp.value
						if cp.flag~="" then library.flags[cp.flag]=cp.value end
						pcall(cp.callback,cp.value)
					end
					function cp:Get() return cp.value end
					function cp:RefreshHue()
						local x=(mouse.X-hue.AbsolutePosition.X)/hue.AbsoluteSize.X
						local y=(mouse.Y-hue.AbsolutePosition.Y)/hue.AbsoluteSize.Y
						hptr:TweenPosition(UDim2.new(math.clamp(x,0,0.95),0,math.clamp(y,0,0.88),0),Enum.EasingDirection.In,Enum.EasingStyle.Sine,0.05)
						cp:Set(Color3.fromHSV(cp.color or 0,math.clamp(x,0,1),1-math.clamp(y,0,1)))
					end
					function cp:RefreshSel()
						local pos=math.clamp((mouse.X-sel.AbsolutePosition.X)/sel.AbsoluteSize.X,0,1)
						cp.color=1-pos
						ptr:TweenPosition(UDim2.new(pos,0,0,0),Enum.EasingDirection.In,Enum.EasingStyle.Sine,0.05)
						hue.BackgroundColor3=Color3.fromHSV(1-pos,1,1)
					end

					local dh,ds=false,false
					hue.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dh=true;cp:RefreshHue() end end)
					hue.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dh=false end end)
					sel.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then ds=true;cp:RefreshSel() end end)
					sel.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then ds=false end end)
					uis.InputChanged:Connect(function(i)
						if i.UserInputType==Enum.UserInputType.MouseMovement then
							if dh then cp:RefreshHue() end
							if ds then cp:RefreshSel() end
						end
					end)
					swatch.InputBegan:Connect(function(i)
						if i.UserInputType==Enum.UserInputType.MouseButton1 then
							for p,_ in pairs(W.openedPickers) do p.Visible=false ; W.openedPickers[p]=false end
							picker.Visible=not picker.Visible ; W.openedPickers[picker]=picker.Visible
							ss.Color=picker.Visible and T.accent or T.outline
						end
					end)
					cp:Set(cp.value) ; table.insert(library.items,cp) ; return cp
				end

				-- ────────────────────────────────────────
				-- AddTextbox
				-- ────────────────────────────────────────
				function sector:AddTextbox(text, default, callback, flag)
					local tb={value="",flag=flag or text,callback=callback or function()end}
					local row=mkRow(34)
					mkText(row,text,Enum.TextXAlignment.Left,T.text,11).Size=UDim2.new(1,0,0,14)
					local box=newInst("TextBox",{
						Size=UDim2.new(1,0,0,18), Position=UDim2.fromOffset(0,16),
						BackgroundColor3=Color3.fromRGB(28,28,28), BorderSizePixel=0,
						Text="", PlaceholderText=text, PlaceholderColor3=T.textdim,
						Font=Enum.Font.Gotham, TextSize=11, TextColor3=T.textactive,
						ClearTextOnFocus=false, ZIndex=6, TextXAlignment=Enum.TextXAlignment.Left,
					},row)
					corner(4,box)
					local bs=stroke(T.outline,1,box)
					newInst("UIPadding",{PaddingLeft=UDim.new(0,6)},box)
					box.Focused:Connect(function() bs.Color=T.accent end)
					box.FocusLost:Connect(function() bs.Color=T.outline ; tb.value=box.Text ; if tb.flag~="" then library.flags[tb.flag]=box.Text end ; pcall(tb.callback,box.Text) end)
					if tb.flag~="" then library.flags[tb.flag]="" end
					function tb:Set(v) tb.value=v ; box.Text=v ; if tb.flag~="" then library.flags[tb.flag]=v end ; pcall(tb.callback,v) end
					if default then tb:Set(default) end
					table.insert(library.items,tb) ; return tb
				end

				-- ────────────────────────────────────────
				-- AddSeparator
				-- ────────────────────────────────────────
				function sector:AddSeparator(text)
					local row=mkRow(12)
					local line=newInst("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,0.5,0),BackgroundColor3=T.outline,BorderSizePixel=0,ZIndex=6},row)
					if text and text~="" then
						local ts=textservice:GetTextSize(text,10,Enum.Font.GothamBold,Vector2.new(2000,100))
						local bg=newInst("Frame",{Size=UDim2.fromOffset(ts.X+8,12),Position=UDim2.new(0.5,-(ts.X+8)/2,-0.5,0),BackgroundColor3=T.card,BorderSizePixel=0,ZIndex=7},line)
						mkText(bg,text,Enum.TextXAlignment.Center,T.textdim,10,Enum.Font.GothamBold,8).Size=UDim2.fromScale(1,1)
					end
				end

				return sector
			end -- CreateSector

			return st
		end -- CreateSubTab

		-- Shortcut: tab:CreateSector goes directly (no subtab)
		function tab:CreateSector(name, side)
			-- Create a default subtab if none exists
			if #tab.subtabs==0 then
				tab:CreateSubTab(tab.name)
			end
			return tab.subtabs[1]:CreateSector(name)
		end

		return tab
	end -- CreateTab

	-- ================================================================
	-- Notify
	-- ================================================================
	function W:Notify(title, desc, duration)
		duration = duration or 5
		local ng=newInst("ScreenGui",{Name="PhotonNotif",DisplayOrder=30},coregui)
		if syn then pcall(function() syn.protect_gui(ng) end) end

		local nf=newInst("Frame",{
			Size=UDim2.fromOffset(260, desc and 60 or 40),
			Position=UDim2.new(1,270,0,60), BackgroundColor3=Color3.fromRGB(22,22,22),
			BorderSizePixel=0,
		},ng)
		corner(6,nf) ; stroke(T.outline,1,nf)

		newInst("Frame",{Size=UDim2.fromOffset(3,nf.Size.Y.Offset),BackgroundColor3=T.accent,BorderSizePixel=0,ZIndex=4},nf)

		newInst("TextLabel",{
			Text=title, Font=Enum.Font.GothamBold, TextSize=12,
			TextColor3=T.textactive, BackgroundTransparency=1,
			Position=UDim2.fromOffset(12, desc and 8 or 12),
			Size=UDim2.fromOffset(236,16), ZIndex=5, TextXAlignment=Enum.TextXAlignment.Left,
		},nf)

		if desc then
			newInst("TextLabel",{
				Text=desc, Font=Enum.Font.Gotham, TextSize=10,
				TextColor3=T.textdim, BackgroundTransparency=1,
				Position=UDim2.fromOffset(12,28), Size=UDim2.fromOffset(236,22),
				ZIndex=5, TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true,
			},nf)
		end

		local pbg=newInst("Frame",{Size=UDim2.fromOffset(260,2),Position=UDim2.new(0,0,1,-2),BackgroundColor3=Color3.fromRGB(35,35,35),BorderSizePixel=0,ZIndex=4},nf)
		local pb=newInst("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=T.accent,BorderSizePixel=0,ZIndex=5},pbg)

		tween(nf,{Position=UDim2.new(1,-272,0,60)},0.3)
		task.wait(0.35)
		tweenservice:Create(pb,TweenInfo.new(duration,Enum.EasingStyle.Linear),{Size=UDim2.fromScale(0,1)}):Play()
		task.delay(duration,function()
			tween(nf,{Position=UDim2.new(1,270,0,60)},0.25)
			task.wait(0.3) ; ng:Destroy()
		end)
	end

	return W
end

function library:Notify(title,desc,duration)
	-- standalone notify (sans window)
	print("[Photon] "..tostring(title)..": "..tostring(desc or ""))
end

return library
