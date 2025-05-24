local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")


local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local function base64enc(data)
    return ((data:gsub('.', function(x)
        local r, bcode = '', x:byte()
        for i=8,1,-1 do r = r .. (bcode % 2^i - bcode % 2^(i-1) > 0 and '1' or '0') end
        return r
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if #x < 6 then return '' end
        local c = 0
        for i = 1, 6 do c = c + (x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end


local userKeys = {
    [8512879479] = "Quang",
    [7521680762] = "Tony",
    [8527227237] = "Quang",
}


local userKeysBase64 = {}
for userId, key in pairs(userKeys) do
    userKeysBase64[userId] = base64enc(key)
end

local playerUserId = LocalPlayer.UserId
local validBase64Key = userKeysBase64[playerUserId]


if not validBase64Key then
    warn("Liên hệ Quang để lấy key.")
    return
end


local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KeyCheckGui"
ScreenGui.Parent = PlayerGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 150)
Frame.Position = UDim2.new(0.5, -150, 0.5, -75)
Frame.AnchorPoint = Vector2.new(0.5, 0.5)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local TextLabel = Instance.new("TextLabel")
TextLabel.Text = "Nhập key:"
TextLabel.Size = UDim2.new(1, 0, 0, 30)
TextLabel.BackgroundTransparency = 1
TextLabel.TextColor3 = Color3.new(1, 1, 1)
TextLabel.TextScaled = true
TextLabel.Parent = Frame

local TextBox = Instance.new("TextBox")
TextBox.PlaceholderText = "Nhập ở đây"
TextBox.Size = UDim2.new(1, -20, 0, 40)
TextBox.Position = UDim2.new(0, 10, 0, 40)
TextBox.ClearTextOnFocus = false
TextBox.TextScaled = true
TextBox.Parent = Frame

local Button = Instance.new("TextButton")
Button.Text = "Gửi"
Button.Size = UDim2.new(1, -20, 0, 40)
Button.Position = UDim2.new(0, 10, 0, 90)
Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Button.TextColor3 = Color3.new(1, 1, 1)
Button.TextScaled = true
Button.Parent = Frame


local espEnabled = false 
local maxDistance = 2000
local espDrawings = {}
local toggleKey = Enum.KeyCode.F1

local bonePairs = {
    {"ServerColliderHead", "ServerCollider"},
    {"ServerCollider", "HumanoidRootPart"},
    {"HumanoidRootPart", "LeftLeg"},
}


local function createText(size)
    local t = Drawing.new("Text")
    t.Size = size
    t.Center = true
    t.Outline = false
    t.Color = Color3.new(1, 1, 1)
    t.Visible = false
    return t
end


local function CreateESP(player)
    if espDrawings[player] then return end

    local nameTag = createText(18)
    local distanceTag = createText(16)
    local weaponTag = createText(16)

    local boneLines = {}
    for i = 1, #bonePairs do
        local line = Drawing.new("Line")
        line.Thickness = 2
        line.Color = Color3.new(1, 1, 1)
        line.Visible = false
        table.insert(boneLines, line)
    end

    local box = Drawing.new("Square")
    box.Thickness = 1
    box.Color = Color3.new(1, 1, 1)
    box.Visible = false
    box.Filled = false

    local lastUpdate = 0
    local updateInterval = 0.05

    local function UpdateESP(dt)
        if not espEnabled then
            nameTag.Visible = false
            distanceTag.Visible = false
            weaponTag.Visible = false
            for _, line in pairs(boneLines) do line.Visible = false end
            box.Visible = false
            return
        end

        lastUpdate += dt
        if lastUpdate < updateInterval then return end
        lastUpdate = 0

        local char = player.Character
        if not char then return end

        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        local camPos = Camera.CFrame.Position
        local dist = (camPos - root.Position).Magnitude
        if dist > maxDistance then
            nameTag.Visible = false
            distanceTag.Visible = false
            weaponTag.Visible = false
            for _, line in pairs(boneLines) do line.Visible = false end
            box.Visible = false
            return
        end

        local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
        local visible = false

        local glow = 0.5 + 0.5 * math.sin(tick() * 3)
        local animatedColor = Color3.new(1 - glow * 0.5, 1, glow)

        for i, pair in ipairs(bonePairs) do
            local a = char:FindFirstChild(pair[1])
            local b = char:FindFirstChild(pair[2])
            local line = boneLines[i]

            if a and b then
                local sa, va = Camera:WorldToViewportPoint(a.Position)
                local sb, vb = Camera:WorldToViewportPoint(b.Position)

                if va and vb then
                    local va2 = Vector2.new(sa.X, sa.Y)
                    local vb2 = Vector2.new(sb.X, sb.Y)
                    line.From = va2
                    line.To = vb2
                    line.Color = animatedColor
                    line.Visible = true
                    visible = true
                    minX = math.min(minX, va2.X, vb2.X)
                    minY = math.min(minY, va2.Y, vb2.Y)
                    maxX = math.max(maxX, va2.X, vb2.X)
                    maxY = math.max(maxY, va2.Y, vb2.Y)
                else
                    line.Visible = false
                end
            else
                line.Visible = false
            end
        end

        if not visible then
            nameTag.Visible = false
            distanceTag.Visible = false
            weaponTag.Visible = false
            for _, line in pairs(boneLines) do line.Visible = false end
            box.Visible = false
            return
        end

        local boxCenterX = (minX + maxX) / 2

        nameTag.Text = player.Name
        nameTag.Position = Vector2.new(boxCenterX, minY - 40)
        nameTag.Color = animatedColor
        nameTag.Visible = true

        distanceTag.Text = math.floor(dist) .. " meters"
        distanceTag.Position = Vector2.new(boxCenterX, maxY + 5)
        distanceTag.Color = animatedColor
        distanceTag.Visible = true

        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            weaponTag.Text = tool.Name
            weaponTag.Position = Vector2.new(boxCenterX, maxY + 24)
            weaponTag.Color = animatedColor
            weaponTag.Visible = true
        else
            weaponTag.Visible = false
        end

        box.Position = Vector2.new(minX, minY)
        box.Size = Vector2.new(maxX - minX, maxY - minY)
        box.Color = animatedColor
        box.Visible = true
    end

    local conn = RunService.Heartbeat:Connect(UpdateESP)

    espDrawings[player] = {
        conn = conn,
        bones = boneLines,
        box = box,
        texts = {nameTag, distanceTag, weaponTag},
    }
end

Players.PlayerRemoving:Connect(function(player)
    local esp = espDrawings[player]
    if esp then
        esp.conn:Disconnect()
        for _, obj in pairs(esp.bones) do obj:Remove() end
        for _, t in pairs(esp.texts) do t:Remove() end
        esp.box:Remove()
        espDrawings[player] = nil
    end
end)


local function EnableESP()
    espEnabled = true

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            CreateESP(player)
        end
    end

    Players.PlayerAdded:Connect(function(player)
        if player ~= LocalPlayer then
            player.CharacterAdded:Connect(function()
                wait(1)
                CreateESP(player)
            end)
        end
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == toggleKey then
            espEnabled = not espEnabled
        end
    end)
end

local function runESP()
    ScreenGui:Destroy()
    EnableESP()
end

Button.MouseButton1Click:Connect(function()
    if TextBox.Text == validBase64Key then
        runESP()
    else
        TextLabel.Text = "Sai key, hãy nhập lại."
        TextLabel.TextColor3 = Color3.new(1, 0, 0)
    end
end)
