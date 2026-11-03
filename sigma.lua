-- ============================================================
-- NEVER WIN — premium cheat panel (CS2-style red/black)
-- ============================================================
local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local LocalPlayer       = Players.LocalPlayer

pcall(function()
    for _, step in ipairs({"NexusCamera", "NexusTrigger", "NexusTapTap", "NexusAim", "NexusThirdPerson"}) do
        RunService:UnbindFromRenderStep(step)
    end
end)

-- ============================================================
-- Хелперы
-- ============================================================
local function tween(obj, props, time, style, dir)
    local info = TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
    local t = TweenService:Create(obj, info, props); t:Play(); return t
end

local function new(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do inst[k] = v end
    if parent then inst.Parent = parent end
    return inst
end

-- ============================================================
-- Палитра
-- ============================================================
local COLORS = {
    bg = Color3.fromRGB(15, 15, 17), sidebar = Color3.fromRGB(18, 18, 20),
    topbar = Color3.fromRGB(18, 18, 20), panel = Color3.fromRGB(25, 25, 28),
    panelHover = Color3.fromRGB(35, 35, 38), accent = Color3.fromRGB(255, 51, 51),
    accent2 = Color3.fromRGB(255, 80, 80), text = Color3.fromRGB(220, 220, 220),
    textDim = Color3.fromRGB(130, 130, 140), border = Color3.fromRGB(45, 45, 48),
    trackOff = Color3.fromRGB(40, 40, 45), success = Color3.fromRGB(80, 250, 123),
    danger = Color3.fromRGB(255, 55, 65), warn = Color3.fromRGB(255, 184, 108),
    tracerNeon = Color3.fromRGB(170, 0, 255),
}

-- ============================================================
-- Настройки
-- ============================================================
local settings = {
    aimAssist = false, silentAim = false, showFOV = false, fov = 120, smoothness = 1,
    aimBind = { kind = "keyboard", key = Enum.KeyCode.E },
    triggerBot = false, triggerDelay = 50, triggerRequireHold = false,
    triggerBind = { kind = "keyboard", key = Enum.KeyCode.T },
    tapTap = false, tapTapDelay = 50, tapTapRange = 800,
    espPlayers = false, boxESP = false, healthESP = false, nameESP = false,
    espDistance = 500, tracers = false, thirdPerson = false,
    tpDistance = 12, tpBind = { kind = "keyboard", key = Enum.KeyCode.V },
    antiAim = false, antiAimMode = 1, antiAimSpeed = 15,
    detectAimers = true, autoEscape = false, autoClicker = false, friendToggle = true,
    bunnyHop = false, bunnyHopMaxSpeed = 120, bunnyHopAccel = 8,
    autoStrafe = false, -- НОВАЯ НАСТРОЙКА
}

-- ============================================================
-- Друзья
-- ============================================================
local friends = {}
local function isFriend(p) return p ~= nil and friends[p.UserId] == true end
local function toggleFriend(p)
    if not p then return nil end
    if friends[p.UserId] then friends[p.UserId] = nil; return false end
    friends[p.UserId] = true; return true
end

-- ============================================================
-- Все гуманоиды
-- ============================================================
local trackedChars = {}
local function isCharacterValid(char)
    if not char or not char.Parent then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    return char:FindFirstChild("Head") ~= nil or char:FindFirstChild("HumanoidRootPart") ~= nil
end
local function getAimPart(char) return char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart") end

local function tryTrack(char)
    if not char or char == LocalPlayer.Character or trackedChars[char] then return end
    if char:FindFirstChildOfClass("Humanoid") and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")) then
        trackedChars[char] = true
    end
end

workspace.DescendantAdded:Connect(function(inst)
    if inst:IsA("Humanoid") then task.delay(0.1, function() tryTrack(inst.Parent) end)
    elseif inst.Name == "Head" or inst.Name == "HumanoidRootPart" then
        local char = inst.Parent
        if char and char:FindFirstChildOfClass("Humanoid") then tryTrack(char) end
    end
end)
task.spawn(function() 
    for _, obj in ipairs(workspace:GetDescendants()) do if obj:IsA("Humanoid") then tryTrack(obj.Parent) end end
    while true do task.wait(2) end 
end)

-- ============================================================
-- Бинд утилиты
-- ============================================================
local function isMouseInput(t) return tostring(t):find("MouseButton") ~= nil end
local function matchesBind(input, bind)
    if not bind then return false end
    if bind.kind == "keyboard" then return input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == bind.key end
    return input.UserInputType == bind.key
end
local function bindDisplay(b)
    if not b then return "None" end
    if b.kind == "keyboard" then return b.key.Name end
    return (tostring(b.key):gsub("Enum.UserInputType%.", ""))
end

-- ============================================================
-- ScreenGui & FOV
-- ============================================================
local ScreenGui = new("ScreenGui", { Name = "NeverWinMenu", ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999 }, LocalPlayer:WaitForChild("PlayerGui"))

local fovContainer = new("Frame", { Size = UDim2.new(0, 240, 0, 240), Position = UDim2.new(0.5, -120, 0.5, -120), BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false, ZIndex = 10 }, ScreenGui)
local fovGlow = new("Frame", { Size = UDim2.new(1, 10, 1, 10), Position = UDim2.new(0, -5, 0, -5), BackgroundTransparency = 1, BorderSizePixel = 0 }, fovContainer)
new("UICorner", { CornerRadius = UDim.new(1, 0) }, fovGlow)
local glowStroke = new("UIStroke", { Color = COLORS.accent, Thickness = 4, Transparency = 0.85 }, fovGlow)
local fovCircle = new("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0 }, fovContainer)
new("UICorner", { CornerRadius = UDim.new(1, 0) }, fovCircle)
local fovStroke = new("UIStroke", { Color = COLORS.accent, Thickness = 1.5, Transparency = 0.1 }, fovCircle)
local fovDot = new("Frame", { Size = UDim2.new(0, 5, 0, 5), Position = UDim2.new(0.5, -2.5, 0.5, -2.5), BackgroundColor3 = COLORS.accent2, BorderSizePixel = 0 }, fovContainer)
new("UICorner", { CornerRadius = UDim.new(1, 0) }, fovDot)

local function updateFOVCircle()
    local size = math.max(settings.fov * 2, 40)
    fovContainer.Size = UDim2.new(0, size, 0, size)
    fovContainer.Position = UDim2.new(0.5, -size / 2, 0.5, -size / 2)
    fovContainer.Visible = settings.showFOV
end
updateFOVCircle()

local fovLocked = false
local function setFOVTargetLocked(locked)
    if fovLocked == locked then return end
    fovLocked = locked
    local c = locked and COLORS.success or COLORS.accent
    fovStroke.Color = c; glowStroke.Color = c
end

-- Toast
local function showToast(text, color)
    color = color or COLORS.accent
    local toast = new("TextLabel", { Size = UDim2.new(0, 380, 0, 42), Position = UDim2.new(0.5, -190, 1, -40), BackgroundColor3 = COLORS.panel, BackgroundTransparency = 1, BorderSizePixel = 0, Text = text, TextColor3 = COLORS.text, TextTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 13, ZIndex = 50 }, ScreenGui)
    new("UICorner", { CornerRadius = UDim.new(0, 4) }, toast)
    local stroke = new("UIStroke", { Color = color, Thickness = 1, Transparency = 1 }, toast)
    tween(toast, { BackgroundTransparency = 0, TextTransparency = 0, Position = UDim2.new(0.5, -190, 1, -70) }, 0.3, Enum.EasingStyle.Back)
    tween(stroke, { Transparency = 0.25 }, 0.3)
    task.delay(2.2, function()
        tween(toast, { BackgroundTransparency = 1, TextTransparency = 1, Position = UDim2.new(0.5, -190, 1, -40) }, 0.3)
        tween(stroke, { Transparency = 1 }, 0.3)
        task.wait(0.35); toast:Destroy()
    end)
end

-- ============================================================
-- UI ENIGMA
-- ============================================================
local menuCanvas = new("CanvasGroup", { Size = UDim2.new(0, 850, 0, 520), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = COLORS.bg, BorderSizePixel = 0, GroupTransparency = 1, Visible = false, ClipsDescendants = true }, ScreenGui)
new("UICorner", { CornerRadius = UDim.new(0, 6) }, menuCanvas)
new("UIStroke", { Color = COLORS.border, Thickness = 1 }, menuCanvas)
local menuScale = new("UIScale", { Scale = 0.9 }, menuCanvas)

local sidebar = new("Frame", { Size = UDim2.new(0, 180, 1, 0), BackgroundColor3 = COLORS.sidebar, BorderSizePixel = 0 }, menuCanvas)
new("UICorner", { CornerRadius = UDim.new(0, 6) }, sidebar)
local logoFrame = new("Frame", { Size = UDim2.new(1, 0, 0, 60), BackgroundTransparency = 1 }, sidebar)
new("TextLabel", { Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 20, 0, 15), BackgroundTransparency = 1, Text = "Enigma", TextColor3 = COLORS.text, Font = Enum.Font.GothamBold, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left }, logoFrame)
new("TextLabel", { Size = UDim2.new(1, -20, 0, 15), Position = UDim2.new(0, 20, 0, 35), BackgroundTransparency = 1, Text = "build v3 (NEVER WIN)", TextColor3 = COLORS.textDim, Font = Enum.Font.GothamMedium, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left }, logoFrame)

local navContainer = new("Frame", { Size = UDim2.new(1, 0, 1, -130), Position = UDim2.new(0, 0, 0, 70), BackgroundTransparency = 1 }, sidebar)
new("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }, navContainer)
new("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }, navContainer)

local profileFrame = new("Frame", { Size = UDim2.new(1, -20, 0, 45), Position = UDim2.new(0, 10, 1, -55), BackgroundColor3 = COLORS.panel, BorderSizePixel = 0 }, sidebar)
new("UICorner", { CornerRadius = UDim.new(0, 4) }, profileFrame)
new("TextLabel", { Size = UDim2.new(1, -50, 0, 15), Position = UDim2.new(0, 10, 0, 8), BackgroundTransparency = 1, Text = LocalPlayer.Name, TextColor3 = COLORS.text, Font = Enum.Font.GothamMedium, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left }, profileFrame)
new("TextLabel", { Size = UDim2.new(1, -50, 0, 15), Position = UDim2.new(0, 10, 0, 22), BackgroundTransparency = 1, Text = "Roblox", TextColor3 = COLORS.textDim, Font = Enum.Font.GothamMedium, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left }, profileFrame)

local topbar = new("Frame", { Size = UDim2.new(1, -180, 0, 60), Position = UDim2.new(0, 180, 0, 0), BackgroundColor3 = COLORS.topbar, BorderSizePixel = 0 }, menuCanvas)
new("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, 0), BackgroundColor3 = COLORS.border, BorderSizePixel = 0 }, topbar)
local searchBg = new("Frame", { Size = UDim2.new(0, 300, 0, 30), Position = UDim2.new(0, 20, 0.5, -15), BackgroundColor3 = COLORS.bg, BorderSizePixel = 0 }, topbar)
new("UICorner", { CornerRadius = UDim.new(0, 4) }, searchBg)
new("UIStroke", { Color = COLORS.border, Thickness = 1 }, searchBg)
new("TextLabel", { Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(0, 5, 0, 0), BackgroundTransparency = 1, Text = "🔍", TextColor3 = COLORS.textDim, TextSize = 12 }, searchBg)
local searchBox = new("TextBox", { Size = UDim2.new(1, -30, 1, 0), Position = UDim2.new(0, 25, 0, 0), BackgroundTransparency = 1, Text = "Поиск...", TextColor3 = COLORS.textDim, Font = Enum.Font.GothamMedium, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left }, searchBg)
searchBox.Focused:Connect(function() searchBox.Text = "" end)
searchBox.FocusLost:Connect(function() if searchBox.Text == "" then searchBox.Text = "Поиск..." end end)

local contentHolder = new("Frame", { Size = UDim2.new(1, -180, 1, -60), Position = UDim2.new(0, 180, 0, 60), BackgroundTransparency = 1, ClipsDescendants = true }, menuCanvas)

local toggleSetters = {}
local function createSection(parent, text)
    local c = new("Frame", { Size = UDim2.new(1, 0, 0, 25), BackgroundTransparency = 1 }, parent)
    new("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "≡ " .. text, TextColor3 = COLORS.textDim, Font = Enum.Font.GothamBold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left }, c)
end

local function createToggle(parent, text, default, callback, stateId)
    local btn = new("TextButton", { Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = COLORS.panel, BorderSizePixel = 0, Text = "", AutoButtonColor = false }, parent)
    new("UICorner", { CornerRadius = UDim.new(0, 4) }, btn)
    new("UIStroke", { Color = COLORS.border, Thickness = 1, Transparency = 0.5 }, btn)
    new("TextLabel", { Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 12, 0, 0), BackgroundTransparency = 1, Text = text, TextColor3 = COLORS.text, Font = Enum.Font.GothamMedium, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left }, btn)
    local track = new("Frame", { Size = UDim2.new(0, 34, 0, 18), Position = UDim2.new(1, -46, 0.5, -9), BackgroundColor3 = COLORS.trackOff, BorderSizePixel = 0 }, btn)
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, track)
    local knob = new("Frame", { Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = COLORS.textDim, BorderSizePixel = 0, ZIndex = 2 }, track)
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, knob)

    local state = default or false
    local function apply(anim)
        if state then
            local p = UDim2.new(1, -16, 0.5, -7)
            if anim then tween(knob, { Position = p, BackgroundColor3 = Color3.new(1,1,1) }, 0.2); tween(track, { BackgroundColor3 = COLORS.accent }, 0.2)
            else knob.Position = p; knob.BackgroundColor3 = Color3.new(1,1,1); track.BackgroundColor3 = COLORS.accent end
        else
            local p = UDim2.new(0, 2, 0.5, -7)
            if anim then tween(knob, { Position = p, BackgroundColor3 = COLORS.textDim }, 0.2); tween(track, { BackgroundColor3 = COLORS.trackOff }, 0.2)
            else knob.Position = p; knob.BackgroundColor3 = COLORS.textDim; track.BackgroundColor3 = COLORS.trackOff end
        end
    end
    local function setState(newState, anim, callCb)
        state = newState; apply(anim); if callCb and callback then callback(state) end
    end
    apply(false); if state and callback then callback(true) end
    if stateId then toggleSetters[stateId] = function(newState) setState(newState, true, false) end end
    btn.MouseEnter:Connect(function() tween(btn, { BackgroundColor3 = COLORS.panelHover }, 0.15) end)
    btn.MouseLeave:Connect(function() tween(btn, { BackgroundColor3 = COLORS.panel }, 0.15) end)
    btn.MouseButton1Click:Connect(function() setState(not state, true, true) end)
    return btn
end

local function createButton(parent, text, callback, isDanger)
    local btn = new("TextButton", { Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = isDanger and Color3.fromRGB(45, 10, 14) or COLORS.panel, BorderSizePixel = 0, Text = "", AutoButtonColor = false }, parent)
    new("UICorner", { CornerRadius = UDim.new(0, 4) }, btn)
    new("UIStroke", { Color = isDanger and COLORS.danger or COLORS.border, Thickness = 1, Transparency = 0.5 }, btn)
    new("TextLabel", { Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 12, 0, 0), BackgroundTransparency = 1, Text = text, TextColor3 = COLORS.text, Font = Enum.Font.GothamMedium, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left }, btn)
    btn.MouseEnter:Connect(function() tween(btn, { BackgroundColor3 = isDanger and Color3.fromRGB(70, 15, 20) or COLORS.panelHover }, 0.15) end)
    btn.MouseLeave:Connect(function() tween(btn, { BackgroundColor3 = isDanger and Color3.fromRGB(45, 10, 14) or COLORS.panel }, 0.15) end)
    btn.MouseButton1Click:Connect(function() if callback then callback() end end)
    return btn
end

local function createSlider(parent, text, min, max, default, callback)
    local c = new("Frame", { Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = COLORS.panel, BorderSizePixel = 0 }, parent)
    new("UICorner", { CornerRadius = UDim.new(0, 4) }, c)
    new("UIStroke", { Color = COLORS.border, Thickness = 1, Transparency = 0.5 }, c)
    new("TextLabel", { Size = UDim2.new(1, -60, 0, 20), Position = UDim2.new(0, 12, 0, 6), BackgroundTransparency = 1, Text = text, TextColor3 = COLORS.text, Font = Enum.Font.GothamMedium, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left }, c)
    local vLbl = new("TextLabel", { Size = UDim2.new(0, 40, 0, 20), Position = UDim2.new(1, -52, 0, 6), BackgroundTransparency = 1, Text = tostring(default), TextColor3 = COLORS.textDim, Font = Enum.Font.GothamMedium, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right }, c)
    local bar = new("Frame", { Size = UDim2.new(1, -24, 0, 4), Position = UDim2.new(0, 12, 0, 34), BackgroundColor3 = COLORS.trackOff, BorderSizePixel = 0 }, c)
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, bar)
    local fill = new("Frame", { Size = UDim2.new((default - min) / (max - min), 0, 1, 0), BackgroundColor3 = COLORS.accent, BorderSizePixel = 0 }, bar)
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, fill)
    local thumb = new("Frame", { Size = UDim2.new(0, 12, 0, 12), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0), BackgroundColor3 = Color3.new(1,1,1), BorderSizePixel = 0, ZIndex = 2 }, bar)
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, thumb)

    local dragging = false
    local function update(input)
        local relX = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local v = math.floor(min + (max - min) * relX + 0.5)
        fill.Size = UDim2.new(relX, 0, 1, 0); thumb.Position = UDim2.new(relX, 0, 0.5, 0); vLbl.Text = tostring(v)
        if callback then callback(v) end
    end
    bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; update(i) end end)
    UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then update(i) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    return c
