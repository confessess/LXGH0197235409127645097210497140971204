-- ============================================================
-- LIGHT HUB - Script Hub UI
-- ============================================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local GUI = {}

local Theme = {
    Background = Color3.fromRGB(18, 19, 24),
    Panel = Color3.fromRGB(24, 25, 31),
    Surface = Color3.fromRGB(30, 32, 39),
    SurfaceAlt = Color3.fromRGB(35, 38, 46),
    Line = Color3.fromRGB(72, 77, 87),
    Text = Color3.fromRGB(245, 245, 247),
    TextDim = Color3.fromRGB(172, 176, 186),
    TextSoft = Color3.fromRGB(131, 136, 146),
    Shadow = Color3.fromRGB(8, 9, 12),
}

local ScreenGui, MainFrame, Title, SearchBox, GameList, DetailsPanel, LoadButton, SelectedGame
local MenuOpen = true

local ScriptLibrary = {
    {
        Name = "Blox Fruits",
        Game = "Blox Fruits",
        Tag = "Combat",
        Description = "Auto farm, movement, and utility script for Blox Fruits with clean loadout options.",
        Script = [[
print("[LightHub] Blox Fruits loaded")
]],
    },
    {
        Name = "Pet Simulator 99",
        Game = "Pet Simulator 99",
        Tag = "Farm",
        Description = "Farm loop and collection helper designed for fast progress on higher-tier pets.",
        Script = [[
print("[LightHub] Pet Simulator 99 loaded")
]],
    },
    {
        Name = "Arsenal",
        Game = "Arsenal",
        Tag = "Combat",
        Description = "Movement and aiming assistance script built for quick execution in fast matches.",
        Script = [[
print("[LightHub] Arsenal loaded")
]],
    },
    {
        Name = "Adopt Me",
        Game = "Adopt Me",
        Tag = "Farm",
        Description = "Simple collection and progression helper for trading and farming loops.",
        Script = [[
print("[LightHub] Adopt Me loaded")
]],
    },
    {
        Name = "Doors",
        Game = "Doors",
        Tag = "Utility",
        Description = "Helper script for faster navigation and safer route management during runs.",
        Script = [[
print("[LightHub] Doors loaded")
]],
    },
    {
        Name = "Tower of Hell",
        Game = "Tower of Hell",
        Tag = "Parkour",
        Description = "Parkour and movement tools for smoother route execution and reaction timing.",
        Script = [[
print("[LightHub] Tower of Hell loaded")
]],
    },
}

local function tween(obj, props, duration)
    TweenService:Create(obj, TweenInfo.new(duration or 0.18), props):Play()
end

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
end

local function stroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Line
    s.Thickness = thickness or 1
    s.Parent = parent
end

local function addGradient(parent, rotation, c1, c2)
    local g = Instance.new("UIGradient")
    g.Rotation = rotation or -90
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, c1 or Color3.fromRGB(145, 150, 160)),
        ColorSequenceKeypoint.new(1, c2 or Color3.fromRGB(220, 222, 226)),
    })
    g.Parent = parent
    return g
end

local function setCardGlow(card, glow, active)
    if not card or not glow then return end
    glow.Transparency = active and 0.45 or 0.75
    glow.Thickness = active and 1.5 or 1
end

local function applyCardState(card, gameData)
    if not card then return end

    local selected = SelectedGame and SelectedGame.Name == gameData.Name
    local glow = card:FindFirstChildOfClass("UIStroke")

    if selected then
        tween(card, {BackgroundColor3 = Color3.fromRGB(145, 150, 160)})
        setCardGlow(card, glow, true)
    else
        tween(card, {BackgroundColor3 = Theme.SurfaceAlt})
        setCardGlow(card, glow, false)
    end
end

local function dragify(frame)
    local dragToggle = false
    local dragStart, startPos
    local dragInput = nil

    frame.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and UserInputService:GetFocusedTextBox() == nil then
            dragToggle = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragToggle then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local function setSelectedGame(gameData)
    SelectedGame = gameData

    if not SelectedGame then return end

    local nameLabel = DetailsPanel:FindFirstChild("GameName")
    local descLabel = DetailsPanel:FindFirstChild("GameDescription")

    if nameLabel then nameLabel.Text = SelectedGame.Name end
    if descLabel then descLabel.Text = SelectedGame.Description end

    if LoadButton then
        LoadButton.Text = "Load Script"
    end
