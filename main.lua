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
-- 📁 YOUR MAIN GAME HUB SCRIPT INTERFACE GOES BELOW HERE:
-- ==============================================================================
-- Example: 
-- local Tab = Window:CreateTab("Main Hacks", 4483362458)
-- local Button = Tab:CreateButton({ Name = "Auto Wheelie", Callback = function() ... end })
