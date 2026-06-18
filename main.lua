-- ==========================================================
-- 1. DYNAMIC KEY FETCH (Wait until ready)
-- ==========================================================
local HttpService = game:GetService("HttpService")
local keysUrl = "https://raw.githubusercontent.com/prbusinesscontact-lab/Dornahub1/refs/heads/main/keys.json"
local validKeys = {}
local fetched = false

task.spawn(function()
    local success, response = pcall(function() return game:HttpGet(keysUrl) end)
    if success and response then
        local decodeSuccess, decodedTable = pcall(function() return HttpService:JSONDecode(response) end)
        if decodeSuccess then validKeys = decodedTable; fetched = true end
    end
end)
repeat task.wait(0.5) until fetched

-- ==========================================================
-- 2. INITIALIZATION & FORCED REDIRECT
-- ==========================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Instead of risky auto-redirect, we use a clean notification to force the user to click the link
Rayfield:Notify({
    Title = "Welcome to SVM2",
    Content = "Click the Discord tab to join our community!",
    Duration = 10
})

-- ==========================================================
-- 3. CORE FEATURES
-- ==========================================================
local Config = {Enabled = false, Webhook = "", HoldDuration = 0.06, IntervalDuration = 0.05}

-- Webhook Logic
local function sendNotification(msg)
    if Config.Webhook == "" then return end
    local data = {["content"] = msg}
    local finalJson = HttpService:JSONEncode(data)
    local requestFunc = syn and syn.request or request or http_request
    if requestFunc then 
        task.spawn(function() 
            requestFunc({Url = Config.Webhook, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = finalJson}) 
        end) 
    end
end

-- Window
local Window = Rayfield:CreateWindow({
   Name = "Street Volt Miami 2 | Auto-Wheelie",
   KeySystem = true, 
   KeySettings = {Key = validKeys, SaveKey = true, FileName = "SVM2KeyCache"}
})

-- Loop
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

-- UI
local AutoWheelieTab = Window:CreateTab("Auto Wheelie", nil)
AutoWheelieTab:CreateToggle({Name = "Enable Auto Wheelie", Callback = function(V) Config.Enabled = V end})
AutoWheelieTab:CreateSlider({Name = "Hold Time", Min = 0.01, Max = 1.5, CurrentValue = 0.06, Callback = function(V) Config.HoldDuration = V end})
AutoWheelieTab:CreateSlider({Name = "Interval", Min = 0.01, Max = 1.5, CurrentValue = 0.05, Callback = function(V) Config.IntervalDuration = V end})

local DiscordTab = Window:CreateTab("Discord", nil)
DiscordTab:CreateInput({Name = "Discord Webhook URL", Callback = function(T) Config.Webhook = T end})
DiscordTab:CreateButton({Name = "JOIN DISCORD (CLICK ME)", Callback = function() 
    setclipboard("https://discord.gg/YugE36557n") 
    Rayfield:Notify({Title = "Copied!", Content = "Discord link copied to clipboard.", Duration = 5})
end})
