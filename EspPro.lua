local P=game:GetService("Players")
local R=game:GetService("RunService")
local U=game:GetService("UserInputService")
local H=game:GetService("HttpService")
local C=workspace.CurrentCamera
local L=P.LocalPlayer
local kP={[8512879479]="Quang",[7521680762]="Tony"}
local kB={}
for i,v in pairs(kP)do kB[i]=H:Base64Encode(v)end
local u=L.UserId
local vK=kB[u]
local SG=Instance.new("ScreenGui",L:WaitForChild("PlayerGui"))
SG.Name="KeyCheckGui"
local F=Instance.new("Frame",SG)
F.Size=UDim2.new(0,300,0,150)
F.Position=UDim2.new(0.5,-150,0.5,-75)
F.BackgroundColor3=Color3.fromRGB(30,30,30)
F.BorderSizePixel=0
F.AnchorPoint=Vector2.new(0.5,0.5)
local TL=Instance.new("TextLabel",F)
TL.Text="Nhập key:"
TL.Size=UDim2.new(1,0,0,30)
TL.BackgroundTransparency=1
TL.TextColor3=Color3.new(1,1,1)
TL.TextScaled=true
local TB=Instance.new("TextBox",F)
TB.PlaceholderText="Nhập ở đây"
TB.Size=UDim2.new(1,-20,0,40)
TB.Position=UDim2.new(0,10,0,40)
TB.Text=""
TB.ClearTextOnFocus=false
TB.TextScaled=true
local B=Instance.new("TextButton",F)
B.Text="Submit"
B.Size=UDim2.new(1,-20,0,40)
B.Position=UDim2.new(0,10,0,90)
B.BackgroundColor3=Color3.fromRGB(50,50,50)
B.TextColor3=Color3.new(1,1,1)
B.TextScaled=true
if not vK then
  TL.Text="Sai key. kút."
  TL.TextColor3=Color3.fromRGB(255,0,0)
  TB:Destroy()
  B:Destroy()
  return
end
local e=true
local m=2000
local d={}
local t=Enum.KeyCode.F1
local bP={{"ServerColliderHead","ServerCollider"},{"ServerCollider","HumanoidRootPart"},{"HumanoidRootPart","LeftLeg"}}
local function cT(s)
  local t=Drawing.new("Text")
  t.Size=s
  t.Center=true
  t.Outline=false
  t.Color=Color3.new(1,1,1)
  t.Visible=false
  return t
end
local function CESP(p)
 if d[p]then return end
 local nT=cT(18)
 local distT=cT(16)
 local wT=cT(16)
 local bL={}
 for i=1,#bP do
  local l=Drawing.new("Line")
  l.Thickness=2
  l.Color=Color3.new(1,1,1)
  l.Visible=false
  table.insert(bL,l)
 end
 local box=Drawing.new("Square")
 box.Thickness=1
 box.Color=Color3.new(1,1,1)
 box.Visible=false
 box.Filled=false
 local lu=0
 local ui=0.05
 local function UESP(dt)
  if not e then
   nT.Visible=false;distT.Visible=false;wT.Visible=false
   for _,l in pairs(bL)do l.Visible=false end
   box.Visible=false
   return
  end
  lu+=dt
  if lu<ui then return end
  lu=0
  local c=p.Character
  if not c then return end
  local r=c:FindFirstChild("HumanoidRootPart")
  if not r then return end
  local cp=C.CFrame.Position
  local dist=(cp-r.Position).Magnitude
  if dist>m then
   nT.Visible=false;distT.Visible=false;wT.Visible=false
   for _,l in pairs(bL)do l.Visible=false end
   box.Visible=false
   return
  end
  local minX,minY,maxX,maxY=math.huge,math.huge,-math.huge,-math.huge
  local vis=false
  local glow=0.5+0.5*math.sin(tick()*3)
  local ac=Color3.new(1-glow*0.5,1,glow)
  for i,pair in ipairs(bP)do
   local a,b=c:FindFirstChild(pair[1]),c:FindFirstChild(pair[2])
   local l=bL[i]
   if a and b then
    local sa,va=C:WorldToViewportPoint(a.Position)
    local sb,vb=C:WorldToViewportPoint(b.Position)
    if va and vb then
     local va2,vb2=Vector2.new(sa.X,sa.Y),Vector2.new(sb.X,sb.Y)
     l.From=va2
     l.To=vb2
     l.Color=ac
     l.Visible=true
     vis=true
     minX,minY=math.min(minX,va2.X,vb2.X),math.min(minY,va2.Y,vb2.Y)
     maxX,maxY=math.max(maxX,va2.X,vb2.X),math.max(maxY,va2.Y,vb2.Y)
    else l.Visible=false end
   else l.Visible=false end
  end
  if not vis then
   nT.Visible=false;distT.Visible=false;wT.Visible=false
   for _,l in pairs(bL)do l.Visible=false end
   box.Visible=false
   return
  end
  local cx=(minX+maxX)/2
  nT.Text=p.Name
  nT.Position=Vector2.new(cx,minY-40)
  nT.Color=ac
  nT.Visible=true
  distT.Text=math.floor(dist).." meters"
  distT.Position=Vector2.new(cx,maxY+5)
  distT.Color=ac
  distT.Visible=true
  local tool=c:FindFirstChildOfClass("Tool")
  if tool then
   wT.Text=tool.Name
   wT.Position=Vector2.new(cx,maxY+24)
   wT.Color=ac
   wT.Visible=true
  else wT.Visible=false end
  box.Position=Vector2.new(minX,minY)
  box.Size=Vector2.new(maxX-minX,maxY-minY)
  box.Color=ac
  box.Visible=true
 end
 local conn=R.Heartbeat:Connect(UESP)
 d[p]={conn=conn,bones=bL,box=box,texts={nT,distT,wT}}
end
P.PlayerRemoving:Connect(function(p)
 local esp=d[p]
 if esp then
  esp.conn:Disconnect()
  for _,o in pairs(esp.bones)do o:Remove() end
  for _,t in pairs(esp.texts)do t:Remove() end
  esp.box:Remove()
  d[p]=nil
 end
end)
for _,p in ipairs(P:GetPlayers())do if p~=L then CESP(p) end end
P.PlayerAdded:Connect(function(p)
 if p~=L then
  p.CharacterAdded:Connect(function()
   wait(1)
   CESP(p)
  end)
 end
end)
U.InputBegan:Connect(function(i,gpe)
 if gpe then return end
 if i.KeyCode==t then e=not e end
end)
local function rESP()SG:Destroy()end
B.MouseButton1Click:Connect(function()
 if TB.Text==vK then rESP() else TL.Text="Invalid Key! Try Again." TL.TextColor3=Color3.new(1,0,0) end
end)