end

local pages = {}
local sidebarBtns = {}
local function setActivePage(pageName)
    for name, page in pairs(pages) do page.Visible = (name == pageName) end
    for name, btn in pairs(sidebarBtns) do
        btn.Bg.BackgroundTransparency = (name == pageName) and 0.5 or 1
        btn.Line.Visible = (name == pageName)
        btn.Text.TextColor3 = (name == pageName) and COLORS.text or COLORS.textDim
        btn.Icon.TextColor3 = (name == pageName) and COLORS.accent or COLORS.textDim
    end
end

-- Правая панель (Viewport)
local rightPanel = new("Frame", { Size = UDim2.new(0, 240, 1, -20), Position = UDim2.new(1, -250, 0, 10), BackgroundColor3 = COLORS.panel, BorderSizePixel = 0, Visible = false }, contentHolder)
new("UICorner", { CornerRadius = UDim.new(0, 4) }, rightPanel)
new("UIStroke", { Color = COLORS.border, Thickness = 1 }, rightPanel)
new("TextLabel", { Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Text = "≡ ПРОСМОТР ПЕРСОНАЖА", TextColor3 = COLORS.textDim, Font = Enum.Font.GothamBold, TextSize = 11 }, rightPanel)

local vpf = new("ViewportFrame", { Size = UDim2.new(1, -20, 1, -50), Position = UDim2.new(0, 10, 0, 35), BackgroundColor3 = COLORS.bg, BorderSizePixel = 0 }, rightPanel)
new("UICorner", { CornerRadius = UDim.new(0, 4) }, vpf)
new("UIStroke", { Color = COLORS.border, Thickness = 1 }, vpf)

