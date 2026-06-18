local HttpService = game:GetService("HttpService")

-- The raw link to your keys database
local keysUrl = "https://raw.githubusercontent.com/prbusinesscontact-lab/Dornahub1/refs/heads/main/keys.json"

-- Fetch the key array text from GitHub
local success, response = pcall(function()
    return game:HttpGet(keysUrl)
end)

local validKeys = {}
if success and response then
    -- Convert the raw text from keys.json into a usable Roblox table list
    local decodeSuccess, decodedTable = pcall(function()
        return HttpService:JSONDecode(response)
    end)
    
    if decodeSuccess then
        validKeys = decodedTable
    else
        warn("Failed to decode keys.json structure.")
    end
else
    warn("Failed to connect to keys database.")
end

-- Load the Rayfield Library Interface natively
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Street Volt Miami 2",
    LoadingTitle = "Dorna Hub Loading...",
    LoadingSubtitle = "by xyaz",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "DornaHubConfig",
        FileName = "SVM2_Config"
    },
    KeySystem = true, 
    KeySettings = {
        Title = "Dorna Hub | Verification",
        Subtitle = "Key System",
        Note = "Generate a key instantly inside our Discord server!",
        SaveKey = true, 
        Key = validKeys -- Check inputs directly against your live array list
    }
})

-- ==============================================================================
-- 📁 MAIN GAME HUB INTERFACE (UNLOCKED AFTER KEY VERIFICATION)
-- ==============================================================================

-- Create the main menu category tab
local MainTab = Window:CreateTab("Main Features", 4483362458)

-- Add the Auto Wheelie toggle inside the tab
local WheelieToggle = MainTab:CreateToggle({
    Name = "Auto Wheelie",
    CurrentValue = false,
    Flag = "AutoWheelieFlag", -- Unique identifier for config saving
    Callback = function(Value)
        _G.AutoWheelieEnabled = Value
        
        if Value then
            Rayfield:Notify({
                Title = "Dorna Hub",
                Content = "Auto Wheelie Activated!",
                Duration = 2,
                Image = 4483362458,
            })
            
            -- Your continuous loops or state management code handles the physical adjustment loops here
            task.spawn(function()
                while _G.AutoWheelieEnabled do
                    -- This runs continuously in the background while the toggle is ON
                    task.wait(0.1)
                end
            end)
        else
            Rayfield:Notify({
                Title = "Dorna Hub",
                Content = "Auto Wheelie Deactivated.",
                Duration = 2,
                Image = 4483362458,
            })
        end
    end,
})

-- Add any extra features or buttons down here below the toggle!
