--// ◈ VOIDOR Z SCRIPTHUB V1.4.0 ◈
--// ৻ Thank you for using Voidor Z ScriptHub. ৲
print([[
__   ___  ___ ___   ___  ____    ____
\ \ / / |/ _ \_ _| / _ \|  _ \  |_  /
 \ V /| | | | | | | | | | |_) |  / /
  \_/ |_|\___/___| \___/|_.__/  /___|
     S C R I P T H U B   v1.4.0
]])
 
local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TeleportSvc  = game:GetService("TeleportService")
local Lighting     = game:GetService("Lighting")
local VirtualUser  = game:GetService("VirtualUser")
local HttpService  = game:GetService("HttpService")
local ContentProvider = game:GetService("ContentProvider")
 
local player  = Players.LocalPlayer
local camera  = workspace.CurrentCamera
local IS_MOBILE = UIS.TouchEnabled and not UIS.KeyboardEnabled
 
local function getChar() return player.Character or player.CharacterAdded:Wait() end
local function getHum()  return getChar():FindFirstChildOfClass("Humanoid") end
local function getRoot() return getChar():FindFirstChild("HumanoidRootPart") end
 
-- ═══ SAVE ════════════════════════════════════════════════════
local SAVE_FILE = "voidorz_140.json"
local saveData  = {}
local function loadSave()
    if type(isfile)=="function" and isfile(SAVE_FILE) then
        local ok,d=pcall(function() return HttpService:JSONDecode(readfile(SAVE_FILE)) end)
        if ok and type(d)=="table" then return d end
    end
    return {}
end
local function writeSave()
    if type(writefile)=="function" then
        pcall(function() writefile(SAVE_FILE, HttpService:JSONEncode(saveData)) end)
    end
end
local function sv(k,v) saveData[k]=v; writeSave() end
local function gv(k,d) if saveData[k]~=nil then return saveData[k] end; return d end
saveData = loadSave()
 
-- ═══ LOGO ════════════════════════════════════════════════════
-- Preload the asset so it is ready before the GUI shows
local LOGO_ID = "rbxassetid://121589619252959"
pcall(function() ContentProvider:PreloadAsync({LOGO_ID}) end)
 
-- ═══ THEME ════════════════════════════════════════════════════
local isDark = gv("isDark", true)
local DARK = {
    bg=Color3.fromRGB(8,6,18),        top=Color3.fromRGB(14,10,32),
    card=Color3.fromRGB(20,15,42),    text=Color3.fromRGB(240,235,255),
    sub=Color3.fromRGB(160,150,200),  off=Color3.fromRGB(45,40,65),
    red=Color3.fromRGB(180,45,45),    bgT=0.22,
    grad0=Color3.fromRGB(32,18,72),   grad1=Color3.fromRGB(10,7,22),
    grad2=Color3.fromRGB(6,4,16),     loader=Color3.fromRGB(4,3,12),
    starC=Color3.fromRGB(200,190,255),titleC=Color3.fromRGB(200,160,255),
    subC=Color3.fromRGB(130,110,180),
}
-- Light mode: genuinely light / clean white palette
local LIGHT = {
    bg=Color3.fromRGB(250,249,255),   top=Color3.fromRGB(242,240,255),
    card=Color3.fromRGB(255,255,255), text=Color3.fromRGB(18,14,40),
    sub=Color3.fromRGB(75,65,105),    off=Color3.fromRGB(200,196,220),
    red=Color3.fromRGB(200,40,40),    bgT=0.0,
    grad0=Color3.fromRGB(245,242,255),grad1=Color3.fromRGB(250,249,255),
    grad2=Color3.fromRGB(252,251,255),loader=Color3.fromRGB(250,249,255),
    starC=Color3.fromRGB(140,110,210),titleC=Color3.fromRGB(50,28,140),
    subC=Color3.fromRGB(85,65,140),
}
local function TH() return isDark and DARK or LIGHT end
 
local C = {
    accent  = Color3.fromRGB(130,70,255),
    accent2 = Color3.fromRGB(100,50,220),
    on      = Color3.fromRGB(140,80,255),
}
do
    local r,g,b = gv("aR",nil),gv("aG",nil),gv("aB",nil)
    if r and g and b then
        C.accent=Color3.new(r,g,b); C.on=C.accent
        local r2,g2,b2=gv("a2R",nil),gv("a2G",nil),gv("a2B",nil)
        if r2 and g2 and b2 then C.accent2=Color3.new(r2,g2,b2) end
    end
end
 
local accentTargets={}; local themeTargets={}
local function tA(o,p) table.insert(accentTargets,{o=o,p=p}) end
local function tT(o,p,r) table.insert(themeTargets,{o=o,p=p,role=r}) end
 
local function applyAccent(a,a2)
    C.accent=a; C.accent2=a2 or a:Lerp(Color3.fromRGB(50,30,140),0.4); C.on=a
    for _,t in ipairs(accentTargets) do pcall(function() t.o[t.p]=C.accent end) end
end
local function applyTheme()
    local th=TH()
    for _,t in ipairs(themeTargets) do
        pcall(function()
            local v=th[t.role] or C[t.role]
            if v then t.o[t.p]=v end
        end)
    end
end
 
-- ═══ DEFAULTS ════════════════════════════════════════════════
local DEF = {
    ws=16, jp=50, flySpeed=75, fov=70, gravity=workspace.Gravity,
    lighting={
        Brightness=Lighting.Brightness, GlobalShadows=Lighting.GlobalShadows,
        FogEnd=Lighting.FogEnd, Ambient=Lighting.Ambient,
        OutdoorAmbient=Lighting.OutdoorAmbient, ClockTime=Lighting.ClockTime,
    },
}
 
-- ═══ STATE ═══════════════════════════════════════════════════
local fly=false;    local noclip=false;  local infJump=false
local clickTP=false; local spinbot=false; local bhop=false
local tracersOn=false; local antiFling=false
local flySpeed = gv("flySpeed", DEF.flySpeed)
local wsValue  = gv("wsValue",  DEF.ws)
local tracers  = {}
 
local tabToggles={}; local tabSliders={}
local function regT(p,fn,def) tabToggles[p]=tabToggles[p] or {}; table.insert(tabToggles[p],{fn=fn,def=def or false}) end
local function regS(p,fn,def) tabSliders[p]=tabSliders[p] or {}; table.insert(tabSliders[p],{fn=fn,def=def}) end
local function resetT(p) if tabToggles[p] then for _,t in ipairs(tabToggles[p]) do t.fn(t.def) end end end
local function resetS(p) if tabSliders[p] then for _,s in ipairs(tabSliders[p]) do s.fn(s.def) end end end
 
-- Walkspeed enforcement + Anti-Fling
RunService.Heartbeat:Connect(function()
    local h=getHum(); if h then h.WalkSpeed=wsValue end
    if antiFling then
        local char=player.Character; if not char then return end
        for _,p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanCollide=false
                -- Zero out any extreme incoming velocity to prevent fling
                if not fly and p.AssemblyLinearVelocity.Magnitude > 80 then
                    p.AssemblyLinearVelocity = Vector3.zero
                end
            end
        end
    end
end)
 
-- ═══ KEYBINDS ════════════════════════════════════════════════
local function kcFromName(n)
    if not n or n=="NONE" then return nil end
    for _,v in pairs(Enum.KeyCode:GetEnumItems()) do if v.Name==n then return v end end
    return nil
end
local KB = {
    fly        = kcFromName(gv("kb_fly",        "NONE")),
    void       = kcFromName(gv("kb_void",       "NONE")),
    mega       = kcFromName(gv("kb_mega",       "NONE")),
    hideUI     = kcFromName(gv("kb_hideUI",     "NONE")),
    noclip     = kcFromName(gv("kb_noclip",     "NONE")),
    tracers    = kcFromName(gv("kb_tracers",    "NONE")),
    bhop       = kcFromName(gv("kb_bhop",       "NONE")),
    infJump    = kcFromName(gv("kb_infJump",    "NONE")),
    fullbright = kcFromName(gv("kb_fullbright", "NONE")),
    clickTP    = kcFromName(gv("kb_clickTP",    "NONE")),
    spinbot    = kcFromName(gv("kb_spinbot",    "NONE")),
    antiFling  = kcFromName(gv("kb_antiFling",  "NONE")),
}
local function kbName(kc) if not kc then return "--" end; local s=tostring(kc); return s:match("KeyCode%.(.+)") or s end
 
-- ═══ LOADING SCREEN ══════════════════════════════════════════
local loadGui=Instance.new("ScreenGui")
loadGui.Name="VoidorZLoader"; loadGui.ResetOnSpawn=false
loadGui.IgnoreGuiInset=true; loadGui.DisplayOrder=999
loadGui.Parent=player.PlayerGui
 
local th0=TH()
local lb=Instance.new("Frame",loadGui)
lb.Size=UDim2.new(1,0,1,0); lb.BackgroundColor3=th0.loader; lb.BorderSizePixel=0
 
-- Stars
for _=1,80 do
    local s=Instance.new("Frame",lb)
    local sz=math.random(1,3)
    s.Size=UDim2.new(0,sz,0,sz)
    s.Position=UDim2.new(math.random(),0,math.random(),0)
    s.BackgroundColor3=th0.starC
    s.BackgroundTransparency=math.random(30,80)/100
    s.BorderSizePixel=0
    Instance.new("UICorner",s).CornerRadius=UDim.new(1,0)
end
 
-- Logo — ImageTransparency=0 from the start so it always shows if asset is loaded
local lLogo=Instance.new("ImageLabel",lb)
lLogo.Size=UDim2.new(0,200,0,200)
lLogo.Position=UDim2.new(0.5,-100,0.5,-175)
lLogo.BackgroundTransparency=1
lLogo.Image=LOGO_ID
lLogo.ImageTransparency=0          -- always visible
lLogo.ScaleType=Enum.ScaleType.Fit  -- ensures proper scaling
 
local lTitle=Instance.new("TextLabel",lb)
lTitle.Size=UDim2.new(0,500,0,50); lTitle.Position=UDim2.new(0.5,-250,0.5,40)
lTitle.BackgroundTransparency=1; lTitle.Font=Enum.Font.GothamBold; lTitle.TextSize=32
lTitle.TextColor3=th0.titleC; lTitle.Text="VOIDOR Z SCRIPTHUB"; lTitle.TextTransparency=1
 
local lSub=Instance.new("TextLabel",lb)
lSub.Size=UDim2.new(0,400,0,24); lSub.Position=UDim2.new(0.5,-200,0.5,96)
lSub.BackgroundTransparency=1; lSub.Font=Enum.Font.Gotham; lSub.TextSize=14
lSub.TextColor3=th0.subC; lSub.Text="v1.4.0"; lSub.TextTransparency=1
 