local worldModel = new("WorldModel", {}, vpf)
local vpCamera = new("Camera", {}, vpf)
vpf.CurrentCamera = vpCamera
vpCamera.FieldOfView = 40
vpCamera.CFrame = CFrame.new(0, 0, -6) * CFrame.Angles(0, math.rad(180), 0)

local clone = nil
local function refreshModel()
    if clone then clone:Destroy() end
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        clone = char:Clone()
        for _, v in ipairs(clone:GetDescendants()) do
            if v:IsA("BaseScript") or v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Light") or v:IsA("Sound") or v:IsA("Humanoid") then v:Destroy() end
        end
        clone.PrimaryPart = clone:FindFirstChild("HumanoidRootPart")
        clone.Parent = worldModel
        clone:PivotTo(CFrame.new(0, -3, 0))
    end
end

LocalPlayer.CharacterAdded:Connect(function() task.wait(1.5); refreshModel() end)
task.spawn(function() if LocalPlayer.Character then refreshModel() end; task.wait(1.5); refreshModel() end)

task.spawn(function()
    while rightPanel.Parent do
        task.wait(0.05)
        if clone and clone:FindFirstChild("HumanoidRootPart") then
            local angle = tick() * 30
            clone:PivotTo(CFrame.new(0, -3, 0) * CFrame.Angles(0, math.rad(angle), 0))
        end
    end
end)

