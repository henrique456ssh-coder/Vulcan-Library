local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Vulcan = { Version = "1.1.0" }
local HEADER_HEIGHT = 52
local CONTROL_HEIGHT = 40
local CONTROL_GAP = 8
local PANEL_WIDTH = 304
local EDGE_MARGIN = 8
local THEME_ACCENT = Color3.fromRGB(236, 69, 35)
local ROW_COLOR = Color3.fromRGB(19, 10, 11)
local TEXT_COLOR = Color3.fromRGB(255, 225, 207)
local SLIDE = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local BUTTON_FEEDBACK = TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function create(className, parent, properties)
    local instance = Instance.new(className)
    for property, value in pairs(properties) do
        instance[property] = value
    end
    instance.Parent = parent
    return instance
end

local function round(parent, radius)
    create("UICorner", parent, { CornerRadius = UDim.new(0, radius) })
end

local function gradient(parent, rotation, startColor, middleColor, endColor)
    create("UIGradient", parent, {
        Rotation = rotation,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, startColor),
            ColorSequenceKeypoint.new(0.55, middleColor),
            ColorSequenceKeypoint.new(1, endColor),
        }),
    })
end

local function outlineRow(row)
    round(row, 8)
    create("UIStroke", row, {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Thickness = 1,
        Color = Color3.fromRGB(122, 61, 49),
        Transparency = 0.16,
    })
end

local function finite(value)
    return type(value) == "number" and value > -math.huge and value < math.huge
end

local function notify(callback, ...)
    if callback then
        task.spawn(callback, ...)
    end
end

