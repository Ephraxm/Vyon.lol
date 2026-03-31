local RUN_TOKEN_KEY = "EggBotActiveRunToken"
local ANTI_AFK_CONN_KEY = "EggBotAntiAfkConnection"
local CONNECTIONS_KEY = "EggBotConnections"
local runToken = tostring(os.clock()) .. "_" .. tostring(math.random(100000, 999999))
shared[RUN_TOKEN_KEY] = runToken

local function isCurrentRun()
    return shared[RUN_TOKEN_KEY] == runToken
end

local function cleanupPreviousObjects()
    local oldConnections = shared[CONNECTIONS_KEY]
    if type(oldConnections) == "table" then
        for _, connection in ipairs(oldConnections) do
            if connection and connection.Disconnect then
                pcall(function() connection:Disconnect() end)
            end
        end
    end
    shared[CONNECTIONS_KEY] = nil

    local oldAntiAfkConn = shared[ANTI_AFK_CONN_KEY]
    if oldAntiAfkConn and oldAntiAfkConn.Disconnect then
        pcall(function() oldAntiAfkConn:Disconnect() end)
    end
    shared[ANTI_AFK_CONN_KEY] = nil
    shared.toggled = false

    local cleanupNames = {
        "Slope1", "Slope2", "Slope3",
        "SlopeSoNoStuckyPoo", "SlopeSoNoStuckyPoo2", "SlopeSoNoStuckyPoo3",
        "Anti-Stuck1", "Anti-Stuck2", "Anti-Stuck3", "Anti-Stuck4", "Anti-Stuck5",
        "ActivePath",
        "WalkPaths",
    }

    for _, name in ipairs(cleanupNames) do
        local obj = workspace:FindFirstChild(name)
        if obj then
            pcall(function() obj:Destroy() end)
        end
    end

    local player = game:GetService("Players").LocalPlayer
    if player then
        local gui = player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("EggBotStatusUI")
        if gui then
            pcall(function() gui:Destroy() end)
        end
    end
end

cleanupPreviousObjects()
 
if workspace:FindFirstChild("Slope1") then
	task.spawn(function()
		workspace:FindFirstChild("Slope1"):Destroy()
		workspace:FindFirstChild("Anti-Stuck1"):Destroy()
		workspace:FindFirstChild("Anti-Stuck2"):Destroy()
		workspace:FindFirstChild("Anti-Stuck3"):Destroy()
		workspace:FindFirstChild("Anti-Stuck4"):Destroy()
	end)
end
 
local Slope1 = Instance.new("Part", game.Workspace)
Slope1.Name = "SlopeSoNoStuckyPoo"
Slope1.Size = Vector3.new(10,15,15)
Slope1.Position = Vector3.new(448.75, 102.75, -406)
Slope1.Rotation = Vector3.new(0,90,0)
Slope1.Shape = Enum.PartType.Wedge
Slope1.Anchored = true
Slope1.Transparency = 0.5
 
local Slope2 = Instance.new("Part", game.Workspace)
Slope2.Name = "SlopeSoNoStuckyPoo2"
Slope2.Size = Vector3.new(33, 20, 30)
Slope2.Position = Vector3.new(-63, 85, -182)
Slope2.Rotation = Vector3.new(0,0,0)
Slope2.Shape = Enum.PartType.Wedge
Slope2.Anchored = true
Slope2.Transparency = 0.5
 
local Slope3 = Instance.new("Part", game.Workspace)
Slope3.Name = "SlopeSoNoStuckyPoo3"
Slope3.Size = Vector3.new(20,20,19)
Slope3.Position = Vector3.new(478.5477600097656, 102.00000762939453, -399.6143493652344)
Slope3.Rotation = Vector3.new(0,90,0)
Slope3.Shape = Enum.PartType.Wedge
Slope3.Anchored = true
Slope3.Transparency = 0.5
 
local AntiSign1 = Instance.new("Part", game.Workspace)
AntiSign1.Name = "Anti-Stuck1"
AntiSign1.Anchored = true
AntiSign1.Size = Vector3.new(2, 34, 21)
AntiSign1.Position = Vector3.new(321, 100, -390)
AntiSign1.Rotation = Vector3.new(-90, 0, 180)
AntiSign1.Transparency = 0.5
 
local AntiSign2 = Instance.new("Part", game.Workspace)
AntiSign2.Name = "Anti-Stuck2"
AntiSign2.Anchored = true
AntiSign2.Size = Vector3.new(25,40,5)
AntiSign2.Position = Vector3.new(278.137, 106, -433.454)
AntiSign2.Rotation = Vector3.new(0, -69.999, 0)
AntiSign2.Transparency = 0.5
 
local AntiSign3 = Instance.new("Part", game.Workspace)
AntiSign3.Name = "Anti-Stuck3"
AntiSign3.Anchored = true
AntiSign3.Size = Vector3.new(25,40,5)
AntiSign3.Position = Vector3.new(255.786, 106, -452.495)
AntiSign3.Rotation = Vector3.new(0, -19.999, 0)
AntiSign3.Transparency = 0.5
 
local AntiSign4 = Instance.new("Part", game.Workspace)
AntiSign4.Name = "Anti-Stuck4"
AntiSign4.Anchored = true
AntiSign4.Size = Vector3.new(40, 50, 8)
AntiSign4.Position = Vector3.new(113.875, 100, -444)
AntiSign4.Rotation = Vector3.new(0, -90, 0)
AntiSign4.Transparency = 0.5
 
local AntiSign5 = Instance.new("Part", game.Workspace)
AntiSign5.Name = "Anti-Stuck5"
AntiSign5.Anchored = true
AntiSign5.Size = Vector3.new(80, 2, 8)
AntiSign5.Position = Vector3.new(400, 91, -316.5)
AntiSign5.Rotation = Vector3.new(0, 0, 0)
AntiSign5.Transparency = 0.5
 
local Players            = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local UserInputService   = game:GetService("UserInputService")
local HttpService        = game:GetService("HttpService")
local VirtualUser        = game:GetService("VirtualUser")
 
local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local trackedConnections = {}

local function trackConnection(connection)
    if connection then
        table.insert(trackedConnections, connection)
        shared[CONNECTIONS_KEY] = trackedConnections
    end
    return connection
end