local function createPage(name, icon, order, hasPanel)
    local btn = new("TextButton", { Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = COLORS.panel, BackgroundTransparency = 1, BorderSizePixel = 0, Text = "", AutoButtonColor = false, LayoutOrder = order }, navContainer)
    new("UICorner", { CornerRadius = UDim.new(0, 4) }, btn)
    local line = new("Frame", { Size = UDim2.new(0, 3, 0, 20), Position = UDim2.new(0, 0, 0.5, -10), BackgroundColor3 = COLORS.accent, BorderSizePixel = 0, Visible = false }, btn)
    new("UICorner", { CornerRadius = UDim.new(1, 0) }, line)
    local iconLbl = new("TextLabel", { Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = icon, TextColor3 = COLORS.textDim, Font = Enum.Font.GothamBold, TextSize = 14 }, btn)
    local textLbl = new("TextLabel", { Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 35, 0, 0), BackgroundTransparency = 1, Text = name, TextColor3 = COLORS.textDim, Font = Enum.Font.GothamMedium, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left }, btn)
    sidebarBtns[name] = { Bg = btn, Line = line, Text = textLbl, Icon = iconLbl }
    
    local page = new("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false }, contentHolder)
    local scrollFrame = new("ScrollingFrame", { Size = UDim2.new(1, hasPanel and -260 or -20, 1, -20), Position = UDim2.new(0, 20, 0, 10), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = COLORS.accent, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingDirection = Enum.ScrollingDirection.Y }, page)
    new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, scrollFrame)
    
    pages[name] = page
    btn.MouseButton1Click:Connect(function() setActivePage(name); rightPanel.Visible = hasPanel end)
    return scrollFrame
end

local aimPage = createPage("Aimbot", "⌖", 1, true)
local triggerPage = createPage("Trigger", "☄", 2, true)
local visualPage = createPage("Visuals", "◉", 3, true)
local antiAimPage = createPage("Anti-Aim", "!", 4, true)
local miscPage = createPage("Misc", "✤", 5, true)

local bindListening, tpBindListening, triggerBindListening = false, false, false
local bindButton, tpBindButton, triggerBindButton
local justBound, justBoundTp, justBoundTrigger = false, false, false

createSection(aimPage, "AIM SETTINGS")
bindButton = createButton(aimPage, "Bind: " .. bindDisplay(settings.aimBind), function()
    if justBound then return end
    if bindListening then bindListening = false; bindButton.Text = "Bind: " .. bindDisplay(settings.aimBind); return end
    if tpBindListening then tpBindListening = false; tpBindButton.Text = "TP Bind: " .. bindDisplay(settings.tpBind) end
    if triggerBindListening then triggerBindListening = false; triggerBindButton.Text = "Trigger Bind: " .. bindDisplay(settings.triggerBind) end
    bindListening = true; bindButton.Text = "Press a key / mouse btn..."
end, false)

createToggle(aimPage, "Aim Assist (players + bots)", false, function(s) settings.aimAssist = s end, nil)
createToggle(aimPage, "Silent Aim (executor)", false, function(s) settings.silentAim = s end, nil)
createToggle(aimPage, "Show FOV", false, function(s) settings.showFOV = s; updateFOVCircle() end, nil)
createSection(aimPage, "PARAMS")
createSlider(aimPage, "FOV", 20, 500, settings.fov, function(v) settings.fov = v; updateFOVCircle() end)
createSlider(aimPage, "Smoothness (1=instant, 10=slow)", 1, 10, settings.smoothness, function(v) settings.smoothness = v end)

createSection(triggerPage, "TAP TAP")
createToggle(triggerPage, "Tap Tap (Auto Aim & Fire on Sight)", false, function(s) settings.tapTap = s end, nil)
createSlider(triggerPage, "Tap Tap Delay (ms)", 10, 500, settings.tapTapDelay, function(v) settings.tapTapDelay = v end)
createSlider(triggerPage, "Tap Tap Range", 100, 2000, settings.tapTapRange, function(v) settings.tapTapRange = v end)

createSection(triggerPage, "TRIGGER BOT")
createToggle(triggerPage, "Trigger Bot (Auto Fire in Crosshair)", false, function(s) settings.triggerBot = s end, nil)
createToggle(triggerPage, "Require Hold Key", false, function(s) settings.triggerRequireHold = s end, nil)
createSlider(triggerPage, "Delay (ms)", 10, 500, settings.triggerDelay, function(v) settings.triggerDelay = v end)
triggerBindButton = createButton(triggerPage, "Trigger Bind: " .. bindDisplay(settings.triggerBind), function()
    if justBoundTrigger then return end
    if triggerBindListening then triggerBindListening = false; triggerBindButton.Text = "Trigger Bind: " .. bindDisplay(settings.triggerBind); return end
    if bindListening then bindListening = false; bindButton.Text = "Bind: " .. bindDisplay(settings.aimBind) end
    if tpBindListening then tpBindListening = false; tpBindButton.Text = "TP Bind: " .. bindDisplay(settings.tpBind) end
    triggerBindListening = true; triggerBindButton.Text = "Press a key / mouse btn..."
end, false)

createSection(visualPage, "ESP")
createToggle(visualPage, "ESP Players", false, function(s) settings.espPlayers = s end, nil)
createToggle(visualPage, "Box ESP", false, function(s) settings.boxESP = s end, nil)
createToggle(visualPage, "Health ESP", false, function(s) settings.healthESP = s end, nil)
createToggle(visualPage, "Name ESP", false, function(s) settings.nameESP = s end, nil)
createSlider(visualPage, "ESP Distance", 50, 2000, settings.espDistance, function(v) settings.espDistance = v end)
createSection(visualPage, "EFFECTS")
createToggle(visualPage, "Bullet Tracers (Neon)", false, function(s) settings.tracers = s end, nil)
createToggle(visualPage, "Third Person", false, function(s) settings.thirdPerson = s end, "thirdPerson")
createSlider(visualPage, "TP Distance", 4, 30, settings.tpDistance, function(v) settings.tpDistance = v end)

tpBindButton = createButton(visualPage, "TP Bind: " .. bindDisplay(settings.tpBind), function()
    if justBoundTp then return end
    if tpBindListening then tpBindListening = false; tpBindButton.Text = "TP Bind: " .. bindDisplay(settings.tpBind); return end
    if bindListening then bindListening = false; bindButton.Text = "Bind: " .. bindDisplay(settings.aimBind) end
    if triggerBindListening then triggerBindListening = false; triggerBindButton.Text = "Trigger Bind: " .. bindDisplay(settings.triggerBind) end
    tpBindListening = true; tpBindButton.Text = "Press a key / mouse btn..."
end, false)

createSection(antiAimPage, "DEFENSE")
createToggle(antiAimPage, "Anti-Aim", false, function(s) settings.antiAim = s end, nil)
createSlider(antiAimPage, "Anti-Aim Speed (1-100)", 1, 100, settings.antiAimSpeed, function(v) settings.antiAimSpeed = v end)
createSection(antiAimPage, "DETECT")
createToggle(antiAimPage, "Detect Aimers", true, function(s) settings.detectAimers = s end, nil)
createToggle(antiAimPage, "Auto-Escape", false, function(s) settings.autoEscape = s end, nil)

