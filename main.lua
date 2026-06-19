local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local AcceptedKeys = {"BHoipaf091niugDUY3","Xk92LzPq71mNvbWq4K","JpR5tW8mQ0vB1zXy9L","M7zPq91kLwbN2xTuV5","KjH8gF3dS2aQ1wErTy","ZxCvB65nM43lLkJiHg","LIFETIME_aN89uIop12mKxB","LIFETIME_qWerty7890uiOp","LIFETIME_zXyWvUtSrQpOnM"}

local Window = Rayfield:CreateWindow({
    Name = "Dorna SVM2", 
    LoadingTitle = "Dorna Hub", 
    LoadingSubtitle = "By xyaz & AI", 
    ConfigurationSaving = {
        Enabled = true, 
        FolderName = "StreetVoltMiami", 
        FileName = "WheelieConfig"
    }, 
    KeySystem = true, 
    KeySettings = {
        Title = "Dorna Hub | Verification", 
        Subtitle = "Key System", 
        Note = "Enter your authorization key.", 
        FileName = "DornaHubKeyConfig", 
        SaveKey = true, 
        GrabKeyFromUrl = false, 
        Key = AcceptedKeys
    }
})

local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

local Config = {
    Enabled = false, 
    AFKRouteEnabled = false, 
    Webhook = "", 
    StatName = "Cash", 
    CurrentWaypointIndex = 1, 
    TargetTime = nil
}

local StraightawayWaypoints = {}
local lastMoneyValue = 0
local activeVisualLines = {}

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
    if not Config.Webhook or Config.Webhook == "" or Config.Webhook == "YOUR_WEBHOOK_URL_HERE" then return end
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

local function keyPress(keyCode)
    VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
end

local function keyRelease(keyCode)
    VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
end

RunService.RenderStepped:Connect(function()
    if Config.TargetTime then
        Lighting.ClockTime = Config.TargetTime
    end
end)

local function clearVisualLines()
    for _, line in ipairs(activeVisualLines) do
        if line then pcall(function() line:Destroy() end) end
    end
    table.clear(activeVisualLines)
end

local function drawPathLines()
    clearVisualLines()
    if not Config.AFKRouteEnabled or #StraightawayWaypoints < 2 then return end
    for i = 1, #StraightawayWaypoints - 1 do
        local pA = StraightawayWaypoints[i]
        local pB = StraightawayWaypoints[i+1]
        local part = Instance.new("Part")
        part.Name = "RouteVisualLine"
        part.Anchored = true
        part.CanCollide = false
        part.Color = Color3.fromRGB(0, 255, 120)
        part.Material = Enum.Material.Neon
        part.Transparency = 0.4
        local dist = (pA - pB).Magnitude
        part.Size = Vector3.new(0.5, 0.5, dist)
        part.CFrame = CFrame.new(pA:Lerp(pB, 0.5), pB)
        part.Parent = workspace
        table.insert(activeVisualLines, part)
    end
end

