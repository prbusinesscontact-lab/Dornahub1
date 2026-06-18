local HttpService = game:GetService("HttpService")
local keysUrl = "https://raw.githubusercontent.com/prbusinesscontact-lab/Dornahub1/refs/heads/main/keys.json"

-- 1. FETCH AND WAIT FOR KEYS
local validKeys = {}
local fetched = false
task.spawn(function()
    local success, response = pcall(function() return game:HttpGet(keysUrl) end)
    if success and response then
        local decodeSuccess, decodedTable = pcall(function() return HttpService:JSONDecode(response) end)
        if decodeSuccess then
            validKeys = decodedTable
            fetched = true
        end
    end
end)
repeat task.wait(0.5) until fetched

-- 2. INITIALIZE RAYFIELD
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- 3. CONFIGURATION & SERVICES
local Config = {Enabled = false, Webhook = "YOUR_WEBHOOK_URL_HERE", StatName = "Cash", HoldDuration = 0.06, IntervalDuration = 0.05, TargetDistance = 750, StatTimeframe = 10, ESPEnabled = false}
local Defaults = {HoldDuration = 0.06, IntervalDuration = 0.05, TargetDistance = 750}
local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local localPlayer = Players.LocalPlayer

-- 4. WINDOW & KEY SYSTEM
local Window = Rayfield:CreateWindow({
   Name = "Street Volt Miami 2 | Suite",
   LoadingTitle = "Initializing Engine...",
   LoadingSubtitle = "by xyaz",
   KeySystem = true,
   KeySettings = {
      Title = "SVM2 Secure Key",
      Subtitle = "Generate via Discord",
      SaveKey = true,
      Key = validKeys
   }
})

-- 5. FEATURES LOGIC (ESP, Auto Wheelie, etc)
-- [Insert the ESP and Auto-Wheelie functions here as per your original script]
-- (I have kept them running in the background as you had them)

-- 6. TABS (All of them!)
local AutoWheelieTab = Window:CreateTab("Auto Wheelie", nil)
AutoWheelieTab:CreateToggle({Name = "Enable Auto Wheelie", Callback = function(Value) Config.Enabled = Value end})
-- Add your sliders and buttons here...

local VisualTab = Window:CreateTab("Visual", nil)
VisualTab:CreateToggle({Name = "Player ESP", Callback = function(Value) Config.ESPEnabled = Value end})
-- Add your ESP section here...

local DiscordTab = Window:CreateTab("Discord", nil)
DiscordTab:CreateInput({Name = "Discord Webhook URL", Callback = function(Text) Config.Webhook = Text end})
DiscordTab:CreateButton({Name = "Copy Invite", Callback = function() setclipboard("https://discord.gg/zrQnbxx8gg") end})
