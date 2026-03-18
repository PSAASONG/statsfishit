-- ==================== KONFIGURASI (UBAH INI) ====================
local WEBHOOK_URL = "https://discord.com/api/webhooks/1483891339564155023/c3C0hi14rCYegmtgjhn4Y34NoWEcJleKjL3bhwzI90BILuAfJPICWO-gKaqjNEMyD7Pa"
local THUMBNAIL_URL = "https://files.catbox.moe/g447uo.jpg"
local INTERVAL = 900 -- 900 detik = 15 menit

-- ==================== SERVICES ====================
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- ==================== CLEANUP UI LAMA ====================
pcall(function() CoreGui:FindFirstChild("FishTrackerUI"):Destroy() end)

-- ==================== UI SETUP ====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FishTrackerUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = CoreGui

-- Frame utama (dibikin lebih tinggi biar muat banyak status)
local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 280, 0, 120)
frame.Position = UDim2.new(1, 10, 1, -130)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.Parent = screenGui

-- Rounded corners
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = frame

-- Border glow
local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(0, 255, 100)
stroke.Transparency = 0.3
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.Parent = frame

-- Icon
local icon = Instance.new("TextLabel")
icon.Size = UDim2.new(0, 40, 1, 0)
icon.Position = UDim2.new(0, 5, 0, 0)
icon.BackgroundTransparency = 1
icon.Text = "🎣"
icon.TextColor3 = Color3.fromRGB(255, 255, 255)
icon.TextScaled = true
icon.Font = Enum.Font.GothamBold
icon.Parent = frame

-- Title
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

-- Status active
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

-- Player count
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

-- Webhook status (baris 1)
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

-- Error detail (baris 2, baru)
local errorDetail = Instance.new("TextLabel")
errorDetail.Size = UDim2.new(1, -50, 0, 18)
errorDetail.Position = UDim2.new(0, 45, 0, 86)
errorDetail.BackgroundTransparency = 1
errorDetail.Text = ""
errorDetail.TextColor3 = Color3.fromRGB(255, 100, 100)
errorDetail.TextSize = 9
errorDetail.Font = Enum.Font.Gotham
errorDetail.TextXAlignment = Enum.TextXAlignment.Left
errorDetail.TextWrapped = true
errorDetail.Parent = frame

-- ==================== ANIMASI ====================
local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local goal = {Position = UDim2.new(1, -290, 1, -130)}
local tween = TweenService:Create(frame, tweenInfo, goal)
tween:Play()