local lBarTrack=Instance.new("Frame",lb)
lBarTrack.Size=UDim2.new(0,320,0,4); lBarTrack.Position=UDim2.new(0.5,-160,0.5,136)
lBarTrack.BackgroundColor3=isDark and Color3.fromRGB(30,20,60) or Color3.fromRGB(210,205,240)
lBarTrack.BorderSizePixel=0
Instance.new("UICorner",lBarTrack).CornerRadius=UDim.new(1,0)
 
local lBarFill=Instance.new("Frame",lBarTrack)
lBarFill.Size=UDim2.new(0,0,1,0); lBarFill.BackgroundColor3=C.accent; lBarFill.BorderSizePixel=0
Instance.new("UICorner",lBarFill).CornerRadius=UDim.new(1,0)
 
local lStat=Instance.new("TextLabel",lb)
lStat.Size=UDim2.new(0,320,0,20); lStat.Position=UDim2.new(0.5,-160,0.5,148)
lStat.BackgroundTransparency=1; lStat.Font=Enum.Font.Gotham; lStat.TextSize=11
lStat.TextColor3=th0.subC; lStat.Text="Initializing..."; lStat.TextTransparency=1
 
-- ═══ MAIN GUI ════════════════════════════════════════════════
local gui=Instance.new("ScreenGui")
gui.Name="VOIDORZ_140"; gui.ResetOnSpawn=false; gui.IgnoreGuiInset=true; gui.Parent=player.PlayerGui
 
local WIN_W,WIN_H = 840,700
local main=Instance.new("Frame",gui)
if IS_MOBILE then
    main.Size=UDim2.new(0.97,0,0.90,0)
    main.Position=UDim2.new(0.015,0,0.05,0)
else
    main.Size=UDim2.new(0,WIN_W,0,WIN_H)
    main.Position=UDim2.new(0.5,-WIN_W/2,0.5,-WIN_H/2)
end
main.BackgroundColor3=TH().bg
main.BackgroundTransparency=gv("uiTrans",math.floor(TH().bgT*100))/100
main.BorderSizePixel=0; main.Active=true
Instance.new("UICorner",main).CornerRadius=UDim.new(0,22)
tT(main,"BackgroundColor3","bg")
 
local winStroke=Instance.new("UIStroke",main)
winStroke.Color=C.accent; winStroke.Transparency=0.35; winStroke.Thickness=1.4; tA(winStroke,"Color")
 
local wg=Instance.new("UIGradient",main); wg.Rotation=120
local function refreshGradient()
    local th=TH()
    wg.Color=ColorSequence.new{
        ColorSequenceKeypoint.new(0,  th.grad0),
        ColorSequenceKeypoint.new(0.5,th.grad1),
        ColorSequenceKeypoint.new(1,  th.grad2),
    }
end
refreshGradient()
 
do
    local sc=gv("uiScale",100)
    if sc~=100 then local s=Instance.new("UIScale",main); s.Scale=sc/100 end
end
 
-- TOPBAR
local topH = IS_MOBILE and 52 or 56
local top=Instance.new("Frame",main)
top.Size=UDim2.new(1,0,0,topH); top.BackgroundColor3=TH().top; top.BackgroundTransparency=0.15
top.BorderSizePixel=0; top.Active=true
Instance.new("UICorner",top).CornerRadius=UDim.new(0,22)
tT(top,"BackgroundColor3","top")
 
local topFix=Instance.new("Frame",top)
topFix.Size=UDim2.new(1,0,0,22); topFix.Position=UDim2.new(0,0,1,-22)
topFix.BackgroundColor3=TH().top; topFix.BackgroundTransparency=0.15; topFix.BorderSizePixel=0
tT(topFix,"BackgroundColor3","top")
 
-- Topbar logo — always visible, Fit scale
local topLogo=Instance.new("ImageLabel",top)
topLogo.Size=UDim2.new(0,32,0,32); topLogo.Position=UDim2.new(0,10,0.5,-16)
topLogo.BackgroundTransparency=1; topLogo.Image=LOGO_ID
topLogo.ImageTransparency=0; topLogo.ScaleType=Enum.ScaleType.Fit
 
local titleLbl=Instance.new("TextLabel",top); titleLbl.BackgroundTransparency=1
titleLbl.Position=UDim2.new(0,50,0,2); titleLbl.Size=UDim2.new(1,-160,0,28)
titleLbl.Text="VOIDOR Z SCRIPTHUB"; titleLbl.Font=Enum.Font.GothamBold
titleLbl.TextSize=IS_MOBILE and 15 or 17; titleLbl.TextColor3=TH().text
titleLbl.TextXAlignment=Enum.TextXAlignment.Left; tT(titleLbl,"TextColor3","text")
 
local subLbl=Instance.new("TextLabel",top); subLbl.BackgroundTransparency=1
subLbl.Position=UDim2.new(0,51,0,topH-18); subLbl.Size=UDim2.new(0.78,0,0,14)
subLbl.Font=Enum.Font.Gotham; subLbl.TextSize=10; subLbl.TextColor3=TH().sub
subLbl.TextXAlignment=Enum.TextXAlignment.Left; tT(subLbl,"TextColor3","sub")
 
local function updateSubLbl()
    subLbl.Text="v1.4.0  |  "..kbName(KB.hideUI).."=hide  |  "..kbName(KB.fly).."=fly  |  "..kbName(KB.tracers).."=tracers"
end
updateSubLbl()
 
local closeBtn=Instance.new("TextButton",top)
closeBtn.Size=UDim2.new(0,30,0,30); closeBtn.Position=UDim2.new(1,-40,0.5,-15)
closeBtn.BackgroundColor3=TH().red; closeBtn.Text="X"
closeBtn.Font=Enum.Font.GothamBold; closeBtn.TextSize=13
closeBtn.TextColor3=Color3.new(1,1,1); closeBtn.BorderSizePixel=0
Instance.new("UICorner",closeBtn).CornerRadius=UDim.new(1,0); tT(closeBtn,"BackgroundColor3","red")
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)
 
local minBtn=Instance.new("TextButton",top)
minBtn.Size=UDim2.new(0,30,0,30); minBtn.Position=UDim2.new(1,-78,0.5,-15)
minBtn.BackgroundColor3=C.accent2; minBtn.Text="-"
minBtn.Font=Enum.Font.GothamBold; minBtn.TextSize=18
minBtn.TextColor3=Color3.new(1,1,1); minBtn.BorderSizePixel=0
Instance.new("UICorner",minBtn).CornerRadius=UDim.new(1,0); tA(minBtn,"BackgroundColor3")
 
local minimised=false
minBtn.MouseButton1Click:Connect(function()
    minimised=not minimised
    local colH = IS_MOBILE and UDim2.new(0.97,0,0,topH) or UDim2.new(0,WIN_W,0,topH)
    local expH = IS_MOBILE and UDim2.new(0.97,0,0.90,0) or UDim2.new(0,WIN_W,0,WIN_H)
    TweenService:Create(main,TweenInfo.new(0.2),{Size=minimised and colH or expH}):Play()
end)
 
-- Drag — works for both mouse and touch
local dragging,dragStart,startPos
local function startDrag(pos)
    if minimised then return end
    dragging=true; dragStart=pos; startPos=main.Position
end
local function doDrag(pos)
    if not dragging then return end
    local d=pos-dragStart
    main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
end
local function endDrag() dragging=false end
 
top.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        startDrag(i.Position)
    end
end)
UIS.InputChanged:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
        doDrag(i.Position)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        endDrag()
    end
end)
 
-- Tab bar
local tabBar=Instance.new("ScrollingFrame",main)
tabBar.Position=UDim2.new(0,10,0,topH+7)
tabBar.Size=UDim2.new(1,-20,0,38)
tabBar.CanvasSize=UDim2.new(0,2400,0,0); tabBar.BackgroundTransparency=1
tabBar.ScrollBarThickness=0; tabBar.BorderSizePixel=0
tabBar.ScrollingDirection=Enum.ScrollingDirection.X
local tabLL=Instance.new("UIListLayout",tabBar)
tabLL.FillDirection=Enum.FillDirection.Horizontal; tabLL.Padding=UDim.new(0,5)
 
local CONTENT_Y = topH+7+38+4
local divLine=Instance.new("Frame",main)
divLine.Size=UDim2.new(1,-20,0,1); divLine.Position=UDim2.new(0,10,0,CONTENT_Y-2)
divLine.BackgroundColor3=C.accent; divLine.BackgroundTransparency=0.6; divLine.BorderSizePixel=0
tA(divLine,"BackgroundColor3")
 
-- ═══ PAGE / TAB SYSTEM ═══════════════════════════════════════
local pages={}; local tabBtns={}
 
local function createPage(name)
    local sf=Instance.new("ScrollingFrame",main)
    sf.Name="Page_"..name
    sf.Position=UDim2.new(0,10,0,CONTENT_Y+2)
    sf.Size=UDim2.new(1,-20,1,-(CONTENT_Y+12))
    sf.BackgroundTransparency=1; sf.BorderSizePixel=0
    sf.ScrollBarThickness=IS_MOBILE and 5 or 4
    sf.ScrollBarImageColor3=C.accent; sf.ScrollBarImageTransparency=0.2
    sf.CanvasSize=UDim2.new(0,0,0,0); sf.AutomaticCanvasSize=Enum.AutomaticSize.Y
    sf.ScrollingDirection=Enum.ScrollingDirection.Y; sf.ScrollingEnabled=true
    sf.ClipsDescendants=true; sf.Active=true
    sf.ElasticBehavior=Enum.ElasticBehavior.WhenScrollable; sf.Visible=false
    tA(sf,"ScrollBarImageColor3")
    local l=Instance.new("UIListLayout",sf)
    l.Padding=UDim.new(0,9); l.SortOrder=Enum.SortOrder.LayoutOrder
    l.HorizontalAlignment=Enum.HorizontalAlignment.Center
    local p=Instance.new("UIPadding",sf)
    p.PaddingLeft=UDim.new(0,2); p.PaddingRight=UDim.new(0,2)
    p.PaddingTop=UDim.new(0,8); p.PaddingBottom=UDim.new(0,18)
    pages[name]=sf; return sf
end
 
local function switchPage(name)
    for n,p in pairs(pages) do
        p.Visible=(n==name)
        if n==name then
            p.CanvasPosition=Vector2.zero
            p.AutomaticCanvasSize=Enum.AutomaticSize.None
            task.defer(function()
                if p and p.Parent then
                    p.AutomaticCanvasSize=Enum.AutomaticSize.Y
                    p.ScrollingEnabled=true
                end
            end)
        end
    end
    for n,b in pairs(tabBtns) do
        TweenService:Create(b,TweenInfo.new(0.14),{
            BackgroundColor3=n==name and C.accent or TH().card,
            BackgroundTransparency=n==name and 0.05 or 0.3,
        }):Play()
        b.TextColor3=n==name and Color3.new(1,1,1) or TH().sub
    end
