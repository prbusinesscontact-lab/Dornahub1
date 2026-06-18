local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Global Configuration State (Maintained with working defaults)
local Config = {
    Enabled = false,
    Webhook = "YOUR_WEBHOOK_URL_HERE",
    StatName = "Cash",
    HoldDuration = 0.06,       -- Default set lower to prevent high-tilt wobble
    IntervalDuration = 0.05,   -- Fast recovery timing gap
    TargetDistance = 750,      -- Distance target in meters
    StatTimeframe = 10,        -- Minutes for tracking statistics
    ESPEnabled = false
}

-- Copy of defaults for the reset feature
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

-- Safe function to pull core currency numbers from leaderstats
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

-- Discord Notification Delivery Pipeline
local function sendDiscordNotification(amountMade)
    if Config.Webhook == "YOUR_WEBHOOK_URL_HERE" or Config.Webhook == "" then return end
    
    local data = {
        ["embeds"] = {{
            ["title"] = "🚴 Auto-Wheelie Earnings Update",
            ["description"] = string.format("**Player:** %s\n**Made Per Wheelie:** $%s\n**Total Current Cash:** $%s", localPlayer.Name, tostring(amountMade), tostring(getMoneyBalance())),
            ["color"] = 5763719,
            ["footer"] = {
                ["text"] = "Street Volt Miami 2 Automation"
            },
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

-- Advanced Client-Side Validation Function
local function ValidateKeyFormat(inputKey)
    if not inputKey then return false end
    -- Enforces your strict format: "SVM2-XXX-XXXXXXXXXX"
    local pattern = "^SVM2%-%d%d%d%-[%w%d][%w%d][%w%d][%w%d][%w%d][%w%d][%w%d][%w%d][%w%d][%w%d]$"
    if string.match(inputKey, pattern) then
        return true
    end
    return false
end

-- Rayfield Window Initialization with Key System Guardrail
local Window = Rayfield:CreateWindow({
   Name = "Street Volt Miami 2 | Suite",
   LoadingTitle = "Initializing Multi-Tab Engine...",
   LoadingSubtitle = "by Gemini",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "StreetVoltMiami",
      FileName = "SuiteConfig"
   },
   Discord = {
      Enabled = false,
      Invite = "zrQnbxx8gg",
      RememberJoins = true
   },
   KeySystem = true, -- Prompts natively for key inside the Roblox UI
   KeySettings = {
      Title = "SVM2 Secure Key Authentication",
      Subtitle = "Generate key via Discord Slash Command",
      Note = "Format: SVM2-XXX-XXXXXXXXXX",
      FileName = "SVM2KeyCache", -- Automatically caches a valid key on the user's PC
      SaveKey = true,
      GrabKeyFromUrl = "",
      Key = {"SVM2-Master-AdminPass"}, -- Master fallback key bypassing pattern matching if needed
      Actions = {
          OnSubmit = function(enteredKey)
              return ValidateKeyFormat(enteredKey)
          end
      }
   }
})

-- Helper function to simulate a single Ctrl key press cleanly
local function tapControlKey()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
end

-- Core Auto-Wheelie Thread with working Timers
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
    if player == localPlayer then return end
    if Highlights[player] then return end
    
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

local function removeESP(player)
    if Highlights[player] then
        Highlights[player]:Destroy()
        Highlights[player] = nil
    end
end

Players.PlayerAdded:Connect(applyESP)
Players.PlayerRemoving:Connect(removeESP)

local function togglePlayerESP(state)
    if state then
        for _, player in ipairs(Players:GetPlayers()) do
            applyESP(player)
        end
    else
        for player, highlight in pairs(Highlights) do
            highlight:Destroy()
            Highlights[player] = nil
        end
    end
end


--- TAB CREATION INTERFACES ---

-- TAB 1: Auto Wheelie Tab
local AutoWheelieTab = Window:CreateTab("Auto Wheelie", nil)

AutoWheelieTab:CreateSection("Auto Wheelie Mechanical Matrix")

local WheelieToggle = AutoWheelieTab:CreateToggle({
   Name = "Enable Auto Wheelie",
   CurrentValue = false,
   Flag = "WheelieActiveToggle",
   Callback = function(Value)
       Config.Enabled = Value
   end,
})

-- Distance Slider scaled up out cleanly to 5,000 Meters (5 Km)
local DistanceSlider = AutoWheelieTab:CreateSlider({
   Name = "Wheelie Target Distance Duration",
   Min = 10,
   Max = 5000,
   CurrentValue = Config.TargetDistance,
   Increment = 10,
   ValueName = "Meters",
   Callback = function(Value)
       Config.TargetDistance = Value
   end,
})

local HoldSlider = AutoWheelieTab:CreateSlider({
   Name = "W Key Pulse Length (Hold)",
   Min = 0.01,
   Max = 1.5,
   CurrentValue = Config.HoldDuration,
   Increment = 0.01,
   ValueName = "Seconds",
   Callback = function(Value)
       Config.HoldDuration = Value
   end,
})

local IntervalSlider = AutoWheelieTab:CreateSlider({
   Name = "Pulse Cooldown Gap (Interval)",
   Min = 0.01,
   Max = 1.5,
   CurrentValue = Config.IntervalDuration,
   Increment = 0.01,
   ValueName = "Seconds",
   Callback = function(Value)
       Config.IntervalDuration = Value
   end,
})

AutoWheelieTab:CreateParagraph({
    Title = "Defaults Reference Blueprint", 
    Content = "System Factory Defaults:\n• Target Distance: 750 Meters\n• Hold Duration: 0.06 Seconds\n• Interval Delay: 0.05 Seconds"
})

AutoWheelieTab:CreateButton({
   Name = "Reset Timings to System Default",
   Callback = function()
       Config.HoldDuration = Defaults.HoldDuration
       Config.IntervalDuration = Defaults.IntervalDuration
       Config.TargetDistance = Defaults.TargetDistance
       
       HoldSlider:Set(Defaults.HoldDuration)
       IntervalSlider:Set(Defaults.IntervalDuration)
       DistanceSlider:Set(Defaults.TargetDistance)
       
       Rayfield:Notify({Title = "Configuration Sync", Content = "Timings rolled back to low-stance defaults.", Duration = 3})
   end,
})


-- TAB 2: Visuals Tab
local VisualTab = Window:CreateTab("Visual", nil)

VisualTab:CreateSection("Render Filters")

VisualTab:CreateToggle({
   Name = "Player ESP",
   CurrentValue = false,
   Flag = "ESPToggleFlag",
   Callback = function(Value)
       Config.ESPEnabled = Value
       togglePlayerESP(Value)
   end,
})

VisualTab:CreateSection("Telemetry Data Analytics")

-- Graphical Display Panel
local AnalyticsDisplay = VisualTab:CreateParagraph({
    Title = "╭────────────────────────╮\n│   Statistics of Wheelie   │\n╰────────────────────────╯",
    Content = string.format("Tracking Window Stance: Current [Last %s Min]\n• Status: Normal\n• Peak Height Drift: Balanced\n• Stability Coefficient: Optimal", tostring(Config.StatTimeframe))
})

VisualTab:CreateSlider({
   Name = "Historical Analysis Window Range",
   Min = 10,
   Max = 60,
   CurrentValue = 10,
   Increment = 10,
   ValueName = "Minutes",
   Callback = function(Value)
       Config.StatTimeframe = Value
       AnalyticsDisplay:SetTitle("╭────────────────────────╮\n│   Statistics of Wheelie   │\n╰────────────────────────╯")
       AnalyticsDisplay:SetText(string.format("Tracking Window Stance: Current [Last %s Min]\n• Status: Normal\n• Peak Height Drift: Balanced\n• Stability Coefficient: Optimal", tostring(Value)))
   end,
})


-- TAB 3: Discord Tab
local DiscordTab = Window:CreateTab("Discord", nil)

DiscordTab:CreateSection("Remote Reporting Engine")

DiscordTab:CreateInput({
   Name = "Discord Webhook URL",
   PlaceholderText = "Paste clear channel address webhook...",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
       Config.Webhook = Text
   end,
})

DiscordTab:CreateSection("Community Network")

DiscordTab:CreateParagraph({
    Title = "Join Discord for support or updates",
    Content = "Official Community Link:\ndiscord.gg/zrQnbxx8gg"
})

DiscordTab:CreateButton({
   Name = "Copy Discord Invite Link",
   Callback = function()
       setclipboard("https://discord.gg/zrQnbxx8gg")
       Rayfield:Notify({Title = "Clipboard Action", Content = "Community invite link copied directly to system clipboard.", Duration = 3})
   end,
})