createSection(miscPage, "MOVEMENT")
createToggle(miscPage, "Bunny Hop", false, function(s) settings.bunnyHop = s; if not s then bunnyState.currentSpeed = 0 end end, nil)
createToggle(miscPage, "Auto-Strafe (Air Control)", false, function(s) settings.autoStrafe = s end, nil) -- НОВАЯ ФУНКЦИЯ
createSlider(miscPage, "Bunny Max Speed", 20, 500, settings.bunnyHopMaxSpeed, function(v) settings.bunnyHopMaxSpeed = v end)
createSlider(miscPage, "Bunny Accel", 1, 30, settings.bunnyHopAccel, function(v) settings.bunnyHopAccel = v end)
createSlider(miscPage, "Walk Speed", 16, 200, 16, function(v) local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if hum then hum.WalkSpeed = v end end)
createSection(miscPage, "MISC")
createToggle(miscPage, "Auto Clicker", false, function(s) settings.autoClicker = s end, nil)
createToggle(miscPage, "Friend Toggle (Mid Click)", true, function(s) settings.friendToggle = s end, nil)

setActivePage("Aimbot")
rightPanel.Visible = true

-- Ватермарка
local wmFrame = new("Frame", { Size = UDim2.new(0, 160, 0, 32), Position = UDim2.new(1, -20, 0, 20), AnchorPoint = Vector2.new(1, 0), BackgroundColor3 = Color3.fromRGB(25, 25, 25), BorderSizePixel = 0, ZIndex = 100 }, ScreenGui)
new("UICorner", { CornerRadius = UDim.new(1, 0) }, wmFrame)
new("UIStroke", { Color = Color3.fromRGB(50, 50, 50), Thickness = 1, Transparency = 0.5 }, wmFrame)
new("TextLabel", { Size = UDim2.new(0, 80, 1, 0), Position = UDim2.new(0, 12, 0, 0), BackgroundTransparency = 1, Text = "NEVER WIN", TextColor3 = COLORS.text, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 101 }, wmFrame)
new("Frame", { Size = UDim2.new(0, 1, 0, 14), Position = UDim2.new(0, 95, 0.5, -7), BackgroundColor3 = COLORS.textDim, BorderSizePixel = 0, ZIndex = 101 }, wmFrame)
new("TextLabel", { Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 105, 0.5, -7), BackgroundTransparency = 1, Text = "📈", TextSize = 12, ZIndex = 101 }, wmFrame)
local fpsLbl = new("TextLabel", { Size = UDim2.new(0, 40, 1, 0), Position = UDim2.new(0, 120, 0, 0), BackgroundTransparency = 1, Text = "60 fps", TextColor3 = COLORS.textDim, Font = Enum.Font.GothamMedium, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 101 }, wmFrame)
local frames, wmTime = 0, tick()
RunService.RenderStepped:Connect(function() frames = frames + 1; if tick() - wmTime >= 1 then fpsLbl.Text = tostring(frames) .. " fps"; frames = 0; wmTime = tick() end end)

-- ============================================================
-- ЛОГИКА АИМА
-- ============================================================
local aimKeyHeld = false
local triggerKeyHeld = false
local currentTargetPart = nil

local function getClosestTarget(fov)
    local camera = workspace.CurrentCamera
    if not camera then return nil end
    local center = camera.ViewportSize / 2
    local nearest, nearestDist = nil, fov
    for char in pairs(trackedChars) do
        if isCharacterValid(char) then
            local player = Players:GetPlayerFromCharacter(char)
            if not (player and isFriend(player)) then
                local part = getAimPart(char)
                if part then
                    local sp, on = camera:WorldToViewportPoint(part.Position)
                    if on and sp.Z > 0 then
                        local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                        if d < nearestDist then nearestDist = d; nearest = part end
                    end
                end
            end
        end
    end
    return nearest
end

RunService:BindToRenderStep("NexusCamera", Enum.RenderPriority.Camera.Value + 5, function(dt)
    local camera = workspace.CurrentCamera
    if not camera then return end
    
    local aimActive = settings.aimAssist and aimKeyHeld
    
    if not aimActive and settings.thirdPerson then
        local char = LocalPlayer.Character
        local head = char and char:FindFirstChild("Head")
        if head then
            local dist = settings.tpDistance
            local rayParams = RaycastParams.new()
            rayParams.FilterDescendantsInstances = {char}
            rayParams.FilterType = Enum.RaycastFilterType.Exclude
            local rayDir = -camera.CFrame.LookVector * dist
            local hit = workspace:Raycast(camera.CFrame.Position, rayDir, rayParams)
            if hit then dist = math.max(0, (hit.Position - camera.CFrame.Position).Magnitude - 0.5) end
            camera.CFrame = camera.CFrame * CFrame.new(0, 2, dist)
        end
    end
    
    if not aimActive then
        if settings.showFOV and not (settings.triggerBot or settings.tapTap) then setFOVTargetLocked(false) end
        currentTargetPart = nil
        return
    end
    
    if currentTargetPart and isCharacterValid(currentTargetPart.Parent) then
        local sp, on = camera:WorldToViewportPoint(currentTargetPart.Position)
        if not on or sp.Z <= 0 or (Vector2.new(sp.X, sp.Y) - camera.ViewportSize / 2).Magnitude > settings.fov then
            currentTargetPart = nil
        end
    else
        currentTargetPart = nil
    end
    
    if not currentTargetPart then
        currentTargetPart = getClosestTarget(settings.fov)
    end
    
    if settings.showFOV then setFOVTargetLocked(currentTargetPart ~= nil) end
    if not currentTargetPart then return end
    
    local aimCF = CFrame.lookAt(camera.CFrame.Position, currentTargetPart.Position)
    if settings.smoothness <= 1 then
        camera.CFrame = aimCF
    else
        local lerpSpeed = 1 / (settings.smoothness * 1.5)
        local f = math.clamp(lerpSpeed * (dt * 60), 0, 1)
        camera.CFrame = camera.CFrame:Lerp(aimCF, f)
    end
end)

-- ============================================================
-- ТРИГГЕРБОТ
-- ============================================================
local lastShot = 0
RunService:BindToRenderStep("NexusTrigger", Enum.RenderPriority.Camera.Value + 6, function()
    if not settings.triggerBot then return end
    if settings.triggerRequireHold and not triggerKeyHeld then return end
    
    local camera = workspace.CurrentCamera
    if not camera then return end
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("Humanoid") or myChar.Humanoid.Health <= 0 then return end
    
    local center = camera.ViewportSize / 2
    local target = nil
    local nearestDist = 60
    
    for char in pairs(trackedChars) do
        if isCharacterValid(char) then
            local player = Players:GetPlayerFromCharacter(char)
            if not (player and isFriend(player)) then
                local part = getAimPart(char)
                if part then
                    local sp, on = camera:WorldToViewportPoint(part.Position)
                    if on and sp.Z > 0 then
                        local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                        if d < nearestDist then
                            local rayDir = part.Position - camera.CFrame.Position
                            local rayParams = RaycastParams.new()
                            rayParams.FilterDescendantsInstances = { myChar, char }
                            rayParams.FilterType = Enum.RaycastFilterType.Exclude
                            local rayHit = workspace:Raycast(camera.CFrame.Position, rayDir, rayParams)
                            if not rayHit then nearestDist = d; target = part end
                        end
                    end
                end
            end
        end
    end
    
    if not target then
        if settings.showFOV and not (settings.aimAssist and aimKeyHeld) then setFOVTargetLocked(false) end
        return
    end
    
    if settings.showFOV then setFOVTargetLocked(true) end
    local now = tick()
    if now - lastShot < (settings.triggerDelay / 1000) then return end
    lastShot = now
    
    local oldCF = camera.CFrame
    camera.CFrame = CFrame.lookAt(camera.CFrame.Position, target.Position)
    local tool = myChar:FindFirstChildOfClass("Tool")
    if tool then pcall(function() tool:Activate() end) end
    if mouse1click then pcall(mouse1click) end
    task.spawn(function() 
        task.wait() task.wait() 
        if camera and not (settings.aimAssist and aimKeyHeld) then camera.CFrame = oldCF end 
    end)
end)