end
 
local TAB_W = IS_MOBILE and 92 or 110
local function createTab(name)
    local btn=Instance.new("TextButton",tabBar)
    btn.Size=UDim2.new(0,TAB_W,1,0)
    btn.BackgroundColor3=TH().card; btn.BackgroundTransparency=0.3
    btn.Text=name; btn.TextColor3=TH().sub
    btn.Font=Enum.Font.GothamMedium; btn.TextSize=IS_MOBILE and 11 or 12
    btn.BorderSizePixel=0; Instance.new("UICorner",btn).CornerRadius=UDim.new(1,0)
    local bs=Instance.new("UIStroke",btn); bs.Color=C.accent; bs.Transparency=0.72; bs.Thickness=1; tA(bs,"Color")
    btn.MouseButton1Click:Connect(function() switchPage(name) end)
    btn.MouseEnter:Connect(function()
        if not pages[name] or not pages[name].Visible then
            TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=C.accent2,BackgroundTransparency=0.4}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if not pages[name] or not pages[name].Visible then
            TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=TH().card,BackgroundTransparency=0.3}):Play()
        end
    end)
    tabBtns[name]=btn
end
 
-- ═══ WIDGETS ══════════════════════════════════════════════════
local CARD_H   = IS_MOBILE and 66 or 62
local SLIDER_H = IS_MOBILE and 80 or 76
local BTN_H    = IS_MOBILE and 58 or 54
local FONT_SZ  = IS_MOBILE and 13 or 14
 
local function makeCard(parent,h,order)
    local card=Instance.new("Frame",parent)
    card.Size=UDim2.new(1,-4,0,h or CARD_H)
    card.BackgroundColor3=TH().card; card.BackgroundTransparency=isDark and 0.28 or 0.0
    card.BorderSizePixel=0; card.LayoutOrder=order or 0
    Instance.new("UICorner",card).CornerRadius=UDim.new(0,13)
    local cs=Instance.new("UIStroke",card); cs.Color=C.accent; cs.Transparency=isDark and 0.82 or 0.7; cs.Thickness=1
    tA(cs,"Color"); tT(card,"BackgroundColor3","card")
    return card
end
 
local function secLabel(parent,text,order)
    local f=Instance.new("Frame",parent)
    f.Size=UDim2.new(1,-4,0,24); f.BackgroundTransparency=1; f.LayoutOrder=order or 0
    local l=Instance.new("TextLabel",f); l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1
    l.Font=Enum.Font.GothamBold; l.TextSize=10; l.TextColor3=C.accent
    l.Text=string.upper(text); l.TextXAlignment=Enum.TextXAlignment.Left; tA(l,"TextColor3")
    local line=Instance.new("Frame",f)
    line.Size=UDim2.new(1,0,0,1); line.Position=UDim2.new(0,0,1,-1)
    line.BackgroundColor3=C.accent; line.BackgroundTransparency=0.65; line.BorderSizePixel=0
    tA(line,"BackgroundColor3")
end
 
local function makeToggle(parent,text,order,callback)
    local card=makeCard(parent,CARD_H,order)
    local lbl=Instance.new("TextLabel",card); lbl.BackgroundTransparency=1
    lbl.Position=UDim2.new(0,16,0,0); lbl.Size=UDim2.new(1,-88,1,0)
    lbl.Text=text; lbl.TextColor3=TH().text; lbl.Font=Enum.Font.GothamMedium
    lbl.TextSize=FONT_SZ; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.TextWrapped=true
    tT(lbl,"TextColor3","text")
    local tog=Instance.new("TextButton",card)
    tog.Size=UDim2.new(0,52,0,27); tog.Position=UDim2.new(1,-68,0.5,-13)
    tog.BackgroundColor3=TH().off; tog.Text=""; tog.BorderSizePixel=0
    Instance.new("UICorner",tog).CornerRadius=UDim.new(1,0); tT(tog,"BackgroundColor3","off")
    local knob=Instance.new("Frame",tog)
    knob.Size=UDim2.new(0,21,0,21); knob.Position=UDim2.new(0,3,0.5,-10)
    knob.BackgroundColor3=Color3.new(1,1,1); knob.BorderSizePixel=0
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    local enabled=false
    local function set(s)
        enabled=s
        TweenService:Create(tog,TweenInfo.new(0.15),{BackgroundColor3=s and C.on or TH().off}):Play()
        knob:TweenPosition(s and UDim2.new(1,-24,0.5,-10) or UDim2.new(0,3,0.5,-10),
            Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.15,true)
        callback(s)
    end
    tog.MouseButton1Click:Connect(function() set(not enabled) end)
    return set, function() set(not enabled) end
end
 