local function enableAntiAfk(nonotify)
    if getconnections then
        for _, connection in pairs(getconnections(player.Idled)) do
            if connection and connection.Disable then
                pcall(connection.Disable, connection)
            elseif connection and connection.Disconnect then
                pcall(connection.Disconnect, connection)
            end
        end
    end

    local antiAfkConn = player.Idled:Connect(function()
        if not isCurrentRun() then return end
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)

    shared[ANTI_AFK_CONN_KEY] = antiAfkConn

    if not nonotify then
        print("[EggBot] Anti AFK enabled")
    end
end

enableAntiAfk()

local function farmEnabled()  return shared.toggled == true end
local function setFarm(v)     shared.toggled = v end
local checkEgg
local processQueue
local isWalking    = false
local eggQueue     = {}
local queuedIds    = {}
local lastMoveTick = tick()

local statusGui = playerGui:FindFirstChild("EggBotStatusUI")
if statusGui then statusGui:Destroy() end

statusGui = Instance.new("ScreenGui")
statusGui.Name = "EggBotStatusUI"
statusGui.ResetOnSpawn = false
statusGui.Parent = playerGui

local statusFrame = Instance.new("Frame")
statusFrame.Name = "Container"
statusFrame.Size = UDim2.new(0, 300, 0, 130)
statusFrame.Position = UDim2.new(0, 20, 0, 120)
statusFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
statusFrame.BackgroundTransparency = 0.15
statusFrame.BorderSizePixel = 0
statusFrame.Parent = statusGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = statusFrame

local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 30)
topBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
topBar.BorderSizePixel = 0
topBar.Parent = statusFrame

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 10)
topCorner.Parent = topBar

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -96, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Text = "EggBot Monitor"
title.Parent = topBar

local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 80, 0, 22)
toggleButton.Position = UDim2.new(1, -86, 0, 4)
toggleButton.BackgroundColor3 = Color3.fromRGB(46, 125, 50)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 12
toggleButton.Text = "OFF"
toggleButton.AutoButtonColor = true
toggleButton.Parent = topBar

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 6)
buttonCorner.Parent = toggleButton

local body = Instance.new("TextLabel")
body.Name = "Body"
body.Size = UDim2.new(1, -16, 1, -42)
body.Position = UDim2.new(0, 8, 0, 34)
body.BackgroundTransparency = 1
body.TextXAlignment = Enum.TextXAlignment.Left
body.TextYAlignment = Enum.TextYAlignment.Top
body.TextWrapped = true
body.TextColor3 = Color3.fromRGB(240, 240, 240)
body.Font = Enum.Font.Code
body.TextSize = 14
body.Text = "Status: Loading..."
body.Parent = statusFrame

local itemsFrame = Instance.new("Frame")
itemsFrame.Name = "CollectedContainer"
itemsFrame.Size = UDim2.new(0, 300, 0, 170)
itemsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
itemsFrame.BackgroundTransparency = 0.15
itemsFrame.BorderSizePixel = 0
itemsFrame.Parent = statusGui

local itemsCorner = Instance.new("UICorner")
itemsCorner.CornerRadius = UDim.new(0, 10)
itemsCorner.Parent = itemsFrame

local itemsHeader = Instance.new("TextLabel")
itemsHeader.Name = "Header"
itemsHeader.Size = UDim2.new(1, -12, 0, 24)
itemsHeader.Position = UDim2.new(0, 8, 0, 6)
itemsHeader.BackgroundTransparency = 1
itemsHeader.TextXAlignment = Enum.TextXAlignment.Left
itemsHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
itemsHeader.Font = Enum.Font.GothamBold
itemsHeader.TextSize = 13
itemsHeader.Text = "Collected This Run"
itemsHeader.Parent = itemsFrame

local itemsBody = Instance.new("TextLabel")
itemsBody.Name = "ItemsBody"
itemsBody.Size = UDim2.new(1, -16, 1, -36)
itemsBody.Position = UDim2.new(0, 8, 0, 30)
itemsBody.BackgroundTransparency = 1
itemsBody.TextXAlignment = Enum.TextXAlignment.Left
itemsBody.TextYAlignment = Enum.TextYAlignment.Top
itemsBody.TextWrapped = true
itemsBody.TextColor3 = Color3.fromRGB(240, 240, 240)
itemsBody.Font = Enum.Font.Code
itemsBody.TextSize = 13
itemsBody.Text = "Nothing collected yet."
itemsBody.Parent = itemsFrame

local PANEL_GAP = 8

local function positionPanels(basePos)
    statusFrame.Position = basePos
    itemsFrame.Position = UDim2.new(
        basePos.X.Scale,
        basePos.X.Offset,
        basePos.Y.Scale,
        basePos.Y.Offset + statusFrame.Size.Y.Offset + PANEL_GAP
    )
end

positionPanels(statusFrame.Position)

local dragging = false
local dragStart
local startPos

trackConnection(topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = statusFrame.Position
    end
end))

trackConnection(topBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end))

trackConnection(UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
    local delta = input.Position - dragStart
    positionPanels(UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y))
end))

local currentAction = "Idle"
local currentTarget = "None"
local collectedTotals = {}
local collectedOrder = {}

local function refreshCollectedUi()
    if not isCurrentRun() then return end

    if #collectedOrder == 0 then
        itemsBody.Text = "Nothing collected yet."
        return
    end

    local lines = {}
    for i, itemName in ipairs(collectedOrder) do
        lines[i] = "- " .. itemName .. " x" .. tostring(collectedTotals[itemName])
    end
    itemsBody.Text = table.concat(lines, "\n")
end

local function recordCollectedItem(itemName)
    if not isCurrentRun() then return end
    local name = tostring(itemName or "Unknown")
    if collectedTotals[name] == nil then
        collectedTotals[name] = 1
        table.insert(collectedOrder, name)
    else
        collectedTotals[name] = collectedTotals[name] + 1
    end
    refreshCollectedUi()
end

local function refreshStatusUi()
    if not isCurrentRun() then return end
    local queueCount = #eggQueue
    local farmState = farmEnabled() and "ON" or "OFF"
    body.Text = "Status: " .. currentAction
        .. "\nTarget: " .. currentTarget
        .. "\nQueue: " .. tostring(queueCount)
        .. "\nFarm: " .. farmState
end

local function setAction(action)
    if not isCurrentRun() then return end
    currentAction = action
    refreshStatusUi()
end

local function setTarget(target)
    if not isCurrentRun() then return end
    currentTarget = target
    refreshStatusUi()
end

local function refreshToggleButton()
    if not isCurrentRun() then return end
    if farmEnabled() then
        toggleButton.Text = "ON"
        toggleButton.BackgroundColor3 = Color3.fromRGB(46, 125, 50)
    else
        toggleButton.Text = "OFF"
        toggleButton.BackgroundColor3 = Color3.fromRGB(183, 28, 28)
    end
