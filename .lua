-- ================================================================
-- PHOTON LIBRARY — Style External Photon (FIXED)
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

local T = {
	bg         = Color3.fromRGB(15,15,15),
	card       = Color3.fromRGB(26,26,26),
	cardheader = Color3.fromRGB(22,22,22),
	topbar     = Color3.fromRGB(18,18,18),
	tabbar     = Color3.fromRGB(12,12,12),
	sidebar    = Color3.fromRGB(20,20,20),
	accent     = Color3.fromRGB(232,51,58),
	outline    = Color3.fromRGB(40,40,40),
	text       = Color3.fromRGB(200,200,200),
	textdim    = Color3.fromRGB(120,120,120),
	textactive = Color3.fromRGB(255,255,255),
	slider     = Color3.fromRGB(35,35,35),
}

local knames={LeftShift="LSHIFT",RightShift="RSHIFT",LeftControl="LCTRL",RightControl="RCTRL",LeftAlt="LALT",RightAlt="RALT"}
local mbtns={[Enum.UserInputType.MouseButton1]="MB1",[Enum.UserInputType.MouseButton2]="MB2",[Enum.UserInputType.MouseButton3]="MB3"}
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
local function corner(r,p) local c=Instance.new("UICorner",p) c.CornerRadius=UDim.new(0,r) return c end
local function stroke(col,t,p) local s=Instance.new("UIStroke",p) s.Color=col s.Thickness=t s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border return s end
local function tween(o,props,t) tweenservice:Create(o,TweenInfo.new(t or 0.12),props):Play() end

