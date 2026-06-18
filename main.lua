-- ==========================================================
-- 1. KEY SYSTEM FETCH
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
-- 2. AUTO-REDIRECT TO DISCORD
-- ==========================================================
-- This automatically opens your Discord link in the user's browser
local requestFunc = syn and syn.request or request or http_request
if requestFunc then
    requestFunc({
        Url = "https://discord.gg/YugE36557n",
        Method = "GET"
    })
end

-- ==========================================================
-- 3. CORE SCRIPT (Auto Wheelie + Discord Webhook Only)
-- ==========================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Config = {Enabled = false, Webhook = "YOUR_WEBHOOK_URL_HERE", HoldDuration = 0.06, IntervalDuration = 0.05}
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Window
local Window = Rayfield:CreateWindow({
   Name = "Street Volt Miami 2 | Auto-Wheelie",
   KeySystem = true, 
   KeySettings = {
      Key = validKeys,
      SaveKey = true,
      FileName = "SVM2KeyCache"
   }
})

-- Wheelie Logic
task.spawn(function()
    local wasEnabled = false
    while true do
        if Config.Enabled then
            if not wasEnabled then VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game); task.wait(0.1); VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game); task.wait(0.1); wasEnabled = true end
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, game); task.wait(Config.HoldDuration); VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, game); task.wait(Config.IntervalDuration)
        else
            if wasEnabled then VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game); task.wait(0.1); VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game); wasEnabled = false end
            task.wait(0.1)
        end
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
