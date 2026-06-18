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
-- 2. FLUENT UI INITIALIZATION
-- ==========================================================
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local Window = Fluent:CreateWindow({
    Title = "SVM2 Suite | v1.0",
    SubTitle = "by xyaz",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark"
})

-- Handle Key System (Fluent handles this differently)
Window:SelectTab(1)
Fluent:Notify({Title = "SVM2", Content = "Key validated successfully.", Duration = 3})

-- ==========================================================
-- 3. TABS AND FEATURES
-- ==========================================================
local Config = {Enabled = false, Hold = 0.06, Interval = 0.05, Webhook = ""}

local MainTab = Window:AddTab({Title = "Auto Wheelie", Icon = "bike"})
MainTab:AddToggle("WheelieToggle", {Title = "Enable Auto Wheelie", Default = false, Callback = function(V) Config.Enabled = V end})
MainTab:AddSlider("HoldSlider", {Title = "Hold Time", Min = 0.01, Max = 1.5, Default = 0.06, Decimals = 2, Callback = function(V) Config.Hold = V end})
MainTab:AddSlider("IntervalSlider", {Title = "Interval", Min = 0.01, Max = 1.5, Default = 0.05, Decimals = 2, Callback = function(V) Config.Interval = V end})

local DiscordTab = Window:AddTab({Title = "Discord", Icon = "discord"})
DiscordTab:AddInput("WebhookInput", {Title = "Webhook URL", Default = "", Callback = function(T) Config.Webhook = T end})
DiscordTab:AddButton({Title = "Copy Discord Invite", Callback = function() setclipboard("https://discord.gg/YugE36557n") end})

-- ==========================================================
-- 4. BACKGROUND LOOP
-- ==========================================================
task.spawn(function()
    local VIM = game:GetService("VirtualInputManager")
    while true do
        if Config.Enabled then
            VIM:SendKeyEvent(true, Enum.KeyCode.W, false, game)
            task.wait(Config.Hold)
            VIM:SendKeyEvent(false, Enum.KeyCode.W, false, game)
            task.wait(Config.Interval)
        end
        task.wait(0.1)
    end
end)