local function makeSlider(parent,text,minV,maxV,defV,order,onChange)
    local card=makeCard(parent,SLIDER_H,order)
    local lbl=Instance.new("TextLabel",card); lbl.BackgroundTransparency=1
    lbl.Position=UDim2.new(0,16,0,7); lbl.Size=UDim2.new(1,-20,0,20)
    lbl.Text=text..": "..defV; lbl.TextColor3=TH().text
    lbl.Font=Enum.Font.GothamMedium; lbl.TextSize=FONT_SZ
    lbl.TextXAlignment=Enum.TextXAlignment.Left; tT(lbl,"TextColor3","text")
    local bar=Instance.new("Frame",card)
    bar.Position=UDim2.new(0,16,1,-22); bar.Size=UDim2.new(1,-32,0,9)
    bar.BackgroundColor3=TH().off; bar.BorderSizePixel=0; bar.Active=true
    Instance.new("UICorner",bar).CornerRadius=UDim.new(1,0); tT(bar,"BackgroundColor3","off")
    local initR=math.clamp((defV-minV)/(maxV-minV),0,1)
    local fill=Instance.new("Frame",bar)
    fill.Size=UDim2.new(initR,0,1,0); fill.BackgroundColor3=C.accent; fill.BorderSizePixel=0
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0); tA(fill,"BackgroundColor3")
    local thumb=Instance.new("Frame",bar)
    thumb.Size=UDim2.new(0,20,0,20); thumb.AnchorPoint=Vector2.new(0.5,0.5)
    thumb.Position=UDim2.new(initR,0,0.5,0)
    thumb.BackgroundColor3=Color3.fromRGB(200,175,255); thumb.BorderSizePixel=0
    thumb.ZIndex=3; thumb.Active=true
    Instance.new("UICorner",thumb).CornerRadius=UDim.new(1,0)
    local dg=false
    local function update(x)
        local r=math.clamp((x-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
        local v=math.floor(minV+r*(maxV-minV))
        fill.Size=UDim2.new(r,0,1,0); thumb.Position=UDim2.new(r,0,0.5,0)
        lbl.Text=text..": "..v; onChange(v)
    end
    local function setVal(v)
        local r=math.clamp((v-minV)/(maxV-minV),0,1)
        fill.Size=UDim2.new(r,0,1,0); thumb.Position=UDim2.new(r,0,0.5,0)
        lbl.Text=text..": "..v; onChange(v)
    end
    local function onBegin(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dg=true end
    end
    local function onEnd(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dg=false end
    end
    thumb.InputBegan:Connect(onBegin); thumb.InputEnded:Connect(onEnd)
    bar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dg=true; update(i.Position.X)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dg and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            update(i.Position.X)
        end
    end)
    UIS.InputEnded:Connect(onEnd)
    return setVal
end
 
local function makeBtn(parent,text,color,order,cb)
    local card=makeCard(parent,BTN_H,order)
    local ind=Instance.new("Frame",card)
    ind.Size=UDim2.new(0,4,0.55,0); ind.Position=UDim2.new(0,0,0.225,0)
    ind.BackgroundColor3=color or C.accent; ind.BorderSizePixel=0
    Instance.new("UICorner",ind).CornerRadius=UDim.new(1,0)
    local btn=Instance.new("TextButton",card)
    btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1
    btn.Text=text; btn.Font=Enum.Font.GothamMedium; btn.TextSize=FONT_SZ
    btn.TextColor3=TH().text; tT(btn,"TextColor3","text")
    btn.MouseButton1Click:Connect(cb)
    btn.MouseEnter:Connect(function() TweenService:Create(card,TweenInfo.new(0.1),{BackgroundTransparency=0.1}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(card,TweenInfo.new(0.1),{BackgroundTransparency=isDark and 0.28 or 0}):Play() end)
    return ind
end
local function makeABtn(parent,text,order,cb)
    local ind=makeBtn(parent,text,C.accent,order,cb); tA(ind,"BackgroundColor3")
end
local function makeResetBtn(parent,order,cb)
    local card=makeCard(parent,44,order)
    card.BackgroundTransparency=0.1
    card.BackgroundColor3=isDark and Color3.fromRGB(10,7,24) or Color3.fromRGB(235,230,255)
    local cs=card:FindFirstChildOfClass("UIStroke")
    if cs then cs.Color=TH().red; cs.Transparency=0.6 end
    local btn=Instance.new("TextButton",card)
    btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1
    btn.Text="[ Reset Tab Settings ]"; btn.Font=Enum.Font.GothamBold; btn.TextSize=12
    btn.TextColor3=TH().sub; tT(btn,"TextColor3","sub")
    btn.MouseButton1Click:Connect(cb)
    btn.MouseEnter:Connect(function() TweenService:Create(card,TweenInfo.new(0.1),{BackgroundTransparency=0}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(card,TweenInfo.new(0.1),{BackgroundTransparency=0.1}):Play() end)
end
 
-- ═══ BUILD PAGES ══════════════════════════════════════════════
local movPage   = createPage("Movement")
local voidPage  = createPage("Void Lab")
local visPage   = createPage("Visuals")
local tpPage    = createPage("Players")
local miscPage  = createPage("Misc")
local utilPage  = createPage("Utility")
local kbPage    = createPage("Keybinds")
local patchPage = createPage("Patch Notes")
local setPage   = createPage("Settings")
 
createTab("Movement"); createTab("Void Lab"); createTab("Visuals")
createTab("Players");  createTab("Misc");     createTab("Utility")
createTab("Keybinds"); createTab("Patch Notes"); createTab("Settings")
 
local o=0; local function O() o=o+1; return o end
 
-- ═══ PATCH NOTES ══════════════════════════════════════════════
do
    local patches={
        {ver="1.4.0  (current)",ch={
            "Void Lab streamlined: only VOID and MEGA VOID remain",
            "All character FX (fire, smoke, rainbow, platforms, etc.) moved to Visuals",
            "Removed: hitbox size, character scale, fake death, restore body, kill all NPCs",
            "Freeze/Unfreeze NPCs reworked to visual-only (hides them, does not affect AI)",
            "Light Mode fully reworked: genuinely clean white palette, no purple tint",
            "Anti-Fling improved: disables all collisions AND zeroes out extreme velocity",
            "Mobile drag support: title bar drag now works with Touch input",
            "Icon fix: ContentProvider:PreloadAsync() called before GUI builds, ImageTransparency=0, ScaleType=Fit",
            "Added small ambient details: live clock display in Misc, animated accent dot in topbar",
        }},
        {ver="1.3.2",ch={
            "Critical launch fix via Python file writing",
            "Mobile scale-based sizing",
            "All keybind toggle functions properly wired",
            "Scroll fix: AutomaticCanvasSize reset on tab switch",
        }},
        {ver="1.3.x",ch={
            "Rebranded to Voidor Z",
            "Dark / Light mode",
            "Misc tab, Anti-Fling, Visuals expansion",
        }},
        {ver="1.x.x",ch={
            "All base features — fly, noclip, keybinds, save system, tracers, lighting",
        }},
    }
    secLabel(patchPage,"Voidor Z ScriptHub — Update History",O())
    for _,p in ipairs(patches) do
        local vc=makeCard(patchPage,36,O())
        vc.BackgroundColor3=isDark and Color3.fromRGB(28,16,62) or Color3.fromRGB(225,218,255)
        vc.BackgroundTransparency=isDark and 0.1 or 0.0
        local vs=vc:FindFirstChildOfClass("UIStroke"); if vs then vs.Color=C.accent; vs.Transparency=0.35 end
        local vl=Instance.new("TextLabel",vc)
        vl.Size=UDim2.new(1,-20,1,0); vl.Position=UDim2.new(0,14,0,0)
        vl.BackgroundTransparency=1; vl.Font=Enum.Font.GothamBold; vl.TextSize=13
        vl.TextColor3=C.accent; vl.Text=p.ver; vl.TextXAlignment=Enum.TextXAlignment.Left; tA(vl,"TextColor3")
        for _,line in ipairs(p.ch) do
            local ec=makeCard(patchPage,34,O()); ec.BackgroundTransparency=isDark and 0.6 or 0.1
            local d2=Instance.new("Frame",ec)
            d2.Size=UDim2.new(0,5,0,5); d2.Position=UDim2.new(0,14,0.5,-2)
            d2.BackgroundColor3=C.accent2; d2.BorderSizePixel=0
            Instance.new("UICorner",d2).CornerRadius=UDim.new(1,0); tA(d2,"BackgroundColor3")
            local el=Instance.new("TextLabel",ec)
            el.Size=UDim2.new(1,-28,1,0); el.Position=UDim2.new(0,28,0,0)
            el.BackgroundTransparency=1; el.Font=Enum.Font.Gotham; el.TextSize=12
            el.TextColor3=TH().sub; el.Text="- "..line
            el.TextXAlignment=Enum.TextXAlignment.Left; el.TextWrapped=true; tT(el,"TextColor3","sub")
        end
    end
end
 
-- ═══ MOVEMENT ═════════════════════════════════════════════════
secLabel(movPage,"Flying",O())
local setFly,togFly=makeToggle(movPage,"Flight",O(),function(s) fly=s end); regT(movPage,setFly,false)
local setFlySpd=makeSlider(movPage,"Fly Speed",20,500,flySpeed,O(),function(v) flySpeed=v; sv("flySpeed",v) end); regS(movPage,setFlySpd,DEF.flySpeed)
 
secLabel(movPage,"On Foot",O())
local setNoclip,togNoclip=makeToggle(movPage,"Noclip",O(),function(s) noclip=s end); regT(movPage,setNoclip,false)
local setInfJ,togInfJ=makeToggle(movPage,"Infinite Jump",O(),function(s) infJump=s end); regT(movPage,setInfJ,false)
local setBhop,togBhop=makeToggle(movPage,"Bunny Hop",O(),function(s) bhop=s end); regT(movPage,setBhop,false)
local setClickTP,togClickTP=makeToggle(movPage,"Click Teleport",O(),function(s) clickTP=s end); regT(movPage,setClickTP,false)
 
secLabel(movPage,"Sliders",O())
local setWS=makeSlider(movPage,"Walkspeed",16,350,wsValue,O(),function(v) wsValue=v; sv("wsValue",v) end); regS(movPage,setWS,DEF.ws)
local setJP=makeSlider(movPage,"Jump Power",7,500,gv("jp",DEF.jp),O(),function(v) sv("jp",v); local h=getHum(); if h then h.JumpPower=v end end); regS(movPage,setJP,DEF.jp)
local setGrav=makeSlider(movPage,"Gravity",0,400,gv("gravity",DEF.gravity),O(),function(v) workspace.Gravity=v; sv("gravity",v) end); regS(movPage,setGrav,DEF.gravity)
local setHipH=makeSlider(movPage,"Hip Height",0,10,gv("stepH",1),O(),function(v) sv("stepH",v); local h=getHum(); if h then h.HipHeight=v end end); regS(movPage,setHipH,1)
do local h=getHum(); if h then h.JumpPower=gv("jp",DEF.jp); h.HipHeight=gv("stepH",1) end; workspace.Gravity=gv("gravity",DEF.gravity) end
 
secLabel(movPage,"Presets",O())
makeABtn(movPage,"Normal Gravity",O(),function() workspace.Gravity=196.2 end)
makeBtn(movPage,"Moon Gravity",Color3.fromRGB(130,130,180),O(),function() workspace.Gravity=32 end)
makeBtn(movPage,"Zero Gravity",Color3.fromRGB(60,30,120),O(),function() workspace.Gravity=0.1 end)
makeBtn(movPage,"Super Jump",Color3.fromRGB(60,160,80),O(),function() local h=getHum(); if h then h.JumpPower=350 end end)
makeBtn(movPage,"Speed Demon",Color3.fromRGB(200,100,20),O(),function() wsValue=120; sv("wsValue",120) end)
 
makeResetBtn(movPage,O(),function()
    fly=false; noclip=false; infJump=false; bhop=false; clickTP=false
    flySpeed=DEF.flySpeed; wsValue=DEF.ws; workspace.Gravity=DEF.gravity
    local h=getHum(); if h then h.WalkSpeed=DEF.ws; h.JumpPower=DEF.jp; h.HipHeight=1 end
    sv("flySpeed",DEF.flySpeed); sv("wsValue",DEF.ws); sv("gravity",DEF.gravity); sv("jp",DEF.jp); sv("stepH",1)
    resetT(movPage); resetS(movPage)
end)
 
-- ═══ VOID LAB (streamlined) ════════════════════════════════════
secLabel(voidPage,"Void Teleports",O())
makeABtn(voidPage,"VOID",O(),function()
    local r=getRoot(); if r then r.CFrame=CFrame.new(r.Position+Vector3.new(0,9e4,0)) end
end)
makeBtn(voidPage,"MEGA VOID",Color3.fromRGB(60,0,160),O(),function()
    local r=getRoot(); if r then r.CFrame=CFrame.new(r.Position+Vector3.new(0,9e6,0)) end
end)
 
secLabel(voidPage,"Spinbot",O())
local setSpinbot,togSpinbot=makeToggle(voidPage,"Spinbot",O(),function(s) spinbot=s end); regT(voidPage,setSpinbot,false)
 
makeResetBtn(voidPage,O(),function()
    spinbot=false; resetT(voidPage)
end)
 
-- ═══ VISUALS ═════════════════════════════════════════════════
secLabel(visPage,"Weapons & Combat",O())
makeABtn(visPage,"Give Sword",O(),function()
    local tool=Instance.new("Tool"); tool.Name="VoidSword"; tool.RequiresHandle=false
    local blade=Instance.new("Part",tool); blade.Size=Vector3.new(0.2,4,0.2)
    blade.BrickColor=BrickColor.new("Bright violet"); blade.Material=Enum.Material.Neon; blade.Name="Handle"
    tool.Parent=player.Backpack
end)
makeBtn(visPage,"Forcefield (10s)",Color3.fromRGB(100,50,220),O(),function()
    local ff=Instance.new("ForceField"); ff.Visible=true; ff.Parent=getChar()
    task.delay(10,function() if ff and ff.Parent then ff:Destroy() end end)
end)
makeBtn(visPage,"Permanent Forcefield",Color3.fromRGB(80,30,200),O(),function()
    Instance.new("ForceField",getChar()).Visible=true
end)
makeBtn(visPage,"Remove Forcefield",TH().off,O(),function()
    for _,v in ipairs(getChar():GetChildren()) do if v:IsA("ForceField") then v:Destroy() end end
end)
makeBtn(visPage,"Shockwave",Color3.fromRGB(80,30,200),O(),function()
    local r=getRoot(); if not r then return end
    local e=Instance.new("Explosion",workspace); e.Position=r.Position; e.BlastRadius=22; e.BlastPressure=0
end)
makeBtn(visPage,"Lightning Strike",Color3.fromRGB(200,200,50),O(),function()
    local r=getRoot(); if not r then return end
    for i=1,5 do task.delay(i*0.08,function()
        local b=Instance.new("Part",workspace); b.Size=Vector3.new(0.3,80,0.3); b.Anchored=true
        b.Material=Enum.Material.Neon; b.Color=Color3.fromRGB(255,255,100)
        b.CFrame=CFrame.new(r.Position+Vector3.new(math.random(-5,5),40,math.random(-5,5))); b.CanCollide=false
        game:GetService("Debris"):AddItem(b,0.12)
    end) end
end)
 
secLabel(visPage,"Character FX",O())
local setPlatform=makeToggle(visPage,"Floating Platform",O(),function(s)
    if s then
        local p=Instance.new("Part",workspace); p.Name="VoidPlatform"; p.Size=Vector3.new(14,1,14)
        p.Anchored=true; p.Material=Enum.Material.Neon; p.Color=C.accent; _G.vPlatform=p
    else if _G.vPlatform then _G.vPlatform:Destroy(); _G.vPlatform=nil end end
end); regT(visPage,setPlatform,false)
 
local setOrbit=makeToggle(visPage,"Orbit Platform",O(),function(s)
    if s then
        local p=Instance.new("Part",workspace); p.Name="VoidOrbit"; p.Size=Vector3.new(10,0.8,10)
        p.Anchored=true; p.Material=Enum.Material.Neon; p.Color=C.accent; _G.vOrbit=p; _G.vOrbitA=0
    else if _G.vOrbit then _G.vOrbit:Destroy(); _G.vOrbit=nil end end
end); regT(visPage,setOrbit,false)
 
local setRainbowChar=makeToggle(visPage,"Rainbow Character",O(),function(s)
    if s then _G.vRainbowChar=RunService.RenderStepped:Connect(function()
        for _,v in ipairs(getChar():GetDescendants()) do if v:IsA("BasePart") then v.Color=Color3.fromHSV(tick()%5/5,1,1) end end
    end) else if _G.vRainbowChar then _G.vRainbowChar:Disconnect(); _G.vRainbowChar=nil end end
end); regT(visPage,setRainbowChar,false)
 
local setFire=makeToggle(visPage,"Fire Character",O(),function(s)
    for _,v in ipairs(getChar():GetDescendants()) do if v:IsA("BasePart") then
        if s then local f=Instance.new("Fire",v); f.Size=7; f.Name="VoidFire"
        else local f=v:FindFirstChild("VoidFire"); if f then f:Destroy() end end
    end end
end); regT(visPage,setFire,false)
 
local setSmoke=makeToggle(visPage,"Smoke Aura",O(),function(s)
    local root=getRoot(); if not root then return end
    if s then
        local sm=Instance.new("Smoke",root); sm.Name="VoidSmoke"
        sm.Color=Color3.fromRGB(100,60,200); sm.Opacity=0.4; sm.RiseVelocity=4
    else local sm=root:FindFirstChild("VoidSmoke"); if sm then sm:Destroy() end end
end); regT(visPage,setSmoke,false)
 
local setIce=makeToggle(visPage,"Ice Sparkles",O(),function(s)
    for _,v in ipairs(getChar():GetDescendants()) do if v:IsA("BasePart") then
        if s then local sp=Instance.new("Sparkles",v); sp.Name="VoidIce"; sp.SparkleColor=Color3.fromRGB(180,220,255)
        else local sp=v:FindFirstChild("VoidIce"); if sp then sp:Destroy() end end
    end end
end); regT(visPage,setIce,false)
 
local setBigHead=makeToggle(visPage,"Big Head",O(),function(s)
    local head=getChar():FindFirstChild("Head")
    if head then head.Size=s and Vector3.new(4,4,4) or Vector3.new(2,1,1) end
end); regT(visPage,setBigHead,false)
 
local setTiny=makeToggle(visPage,"Tiny Mode",O(),function(s)
    for _,p in ipairs(getChar():GetDescendants()) do
        if p:IsA("BasePart") then p.Size=p.Size*(s and 0.3 or 3.33) end
    end
end); regT(visPage,setTiny,false)
 
local setGhost=makeToggle(visPage,"Ghost Mode",O(),function(s)
    for _,p in ipairs(getChar():GetDescendants()) do
        if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then p.Transparency=s and 0.6 or 0 end
    end
end); regT(visPage,setGhost,false)
 
local setPartRain=makeToggle(visPage,"Part Rain",O(),function(s)
    if s then _G.vPartRain=RunService.Heartbeat:Connect(function()
        if math.random(1,8)~=1 then return end
        local root=getRoot(); if not root then return end
        local p=Instance.new("Part",workspace)
        p.Size=Vector3.new(math.random(1,4),math.random(1,4),math.random(1,4))
        p.Position=root.Position+Vector3.new(math.random(-20,20),50,math.random(-20,20))
        p.Color=Color3.fromHSV(math.random(),1,1); p.Material=Enum.Material.Neon; p.CanCollide=false
        game:GetService("Debris"):AddItem(p,4)
    end) else if _G.vPartRain then _G.vPartRain:Disconnect(); _G.vPartRain=nil end end
end); regT(visPage,setPartRain,false)
 
makeBtn(visPage,"Explode Character",Color3.fromRGB(180,80,0),O(),function()
    for _,v in ipairs(getChar():GetDescendants()) do
        if v:IsA("BasePart") then local e=Instance.new("Explosion",workspace); e.Position=v.Position end
    end
end)
makeBtn(visPage,"Restore Body",TH().off,O(),function()
    for _,v in ipairs(getChar():GetDescendants()) do if v:IsA("BasePart") then v.Transparency=0 end end
end)
 
-- NPC visual hide/show (visual only)
secLabel(visPage,"World FX",O())
local npcHidden=false
local setHideNPC=makeToggle(visPage,"Hide NPCs (Visual)",O(),function(s)
    npcHidden=s
    for _,m in ipairs(workspace:GetDescendants()) do
        if m:IsA("Humanoid") and m.Parent~=player.Character then
            for _,p in ipairs(m.Parent:GetDescendants()) do
                if p:IsA("BasePart") then p.Transparency=s and 1 or 0 end
                if p:IsA("Decal") or p:IsA("SpecialMesh") then end
            end
        end
    end
end); regT(visPage,setHideNPC,false)
 
local setNeonWorld=makeToggle(visPage,"Neon World",O(),function(s)
    if s then _G.vNeonWorld=RunService.Heartbeat:Connect(function()
        for _,p in ipairs(workspace:GetDescendants()) do
            if p:IsA("BasePart") and p.Parent~=player.Character then p.Material=Enum.Material.Neon end
        end
    end) else if _G.vNeonWorld then _G.vNeonWorld:Disconnect(); _G.vNeonWorld=nil end end
end); regT(visPage,setNeonWorld,false)
 
secLabel(visPage,"Player Visuals",O())
local setTrail=makeToggle(visPage,"Sword Trail",O(),function(s)
    local root=getRoot(); if not root then return end
    if s then
        local a0=Instance.new("Attachment",root); a0.Name="TrailA0"
        local a1=Instance.new("Attachment",root); a1.Name="TrailA1"; a1.Position=Vector3.new(0,3,0)
        local trail=Instance.new("Trail"); trail.Name="VoidTrail"; trail.Attachment0=a0; trail.Attachment1=a1
        trail.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,C.accent),ColorSequenceKeypoint.new(1,Color3.fromRGB(60,0,180))}
        trail.LightEmission=0.8; trail.Lifetime=0.35
        trail.Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)}
        trail.Parent=root
    else
        local r=getRoot(); if not r then return end
        for _,v in ipairs(r:GetChildren()) do
            if v:IsA("Trail") or (v:IsA("Attachment") and v.Name:find("TrailA")) then v:Destroy() end
        end
    end
end); regT(visPage,setTrail,false)
 
local setNametag=makeToggle(visPage,"Rainbow Nametag",O(),function(s)
    if s then _G.vNametag=RunService.RenderStepped:Connect(function()
        local hue=(tick()*60)%360
        local char=player.Character; if not char then return end
        local head=char:FindFirstChild("Head"); if not head then return end
        local bb=head:FindFirstChild("VoidTag") or Instance.new("BillboardGui",head)
        bb.Name="VoidTag"; bb.Size=UDim2.new(0,160,0,30); bb.StudsOffset=Vector3.new(0,3,0); bb.AlwaysOnTop=true
        local l=bb:FindFirstChildOfClass("TextLabel") or Instance.new("TextLabel",bb)
        l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1; l.Font=Enum.Font.GothamBold
        l.TextSize=14; l.TextStrokeTransparency=0.2
        l.Text="  "..player.DisplayName.."  "; l.TextColor3=Color3.fromHSV(hue/360,1,1)
    end)
    else
        if _G.vNametag then _G.vNametag:Disconnect(); _G.vNametag=nil end
        local char=player.Character
        if char then local hd=char:FindFirstChild("Head"); if hd then local b=hd:FindFirstChild("VoidTag"); if b then b:Destroy() end end end
    end
end); regT(visPage,setNametag,false)
 
local setTracers,togTracers=makeToggle(visPage,"Player Tracers",O(),function(s)
    tracersOn=s
    if not s then for _,l in pairs(tracers) do pcall(function() l:Remove() end) end; tracers={} end
end); regT(visPage,setTracers,false)
 
local setChams=makeToggle(visPage,"Chams",O(),function(s)
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=player and plr.Character then
            local h=plr.Character:FindFirstChild("VoidChams")
            if s and not h then
                local hl=Instance.new("SelectionBox",plr.Character); hl.Name="VoidChams"
                hl.Adornee=plr.Character; hl.LineThickness=0.04; hl.Color3=C.accent
                hl.SurfaceTransparency=0.85; hl.SurfaceColor3=C.accent
            elseif not s and h then h:Destroy() end
        end
    end
end); regT(visPage,setChams,false)
 
local setFreezeChar=makeToggle(visPage,"Freeze Self",O(),function(s)
    local root=getRoot(); if not root then return end
    if s then
        local bg=Instance.new("BodyGyro",root); bg.Name="FrzG"; bg.MaxTorque=Vector3.new(1e9,1e9,1e9); bg.D=500; bg.P=1e6; bg.CFrame=root.CFrame
        local bv=Instance.new("BodyVelocity",root); bv.Name="FrzV"; bv.Velocity=Vector3.zero; bv.MaxForce=Vector3.new(1e9,1e9,1e9)
    else
        local r=getRoot(); if not r then return end
        for _,v in ipairs(r:GetChildren()) do if v.Name=="FrzG" or v.Name=="FrzV" then v:Destroy() end end
    end
end); regT(visPage,setFreezeChar,false)
 
secLabel(visPage,"Camera FX",O())
local setNightVis=makeToggle(visPage,"Night Vision",O(),function(s)
    if s then
        local cc=Lighting:FindFirstChild("VoidNV") or Instance.new("ColorCorrectionEffect",Lighting)
        cc.Name="VoidNV"; cc.Brightness=0.3; cc.Contrast=0.5; cc.TintColor=Color3.fromRGB(180,255,180)
    else local cc=Lighting:FindFirstChild("VoidNV"); if cc then cc:Destroy() end end
    Lighting.Brightness=s and 6 or DEF.lighting.Brightness; Lighting.GlobalShadows=not s
end); regT(visPage,setNightVis,false)
 
local setBlur=makeToggle(visPage,"Blur World",O(),function(s)
    if s then local b=Lighting:FindFirstChild("VoidBlur") or Instance.new("BlurEffect",Lighting); b.Name="VoidBlur"; b.Size=18
    else local b=Lighting:FindFirstChild("VoidBlur"); if b then b:Destroy() end end
end); regT(visPage,setBlur,false)
 
local setScopeZoom=makeToggle(visPage,"Scope Zoom",O(),function(s)
    camera.FieldOfView=s and 20 or gv("fov",DEF.fov)
end); regT(visPage,setScopeZoom,false)
 
local setDarkness=makeToggle(visPage,"Darkness",O(),function(s)
    Lighting.Brightness=s and 0 or DEF.lighting.Brightness
    Lighting.Ambient=s and Color3.fromRGB(0,0,0) or DEF.lighting.Ambient
end); regT(visPage,setDarkness,false)
 
local setSat=makeSlider(visPage,"Saturation",-1,5,0,O(),function(v)
    local cc=Lighting:FindFirstChild("VoidCC") or Instance.new("ColorCorrectionEffect",Lighting); cc.Name="VoidCC"; cc.Saturation=v
end); regS(visPage,setSat,0)
local setCon=makeSlider(visPage,"Contrast",-1,3,0,O(),function(v)
    local cc=Lighting:FindFirstChild("VoidCC") or Instance.new("ColorCorrectionEffect",Lighting); cc.Name="VoidCC"; cc.Contrast=v
end); regS(visPage,setCon,0)
 
secLabel(visPage,"Lighting",O())
local setFB,togFB=makeToggle(visPage,"Fullbright",O(),function(s)
    Lighting.Brightness=s and 8 or DEF.lighting.Brightness; Lighting.GlobalShadows=not s
end); regT(visPage,setFB,false)
 
local setRL=makeToggle(visPage,"Rainbow Lighting",O(),function(s)
    if s then _G.vRL=RunService.RenderStepped:Connect(function() Lighting.Ambient=Color3.fromHSV(tick()%5/5,1,1) end)
    else if _G.vRL then _G.vRL:Disconnect(); _G.vRL=nil end; Lighting.Ambient=DEF.lighting.Ambient end
end); regT(visPage,setRL,false)
 
local setPSky=makeToggle(visPage,"Purple Sky",O(),function(s)
    Lighting.Ambient=s and Color3.fromRGB(120,70,255) or DEF.lighting.Ambient
    Lighting.OutdoorAmbient=s and Color3.fromRGB(100,50,200) or DEF.lighting.OutdoorAmbient
end); regT(visPage,setPSky,false)
 
local setFogW=makeToggle(visPage,"Fog World",O(),function(s)
    Lighting.FogEnd=s and 60 or DEF.lighting.FogEnd
end); regT(visPage,setFogW,false)
 
local setTOD=makeSlider(visPage,"Time of Day",0,24,DEF.lighting.ClockTime,O(),function(v) Lighting.ClockTime=v end); regS(visPage,setTOD,DEF.lighting.ClockTime)
local setFogD=makeSlider(visPage,"Fog Distance",10,2000,1000,O(),function(v) Lighting.FogEnd=v end); regS(visPage,setFogD,1000)
local setBrightS=makeSlider(visPage,"Brightness",0,10,DEF.lighting.Brightness,O(),function(v) Lighting.Brightness=v end); regS(visPage,setBrightS,DEF.lighting.Brightness)
 
makeABtn(visPage,"Day",O(),function() Lighting.ClockTime=14 end)
makeBtn(visPage,"Sunrise",Color3.fromRGB(200,100,40),O(),function() Lighting.ClockTime=6 end)
makeBtn(visPage,"Sunset",Color3.fromRGB(180,60,30),O(),function() Lighting.ClockTime=19 end)
makeBtn(visPage,"Night",Color3.fromRGB(30,25,80),O(),function() Lighting.ClockTime=0 end)
makeBtn(visPage,"Reset Lighting",TH().off,O(),function()
    Lighting.Brightness=DEF.lighting.Brightness; Lighting.GlobalShadows=DEF.lighting.GlobalShadows
    Lighting.FogEnd=DEF.lighting.FogEnd; Lighting.Ambient=DEF.lighting.Ambient
    Lighting.OutdoorAmbient=DEF.lighting.OutdoorAmbient; Lighting.ClockTime=DEF.lighting.ClockTime
    for _,n in ipairs({"VoidCC","VoidNV","VoidBlur"}) do local v=Lighting:FindFirstChild(n); if v then v:Destroy() end end
end)
 
makeResetBtn(visPage,O(),function()
    if _G.vRL       then _G.vRL:Disconnect();        _G.vRL=nil        end
    if _G.vNeonWorld then _G.vNeonWorld:Disconnect(); _G.vNeonWorld=nil end
    if _G.vPlatform  then _G.vPlatform:Destroy();     _G.vPlatform=nil  end
    if _G.vOrbit     then _G.vOrbit:Destroy();         _G.vOrbit=nil     end
    if _G.vRainbowChar then _G.vRainbowChar:Disconnect(); _G.vRainbowChar=nil end
    if _G.vPartRain  then _G.vPartRain:Disconnect();   _G.vPartRain=nil  end
    tracersOn=false; for _,l in pairs(tracers) do pcall(function() l:Remove() end) end; tracers={}
    Lighting.Brightness=DEF.lighting.Brightness; Lighting.GlobalShadows=DEF.lighting.GlobalShadows
    Lighting.FogEnd=DEF.lighting.FogEnd; Lighting.Ambient=DEF.lighting.Ambient
    Lighting.OutdoorAmbient=DEF.lighting.OutdoorAmbient; Lighting.ClockTime=DEF.lighting.ClockTime
    for _,n in ipairs({"VoidCC","VoidNV","VoidBlur"}) do local v=Lighting:FindFirstChild(n); if v then v:Destroy() end end
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr.Character then local h=plr.Character:FindFirstChild("VoidChams"); if h then h:Destroy() end end
    end
    local char=player.Character
    if char then
        local hd=char:FindFirstChild("Head"); if hd then local b=hd:FindFirstChild("VoidTag"); if b then b:Destroy() end end
        for _,v in ipairs(char:GetDescendants()) do
            if v:IsA("Fire")     and v.Name=="VoidFire"  then v:Destroy() end
            if v:IsA("Smoke")    and v.Name=="VoidSmoke" then v:Destroy() end
            if v:IsA("Sparkles") and v.Name=="VoidIce"   then v:Destroy() end
            if v:IsA("BasePart") then v.Transparency=0 end
        end
        local head=char:FindFirstChild("Head"); if head then head.Size=Vector3.new(2,1,1) end
    end
    local root=getRoot()
    if root then
        for _,v in ipairs(root:GetChildren()) do
            if v:IsA("Trail") or (v:IsA("Attachment") and v.Name:find("TrailA")) then v:Destroy() end
            if v.Name=="FrzG" or v.Name=="FrzV" then v:Destroy() end
        end
    end
    resetT(visPage); resetS(visPage)
end)
 
-- ═══ PLAYERS ══════════════════════════════════════════════════
makeABtn(tpPage,"Stop Spectating",O(),function()
    camera.CameraSubject=getHum(); camera.CameraType=Enum.CameraType.Custom
end)
makeBtn(tpPage,"Print All Players",C.accent2,O(),function()
    print("=== Players in Server ===")
    for _,plr in ipairs(Players:GetPlayers()) do print(string.format("[%d] %s",plr.UserId,plr.Name)) end
end)
local function refreshPlayers()
    for _,v in ipairs(tpPage:GetChildren()) do if v.Name=="PlayerCard" then v:Destroy() end end
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=player then
            local card=makeCard(tpPage,70,O()); card.Name="PlayerCard"
            local nm=Instance.new("TextLabel",card); nm.BackgroundTransparency=1
            nm.Position=UDim2.new(0,14,0,0); nm.Size=UDim2.new(0.34,0,1,0)
            nm.Text=plr.Name; nm.Font=Enum.Font.GothamBold; nm.TextSize=FONT_SZ
            nm.TextColor3=TH().text; nm.TextXAlignment=Enum.TextXAlignment.Left
            nm.TextTruncate=Enum.TextTruncate.AtEnd; tT(nm,"TextColor3","text")
            local bw=IS_MOBILE and 70 or 80
            local function mkB(txt,col,xoff)
                local b=Instance.new("TextButton",card)
                b.Size=UDim2.new(0,bw,0,32); b.Position=UDim2.new(1,xoff,0.5,-16)
                b.BackgroundColor3=col; b.Text=txt; b.TextColor3=Color3.new(1,1,1)
                b.Font=Enum.Font.GothamBold; b.TextSize=12; b.BorderSizePixel=0
                Instance.new("UICorner",b).CornerRadius=UDim.new(1,0); return b
            end
            local tp2=mkB("Teleport",C.accent,-(bw*3+6)); tA(tp2,"BackgroundColor3")
            tp2.MouseButton1Click:Connect(function()
                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    getRoot().CFrame=plr.Character.HumanoidRootPart.CFrame+Vector3.new(0,3,0)
                end
            end)
            local sp=mkB("Spectate",C.accent2,-(bw*2+4))
            sp.MouseButton1Click:Connect(function()
                if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                    camera.CameraSubject=plr.Character.Humanoid
                end
            end)
            local ab=mkB("Above",Color3.fromRGB(80,50,200),-(bw+2))
            ab.MouseButton1Click:Connect(function()
                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    getRoot().CFrame=plr.Character.HumanoidRootPart.CFrame+Vector3.new(0,22,0)
                end
            end)
        end
    end
end
refreshPlayers()
Players.PlayerAdded:Connect(refreshPlayers); Players.PlayerRemoving:Connect(refreshPlayers)
makeABtn(tpPage,"Refresh List",O(),refreshPlayers)
 
-- ═══ MISC ═════════════════════════════════════════════════════
secLabel(miscPage,"Protection",O())
local setAF,togAF=makeToggle(miscPage,"Anti-Fling",O(),function(s) antiFling=s end); regT(miscPage,setAF,false)
 
-- Live server clock card
do
    local clockCard=makeCard(miscPage,50,O()); clockCard.BackgroundTransparency=isDark and 0.4 or 0.05
    local clockLbl=Instance.new("TextLabel",clockCard)
    clockLbl.Size=UDim2.new(1,-20,1,0); clockLbl.Position=UDim2.new(0,14,0,0)
    clockLbl.BackgroundTransparency=1; clockLbl.Font=Enum.Font.GothamMedium; clockLbl.TextSize=13
    clockLbl.TextColor3=TH().sub; clockLbl.TextXAlignment=Enum.TextXAlignment.Left; tT(clockLbl,"TextColor3","sub")
    RunService.Heartbeat:Connect(function()
        local root=getRoot()
        local spd=root and math.floor(root.Velocity.Magnitude) or 0
        local h2=getHum()
        local hp=h2 and math.floor(h2.Health) or 0
        clockLbl.Text=string.format("HP: %d  |  Speed: %d  |  Fly: %s  |  Players: %d",
            hp, spd, fly and "ON" or "OFF", #Players:GetPlayers())
    end)
end
 
secLabel(miscPage,"Info & Copy",O())
makeBtn(miscPage,"Copy UserID",C.accent2,O(),function()
    if setclipboard then setclipboard(tostring(player.UserId)) end
    print("UserID: "..player.UserId)
end)
makeBtn(miscPage,"Copy Position",C.accent2,O(),function()
    if setclipboard and getRoot() then setclipboard(tostring(getRoot().Position)) end
end)
makeBtn(miscPage,"Copy Camera CFrame",C.accent2,O(),function()
    if setclipboard then setclipboard(tostring(camera.CFrame)) end
end)
makeABtn(miscPage,"Server Info",O(),function()
    local ok,name=pcall(function() return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name end)
    local msg=string.format("Game: %s\nPlaceID: %d\nPlayers: %d/%d\nJobID: %s",
        ok and name or "Unknown",game.PlaceId,#Players:GetPlayers(),Players.MaxPlayers,
        tostring(game.JobId):sub(1,20).."...")
    print(msg); if setclipboard then setclipboard(msg) end
end)
 
secLabel(miscPage,"Quick",O())
makeBtn(miscPage,"Reset Character",TH().red,O(),function()
    local h=getHum(); if h then h.Health=0 end
end)
makeBtn(miscPage,"FPS Boost",C.accent2,O(),function()
    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then v.Material=Enum.Material.Plastic; v.Reflectance=0 end
    end
    Lighting.GlobalShadows=false
end)
makeResetBtn(miscPage,O(),function() antiFling=false; resetT(miscPage) end)
 
-- ═══ UTILITY ══════════════════════════════════════════════════
secLabel(utilPage,"Actions",O())
makeABtn(utilPage,"Rejoin Server",O(),function() TeleportSvc:Teleport(game.PlaceId,player) end)
makeBtn(utilPage,"Copy Position",C.accent2,O(),function()
    if setclipboard and getRoot() then setclipboard(tostring(getRoot().Position)) end
end)
makeBtn(utilPage,"Copy Look Vector",C.accent2,O(),function()
    if setclipboard then setclipboard(tostring(camera.CFrame.LookVector)) end
end)
makeBtn(utilPage,"Anti AFK",C.accent2,O(),function()
    player.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0,0),camera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0),camera.CFrame)
    end)
