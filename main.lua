local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Dorna SVM2",
   LoadingTitle = "discord.gg/YugE36557n",
   LoadingSubtitle = "By DornaHub",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "StreetVoltMiami",
      FileName = "WheelieConfig"
   },
   Discord = {
      Enabled = false,
      Invite = "",
      RememberJoins = true
   },
   KeySystem = false
})

-- Services
local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local localPlayer = Players.LocalPlayer

-- Global Configuration (Lowered hold duration to drop the scooter's angle)
local Config = {
    Enabled = false,
    Webhook = "Discord-Webhook-Here",
    StatName = "Cash",
    HoldDuration = 0.06,       -- Decreased to 0.06s to keep the front end lower
    IntervalDuration = 0.05    -- Maintained fast recovery rate
}

local lastMoneyValue = 0

-- Safe function to pull core currency numbers
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

-- Helper function to simulate a single Ctrl key press cleanly
local function tapControlKey()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
end

-- Dedicated Low-Stance Macro Thread
task.spawn(function()
    local wasEnabled = false
    
    while true do
        if Config.Enabled then
            -- Lift front wheel on initialization
            if not wasEnabled then
                tapControlKey()
                task.wait(0.1) 
                wasEnabled = true
            end
            
            lastMoneyValue = getMoneyBalance()
            
            -- Lower power input loop to hold a lower angle
            if not Config.Enabled then continue end
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, game)
            task.wait(Config.HoldDuration) 
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, game)
            
            task.wait(Config.IntervalDuration) 
            
            -- Evaluate loop cycle generation profits
            local currentMoney = getMoneyBalance()
            if currentMoney > lastMoneyValue then
                local profit = currentMoney - lastMoneyValue
                sendDiscordNotification(profit)
            end
        else
            -- Clean drop down when disabled
            if wasEnabled then
                tapControlKey()
                wasEnabled = false
            end
            task.wait(0.1)
        end
    end
end)

--- UI Tab Setup ---
local MainTab = Window:CreateTab("Main Framework", nil)

MainTab:CreateSection("Low-Angle Automation Matrix")

MainTab:CreateToggle({
   Name = "Auto-Wheelie",
   CurrentValue = false,
   Flag = "WheelieToggle",
   Callback = function(Value)
       Config.Enabled = Value
   end,
})

MainTab:CreateSection("Networking & Webhooks")

MainTab:CreateInput({
   Name = "Discord Webhook URL",
   PlaceholderText = "Paste webhook here...",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
       Config.Webhook = Text
   end,
})

MainTab:CreateInput({
   Name = "Leaderstat Money Variable",
   CurrentValue = "Cash",
   PlaceholderText = "e.g., Cash, Money",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
       Config.StatName = Text
   end,
})

MainTab:CreateSection("Precision Physics Tuning")

MainTab:CreateSlider({
   Name = "W Key Pulse Length (Sec)",
   Min = 0.01,
   Max = 1.0,
   CurrentValue = 0.06, -- Default set lower to 0.06
   Increment = 0.01,
   ValueName = "Seconds",
   Callback = function(Value)
       Config.HoldDuration = Value
   end,
})

MainTab:CreateSlider({
   Name = "Pulse Cooldown Gap (Sec)",
   Min = 0.01, 
   Max = 1.0,
   CurrentValue = 0.05, 
   Increment = 0.01,
   ValueName = "Seconds",
   Callback = function(Value)
       Config.IntervalDuration = Value
   end,
})
