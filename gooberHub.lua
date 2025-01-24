local library = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ShaddowScripts/Main/main/Library"))()

local Main = library:CreateWindow("Goober Hub | Made By swig5 | V1.0","Crimson")

-- FUNCITONS
local function SendNotification(message)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Goober Hub",
        Text = message
    })
end

SendNotification("Goober Hub Has Successfully Loaded!")

-- MAIN
local MainTab = Main:CreateTab("Main")
MainTab:CreateButton("Hi",function()
    print("clicked")
end)

MainTab:CreateButton("Discord", function()
    local link = "https://discord.gg/mushroom"
    setclipboard(link)
    SendNotification("Link Copied To Clipboard!")
end)

-- UNIVERSAL
local UniversalTab = Main:CreateTab("Universal")
UniversalTab:CreateButton("Inject",function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/Swig4/SillyRobloxStuff/main/universalGoober.lua'))()
end)


-- DEEPWOKEN
local DeepwokenTab = Main:CreateTab("Deepwoken")
DeepwokenTab:CreateButton("Inject",function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/Swig4/SillyRobloxStuff/main/Deepwoken-Goober.lua'))()
end)

-- NON GOOBER
local NonGooberTab = Main:CreateTab("Non Goober Scripts")
NonGooberTab:CreateButton("Aimbot",function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/Swig4/SillyRobloxStuff/main/aimbot.lua'))()
end)

NonGooberTab:CreateButton("Orca",function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/richie0866/orca/master/public/latest.lua'))()
end)

NonGooberTab:CreateButton("Infinite Yield",function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
end)


tab:Show()
