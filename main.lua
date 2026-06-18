local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Global Configuration State
local Config = {
    Enabled = false,
    Webhook = "YOUR_WEBHOOK_URL_HERE",
    StatName = "Cash",
    HoldDuration = 0.06,
    IntervalDuration = 0.05,
    TargetDistance = 750,
    StatTimeframe = 10,
    ESPEnabled = false
}

local Defaults = {
    HoldDuration = 0.06,
    IntervalDuration = 0.05,
    TargetDistance = 750
}

-- Services
local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local localPlayer = Players.LocalPlayer

local lastMoneyValue = 0

-- Functions
local function getMoneyBalance()
    local leaderstats = localPlayer:FindFirstChild("leaderstats")
    if leaderstats then
        local moneyObj = leaderstats:FindFirstChild(Config.StatName)
        if moneyObj and (moneyObj:IsA("ValueBase") or moneyObj:IsA("IntValue") or moneyObj:IsA("NumberValue")) then
            return moneyObj.Value
        end
    end
    return 0
end

local function sendDiscordNotification(amountMade)
    if Config.Webhook == "YOUR_WEBHOOK_URL_HERE" or Config.Webhook == "" then return end
    
    local data = {
        ["embeds"] = {{
            ["title"] = "🚴 Auto-Wheelie Earnings Update",
            ["description"] = string.format("**Player:** %s\n**Made Per Wheelie:** $%s\n**Total Current Cash:** $%s", localPlayer.Name, tostring(amountMade), tostring(getMoneyBalance())),
            ["color"] = 5763719,
            ["footer"] = {["text"] = "Street Volt Miami 2 Automation"},
            ["timestamp"] = DateTime.now():ToIsoDate()
        }}
    }
    
    local finalJson = HttpService:JSONEncode(data)
    local requestFunc = syn and syn.request or request or http_request
    
    if requestFunc then
        task.spawn(function()
            requestFunc({Url = Config.Webhook, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = finalJson})
        end)
    end
end

-- Rayfield Window Initialization (Key System Removed)
local Window = Rayfield:CreateWindow({
   Name = "Street Volt Miami 2 | Suite",
   LoadingTitle = "Initializing Multi-Tab Engine...",
   LoadingSubtitle = "by Gemini",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "StreetVoltMiami",
      FileName = "SuiteConfig"
   }
})

local function tapControlKey()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
end

-- Core Auto-Wheelie Thread
task.spawn(function()
    local wasEnabled = false
    while true do
        if Config.Enabled then
            if not wasEnabled then
                tapControlKey()
                task.wait(0.1) 
                wasEnabled = true
            end
            
            lastMoneyValue = getMoneyBalance()
            
            if not Config.Enabled then continue end
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, game)
            task.wait(Config.HoldDuration) 
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, game)
            
            task.wait(Config.IntervalDuration) 
            
            local currentMoney = getMoneyBalance()
            if currentMoney > lastMoneyValue then
                local profit = currentMoney - lastMoneyValue
                sendDiscordNotification(profit)
            end
        else
            if wasEnabled then
                tapControlKey()
                wasEnabled = false
            end
            task.wait(0.1)
        end
    end
end)

-- Highlights/ESP Management System
local Highlights = {}
local function applyESP(player)
    if player == localPlayer or Highlights[player] then return end
    local function addHighlight(character)
        if not character then return end
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESP_Highlight"
        highlight.FillColor = Color3.fromRGB(255, 0, 100)
        highlight.FillTransparency = 0.5
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineTransparency = 0.1
        highlight.Adornee = character
        highlight.Parent = CoreGui
        Highlights[player] = highlight
    end
    if player.Character then addHighlight(player.Character) end
    player.CharacterAdded:Connect(addHighlight)
end

local function togglePlayerESP(state)
    if state then
        for _, player in ipairs(Players:GetPlayers()) do applyESP(player) end
    else
        for player, highlight in pairs(Highlights) do
            highlight:Destroy()
            Highlights[player] = nil
        end
    end
end

Players.PlayerAdded:Connect(applyESP)
Players.PlayerRemoving:Connect(function(p) if Highlights[p] then Highlights[p]:Destroy(); Highlights[p] = nil end end)

-- TAB 1: Auto Wheelie
local AutoWheelieTab = Window:CreateTab("Auto Wheelie", nil)
AutoWheelieTab:CreateToggle({Name = "Enable Auto Wheelie", Callback = function(V) Config.Enabled = V end})
local DistanceSlider = AutoWheelieTab:CreateSlider({Name = "Wheelie Target Distance", Min = 10, Max = 5000, CurrentValue = Config.TargetDistance, Increment = 10, Callback = function(V) Config.TargetDistance = V end})
local HoldSlider = AutoWheelieTab:CreateSlider({Name = "Hold Time", Min = 0.01, Max = 1.5, CurrentValue = Config.HoldDuration, Increment = 0.01, Callback = function(V) Config.HoldDuration = V end})
local IntervalSlider = AutoWheelieTab:CreateSlider({Name = "Interval", Min = 0.01, Max = 1.5, CurrentValue = Config.IntervalDuration, Increment = 0.01, Callback = function(V) Config.IntervalDuration = V end})

AutoWheelieTab:CreateButton({Name = "Reset to Defaults", Callback = function()
    Config.HoldDuration = Defaults.HoldDuration
    Config.IntervalDuration = Defaults.IntervalDuration
    HoldSlider:Set(Defaults.HoldDuration)
    IntervalSlider:Set(Defaults.IntervalDuration)
end})

-- TAB 2: Visuals
local VisualTab = Window:CreateTab("Visual", nil)
VisualTab:CreateToggle({Name = "Player ESP", Callback = function(V) Config.ESPEnabled = V; togglePlayerESP(V) end})

-- TAB 3: Discord
local DiscordTab = Window:CreateTab("Discord", nil)
DiscordTab:CreateInput({Name = "Discord Webhook URL", Callback = function(T) Config.Webhook = T end})
DiscordTab:CreateButton({Name = "Copy Invite Link", Callback = function() setclipboard("https://discord.gg/zrQnbxx8gg") end})