-- ============================================================
-- TAP TAP
-- ============================================================
local lastTapTap = 0
RunService:BindToRenderStep("NexusTapTap", Enum.RenderPriority.Camera.Value + 7, function()
    if not settings.tapTap then return end
    
    local camera = workspace.CurrentCamera
    if not camera then return end
    local myChar = LocalPlayer.Character
    if not myChar then return end
    local hrp = myChar:FindFirstChild("HumanoidRootPart")
    local hum = myChar:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return end
    local tool = myChar:FindFirstChildOfClass("Tool")
    if not tool then return end

    local now = tick()
    if now - lastTapTap < (settings.tapTapDelay / 1000) then return end

    local bestTarget = nil
    local bestDist = settings.tapTapRange or 800
    
    for char in pairs(trackedChars) do
        if isCharacterValid(char) then
            local player = Players:GetPlayerFromCharacter(char)
            if not (player and isFriend(player)) then
                local part = getAimPart(char)
                if part then
                    local dist = (part.Position - camera.CFrame.Position).Magnitude
                    if dist < bestDist then
                        local rayDir = part.Position - camera.CFrame.Position
                        local rayParams = RaycastParams.new()
                        rayParams.FilterDescendantsInstances = { myChar, char }
                        rayParams.FilterType = Enum.RaycastFilterType.Exclude
                        local rayHit = workspace:Raycast(camera.CFrame.Position, rayDir, rayParams)
                        if not rayHit then bestDist = dist; bestTarget = part end
                    end
                end
            end
        end
    end
    
    if not bestTarget then 
        if settings.showFOV and not (settings.aimAssist and aimKeyHeld) and not settings.triggerBot then setFOVTargetLocked(false) end
        return 
    end
    
    lastTapTap = now
    if settings.showFOV then setFOVTargetLocked(true) end

    local oldCF = camera.CFrame
    local oldHRP = hrp.CFrame
    
    camera.CFrame = CFrame.lookAt(camera.CFrame.Position, bestTarget.Position)
    hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(bestTarget.Position.X, hrp.Position.Y, bestTarget.Position.Z))
    
    if tool then pcall(function() tool:Activate() end) end
    if mouse1click then pcall(mouse1click) end
    
    task.spawn(function()
        task.wait() task.wait()
        if camera and not (settings.aimAssist and aimKeyHeld) then camera.CFrame = oldCF end
        if hrp and oldHRP and not (settings.aimAssist and aimKeyHeld) then hrp.CFrame = oldHRP end
    end)
end)

-- Silent Aim
task.spawn(function()
    if not hookmetamethod then return end
    pcall(function()
        local mouse = LocalPlayer:GetMouse()
        local old
        old = hookmetamethod(game, "__index", function(self, key)
            if settings.silentAim and self == mouse and (key == "Hit" or key == "Target") then
                local target = getClosestTarget(settings.fov)
                if target then 
                    if key == "Hit" then return CFrame.new(target.Position) end
                    if key == "Target" then return target end
                end
            end
            return old(self, key)
        end)
    end)
end)

-- ESP
local espCache = {}
local aimerSet = {}
local function setupESPForCharacter(char)
    if espCache[char] then return end
    local part = getAimPart(char)
    if not part then return end
    local nameBg = new("BillboardGui", { Size = UDim2.new(0, 240, 0, 20), StudsOffset = Vector3.new(0, 2.5, 0), AlwaysOnTop = true, Enabled = false }, part)
    local nameLbl = new("TextLabel", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = char.Name, TextColor3 = Color3.new(1, 1, 1), TextStrokeTransparency = 0, Font = Enum.Font.Code, TextSize = 13 }, nameBg)
    local healthBg = new("BillboardGui", { Size = UDim2.new(0, 100, 0, 8), StudsOffset = Vector3.new(0, 2, 0), AlwaysOnTop = true, Enabled = false }, part)
    local hFrame = new("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0 }, healthBg)
    local hFill = new("Frame", { Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(255, 60, 60), BorderSizePixel = 0 }, hFrame)
    local hl = new("Highlight", { FillTransparency = 1, OutlineColor = COLORS.accent, OutlineTransparency = 0, Enabled = false }, char)
    espCache[char] = { nameBg = nameBg, nameLbl = nameLbl, healthBg = healthBg, healthFill = hFill, highlight = hl }
end

local function updateESP()
    local anyOn = settings.espPlayers or settings.nameESP or settings.healthESP or settings.boxESP
    if not anyOn then
        for _, d in pairs(espCache) do d.nameBg.Enabled = false; d.healthBg.Enabled = false; d.highlight.Enabled = false end
        return
    end
    local camera = workspace.CurrentCamera
    if not camera then return end
    for char in pairs(trackedChars) do
        if isCharacterValid(char) then
            setupESPForCharacter(char)
            local d = espCache[char]
            if d then
                local part = getAimPart(char)
                local hum = char:FindFirstChildOfClass("Humanoid")
                local dist = (camera.CFrame.Position - part.Position).Magnitude
                local show = dist <= settings.espDistance
                local player = Players:GetPlayerFromCharacter(char)
                local friend = player and isFriend(player)
                local isAimer = aimerSet[char] and (tick() - aimerSet[char] < 5)
                local col = isAimer and COLORS.warn or (friend and COLORS.success or COLORS.accent)
                local prefix = isAimer and "!! " or (friend and "[F] " or (not player and "[N] " or ""))
                d.nameBg.Enabled = settings.nameESP and show
                d.healthBg.Enabled = settings.healthESP and show
                d.highlight.Enabled = settings.boxESP and show
                d.highlight.OutlineColor = col
                d.nameLbl.TextColor3 = col
                d.nameLbl.Text = prefix .. char.Name
                if hum then
                    local hp = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
                    d.healthFill.Size = UDim2.new(hp, 0, 1, 0)
                    d.healthFill.BackgroundColor3 = Color3.fromRGB(math.floor(255 * (1 - hp)), math.floor(255 * hp), 0)
                end
            end
        else
            local d = espCache[char]
            if d then for _, inst in pairs(d) do if typeof(inst) == "Instance" and inst.Parent then inst:Destroy() end end end
            espCache[char] = nil; trackedChars[char] = nil
        end
    end
end
task.spawn(function() while true do task.wait(0.1); updateESP() end end)

-- Auto Clicker
task.spawn(function()
    while true do
        task.wait(0.05)
        if settings.autoClicker then
            local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool then pcall(function() tool:Activate() end) end
            if mouse1click then pcall(mouse1click) end
        end
    end
end)

-- Anti-Aim
local spinAngle = 0; local jx, jy, jz = 0, 0, 0
RunService.Heartbeat:Connect(function(dt)
    if not settings.antiAim then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return end
    local mode, speed = settings.antiAimMode, settings.antiAimSpeed
    if mode == 1 then
        spinAngle = (spinAngle + dt * speed * 60) % 360
        hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, math.rad(spinAngle), 0)
    elseif mode == 2 then
        local amp = math.min(speed * 1.6, 90)
        jx = jx + dt * speed * 12; jy = jy + dt * speed * 22; jz = jz + dt * speed * 9
        local bx, by, bz = math.sin(jx) * amp, math.sin(jy) * amp * 1.8, math.sin(jz) * amp
        local n = (math.random() - 0.5) * amp * 0.6
        hrp.CFrame = hrp.CFrame * CFrame.Angles(math.rad(bx + n), math.rad(by + n), math.rad(bz + n))
    elseif mode == 3 then
        local chance = math.min(0.95, 0.05 * speed)
        if math.random() < chance then
            local s = math.min(speed * 0.5, 12)
            hrp.CFrame = hrp.CFrame + Vector3.new((math.random() - 0.5) * s, 0, (math.random() - 0.5) * s)
        end
    end
end)