function Vulcan.CreateWindow(options)
    options = options or {}
    assert(type(options) == "table", "CreateWindow espera uma tabela de opções.")
    local title = options.Title or "Vulcan Library"
    local name = options.Name or "VulcanLibrary"
    assert(type(title) == "string" and title ~= "", "Title deve ser um texto.")
    assert(type(name) == "string" and name ~= "", "Name deve ser um texto.")

    local player = Players.LocalPlayer
    assert(player, "Vulcan Library requer o cliente Roblox com um jogador conectado.")
    local playerGui = player:WaitForChild("PlayerGui", 15)
    assert(playerGui, "PlayerGui indisponível. Aguarde o jogo carregar e execute novamente.")
    local previous = playerGui:FindFirstChild(name)
    if previous then
        assert(previous:IsA("ScreenGui") and previous:GetAttribute("VulcanWindow"), "Name já pertence a outra interface.")
        previous:Destroy()
    end

    local gui = create("ScreenGui", nil, {
        Name = name,
        ResetOnSpawn = false,
        DisplayOrder = 10,
    })

    local root = create("Frame", gui, {
        Name = "Viewport",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
    })

    local panel = create("Frame", root, {
        Name = "Panel",
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.fromScale(0.5, 0.42),
        Size = UDim2.new(1, -24, 0, HEADER_HEIGHT),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
    })
    round(panel, 14)
    create("UISizeConstraint", panel, { MaxSize = Vector2.new(PANEL_WIDTH, 100000) })
    gradient(panel, 28, Color3.fromRGB(24, 12, 12), Color3.fromRGB(55, 20, 16), Color3.fromRGB(139, 42, 18))

    local outline = create("UIStroke", panel, { Thickness = 1, Color = Color3.new(1, 1, 1) })
    gradient(outline, 25, Color3.fromRGB(149, 71, 50), Color3.fromRGB(106, 44, 31), Color3.fromRGB(255, 132, 62))

    local header = create("Frame", panel, {
        Name = "Header",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, HEADER_HEIGHT),
    })

    local emblem = create("Frame", header, {
        Name = "Ember",
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 12, 0.5, 0),
        Size = UDim2.fromOffset(28, 28),
        BackgroundColor3 = Color3.fromRGB(107, 43, 28),
        BorderSizePixel = 0,
    })
    round(emblem, 8)

    local ember = create("Frame", emblem, {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(11, 11),
        Rotation = 45,
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
    })
    round(ember, 3)
    gradient(ember, 65, Color3.fromRGB(255, 220, 148), Color3.fromRGB(255, 153, 65), THEME_ACCENT)

    local titleLabel = create("TextLabel", header, {
        Name = "Title",
        Position = UDim2.fromOffset(49, 0),
        Size = UDim2.new(1, -141, 1, 0),
        BackgroundTransparency = 1,
        Text = title,
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        TextColor3 = Color3.fromRGB(255, 244, 234),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })

    local dragHandle = create("Frame", header, {
        Name = "AreaDeArraste",
        Size = UDim2.new(1, -88, 1, 0),
        BackgroundTransparency = 1,
        Active = true,
        ZIndex = 2,
    })

    local function windowButton(name, rightOffset, color)
        local button = create("TextButton", header, {
            Name = name,
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, rightOffset, 0.5, 0),
            Size = UDim2.fromOffset(40, 42),
            Text = "",
            BackgroundTransparency = 1,
            AutoButtonColor = false,
        })
        local surface = create("Frame", button, {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(30, 30),
            BackgroundColor3 = color,
            BorderSizePixel = 0,
        })
        round(surface, 8)
        return button, surface
    end

    local function iconLine(parent, rotation)
        local line = create("Frame", parent, {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(11, 2),
            Rotation = rotation,
            BackgroundColor3 = Color3.fromRGB(255, 226, 206),
            BorderSizePixel = 0,
        })
        round(line, 1)
        return line
    end

    local minimize, minimizeSurface = windowButton("Minimizar", -45, Color3.fromRGB(92, 48, 38))
    iconLine(minimizeSurface, 0)
    local restoreLine = iconLine(minimizeSurface, 90)
    restoreLine.Visible = false

    local close, closeSurface = windowButton("Fechar", -5, Color3.fromRGB(139, 51, 34))
    iconLine(closeSurface, 45)
    iconLine(closeSurface, -45)

    gui:SetAttribute("VulcanWindow", true)
    local body = create("ScrollingFrame", panel, {
        Name = "Controls",
        Position = UDim2.fromOffset(12, HEADER_HEIGHT),
        Size = UDim2.new(1, -24, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.fromOffset(0, 0),
        CanvasPosition = Vector2.new(0, 0),
        ScrollBarImageColor3 = Color3.fromRGB(149, 84, 69),
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Visible = false,
    })

    local window = {}
    local expanded = true
    local disposed = false
    local rowCount = 0
    local drag

    local function stopDrag(closing)
        local current = drag
        if not current then
            return
        end
        drag = nil
        current.stateChanged:Disconnect()
        if current.finish and not closing then
            current.finish()
        end
    end

    local function placePanel(x, y)
        local viewport = root.AbsoluteSize
        if viewport.X <= 0 or viewport.Y <= 0 then
            return
        end
        local width = math.min(PANEL_WIDTH, math.max(1, viewport.X - 24))
        local height = panel.Size.Y.Offset
        local left = math.min(viewport.X / 2, width / 2 + EDGE_MARGIN)
        local top = math.min(EDGE_MARGIN, math.max(0, (viewport.Y - height) / 2))
        local bottom = math.max(top, viewport.Y - height - top)
        panel.Position = UDim2.fromScale(
            math.clamp(x, left, viewport.X - left) / viewport.X,
            math.clamp(y, top, bottom) / viewport.Y
        )
    end

    local function resize()
        local viewport = root.AbsoluteSize
        local canvasHeight = math.max(0, rowCount * (CONTROL_HEIGHT + CONTROL_GAP) - CONTROL_GAP + 2)
        local available = viewport.Y > 0 and math.max(0, viewport.Y - HEADER_HEIGHT - 24) or canvasHeight
        local bodyHeight = expanded and math.min(canvasHeight, available) or 0
        local overflow = canvasHeight > bodyHeight
        body.Visible = bodyHeight > 0
        body.ScrollBarThickness = overflow and 3 or 0
        body.Size = UDim2.new(1, -24, 0, bodyHeight)
        body.CanvasSize = UDim2.fromOffset(0, canvasHeight)
        if bodyHeight > 0 then
            body.CanvasPosition = Vector2.new(0, math.clamp(body.CanvasPosition.Y, 0, canvasHeight - bodyHeight))
        end
        panel.Size = UDim2.new(1, -24, 0, HEADER_HEIGHT + bodyHeight + (bodyHeight > 0 and 12 or 0))
        local anchor = panel.Position
        placePanel(viewport.X * anchor.X.Scale, viewport.Y * anchor.Y.Scale)
    end

    local function addRow(className, name)
        assert(not disposed, "Esta janela já foi fechada.")
        stopDrag()
        local row = create(className, body, {
            Name = name,
            Position = UDim2.fromOffset(0, 1 + rowCount * (CONTROL_HEIGHT + CONTROL_GAP)),
            Size = UDim2.new(1, -5, 0, CONTROL_HEIGHT),
            BackgroundColor3 = ROW_COLOR,
            BackgroundTransparency = 0.29,
            BorderSizePixel = 0,
        })
        outlineRow(row)
        rowCount = rowCount + 1
        resize()
        return row
    end

    local function label(parent, text, position, size, textSize, alignment)
        return create("TextLabel", parent, {
            Text = text,
            Position = position,
            Size = size,
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamMedium,
            TextSize = textSize,
            TextColor3 = TEXT_COLOR,
            TextXAlignment = alignment,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Active = false,
        })
    end

    local function beginDrag(input, move, finish)
        local kind = input.UserInputType
        if drag or (kind ~= Enum.UserInputType.MouseButton1 and kind ~= Enum.UserInputType.Touch) then
            return false
        end
        local current = {
            input = input,
            isMouse = kind == Enum.UserInputType.MouseButton1,
            move = move,
            finish = finish,
        }
        drag = current
        current.stateChanged = input:GetPropertyChangedSignal("UserInputState"):Connect(function()
            if drag == current and input.UserInputState == Enum.UserInputState.Cancel then
                stopDrag()
            end
        end)
        return true
    end

    dragHandle.InputBegan:Connect(function(input)
        local viewport = root.AbsoluteSize
        if viewport.X <= 0 or viewport.Y <= 0 then
            return
        end
        local start = input.Position
        local anchor = panel.Position
        local x = viewport.X * anchor.X.Scale
        local y = viewport.Y * anchor.Y.Scale
        beginDrag(input, function(pointer)
            placePanel(x + pointer.X - start.X, y + pointer.Y - start.Y)
        end)
    end)

    function window:AddToggle(config)
        config = config or {}
        local text = config.Text or "Toggle"
        assert(type(text) == "string", "Text deve ser um texto.")
        assert(config.Default == nil or type(config.Default) == "boolean", "Default deve ser booleano.")
        assert(config.Callback == nil or type(config.Callback) == "function", "Callback deve ser uma função.")
        local row = addRow("Frame", "Toggle")
        label(row, text, UDim2.fromOffset(12, 0), UDim2.new(1, -76, 1, 0), 14, Enum.TextXAlignment.Left)
        local hit = create("TextButton", row, {
            Name = "Switch",
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.fromScale(1, 0.5),
            Size = UDim2.fromOffset(60, CONTROL_HEIGHT),
            Text = "",
            BackgroundTransparency = 1,
            AutoButtonColor = false,
        })
        local offColor = Color3.fromRGB(43, 34, 36)
        local offThumb = Color3.fromRGB(111, 92, 96)
        local onThumb = Color3.fromRGB(255, 232, 221)
        local value = config.Default == true
        local track = create("Frame", hit, {
            Name = "Track",
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(42, 22),
            BackgroundColor3 = value and THEME_ACCENT or offColor,
            BorderSizePixel = 0,
        })
        round(track, 11)
        local offPosition = UDim2.new(0, 11, 0.5, 0)
        local onPosition = UDim2.new(1, -11, 0.5, 0)
        local thumb = create("Frame", track, {
            Name = "Thumb",
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = value and onPosition or offPosition,
            Size = UDim2.fromOffset(16, 16),
            BackgroundColor3 = value and onThumb or offThumb,
            BorderSizePixel = 0,
        })
        round(thumb, 8)

        local control = {}
        function control:Get()
            return value
        end
        function control:Set(nextValue, silent)
            assert(type(nextValue) == "boolean", "Toggle:Set espera um booleano.")
            if disposed or nextValue == value then
                return
            end
            value = nextValue
            TweenService:Create(track, SLIDE, { BackgroundColor3 = value and THEME_ACCENT or offColor }):Play()
            TweenService:Create(thumb, SLIDE, {
                Position = value and onPosition or offPosition,
                BackgroundColor3 = value and onThumb or offThumb,
            }):Play()
            if not silent then
                notify(config.Callback, value)
            end
        end
        hit.Activated:Connect(function()
            control:Set(not value)
        end)
        return control
    end

    function window:AddButton(config)
        config = config or {}
        local text = config.Text or "Botão"
        assert(type(text) == "string", "Text deve ser um texto.")
        assert(config.Callback == nil or type(config.Callback) == "function", "Callback deve ser uma função.")
        local row = addRow("TextButton", "Button")
        row.Text = ""
        row.AutoButtonColor = false
        label(row, text, UDim2.fromOffset(12, 0), UDim2.new(1, -52, 1, 0), 14, Enum.TextXAlignment.Left)
        create("ImageLabel", row, {
            Name = "Fingerprint",
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -12, 0.5, 0),
            Size = UDim2.fromOffset(18, 18),
            BackgroundTransparency = 1,
            Image = "rbxassetid://10723375250",
            ImageColor3 = Color3.fromRGB(255, 179, 144),
            Active = false,
        })
        row.Activated:Connect(function()
            row.BackgroundColor3 = Color3.fromRGB(103, 42, 29)
            TweenService:Create(row, BUTTON_FEEDBACK, { BackgroundColor3 = ROW_COLOR }):Play()
            notify(config.Callback)
        end)
        return row
    end

    function window:AddSlider(config)
        config = config or {}
        local text = config.Text or "Slider"
        local minimum, maximum = config.Min or 0, config.Max or 20
        assert(type(text) == "string", "Text deve ser um texto.")
        assert(finite(minimum) and finite(maximum) and maximum > minimum, "Min e Max devem formar um intervalo válido.")
        assert(config.Default == nil or finite(config.Default), "Default deve ser um número finito.")
        assert(config.Callback == nil or type(config.Callback) == "function", "Callback deve ser uma função.")
        assert(config.Format == nil or type(config.Format) == "function", "Format deve ser uma função.")
        local range = maximum - minimum
        local step = config.Step or math.min(1, range)
        assert(finite(range) and finite(step) and step > 0 and step <= range and finite(range / step),
            "Step deve ser positivo e caber no intervalo.")
        local function quantize(input)
            local value = math.clamp(input, minimum, maximum)
            if value == maximum then
                return maximum
            end
            return math.clamp(minimum + math.floor((value - minimum) / step + 0.5) * step, minimum, maximum)
        end

        local row = addRow("Frame", "Slider")
        label(row, text, UDim2.fromOffset(12, 2), UDim2.new(1, -24, 0, 14), 12, Enum.TextXAlignment.Left)
        local track = create("Frame", row, {
            Name = "Track",
            Position = UDim2.fromOffset(12, 18),
            Size = UDim2.new(1, -24, 0, 17),
            BackgroundColor3 = Color3.fromRGB(43, 29, 30),
            BorderSizePixel = 0,
        })
        round(track, 4)
        create("UIStroke", track, { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Thickness = 1,
            Color = Color3.fromRGB(149, 84, 69), Transparency = 0.1 })
        local travel = create("Frame", track, {
            Name = "Travel",
            Position = UDim2.fromOffset(8, 0),
            Size = UDim2.new(1, -85, 1, 0),
            BackgroundTransparency = 1,
        })
        local fill = create("Frame", travel, {
            Name = "Fill",
            Position = UDim2.fromOffset(-8, 0),
            BackgroundColor3 = THEME_ACCENT,
            BackgroundTransparency = 0.68,
            BorderSizePixel = 0,
        })
        round(fill, 4)
        local thumb = create("Frame", travel, {
            Name = "Thumb",
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size = UDim2.fromOffset(13, 13),
            BackgroundColor3 = Color3.fromRGB(255, 148, 102),
            BackgroundTransparency = 0.08,
            BorderSizePixel = 0,
            ZIndex = 2,
        })
        round(thumb, 2)
        local valueLabel = label(track, "", UDim2.new(1, -7, 0.5, 0), UDim2.fromOffset(62, 17),
            10, Enum.TextXAlignment.Right)
        valueLabel.Name = "Value"
        valueLabel.AnchorPoint = Vector2.new(1, 0.5)
        valueLabel.ZIndex = 2
        local hit = create("Frame", row, {
            Name = "Input",
            Position = UDim2.fromOffset(12, 16),
            Size = UDim2.new(1, -24, 1, -16),
            BackgroundTransparency = 1,
            Active = true,
            ZIndex = 3,
        })

        local value = quantize(config.Default or minimum)
        local thumbFade
        local function fraction()
            return (value - minimum) / range
        end
        local function draw(position)
            fill.Visible = position > 0
            fill.Size = UDim2.new(position, 8, 1, 0)
            thumb.Position = UDim2.fromScale(position, 0.5)
            local rendered = string.format("%g", value)
            if config.Format then
                local ok, formatted = pcall(config.Format, value)
                if ok and formatted ~= nil then
                    rendered = tostring(formatted)
                end
            end
            valueLabel.Text = rendered
        end
        draw(fraction())

        local function change(nextValue, silent, position)
            local resolved = quantize(nextValue)
            local changed = value ~= resolved
            value = resolved
            draw(position or fraction())
            if changed and not silent then
                notify(config.Callback, value)
            end
        end

        local control = {}
        function control:Get()
            return value
        end
        function control:Set(nextValue, silent)
            assert(finite(nextValue), "Slider:Set espera um número finito.")
            if not disposed then
                change(nextValue, silent)
            end
        end

        hit.InputBegan:Connect(function(input)
            local width = travel.AbsoluteSize.X
            if width <= 0 then
                return
            end
            local tap = input.Position
            local origin = fraction()
            local startX = travel.AbsolutePosition.X
            local touch = input.UserInputType == Enum.UserInputType.Touch
            local active = false
            local function move(pointer, ended)
                if not active then
                    if touch then
                        local dx, dy = math.abs(pointer.X - tap.X), math.abs(pointer.Y - tap.Y)
                        if dy >= 7 and dy > dx then
                            stopDrag()
                            return
                        end
                        if dx < 7 and not ended then
                            return
                        end
                    end
                    active = true
                    body.ScrollingEnabled = false
                end
                local position = math.clamp((pointer.X - startX) / width, 0, 1)
                change(minimum + position * range, false, position)
                thumb.BackgroundTransparency = 0.08 + 0.55 * math.abs(position - origin)
            end
            local function finish()
                if active then
                    body.ScrollingEnabled = true
                    draw(fraction())
                    thumbFade = TweenService:Create(thumb, SLIDE, { BackgroundTransparency = 0.08 })
                    thumbFade:Play()
                end
            end
            if beginDrag(input, move, finish) then
                if thumbFade then
                    thumbFade:Cancel()
                    thumbFade = nil
                end
                move(tap, false)
            end
        end)
        return control
    end

    local moved = UserInputService.InputChanged:Connect(function(input)
        local active = drag
        if active and ((active.isMouse and input.UserInputType == Enum.UserInputType.MouseMovement)
            or (not active.isMouse and input == active.input)) then
            active.move(input.Position, false)
        end
    end)
    local ended = UserInputService.InputEnded:Connect(function(input)
        local active = drag
        if active and (input == active.input or (active.isMouse and input.UserInputType == Enum.UserInputType.MouseButton1)) then
            if input.UserInputState ~= Enum.UserInputState.Cancel then
                active.move(input.Position, true)
            end
            stopDrag()
        end
    end)
    local focusLost = UserInputService.WindowFocusReleased:Connect(stopDrag)
    root:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        stopDrag()
        resize()
    end)
    gui.Destroying:Connect(function()
        disposed = true
        stopDrag(true)
        moved:Disconnect()
        ended:Disconnect()
        focusLost:Disconnect()
    end)

    function window:SetTitle(nextTitle)
        assert(type(nextTitle) == "string" and nextTitle ~= "", "SetTitle espera um texto.")
        if not disposed then
            titleLabel.Text = nextTitle
        end
    end

    function window:SetVisible(visible)
        assert(type(visible) == "boolean", "SetVisible espera um booleano.")
        if not disposed then
            stopDrag()
            gui.Enabled = visible
        end
    end

    function window:SetMinimized(minimized)
        assert(type(minimized) == "boolean", "SetMinimized espera um booleano.")
        if disposed then
            return
        end
        stopDrag()
        expanded = not minimized
        restoreLine.Visible = minimized
        minimize.Name = minimized and "Restaurar" or "Minimizar"
        resize()
    end

    function window:Destroy()
        if not disposed then
            gui:Destroy()
        end
    end

    minimize.Activated:Connect(function()
        window:SetMinimized(expanded)
    end)
    close.Activated:Connect(function()
        window:Destroy()
    end)

    gui.Parent = playerGui
    resize()
    return window
end

return Vulcan