end

local function enableFarm()
    if not isCurrentRun() then return end
    if farmEnabled() then return end

    setFarm(true)
    setAction("Farm enabled")
    lastMoveTick = tick()
    for _, v in ipairs(workspace:GetChildren()) do
        checkEgg(v)
    end
    processQueue()
    refreshToggleButton()
end

local function disableFarm()
    if not isCurrentRun() then return end
    setFarm(false)
    isWalking = false
    setTarget("None")
    setAction("Farm disabled")
    refreshToggleButton()
end

trackConnection(toggleButton.Activated:Connect(function()
    if not isCurrentRun() then return end
    local turnOn = not farmEnabled()
    if turnOn then
        enableFarm()
    else
        disableFarm()
    end
end))

refreshToggleButton()

local WALK_PATH_LABEL = "EggBotWalkPath"
local walkPathsFolder = nil

local WALK_PATHS_JSON = [[
[{"CanCollide":true,"Color":{"b":0.6470588445663452,"g":0.6352941393852234,"r":0.6392157077789307},"Anchored":true,"Transparency":0,"Name":"Part","Position":{"y":86.41002655029297,"x":182.50320434570313,"z":-590.6454467773438},"Material":"Enum.Material.Plastic","CFrame":{"lookVector":{"y":0,"x":0.7071067690849304,"z":-0.7071067690849304},"rightVector":{"y":0,"x":0.7071067690849304,"z":0.7071067690849304},"upVector":{"y":1,"x":0,"z":0}},"Size":{"y":1,"x":4,"z":12}},{"CanCollide":true,"Color":{"b":0.6470588445663452,"g":0.6352941393852234,"r":0.6392157077789307},"Anchored":true,"Transparency":0,"Name":"Part","Position":{"y":88.5,"x":174,"z":-575},"Material":"Enum.Material.Plastic","CFrame":{"lookVector":{"y":-0.258819043636322,"x":0,"z":-0.9659258127212524},"rightVector":{"y":0,"x":1,"z":0},"upVector":{"y":0.9659258127212524,"x":0,"z":-0.258819043636322}},"Size":{"y":1,"x":4,"z":12}},{"CanCollide":true,"Color":{"b":0.6470588445663452,"g":0.6352941393852234,"r":0.6392157077789307},"Anchored":true,"Transparency":0,"Name":"Part","Position":{"y":87.41002655029297,"x":193.50320434570313,"z":-602.6454467773438},"Material":"Enum.Material.Plastic","CFrame":{"lookVector":{"y":0.17364895343780518,"x":0.6963639259338379,"z":-0.6963642835617065},"rightVector":{"y":-0.0000019669532775878908,"x":0.7071071863174439,"z":0.7071062922477722},"upVector":{"y":0.9848076105117798,"x":-0.12278690934181214,"z":0.12278979271650315}},"Size":{"y":1,"x":4,"z":12}},{"CanCollide":true,"Color":{"b":0.6470588445663452,"g":0.6352941393852234,"r":0.6392157077789307},"Anchored":true,"Transparency":0,"Name":"Part","Position":{"y":96.5,"x":178.25,"z":-676},"Material":"Enum.Material.Plastic","CFrame":{"lookVector":{"y":0,"x":1,"z":4.371138828673793e-8},"rightVector":{"y":0,"x":-4.371138828673793e-8,"z":1},"upVector":{"y":1,"x":0,"z":0}},"Size":{"y":1,"x":4,"z":21.5}},{"CanCollide":true,"Color":{"b":0.6470588445663452,"g":0.6352941393852234,"r":0.6392157077789307},"Anchored":true,"Transparency":0,"Name":"Part","Position":{"y":93.70304107666016,"x":135.14248657226563,"z":-676.4281005859375},"Material":"Enum.Material.Plastic","CFrame":{"lookVector":{"y":0,"x":0,"z":-1},"rightVector":{"y":-0.5735765099525452,"x":0.8191519975662231,"z":0},"upVector":{"y":0.8191519975662231,"x":0.5735765099525452,"z":0}},"Size":{"y":1,"x":19,"z":6}},{"CanCollide":true,"Color":{"b":0.6470588445663452,"g":0.6352941393852234,"r":0.6392157077789307},"Anchored":true,"Transparency":0,"Name":"Part","Position":{"y":100.73204803466797,"x":125.48541259765625,"z":-681.8712158203125},"Material":"Enum.Material.Plastic","CFrame":{"lookVector":{"y":-0.4999931752681732,"x":0.5566726326942444,"z":0.6634171605110169},"rightVector":{"y":0.000002682209014892578,"x":0.7660456895828247,"z":-0.6427860856056213},"upVector":{"y":-0.8660293221473694,"x":-0.3213868737220764,"z":-0.3830191493034363}},"Size":{"y":1,"x":4,"z":9}},{"CanCollide":true,"Color":{"b":0.6470588445663452,"g":0.6352941393852234,"r":0.6392157077789307},"Anchored":true,"Transparency":0,"Name":"Part","Position":{"y":103.73204803466797,"x":120.49268341064453,"z":-683.882080078125},"Material":"Enum.Material.Plastic","CFrame":{"lookVector":{"y":-0.5000066757202148,"x":0.7499956488609314,"z":-0.4330124855041504},"rightVector":{"y":-0.000009328126907348633,"x":-0.5000066757202148,"z":-0.8660215139389038},"upVector":{"y":-0.8660215139389038,"x":-0.43301254510879519,"z":0.25001367926597597}},"Size":{"y":1,"x":4,"z":9}},{"CanCollide":true,"Color":{"b":0.6470588445663452,"g":0.6352941393852234,"r":0.6392157077789307},"Anchored":true,"Transparency":0,"Name":"Part","Position":{"y":98,"x":93.83153533935547,"z":-647.8717651367188},"Material":"Enum.Material.Plastic","CFrame":{"lookVector":{"y":0,"x":0.7660444378852844,"z":-0.6427876353263855},"rightVector":{"y":0,"x":0.6427876353263855,"z":0.7660444378852844},"upVector":{"y":1,"x":0,"z":0}},"Size":{"y":1,"x":6,"z":16}},{"CanCollide":true,"Color":{"b":0.6470588445663452,"g":0.6352941393852234,"r":0.6392157077789307},"Anchored":true,"Transparency":0,"Name":"Part","Position":{"y":127.88510131835938,"x":536.3203125,"z":-257.306640625},"Material":"Enum.Material.Plastic","CFrame":{"lookVector":{"y":-0.5000003576278687,"x":-0,"z":-0.8660252094268799},"rightVector":{"y":0,"x":1,"z":0},"upVector":{"y":0.8660252094268799,"x":0,"z":-0.5000003576278687}},"Size":{"y":1,"x":4,"z":9.5}},{"CanCollide":true,"Color":{"b":0.6470588445663452,"g":0.6352941393852234,"r":0.6392157077789307},"Anchored":true,"Transparency":0,"Name":"Part","Position":{"y":119.16266632080078,"x":536.3203125,"z":-276.1989440917969},"Material":"Enum.Material.Plastic","CFrame":{"lookVector":{"y":-0.7071070671081543,"x":-0,"z":-0.7071065306663513},"rightVector":{"y":0,"x":1,"z":0},"upVector":{"y":0.7071065306663513,"x":0,"z":-0.7071070671081543}},"Size":{"y":1,"x":4,"z":13.5}},{"CanCollide":true,"Color":{"b":0.6470588445663452,"g":0.6352941393852234,"r":0.6392157077789307},"Anchored":true,"Transparency":0,"Name":"Part","Position":{"y":134.1434326171875,"x":536.3203125,"z":-242.14637756347657},"Material":"Enum.Material.Plastic","CFrame":{"lookVector":{"y":-0.5000003576278687,"x":-0,"z":-0.8660252094268799},"rightVector":{"y":0,"x":1,"z":0},"upVector":{"y":0.8660252094268799,"x":0,"z":-0.5000003576278687}},"Size":{"y":1,"x":4,"z":9.5}},{"CanCollide":true,"Color":{"b":0.6470588445663452,"g":0.6352941393852234,"r":0.6392157077789307},"Anchored":true,"Transparency":0,"Name":"Part","Position":{"y":141.1409149169922,"x":556.0523681640625,"z":-144.99830627441407},"Material":"Enum.Material.Plastic","CFrame":{"lookVector":{"y":-0.5000003576278687,"x":-0.8660252094268799,"z":1.1175870895385742e-7},"rightVector":{"y":1.043081283569336e-7,"x":-1.8066697293761536e-7,"z":-1},"upVector":{"y":0.8660252094268799,"x":-0.5000002384185791,"z":1.7881393432617188e-7}},"Size":{"y":1,"x":4,"z":13.5}},{"CanCollide":true,"Color":{"b":0.6470588445663452,"g":0.6352941393852234,"r":0.6392157077789307},"Anchored":true,"Transparency":0,"Name":"Part","Position":{"y":148.8837127685547,"x":563.5523681640625,"z":-149.58740234375},"Material":"Enum.Material.Plastic","CFrame":{"lookVector":{"y":-0.5000003576278687,"x":1.3361439243908536e-7,"z":0.8660252094268799},"rightVector":{"y":1.2616382605301625e-7,"x":-1,"z":2.1852214615591948e-7},"upVector":{"y":0.8660252094268799,"x":2.166691217553307e-7,"z":0.5000002384185791}},"Size":{"y":1,"x":4,"z":7}},{"CanCollide":true,"Color":{"b":0.6470588445663452,"g":0.6352941393852234,"r":0.6392157077789307},"Anchored":true,"Transparency":0,"Name":"Part","Position":{"y":143.85743713378907,"x":565.5523681640625,"z":-136.29318237304688},"Material":"Enum.Material.Plastic","CFrame":{"lookVector":{"y":-0.5000003576278687,"x":1.3361439243908536e-7,"z":0.8660252094268799},"rightVector":{"y":1.2616382605301625e-7,"x":-1,"z":2.1852214615591948e-7},"upVector":{"y":0.8660252094268799,"x":2.166691217553307e-7,"z":0.5000002384185791}},"Size":{"y":1,"x":4,"z":7}},{"CanCollide":true,"Color":{"b":0.6470588445663452,"g":0.6352941393852234,"r":0.6392157077789307},"Anchored":true,"Transparency":0,"Name":"Part","Position":{"y":104.50001525878906,"x":504.3572998046875,"z":-172.01644897460938},"Material":"Enum.Material.Plastic","CFrame":{"lookVector":{"y":-0,"x":-0,"z":-1},"rightVector":{"y":0,"x":1,"z":0},"upVector":{"y":1,"x":0,"z":0}},"Size":{"y":1,"x":8,"z":3.5}},{"CanCollide":true,"Color":{"b":0.6470588445663452,"g":0.6352941393852234,"r":0.6392157077789307},"Anchored":true,"Transparency":0,"Name":"Part","Position":{"y":128.49237060546876,"x":543.3203125,"z":-261.0163269042969},"Material":"Enum.Material.Plastic","CFrame":{"lookVector":{"y":-0.42261791229248049,"x":-0,"z":0.9063080549240112},"rightVector":{"y":0,"x":1,"z":0},"upVector":{"y":-0.9063080549240112,"x":0,"z":-0.42261791229248049}},"Size":{"y":1,"x":4,"z":9.5}},{"CanCollide":true,"Color":{"b":0.6470588445663452,"g":0.6352941393852234,"r":0.6392157077789307},"Anchored":true,"Transparency":0,"Name":"Part","Position":{"y":144.8754119873047,"x":545.6146240234375,"z":-270.19354248046877},"Material":"Enum.Material.Plastic","CFrame":{"lookVector":{"y":-0.42261791229248049,"x":-0.9063080549240112,"z":6.8398349206688639e-9},"rightVector":{"y":-5.962440319251527e-9,"x":1.0327249277963802e-8,"z":1},"upVector":{"y":-0.9063080549240112,"x":0.42261791229248049,"z":-9.768288400380243e-9}},"Size":{"y":1,"x":4,"z":9.5}},{"CanCollide":true,"Color":{"b":0.6470588445663452,"g":0.6352941393852234,"r":0.6392157077789307},"Anchored":true,"Transparency":0,"Name":"Part","Position":{"y":175.97608947753907,"x":567.0935668945313,"z":-206.5504150390625},"Material":"Enum.Material.Plastic","CFrame":{"lookVector":{"y":-0.8191521167755127,"x":0,"z":-0.5735763311386108},"rightVector":{"y":0,"x":1,"z":0},"upVector":{"y":0.5735763311386108,"x":0,"z":-0.8191521167755127}},"Size":{"y":1,"x":4,"z":17}},{"CanCollide":true,"Color":{"b":0.6470588445663452,"g":0.6352941393852234,"r":0.6392157077789307},"Anchored":true,"Transparency":0,"Name":"Part","Position":{"y":91.00001525878906,"x":92.90532684326172,"z":-419.2622375488281},"Material":"Enum.Material.Plastic","CFrame":{"lookVector":{"y":0,"x":0.866025447845459,"z":-0.4999999701976776},"rightVector":{"y":0.4226182997226715,"x":0.4531538486480713,"z":0.784885585308075},"upVector":{"y":0.9063077569007874,"x":-0.21130913496017457,"z":-0.36599820852279665}},"Size":{"y":1,"x":12,"z":3}},{"CanCollide":true,"Color":{"b":0.6470588445663452,"g":0.6352941393852234,"r":0.6392157077789307},"Anchored":true,"Transparency":0,"Name":"Part","Position":{"y":89.00001525878906,"x":84.80835723876953,"z":-435.7908020019531},"Material":"Enum.Material.Plastic","CFrame":{"lookVector":{"y":-0,"x":-0,"z":-1},"rightVector":{"y":0,"x":1,"z":0},"upVector":{"y":1,"x":0,"z":0}},"Size":{"y":1,"x":4,"z":8}},{"CanCollide":true,"Color":{"b":0.6470588445663452,"g":0.6352941393852234,"r":0.6392157077789307},"Anchored":true,"Transparency":0,"Name":"Part","Position":{"y":91.00001525878906,"x":64.98652648925781,"z":-444.8250732421875},"Material":"Enum.Material.Plastic","CFrame":{"lookVector":{"y":-0,"x":-0,"z":-1},"rightVector":{"y":0,"x":1,"z":0},"upVector":{"y":1,"x":0,"z":0}},"Size":{"y":1,"x":13.5,"z":3.5}},{"CanCollide":true,"Color":{"b":0.6470588445663452,"g":0.6352941393852234,"r":0.6392157077789307},"Anchored":true,"Transparency":0,"Name":"Part","Position":{"y":111.67679595947266,"x":518.3572998046875,"z":-174.8396759033203},"Material":"Enum.Material.Plastic","CFrame":{"lookVector":{"y":2.5071823728239907e-8,"x":1,"z":3.5806273501748367e-8},"rightVector":{"y":0.5735763907432556,"x":-4.371138828673793e-8,"z":0.8191521167755127},"upVector":{"y":0.8191521167755127,"x":0,"z":-0.5735763907432556}},"Size":{"y":1,"x":11.5,"z":3.5}}]
]]