local spinAngle2 = 0
RunService.RenderStepped:Connect(function(dt)
    if not settings.antiAim or settings.antiAimMode == 3 then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return end
    local speed = settings.antiAimSpeed
    if settings.antiAimMode == 1 then
        spinAngle2 = (spinAngle2 + dt * speed * 90) % 360
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(spinAngle2), 0)
    elseif settings.antiAimMode == 2 then
        local amp = math.min(speed * 2.2, 120)
        hrp.CFrame = hrp.CFrame * CFrame.Angles(math.rad((math.random() - 0.5) * amp), math.rad((math.random() - 0.5) * amp * 2), math.rad((math.random() - 0.5) * amp))
    end
end)

-- Tracers
local function spawnTracer()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local camera = workspace.CurrentCamera
    if not hrp or not camera then return end
    local tool = char:FindFirstChildOfClass("Tool")
    local muzzle = tool and (tool:FindFirstChild("Muzzle") or tool:FindFirstChild("Handle") or tool:FindFirstChild("Barrel"))
    local startPos
    if muzzle then startPos = muzzle.Position + muzzle.CFrame.LookVector * 1.2
    else
        local right = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
        startPos = right and (right.Position + right.CFrame.LookVector * 1.5) or (hrp.Position + Vector3.new(0, 1.5, 0) + camera.CFrame.LookVector * 2)
    end
    local mouse = LocalPlayer:GetMouse()
    local targetPos = mouse.Hit.Position
    local origin = camera.CFrame.Position
    local dir = targetPos - origin
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = { char }
    params.FilterType = Enum.RaycastFilterType.Exclude
    local res = workspace:Raycast(origin, dir, params)
    if res then targetPos = res.Position end
    local p1 = new("Part", { Anchored = true, CanCollide = false, CanQuery = false, CanTouch = false, Transparency = 1, Size = Vector3.new(0.1, 0.1, 0.1), CFrame = CFrame.new(startPos), Parent = workspace })
    local p2 = new("Part", { Anchored = true, CanCollide = false, CanQuery = false, CanTouch = false, Transparency = 1, Size = Vector3.new(0.1, 0.1, 0.1), CFrame = CFrame.new(targetPos), Parent = workspace })
    local a0 = new("Attachment", { Parent = p1 })
    local a1 = new("Attachment", { Parent = p2 })
    local beam = new("Beam", {
        Attachment0 = a0, Attachment1 = a1,
        Color = ColorSequence.new(COLORS.tracerNeon),
        LightEmission = 1, LightInfluence = 0,
        Width0 = 0.25, Width1 = 0.1, FaceCamera = true,
        Transparency = NumberSequence.new(0.1),
        CurveSize0 = 0, CurveSize1 = 0,
    }, p1)
    task.spawn(function()
        for i = 1, 8 do task.wait(0.03); beam.Transparency = NumberSequence.new(0.1 + i / 8 * 0.9) end
        beam:Destroy(); p1:Destroy(); p2:Destroy()
    end)
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if not settings.tracers then return end
    local isLMB = input.UserInputType == Enum.UserInputType.MouseButton1
    local isPad = input.UserInputType == Enum.UserInputType.Gamepad1 and input.KeyCode == Enum.KeyCode.ButtonR2
    if isLMB or isPad then
        local char = LocalPlayer.Character
        local tool = char and char:FindFirstChildOfClass("Tool")
        if tool then spawnTracer() end
    end
end)

-- ============================================================
-- BUNNY HOP & CS2 STYLE AUTO STRAFE
-- ============================================================
local bunnyState = { wasAir = false, lastJump = 0, currentSpeed = 0, lastLand = 0 }
RunService.Heartbeat:Connect(function(dt)
    if not settings.bunnyHop and not settings.autoStrafe then 
        bunnyState.wasAir = false; bunnyState.currentSpeed = 0; return 
    end
    
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp or hum.Health <= 0 then return end
    
    local state = hum:GetState()
    local now = tick()

    -- CS2 АВТО-СТРЕЙФ (Управление в воздухе)
    if settings.autoStrafe and state == Enum.HumanoidStateType.Freefall then
        local vel = hrp.AssemblyLinearVelocity
        local horizVel = Vector3.new(vel.X, 0, vel.Z)
        local moveDir = hum.MoveDirection
        
        if moveDir.Magnitude > 0.1 then
            local wishDir = Vector3.new(moveDir.X, 0, moveDir.Z).Unit
            
            -- Скорость, которую мы хотим достичь в направлении движения (в КС это AirSpeedCap)
            local wishSpeed = math.max(30, hum.WalkSpeed) 
            
            -- Сколько скорости мы уже имеем в этом направлении
            local currentSpeedInWishDir = horizVel:Dot(wishDir)
            local addSpeed = wishSpeed - currentSpeedInWishDir
            
            -- Если можем добавить скорость
            if addSpeed > 0 then
                local accel = 100 -- Сила воздушного ускорения (влияет на то, как быстро разгоняешься)
                local accelSpeed = math.min(accel * dt, addSpeed)
                horizVel = horizVel + wishDir * accelSpeed
                hrp.AssemblyLinearVelocity = Vector3.new(horizVel.X, vel.Y, horizVel.Z)
            end
        end
    end

    -- BUNNY HOP
    if settings.bunnyHop then
        if state ~= Enum.HumanoidStateType.Freefall and state ~= Enum.HumanoidStateType.Jumping and now - bunnyState.lastLand > 2 then 
            bunnyState.currentSpeed = 0 
        end
        if state == Enum.HumanoidStateType.Freefall then
            bunnyState.wasAir = true
        elseif bunnyState.wasAir and (state == Enum.HumanoidStateType.Landed or state == Enum.HumanoidStateType.Running or state == Enum.HumanoidStateType.RunningNoPhysics) then
            bunnyState.wasAir = false; bunnyState.lastLand = now
            if hum.MoveDirection.Magnitude < 0.1 then return end
            if now - bunnyState.lastJump > 0.15 then
                bunnyState.lastJump = now
                if bunnyState.currentSpeed < 1 then bunnyState.currentSpeed = hum.WalkSpeed end
                local effectiveMax = math.max(settings.bunnyHopMaxSpeed, hum.WalkSpeed)
                bunnyState.currentSpeed = math.min(bunnyState.currentSpeed + settings.bunnyHopAccel, effectiveMax)
                local dir = Vector3.new(hum.MoveDirection.X, 0, hum.MoveDirection.Z).Unit
                local newSpeed = bunnyState.currentSpeed
                task.defer(function()
                    if hum.Health <= 0 then return end
                    hum:ChangeState(Enum.HumanoidStateType.Jumping); task.wait()
                    if hrp.Parent then hrp.AssemblyLinearVelocity = Vector3.new(dir.X * newSpeed, hrp.AssemblyLinearVelocity.y, dir.Z * newSpeed) end
                end)
            end
        end
    end
end)