end)
secLabel(utilPage,"Camera",O())
makeBtn(utilPage,"First Person",C.accent2,O(),function() player.CameraMinZoomDistance=0; player.CameraMaxZoomDistance=0 end)
makeBtn(utilPage,"Third Person",TH().off,O(),function() player.CameraMinZoomDistance=0.5; player.CameraMaxZoomDistance=400 end)
makeBtn(utilPage,"Lock Zoom (10)",TH().off,O(),function() player.CameraMinZoomDistance=10; player.CameraMaxZoomDistance=10 end)
local setFOV=makeSlider(utilPage,"FOV",10,120,gv("fov",DEF.fov),O(),function(v) camera.FieldOfView=v; sv("fov",v) end); regS(utilPage,setFOV,DEF.fov)
makeResetBtn(utilPage,O(),function()
    camera.FieldOfView=DEF.fov; sv("fov",DEF.fov)
    player.CameraMinZoomDistance=0.5; player.CameraMaxZoomDistance=400; resetS(utilPage)
end)
 
-- ═══ KEYBINDS ════════════════════════════════════════════════
if not IS_MOBILE then
    secLabel(kbPage,"Click [KEY] to rebind  |  Click [X] to unbind",O())
    local kbDefs={
        {label="Flight",         key="fly",        save="kb_fly"},
        {label="Void",           key="void",       save="kb_void"},
        {label="Mega Void",      key="mega",       save="kb_mega"},
        {label="Hide UI",        key="hideUI",     save="kb_hideUI"},
        {label="Noclip",         key="noclip",     save="kb_noclip"},
        {label="Tracers",        key="tracers",    save="kb_tracers"},
        {label="Bunny Hop",      key="bhop",       save="kb_bhop"},
        {label="Infinite Jump",  key="infJump",    save="kb_infJump"},
        {label="Fullbright",     key="fullbright", save="kb_fullbright"},
        {label="Click Teleport", key="clickTP",    save="kb_clickTP"},
        {label="Spinbot",        key="spinbot",    save="kb_spinbot"},
        {label="Anti-Fling",     key="antiFling",  save="kb_antiFling"},
    }
    local kbBtns={}; local listeningFor=nil
    for _,def in ipairs(kbDefs) do
        local card=makeCard(kbPage,56,O())
        local lbl=Instance.new("TextLabel",card); lbl.BackgroundTransparency=1
        lbl.Position=UDim2.new(0,16,0,0); lbl.Size=UDim2.new(0.48,0,1,0)
        lbl.Text=def.label; lbl.TextColor3=TH().text; lbl.Font=Enum.Font.GothamMedium
        lbl.TextSize=14; lbl.TextXAlignment=Enum.TextXAlignment.Left; tT(lbl,"TextColor3","text")
        local bindBtn=Instance.new("TextButton",card)
        bindBtn.Size=UDim2.new(0,120,0,32); bindBtn.Position=UDim2.new(1,-170,0.5,-16)
        bindBtn.BackgroundColor3=KB[def.key] and C.accent2 or TH().off
        bindBtn.Text="[ "..kbName(KB[def.key]).." ]"
        bindBtn.Font=Enum.Font.GothamBold; bindBtn.TextSize=13
        bindBtn.TextColor3=TH().text; bindBtn.BorderSizePixel=0
        Instance.new("UICorner",bindBtn).CornerRadius=UDim.new(1,0); tA(bindBtn,"BackgroundColor3")
        local unBtn=Instance.new("TextButton",card)
        unBtn.Size=UDim2.new(0,36,0,32); unBtn.Position=UDim2.new(1,-42,0.5,-16)
        unBtn.BackgroundColor3=TH().red; unBtn.Text="X"; unBtn.Font=Enum.Font.GothamBold; unBtn.TextSize=13
        unBtn.TextColor3=Color3.new(1,1,1); unBtn.BorderSizePixel=0
        Instance.new("UICorner",unBtn).CornerRadius=UDim.new(1,0)
        kbBtns[def.key]={bind=bindBtn, save=def.save}
        bindBtn.MouseButton1Click:Connect(function()
            if listeningFor then return end
            listeningFor=def.key; bindBtn.Text="Press a key..."; bindBtn.BackgroundColor3=TH().red
        end)
        unBtn.MouseButton1Click:Connect(function()
            KB[def.key]=nil; sv(def.save,"NONE"); bindBtn.Text="[ -- ]"; bindBtn.BackgroundColor3=TH().off; updateSubLbl()
        end)
    end
    UIS.InputBegan:Connect(function(inp,gp)
        if listeningFor then
            if inp.UserInputType==Enum.UserInputType.Keyboard then
                for _,d in ipairs(kbDefs) do
                    if KB[d.key]==inp.KeyCode and d.key~=listeningFor then
                        KB[d.key]=nil; sv(d.save,"NONE")
                        if kbBtns[d.key] then kbBtns[d.key].bind.Text="[ -- ]"; kbBtns[d.key].bind.BackgroundColor3=TH().off end
                    end
                end
                KB[listeningFor]=inp.KeyCode
                local entry=kbBtns[listeningFor]
                if entry then entry.bind.Text="[ "..kbName(inp.KeyCode).." ]"; entry.bind.BackgroundColor3=C.accent2; sv(entry.save,inp.KeyCode.Name) end
                listeningFor=nil; updateSubLbl()
            end
            return
        end
    end,true)
    do
        local ic=makeCard(kbPage,44,O()); ic.BackgroundTransparency=isDark and 0.5 or 0.1
        local il=Instance.new("TextLabel",ic)
        il.Size=UDim2.new(1,-20,1,0); il.Position=UDim2.new(0,14,0,0)
        il.BackgroundTransparency=1; il.Font=Enum.Font.Gotham; il.TextSize=11
        il.TextColor3=TH().sub; il.TextXAlignment=Enum.TextXAlignment.Left; il.TextWrapped=true
        tT(il,"TextColor3","sub")
        il.Text="All keybinds start unbound. Click [KEY] to assign, [X] to clear. Saved automatically."
    end
