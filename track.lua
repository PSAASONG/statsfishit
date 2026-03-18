-- CONFIG (UBAH INI DOANG)
local WEBHOOK_URL = "https://discord.com/api/webhooks/1483891339564155023/c3C0hi14rCYegmtgjhn4Y34NoWEcJleKjL3bhwzI90BILuAfJPICWO-gKaqjNEMyD7Pa"
local THUMBNAIL_URL = "https://files.catbox.moe/g447uo.jpg"

-- Services
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- UI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FishTrackerUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = CoreGui

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 260, 0, 70)
frame.Position = UDim2.new(1, 10, 1, -80)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.ClipsDescendants = true

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(0, 255, 100)
stroke.Transparency = 0.3
stroke.Parent = frame

local iconLabel = Instance.new("TextLabel")
iconLabel.Name = "Icon"
iconLabel.Size = UDim2.new(0, 40, 1, 0)
iconLabel.Position = UDim2.new(0, 5, 0, 0)
iconLabel.BackgroundTransparency = 1
iconLabel.Text = "🎣"
iconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
iconLabel.TextScaled = true
iconLabel.Font = Enum.Font.GothamBold
iconLabel.Parent = frame

local mainText = Instance.new("TextLabel")
mainText.Name = "MainText"
mainText.Size = UDim2.new(1, -50, 0, 22)
mainText.Position = UDim2.new(0, 45, 0, 10)
mainText.BackgroundTransparency = 1
mainText.Text = "🟢 FISH TRACKER ACTIVE"
mainText.TextColor3 = Color3.fromRGB(0, 255, 100)
mainText.TextSize = 14
mainText.Font = Enum.Font.GothamBold
mainText.TextXAlignment = Enum.TextXAlignment.Left
mainText.Parent = frame

local statusText = Instance.new("TextLabel")
statusText.Name = "StatusText"
statusText.Size = UDim2.new(1, -50, 0, 18)
statusText.Position = UDim2.new(0, 45, 0, 35)
statusText.BackgroundTransparency = 1
statusText.Text = "Monitoring " .. #Players:GetPlayers() .. " players"
statusText.TextColor3 = Color3.fromRGB(200, 200, 200)
statusText.TextSize = 11
statusText.Font = Enum.Font.Gotham
statusText.TextXAlignment = Enum.TextXAlignment.Left
statusText.Parent = frame

frame.Parent = screenGui

-- Animasi masuk
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local goal = {Position = UDim2.new(1, -270, 1, -80)}
local tween = TweenService:Create(frame, tweenInfo, goal)
tween:Play()

-- ========== FUNGSI UTAMA ==========

-- Format angka (1/1M, 1/2.5M, 1/10K)
local function formatNumber(num)
    if type(num) ~= "number" then return "0" end
    if num >= 1000000 then
        return string.format("1/%.1fM", num / 1000000)
    elseif num >= 1000 then
        return string.format("1/%.1fK", num / 1000)
    else
        return "1/" .. tostring(num)
    end
end

-- Ambil stats player dari Leaderboard
local function getPlayerStats(player)
    local rarestFish = "0"
    local caught = 0
    
    -- Cari di Leaderboard (bukan leaderstats!)
    pcall(function()
        local leaderboard = player:FindFirstChild("Leaderboard")
        if leaderboard then
            local rarest = leaderboard:FindFirstChild("Rarest Fish")
            if rarest and rarest.Value then
                rarestFish = formatNumber(rarest.Value)
            end
            
            local caughtStat = leaderboard:FindFirstChild("Caught")
            if caughtStat and caughtStat.Value then
                caught = caughtStat.Value
            end
        end
    end)
    
    return rarestFish, caught
end

-- Kirim ke Discord
local function sendToDiscord()
    print(" [Fish It Tracker] Mencoba kirim ke Discord...")
    
    local players = Players:GetPlayers()
    local playerList = {}
    
    for _, player in ipairs(players) do
        local rarest, caught = getPlayerStats(player)
        table.insert(playerList, string.format("🔹 %s\n└ 🔝 %s | 🐟 %d", player.Name, rarest, caught))
    end
    
    local playerListStr = table.concat(playerList, "\n")
    if #playerListStr == 0 then
        playerListStr = "No players online"
    end
    
    -- Batasi panjang (Discord max 1024)
    if #playerListStr > 1000 then
        playerListStr = string.sub(playerListStr, 1, 1000) .. "..."
    end
    
    local data = {
        embeds = {{
            title = "🎣 Fish Tracker Status",
            description = "🟢 **TRACKER ACTIVE**\n\nServer: `" .. game.JobId .. "`",
            color = 0x00D1B2,
            author = {
                name = "Dungeon Tracker",
                icon_url = THUMBNAIL_URL
            },
            thumbnail = {
                url = THUMBNAIL_URL
            },
            fields = {
                {
                    name = "🗨️ Server Info",
                    value = "Total Players: **" .. #players .. "**",
                    inline = false
                },
                {
                    name = "👥 Player List",
                    value = playerListStr,
                    inline = false
                }
            },
            timestamp = DateTime.now():ToIsoDate()
        }}
    }
    
    local success, err = pcall(function()
        HttpService:PostAsync(
            WEBHOOK_URL,
            HttpService:JSONEncode(data),
            Enum.HttpContentType.ApplicationJson,
            false -- no compress biar kompatibel sama Delta
        )
    end)
    
    if success then
        print("✅ [FishTracker] BERHASIL kirim! Player: " .. #players)
    else
        warn("❌ [FishTracker] GAGAL: " .. tostring(err))
    end
end

-- ========== EKSEKUSI ==========

-- Kirim pertama (delay biar game load)
task.spawn(function()
    print("🚀 Fish Tracker Active - Tunggu 5 detik...")
    task.wait(5)
    sendToDiscord()
end)

-- Update status UI tiap detik
task.spawn(function()
    while task.wait(1) do
        if frame and frame.Parent then
            statusText.Text = "Monitoring " .. #Players:GetPlayers() .. " players"
        end
    end
end)

-- Loop kirim setiap 15 menit
task.spawn(function()
    while true do
        task.wait(900) -- 15 menit
        print("⏰ [FishTracker] Interval 15 menit, ngirim ulang...")
        sendToDiscord()
    end
end)

-- Event handler
Players.PlayerAdded:Connect(function()
    statusText.Text = "Monitoring " .. #Players:GetPlayers() .. " players"
end)

Players.PlayerRemoving:Connect(function()
    statusText.Text = "Monitoring " .. #Players:GetPlayers() .. " players"
end)

print("✅ Fish Tracker Siap - Cek console buat log")