local function parseMaterial(materialName)
    if type(materialName) ~= "string" then
        return Enum.Material.Plastic
    end

    local enumName = string.match(materialName, "Enum%.Material%.(.+)") or materialName
    return Enum.Material[enumName] or Enum.Material.Plastic
end

local function parseVector3(vec)
    if type(vec) ~= "table" then
        return nil
    end

    local x = tonumber(vec.x)
    local y = tonumber(vec.y)
    local z = tonumber(vec.z)
    if not x or not y or not z then
        return nil
    end

    return Vector3.new(x, y, z)
end

local function createWalkPathsFromJson(jsonText)
    if not isCurrentRun() then return end

    local ok, decoded = pcall(function()
        return HttpService:JSONDecode(jsonText)
    end)
    if not ok or type(decoded) ~= "table" then
        warn("[EggBot] Failed to decode WALK_PATHS_JSON")
        return
    end

    local existing = workspace:FindFirstChild("WalkPaths")
    if existing then
        existing:Destroy()
    end

    local folder = Instance.new("Folder")
    folder.Name = "WalkPaths"
    folder.Parent = workspace
    walkPathsFolder = folder

    for _, item in ipairs(decoded) do
        if type(item) == "table" then
            local part = Instance.new("Part")
            part.Name = tostring(item.Name or "Part")
            part.Anchored = item.Anchored == true
            part.CanCollide = item.CanCollide ~= false
            part.Transparency = tonumber(item.Transparency) or 0
            part.Material = parseMaterial(item.Material)

            local color = item.Color or {}
            part.Color = Color3.new(
                tonumber(color.r) or 1,
                tonumber(color.g) or 1,
                tonumber(color.b) or 1
            )

            local size = item.Size or {}
            part.Size = Vector3.new(
                tonumber(size.x) or 4,
                tonumber(size.y) or 1,
                tonumber(size.z) or 4
            )

            local pos = parseVector3(item.Position) or Vector3.new(0, 0, 0)
            part.Position = pos

            local cf = item.CFrame
            if type(cf) == "table" then
                local right = parseVector3(cf.rightVector)
                local up = parseVector3(cf.upVector)
                local look = parseVector3(cf.lookVector)
                if right and up and look then
                    part.CFrame = CFrame.fromMatrix(pos, right, up, -look)
                end
            end

            local modifier = Instance.new("PathfindingModifier")
            modifier.Label = WALK_PATH_LABEL
            modifier.PassThrough = false
            modifier.Parent = part

            part.Parent = folder
        end
    end