else
    local ic=makeCard(kbPage,60,O()); ic.BackgroundTransparency=isDark and 0.3 or 0.05
    local il=Instance.new("TextLabel",ic)
    il.Size=UDim2.new(1,-20,1,0); il.Position=UDim2.new(0,14,0,0)
    il.BackgroundTransparency=1; il.Font=Enum.Font.Gotham; il.TextSize=13
    il.TextColor3=TH().sub; il.TextXAlignment=Enum.TextXAlignment.Left; il.TextWrapped=true; tT(il,"TextColor3","sub")
    il.Text="Keybinds are desktop only. Use the toggles in each tab directly on mobile."
end
 
-- ═══ SETTINGS ════════════════════════════════════════════════
secLabel(setPage,"Theme",O())
 
local function makeThemeCard(parent,order,dark)
    local card=makeCard(parent,70,order)
    card.BackgroundColor3=dark and Color3.fromRGB(12,10,28) or Color3.fromRGB(248,246,255)
    card.BackgroundTransparency=dark and 0.08 or 0.0
    local img=Instance.new("ImageLabel",card)
    img.Size=UDim2.new(0,42,0,42); img.Position=UDim2.new(0,12,0.5,-21)
    img.BackgroundTransparency=1; img.Image=LOGO_ID
    img.ImageTransparency=0; img.ScaleType=Enum.ScaleType.Fit
    local nameLbl=Instance.new("TextLabel",card); nameLbl.BackgroundTransparency=1
    nameLbl.Position=UDim2.new(0,64,0,10); nameLbl.Size=UDim2.new(0.45,0,0,22)
    nameLbl.Text=dark and "Dark Mode" or "Light Mode"; nameLbl.Font=Enum.Font.GothamBold; nameLbl.TextSize=14
    nameLbl.TextColor3=dark and Color3.fromRGB(200,185,255) or Color3.fromRGB(45,28,110)
    nameLbl.TextXAlignment=Enum.TextXAlignment.Left
    local descLbl=Instance.new("TextLabel",card); descLbl.BackgroundTransparency=1
    descLbl.Position=UDim2.new(0,64,0,32); descLbl.Size=UDim2.new(0.5,0,0,16)
    descLbl.Text=dark and "Dark purple glass" or "Clean white style"; descLbl.Font=Enum.Font.Gotham; descLbl.TextSize=11
    descLbl.TextColor3=dark and Color3.fromRGB(110,100,150) or Color3.fromRGB(80,65,120)
    descLbl.TextXAlignment=Enum.TextXAlignment.Left
    local applyBtn=Instance.new("TextButton",card)
    applyBtn.Size=UDim2.new(0,88,0,34); applyBtn.Position=UDim2.new(1,-104,0.5,-17)
    applyBtn.BackgroundColor3=dark and Color3.fromRGB(55,35,115) or Color3.fromRGB(130,70,255)
    applyBtn.Text=(dark==isDark) and "Active" or "Apply"
    applyBtn.Font=Enum.Font.GothamBold; applyBtn.TextSize=13
    applyBtn.TextColor3=Color3.new(1,1,1); applyBtn.BorderSizePixel=0
    Instance.new("UICorner",applyBtn).CornerRadius=UDim.new(1,0)
    applyBtn.MouseButton1Click:Connect(function()
        if isDark==dark then return end
        isDark=dark; sv("isDark",dark)
        applyTheme(); refreshGradient()
        main.BackgroundColor3=TH().bg
        top.BackgroundColor3=TH().top; topFix.BackgroundColor3=TH().top
        applyBtn.Text="Active"
    end)