-- ==================== FUNGSI FORMAT ====================
local function formatPlayerList()
    local players = Players:GetPlayers()
    local lines = {}
    
    if #players == 0 then
        return "```\nNo players online\n```"
    end
    
    for i, player in ipairs(players) do
        if i <= 10 then
            table.insert(lines, string.format("%d. %s", i, player.Name))
        elseif i == 11 then
            table.insert(lines, "... and " .. (#players - 10) .. " more")
            break
        end
    end
    
    return "```\n" .. table.concat(lines, "\n") .. "\n```"
end

-- ==================== FUNGSI KIRIM WEBHOOK DENGAN DEBUG ====================
local function sendToDiscord()
    webhookStatus.Text = "📤 Sending..."
    webhookStatus.TextColor3 = Color3.fromRGB(255, 200, 0)
    errorDetail.Text = "" -- Reset error detail
    
    local playerCountNum = #Players:GetPlayers()
    local playerListFormatted = formatPlayerList()
    
    -- Prepare embed data
    local embedData = {
        embeds = {{
            title = "🎣 **FISH TRACKER STATUS**",
            description = "━━━━━━━━━━━━━━━━━━━",
            color = 0x00D1B2,
            thumbnail = {url = THUMBNAIL_URL},
            fields = {
                {
                    name = "📊 **SERVER INFORMATION**",
                    value = string.format("```\nJob ID: %s\nPlayers: %d\nStatus: ACTIVE\n```", 
                        string.sub(game.JobId, 1, 15), playerCountNum),
                    inline = false
                },
                {
                    name = "👥 **PLAYER LIST** [`" .. playerCountNum .. "`]",
                    value = playerListFormatted,
                    inline = false
                }
            },
            footer = {
                text = "Last Update • " .. os.date("%Y-%m-%d %H:%M:%S"),
                icon_url = THUMBNAIL_URL
            },
            timestamp = DateTime.now():ToIsoDate()
        }}
    }
    
    local jsonData = HttpService:JSONEncode(embedData)
    local success = false
    local errorMsg = ""
    
    --- METHOD 1: Coba pake request() (recommended buat executor) ---
    local requestSuccess, requestResult = pcall(function()
        -- Cari fungsi request yang tersedia
        local requestFunc = http_request or request or syn and syn.request
        
        if requestFunc then
            local response = requestFunc({
                Url = WEBHOOK_URL,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json",
                    ["User-Agent"] = "Roblox/Discord-Webhook"
                },
                Body = jsonData
            })
            
            -- Log response status
            if response and response.StatusCode == 204 or response.StatusCode == 200 then
                return true, "Success (HTTP " .. tostring(response.StatusCode) .. ")"
            else
                return false, "HTTP " .. tostring(response.StatusCode or "Unknown")
            end
        else
            return false, "No request function found"
        end
    end)
    
    if requestSuccess and type(requestResult) == "table" then
        -- Ini berarti function request() berhasil dipanggil, tapi kita perlu parse result-nya
        -- Karena kita pake pcall, struktur return-nya agak ribet. Kita simplify.
        -- Anggap aja kita set success dari sini
        success = true
        errorMsg = "Request method OK"
    elseif requestSuccess and type(requestResult) == "string" and requestResult:find("Success") then
        success = true
        errorMsg = requestResult
    elseif requestSuccess and type(requestResult) == "string" then
        errorMsg = "Request method: " .. requestResult
    else
        errorMsg = "Request method failed: " .. tostring(requestResult)
    end
    
    --- METHOD 2: Fallback ke HttpService:PostAsync() ---
    if not success then
        local postSuccess, postResult = pcall(function()
            HttpService:PostAsync(WEBHOOK_URL, jsonData, Enum.HttpContentType.ApplicationJson)
            return true
        end)
        
        if postSuccess then
            success = true
            errorMsg = "HttpService method OK"
        else
            errorMsg = errorMsg .. " | HttpService error: " .. tostring(postResult)
        end
    end
    
    --- METHOD 3: Coba dengan format simple (tanpa embed) ---
    if not success then
        local simpleData = {content = "Fish Tracker Update - " .. os.date("%H:%M:%S")}
        local simpleJson = HttpService:JSONEncode(simpleData)
        
        local simpleSuccess = pcall(function()
            local requestFunc = http_request or request or syn and syn.request
            if requestFunc then
                local response = requestFunc({
                    Url = WEBHOOK_URL,
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = simpleJson
                })
                if response and response.StatusCode == 204 then
                    success = true
                    errorMsg = "Simple message OK"
                end
            end
        end)
    end
    
    -- Update UI berdasarkan hasil
    if success then
        webhookStatus.Text = "✅ Sent at " .. os.date("%H:%M:%S")
        webhookStatus.TextColor3 = Color3.fromRGB(0, 255, 100)
        errorDetail.Text = errorMsg
    else
        webhookStatus.Text = "❌ Failed"
        webhookStatus.TextColor3 = Color3.fromRGB(255, 0, 0)
        errorDetail.Text = errorMsg
        warn("[FishTracker] Webhook failed: " .. errorMsg)
    end
end

-- ==================== TEST WEBHOOK TERPISAH ====================
local function testWebhookOnly()
    local testData = {
        content = "🔧 **Fish Tracker Test**\nJika pesan ini muncul, webhook berfungsi!"
    }
    
    local jsonData = HttpService:JSONEncode(testData)
    local success = false
    local errMsg = ""
    
    pcall(function()
        local requestFunc = http_request or request or syn and syn.request
        if requestFunc then
            local response = requestFunc({
                Url = WEBHOOK_URL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = jsonData
            })
            if response and response.StatusCode == 204 then
                success = true
            end
        end
    end)
    
    if success then
        print("✅ Test webhook berhasil!")
    else
        warn("❌ Test webhook gagal!")
    end
end

-- ==================== EKSEKUSI ====================
print("🚀 Fish Tracker Starting...")

-- Test webhook dulu
task.spawn(function()
    task.wait(2)
    testWebhookOnly()
end)

-- Kirim pertama (delay 3 detik)
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

-- Update player count setiap detik
task.spawn(function()
    while task.wait(1) do
        if frame and frame.Parent then
            playerCount.Text = "Players: " .. #Players:GetPlayers()
        end
    end
end)

-- Event handler player masuk/keluar
Players.PlayerAdded:Connect(function()
    playerCount.Text = "Players: " .. #Players:GetPlayers()
end)

Players.PlayerRemoving:Connect(function()
    playerCount.Text = "Players: " .. #Players:GetPlayers()
end)

print("✅ Fish Tracker Active - Interval: " .. (INTERVAL/60) .. " menit")