function library:CreateWindow(name, size, hidekey)
	local W={name=name or "photon", tabs={}, openedPickers={}}
	local SW = size and size.X or 960
	local SH = size and size.Y or 580
	W.hidekey = hidekey or Enum.KeyCode.RightShift

	local TOPBAR_H  = 36
	local TABBAR_H  = 52
	local SIDEBAR_W = 160
	local CONTENT_TOP = TOPBAR_H + 2
	local CONTENT_H   = SH - CONTENT_TOP - TABBAR_H
	local COL_W = math.floor((SW - SIDEBAR_W - 30) / 2)

	-- ScreenGui
	W.gui = Instance.new("ScreenGui")
	W.gui.Name=name ; W.gui.DisplayOrder=20 ; W.gui.ResetOnSpawn=false ; W.gui.Parent=coregui
	if syn then pcall(function() syn.protect_gui(W.gui) end) end
	if getgenv then if getgenv().uilib then pcall(function() getgenv().uilib:Destroy() end) end ; getgenv().uilib=W.gui end

	-- Main frame
	W.frame = Instance.new("TextButton")
	W.frame.Name="Window" ; W.frame.Size=UDim2.fromOffset(SW,SH)
	W.frame.Position=UDim2.fromScale(0.5,0.5) ; W.frame.AnchorPoint=Vector2.new(0.5,0.5)
	W.frame.BackgroundColor3=T.bg ; W.frame.BorderSizePixel=0
	W.frame.AutoButtonColor=false ; W.frame.Text="" ; W.frame.ClipsDescendants=true
	W.frame.Parent=W.gui
	corner(8,W.frame) ; stroke(T.outline,1,W.frame)

	-- Drag
	local dragging,dstart,dpos
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

	-- TOPBAR
	local topbar=Instance.new("Frame",W.frame)
	topbar.Size=UDim2.fromOffset(SW,TOPBAR_H) ; topbar.BackgroundColor3=T.topbar ; topbar.BorderSizePixel=0 ; topbar.ZIndex=5

	local accentLine=Instance.new("Frame",W.frame)
	accentLine.Size=UDim2.fromOffset(SW,2) ; accentLine.Position=UDim2.fromOffset(0,TOPBAR_H)
	accentLine.BackgroundColor3=T.accent ; accentLine.BorderSizePixel=0 ; accentLine.ZIndex=4

	local titleLbl=Instance.new("TextLabel",topbar)
	titleLbl.Text=W.name:lower() ; titleLbl.Font=Enum.Font.GothamBold ; titleLbl.TextSize=16
	titleLbl.TextColor3=T.accent ; titleLbl.BackgroundTransparency=1
	titleLbl.Position=UDim2.fromOffset(14,0) ; titleLbl.Size=UDim2.fromOffset(200,TOPBAR_H)
	titleLbl.TextXAlignment=Enum.TextXAlignment.Left ; titleLbl.ZIndex=6

	local closeBtn=Instance.new("TextButton",topbar)
	closeBtn.Text="✕" ; closeBtn.Font=Enum.Font.GothamBold ; closeBtn.TextSize=13
	closeBtn.TextColor3=T.textdim ; closeBtn.BackgroundTransparency=1 ; closeBtn.BorderSizePixel=0
	closeBtn.Size=UDim2.fromOffset(30,30) ; closeBtn.Position=UDim2.new(1,-34,0,3) ; closeBtn.ZIndex=10 ; closeBtn.AutoButtonColor=false
	closeBtn.MouseEnter:Connect(function() tween(closeBtn,{TextColor3=T.accent}) end)
	closeBtn.MouseLeave:Connect(function() tween(closeBtn,{TextColor3=T.textdim}) end)
	closeBtn.MouseButton1Down:Connect(function() W.gui:Destroy() end)

	local minBtn=Instance.new("TextButton",topbar)
	minBtn.Text="─" ; minBtn.Font=Enum.Font.GothamBold ; minBtn.TextSize=13
	minBtn.TextColor3=T.textdim ; minBtn.BackgroundTransparency=1 ; minBtn.BorderSizePixel=0
	minBtn.Size=UDim2.fromOffset(30,30) ; minBtn.Position=UDim2.new(1,-64,0,3) ; minBtn.ZIndex=10 ; minBtn.AutoButtonColor=false
	minBtn.MouseEnter:Connect(function() tween(minBtn,{TextColor3=T.textactive}) end)
	minBtn.MouseLeave:Connect(function() tween(minBtn,{TextColor3=T.textdim}) end)
	local minimized=false
	minBtn.MouseButton1Down:Connect(function()
		minimized=not minimized
		W.frame:TweenSize(UDim2.fromOffset(SW,minimized and TOPBAR_H+2 or SH),Enum.EasingDirection.Out,Enum.EasingStyle.Quint,0.2)
	end)

	-- TABBAR
	local tabbar=Instance.new("Frame",W.frame)
	tabbar.Name="TabBar" ; tabbar.Size=UDim2.fromOffset(SW,TABBAR_H)
	tabbar.Position=UDim2.fromOffset(0,SH-TABBAR_H) ; tabbar.BackgroundColor3=T.tabbar ; tabbar.BorderSizePixel=0 ; tabbar.ZIndex=5

	local tabLine=Instance.new("Frame",W.frame)
	tabLine.Size=UDim2.fromOffset(SW,1) ; tabLine.Position=UDim2.fromOffset(0,SH-TABBAR_H-1)
	tabLine.BackgroundColor3=T.outline ; tabLine.BorderSizePixel=0 ; tabLine.ZIndex=4

	local tabLayout=Instance.new("UIListLayout",tabbar)
	tabLayout.FillDirection=Enum.FillDirection.Horizontal
	tabLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center
	tabLayout.VerticalAlignment=Enum.VerticalAlignment.Center
	tabLayout.SortOrder=Enum.SortOrder.LayoutOrder ; tabLayout.Padding=UDim.new(0,2)

	W.tabInd=Instance.new("Frame",tabbar)
	W.tabInd.Size=UDim2.fromOffset(60,2) ; W.tabInd.Position=UDim2.fromOffset(0,0)
	W.tabInd.BackgroundColor3=T.accent ; W.tabInd.BorderSizePixel=0 ; W.tabInd.ZIndex=8

	-- CONTENT
	W.content=Instance.new("Frame",W.frame)
	W.content.Name="Content" ; W.content.Size=UDim2.fromOffset(SW,CONTENT_H)
	W.content.Position=UDim2.fromOffset(0,CONTENT_TOP) ; W.content.BackgroundTransparency=1
	W.content.BorderSizePixel=0 ; W.content.ZIndex=2 ; W.content.ClipsDescendants=true

	-- Sidebar background (persistent)
	local sidebarBG=Instance.new("Frame",W.content)
	sidebarBG.Size=UDim2.fromOffset(SIDEBAR_W,CONTENT_H) ; sidebarBG.BackgroundColor3=T.sidebar ; sidebarBG.BorderSizePixel=0 ; sidebarBG.ZIndex=2
	local sideBorder=Instance.new("Frame",sidebarBG)
	sideBorder.Size=UDim2.fromOffset(1,CONTENT_H) ; sideBorder.Position=UDim2.new(1,-1,0,0)
	sideBorder.BackgroundColor3=T.outline ; sideBorder.BorderSizePixel=0 ; sideBorder.ZIndex=3

	-- ================================================================
	-- CreateTab
	-- ================================================================
	function W:CreateTab(name, icon)
		local tab={name=name, subtabs={}}
		local btnW=math.max(72,textservice:GetTextSize(name,11,Enum.Font.Gotham,Vector2.new(300,50)).X+36)

		tab.btn=Instance.new("TextButton",tabbar)
		tab.btn.Size=UDim2.fromOffset(btnW,TABBAR_H) ; tab.btn.BackgroundTransparency=1
		tab.btn.BorderSizePixel=0 ; tab.btn.AutoButtonColor=false ; tab.btn.ZIndex=6 ; tab.btn.Text="" ; tab.btn.Name=name
		tab.btn.LayoutOrder=#W.tabs+1

		if icon and icon~="" then
			local ico=Instance.new("ImageLabel",tab.btn)
			ico.Image=icon ; ico.Size=UDim2.fromOffset(20,20) ; ico.Position=UDim2.new(0.5,-10,0,5)
			ico.BackgroundTransparency=1 ; ico.ImageColor3=T.textdim ; ico.ZIndex=7
		end

		tab.btnLabel=Instance.new("TextLabel",tab.btn)
		tab.btnLabel.Text=name ; tab.btnLabel.Font=Enum.Font.Gotham ; tab.btnLabel.TextSize=11
		tab.btnLabel.TextColor3=T.textdim ; tab.btnLabel.BackgroundTransparency=1
		tab.btnLabel.ZIndex=7 ; tab.btnLabel.TextXAlignment=Enum.TextXAlignment.Center
		tab.btnLabel.Size=UDim2.fromOffset(btnW,TABBAR_H)

		tab.container=Instance.new("Frame",W.content)
		tab.container.Size=UDim2.fromOffset(SW,CONTENT_H) ; tab.container.BackgroundTransparency=1
		tab.container.Visible=false ; tab.container.ZIndex=3

		-- Sidebar entries for this tab
		tab.sidebar=Instance.new("Frame",tab.container)
		tab.sidebar.Size=UDim2.fromOffset(SIDEBAR_W,CONTENT_H) ; tab.sidebar.BackgroundTransparency=1 ; tab.sidebar.ZIndex=4
		local sideLL=Instance.new("UIListLayout",tab.sidebar)
		sideLL.FillDirection=Enum.FillDirection.Vertical ; sideLL.SortOrder=Enum.SortOrder.LayoutOrder ; sideLL.Padding=UDim.new(0,2)
		local sidePad=Instance.new("UIPadding",tab.sidebar)
		sidePad.PaddingTop=UDim.new(0,8) ; sidePad.PaddingLeft=UDim.new(0,6) ; sidePad.PaddingRight=UDim.new(0,6)

		-- Left column
		tab.leftCol=Instance.new("ScrollingFrame",tab.container)
		tab.leftCol.Size=UDim2.fromOffset(COL_W,CONTENT_H) ; tab.leftCol.Position=UDim2.fromOffset(SIDEBAR_W+8,0)
		tab.leftCol.BackgroundTransparency=1 ; tab.leftCol.BorderSizePixel=0
		tab.leftCol.ScrollBarThickness=3 ; tab.leftCol.ScrollingDirection=Enum.ScrollingDirection.Y
		tab.leftCol.ScrollBarImageColor3=T.accent ; tab.leftCol.AutomaticCanvasSize=Enum.AutomaticSize.Y
		tab.leftCol.CanvasSize=UDim2.fromOffset(0,0) ; tab.leftCol.ZIndex=3
		local leftLL=Instance.new("UIListLayout",tab.leftCol)
		leftLL.FillDirection=Enum.FillDirection.Vertical ; leftLL.SortOrder=Enum.SortOrder.LayoutOrder ; leftLL.Padding=UDim.new(0,8)
		local leftPad=Instance.new("UIPadding",tab.leftCol)
		leftPad.PaddingTop=UDim.new(0,8) ; leftPad.PaddingBottom=UDim.new(0,8)

		-- Right column
		tab.rightCol=Instance.new("ScrollingFrame",tab.container)
		tab.rightCol.Size=UDim2.fromOffset(COL_W,CONTENT_H) ; tab.rightCol.Position=UDim2.fromOffset(SIDEBAR_W+COL_W+16,0)
		tab.rightCol.BackgroundTransparency=1 ; tab.rightCol.BorderSizePixel=0
		tab.rightCol.ScrollBarThickness=3 ; tab.rightCol.ScrollingDirection=Enum.ScrollingDirection.Y
		tab.rightCol.ScrollBarImageColor3=T.accent ; tab.rightCol.AutomaticCanvasSize=Enum.AutomaticSize.Y
		tab.rightCol.CanvasSize=UDim2.fromOffset(0,0) ; tab.rightCol.ZIndex=3
		local rightLL=Instance.new("UIListLayout",tab.rightCol)
		rightLL.FillDirection=Enum.FillDirection.Vertical ; rightLL.SortOrder=Enum.SortOrder.LayoutOrder ; rightLL.Padding=UDim.new(0,8)
		local rightPad=Instance.new("UIPadding",tab.rightCol)
		rightPad.PaddingTop=UDim.new(0,8) ; rightPad.PaddingBottom=UDim.new(0,8)

		function tab:Select()
			for _,t in pairs(W.tabs) do
				t.container.Visible=false
				t.btnLabel.TextColor3=T.textdim ; t.btnLabel.Font=Enum.Font.Gotham
			end
			tab.container.Visible=true
			tab.btnLabel.TextColor3=T.accent ; tab.btnLabel.Font=Enum.Font.GothamBold
			local bx=tab.btn.AbsolutePosition.X-tabbar.AbsolutePosition.X
			tween(W.tabInd,{Position=UDim2.fromOffset(bx,0),Size=UDim2.fromOffset(tab.btn.AbsoluteSize.X,2)},0.15)
			if tab.subtabs[1] then tab.subtabs[1]:Select() end
		end
		tab.btn.MouseButton1Down:Connect(function() tab:Select() end)
		if #W.tabs==0 then task.defer(function() tab:Select() end) end
		table.insert(W.tabs,tab)

		-- ================================================================
		-- CreateSubTab
		-- ================================================================
		function tab:CreateSubTab(name)
			local st={name=name, leftSectors={}, rightSectors={}}

			st.btn=Instance.new("TextButton",tab.sidebar)
			st.btn.Size=UDim2.new(1,0,0,28) ; st.btn.BackgroundColor3=Color3.fromRGB(30,30,30)
			st.btn.BackgroundTransparency=1 ; st.btn.BorderSizePixel=0
			st.btn.AutoButtonColor=false ; st.btn.ZIndex=5 ; st.btn.Text="" ; st.btn.LayoutOrder=#tab.subtabs+1
			corner(4,st.btn)

			st.accentBar=Instance.new("Frame",st.btn)
			st.accentBar.Size=UDim2.fromOffset(3,14) ; st.accentBar.Position=UDim2.new(0,0,0.5,-7)
			st.accentBar.BackgroundColor3=T.accent ; st.accentBar.BorderSizePixel=0 ; st.accentBar.ZIndex=7 ; st.accentBar.Visible=false
			corner(2,st.accentBar)

			st.label=Instance.new("TextLabel",st.btn)
			st.label.Text=name ; st.label.Font=Enum.Font.Gotham ; st.label.TextSize=12
			st.label.TextColor3=T.textdim ; st.label.BackgroundTransparency=1
			st.label.Size=UDim2.fromScale(1,1) ; st.label.ZIndex=6 ; st.label.TextXAlignment=Enum.TextXAlignment.Left
			local lp=Instance.new("UIPadding",st.label) ; lp.PaddingLeft=UDim.new(0,12)

			function st:Select()
				for _,s in pairs(tab.subtabs) do
					tween(s.label,{TextColor3=T.textdim}) ; s.label.Font=Enum.Font.Gotham
					tween(s.btn,{BackgroundTransparency=1}) ; s.accentBar.Visible=false
					for _,sec in pairs(s.leftSectors) do sec.frame.Visible=false end
					for _,sec in pairs(s.rightSectors) do sec.frame.Visible=false end
				end
				for _,sec in pairs(st.leftSectors) do sec.frame.Visible=true end
				for _,sec in pairs(st.rightSectors) do sec.frame.Visible=true end
				tween(st.label,{TextColor3=T.textactive}) ; st.label.Font=Enum.Font.GothamBold
				tween(st.btn,{BackgroundTransparency=0}) ; st.accentBar.Visible=true
			end
			st.btn.MouseButton1Down:Connect(function() st:Select() end)
			st.btn.MouseEnter:Connect(function() if not st.accentBar.Visible then tween(st.btn,{BackgroundTransparency=0.7}) end end)
			st.btn.MouseLeave:Connect(function() if not st.accentBar.Visible then tween(st.btn,{BackgroundTransparency=1}) end end)
			if #tab.subtabs==0 then task.defer(function() st:Select() end) end
			table.insert(tab.subtabs,st)

			-- ================================================================
			-- CreateSector
			-- ================================================================
			function st:CreateSector(name, col)
				local sector={name=name}
				local isLeft=(col or "left"):lower()~="right"
				local parentCol=isLeft and tab.leftCol or tab.rightCol
				local sectorList=isLeft and st.leftSectors or st.rightSectors

				sector.frame=Instance.new("Frame",parentCol)
				sector.frame.Name=name.."Sector" ; sector.frame.BackgroundColor3=T.card
				sector.frame.BorderSizePixel=0 ; sector.frame.ZIndex=4
				sector.frame.AutomaticSize=Enum.AutomaticSize.Y
				sector.frame.Size=UDim2.new(1,0,0,0)
				sector.frame.LayoutOrder=#sectorList+1
				corner(6,sector.frame) ; stroke(T.outline,1,sector.frame)

				-- Red top accent
				local redLine=Instance.new("Frame",sector.frame)
				redLine.Size=UDim2.new(1,0,0,2) ; redLine.BackgroundColor3=T.accent ; redLine.BorderSizePixel=0 ; redLine.ZIndex=6

				-- Header
				local header=Instance.new("Frame",sector.frame)
				header.Size=UDim2.new(1,0,0,24) ; header.BackgroundColor3=T.cardheader ; header.BorderSizePixel=0 ; header.ZIndex=5
				corner(6,header)
				local hfix=Instance.new("Frame",header)
				hfix.Size=UDim2.new(1,0,0,8) ; hfix.Position=UDim2.new(0,0,1,-8) ; hfix.BackgroundColor3=T.cardheader ; hfix.BorderSizePixel=0 ; hfix.ZIndex=5
				local htitle=Instance.new("TextLabel",header)
				htitle.Text=name:upper() ; htitle.Font=Enum.Font.GothamBold ; htitle.TextSize=10
				htitle.TextColor3=T.textactive ; htitle.BackgroundTransparency=1
				htitle.Size=UDim2.new(1,-12,1,0) ; htitle.Position=UDim2.fromOffset(10,0)
				htitle.TextXAlignment=Enum.TextXAlignment.Left ; htitle.ZIndex=7

				-- Items list
				sector.list=Instance.new("Frame",sector.frame)
				sector.list.Name="Items" ; sector.list.BackgroundTransparency=1 ; sector.list.BorderSizePixel=0
				sector.list.ZIndex=5 ; sector.list.AutomaticSize=Enum.AutomaticSize.Y
				sector.list.Size=UDim2.new(1,0,0,0) ; sector.list.Position=UDim2.fromOffset(0,26)
				local listLL=Instance.new("UIListLayout",sector.list)
				listLL.FillDirection=Enum.FillDirection.Vertical ; listLL.SortOrder=Enum.SortOrder.LayoutOrder ; listLL.Padding=UDim.new(0,6)
				local listPad=Instance.new("UIPadding",sector.list)
				listPad.PaddingTop=UDim.new(0,8) ; listPad.PaddingBottom=UDim.new(0,10)
				listPad.PaddingLeft=UDim.new(0,10) ; listPad.PaddingRight=UDim.new(0,10)

				table.insert(sectorList,sector)

				local function mkRow(h)
					local f=Instance.new("Frame",sector.list)
					f.BackgroundTransparency=1 ; f.BorderSizePixel=0 ; f.ZIndex=5 ; f.Size=UDim2.new(1,0,0,h)
					return f
				end
				local function mkLbl(parent,txt,xa,col,sz,font,zi)
					local l=Instance.new("TextLabel",parent)
					l.Text=txt or "" ; l.Font=font or Enum.Font.Gotham ; l.TextSize=sz or 11
					l.TextColor3=col or T.text ; l.BackgroundTransparency=1 ; l.BorderSizePixel=0
					l.ZIndex=zi or 6 ; l.TextXAlignment=xa or Enum.TextXAlignment.Left ; l.TextStrokeTransparency=1
					return l
				end

				function sector:AddLabel(text,color)
					local row=mkRow(14)
					local bar=Instance.new("Frame",row) ; bar.Size=UDim2.fromOffset(2,12) ; bar.Position=UDim2.new(0,0,0.5,-6)
					bar.BackgroundColor3=T.accent ; bar.BorderSizePixel=0 ; bar.ZIndex=6 ; corner(1,bar)
					local lbl=mkLbl(row,text,Enum.TextXAlignment.Left,color or T.textdim,11)
					lbl.Position=UDim2.fromOffset(8,0) ; lbl.Size=UDim2.new(1,-8,1,0) ; lbl.TextWrapped=true
					local obj={Main=row} ; function obj:Set(v) lbl.Text=tostring(v) end ; return obj
				end

				function sector:AddButton(text,callback)
					local row=mkRow(26)
					local btn=Instance.new("TextButton",row)
					btn.Text="" ; btn.BackgroundColor3=Color3.fromRGB(36,36,36) ; btn.BorderSizePixel=0
					btn.AutoButtonColor=false ; btn.ZIndex=6 ; btn.Size=UDim2.fromScale(1,1)
					corner(4,btn) ; local bs=stroke(T.outline,1,btn)
					local lbl=mkLbl(btn,text,Enum.TextXAlignment.Center,T.textactive,11,Enum.Font.GothamBold,7)
					lbl.Size=UDim2.fromScale(1,1)
					btn.MouseEnter:Connect(function() bs.Color=T.accent ; tween(btn,{BackgroundColor3=Color3.fromRGB(42,42,42)}) end)
					btn.MouseLeave:Connect(function() bs.Color=T.outline ; tween(btn,{BackgroundColor3=Color3.fromRGB(36,36,36)}) end)
					btn.MouseButton1Down:Connect(function()
						tween(btn,{BackgroundColor3=T.accent},0.05)
						task.delay(0.12,function() tween(btn,{BackgroundColor3=Color3.fromRGB(36,36,36)},0.1) end)
						pcall(callback)
					end)
					return {Main=row}
				end

				function sector:AddToggle(text,default,callback,flag)
					local toggle={value=default or false,flag=flag or text,callback=callback or function()end}
					local row=mkRow(18)
					local box=Instance.new("TextButton",row)
					box.Size=UDim2.fromOffset(15,15) ; box.Position=UDim2.new(0,0,0.5,-7)
					box.BackgroundColor3=Color3.fromRGB(28,28,28) ; box.BorderSizePixel=0
					box.AutoButtonColor=false ; box.ZIndex=6 ; box.Text="" ; corner(3,box)
					local boxS=stroke(Color3.fromRGB(60,60,60),1,box)
					local check=Instance.new("Frame",box)
					check.Size=UDim2.fromOffset(9,9) ; check.Position=UDim2.fromOffset(3,3)
					check.BackgroundColor3=T.accent ; check.BorderSizePixel=0 ; check.ZIndex=7 ; check.Visible=false ; corner(2,check)
					local lbl=Instance.new("TextButton",row)
					lbl.Text=text ; lbl.Font=Enum.Font.Gotham ; lbl.TextSize=11 ; lbl.TextColor3=T.text
					lbl.BackgroundTransparency=1 ; lbl.BorderSizePixel=0 ; lbl.Position=UDim2.fromOffset(22,0)
					lbl.Size=UDim2.new(1,-90,1,0) ; lbl.ZIndex=6 ; lbl.AutoButtonColor=false ; lbl.TextXAlignment=Enum.TextXAlignment.Left
					toggle.items=Instance.new("Frame",row)
					toggle.items.Size=UDim2.fromOffset(65,18) ; toggle.items.Position=UDim2.new(1,-65,0,0)
					toggle.items.BackgroundTransparency=1 ; toggle.items.BorderSizePixel=0 ; toggle.items.ZIndex=6
					local til=Instance.new("UIListLayout",toggle.items) ; til.FillDirection=Enum.FillDirection.Horizontal
					til.HorizontalAlignment=Enum.HorizontalAlignment.Right ; til.SortOrder=Enum.SortOrder.LayoutOrder ; til.Padding=UDim.new(0,4)
					if toggle.flag~="" then library.flags[toggle.flag]=toggle.value end
					function toggle:Set(v)
						toggle.value=v ; check.Visible=v ; boxS.Color=v and T.accent or Color3.fromRGB(60,60,60)
						lbl.TextColor3=v and T.textactive or T.text
						if toggle.flag~="" then library.flags[toggle.flag]=v end ; pcall(toggle.callback,v)
					end
					function toggle:Get() return toggle.value end
					toggle:Set(toggle.value)
					local function click() toggle:Set(not toggle.value) end
					box.MouseButton1Down:Connect(click)
					lbl.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then click() end end)
					function toggle:AddKeybind(default,kflag)
						local kb={value=default or "None",flag=kflag or (text.."kb")}
						local kbtn=Instance.new("TextButton",toggle.items)
						kbtn.Text=kbText(kb.value) ; kbtn.Font=Enum.Font.Gotham ; kbtn.TextSize=10
						kbtn.TextColor3=T.textdim ; kbtn.BackgroundTransparency=1 ; kbtn.BorderSizePixel=0
						kbtn.Size=UDim2.fromOffset(55,16) ; kbtn.ZIndex=7 ; kbtn.AutoButtonColor=false ; kbtn.TextXAlignment=Enum.TextXAlignment.Right
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

				function sector:AddSlider(text,min,default,max,decimals,callback,flag)
					local slider={min=min or 0,max=max or 100,decimals=decimals or 1,
						value=default or min or 0,flag=flag or text,callback=callback or function()end}
					local row=mkRow(34)
					local lr=Instance.new("Frame",row) ; lr.Size=UDim2.new(1,0,0,14) ; lr.BackgroundTransparency=1 ; lr.BorderSizePixel=0 ; lr.ZIndex=5
					mkLbl(lr,text,Enum.TextXAlignment.Left,T.text,11).Size=UDim2.new(0.7,0,1,0)
					slider.valLabel=mkLbl(lr,tostring(slider.value),Enum.TextXAlignment.Right,T.accent,11,Enum.Font.GothamBold)
					slider.valLabel.Size=UDim2.fromScale(1,1)
					local track=Instance.new("TextButton",row)
					track.Size=UDim2.new(1,0,0,5) ; track.Position=UDim2.fromOffset(0,18) ; track.BackgroundColor3=T.slider
					track.BorderSizePixel=0 ; track.AutoButtonColor=false ; track.ZIndex=6 ; track.Text="" ; corner(3,track)
					local fill=Instance.new("Frame",track) ; fill.Size=UDim2.fromOffset(0,5) ; fill.BackgroundColor3=T.accent ; fill.BorderSizePixel=0 ; fill.ZIndex=7 ; corner(3,fill)
					local thumb=Instance.new("Frame",track) ; thumb.Size=UDim2.fromOffset(10,10) ; thumb.Position=UDim2.fromOffset(-5,-3)
					thumb.BackgroundColor3=Color3.fromRGB(220,220,220) ; thumb.BorderSizePixel=0 ; thumb.ZIndex=8 ; corner(5,thumb) ; stroke(T.accent,1,thumb)
					if slider.flag~="" then library.flags[slider.flag]=slider.value end
					function slider:Set(v)
						slider.value=math.clamp(math.round(v*slider.decimals)/slider.decimals,slider.min,slider.max)
						local pct=(slider.value-slider.min)/(slider.max-slider.min)
						local px=pct*track.AbsoluteSize.X
						fill:TweenSize(UDim2.fromOffset(px,5),Enum.EasingDirection.In,Enum.EasingStyle.Linear,0.04)
						thumb:TweenPosition(UDim2.fromOffset(px-5,-3),Enum.EasingDirection.In,Enum.EasingStyle.Linear,0.04)
						slider.valLabel.Text=slider.value
						if slider.flag~="" then library.flags[slider.flag]=slider.value end ; pcall(slider.callback,slider.value)
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
					table.insert(library.items,slider) ; return slider
				end

				function sector:AddDropdown(text,items,default,multi,callback,flag)
					local dd={values={},items=items or {},multi=multi or false,flag=flag or text,callback=callback or function()end}
					local row=mkRow(34)
					mkLbl(row,text,Enum.TextXAlignment.Left,T.text,11).Size=UDim2.new(1,0,0,14)
					local main=Instance.new("TextButton",row)
					main.Size=UDim2.new(1,0,0,18) ; main.Position=UDim2.fromOffset(0,16) ; main.BackgroundColor3=Color3.fromRGB(28,28,28)
					main.BorderSizePixel=0 ; main.AutoButtonColor=false ; main.ZIndex=6 ; main.Text="" ; corner(4,main)
					local ms=stroke(T.outline,1,main)
					dd.selLabel=mkLbl(main,default or (items[1] or ""),Enum.TextXAlignment.Left,Color3.fromRGB(175,175,175),11)
					dd.selLabel.Size=UDim2.new(1,-20,1,0) ; dd.selLabel.Position=UDim2.fromOffset(7,0)
					local arrow=mkLbl(main,"▾",Enum.TextXAlignment.Center,T.textdim,11)
					arrow.Size=UDim2.fromOffset(16,18) ; arrow.Position=UDim2.new(1,-18,0,0)
					local list=Instance.new("ScrollingFrame",main)
					list.Size=UDim2.fromOffset(0,0) ; list.Position=UDim2.fromOffset(0,22) ; list.BackgroundColor3=Color3.fromRGB(22,22,22)
					list.BorderSizePixel=0 ; list.ZIndex=20 ; list.Visible=false ; list.ScrollBarThickness=2 ; list.ScrollBarImageColor3=T.accent ; list.CanvasSize=UDim2.fromOffset(0,0)
					corner(4,list) ; stroke(T.outline,1,list)
					local ll2=Instance.new("UIListLayout",list) ; ll2.SortOrder=Enum.SortOrder.LayoutOrder
					local lp3=Instance.new("UIPadding",list) ; lp3.PaddingTop=UDim.new(0,3) ; lp3.PaddingBottom=UDim.new(0,3) ; lp3.PaddingLeft=UDim.new(0,3) ; lp3.PaddingRight=UDim.new(0,3)
					if dd.flag~="" then library.flags[dd.flag]=default or (items[1] or "") end
					function dd:isSelected(v) for _,x in pairs(dd.values) do if x==v then return true end end return false end
					function dd:Set(v)
						if type(v)=="table" then dd.values=v ; dd.selLabel.Text=#v>0 and table.concat(v,", ") or ""
						else dd.values={v} ; dd.selLabel.Text=v end
						if dd.flag~="" then library.flags[dd.flag]=dd.multi and dd.values or dd.values[1] end
						pcall(dd.callback,dd.multi and dd.values or dd.values[1])
					end
					function dd:Get() return dd.multi and dd.values or dd.values[1] end
					for _,v in pairs(dd.items) do
						local item=Instance.new("TextButton",list)
						item.Text=v ; item.Font=Enum.Font.Gotham ; item.TextSize=11 ; item.TextColor3=Color3.fromRGB(175,175,175)
						item.BackgroundColor3=Color3.fromRGB(28,28,28) ; item.BorderSizePixel=0 ; item.Size=UDim2.new(1,0,0,18)
						item.AutoButtonColor=false ; item.ZIndex=21 ; item.TextXAlignment=Enum.TextXAlignment.Left ; corner(3,item)
						local ip=Instance.new("UIPadding",item) ; ip.PaddingLeft=UDim.new(0,5)
						item.MouseButton1Down:Connect(function()
							if dd.multi then
								if dd:isSelected(v) then for i2,x in pairs(dd.values) do if x==v then table.remove(dd.values,i2) end end ; dd:Set(dd.values)
								else table.insert(dd.values,v) ; dd:Set(dd.values) end ; return
							end
							arrow.Text="▾" ; list.Visible=false ; ms.Color=T.outline ; row.Size=UDim2.new(1,0,0,34) ; dd:Set(v)
						end)
						runservice.RenderStepped:Connect(function()
							if dd:isSelected(v) then item.TextColor3=T.accent ; item.BackgroundColor3=Color3.fromRGB(38,38,38)
							else item.TextColor3=Color3.fromRGB(175,175,175) ; item.BackgroundColor3=Color3.fromRGB(28,28,28) end
						end)
					end
					main.MouseButton1Down:Connect(function()
						list.Visible=not list.Visible ; arrow.Text=list.Visible and "▴" or "▾" ; ms.Color=list.Visible and T.accent or T.outline
						if list.Visible then local h=math.clamp(#dd.items*18+6,18,110) ; list.Size=UDim2.fromOffset(main.AbsoluteSize.X,h) ; list.CanvasSize=UDim2.fromOffset(0,#dd.items*18+6) ; row.Size=UDim2.new(1,0,0,34+h+4)
						else row.Size=UDim2.new(1,0,0,34) end
					end)
					main.MouseEnter:Connect(function() ms.Color=T.accent end)
					main.MouseLeave:Connect(function() if not list.Visible then ms.Color=T.outline end end)
					if default then dd:Set(default) end
					table.insert(library.items,dd) ; return dd
				end

				function sector:AddColorpicker(text,default,callback,flag)
					local cp={value=default or Color3.new(1,1,1),flag=flag or text,callback=callback or function()end,color=0}
					local row=mkRow(18)
					mkLbl(row,text,Enum.TextXAlignment.Left,T.text,11).Size=UDim2.new(1,-40,1,0)
					local swatch=Instance.new("TextButton",row)
					swatch.Size=UDim2.fromOffset(30,14) ; swatch.Position=UDim2.new(1,-30,0.5,-7) ; swatch.BackgroundColor3=cp.value
					swatch.BorderSizePixel=0 ; swatch.ZIndex=6 ; swatch.AutoButtonColor=false ; swatch.Text="" ; corner(3,swatch)
					local ss=stroke(T.outline,1,swatch)
					local picker=Instance.new("TextButton",swatch)
					picker.Size=UDim2.fromOffset(180,196) ; picker.Position=UDim2.fromOffset(-150,18) ; picker.BackgroundColor3=Color3.fromRGB(26,26,26)
					picker.BorderSizePixel=0 ; picker.ZIndex=100 ; picker.Visible=false ; picker.AutoButtonColor=false ; picker.Text=""
					corner(6,picker) ; stroke(T.outline,1,picker) ; W.openedPickers[picker]=false
					local hue=Instance.new("ImageLabel",picker) ; hue.Image="rbxassetid://4155801252" ; hue.Size=UDim2.new(0,170,0,170) ; hue.Position=UDim2.fromOffset(5,5) ; hue.ZIndex=101 ; hue.ScaleType=Enum.ScaleType.Stretch ; hue.BackgroundColor3=Color3.new(1,0,0) ; hue.BorderSizePixel=0
					local hptr=Instance.new("ImageLabel",picker) ; hptr.Image="rbxassetid://6885856475" ; hptr.Size=UDim2.fromOffset(7,7) ; hptr.ZIndex=102 ; hptr.BackgroundTransparency=1 ; hptr.BorderSizePixel=0
					local sel=Instance.new("TextLabel",picker) ; sel.Size=UDim2.new(0,170,0,10) ; sel.Position=UDim2.fromOffset(5,181) ; sel.BackgroundColor3=Color3.fromRGB(255,255,255) ; sel.BorderSizePixel=0 ; sel.ZIndex=100 ; sel.Text="" ; corner(2,sel)
					local grad=Instance.new("UIGradient",sel) ; grad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,0,0)),ColorSequenceKeypoint.new(0.17,Color3.new(1,0,1)),ColorSequenceKeypoint.new(0.33,Color3.new(0,0,1)),ColorSequenceKeypoint.new(0.5,Color3.new(0,1,1)),ColorSequenceKeypoint.new(0.67,Color3.new(0,1,0)),ColorSequenceKeypoint.new(0.83,Color3.new(1,1,0)),ColorSequenceKeypoint.new(1,Color3.new(1,0,0))})
					local ptr=Instance.new("Frame",sel) ; ptr.Size=UDim2.fromOffset(2,10) ; ptr.BackgroundColor3=Color3.fromRGB(255,255,255) ; ptr.BorderSizePixel=0 ; ptr.ZIndex=101
					if cp.flag~="" then library.flags[cp.flag]=cp.value end
					function cp:Set(v) cp.value=Color3.new(math.clamp(v.r,0,1),math.clamp(v.g,0,1),math.clamp(v.b,0,1)) ; swatch.BackgroundColor3=cp.value ; if cp.flag~="" then library.flags[cp.flag]=cp.value end ; pcall(cp.callback,cp.value) end
					function cp:Get() return cp.value end
					function cp:RefreshHue() local x=(mouse.X-hue.AbsolutePosition.X)/hue.AbsoluteSize.X ; local y=(mouse.Y-hue.AbsolutePosition.Y)/hue.AbsoluteSize.Y ; hptr:TweenPosition(UDim2.new(math.clamp(x,0,0.95),0,math.clamp(y,0,0.88),0),Enum.EasingDirection.In,Enum.EasingStyle.Sine,0.05) ; cp:Set(Color3.fromHSV(cp.color or 0,math.clamp(x,0,1),1-math.clamp(y,0,1))) end
					function cp:RefreshSel() local pos=math.clamp((mouse.X-sel.AbsolutePosition.X)/sel.AbsoluteSize.X,0,1) ; cp.color=1-pos ; ptr:TweenPosition(UDim2.new(pos,0,0,0),Enum.EasingDirection.In,Enum.EasingStyle.Sine,0.05) ; hue.BackgroundColor3=Color3.fromHSV(1-pos,1,1) end
					local dh,ds=false,false
					hue.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dh=true;cp:RefreshHue() end end) ; hue.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dh=false end end)
					sel.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then ds=true;cp:RefreshSel() end end) ; sel.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then ds=false end end)
					uis.InputChanged:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseMovement then if dh then cp:RefreshHue() end if ds then cp:RefreshSel() end end end)
					swatch.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then for p,_ in pairs(W.openedPickers) do p.Visible=false ; W.openedPickers[p]=false end ; picker.Visible=not picker.Visible ; W.openedPickers[picker]=picker.Visible ; ss.Color=picker.Visible and T.accent or T.outline end end)
					cp:Set(cp.value) ; table.insert(library.items,cp) ; return cp
				end

				function sector:AddTextbox(text,default,callback,flag)
					local tb={value="",flag=flag or text,callback=callback or function()end}
					local row=mkRow(34)
					mkLbl(row,text,Enum.TextXAlignment.Left,T.text,11).Size=UDim2.new(1,0,0,14)
					local box=Instance.new("TextBox",row)
					box.Size=UDim2.new(1,0,0,18) ; box.Position=UDim2.fromOffset(0,16) ; box.BackgroundColor3=Color3.fromRGB(28,28,28)
					box.BorderSizePixel=0 ; box.Text="" ; box.PlaceholderText=text ; box.PlaceholderColor3=T.textdim
					box.Font=Enum.Font.Gotham ; box.TextSize=11 ; box.TextColor3=T.textactive ; box.ClearTextOnFocus=false ; box.ZIndex=6 ; box.TextXAlignment=Enum.TextXAlignment.Left
					corner(4,box) ; local bs=stroke(T.outline,1,box) ; local bp=Instance.new("UIPadding",box) ; bp.PaddingLeft=UDim.new(0,6)
					box.Focused:Connect(function() bs.Color=T.accent end)
					box.FocusLost:Connect(function() bs.Color=T.outline ; tb.value=box.Text ; if tb.flag~="" then library.flags[tb.flag]=box.Text end ; pcall(tb.callback,box.Text) end)
					if tb.flag~="" then library.flags[tb.flag]="" end
					function tb:Set(v) tb.value=v ; box.Text=v ; if tb.flag~="" then library.flags[tb.flag]=v end ; pcall(tb.callback,v) end
					if default then tb:Set(default) end
					table.insert(library.items,tb) ; return tb
				end

				function sector:AddSeparator(text)
					local row=mkRow(12)
					local line=Instance.new("Frame",row) ; line.Size=UDim2.new(1,0,0,1) ; line.Position=UDim2.new(0,0,0.5,0) ; line.BackgroundColor3=T.outline ; line.BorderSizePixel=0 ; line.ZIndex=6
					if text and text~="" then
						local ts=textservice:GetTextSize(text,10,Enum.Font.GothamBold,Vector2.new(2000,100))
						local bg=Instance.new("Frame",line) ; bg.Size=UDim2.fromOffset(ts.X+8,12) ; bg.Position=UDim2.new(0.5,-(ts.X+8)/2,-0.5,0) ; bg.BackgroundColor3=T.card ; bg.BorderSizePixel=0 ; bg.ZIndex=7
						local sl=mkLbl(bg,text,Enum.TextXAlignment.Center,T.textdim,10,Enum.Font.GothamBold,8) ; sl.Size=UDim2.fromScale(1,1)
					end
				end

				return sector
			end -- CreateSector

			return st
		end -- CreateSubTab

		function tab:CreateSector(name, col)
			if #tab.subtabs==0 then tab:CreateSubTab(tab.name) end
			return tab.subtabs[1]:CreateSector(name, col)
		end

		return tab
	end -- CreateTab

	function W:Notify(title,desc,duration)
		duration=duration or 5
		local ng=Instance.new("ScreenGui") ; ng.Name="PhotonNotif" ; ng.DisplayOrder=30 ; ng.Parent=coregui
		if syn then pcall(function() syn.protect_gui(ng) end) end
		local nf=Instance.new("Frame",ng) ; nf.Size=UDim2.fromOffset(260,desc and 60 or 40) ; nf.Position=UDim2.new(1,270,0,60) ; nf.BackgroundColor3=Color3.fromRGB(22,22,22) ; nf.BorderSizePixel=0 ; corner(6,nf) ; stroke(T.outline,1,nf)
		local lb=Instance.new("Frame",nf) ; lb.Size=UDim2.fromOffset(3,nf.Size.Y.Offset) ; lb.BackgroundColor3=T.accent ; lb.BorderSizePixel=0 ; lb.ZIndex=4
		local tl=Instance.new("TextLabel",nf) ; tl.Text=title ; tl.Font=Enum.Font.GothamBold ; tl.TextSize=12 ; tl.TextColor3=T.textactive ; tl.BackgroundTransparency=1 ; tl.ZIndex=5 ; tl.Position=UDim2.fromOffset(12,desc and 8 or 12) ; tl.Size=UDim2.fromOffset(236,16) ; tl.TextXAlignment=Enum.TextXAlignment.Left
		if desc then local dl=Instance.new("TextLabel",nf) ; dl.Text=desc ; dl.Font=Enum.Font.Gotham ; dl.TextSize=10 ; dl.TextColor3=T.textdim ; dl.BackgroundTransparency=1 ; dl.ZIndex=5 ; dl.TextWrapped=true ; dl.Position=UDim2.fromOffset(12,28) ; dl.Size=UDim2.fromOffset(236,22) ; dl.TextXAlignment=Enum.TextXAlignment.Left end
		local pbg=Instance.new("Frame",nf) ; pbg.Size=UDim2.fromOffset(260,2) ; pbg.Position=UDim2.new(0,0,1,-2) ; pbg.BackgroundColor3=Color3.fromRGB(35,35,35) ; pbg.BorderSizePixel=0 ; pbg.ZIndex=4
		local pb=Instance.new("Frame",pbg) ; pb.Size=UDim2.fromScale(1,1) ; pb.BackgroundColor3=T.accent ; pb.BorderSizePixel=0 ; pb.ZIndex=5
		tween(nf,{Position=UDim2.new(1,-272,0,60)},0.3) ; task.wait(0.35)
		tweenservice:Create(pb,TweenInfo.new(duration,Enum.EasingStyle.Linear),{Size=UDim2.fromScale(0,1)}):Play()
		task.delay(duration,function() tween(nf,{Position=UDim2.new(1,270,0,60)},0.25) ; task.wait(0.3) ; ng:Destroy() end)
	end

	return W
end

function library:Notify(t,d,dur) print("[Photon] "..tostring(t)) end

return library