end

local function createGameCard(gameData, index)
    local card = Instance.new("TextButton")
    card.Size = UDim2.new(1, 0, 0, 48)
    card.BackgroundColor3 = Theme.SurfaceAlt
    card.BorderSizePixel = 0
    card.AutoButtonColor = false
    card.Text = ""
    card.LayoutOrder = index
    card.Parent = GameList
    corner(card, 8)
    stroke(card, Theme.Line, 1)

    local glow = Instance.new("UIStroke")
    glow.Color = Color3.fromRGB(188, 192, 201)
    glow.Transparency = 0.75
    glow.Thickness = 1
    glow.Parent = card

    local isUniversal = (gameData.Name == "Universal")
    card.BackgroundColor3 = Theme.SurfaceAlt
    addGradient(card, -90, Color3.fromRGB(137, 142, 151), Color3.fromRGB(210, 214, 220))

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -18, 0, 20)
    title.Position = UDim2.new(0, 12, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = gameData.Name
    title.TextColor3 = Theme.Text
    title.Font = Enum.Font.GothamSemibold
    title.TextSize = 13
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = card

    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, -18, 0, 16)
    subtitle.Position = UDim2.new(0, 12, 0, 28)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = gameData.Game
    subtitle.TextColor3 = Theme.TextSoft
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 11
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Parent = card

    card.MouseEnter:Connect(function()
        local childGlow = card:FindFirstChildOfClass("UIStroke")
        if childGlow then
            childGlow.Transparency = 0.6
            childGlow.Thickness = 1.2
        end
    end)

    card.MouseLeave:Connect(function()
        local childGlow = card:FindFirstChildOfClass("UIStroke")
        if SelectedGame and SelectedGame.Name == gameData.Name then
            if childGlow then
                childGlow.Transparency = 0.45
                childGlow.Thickness = 1.5
            end
        else
            if childGlow then
                childGlow.Transparency = 0.75
                childGlow.Thickness = 1
            end
        end
    end)

    card.MouseButton1Click:Connect(function()
        setSelectedGame(gameData)

        for _, child in ipairs(GameList:GetChildren()) do
            if child:IsA("TextButton") then
                local childData = { Name = child.Name }
                if child == card then
                    childData = gameData
                end
                applyCardState(child, childData)
            end
        end
    end)

    return card
end

local function refreshGames(filterText)
    filterText = (filterText or ""):lower()

    local cards = GameList:GetChildren()
    for _, child in ipairs(cards) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    local matches = 0
    for i, gameData in ipairs(ScriptLibrary) do
        local nameMatch = string.find(gameData.Name:lower(), filterText, 1, true)
        local gameMatch = string.find(gameData.Game:lower(), filterText, 1, true)
        local tagMatch = string.find(gameData.Tag:lower(), filterText, 1, true)

        if filterText == "" or nameMatch or gameMatch or tagMatch then
            createGameCard(gameData, i)
            matches += 1
        end
    end

    if matches > 0 then
        if SelectedGame == nil then
            setSelectedGame(ScriptLibrary[1])
        end
    else
        if DetailsPanel then
            local nameLabel = DetailsPanel:FindFirstChild("GameName")
            local descLabel = DetailsPanel:FindFirstChild("GameDescription")
            if nameLabel then nameLabel.Text = "No Results" end
            if descLabel then descLabel.Text = "No game match for this search." end
        end
    end
end

