-- CONFIG (UBAH INI DOANG)
local WEBHOOK_URL = "https://discord.com/api/webhooks/1483891339564155023/c3C0hi14rCYegmtgjhn4Y34NoWEcJleKjL3bhwzI90BILuAfJPICWO-gKaqjNEMyD7Pa"
local THUMBNAIL_URL = "https://files.catbox.moe/g447uo.jpg"

-- Services
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- UI (minimalis)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FishTrackerUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 70)
frame.Position = UDim2.new(1, 10, 1, -80)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(0, 255, 100)
stroke.Transparency = 0.3
stroke.Parent = frame

local mainText = Instance.new("TextLabel")
mainText.Size = UDim2.new(1, -10, 0, 22)
mainText.Position = UDim2.new(0, 5, 0, 8)
mainText.BackgroundTransparency = 1
mainText.Text = "🟢 FISH TRACKER ACTIVE"
mainText.TextColor3 = Color3.fromRGB(0, 255, 100)
mainText.TextSize = 13
mainText.Font = Enum.Font.GothamBold
mainText.Parent = frame

local playerCount = Instance.new("TextLabel")
playerCount.Size = UDim2.new(1, -10, 0, 18)
playerCount.Position = UDim2.new(0, 5, 0, 32)
playerCount.BackgroundTransparency = 1
playerCount.Text = "Players: " .. #Players:GetPlayers()
playerCount.TextColor3 = Color3.fromRGB(200, 200, 200)
playerCount.TextSize = 11
playerCount.Font = Enum.Font.Gotham
playerCount.TextXAlignment = Enum.TextXAlignment.Left
playerCount.Parent = frame

local webhookStatus = Instance.new("TextLabel")
webhookStatus.Size = UDim2.new(1, -10, 0, 18)
webhookStatus.Position = UDim2.new(0, 5, 0, 50)
webhookStatus.BackgroundTransparency = 1
webhookStatus.Text = "⏳ Ready"
webhookStatus.TextColor3 = Color3.fromRGB(255, 200, 0)
webhookStatus.TextSize = 10
webhookStatus.Font = Enum.Font.Gotham
webhookStatus.TextXAlignment = Enum.TextXAlignment.Left
webhookStatus.Parent = frame

-- Animasi masuk
local tween = TweenService:Create(frame, TweenInfo.new(0.5), {Position = UDim2.new(1, -230, 1, -80)})
tween:Play()

-- FUNGSI KIRIM WEBHOOK (EMBED KEREN)
local function sendToDiscord()
    webhookStatus.Text = "📤 Sending..."
    webhookStatus.TextColor3 = Color3.fromRGB(255, 200, 0)
    
    -- Kumpulin nama player
    local playerNames = {}
    for _, player in ipairs(Players:GetPlayers()) do
        table.insert(playerNames, "`" .. player.Name .. "`")
    end
    
    local playerList = table.concat(playerNames, "\n")
    if #playerNames == 0 then
        playerList = "└ **No players online**"
    elseif #playerList > 900 then
        playerList = string.sub(playerList, 1, 900) .. "..."
    else
        playerList = "└ " .. playerList
    end
    
    -- Embed keren
    local data = {
        embeds = {{
            title = "🎣 **FISH TRACKER**",
            description = "🟢 **ACTIVE**\n━━━━━━━━━━━━━━━━━━━",
            color = 0x00D1B2, -- Hijau tosca
            thumbnail = {url = THUMBNAIL_URL},
            fields = {
                {
                    name = "🗨️ **Server Info**",
                    value = "```\nJob ID: " .. string.sub(game.JobId, 1, 15) .. "...\n```",
                    inline = false
                },
                {
                    name = "👥 **Players Online** [`" .. #Players:GetPlayers() .. "`]",
                    value = playerList,
                    inline = false
                }
            },
            footer = {text = "Last Update • " .. os.date("%H:%M:%S")},
            timestamp = DateTime.now():ToIsoDate()
        }}
    }
    
    -- Kirim
    local success = pcall(function()
        HttpService:PostAsync(WEBHOOK_URL, HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson)
    end)
    
    if success then
        webhookStatus.Text = "✅ Sent at " .. os.date("%H:%M")
        webhookStatus.TextColor3 = Color3.fromRGB(0, 255, 100)
    else
        webhookStatus.Text = "❌ Failed"
        webhookStatus.TextColor3 = Color3.fromRGB(255, 0, 0)
    end
end

-- JALANKAN
task.spawn(function()
    task.wait(3)
    sendToDiscord()
end)

task.spawn(function()
    while true do
        task.wait(900) -- 15 menit
        sendToDiscord()
    end
end)

task.spawn(function()
    while task.wait(1) do
        playerCount.Text = "Players: " .. #Players:GetPlayers()
    end
end)

print("✅ Fish Tracker Running - Player list only")
