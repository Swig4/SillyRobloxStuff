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
    loadstring(game:HttpGet('https://raw.githubusercontent.com/Swig4/SillyRobloxStuff/main/UniversalGoober.lua'))()
end)

-- DEEPWOKEN
local DeepwokenTab = Main:CreateTab("Deepwoken")
DeepwokenTab:CreateButton("Inject",function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/Swig4/SillyRobloxStuff/main/Deepwoken-Goober.lua'))()
end)

tab:Show()
