-- ==================== KONFIGURASI ====================
local WEBHOOK_URL = "https://discord.com/api/webhooks/1483891339564155023/c3C0hi14rCYegmtgjhn4Y34NoWEcJleKjL3bhwzI90BILuAfJPICWO-gKaqjNEMyD7Pa"
local THUMBNAIL_URL = "https://files.catbox.moe/g447uo.jpg"
local INTERVAL = 900 -- 15 menit

-- ==================== SERVICES ====================
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- ==================== CLEANUP UI ====================
pcall(function() CoreGui:FindFirstChild("FishTrackerUI"):Destroy() end)

-- ==================== UI SETUP ====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FishTrackerUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 100)
frame.Position = UDim2.new(1, 10, 1, -110)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(0, 255, 100)
stroke.Transparency = 0.3
stroke.Parent = frame

local icon = Instance.new("TextLabel")
icon.Size = UDim2.new(0, 40, 1, 0)
icon.Position = UDim2.new(0, 5, 0, 0)
icon.BackgroundTransparency = 1
icon.Text = "🎣"
icon.TextColor3 = Color3.fromRGB(255, 255, 255)
icon.TextScaled = true
icon.Font = Enum.Font.GothamBold
icon.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 0, 24)
title.Position = UDim2.new(0, 45, 0, 8)
title.BackgroundTransparency = 1
title.Text = "FISH TRACKER"
title.TextColor3 = Color3.fromRGB(0, 255, 100)
title.TextSize = 15
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local activeStatus = Instance.new("TextLabel")
activeStatus.Size = UDim2.new(1, -50, 0, 18)
activeStatus.Position = UDim2.new(0, 45, 0, 32)
activeStatus.BackgroundTransparency = 1
activeStatus.Text = "🟢 ACTIVE"
activeStatus.TextColor3 = Color3.fromRGB(0, 255, 100)
activeStatus.TextSize = 11
activeStatus.Font = Enum.Font.Gotham
activeStatus.TextXAlignment = Enum.TextXAlignment.Left
activeStatus.Parent = frame

local playerCount = Instance.new("TextLabel")
playerCount.Size = UDim2.new(1, -50, 0, 18)
playerCount.Position = UDim2.new(0, 45, 0, 50)
playerCount.BackgroundTransparency = 1
playerCount.Text = "Players: 0"
playerCount.TextColor3 = Color3.fromRGB(200, 200, 200)
playerCount.TextSize = 11
playerCount.Font = Enum.Font.Gotham
playerCount.TextXAlignment = Enum.TextXAlignment.Left
playerCount.Parent = frame

local webhookStatus = Instance.new("TextLabel")
webhookStatus.Size = UDim2.new(1, -50, 0, 18)
webhookStatus.Position = UDim2.new(0, 45, 0, 68)
webhookStatus.BackgroundTransparency = 1
webhookStatus.Text = "⏳ Ready"
webhookStatus.TextColor3 = Color3.fromRGB(255, 200, 0)
webhookStatus.TextSize = 10
webhookStatus.Font = Enum.Font.Gotham
webhookStatus.TextXAlignment = Enum.TextXAlignment.Left
webhookStatus.Parent = frame

-- Animasi
local tween = TweenService:Create(frame, TweenInfo.new(0.5), {Position = UDim2.new(1, -290, 1, -110)})
tween:Play()

-- ==================== FORMAT PLAYER (TANPA BATAS) ====================
local function formatPlayerList()
    local players = Players:GetPlayers()
    
    if #players == 0 then
        return "└ No players online"
    end
    
    local lines = {}
    for i, player in ipairs(players) do
        -- Pake panah biar nyambung
        if i == 1 then
            table.insert(lines, "┌ " .. player.Name)
        elseif i == #players then
            table.insert(lines, "└ " .. player.Name)
        else
            table.insert(lines, "├ " .. player.Name)
        end
    end
    
    return table.concat(lines, "\n")
end

-- ==================== FUNGSI KIRIM WEBHOOK ====================
local function sendToDiscord()
    webhookStatus.Text = "📤 Sending..."
    webhookStatus.TextColor3 = Color3.fromRGB(255, 200, 0)
    
    local playerCountNum = #Players:GetPlayers()
    local playerListStr = formatPlayerList()
    local fullJobId = game.JobId -- Ambil Job ID lengkap
    
    -- Kalo player list kepanjangan, kita potong tapi tetep tampil semua
    -- Discord batasi 1024 karakter per field, jadi kita hitung dulu
    if #playerListStr > 900 then
        -- Alternatif: tampilin dalem code block biasa
        playerListStr = playerListStr
    end
    
    local embedData = {
        embeds = {{
            title = "🎣 **FISH TRACKER**",
            description = string.format(" **ACTIVE**\nSERVER 2 ! \n🗨️ **Server:** `%s`\n👥 **Total Players:** `%d`", 
                fullJobId, playerCountNum),
            color = 0x00D1B2,
            thumbnail = {url = THUMBNAIL_URL},
            fields = {
                {
                    name = "🌐 **PLAYER LIST**",
                    value = "```ml\n" .. playerListStr .. "\n```",
                    inline = false
                }
            },
            footer = {
                text = "Last Update Dungeon • " .. os.date("%H:%M:%S"),
                icon_url = THUMBNAIL_URL
            },
            timestamp = DateTime.now():ToIsoDate()
        }}
    }
    
    local jsonData = HttpService:JSONEncode(embedData)
    
    -- Kirim pake method yang paling work
    local success = pcall(function()
        local requestFunc = http_request or request or syn and syn.request
        if requestFunc then
            requestFunc({
                Url = WEBHOOK_URL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = jsonData
            })
        else
            HttpService:PostAsync(WEBHOOK_URL, jsonData, Enum.HttpContentType.ApplicationJson)
        end
    end)
    
    if success then
        webhookStatus.Text = "✅ Sent at " .. os.date("%H:%M:%S")
        webhookStatus.TextColor3 = Color3.fromRGB(0, 255, 100)
        print("✅ Webhook sent! Players:", playerCountNum)
    else
        webhookStatus.Text = "❌ Failed"
        webhookStatus.TextColor3 = Color3.fromRGB(255, 0, 0)
    end
end

-- ==================== EKSEKUSI ====================
print("🚀 Fish Tracker Starting...")

-- Kirim pertama
task.spawn(function()
    task.wait(3)
    sendToDiscord()
end)

-- Loop interval
task.spawn(function()
    while true do
        task.wait(INTERVAL)
        sendToDiscord()
    end
end)

-- Update player count di UI
task.spawn(function()
    while task.wait(1) do
        playerCount.Text = "Players: " .. #Players:GetPlayers()
    end
end)

print("✅ Fish Tracker Active - Interval: " .. (INTERVAL/60) .. " menit")