end

createWalkPathsFromJson(WALK_PATHS_JSON)
 
local PATH_PARAMS = {
    AgentHeight     = 1.5,
    AgentRadius     = 2,
    AgentCanJump    = true,
    AgentJumpHeight = 25,
    WaypointSpacing = shared.spacing or 2,
}
 
local REACH_DIST           = 4.5
local WAYPOINT_TIMEOUT      = 2.5
local STUCK_VEL_THRESHOLD  = 1.5
local STUCK_CHECK_AFTER    = 0.8
local MAX_PATH_ATTEMPTS    = 5
local WALK_HARD_TIMEOUT    = 90
local GLOBAL_STUCK_TIMEOUT = 90
local QUEUE_COOLDOWN       = 0.2
 
local GAP_DEPTH_THRESHOLD  = 5
local MAX_JUMPABLE_GAP     = 4
local PARKOUR_JUMP_BOOST   = true
local WALKPATH_SEARCH_RADIUS = 140
local MAX_WALKPATH_CANDIDATES = 6
 
local STUCK_RESET_THRESHOLD = 4
local stuckCheckCount       = 0
 
local EGG_COLORS = {
    [1] = Color3.fromRGB(255, 255, 255),
    [2] = Color3.fromRGB(0,   255, 0),
    [3] = Color3.fromRGB(0,   170, 255),
    [4] = Color3.fromRGB(170, 0,   255),
    [5] = Color3.fromRGB(255, 170, 0),
    [6] = Color3.fromRGB(255, 0,   0),
}
local JUMP_COLOR     = Color3.fromRGB(255, 100, 0)
local PRIORITY_COLOR = Color3.fromRGB(255, 0,   0)
local POTION_COLOR   = Color3.fromRGB(170, 0,   255)
local DEFAULT_COLOR  = Color3.new(1, 1, 1)
local GAP_COLOR      = Color3.fromRGB(255, 50, 50)
 