end
makeThemeCard(setPage,O(),true)
makeThemeCard(setPage,O(),false)
 
secLabel(setPage,"UI",O())
local setUITrans=makeSlider(setPage,"UI Transparency",0,90,gv("uiTrans",math.floor(TH().bgT*100)),O(),function(v)
    main.BackgroundTransparency=v/100; sv("uiTrans",v)
end); regS(setPage,setUITrans,math.floor(TH().bgT*100))
local setUIScale=makeSlider(setPage,"UI Scale",60,130,gv("uiScale",100),O(),function(v)
    local s=main:FindFirstChildOfClass("UIScale") or Instance.new("UIScale",main); s.Scale=v/100; sv("uiScale",v)
end); regS(setPage,setUIScale,100)
 
secLabel(setPage,"Accent Color",O())
local accentList={
    {"Purple",   Color3.fromRGB(130,70,255),  Color3.fromRGB(100,50,220)},
    {"Blue",     Color3.fromRGB(50,120,255),  Color3.fromRGB(30,90,210)},
    {"Cyan",     Color3.fromRGB(40,200,220),  Color3.fromRGB(25,155,185)},
    {"Green",    Color3.fromRGB(50,210,100),  Color3.fromRGB(30,165,65)},
    {"Pink",     Color3.fromRGB(230,80,180),  Color3.fromRGB(185,45,145)},
    {"Red",      Color3.fromRGB(220,60,60),   Color3.fromRGB(175,30,30)},
    {"Orange",   Color3.fromRGB(230,130,40),  Color3.fromRGB(185,90,15)},
    {"Gold",     Color3.fromRGB(210,170,40),  Color3.fromRGB(170,130,15)},
    {"White",    Color3.fromRGB(220,220,230), Color3.fromRGB(170,170,190)},
    {"Teal",     Color3.fromRGB(30,200,160),  Color3.fromRGB(20,155,120)},
    {"Lavender", Color3.fromRGB(180,140,255), Color3.fromRGB(140,100,220)},
    {"Coral",    Color3.fromRGB(255,100,80),  Color3.fromRGB(210,65,50)},
}
local rowFrame; local rowCount=0
for _,ac in ipairs(accentList) do
    if rowCount==0 then
        rowFrame=Instance.new("Frame",setPage)
        rowFrame.Size=UDim2.new(1,-4,0,44); rowFrame.BackgroundTransparency=1; rowFrame.LayoutOrder=O()
        local ll=Instance.new("UIListLayout",rowFrame); ll.FillDirection=Enum.FillDirection.Horizontal; ll.Padding=UDim.new(0,7)
    end
    local btn=Instance.new("TextButton",rowFrame)
    btn.Size=UDim2.new(0,0,1,0); btn.AutomaticSize=Enum.AutomaticSize.X
    btn.BackgroundColor3=ac[2]; btn.BorderSizePixel=0
    btn.Text=" "..ac[1].." "; btn.Font=Enum.Font.GothamBold; btn.TextSize=12; btn.TextColor3=Color3.new(1,1,1)
    Instance.new("UICorner",btn).CornerRadius=UDim.new(1,0)
    local up=Instance.new("UIPadding",btn); up.PaddingLeft=UDim.new(0,10); up.PaddingRight=UDim.new(0,10)
    btn.MouseButton1Click:Connect(function()
        applyAccent(ac[2],ac[3])
        sv("aR",ac[2].R); sv("aG",ac[2].G); sv("aB",ac[2].B)
        sv("a2R",ac[3].R); sv("a2G",ac[3].G); sv("a2B",ac[3].B)
        TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=Color3.new(1,1,1)}):Play()
        task.delay(0.18,function() TweenService:Create(btn,TweenInfo.new(0.18),{BackgroundColor3=ac[2]}):Play() end)
    end)
    rowCount=(rowCount+1)%4
