local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer


local userKeysPlain = {
    [8512879479] = "Quang",
    [7521680762] = "Tony",
}


local userKeysBase64 = {}
for userId, keyPlain in pairs(userKeysPlain) do
    userKeysBase64[userId] = HttpService:Base64Encode(keyPlain)
end

local playerUserId = LocalPlayer.UserId
local validKeyBase64 = userKeysBase64[playerUserId]


local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "KeyCheckGui"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 150)
Frame.Position = UDim2.new(0.5, -150, 0.5, -75)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.AnchorPoint = Vector2.new(0.5, 0.5)

local TextLabel = Instance.new("TextLabel", Frame)
TextLabel.Text = "Enter Your Base64 Key to Use Script:"
TextLabel.Size = UDim2.new(1, 0, 0, 30)
TextLabel.BackgroundTransparency = 1
TextLabel.TextColor3 = Color3.new(1,1,1)
TextLabel.TextScaled = true

local TextBox = Instance.new("TextBox", Frame)
TextBox.PlaceholderText = "Base64 key here"
TextBox.Size = UDim2.new(1, -20, 0, 40)
TextBox.Position = UDim2.new(0, 10, 0, 40)
TextBox.Text = ""
TextBox.ClearTextOnFocus = false
TextBox.TextScaled = true

local Button = Instance.new("TextButton", Frame)
Button.Text = "Submit"
Button.Size = UDim2.new(1, -20, 0, 40)
Button.Position = UDim2.new(0, 10, 0, 90)
Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Button.TextColor3 = Color3.new(1,1,1)
Button.TextScaled = true

if not validKeyBase64 then

    TextLabel.Text = "You are not authorized to use this script."
    TextLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    TextBox:Destroy()
    Button:Destroy()
    return
end


local espEnabled = true
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
    for _ = 1, #bonePairs do
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
    local updateInterval = 0.05 -- 20 updates per second

    local function UpdateESP(dt)
        if not espEnabled then
            nameTag.Visible, distanceTag.Visible, weaponTag.Visible = false, false, false
            for _, l in boneLines do l.Visible = false end
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
        local distance = (camPos - root.Position).Magnitude
        if distance > maxDistance then
            nameTag.Visible, distanceTag.Visible, weaponTag.Visible = false, false, false
            for _, l in boneLines do l.Visible = false end
            box.Visible = false
            return
        end

        local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
        local visible = false

        local glow = 0.5 + 0.5 * math.sin(tick() * 3)
        local animatedColor = Color3.new(1 - glow * 0.5, 1, glow)

        for i, pair in ipairs(bonePairs) do
            local a, b = char:FindFirstChild(pair[1]), char:FindFirstChild(pair[2])
            local line = boneLines[i]
            if a and b then
                local sa, va = Camera:WorldToViewportPoint(a.Position)
                local sb, vb = Camera:WorldToViewportPoint(b.Position)
                if va and vb then
                    local va2, vb2 = Vector2.new(sa.X, sa.Y), Vector2.new(sb.X, sb.Y)
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
            nameTag.Visible, distanceTag.Visible, weaponTag.Visible = false, false, false
            for _, l in boneLines do l.Visible = false end
            box.Visible = false
            return
        end

        local boxCenterX = (minX + maxX) / 2

        nameTag.Text = player.Name
        nameTag.Position = Vector2.new(boxCenterX, minY - 40)
        nameTag.Color = animatedColor
        nameTag.Visible = true

        distanceTag.Text = math.floor(distance) .. " meters"
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
        texts = {nameTag, distanceTag, weaponTag}
    }
end


Players.PlayerRemoving:Connect(function(p)
    local esp = espDrawings[p]
    if esp then
        esp.conn:Disconnect()
        for _, obj in pairs(esp.bones) do obj:Remove() end
        for _, t in pairs(esp.texts) do t:Remove() end
        esp.box:Remove()
        espDrawings[p] = nil
    end
end)


for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        CreateESP(p)
    end
end


Players.PlayerAdded:Connect(function(p)
    if p ~= LocalPlayer then
        p.CharacterAdded:Connect(function()
            wait(1)
            CreateESP(p)
        end)
    end
end)

-- Toggle ESP on/off
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == toggleKey then
        espEnabled = not espEnabled
    end
end)

-- Function to run ESP after key is validated
local function runESP()
    ScreenGui:Destroy()

end


Button.MouseButton1Click:Connect(function()
    if TextBox.Text == validKeyBase64 then
        runESP()
    else
        TextLabel.Text = "Invalid Key! Try Again."
        TextLabel.TextColor3 = Color3.new(1, 0, 0)
    end
end)
