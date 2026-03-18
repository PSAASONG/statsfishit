-- Configuration (UBAH INI!)
local WEBHOOK_URL = "https://discord.com/api/webhooks/1483891339564155023/c3C0hi14rCYegmtgjhn4Y34NoWEcJleKjL3bhwzI90BILuAfJPICWO-gKaqjNEMyD7Pa"
local THUMBNAIL_URL = "https://files.catbox.moe/g447uo.jpg"

-- Services
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FishTrackerUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = CoreGui

-- Frame utama
local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 260, 0, 70)
frame.Position = UDim2.new(1, 10, 1, -80)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.ClipsDescendants = true

-- Rounded corners
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

-- Stroke (border glow)
local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(0, 255, 100)
stroke.Transparency = 0.3
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.Parent = frame

-- Icon
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

-- Text utama
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

-- Status text
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

-- Fungsi format angka
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

-- Fungsi get player stats
local function getPlayerStats(player)
    local rarestFish = "0"
    local caught = 0
    
    pcall(function()
        local leaderstats = player:FindFirstChild("leaderstats")
        if leaderstats then
            local rarest = leaderstats:FindFirstChild("Rarest Fish")
            if rarest and rarest.Value then
                rarestFish = formatNumber(rarest.Value)
            end
            
            local caughtStat = leaderstats:FindFirstChild("Caught")
            if caughtStat and caughtStat.Value then
                caught = caughtStat.Value
            end
        end
    end)
    
    return rarestFish, caught
end

-- Fungsi build player list string
local function buildPlayerList()
    local players = Players:GetPlayers()
    local list = {}
    
    for _, player in ipairs(players) do
        local rarest, caught = getPlayerStats(player)
        table.insert(list, string.format("🔹 %s\n└ 🔝 %s | 🐟 %d", player.Name, rarest, caught))
    end
    
    if #list == 0 then
        return "No players online"
    end
    
    return table.concat(list, "\n")
end

-- Fungsi kirim ke Discord
local function sendToDiscord()
    print("[FishTracker] Mencoba kirim ke Discord...")
    
    local players = Players:GetPlayers()
    local playerList = buildPlayerList()
    
    -- Batasi panjang field Discord (max 1024 characters)
    if #playerList > 1000 then
        playerList = string.sub(playerList, 1, 1000) .. "..."
    end
    
    local embed = {
        title = "🎣 Fish Tracker Status",
        description = "🟢 TRACKER ACTIVE",
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
                name = "🌐 Player List",
                value = playerList,
                inline = false
            }
        },
        timestamp = DateTime.now():ToIsoDate()
    }
    
    local data = {
        embeds = {embed},
        content = "@everyone Fish Tracker Update" -- Optional ping
    }
    
    local jsonData = HttpService:JSONEncode(data)
    
    -- Pake pcall untuk handle error
    local success, result = pcall(function()
        return HttpService:PostAsync(WEBHOOK_URL, jsonData, Enum.HttpContentType.ApplicationJson, false) -- false = no compress
    end)
    
    if success then
        print("[FishTracker] ✅ Berhasil kirim ke Discord! Player: " .. #players)
        print("[FishTracker] Response: " .. tostring(result))
    else
        warn("[FishTracker] ❌ Gagal kirim ke Discord: " .. tostring(result))
    end
end

-- Kirim saat pertama kali dengan delay lebih panjang
task.spawn(function()
    print("[FishTracker] Delay 5 detik sebelum kirim pertama...")
    task.wait(5) -- Delay lebih lama biar game fully loaded
    
    print("[FishTracker] Mengirim data pertama...")
    sendToDiscord()
end)

-- Update status text setiap detik
task.spawn(function()
    while task.wait(1) do
        if frame and frame.Parent then
            statusText.Text = "Monitoring " .. #Players:GetPlayers() .. " players"
        end
    end
end)

-- Kirim ke Discord setiap 15 menit
task.spawn(function()
    while true do
        task.wait(900) -- 15 menit = 900 detik
        print("[FishTracker] Interval 15 menit, mengirim ulang...")
        sendToDiscord()
    end
end)

-- Handle player added/removed
local function onPlayerAdded(player)
    if frame and frame.Parent then
        statusText.Text = "Monitoring " .. #Players:GetPlayers() .. " players"
    end
    print("[FishTracker] Player added: " .. player.Name)
end

local function onPlayerRemoving(player)
    if frame and frame.Parent then
        statusText.Text = "Monitoring " .. #Players:GetPlayers() .. " players"
    end
    print("[FishTracker] Player removed: " .. player.Name)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

print("🚀 Fish Tracker Active - Running on Delta Executor")
print("🌐 Webhook: " .. WEBHOOK_URL)
print("⏱️ Interval: 15 menit")