local PRIORITY_SET = {
    andromeda_egg      = true, angelic_egg  = true, blooming_egg = true,
    dreamer_egg        = true, egg_v2       = true, forest_egg   = true,
    hatch_egg          = true, royal_egg    = true, the_egg_of_the_sky = true,
}
 
local function isAlive(inst)
    return inst ~= nil and inst.Parent ~= nil
end
 
local function safeGet(fn)
    local ok, val = pcall(fn)
    return ok and val or nil
end
 
local function getChar()  return player.Character end
local function getHum(c)  return c and c:FindFirstChildOfClass("Humanoid") end
local function getRoot(c) return c and c:FindFirstChild("HumanoidRootPart") end
 
local function resolvePos(inst)
    if not isAlive(inst) then return nil end
    return safeGet(function()
        if inst:IsA("BasePart") then return inst.Position end
        if inst:IsA("Model") then
            if inst.PrimaryPart then return inst.PrimaryPart.Position end
            local bp = inst:FindFirstChildWhichIsA("BasePart", true)
            return bp and bp.Position
        end
    end)
end
 
local function isGapBelow(position)
    local rayDir = Vector3.new(0, -(GAP_DEPTH_THRESHOLD + 0.5), 0)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local char = getChar()
    if char then params.FilterDescendantsInstances = { char } end

    local offsets = {
        Vector3.new(0, 0.5, 0),
        Vector3.new(0.4, 0.5, 0),
        Vector3.new(-0.4, 0.5, 0),
        Vector3.new(0, 0.5, 0.4),
        Vector3.new(0, 0.5, -0.4),
    }
    for _, offset in ipairs(offsets) do
        local result = workspace:Raycast(position + offset, rayDir, params)
        if result then return false end
    end
    return true
end
 
local function getGapInfo(fromPos, toPos)
    local horizontalDist = Vector3.new(toPos.X - fromPos.X, 0, toPos.Z - fromPos.Z).Magnitude
    local midPos = (fromPos + toPos) / 2
 
    local toHasGap  = isGapBelow(toPos)
    local midHasGap = isGapBelow(midPos)
 
    if not toHasGap and not midHasGap then
        return nil
    end
 
    if horizontalDist <= MAX_JUMPABLE_GAP then
        return horizontalDist
    end
 
    return false
end
 
local function makePathFolder(waypoints, eggColor)
    local folder = Instance.new("Folder")
    folder.Name  = "ActivePath"
 
    pcall(function()
        for i, wp in ipairs(waypoints) do
            local p      = Instance.new("Part")
            p.Shape      = Enum.PartType.Ball
            p.Size       = Vector3.new(0.6, 0.6, 0.6)
            p.Position   = wp.Position
            p.Anchored   = true
            p.CanCollide = false
            p.CastShadow = false
            p.Transparency = shared.dev and 0 or 1
            p.Material   = Enum.Material.Neon
            local prevPos = (i > 1) and waypoints[i-1].Position or wp.Position
            local gapInfo = getGapInfo(prevPos, wp.Position)
            if gapInfo then
                p.Color = GAP_COLOR
            elseif wp.Action == Enum.PathWaypointAction.Jump then
                p.Color = JUMP_COLOR
            else
                p.Color = eggColor
            end
            p.Parent = folder
        end
    end)
 
    folder.Parent = workspace
 
    local function cleanup()
        task.spawn(function()
            pcall(function()
                if folder.Parent then folder:Destroy() end
            end)
        end)
    end
 
    return folder, cleanup
end
 
local function doJump(hum)
    if hum and hum:GetState() ~= Enum.HumanoidStateType.Jumping and hum:GetState() ~= Enum.HumanoidStateType.Freefall then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end
 
local function doGapJump(hum, root, targetPos)
    if not hum or not root then return false end
 
    local dir = (Vector3.new(targetPos.X, root.Position.Y, targetPos.Z) - root.Position).Unit
 
    if PARKOUR_JUMP_BOOST then
        local edgeApproach = root.Position + dir * 1.5
        hum:MoveTo(edgeApproach)
        task.wait(0.08)
    end
 
    doJump(hum)
    hum:MoveTo(targetPos)
 
    local t0 = tick()
    local landed = false
    while tick() - t0 < 2.5 do
        task.wait()
        local state = hum:GetState()
        if state ~= Enum.HumanoidStateType.Jumping and state ~= Enum.HumanoidStateType.Freefall then
            landed = true
            break
        end
        hum:MoveTo(targetPos)
    end
 
    return landed
end
 
local function respawnAndWait()
    setAction("Respawning character")
    local humanoid = getHum(getChar())
    if humanoid then
        humanoid.Health = 0
    end
    task.wait(0.5)
    local timeout = 10
    local t0      = tick()
    while tick() - t0 < timeout do
        local c    = getChar()
        local hum  = getHum(c)
        local root = getRoot(c)
        if c and hum and root and hum.Health > 0 then break end
        task.wait(0.2)
    end
    task.wait(0.3)
    setAction("Respawn complete")
end
 
local function findLadderNear(root)
    local nearby = workspace:GetPartBoundsInBox(
        CFrame.new(root.Position),
        Vector3.new(4, 6, 4)
    )
    for _, part in ipairs(nearby) do
        if part:IsA("BasePart")
            and not part:IsA("TrussPart")
            and string.find(part.Name:lower(), "ladder")
        then
            return part
        end
    end
    return nil
end

local function climbLadder(hum, root, ladder)
    local topY = ladder.Position.Y + ladder.Size.Y / 2 + 3
    local topPos = Vector3.new(ladder.Position.X, topY, ladder.Position.Z)

    local basePos = Vector3.new(ladder.Position.X, root.Position.Y, ladder.Position.Z)
    hum:MoveTo(basePos)
    task.wait(0.3)

    local t0 = tick()
    local lastY = root.Position.Y
    local stuckT = tick()

    while tick() - t0 < 10 do
        task.wait(0.1)
        local state = hum:GetState()

        if root.Position.Y >= topY - 1.5 then
            warn("[EggBot] Ladder climbed successfully")
            return true
        end

        hum:MoveTo(topPos)

        if root.Position.Y > lastY + 0.1 then
            lastY = root.Position.Y
            stuckT = tick()
        elseif tick() - stuckT > 2 then
            warn("[EggBot] Stuck on ladder – giving up climb")
            return false
        end
    end

    return false