task.spawn(function()
    local macroRunning = false
    while true do
        task.wait(0.01)
        if Config.Enabled or Config.AFKRouteEnabled then
            if not macroRunning then
                macroRunning = true
                keyPress(Enum.KeyCode.LeftControl)
                task.wait(0.05)
                keyRelease(Enum.KeyCode.LeftControl)
                task.wait(0.1)
                keyPress(Enum.KeyCode.W)
                task.wait(0.8)
                keyRelease(Enum.KeyCode.W)
                task.wait(0.1)
                task.spawn(function()
                    while macroRunning and (Config.Enabled or Config.AFKRouteEnabled) do
                        lastMoneyValue = getMoneyBalance()
                        keyPress(Enum.KeyCode.W)
                        task.wait(0.2)
                        keyRelease(Enum.KeyCode.W)
                        task.wait(0.2)
                        local currentMoney = getMoneyBalance()
                        if currentMoney > lastMoneyValue then
                            sendDiscordNotification(currentMoney - lastMoneyValue)
                        end
                    end
                end)
            end
        else
            if macroRunning then
                macroRunning = false
                keyRelease(Enum.KeyCode.W)
                keyPress(Enum.KeyCode.LeftControl)
                task.wait(0.05)
                keyRelease(Enum.KeyCode.LeftControl)
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.02)
        if Config.AFKRouteEnabled and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local root = localPlayer.Character.HumanoidRootPart
            local targetPos = StraightawayWaypoints[Config.CurrentWaypointIndex]
            if targetPos then
                local currentPosFlat = Vector3.new(root.Position.X, 0, root.Position.Z)
                local targetPosFlat = Vector3.new(targetPos.X, 0, targetPos.Z)
                local distance = (currentPosFlat - targetPosFlat).Magnitude
                if distance > 8 then
                    local targetCFrame = CFrame.new(root.Position, Vector3.new(targetPos.X, root.Position.Y, targetPos.Z))
                    root.CFrame = root.CFrame:Lerp(targetCFrame, 0.25)
                    local currentVel = root.AssemblyLinearVelocity
                    root.AssemblyLinearVelocity = Vector3.new(root.CFrame.LookVector.X * 65, currentVel.Y, root.CFrame.LookVector.Z * 65)
                else
                    if Config.CurrentWaypointIndex < #StraightawayWaypoints then
                        Config.CurrentWaypointIndex = Config.CurrentWaypointIndex + 1
                    else
                        Config.CurrentWaypointIndex = 1 
                    end
                end
            end
        end
    end
end)

local MainTab = Window:CreateTab("Main Framework", 0)
local SettingsTab = Window:CreateTab("Configurations", 0)

MainTab:CreateToggle({
    Name = "Auto-Wheelie", 
    CurrentValue = false, 
    Flag = "WheelieToggle", 
    Callback = function(Value) 
        Config.Enabled = Value 
    end
})

MainTab:CreateToggle({
    Name = "Auto AFK Route (750 Studs Max)", 
    CurrentValue = false, 
    Flag = "AFKRouteToggle", 
    Callback = function(Value) 
        if Value and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then 
            local root = localPlayer.Character.HumanoidRootPart 
            local startPos = root.Position 
            local forwardDirection = root.CFrame.LookVector 
            StraightawayWaypoints = {startPos, startPos + (forwardDirection * 250), startPos + (forwardDirection * 500), startPos + (forwardDirection * 750)} 
            Config.CurrentWaypointIndex = 1 
            Config.AFKRouteEnabled = true 
            drawPathLines() 
        else 
            Config.AFKRouteEnabled = false 
            clearVisualLines() 
        end 
    end
})

SettingsTab:CreateInput({
    Name = "Discord Webhook URL", 
    PlaceholderText = "Paste Discord URL here...", 
    RemoveTextAfterFocusLost = false, 
    Callback = function(Text) 
        Config.Webhook = Text 
    end
})

SettingsTab:CreateButton({
    Name = "Test Webhook Connection", 
    Callback = function() 
        if Config.Webhook and Config.Webhook ~= "" then 
            sendDiscordNotification("0 (Test Alert)") 
        else 
            Rayfield:Notify({Title = "Error", Content = "Please provide a valid webhook link first!", Duration = 3, Image = 4483362458}) 
        end 
    end
})

SettingsTab:CreateDropdown({
    Name = "Time Changer (Client Only)", 
    Options = {"Default/Server", "Day (12:00)", "Night (00:00)"}, 
    CurrentOption = "Default/Server", 
    MultipleOptions = false, 
    Callback = function(Option) 
        if Option == "Day (12:00)" then 
            Config.TargetTime = 12 
        elseif Option == "Night (00:00)" then 
            Config.TargetTime = 0 
        else 
            Config.TargetTime = nil 
        end 
    end
})