end
 
secLabel(setPage,"Danger Zone",O())
makeBtn(setPage,"Destroy UI",TH().red,O(),function() gui:Destroy() end)
makeBtn(setPage,"Clear Saved Data",Color3.fromRGB(140,30,30),O(),function()
    saveData={}; writeSave(); print("Voidor Z: save data cleared")
end)
makeResetBtn(setPage,O(),function()
    local sc=main:FindFirstChildOfClass("UIScale"); if sc then sc.Scale=1 end
    main.BackgroundTransparency=TH().bgT
    applyAccent(Color3.fromRGB(130,70,255),Color3.fromRGB(100,50,220))
    sv("uiTrans",math.floor(TH().bgT*100)); sv("uiScale",100)
    sv("aR",nil); sv("aG",nil); sv("aB",nil)
    resetT(setPage); resetS(setPage)
end)
 
-- ═══ ANIMATED ACCENT DOT IN TOPBAR ════════════════════════════
do
    local accentDot=Instance.new("Frame",top)
    accentDot.Size=UDim2.new(0,6,0,6)
    accentDot.Position=UDim2.new(1,-120,0.5,-3)
    accentDot.BackgroundColor3=C.accent; accentDot.BorderSizePixel=0
    Instance.new("UICorner",accentDot).CornerRadius=UDim.new(1,0); tA(accentDot,"BackgroundColor3")
    local function pulseDot()
        TweenService:Create(accentDot,TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{BackgroundTransparency=0.7}):Play()
        task.delay(1,function()
            TweenService:Create(accentDot,TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{BackgroundTransparency=0}):Play()
            task.delay(1,pulseDot)
        end)
    end
    pulseDot()
end
 
-- ═══ GLOBAL KEYBIND HANDLER ═══════════════════════════════════
UIS.InputBegan:Connect(function(inp,gp)
    if gp then return end
    if inp.UserInputType==Enum.UserInputType.Keyboard then
        local kc=inp.KeyCode
        if KB.fly        and kc==KB.fly        then togFly()      end
        if KB.hideUI     and kc==KB.hideUI     then main.Visible=not main.Visible end
        if KB.void       and kc==KB.void       then local r=getRoot(); if r then r.CFrame=CFrame.new(r.Position+Vector3.new(0,9e4,0)) end end
        if KB.mega       and kc==KB.mega       then local r=getRoot(); if r then r.CFrame=CFrame.new(r.Position+Vector3.new(0,9e6,0)) end end
        if KB.noclip     and kc==KB.noclip     then togNoclip()   end
        if KB.tracers    and kc==KB.tracers    then togTracers()   end
        if KB.bhop       and kc==KB.bhop       then togBhop()     end
        if KB.infJump    and kc==KB.infJump    then togInfJ()     end
        if KB.fullbright and kc==KB.fullbright then togFB()       end
        if KB.clickTP    and kc==KB.clickTP    then togClickTP()  end
        if KB.spinbot    and kc==KB.spinbot    then togSpinbot()  end
        if KB.antiFling  and kc==KB.antiFling  then togAF()       end
    end
    if inp.UserInputType==Enum.UserInputType.MouseButton1 and clickTP then
        local r=getRoot()
        if r then r.CFrame=CFrame.new(player:GetMouse().Hit.Position+Vector3.new(0,3,0)) end
    end
end)
 
UIS.JumpRequest:Connect(function()
    if infJump then local h=getHum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end
end)
 
-- ═══ MAIN LOOP ════════════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    if fly then
        local root=getRoot()
        if root then
            local dir=Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then dir+=camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then dir-=camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then dir-=camera.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then dir+=camera.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space)     then dir+=Vector3.new(0,1,0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir-=Vector3.new(0,1,0) end
            if dir.Magnitude>0 then dir=dir.Unit end
            root.AssemblyLinearVelocity=dir*flySpeed
        end
    end
    if noclip then
        for _,v in ipairs(getChar():GetDescendants()) do if v:IsA("BasePart") then v.CanCollide=false end end
    end
    if bhop then
        local h=getHum()
        if h and h.FloorMaterial~=Enum.Material.Air then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
    if spinbot then
        local root=getRoot(); if root then root.CFrame=root.CFrame*CFrame.Angles(0,math.rad(22),0) end
    end
    if _G.vPlatform and getRoot() then _G.vPlatform.Position=getRoot().Position-Vector3.new(0,4,0) end
    if _G.vOrbit and getRoot() then
        _G.vOrbitA=(_G.vOrbitA or 0)+0.02
        local r=getRoot()
        _G.vOrbit.CFrame=CFrame.new(r.Position+Vector3.new(math.cos(_G.vOrbitA)*10,0,math.sin(_G.vOrbitA)*10))
    end
    if tracersOn then
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr~=player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                if not tracers[plr] then
                    local line=Drawing.new("Line"); line.Color=C.accent; line.Thickness=1.5; line.Transparency=1
                    tracers[plr]=line
                end
                local pos,vis=camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
                if vis then
                    tracers[plr].From=Vector2.new(camera.ViewportSize.X/2,camera.ViewportSize.Y)
                    tracers[plr].To=Vector2.new(pos.X,pos.Y); tracers[plr].Visible=true
                else
                    tracers[plr].Visible=false
                end
            end
        end
    end
end)
 
-- ═══ LAUNCH ═══════════════════════════════════════════════════
switchPage("Movement")
main.Visible=false
 
task.spawn(function()
    local tw=TweenService; task.wait(0.1)
    tw:Create(lTitle,TweenInfo.new(0.6),{TextTransparency=0}):Play()
    task.wait(0.4)
    tw:Create(lSub, TweenInfo.new(0.8),{TextTransparency=0}):Play()
    tw:Create(lStat,TweenInfo.new(0.8),{TextTransparency=0}):Play()
    task.wait(0.4)
    local steps={
        {t="Loading modules...",   p=0.15},
        {t="Building UI...",       p=0.38},
        {t="Hooking services...",  p=0.60},
        {t="Applying settings...", p=0.82},
        {t="Almost ready...",      p=0.95},
        {t="Welcome to Voidor Z!", p=1.00},
    }
    for _,step in ipairs(steps) do
        lStat.Text=step.t
        tw:Create(lBarFill,TweenInfo.new(0.3,Enum.EasingStyle.Quad),{Size=UDim2.new(step.p,0,1,0)}):Play()
        task.wait(0.34)
    end
    task.wait(0.4)
    local fadeItems={
        {lb,"BackgroundTransparency"},{lTitle,"TextTransparency"},
        {lSub,"TextTransparency"},{lStat,"TextTransparency"},
        {lBarTrack,"BackgroundTransparency"},{lBarFill,"BackgroundTransparency"},
    }
    for _,f in ipairs(fadeItems) do tw:Create(f[1],TweenInfo.new(0.55),{[f[2]]=1}):Play() end
    -- Fade logo last so it lingers
    tw:Create(lLogo,TweenInfo.new(0.8),{ImageTransparency=1}):Play()
    task.wait(0.7)
    main.Visible=true
    loadGui:Destroy()
end)
 
print("Voidor Z ScriptHub v1.4.0 loaded | Theme: "..(isDark and "Dark" or "Light"))