-- Детектор аймеров
local lastLooks = {}
RunService.Heartbeat:Connect(function(dt)
    if not settings.detectAimers or dt <= 0 then return end
    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local char = p.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local curLook = hrp.CFrame.LookVector
                local prev = lastLooks[char]
                if prev then
                    local dot = math.clamp(prev:Dot(curLook), -1, 1)
                    local rate = math.deg(math.acos(dot)) / dt
                    if rate > 720 then
                        local toMe = myHRP.Position - hrp.Position
                        if toMe.Magnitude > 0.5 then
                            toMe = toMe.Unit
                            if curLook:Dot(toMe) > 0.92 then
                                local now = tick()
                                if not aimerSet[char] or now - aimerSet[char] > 4 then
                                    aimerSet[char] = now
                                    showToast("!! AIMER: " .. p.Name, COLORS.warn)
                                    if settings.autoEscape and toMe.Magnitude < 40 then
                                        myHRP.CFrame = myHRP.CFrame + (-toMe.Unit * 15)
                                    end
                                else aimerSet[char] = now end
                            end
                        end
                    end
                end
                lastLooks[char] = curLook
            end
        end
    end
end)
Players.PlayerRemoving:Connect(function(p)
    if p.Character then lastLooks[p.Character] = nil; aimerSet[p.Character] = nil end
end)

-- Кнопка меню
local openBtn = new("TextButton", { Size = UDim2.new(0, 120, 0, 30), Position = UDim2.new(0, 20, 0, 20), BackgroundColor3 = COLORS.panel, BorderSizePixel = 0, Text = "[ NEVER WIN ]", TextColor3 = COLORS.text, Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = false, ZIndex = 100 }, ScreenGui)
new("UICorner", { CornerRadius = UDim.new(0, 4) }, openBtn)
new("UIStroke", { Color = COLORS.accent, Thickness = 1 }, openBtn)

local function toggleMenu()
    if menuCanvas.Visible and menuCanvas.GroupTransparency == 0 then
        tween(menuCanvas, { GroupTransparency = 1 }, 0.15)
        tween(menuScale, { Scale = 0.9 }, 0.15)
        task.delay(0.15, function() menuCanvas.Visible = false end)
    else
        menuCanvas.Visible = true
        menuCanvas.GroupTransparency = 1
        menuScale.Scale = 0.9
        tween(menuCanvas, { GroupTransparency = 0 }, 0.2)
        tween(menuScale, { Scale = 1 }, 0.25, Enum.EasingStyle.Quint)
    end
end
openBtn.MouseButton1Click:Connect(toggleMenu)

UserInputService.InputBegan:Connect(function(input, processed)
    if input.KeyCode == Enum.KeyCode.RightShift then toggleMenu(); return end
    if bindListening then
        local isKb = input.UserInputType == Enum.UserInputType.Keyboard
        local isMb = isMouseInput(input.UserInputType)
        if isKb or isMb then
            settings.aimBind = { kind = isKb and "keyboard" or "mouse", key = isKb and input.KeyCode or input.UserInputType }
            aimKeyHeld = false; bindButton.Text = "Bind: " .. bindDisplay(settings.aimBind)
            bindListening = false; justBound = true
            task.delay(0.15, function() justBound = false end)
        end
        return
    end
    if tpBindListening then
        local isKb = input.UserInputType == Enum.UserInputType.Keyboard
        local isMb = isMouseInput(input.UserInputType)
        if isKb or isMb then
            settings.tpBind = { kind = isKb and "keyboard" or "mouse", key = isKb and input.KeyCode or input.UserInputType }
            tpBindButton.Text = "TP Bind: " .. bindDisplay(settings.tpBind)
            tpBindListening = false; justBoundTp = true
            task.delay(0.15, function() justBoundTp = false end)
        end
        return
    end
    if triggerBindListening then
        local isKb = input.UserInputType == Enum.UserInputType.Keyboard
        local isMb = isMouseInput(input.UserInputType)
        if isKb or isMb then
            settings.triggerBind = { kind = isKb and "keyboard" or "mouse", key = isKb and input.KeyCode or input.UserInputType }
            triggerBindButton.Text = "Trigger Bind: " .. bindDisplay(settings.triggerBind)
            triggerBindListening = false; justBoundTrigger = true
            task.delay(0.15, function() justBoundTrigger = false end)
        end
        return
    end
    if processed then return end

    if input.UserInputType == Enum.UserInputType.MouseButton3 then
        local isAimMb3 = settings.aimBind.kind == "mouse" and settings.aimBind.key == Enum.UserInputType.MouseButton3
        local isTpMb3 = settings.tpBind.kind == "mouse" and settings.tpBind.key == Enum.UserInputType.MouseButton3
        local isTrigMb3 = settings.triggerBind.kind == "mouse" and settings.triggerBind.key == Enum.UserInputType.MouseButton3
        if not isAimMb3 and not isTpMb3 and not isTrigMb3 and settings.friendToggle then
            local camera = workspace.CurrentCamera
            local center = camera.ViewportSize / 2
            local nearest, dist = nil, 800
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local head = p.Character:FindFirstChild("Head")
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    if head and hum and hum.Health > 0 then
                        local sp, on = camera:WorldToViewportPoint(head.Position)
                        if on and sp.Z > 0 then
                            local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                            if d < dist then dist = d; nearest = p end
                        end
                    end
                end
            end
            if nearest then
                local added = toggleFriend(nearest)
                if added then showToast("+ Friend: " .. nearest.Name, COLORS.success)
                else showToast("- Unfriend: " .. nearest.Name, COLORS.danger) end
            else showToast("No player under crosshair") end
        end
    end

    if matchesBind(input, settings.aimBind) then aimKeyHeld = true end
    if matchesBind(input, settings.triggerBind) then triggerKeyHeld = true end
    if matchesBind(input, settings.tpBind) then
        settings.thirdPerson = not settings.thirdPerson
        local setter = toggleSetters["thirdPerson"]; if setter then setter(settings.thirdPerson) end
        showToast(settings.thirdPerson and "Third Person ON" or "Third Person OFF")
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if matchesBind(input, settings.aimBind) then aimKeyHeld = false end
    if matchesBind(input, settings.triggerBind) then triggerKeyHeld = false end
end)

-- Drag
local dragging, dragStart, startPos = false, nil, nil
topbar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = menuCanvas.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local d = input.Position - dragStart
        menuCanvas.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

task.delay(0.5, toggleMenu)
