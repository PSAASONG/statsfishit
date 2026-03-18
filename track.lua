local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local WEBHOOK_URL = "https://discord.com/api/webhooks/1483891339564155023/c3C0hi14rCYegmtgjhn4Y34NoWEcJleKjL3bhwzI90BILuAfJPICWO-gKaqjNEMyD7Pa"
local THUMBNAIL_URL = "https://files.catbox.moe/g447uo.jpg"

-- ================= UI =================
local gui = Instance.new("ScreenGui")
gui.Name = "TrackerUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 260, 0, 60)
frame.Position = UDim2.new(1, 300, 1, -80)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.BorderSizePixel = 0

Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(0,255,120)
stroke.Thickness = 2
stroke.Transparency = 0.3

local text = Instance.new("TextLabel", frame)
text.Size = UDim2.new(1,0,1,0)
text.BackgroundTransparency = 1
text.Text = "🟢 TRACKER ACTIVE"
text.TextColor3 = Color3.new(1,1,1)
text.TextScaled = true
text.Font = Enum.Font.GothamBold

-- animasi masuk
frame:TweenPosition(UDim2.new(1, -270, 1, -80), "Out", "Quad", 0.6, true)

-- ================= FORMAT =================
local function formatRareFish(value)
    if typeof(value) ~= "number" or value <= 0 then return "N/A" end
    if value >= 1e6 then
        return "1/"..string.format("%.1f",value/1e6):gsub("%.0","").."M"
    elseif value >= 1e3 then
        return "1/"..string.format("%.1f",value/1e3):gsub("%.0","").."K"
    else
        return "1/"..value
    end
end

-- ================= WEBHOOK =================
local function sendWebhook()
    local list = {}

    for i,p in ipairs(Players:GetPlayers()) do
        local rareFish, caught = "N/A","N/A"
        local ls = p:FindFirstChild("leaderstats")

        if ls then
            local rf = ls:FindFirstChild("Rarest Fish")
            if rf then
                rareFish = typeof(rf.Value)=="number" and formatRareFish(rf.Value) or tostring(rf.Value)
            end

            local ct = ls:FindFirstChild("Caught")
            if ct then
                caught = tostring(ct.Value)
            end
        end

        table.insert(list,
            "🔹 **"..p.Name.."**\n└  "..rareFish.." |  "..caught
        )
    end

    local data = {
        embeds = {{
            author = {
                name = "Dungeon Tracker",
                icon_url = THUMBNAIL_URL
            },

            title = "🎣 Fish Tracker Status",

            description = "```ansi\n\u001b[32m TRACKER ACTIVE\u001b[0m\n```",

            color = 16753920,
            thumbnail = {url = THUMBNAIL_URL},

            fields = {
                {
                    name = "🗨️ Server Info",
                    value = "Players: **"..#Players:GetPlayers().."**",
                    inline = false
                },
                {
                    name = "👥 Player List",
                    value = (#list>0 and table.concat(list,"\n\n") or "No players"),
                    inline = false
                }
            },

            footer = {
                text = "Trackers by Dungeon • 15 min"
            },

            timestamp = DateTime.now():ToIsoDate()
        }}
    }

    pcall(function()
        HttpService:PostAsync(WEBHOOK_URL, HttpService:JSONEncode(data))
    end)
end

-- ================= START =================
task.wait(5)
sendWebhook()

while true do
    task.wait(900)
    sendWebhook()
end
