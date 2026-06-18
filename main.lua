-- ==========================================================
-- 1. DYNAMIC KEY SYSTEM FETCH
-- ==========================================================
local HttpService = game:GetService("HttpService")
local keysUrl = "https://raw.githubusercontent.com/prbusinesscontact-lab/Dornahub1/refs/heads/main/keys.json"
local validKeys = {}

local success, response = pcall(function() return game:HttpGet(keysUrl) end)
if success then
    local decodeSuccess, decodedTable = pcall(function() return HttpService:JSONDecode(response) end)
    if decodeSuccess then validKeys = decodedTable end
end

-- ==========================================================
-- 2. AUTO-REDIRECT TO DISCORD
-- ==========================================================
local requestFunc = syn and syn.request or request or http_request
if requestFunc then
    requestFunc({Url = "https://discord.gg/YugE36557n", Method = "GET"})
end

-- ==========================================================
-- 3. CORE SCRIPT
-- ==========================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local localPlayer = Players.LocalPlayer

local Config = {Enabled = false, Webhook = "", HoldDuration = 0.06, IntervalDuration = 0.05}

-- Notification Helper
local function sendDiscordNotification(amount)
    if Config.Webhook == "" then return end
    local data = {["embeds"] = {{["title"] = "🚴 Earnings Update", ["description"] = "Made: $"..tostring(amount), ["color"] = 5763719}}}
    local finalJson = HttpService:JSONEncode(data)
    local requestFunc = syn and syn.request or request or http_request
    if requestFunc then task.spawn(function() requestFunc({Url = Config.Webhook, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = finalJson}) end) end
end

local Window = Rayfield:CreateWindow({
   Name = "Street Volt Miami 2 | Auto-Wheelie",
   KeySystem = true, 
   KeySettings = {Key = validKeys, SaveKey = true, FileName = "SVM2KeyCache"}
})

-- Wheelie Loop
task.spawn(function()
    while true do
        if Config.Enabled then
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, game)
            task.wait(Config.HoldDuration)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, game)
            task.wait(Config.IntervalDuration)
        end
        task.wait(0.1)
    end
end)

-- TABS
local AutoWheelieTab = Window:CreateTab("Auto Wheelie", nil)
AutoWheelieTab:CreateToggle({Name = "Enable Auto Wheelie", Callback = function(V) Config.Enabled = V end})
AutoWheelieTab:CreateSlider({Name = "Hold Time", Min = 0.01, Max = 1.5, CurrentValue = 0.06, Callback = function(V) Config.HoldDuration = V end})
AutoWheelieTab:CreateSlider({Name = "Interval", Min = 0.01, Max = 1.5, CurrentValue = 0.05, Callback = function(V) Config.IntervalDuration = V end})

local DiscordTab = Window:CreateTab("Discord", nil)
DiscordTab:CreateInput({Name = "Discord Webhook URL", Callback = function(T) Config.Webhook = T end})
DiscordTab:CreateButton({Name = "Join Official Discord", Callback = function() setclipboard("https://discord.gg/YugE36557n") end})
