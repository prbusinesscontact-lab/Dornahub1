-- ==========================================================
-- 1. DYNAMIC KEY SYSTEM FETCHER
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
-- 2. ORIGINAL BIG SCRIPT
-- ==========================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

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

local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local localPlayer = Players.LocalPlayer
local lastMoneyValue = 0

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
    local data = {["embeds"] = {{["title"] = "🚴 Auto-Wheelie Earnings Update", ["description"] = string.format("**Player:** %s\n**Made Per Wheelie:** $%s\n**Total Current Cash:** $%s", localPlayer.Name, tostring(amountMade), tostring(getMoneyBalance())), ["color"] = 5763719, ["footer"] = {["text"] = "Street Volt Miami 2 Automation"}, ["timestamp"] = DateTime.now():ToIsoDate()}}}
    local finalJson = HttpService:JSONEncode(data)
    local requestFunc = syn and syn.request or request or http_request
    if requestFunc then task.spawn(function() requestFunc({Url = Config.Webhook, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = finalJson}) end) end
end

local Window = Rayfield:CreateWindow({
   Name = "Street Volt Miami 2 | Suite",
   LoadingTitle = "Initializing Multi-Tab Engine...",
   LoadingSubtitle = "by xyaz",
   ConfigurationSaving = {Enabled = true, FolderName = "StreetVoltMiami", FileName = "SuiteConfig"},
   KeySystem = true, 
   KeySettings = {
      Title = "SVM2 Secure Key Authentication",
      Subtitle = "Generate key via Discord",
      Note = "Format: SVM2-XXX-XXXXXXXXXX",
      FileName = "SVM2KeyCache",
      SaveKey = true,
      Key = validKeys -- CONNECTED TO FETCHED KEYS
   }
})

task.spawn(function()
    local wasEnabled = false
    while true do
        if Config.Enabled then
            if not wasEnabled then VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game); task.wait(0.1); VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game); task.wait(0.1); wasEnabled = true end
            lastMoneyValue = getMoneyBalance()
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, game); task.wait(Config.HoldDuration); VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, game); task.wait(Config.IntervalDuration)
            local currentMoney = getMoneyBalance()
            if currentMoney > lastMoneyValue then sendDiscordNotification(currentMoney - lastMoneyValue) end
        else
            if wasEnabled then VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game); task.wait(0.1); VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game); wasEnabled = false end
            task.wait(0.1)
        end
    end
end)

local Highlights = {}
local function applyESP(player)
    if player == localPlayer or Highlights[player] then return end
    local function addHighlight(character)
        if not character then return end
        local highlight = Instance.new("Highlight")
        highlight.Adornee = character; highlight.Parent = CoreGui; Highlights[player] = highlight
    end
    if player.Character then addHighlight(player.Character) end
    player.CharacterAdded:Connect(addHighlight)
end

local function togglePlayerESP(state)
    if state then for _, p in ipairs(Players:GetPlayers()) do applyESP(p) end
    else for _, h in pairs(Highlights) do h:Destroy() end; Highlights = {} end
end

-- TABS
local AutoWheelieTab = Window:CreateTab("Auto Wheelie", nil)
local WheelieToggle = AutoWheelieTab:CreateToggle({Name = "Enable Auto Wheelie", CurrentValue = false, Callback = function(V) Config.Enabled = V end})
local DistanceSlider = AutoWheelieTab:CreateSlider({Name = "Wheelie Target Distance", Min = 10, Max = 5000, CurrentValue = 750, Increment = 10, Callback = function(V) Config.TargetDistance = V end})
local HoldSlider = AutoWheelieTab:CreateSlider({Name = "Hold Time", Min = 0.01, Max = 1.5, CurrentValue = 0.06, Increment = 0.01, Callback = function(V) Config.HoldDuration = V end})
local IntervalSlider = AutoWheelieTab:CreateSlider({Name = "Interval", Min = 0.01, Max = 1.5, CurrentValue = 0.05, Increment = 0.01, Callback = function(V) Config.IntervalDuration = V end})
AutoWheelieTab:CreateButton({Name = "Reset Defaults", Callback = function() Config.HoldDuration = 0.06; Config.IntervalDuration = 0.05; HoldSlider:Set(0.06); IntervalSlider:Set(0.05) end})

local VisualTab = Window:CreateTab("Visual", nil)
VisualTab:CreateToggle({Name = "Player ESP", CurrentValue = false, Callback = function(V) Config.ESPEnabled = V; togglePlayerESP(V) end})
local AnalyticsDisplay = VisualTab:CreateParagraph({Title = "Statistics", Content = "Tracking enabled."})

local DiscordTab = Window:CreateTab("Discord", nil)
DiscordTab:CreateInput({Name = "Discord Webhook URL", Callback = function(T) Config.Webhook = T end})
DiscordTab:CreateButton({Name = "Copy Discord Link", Callback = function() setclipboard("https://discord.gg/zrQnbxx8gg") end})