end

local function stepToWaypoint(hum, root, wp, prevPos)
    if not hum or not root then return "fail" end
 
    local fromPos = prevPos or root.Position
    local gapInfo = getGapInfo(fromPos, wp.Position)
 
    if gapInfo == false then
        return "gaptoowide"
    elseif gapInfo then
        local success = doGapJump(hum, root, wp.Position)
        if success then
            lastMoveTick = tick()
            stuckCheckCount = 0
            return "reached"
        else
            return "gapfail"
        end
    end
 
    hum:MoveTo(wp.Position)
 
    local result       = nil
    local startT       = tick()
    local lastPos      = root.Position
    local lastPosTime  = tick()
    local PROGRESS_CHECK_INTERVAL = 0.6
    local MIN_PROGRESS = 0.8
 
    local moveConn = hum.MoveToFinished:Connect(function(reached)
        if result == nil then result = reached and "reached" or "timeout" end
    end)
 
    while result == nil do
        task.wait()

        if not isCurrentRun() then result = "stopped" break end
 
        if not farmEnabled() then result = "stopped" break end
        if tick() - startT > WAYPOINT_TIMEOUT then result = "timeout" break end
 
        local dist = (root.Position - wp.Position).Magnitude
        if dist < REACH_DIST then
            result = "reached"
            lastMoveTick = tick()
            stuckCheckCount = 0
            break
        end
 
        local now = tick()
 
        if now - lastPosTime > PROGRESS_CHECK_INTERVAL then
            local moved = (root.Position - lastPos).Magnitude
 
            if moved < MIN_PROGRESS then
                stuckCheckCount = stuckCheckCount + 1
                warn("[EggBot] Stuck check " .. stuckCheckCount .. "/" .. STUCK_RESET_THRESHOLD)
 
                if stuckCheckCount >= STUCK_RESET_THRESHOLD then
                    warn("[EggBot] Repeatedly stuck – respawning character!")
                    stuckCheckCount = 0
                    moveConn:Disconnect()
                    respawnAndWait()
                    return "stuck_reset"
                end
 
                local lookAheadPos = root.Position + (wp.Position - root.Position).Unit * 3
                local surpriseGap  = getGapInfo(root.Position, lookAheadPos)
 
                local ladder = findLadderNear(root)
                if ladder then
                    warn("[EggBot] Ladder detected - attempting climb")
                    moveConn:Disconnect()
                    local climbed = climbLadder(hum, root, ladder)
                    if climbed then
                        stuckCheckCount = 0
                        result = "reached"
                    else
                        result = "timeout"
                    end
                    break
                elseif surpriseGap and surpriseGap ~= false then
                    local success = doGapJump(hum, root, wp.Position)
                    if success then
                        stuckCheckCount = 0
                        result = "reached"
                        break
                    end
                else
                    local awayDir = (root.Position - wp.Position).Unit
                    local backTarget = root.Position + Vector3.new(awayDir.X * 3, 0, awayDir.Z * 3)
                    
                    hum:MoveTo(backTarget)
                    task.wait(0.4)
                    
                    doJump(hum)
                    task.wait(0.05)
                    
                    hum:MoveTo(wp.Position)
                    warn("[EggBot] Resuming path with Forced Jump")
                end
            else
                stuckCheckCount = 0
            end
 
            lastPos     = root.Position
            lastPosTime = now
        end
    end
 
    moveConn:Disconnect()
    return result
end
 
local function rescanWorkspace()
    for _, v in ipairs(workspace:GetChildren()) do
        checkEgg(v)
    end
end
 
local function pathHasGap(waypoints)
    for i = 2, #waypoints do
        local prevPos = waypoints[i-1].Position
        local curPos  = waypoints[i].Position
        if getGapInfo(prevPos, curPos) ~= nil then
            return true
        end
    end
    return false
end

local function computeSafePath(fromPos, toPos, extraRadius)
    local params = {
        AgentHeight     = PATH_PARAMS.AgentHeight,
        AgentRadius     = PATH_PARAMS.AgentRadius + (extraRadius or 0),
        AgentCanJump    = PATH_PARAMS.AgentCanJump,
        AgentJumpHeight = PATH_PARAMS.AgentJumpHeight,
        WaypointSpacing = PATH_PARAMS.WaypointSpacing,
    }
    local path = PathfindingService:CreatePath(params)
    local ok = pcall(function() path:ComputeAsync(fromPos, toPos) end)
    if not ok or path.Status ~= Enum.PathStatus.Success then return nil end
    return path
end

local function findGapFreeWaypoints(fromPos, toPos)
    for _, extraRadius in ipairs({0, 2, 4, 6, 8}) do
        local candidate = computeSafePath(fromPos, toPos, extraRadius)
        if candidate then
            local wps = candidate:GetWaypoints()
            if not pathHasGap(wps) then
                if extraRadius > 0 then
                    warn("[EggBot] Gap-free path found with radius +" .. extraRadius)
                end
                return wps
            end
        end
    end

    return nil
end

local function findNearbyWalkPathFallback(fromPos, targetPos, usedAnchors)
    local folder = walkPathsFolder or workspace:FindFirstChild("WalkPaths")
    if not folder then return nil, nil end

    local candidates = {}
    local directDist = (targetPos - fromPos).Magnitude

    for _, child in ipairs(folder:GetChildren()) do
        if child:IsA("BasePart") and not usedAnchors[child] then
            local targetDist = (child.Position - targetPos).Magnitude
            local fromDist = (child.Position - fromPos).Magnitude

            if targetDist <= WALKPATH_SEARCH_RADIUS and fromDist < directDist then
                table.insert(candidates, {
                    part = child,
                    targetDist = targetDist,
                    fromDist = fromDist,
                })
            end
        end
    end

    table.sort(candidates, function(a, b)
        if a.targetDist == b.targetDist then
            return a.fromDist < b.fromDist
        end
        return a.targetDist < b.targetDist
    end)

    for index, candidate in ipairs(candidates) do
        if index > MAX_WALKPATH_CANDIDATES then break end

        local waypoints = findGapFreeWaypoints(fromPos, candidate.part.Position)
        if waypoints then
            return candidate.part, waypoints
        end
    end

    return nil, nil