local function buildGui()
    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "LightHub"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.DisplayOrder = 999
    ScreenGui.Parent = playerGui

    MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.Size = UDim2.fromOffset(820, 510)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.Visible = true
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    corner(MainFrame, 10)
    stroke(MainFrame, Theme.Line, 1)

    local Background = Instance.new("Frame")
    Background.Name = "Background"
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.BackgroundColor3 = Theme.Background
    Background.BorderSizePixel = 0
    Background.ZIndex = 0
    Background.Parent = MainFrame
    corner(Background, 10)

    local sheen = Instance.new("Frame")
    sheen.Name = "WaveSheen"
    sheen.Size = UDim2.new(1, 0, 1, 0)
    sheen.BackgroundColor3 = Color3.fromRGB(170, 176, 184)
    sheen.BackgroundTransparency = 0
    sheen.BorderSizePixel = 0
    sheen.ZIndex = 1
    sheen.Parent = Background

    local waveGrad = Instance.new("UIGradient")
    waveGrad.Rotation = -45
    waveGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0.00, 1),
        NumberSequenceKeypoint.new(math.clamp(0.50 - 0.28, 0, 1), 1),
        NumberSequenceKeypoint.new(0.50, 0.82),
        NumberSequenceKeypoint.new(math.clamp(0.50 + 0.28, 0, 1), 1),
        NumberSequenceKeypoint.new(1.00, 1),
    })
    waveGrad.Parent = sheen

    do
        local offset = 1.5
        local paused = false
        local pauseTimer = 0
        local speed = 3.0 / 2.4

        RunService.RenderStepped:Connect(function(dt)
            if not sheen.Parent then return end
            if not MainFrame.Visible then return end

            if paused then
                pauseTimer = pauseTimer - dt
                if pauseTimer <= 0 then
                    paused = false
                    offset = 1.5
                end
                return
            end

            offset = offset - (speed * dt)
            if offset <= -1.5 then
                paused = true
                pauseTimer = 1.0
            end

            waveGrad.Offset = Vector2.new(offset, 0)
        end)
    end

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 62)
    header.BackgroundTransparency = 1
    header.ZIndex = 2
    header.Parent = MainFrame

    Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0, 220, 0, 24)
    Title.Position = UDim2.new(0, 24, 0, 20)
    Title.BackgroundTransparency = 1
    Title.Text = "LIGHT HUB"
    Title.TextColor3 = Theme.Text
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 20
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = header

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.fromOffset(30, 30)
    closeBtn.Position = UDim2.new(1, -42, 0, 16)
    closeBtn.BackgroundColor3 = Theme.Surface
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Theme.TextDim
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 18
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = header
    corner(closeBtn, 8)
    stroke(closeBtn, Theme.Line, 1)
    closeBtn.MouseButton1Click:Connect(function()
        MenuOpen = not MenuOpen
        MainFrame.Visible = MenuOpen
    end)

    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, -32, 0, 1)
    divider.Position = UDim2.new(0, 16, 0, 62)
    divider.BackgroundColor3 = Theme.Line
    divider.BorderSizePixel = 0
    divider.Parent = MainFrame

    local leftPanel = Instance.new("Frame")
    leftPanel.Size = UDim2.new(0, 295, 1, -82)
    leftPanel.Position = UDim2.new(0, 16, 0, 76)
    leftPanel.BackgroundColor3 = Theme.Panel
    leftPanel.BorderSizePixel = 0
    leftPanel.Parent = MainFrame
    corner(leftPanel, 10)
    stroke(leftPanel, Theme.Line, 1)

    local searchBg = Instance.new("Frame")
    searchBg.Size = UDim2.new(1, -18, 0, 36)
    searchBg.Position = UDim2.new(0, 9, 0, 10)
    searchBg.BackgroundColor3 = Theme.Surface
    searchBg.BorderSizePixel = 0
    searchBg.Parent = leftPanel
    corner(searchBg, 8)
    stroke(searchBg, Theme.Line, 1)

    SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(1, -20, 1, -4)
    SearchBox.Position = UDim2.new(0, 10, 0, 2)
    SearchBox.BackgroundTransparency = 1
    SearchBox.PlaceholderText = "Search game..."
    SearchBox.Text = ""
    SearchBox.TextColor3 = Theme.Text
    SearchBox.PlaceholderColor3 = Theme.TextSoft
    SearchBox.Font = Enum.Font.GothamMedium
    SearchBox.TextSize = 12
    SearchBox.ClearTextOnFocus = false
    SearchBox.Parent = searchBg

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        refreshGames(SearchBox.Text)
    end)

    local listFrame = Instance.new("ScrollingFrame")
    listFrame.Size = UDim2.new(1, -34, 1, -54)
    listFrame.Position = UDim2.new(0, 10, 0, 54)
    listFrame.BackgroundTransparency = 1
    listFrame.BorderSizePixel = 0
    listFrame.ScrollBarThickness = 0
    listFrame.ScrollBarImageTransparency = 1
    listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    listFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    listFrame.Parent = leftPanel

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 8)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = listFrame

    local scrollbarTrack = Instance.new("Frame")
    scrollbarTrack.Name = "ScrollBarTrack"
    scrollbarTrack.Size = UDim2.new(0, 6, 1, -72)
    scrollbarTrack.Position = UDim2.new(1, -12, 0, 62)
    scrollbarTrack.BackgroundColor3 = Color3.fromRGB(40, 43, 49)
    scrollbarTrack.BorderSizePixel = 0
    scrollbarTrack.Parent = leftPanel
    corner(scrollbarTrack, 3)

    local scrollbarThumb = Instance.new("Frame")
    scrollbarThumb.Name = "ScrollBarThumb"
    scrollbarThumb.BackgroundColor3 = Theme.Line
    scrollbarThumb.BorderSizePixel = 0
    scrollbarThumb.Size = UDim2.new(1, 0, 0, 0)
    scrollbarThumb.Position = UDim2.new(0, 0, 0, 0)
    scrollbarThumb.Parent = scrollbarTrack
    corner(scrollbarThumb, 3)

    local isDraggingThumb = false
    local dragStartY = 0
    local startScroll = 0

    local function updateCustomScrollbar()
        if not listFrame or not scrollbarTrack or not scrollbarThumb then
            return
        end

        local viewHeight = math.max(1, listFrame.AbsoluteWindowSize.Y)
        local contentHeight = math.max(1, listFrame.CanvasSize.Y.Offset)

        if contentHeight <= viewHeight then
            scrollbarThumb.Size = UDim2.new(1, 0, 1, 0)
            scrollbarThumb.Position = UDim2.new(0, 0, 0, 0)
            return
        end

        local trackHeight = math.max(1, scrollbarTrack.AbsoluteSize.Y)
        local ratio = math.clamp(viewHeight / contentHeight, 0.08, 1)
        local thumbHeight = math.max(28, trackHeight * ratio)
        local maxTravel = math.max(0, trackHeight - thumbHeight)
        local maxScroll = math.max(1, contentHeight - viewHeight)
        local percent = math.clamp(listFrame.CanvasPosition.Y / maxScroll, 0, 1)

        scrollbarThumb.Size = UDim2.new(1, 0, 0, thumbHeight)
        scrollbarThumb.Position = UDim2.new(0, 0, 0, percent * maxTravel)
    end

    scrollbarThumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDraggingThumb = true
            dragStartY = input.Position.Y
            startScroll = listFrame.CanvasPosition.Y
        end
    end)

    scrollbarThumb.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDraggingThumb = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not isDraggingThumb or input.UserInputType ~= Enum.UserInputType.MouseMovement then
            return
        end

        local trackHeight = math.max(1, scrollbarTrack.AbsoluteSize.Y)
        local thumbHeight = scrollbarThumb.AbsoluteSize.Y
        local maxTravel = math.max(0, trackHeight - thumbHeight)
        local maxScroll = math.max(1, listFrame.CanvasSize.Y.Offset - listFrame.AbsoluteWindowSize.Y)

        local deltaY = input.Position.Y - dragStartY
        local percent = math.clamp(deltaY / math.max(1, maxTravel), -1, 1)
        listFrame.CanvasPosition = Vector2.new(listFrame.CanvasPosition.X, startScroll + (percent * maxScroll))
    end)

    listFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(updateCustomScrollbar)
    listFrame:GetPropertyChangedSignal("CanvasSize"):Connect(updateCustomScrollbar)
    listFrame:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(updateCustomScrollbar)
    scrollbarTrack:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateCustomScrollbar)

    GameList = listFrame

    DetailsPanel = Instance.new("Frame")
    DetailsPanel.Size = UDim2.new(1, -325, 1, -82)
    DetailsPanel.Position = UDim2.new(0, 315, 0, 76)
    DetailsPanel.BackgroundColor3 = Theme.Panel
    DetailsPanel.BorderSizePixel = 0
    DetailsPanel.Parent = MainFrame
    corner(DetailsPanel, 10)
    stroke(DetailsPanel, Theme.Line, 1)

    local infoTitle = Instance.new("TextLabel")
    infoTitle.Name = "GameName"
    infoTitle.Size = UDim2.new(1, -32, 0, 24)
    infoTitle.Position = UDim2.new(0, 18, 0, 18)
    infoTitle.BackgroundTransparency = 1
    infoTitle.Text = "Blox Fruits"
    infoTitle.TextColor3 = Theme.Text
    infoTitle.Font = Enum.Font.GothamBold
    infoTitle.TextSize = 20
    infoTitle.TextXAlignment = Enum.TextXAlignment.Left
    infoTitle.Parent = DetailsPanel

    local infoDivider = Instance.new("Frame")
    infoDivider.Size = UDim2.new(1, -32, 0, 1)
    infoDivider.Position = UDim2.new(0, 16, 0, 56)
    infoDivider.BackgroundColor3 = Theme.Line
    infoDivider.BorderSizePixel = 0
    infoDivider.Parent = DetailsPanel

    local descriptionHeader = Instance.new("TextLabel")
    descriptionHeader.Size = UDim2.new(1, -32, 0, 18)
    descriptionHeader.Position = UDim2.new(0, 18, 0, 74)
    descriptionHeader.BackgroundTransparency = 1
    descriptionHeader.Text = "DESCRIPTION"
    descriptionHeader.TextColor3 = Theme.TextDim
    descriptionHeader.Font = Enum.Font.GothamBold
    descriptionHeader.TextSize = 11
    descriptionHeader.TextXAlignment = Enum.TextXAlignment.Left
    descriptionHeader.Parent = DetailsPanel

    local description = Instance.new("TextLabel")
    description.Name = "GameDescription"
    description.Size = UDim2.new(1, -32, 0, 110)
    description.Position = UDim2.new(0, 18, 0, 96)
    description.BackgroundTransparency = 1
    description.Text = "Auto farm, movement, and utility script for Blox Fruits with clean loadout options."
    description.TextColor3 = Theme.TextDim
    description.Font = Enum.Font.Gotham
    description.TextSize = 12
    description.TextWrapped = true
    description.TextXAlignment = Enum.TextXAlignment.Left
    description.TextYAlignment = Enum.TextYAlignment.Top
    description.Parent = DetailsPanel

    local bottomBar = Instance.new("Frame")
    bottomBar.Size = UDim2.new(1, -32, 0, 64)
    bottomBar.Position = UDim2.new(0, 16, 1, -80)
    bottomBar.BackgroundColor3 = Theme.Surface
    bottomBar.BorderSizePixel = 0
    bottomBar.Parent = DetailsPanel
    corner(bottomBar, 10)
    stroke(bottomBar, Theme.Line, 1)

    LoadButton = Instance.new("TextButton")
    LoadButton.Size = UDim2.new(1, -26, 0, 40)
    LoadButton.Position = UDim2.new(0, 13, 0.5, -20)
    LoadButton.BackgroundColor3 = Theme.SurfaceAlt
    LoadButton.BorderSizePixel = 0
    LoadButton.Text = "Load Script"
    LoadButton.TextColor3 = Theme.Text
    LoadButton.Font = Enum.Font.GothamSemibold
    LoadButton.TextSize = 13
    LoadButton.AutoButtonColor = false
    LoadButton.Parent = bottomBar
    corner(LoadButton, 8)
    stroke(LoadButton, Theme.Line, 1)

    LoadButton.MouseEnter:Connect(function()
        tween(LoadButton, {BackgroundColor3 = Theme.Surface})
    end)

    LoadButton.MouseLeave:Connect(function()
        tween(LoadButton, {BackgroundColor3 = Theme.SurfaceAlt})
    end)

    LoadButton.MouseButton1Click:Connect(function()
        if not SelectedGame then return end

        local ok, err = pcall(function()
            if SelectedGame.Script and SelectedGame.Script ~= "" then
                local scriptFunc = loadstring(SelectedGame.Script)
                if scriptFunc then
                    scriptFunc()
                end
            else
                print("[LightHub] No script attached for:", SelectedGame.Name)
            end
        end)

        if not ok then
            warn("[LightHub] Failed to load script: " .. tostring(err))
        end
    end)

    dragify(MainFrame)
    refreshGames("")
    setSelectedGame(ScriptLibrary[1])
end

function GUI.ToggleMenu()
    MenuOpen = not MenuOpen
    if MainFrame then
        MainFrame.Visible = MenuOpen
    end
end

function GUI.Init()
    if ScreenGui then return end

    buildGui()
    print("[LightHub] GUI ready")
end

if not _G.LightHubLoaded then
    _G.LightHubLoaded = true
    GUI.Init()
end

return GUI