end

local function walkToEgg(targetInstance, eggColor)
    if not isCurrentRun() then return "stopped" end
    local char = getChar()
    local hum = getHum(char)
    local root = getRoot(char)
    local usedAnchors = {}

    if not hum or not root then return "fail" end

    for attempt = 1, MAX_PATH_ATTEMPTS do
        if not isCurrentRun() then return "stopped" end
        if not farmEnabled() then return "stopped" end
        setAction("Calculating path (attempt " .. attempt .. ")")

        local targetPos = resolvePos(targetInstance)
        if not targetPos then return "done" end

        local waypoints = findGapFreeWaypoints(root.Position, targetPos)
        local anchorPart = nil

        if not waypoints then
            anchorPart, waypoints = findNearbyWalkPathFallback(root.Position, targetPos, usedAnchors)
        end

        if not waypoints then
            warn("[EggBot] No direct or staged gap-free path found on attempt " .. attempt .. " - retrying")
            setAction("Path failed, retrying")
            task.wait(0.2)
            continue
        end

        if anchorPart then
            usedAnchors[anchorPart] = true
            warn("[EggBot] Routing via nearby walk path anchor: " .. anchorPart:GetFullName())
            setAction("Routing via nearby anchor")
        end

        local pathFolder, cleanup = makePathFolder(waypoints, eggColor)
        local pathBroken = false
        setAction(anchorPart and "Walking to anchor" or "Walking path")

        for i, wp in ipairs(waypoints) do
            if not isCurrentRun() then
                pathBroken = true
                break
            end
            if not farmEnabled() or not isAlive(targetInstance) then
                pathBroken = true
                break
            end

            local prevPos = (i > 1) and waypoints[i-1].Position or root.Position

            if wp.Action == Enum.PathWaypointAction.Jump then
                doJump(hum)
            end

            local stepResult = stepToWaypoint(hum, root, wp, prevPos)

            if stepResult == "stuck_reset" then
                warn("[EggBot] Respawned mid-path - re-queuing egg")
                setAction("Stuck: reset and retry")
                pathBroken = true
                break
            elseif stepResult == "gaptoowide" or stepResult == "gapfail" then
                warn("[EggBot] Unexpected gap mid-walk at waypoint " .. i .. " - recomputing")
                setAction("Gap detected, recomputing")
                pathBroken = true
                break
            elseif stepResult ~= "reached" then
                setAction("Move timeout, recomputing")
                pathBroken = true
                break
            end
        end

        cleanup()
        if not farmEnabled() then return "stopped" end
        if pathBroken then task.wait(0.1) continue end

        if anchorPart then
            setAction("Reached anchor, retrying target")
            task.wait(0.1)
            continue
        end

        local collected = false
        if isAlive(targetInstance) then
            setAction("Collecting target")
            for _, v in ipairs(targetInstance:GetDescendants()) do
                if not isCurrentRun() then return "stopped" end
                if v:IsA("ProximityPrompt") then
                    task.wait(0.5)
                    fireproximityprompt(v)
                    collected = true
                end
            end
        end

        task.wait(0.1)

        if collected then
            recordCollectedItem(targetInstance and targetInstance.Name or "Unknown")
            rescanWorkspace()
        end

        setAction("Target complete")
        return "done"
    end
    setAction("Failed to reach target")
    return "fail"
end
 
local function pruneQueue()
    local alive = {}
    for _, e in ipairs(eggQueue) do
        if isAlive(e.target) then table.insert(alive, e) else queuedIds[e.id] = nil end
    end
    eggQueue = alive
    refreshStatusUi()
end
 
local function releaseWalking() isWalking = false end
 
processQueue = function()
    if not isCurrentRun() then return end
    if not farmEnabled() or isWalking or #eggQueue == 0 then return end
    isWalking = true
    setAction("Processing queue")
 
    task.spawn(function()
        if not isCurrentRun() then
            isWalking = false
            return
        end
        local hardTimer = task.delay(WALK_HARD_TIMEOUT, function() releaseWalking() end)
        pruneQueue()
        local data = table.remove(eggQueue, 1)
        refreshStatusUi()
        if data and queuedIds[data.id] then
            queuedIds[data.id] = nil
            if isCurrentRun() and isAlive(data.target) and farmEnabled() then
                setTarget(data.target.Name)
                warn("[EggBot] Resetting before next egg: " .. data.id)
                respawnAndWait()
                walkToEgg(data.target, data.color)
            end
        end
        task.cancel(hardTimer)
        setTarget("None")
        releaseWalking()
        if isCurrentRun() and #eggQueue == 0 and farmEnabled() then
            setAction("Idle: waiting for new targets")
        end
        if isCurrentRun() and farmEnabled() then task.wait(QUEUE_COOLDOWN) processQueue() end
    end)
end
 
checkEgg = function(v)
    task.spawn(function()
        if not isCurrentRun() then return end
        if not v or not (v:IsA("Model") or v:IsA("BasePart")) then return end
        task.wait(0.1)
        if not isCurrentRun() then return end
        if not isAlive(v) then return end
 
        local name = v.Name
        local uid  = name .. tostring(v)
        if queuedIds[uid] then return end
 
        local eggNum     = tonumber(string.match(name, "egg_(%d+)$"))
        local isPriority = PRIORITY_SET[name] == true
        local isPotion   = string.find(name, "potion", 1, true) ~= nil
        local eggColor

        if isPriority then eggColor = PRIORITY_COLOR
        elseif isPotion then eggColor = POTION_COLOR
        elseif eggNum then eggColor = EGG_COLORS[eggNum] or DEFAULT_COLOR
        else return end

        local hasPrompt = false
        for _, d in ipairs(v:GetDescendants()) do
            if d:IsA("ProximityPrompt") then
                hasPrompt = true
                break
            end
        end
        if not hasPrompt then
            warn("[EggBot] Skipping " .. name .. " – no ProximityPrompt found")
            return
        end

        queuedIds[uid] = true
        table.insert(eggQueue, isPriority and 1 or #eggQueue + 1, { target = v, color = eggColor, id = uid })
        setAction("Queued: " .. name)
        refreshStatusUi()
        if farmEnabled() then processQueue() end
    end)
end
 
trackConnection(workspace.ChildAdded:Connect(function(v)
    if not isCurrentRun() then return end
    checkEgg(v)
end))
setAction("Loaded and ready")
print("[EggBot] Bot Loaded - v2.0.0")
