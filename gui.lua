local mainapi = {
    MainColor = Color3.fromRGB(12, 232, 199),
    SecondaryColor = Color3.fromRGB(12, 163, 232),
    Themes = {
        Aubergine = {Color3.fromRGB(170, 7, 107), Color3.fromRGB(97, 4, 95)},
        Aqua = {Color3.fromRGB(185, 250, 255), Color3.fromRGB(79, 199, 200)},
        Banana = {Color3.fromRGB(253, 236, 177), Color3.fromRGB(255, 255, 255)},
        Blend = {Color3.fromRGB(71, 148, 253), Color3.fromRGB(71, 253, 160)},
        Blossom = {Color3.fromRGB(226, 208, 249), Color3.fromRGB(49, 119, 115)},
        Bubblegum = {Color3.fromRGB(243, 145, 216), Color3.fromRGB(152, 165, 243)},
        ["Candy Cane"] = {Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 255, 255)},
        Cherry = {Color3.fromRGB(187, 55, 125), Color3.fromRGB(251, 211, 233)},
        Christmas = {Color3.fromRGB(255, 64, 64), Color3.fromRGB(255, 255, 255), Color3.fromRGB(64, 255, 64)},
        Coral = {Color3.fromRGB(244, 168, 150), Color3.fromRGB(52, 133, 151)},
        ["Digital Horizon"] = {Color3.fromRGB(95, 195, 228), Color3.fromRGB(229, 93, 135)},
        Express = {Color3.fromRGB(173, 83, 137), Color3.fromRGB(60, 16, 83)},
        ["Lime Water"] = {Color3.fromRGB(18, 255, 247), Color3.fromRGB(179, 255, 171)},
        Lush = {Color3.fromRGB(168, 224, 99), Color3.fromRGB(86, 171, 47)},
        Halogen = {Color3.fromRGB(255, 65, 108), Color3.fromRGB(255, 75, 43)},
        Hyper = {Color3.fromRGB(236, 110, 173), Color3.fromRGB(52, 148, 230)},
        Magic = {Color3.fromRGB(74, 0, 224), Color3.fromRGB(142, 45, 226)},
        May = {Color3.fromRGB(170, 7, 107), Color3.fromRGB(238, 79, 238)},
        ["Orange Juice"] = {Color3.fromRGB(252, 74, 26), Color3.fromRGB(247, 183, 51)},
        Pastel = {Color3.fromRGB(243, 155, 178), Color3.fromRGB(207, 196, 243)},
        Pumpkin = {Color3.fromRGB(241, 166, 98), Color3.fromRGB(255, 216, 169), Color3.fromRGB(227, 139, 42)},
        Satin = {Color3.fromRGB(215, 60, 67), Color3.fromRGB(140, 23, 39)},
        ["Snowy Sky"] = {Color3.fromRGB(1, 171, 179), Color3.fromRGB(234, 234, 234), Color3.fromRGB(18, 232, 232)},
        ["Steel Fade"] = {Color3.fromRGB(66, 134, 244), Color3.fromRGB(55, 59, 68)},       
        Sundae = {Color3.fromRGB(206, 74, 126), Color3.fromRGB(122, 44, 77)},
        Sunkist = {Color3.fromRGB(242, 201, 76), Color3.fromRGB(242, 153, 74)},
        Water = {Color3.fromRGB(12, 232, 199), Color3.fromRGB(12, 163, 232)},
        Winter = {Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 255, 255)},
        Wood = {Color3.fromRGB(79, 109, 81), Color3.fromRGB(170, 139, 87), Color3.fromRGB(240, 235, 206)}
    },
    Targets = {},
    Categories = {},
    Modules = {},
    Fonts = {},
    Visible = false,
    Loaded = false,
    Settings = {
        bkg = true,
        lowercase = false,
        suffix = true,
        spaces = true,
        notifs = true,
        sidebar = true,
        mode = "Exclude render",
        targetinfofollow = false,
        targetinfoenabled = false
    },
    Interface = {}
}
local tweenService = game:GetService("TweenService")
local inputService = game:GetService("UserInputService")
local textService = game:GetService("TextService")
local isfile = isfile or function(file)
	local suc, res = pcall(function() return readfile(file) end)
	return suc and res ~= nil
end
local getcustomasset = getsynasset or getcustomasset or function(location) return "rbxasset://"..location end
local inputConnection
local lastSelected
local guiTween
local gameCamera = workspace.CurrentCamera

local function loadFonts()
    writefile("risesix/fonts/productsans.json", game:GetService("HttpService"):JSONEncode({
        name = "ProductSans",
        faces = {
            {
                name = "Light",
                weight = 300,
                style = "normal",
                assetId = getcustomasset("risesix/fonts/product_sans_light.ttf")
            },
            {
                name = "Regular",
                weight = 400,
                style = "normal",
                assetId = getcustomasset("risesix/fonts/product_sans_regular.ttf")
            },
            {
                name = "Medium",
                weight = 500,
                style = "normal",
                assetId = getcustomasset("risesix/fonts/product_sans_medium.ttf")
            },
            {
                name = "Icon1",
                weight = 600,
                style = "normal",
                assetId = getcustomasset("risesix/fonts/Icon-1.ttf")
            },
            {
                name = "Icon2",
                weight = 700,
                style = "normal",
                assetId = getcustomasset("risesix/fonts/Icon-2.ttf")
            },
            {
                name = "Icon3",
                weight = 800,
                style = "normal",
                assetId = getcustomasset("risesix/fonts/Icon-3.ttf")
            }
        }
    }))
    mainapi.Fonts.RiseIcon1 = Font.new(getcustomasset("risesix/fonts/productsans.json"), Enum.FontWeight.SemiBold)
    mainapi.Fonts.RiseIcon2 = Font.new(getcustomasset("risesix/fonts/productsans.json"), Enum.FontWeight.Bold)
    mainapi.Fonts.RiseIcon3 = Font.new(getcustomasset("risesix/fonts/productsans.json"), Enum.FontWeight.ExtraBold)
    mainapi.Fonts.ProductSans = Font.new(getcustomasset("risesix/fonts/productsans.json"), Enum.FontWeight.Regular)
    mainapi.Fonts.ProductSansMedium = Font.new(getcustomasset("risesix/fonts/productsans.json"), Enum.FontWeight.Medium)
    mainapi.Fonts.ProductSansLight = Font.new(getcustomasset("risesix/fonts/productsans.json"), Enum.FontWeight.Light)
end
loadFonts()


local gui = Instance.new("ScreenGui")
gui.Name = "rise"
gui.DisplayOrder = 999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.OnTopOfCoreBlur = true
if gethui and (not KRNL_LOADED) then
    gui.Parent = gethui()
elseif not is_sirhurt_closure and syn and syn.protect_gui then
    syn.protect_gui(gui)
    gui.Parent = game:GetService("CoreGui")
else
    gui.Parent = game:GetService("CoreGui")
end
mainapi.gui = gui

local watermark = Instance.new("TextLabel")
watermark.Position = UDim2.fromOffset(12, 5)
watermark.Size = UDim2.fromOffset(70, 40)
watermark.BackgroundTransparency = 1
watermark.Text = "Rise"
watermark.TextColor3 = mainapi.MainColor
watermark.TextSize = 43
watermark.TextXAlignment = Enum.TextXAlignment.Left
watermark.TextYAlignment = Enum.TextYAlignment.Top
watermark.FontFace = mainapi.Fonts.ProductSansMedium
watermark.Visible = false
watermark.Parent = gui
table.insert(mainapi.Interface, watermark)

local textguilines = {}
local textgui = Instance.new("Frame")
textgui.Size = UDim2.fromOffset(100, 100)
textgui.Position = UDim2.new(1, -15, 0, 15)
textgui.AnchorPoint = Vector2.new(1, 0)
textgui.BackgroundTransparency = 1
textgui.Visible = false
textgui.Parent = gui
table.insert(mainapi.Interface, textgui)
local textguilist = Instance.new("UIListLayout")
textguilist.FillDirection = Enum.FillDirection.Vertical
textguilist.HorizontalAlignment = Enum.HorizontalAlignment.Right
textguilist.VerticalAlignment = Enum.VerticalAlignment.Top
textguilist.SortOrder = Enum.SortOrder.LayoutOrder
textguilist.Parent = textgui

local function getBlendFactor(vec)
	return math.sin(DateTime.now().UnixTimestampMillis / 600 + vec.X * 0.005 + vec.Y * 0.06) * 0.5 + 0.5
end

function mainapi:getAccentColor(vec)
    local blend = getBlendFactor(vec)
    if mainapi.ThirdColor then 
        if blend <= 0.5 then
            return mainapi.MainColor:Lerp(mainapi.SecondaryColor, blend * 2)
        end
        return mainapi.SecondaryColor:Lerp(mainapi.ThirdColor, (blend - 0.5) * 2)
    end
	return mainapi.SecondaryColor:Lerp(mainapi.MainColor, blend)
end

local tweens = {}
function mainapi:UpdateTextGUI()
    local alreadyExisted = {}
    for i, v in pairs(textguilines) do
        if v.Enabled then 
            alreadyExisted[v.Object.Name] = true
            v.Object:Destroy() 
        end
    end
    table.clear(textguilines)
    for i, v in pairs(mainapi.Modules) do 
        if mainapi.Settings.mode == "Exclude render" then 
            if v.Category == "Render" then continue end
        elseif mainapi.Settings.mode == "Only bound" then 
            if v.Bind == "" then continue end
        end
        if (v.Enabled or alreadyExisted[i]) then 
            local textguipos = Instance.new("Frame")
            textguipos.Size = UDim2.fromOffset(0, 22)
            textguipos.BorderSizePixel = 0
            textguipos.Name = i
            textguipos.BackgroundTransparency = 0.5
            textguipos.BackgroundColor3 = Color3.new()
            textguipos.Parent = textgui
            local textguientry = Instance.new("Frame")
            local sizestr = (mainapi.Settings.spaces and i or ({i:gsub(" ", "")})[1])..(v.ExtraText and mainapi.Settings.suffix and " "..v.ExtraText() or "")
            if mainapi.Settings.lowercase then 
                sizestr = sizestr:lower()
            end
            textguientry.Size = UDim2.fromOffset(mainapi:GetTextSize(sizestr, 21, mainapi.Fonts.ProductSans).X + (v.ExtraText and 10 or 8), 22)
            textguientry.Position = UDim2.fromOffset(-textguientry.Size.X.Offset, 0)
            textguientry.BorderSizePixel = 0
            textguientry.BackgroundTransparency = mainapi.Settings.bkg and 0.5 or 1
            textguientry.BackgroundColor3 = Color3.new()
            textguientry.Parent = textguipos
            local textguientrytext = Instance.new("TextLabel")
            textguientrytext.Size = UDim2.fromScale(1, 1)
            textguientrytext.Position = UDim2.fromOffset(v.ExtraText and -6 or -4, 0)
            textguientrytext.BackgroundTransparency = 1
            textguientrytext.RichText = true
            textguientrytext.BackgroundColor3 = Color3.new()
            textguientrytext.Text = (mainapi.Settings.spaces and i or ({i:gsub(" ", "")})[1])..(v.ExtraText and mainapi.Settings.suffix and " <font color='rgb(200, 200, 200)'>"..v.ExtraText().."</font>" or "")
            if mainapi.Settings.lowercase then 
                textguientrytext.Text = textguientrytext.Text:lower()
            end
            textguientrytext.TextColor3 = Color3.new(1, 1, 1)
            textguientrytext.TextSize = 21
            textguientrytext.TextXAlignment = Enum.TextXAlignment.Right
            textguientrytext.TextYAlignment = Enum.TextYAlignment.Top
            textguientrytext.FontFace = mainapi.Fonts.ProductSans
            textguientrytext.Parent = textguientry
            local textguientryline = Instance.new("Frame")
            textguientryline.Position = UDim2.new(1, -1, 0, 2)
            textguientryline.Size = UDim2.fromOffset(4, 18)
            textguientryline.BackgroundTransparency = mainapi.Settings.sidebar and 0 or 1
            textguientryline.ZIndex = -1
            textguientryline.Parent = textguientry
            local textguientrylinecorner = Instance.new("UICorner")
            textguientrylinecorner.CornerRadius = UDim.new(1, 0)
            textguientrylinecorner.Parent = textguientryline
            if not alreadyExisted[i] then 
                if tweens[textguientry] then tweens[textguientry]:Cancel() end
                if tweens[textguipos] then tweens[textguipos]:Cancel() end
                textguientry.Position = UDim2.fromOffset(15, 0)
                textguipos.Size = UDim2.fromOffset(0, 0)
                tweens[textguipos] = tweenService:Create(textguipos, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Size = UDim2.fromOffset(0, 22)})
                tweens[textguipos].Completed:Connect(function()
                    tweens[textguipos] = nil
                end)
                tweens[textguipos]:Play()
                tweens[textguientry] = tweenService:Create(textguientry, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Position = UDim2.fromOffset(-textguientry.Size.X.Offset, 0)})
                tweens[textguientry].Completed:Connect(function()
                    tweens[textguientry] = nil
                end)
                tweens[textguientry]:Play()
            end
            if not v.Enabled then 
                if tweens[textguientry] then tweens[textguientry]:Cancel() end
                if tweens[textguipos] then tweens[textguipos]:Cancel() end
                tweens[textguipos] = tweenService:Create(textguipos, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Size = UDim2.fromOffset(0, 0)})
                tweens[textguipos].Completed:Connect(function()
                    tweens[textguipos] = nil
                end)
                tweens[textguipos]:Play()
                tweens[textguientry] = tweenService:Create(textguientry, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Position = UDim2.fromOffset(15, 0)})
                tweens[textguientry].Completed:Connect(function()
                    tweens[textguientry] = nil
                end)
                tweens[textguientry]:Play()
            end
            table.insert(textguilines, {Object = textguipos, Text = textguientrytext, Line = textguientryline, Enabled = v.Enabled})
        end
    end
    table.sort(textguilines, function(a, b) return a.Object.Frame.Size.X.Offset > b.Object.Frame.Size.X.Offset end)
    for i, v in pairs(textguilines) do v.Object.LayoutOrder = i end
    for i, v in pairs(textguilines) do 
        v.Text.TextColor3 = mainapi:getAccentColor(v.Text.AbsolutePosition / 2)
        v.Line.BackgroundColor3 = v.Text.TextColor3
    end
end

local function darkerColor(col, amount)
    local h, s, v = col:ToHSV()
    return Color3.fromHSV(h, s, math.max(0, v - (amount or 0.5)))
end

local targetinfo = Instance.new("Frame")
targetinfo.Size = UDim2.fromOffset(295, 95)
targetinfo.Position = UDim2.new(0.5, 0, 0.5, 95)
targetinfo.BackgroundTransparency = 0.5
targetinfo.AnchorPoint = Vector2.new(0.5, 0.5)
targetinfo.Parent = gui
mainapi.TargetInfo = targetinfo
local targetinfoscale = Instance.new("UIScale")
targetinfoscale.Scale = 0
targetinfoscale.Parent = targetinfo
local targetinfocorner = Instance.new("UICorner")
targetinfocorner.CornerRadius = UDim.new(0, 30)
targetinfocorner.Parent = targetinfo
local targetinfogradient = Instance.new("UIGradient")
targetinfogradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, darkerColor(mainapi.MainColor)), ColorSequenceKeypoint.new(1, darkerColor(mainapi.SecondaryColor))})
targetinfogradient.Rotation = 90
targetinfogradient.Parent = targetinfo
local targetinfoextratext = Instance.new("TextLabel")
targetinfoextratext.Size = UDim2.fromOffset(60, 30)
targetinfoextratext.Position = UDim2.fromOffset(95, 21)
targetinfoextratext.BackgroundTransparency = 1
targetinfoextratext.Text = "Name:"
targetinfoextratext.TextColor3 = Color3.new(1, 1, 1)
targetinfoextratext.TextSize = 26
targetinfoextratext.TextXAlignment = Enum.TextXAlignment.Left
targetinfoextratext.FontFace = mainapi.Fonts.ProductSansLight
targetinfoextratext.Parent = targetinfo
local targetinfoname = Instance.new("TextLabel")
targetinfoname.Size = UDim2.fromOffset(60, 30)
targetinfoname.Position = UDim2.fromOffset(163, 22)
targetinfoname.BackgroundTransparency = 1
targetinfoname.Text = "Rise"
targetinfoname.TextColor3 = mainapi.MainColor
targetinfoname.TextSize = 26
targetinfoname.TextXAlignment = Enum.TextXAlignment.Left
targetinfoname.FontFace = mainapi.Fonts.ProductSans
targetinfoname.Parent = targetinfo
local targetinfoimage = Instance.new("ImageLabel")
targetinfoimage.Size = UDim2.fromOffset(64, 64)
targetinfoimage.Position = UDim2.new(0, 48, 0.5, 1)
targetinfoimage.BackgroundTransparency = 1
targetinfoimage.Image = 'rbxthumb://type=AvatarHeadShot&id=1&w=420&h=420'
targetinfoimage.AnchorPoint = Vector2.new(0.5, 0.5)
targetinfoimage.Parent = targetinfo
local targetinfoimagecorner = Instance.new("UICorner")
targetinfoimagecorner.CornerRadius = UDim.new(0, 14)
targetinfoimagecorner.Parent = targetinfoimage
local targetinfohealthbkg = Instance.new("Frame")
targetinfohealthbkg.Size = UDim2.fromOffset(130, 12)
targetinfohealthbkg.Position = UDim2.fromOffset(94, 58)
targetinfohealthbkg.BackgroundColor3 = darkerColor(mainapi.MainColor)
targetinfohealthbkg.BackgroundTransparency = 0.5
targetinfohealthbkg.Parent = targetinfo
local targetinfohealthbkgcorner = Instance.new("UICorner")
targetinfohealthbkgcorner.CornerRadius = UDim.new(0, 10)
targetinfohealthbkgcorner.Parent = targetinfohealthbkg
local targetinfohealth = Instance.new("Frame")
targetinfohealth.Size = UDim2.fromScale(1, 1)
targetinfohealth.BorderSizePixel = 0
targetinfohealth.BackgroundColor3 = Color3.new(1, 1, 1)
targetinfohealth.Parent = targetinfohealthbkg
local targetinfohealthcorner = Instance.new("UICorner")
targetinfohealthcorner.CornerRadius = UDim.new(0, 10)
targetinfohealthcorner.Parent = targetinfohealth
local targetinfohealthgradient = Instance.new("UIGradient")
targetinfohealthgradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, mainapi.MainColor), ColorSequenceKeypoint.new(1, mainapi.SecondaryColor)})
targetinfohealthgradient.Rotation = 90
targetinfohealthgradient.Parent = targetinfohealth
local targetinfohealthtext = Instance.new("TextLabel")
targetinfohealthtext.Size = UDim2.fromOffset(60, 30)
targetinfohealthtext.Position = UDim2.fromOffset(233, 49)
targetinfohealthtext.BackgroundTransparency = 1
targetinfohealthtext.Text = "20.0"
targetinfohealthtext.TextColor3 = mainapi.MainColor
targetinfohealthtext.TextSize = 26
targetinfohealthtext.TextXAlignment = Enum.TextXAlignment.Left
targetinfohealthtext.FontFace = mainapi.Fonts.ProductSansMedium
targetinfohealthtext.Parent = targetinfo
local targetInfoConnection
task.spawn(function()
    local targetInfoOpenTween
    local targetInfoHealthTween
    local targetInfoOldValue
    local targetInfoOldTarget
    local targetInfoOldHealth
    local targetInfoTick = tick()
    targetInfoConnection = game:GetService("RunService").RenderStepped:Connect(function()
        if not mainapi.Settings.targetinfoenabled then return end
        local newValue = tick() < targetInfoTick
        for _, v in pairs(mainapi.Targets) do
            newValue = true
            targetInfoTick = tick() + 1
            targetinfoimage.Image = 'rbxthumb://type=AvatarHeadShot&id='..v.Player.UserId..'&w=420&h=420'
            targetinfoname.Text = (v.Player.DisplayName or v.Player.Name)
            if v.Player ~= targetInfoOldTarget then
                targetInfoOldHealth = v.Humanoid.Health
                local size = mainapi:GetTextSize(targetinfoname.Text, 26, mainapi.Fonts.ProductSansMedium).X + 180
                size = math.max(size, 295)
                targetinfo.Size = UDim2.fromOffset(size, 95)
                targetinfohealth.Size = UDim2.fromScale(math.clamp(v.Humanoid.Health / v.Humanoid.MaxHealth, 0, 1), 1)
                targetinfohealthtext.Text = string.format("%.1f", v.Humanoid.Health / 5)
                targetinfohealthbkg.Size = UDim2.fromOffset(size - 165, 12)
                targetinfohealthtext.Position = UDim2.fromOffset(size - 62, 49)
                targetInfoOldTarget = v.Player
            end
            if v.Humanoid.Health ~= targetInfoOldHealth then
                targetinfohealthtext.Text = string.format("%.1f", v.Humanoid.Health / 5)
                targetinfohealth:TweenSize(UDim2.fromScale(math.clamp(v.Humanoid.Health / v.Humanoid.MaxHealth, 0, 1), 1), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.25, true)
                if targetInfoOldHealth > v.Humanoid.Health then
                    if targetInfoHealthTween then targetInfoHealthTween:Cancel() end
                    targetinfoimage.Size = UDim2.fromOffset(56, 56)
                    targetinfoimage.ImageColor3 = Color3.new(1, 0, 0)
                    targetInfoHealthTween = tweenService:Create(targetinfoimage, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {ImageColor3 = Color3.new(1, 1, 1), Size = UDim2.fromOffset(64, 64)})
                    targetInfoHealthTween:Play()
                end
                targetInfoOldHealth = v.Humanoid.Health
            end
            targetinfohealth.Visible = targetinfohealth.Size.X.Scale ~= 0
            if mainapi.Settings.targetinfofollow then 
                local pos, vis = gameCamera:WorldToViewportPoint(v.RootPart.Position)
                targetinfo.Visible = vis
                targetinfo.Position = UDim2.fromOffset(pos.X + targetinfo.Size.X.Offset / 2 + 20, pos.Y - targetinfo.Size.Y.Offset / 2)
            else
                targetinfo.Visible = true
                targetinfo.Position = UDim2.new(0.5, 0, 0.5, 95)
            end
            break
        end
        if newValue ~= targetInfoOldValue then
            if targetInfoOpenTween then targetInfoOpenTween:Cancel() end
            if newValue then 
                targetInfoOpenTween = tweenService:Create(targetinfoscale, TweenInfo.new(0.85, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {Scale = 1})
                targetinfo.Visible = true
            else
                targetInfoOpenTween = tweenService:Create(targetinfoscale, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Scale = 0})
                targetInfoOpenTween.Completed:Connect(function()
                    targetinfo.Visible = false
                end)
            end
            targetInfoOpenTween:Play()
            targetInfoOldValue = newValue
        end
    end)
end)

local clickgui = Instance.new("Frame")
clickgui.Size = UDim2.fromOffset(800, 600)
clickgui.Position = UDim2.fromScale(0.5, 0.5)
clickgui.AnchorPoint = Vector2.new(0.5, 0.5)
clickgui.BackgroundColor3 = Color3.fromRGB(23, 26, 33)
clickgui.Visible = false
clickgui.Parent = gui
local clickguimouse = Instance.new("TextButton")
clickguimouse.Text = ""
clickguimouse.BackgroundTransparency = 1
clickguimouse.Modal = true
clickguimouse.Parent = clickgui
local clickguiscale = Instance.new("UIScale")
clickguiscale.Scale = 1
clickguiscale.Parent = clickgui
local clickguicorner = Instance.new("UICorner")
clickguicorner.CornerRadius = UDim.new(0, 24)
clickguicorner.Parent = clickgui
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 200, 1, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(18, 20, 25)
sidebar.Parent = clickgui
local sidebarcorner = Instance.new("UICorner")
sidebarcorner.CornerRadius = UDim.new(0, 24)
sidebarcorner.Parent = sidebar
local sidebarremovecorner = Instance.new("Frame")
sidebarremovecorner.BorderSizePixel = 0
sidebarremovecorner.BackgroundColor3 = Color3.fromRGB(18, 20, 25)
sidebarremovecorner.Position = UDim2.new(1, -10, 0, 0)
sidebarremovecorner.Size = UDim2.new(0, 10, 1, 0)
sidebarremovecorner.Parent = sidebar
local sidebarwatermark = Instance.new("TextLabel")
sidebarwatermark.Size = UDim2.fromOffset(70, 40)
sidebarwatermark.Position = UDim2.fromOffset(28, 21)
sidebarwatermark.BackgroundTransparency = 1
sidebarwatermark.Text = "Rise"
sidebarwatermark.TextColor3 = Color3.new(1, 1, 1)
sidebarwatermark.TextSize = 38
sidebarwatermark.TextXAlignment = Enum.TextXAlignment.Left
sidebarwatermark.TextYAlignment = Enum.TextYAlignment.Top
sidebarwatermark.FontFace = mainapi.Fonts.ProductSans
sidebarwatermark.Parent = sidebar
local sidebarwatermarkversion = Instance.new("TextLabel")
sidebarwatermarkversion.Size = UDim2.fromOffset(70, 40)
sidebarwatermarkversion.Position = UDim2.fromOffset(86, 19)
sidebarwatermarkversion.BackgroundTransparency = 1
sidebarwatermarkversion.Text = "6.0"
sidebarwatermarkversion.TextColor3 = mainapi.MainColor
sidebarwatermarkversion.TextSize = 18
sidebarwatermarkversion.TextXAlignment = Enum.TextXAlignment.Left
sidebarwatermarkversion.TextYAlignment = Enum.TextYAlignment.Top
sidebarwatermarkversion.FontFace = mainapi.Fonts.ProductSans
sidebarwatermarkversion.Parent = sidebar
local categoryhighlight = Instance.new("Frame")
categoryhighlight.BackgroundTransparency = 0
categoryhighlight.BackgroundColor3 = mainapi.MainColor
categoryhighlight.Parent = sidebar
local categoryhighlightcorner = Instance.new("UICorner")
categoryhighlightcorner.CornerRadius = UDim.new(0, 8)
categoryhighlightcorner.Parent = categoryhighlight
local categoryholder = Instance.new("Frame")
categoryholder.Size = UDim2.new(1, -23, 1, -80)
categoryholder.Position = UDim2.fromOffset(23, 80)
categoryholder.ZIndex = 2
categoryholder.BackgroundTransparency = 1
categoryholder.Parent = sidebar
local categorysort = Instance.new("UIListLayout")
categorysort.FillDirection = Enum.FillDirection.Vertical
categorysort.Padding = UDim.new(0, 9)
categorysort.HorizontalAlignment = Enum.HorizontalAlignment.Left
categorysort.VerticalAlignment = Enum.VerticalAlignment.Top
categorysort.Parent = categoryholder

task.spawn(function()
    repeat
        task.wait()
        for i, v in pairs(textguilines) do 
            v.Text.TextColor3 = mainapi:getAccentColor(v.Text.AbsolutePosition / 2)
            v.Line.BackgroundColor3 = v.Text.TextColor3
        end
        categoryhighlight.BackgroundColor3 = darkerColor(mainapi:getAccentColor(categoryhighlight.AbsolutePosition / 2), 0.2)
        targetinfogradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, darkerColor(mainapi:getAccentColor(targetinfo.AbsolutePosition / 2))), ColorSequenceKeypoint.new(1, darkerColor(mainapi:getAccentColor((targetinfo.AbsolutePosition + Vector2.new(0, 100)) / 2)))})
    until not gui.Parent
end)

function mainapi:GetTextSize(text, size, font)
    local params = Instance.new("GetTextBoundsParams")
    params.Text = text
    params.Font = font
    params.Size = size
    params.Width = math.huge
    return textService:GetTextBoundsAsync(params)
end

function mainapi:CreateCategory(name, font, icon)
    local categoryapi = {}

    local buttonsize = mainapi:GetTextSize(name, 18, mainapi.Fonts.ProductSans, Vector2.new(1000000, 1000000))
    local categorybutton = Instance.new("TextButton")
    categorybutton.Size = UDim2.fromOffset(buttonsize.X + 42, 30)
    categorybutton.Text = ""
    categorybutton.BackgroundTransparency = 1
    categorybutton.Parent = categoryholder
    local categoryname = Instance.new("TextLabel")
    categoryname.Size = UDim2.fromOffset(60, 30)
    categoryname.Position = UDim2.fromOffset(27, 0)
    categoryname.BackgroundTransparency = 1
    categoryname.Name = "Main"
    categoryname.Text = name
    categoryname.TextColor3 = Color3.fromRGB(200, 200, 200)
    categoryname.TextSize = 18
    categoryname.TextXAlignment = Enum.TextXAlignment.Left
    categoryname.FontFace = mainapi.Fonts.ProductSans
    categoryname.Parent = categorybutton
    local categoryicon = Instance.new("TextLabel")
    categoryicon.Size = UDim2.fromOffset(30, 30)
    categoryicon.Position = UDim2.fromOffset(-4, 0)
    categoryicon.BackgroundTransparency = 1
    categoryicon.Text = icon
    categoryicon.TextColor3 = Color3.fromRGB(200, 200, 200)
    categoryicon.TextSize = 16
    categoryicon.FontFace = font
    categoryicon.Parent = categorybutton
    local categoryframe = Instance.new("ScrollingFrame")
    categoryframe.Visible = false
    categoryframe.Size = UDim2.new(1, -220, 1, -16)
    categoryframe.Position = UDim2.fromOffset(214, 14)
    categoryframe.BackgroundTransparency = 1
    categoryframe.BorderSizePixel = 0
    categoryframe.ScrollBarThickness = 2
    categoryframe.ScrollBarImageColor3 = Color3.fromRGB(110, 110, 110)
    categoryframe.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
    categoryframe.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
    categoryframe.Parent = clickgui
    local categorysort = Instance.new("UIListLayout")
    categorysort.FillDirection = Enum.FillDirection.Vertical
    categorysort.HorizontalAlignment = Enum.HorizontalAlignment.Left
    categorysort.VerticalAlignment = Enum.VerticalAlignment.Top
    categorysort.Padding = UDim.new(0, 14)
    categorysort.Parent = categoryframe
    categorysort:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        categoryframe.CanvasSize = UDim2.fromOffset(0, categorysort.AbsoluteContentSize.Y + 10)
    end)
    mainapi.Categories[name] = categoryapi

    if name == "Search" then 
        lastSelected = {categorybutton, categoryframe}
        categoryname.Position = UDim2.fromOffset(31, 0)
        categoryname.TextColor3 = Color3.new(1, 1, 1)
        categoryicon.Position = UDim2.fromOffset(0, 0)
        categoryicon.TextColor3 = Color3.new(1, 1, 1)
        categoryhighlight.Size = UDim2.fromOffset(buttonsize.X + 42, 30)
        categoryhighlight.Position = UDim2.fromOffset(23, categorybutton.AbsolutePosition.Y - clickgui.AbsolutePosition.Y)
        clickguiscale.Scale = 0
    end
    
    categorybutton.MouseButton1Click:Connect(function()
        if not guiTween or guiTween.PlaybackState ~= Enum.PlaybackState.Playing then
            if lastSelected then 
                lastSelected[1].Main:TweenPosition(UDim2.fromOffset(27, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.2, true)
                lastSelected[1].Main.TextColor3 = Color3.fromRGB(200, 200, 200)
                lastSelected[1].TextLabel:TweenPosition(UDim2.fromOffset(-4, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.2, true)
                lastSelected[1].TextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                lastSelected[2].Visible = false
            end
            lastSelected = {categorybutton, categoryframe}
            categoryname:TweenPosition(UDim2.fromOffset(31, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.2, true)
            categoryname.TextColor3 = Color3.new(1, 1, 1)
            categoryicon:TweenPosition(UDim2.fromOffset(0, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.2, true)
            categoryicon.TextColor3 = Color3.new(1, 1, 1)
            categoryhighlight:TweenSizeAndPosition(UDim2.fromOffset(buttonsize.X + 42, 30), UDim2.fromOffset(23, categorybutton.AbsolutePosition.Y - clickgui.AbsolutePosition.Y), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.2, true)
            categoryframe.Visible = name ~= "Search"
        end
    end)

    function categoryapi:CreateModule(name, func, text, extratext, default)
        local moduleapi = {Enabled = false, Options = {}, Bind = "", ExtraText = extratext, Connections = {}, Category = categoryname.Text, Default = default}
        local modulebutton = Instance.new("TextButton")
        modulebutton.Size = UDim2.fromOffset(570, 76)
        modulebutton.BackgroundColor3 = Color3.fromRGB(18, 20, 25)
        modulebutton.AutoButtonColor = false
        modulebutton.Text = ""
        modulebutton.Parent = categoryframe
        local modulecorner = Instance.new("UICorner")
        modulecorner.CornerRadius = UDim.new(0, 12)
        modulecorner.Parent = modulebutton
        local modulename = Instance.new("TextLabel")
        modulename.Size = UDim2.fromOffset(200, 24)
        modulename.Position = UDim2.fromOffset(12, 11)
        modulename.BackgroundTransparency = 1
        modulename.Text = name
        modulename.TextColor3 = Color3.fromRGB(200, 200, 200)
        modulename.TextSize = 23
        modulename.TextXAlignment = Enum.TextXAlignment.Left
        modulename.TextYAlignment = Enum.TextYAlignment.Top
        modulename.FontFace = mainapi.Fonts.ProductSans
        modulename.Parent = modulebutton
        local moduledesc = Instance.new("TextLabel")
        moduledesc.Size = UDim2.fromOffset(200, 24)
        moduledesc.Position = UDim2.fromOffset(12, 45)
        moduledesc.BackgroundTransparency = 1
        moduledesc.Text = text
        moduledesc.TextColor3 = Color3.fromRGB(100, 100, 100)
        moduledesc.TextSize = 17
        moduledesc.TextXAlignment = Enum.TextXAlignment.Left
        moduledesc.TextYAlignment = Enum.TextYAlignment.Top
        moduledesc.FontFace = mainapi.Fonts.ProductSans
        moduledesc.Parent = modulebutton
        local moduleframe = Instance.new("Frame")
        moduleframe.Visible = false
        moduleframe.Size = UDim2.fromOffset(570, 10)
        moduleframe.Position = UDim2.fromOffset(0, 68)
        moduleframe.BackgroundTransparency = 1
        moduleframe.BorderSizePixel = 0
        moduleframe.Parent = modulebutton
        local moduleframesort = Instance.new("UIListLayout")
        moduleframesort.FillDirection = Enum.FillDirection.Vertical
        moduleframesort.HorizontalAlignment = Enum.HorizontalAlignment.Left
        moduleframesort.VerticalAlignment = Enum.VerticalAlignment.Top
        moduleframesort.Parent = moduleframe
        local colorTween

        function moduleapi:Toggle(loaded)
            moduleapi.Enabled = not moduleapi.Enabled
            mainapi:UpdateTextGUI()
            if colorTween then colorTween:Cancel() end
            colorTween = tweenService:Create(modulename, TweenInfo.new(0.1), {TextColor3 = moduleapi.Enabled and mainapi.MainColor or Color3.fromRGB(200, 200, 200)})
            colorTween:Play()
            moduleapi.ColorObject = moduleapi.Enabled and modulename or nil
            if not loaded and mainapi.Settings.notifs then
                mainapi:CreateNotification("Toggled", "Toggled "..name.." "..(moduleapi.Enabled and "on" or "off"), 1)
            end
            if not moduleapi.Enabled then 
                for i, v in pairs(moduleapi.Connections) do
                    if v.Disconnect then pcall(function() v:Disconnect() end) continue end
                    if v.disconnect then pcall(function() v:disconnect() end) continue end
                end
                table.clear(moduleapi.Connections)
            end
            func(moduleapi.Enabled)
        end

        function moduleapi:CreateToggle(optionname, optionfunc, default)
            local optionapi = {Enabled = false, Type = "Toggle", Default = default}
            local optionframe = Instance.new("TextButton")
            optionframe.Text = ""
            optionframe.Size = UDim2.new(1, 0, 0, 28)
            optionframe.BackgroundTransparency = 1
            optionframe.Parent = moduleframe
            local optiontext = Instance.new("TextLabel")
            optiontext.Size = UDim2.new(1, -12, 1, 0)
            optiontext.Position = UDim2.fromOffset(12, 0)
            optiontext.BackgroundTransparency = 1
            optiontext.Text = optionname
            optiontext.TextColor3 = Color3.fromRGB(200, 200, 200)
            optiontext.TextSize = 18
            optiontext.TextXAlignment = Enum.TextXAlignment.Left
            optiontext.FontFace = mainapi.Fonts.ProductSans
            optiontext.Parent = optionframe
            local optionknob = Instance.new("Frame")
            optionknob.BackgroundColor3 = Color3.fromRGB(23, 26, 33)
            optionknob.Size = UDim2.fromOffset(10, 10)
            optionknob.Position = UDim2.fromOffset(mainapi:GetTextSize(optionname, 18, mainapi.Fonts.ProductSans, Vector2.new(1000000, 1000000)).X + 21, 11)
            optionknob.Parent = optionframe
            local optionknobcorner = Instance.new("UICorner")
            optionknobcorner.CornerRadius = UDim.new(1, 0)
            optionknobcorner.Parent = optionknob
            local optionknobmain = Instance.new("Frame")
            optionknobmain.BackgroundColor3 = mainapi.MainColor
            optionknobmain.Size = UDim2.fromOffset(0, 0)
            optionknobmain.Position = UDim2.fromScale(0.5, 0.5)
            optionknobmain.AnchorPoint = Vector2.new(0.5, 0.5)
            optionknobmain.Visible = false
            optionknobmain.Parent = optionknob
            local optionknobmaincorner = Instance.new("UICorner")
            optionknobmaincorner.CornerRadius = UDim.new(1, 0)
            optionknobmaincorner.Parent = optionknobmain
            optionapi.ColorObject = optionknobmain

            function optionapi:Toggle()
                optionapi.Enabled = not optionapi.Enabled
                optionknobmain.Visible = true
                optionknobmain:TweenSize(UDim2.fromOffset(optionapi.Enabled and 10 or 0, optionapi.Enabled and 10 or 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0.1, true)
                task.delay(0.1, function()
                    optionknobmain.Visible = optionknobmain.Size ~= UDim2.fromOffset()
                end)
                optionfunc(optionapi.Enabled)
            end

            optionframe.MouseButton1Click:Connect(function()
                optionapi:Toggle()
            end)
            if default then
                optionapi:Toggle()
            end

            moduleapi.Options[optionname.."Toggle"] = optionapi

            return optionapi
        end

        function moduleapi:CreateSlider(optionname, optionfunc, min, max, default)
            local optionapi = {Value = default or min, Type = "Slider"}
            local startpos = mainapi:GetTextSize(optionname, 18, mainapi.Fonts.ProductSans, Vector2.new(1000000, 1000000)).X + 26
            local optionframe = Instance.new("TextButton")
            optionframe.Text = ""
            optionframe.Size = UDim2.new(1, 0, 0, 28)
            optionframe.BackgroundTransparency = 1
            optionframe.Parent = moduleframe
            local optiontext = Instance.new("TextLabel")
            optiontext.Size = UDim2.new(1, -12, 1, 0)
            optiontext.Position = UDim2.fromOffset(12, 0)
            optiontext.BackgroundTransparency = 1
            optiontext.Text = optionname
            optiontext.TextColor3 = Color3.fromRGB(200, 200, 200)
            optiontext.TextSize = 18
            optiontext.TextXAlignment = Enum.TextXAlignment.Left
            optiontext.FontFace = mainapi.Fonts.ProductSans
            optiontext.Parent = optionframe
            local optionvalue = Instance.new("TextLabel")
            optionvalue.Size = UDim2.new(1, -12, 1, 0)
            optionvalue.Position = UDim2.fromOffset(startpos + 210, 0)
            optionvalue.BackgroundTransparency = 1
            optionvalue.Text = optionapi.Value
            optionvalue.TextColor3 = Color3.fromRGB(200, 200, 200)
            optionvalue.TextSize = 18
            optionvalue.TextXAlignment = Enum.TextXAlignment.Left
            optionvalue.FontFace = mainapi.Fonts.ProductSans
            optionvalue.Parent = optionframe
            local optionsliderbase = Instance.new("Frame")
            optionsliderbase.Size = UDim2.fromOffset(200, 4)
            optionsliderbase.BackgroundColor3 = Color3.fromRGB(23, 26, 33)
            optionsliderbase.Position = UDim2.fromOffset(startpos, 13)
            optionsliderbase.Parent = optionframe
            local optionsliderbasecorner = Instance.new("UICorner")
            optionsliderbasecorner.CornerRadius = UDim.new(1, 0)
            optionsliderbasecorner.Parent = optionsliderbase
            local optionsliderfill = Instance.new("Frame")
            optionsliderfill.Size = UDim2.new(optionapi.Value / max, 0, 0, 4)
            optionsliderfill.BackgroundColor3 = darkerColor(mainapi.MainColor)
            optionsliderfill.Position = UDim2.fromOffset(0, 0)
            optionsliderfill.Parent = optionsliderbase
            local optionsliderfillcorner = Instance.new("UICorner")
            optionsliderfillcorner.CornerRadius = UDim.new(1, 0)
            optionsliderfillcorner.Parent = optionsliderfill
            local optionssliderknob = Instance.new("Frame")
            optionssliderknob.Size = UDim2.fromOffset(10, 10)
            optionssliderknob.BackgroundColor3 = mainapi.MainColor
            optionssliderknob.Position = UDim2.new(1, -5, 0, -3)
            optionssliderknob.Parent = optionsliderfill
            local optionssliderknobcorner = Instance.new("UICorner")
            optionssliderknobcorner.CornerRadius = UDim.new(1, 0)
            optionssliderknobcorner.Parent = optionssliderknob
            optionapi.ColorObject = optionsliderfill
            optionapi.ColorObject2 = optionssliderknob

            function optionapi:SetValue(val)
                optionapi.Value = val
                optionvalue.Text = optionapi.Value
                optionsliderfill.Size = UDim2.new(math.clamp(val / max, 0, 1), 0, 0, 4)
                optionfunc(val)
            end

            optionframe.MouseButton1Down:Connect(function()
                local dragConnection
                dragConnection = inputService.InputEnded:Connect(function(inputObject)
                    if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then 
                        dragConnection:Disconnect()
                        dragConnection = nil
                    end
                end)
                task.spawn(function()
                    repeat
                        task.wait()
                        local mousepos = inputService:GetMouseLocation()
                        optionapi:SetValue(math.floor(min + ((max - min) * (math.clamp(mousepos.X - optionsliderfill.AbsolutePosition.X, 1, 200) / 200))))
                        optionsliderfill.Size = UDim2.new(math.clamp(mousepos.X - optionsliderfill.AbsolutePosition.X, 1, 200) / 200, 0, 0, 4)
                    until not dragConnection
                end)
            end)

            moduleapi.Options[optionname.."Slider"] = optionapi

            return optionapi
        end
        
        function moduleapi:CreateDropdown(optionname, optionfunc, list)
            local optionapi = {Value = list[1], Type = "Dropdown"}
            local optionframe = Instance.new("TextButton")
            optionframe.Text = ""
            optionframe.Size = UDim2.new(1, 0, 0, 28)
            optionframe.BackgroundTransparency = 1
            optionframe.Parent = moduleframe
            local optiontext = Instance.new("TextLabel")
            optiontext.Size = UDim2.new(1, -12, 1, 0)
            optiontext.Position = UDim2.fromOffset(12, 0)
            optiontext.BackgroundTransparency = 1
            optiontext.Text = optionname..": "..optionapi.Value
            optiontext.TextColor3 = Color3.fromRGB(200, 200, 200)
            optiontext.TextSize = 18
            optiontext.TextXAlignment = Enum.TextXAlignment.Left
            optiontext.FontFace = mainapi.Fonts.ProductSans
            optiontext.Parent = optionframe

            function optionapi:SetValue(val)
                optionapi.Value = table.find(list, val) and val or list[1]
                optiontext.Text = optionname..": "..optionapi.Value
                optionfunc(optionapi.Value)
            end

            optionframe.MouseButton1Click:Connect(function()
                optionapi:SetValue(list[table.find(list, optionapi.Value) + 1 % #list])
            end)
            optionframe.MouseButton2Click:Connect(function()
                local num = table.find(list, optionapi.Value) - 1
                num = num < 1 and #list or num
                optionapi:SetValue(list[num])
            end)

            moduleapi.Options[optionname.."Dropdown"] = optionapi

            return optionapi
        end

        moduleframesort:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            moduleframe.Size = UDim2.fromOffset(570, moduleframesort.AbsoluteContentSize.Y + 10)
            if moduleframe.Visible then 
                modulebutton.Size = UDim2.fromOffset(570, moduleframesort.AbsoluteContentSize.Y + 76)
            end
        end)
        modulebutton.MouseButton1Click:Connect(function()
            if inputService:IsKeyDown(Enum.KeyCode.LeftShift) then 
                mainapi.CurrentlyBinding = moduleapi
                return
            end
            moduleapi:Toggle()
        end)
        modulebutton.MouseButton2Click:Connect(function()
            moduleframe.Visible = not moduleframe.Visible
            modulebutton.Size = UDim2.fromOffset(570, moduleframe.Visible and moduleframe.Size.Y.Offset + 66 or 76)
        end)

        mainapi.Modules[name] = moduleapi

        return moduleapi
    end

    return categoryapi
end


function mainapi:CreateThemeCategory(name, font, icon)
    local categoryapi = {Theme = "Blend"}

    local buttonsize = mainapi:GetTextSize(name, 18, mainapi.Fonts.ProductSans, Vector2.new(1000000, 1000000))
    local categorybutton = Instance.new("TextButton")
    categorybutton.Size = UDim2.fromOffset(buttonsize.X + 42, 30)
    categorybutton.Text = ""
    categorybutton.BackgroundTransparency = 1
    categorybutton.Parent = categoryholder
    local categoryname = Instance.new("TextLabel")
    categoryname.Size = UDim2.fromOffset(60, 30)
    categoryname.Position = UDim2.fromOffset(27, 0)
    categoryname.BackgroundTransparency = 1
    categoryname.Name = "Main"
    categoryname.Text = name
    categoryname.TextColor3 = Color3.fromRGB(200, 200, 200)
    categoryname.TextSize = 18
    categoryname.TextXAlignment = Enum.TextXAlignment.Left
    categoryname.FontFace = mainapi.Fonts.ProductSans
    categoryname.Parent = categorybutton
    local categoryicon = Instance.new("TextLabel")
    categoryicon.Size = UDim2.fromOffset(30, 30)
    categoryicon.Position = UDim2.fromOffset(-4, 0)
    categoryicon.BackgroundTransparency = 1
    categoryicon.Text = icon
    categoryicon.TextColor3 = Color3.fromRGB(200, 200, 200)
    categoryicon.TextSize = 16
    categoryicon.FontFace = font
    categoryicon.Parent = categorybutton
    local categoryframe = Instance.new("ScrollingFrame")
    categoryframe.Visible = false
    categoryframe.Size = UDim2.new(1, -220, 1, -16)
    categoryframe.Position = UDim2.fromOffset(214, 14)
    categoryframe.BackgroundTransparency = 1
    categoryframe.BorderSizePixel = 0
    categoryframe.ScrollBarThickness = 2
    categoryframe.ScrollBarImageColor3 = Color3.fromRGB(110, 110, 110)
    categoryframe.TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
    categoryframe.BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
    categoryframe.Parent = clickgui
    local categorysort = Instance.new("UIGridLayout")
    categorysort.FillDirection = Enum.FillDirection.Horizontal
    categorysort.FillDirectionMaxCells = 3
    categorysort.CellPadding = UDim2.fromOffset(14, 14)
    categorysort.CellSize = UDim2.fromOffset(180, 100)
    categorysort.Parent = categoryframe
    categorysort:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        categoryframe.CanvasSize = UDim2.fromOffset(0, categorysort.AbsoluteContentSize.Y + 10)
    end)
    mainapi.Categories[name] = categoryapi

    if name == "Search" then 
        lastSelected = {categorybutton, categoryframe}
        categoryname.Position = UDim2.fromOffset(31, 0)
        categoryicon.Position = UDim2.fromOffset(0, 0)
        categoryhighlight.Size = UDim2.fromOffset(buttonsize.X + 42, 30)
        categoryhighlight.Position = UDim2.fromOffset(23, categorybutton.AbsolutePosition.Y - clickgui.AbsolutePosition.Y)
        clickguiscale.Scale = 0
    end
    
    categorybutton.MouseButton1Click:Connect(function()
        if not guiTween or guiTween.PlaybackState ~= Enum.PlaybackState.Playing then
            if lastSelected then 
                lastSelected[1].Main:TweenPosition(UDim2.fromOffset(27, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.2, true)
                lastSelected[1].TextLabel:TweenPosition(UDim2.fromOffset(-4, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.2, true)
                lastSelected[2].Visible = false
            end
            lastSelected = {categorybutton, categoryframe}
            categoryname:TweenPosition(UDim2.fromOffset(31, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.2, true)
            categoryicon:TweenPosition(UDim2.fromOffset(0, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.2, true)
            categoryhighlight:TweenSizeAndPosition(UDim2.fromOffset(buttonsize.X + 42, 30), UDim2.fromOffset(23, categorybutton.AbsolutePosition.Y - clickgui.AbsolutePosition.Y), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.2, true)
            categoryframe.Visible = name ~= "Search"
        end
    end)

    function categoryapi:SetTheme(val)
        local theme = mainapi.Themes[val]
        if not theme then
            val = "Blend"
            theme = mainapi.Themes[val]
        end
        categoryapi.Theme = val
        mainapi.MainColor = theme[1]
        mainapi.SecondaryColor = theme[2]
        mainapi.ThirdColor = theme[3]
        watermark.TextColor3 = mainapi.MainColor
        sidebarwatermarkversion.TextColor3 = mainapi.MainColor
        targetinfohealthgradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, mainapi.MainColor), ColorSequenceKeypoint.new(1, mainapi.SecondaryColor)})
        targetinfohealthbkg.BackgroundColor3 = darkerColor(mainapi.MainColor)
        targetinfohealthtext.TextColor3 = mainapi.MainColor
        targetinfoname.TextColor3 = mainapi.MainColor
        categoryhighlight.BackgroundColor3 = mainapi.MainColor
        local notif = gui:FindFirstChild("Notification")
        if notif then notif.NotifName.TextColor3 = mainapi.MainColor end
        for i, v in pairs(mainapi.Modules) do 
            if v.ColorObject then v.ColorObject.TextColor3 = mainapi.MainColor end
            for i2, v2 in pairs(v.Options) do 
                if v2.ColorObject then v2.ColorObject.BackgroundColor3 = v2.ColorObject2 and darkerColor(mainapi.MainColor) or mainapi.MainColor end
                if v2.ColorObject2 then v2.ColorObject2.BackgroundColor3 = mainapi.MainColor end
            end
        end
        mainapi:UpdateTextGUI()
    end

    local sortedthemes = {}
    for i, v in pairs(mainapi.Themes) do table.insert(sortedthemes, i) end
    table.sort(sortedthemes, function(a, b) return a < b end)
    for i, v in pairs(sortedthemes) do 
        local themetitle = v
        v = mainapi.Themes[v]
        local themebutton = Instance.new("TextButton")
        themebutton.Text = ""
        themebutton.AutoButtonColor = false
        themebutton.BackgroundColor3 = Color3.fromRGB(18, 20, 25)
        themebutton.Parent = categoryframe
        local themecorner = Instance.new("UICorner")
        themecorner.CornerRadius = UDim.new(0, 16)
        themecorner.Parent = themebutton
        local themeshowcase = Instance.new("Frame")
        themeshowcase.Size = UDim2.fromOffset(180, 90)
        themeshowcase.BackgroundColor3 = Color3.new(1, 1, 1)
        themeshowcase.Parent = themebutton
        local themeshowcasecorner = Instance.new("UICorner")
        themeshowcasecorner.CornerRadius = UDim.new(0, 16)
        themeshowcasecorner.Parent = themeshowcase
        local themeshowcasegradient = Instance.new("UIGradient")
        if v[3] then 
            themeshowcasegradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, v[1]), ColorSequenceKeypoint.new(0.5, v[2]), ColorSequenceKeypoint.new(1, v[3])})
        else
            themeshowcasegradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, v[1]), ColorSequenceKeypoint.new(1, v[2])})
        end
        themeshowcasegradient.Parent = themeshowcase
        local themeline = Instance.new("Frame")
        themeline.Size = UDim2.new(1, 0, 0, 30)
        themeline.Position = UDim2.new(0, 0, 1, -30)
        themeline.BorderSizePixel = 0
        themeline.BackgroundColor3 = Color3.fromRGB(18, 20, 25)
        themeline.Parent = themeshowcase
        local themename = Instance.new("TextLabel")
        themename.Size = UDim2.fromOffset(179, 24)
        themename.Position = UDim2.fromOffset(0, 65)
        themename.BackgroundTransparency = 1
        themename.Text = themetitle
        themename.TextColor3 = Color3.new(1, 1, 1)
        themename.TextSize = 18
        themename.FontFace = mainapi.Fonts.ProductSans
        themename.ZIndex = 2
        themename.Parent = themebutton
        themebutton.MouseButton1Click:Connect(function()
            categoryapi:SetTheme(themetitle)
        end)
    end

    return categoryapi
end

local notifs = {}
function mainapi:CreateNotification(name, text, duration, continued)
    if #notifs > 0 and not continued then 
        table.insert(notifs, {name, text, duration})
        return
    end
    if not continued then
        table.insert(notifs, {name, text, duration})
    end
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.AnchorPoint = Vector2.new(0.5, 0.5)
    notification.Size = UDim2.fromOffset(280, 60)
    notification.Position = UDim2.fromOffset(150, 84)
    notification.BackgroundTransparency = 1
    notification.BackgroundColor3 = Color3.new()
    notification.Parent = gui
    local notificationcorner = Instance.new("UICorner")
    notificationcorner.CornerRadius = UDim.new(0, 24)
    notificationcorner.Parent = notification
    local notificationscale = Instance.new("UIScale")
    notificationscale.Scale = 1.1
    notificationscale.Parent = notification
    local notificationicon = Instance.new("Frame")
    notificationicon.Size = UDim2.fromOffset(40, 40)
    notificationicon.BackgroundColor3 = Color3.new(1, 1, 1)
    notificationicon.Position = UDim2.fromOffset(10, 10)
    notificationicon.Parent = notification
    local notificationiconcorner = Instance.new("UICorner")
    notificationiconcorner.CornerRadius = UDim.new(0, 16)
    notificationiconcorner.Parent = notificationicon
    local notificationname = Instance.new("TextLabel")
    notificationname.Name = "NotifName"
    notificationname.Size = UDim2.fromOffset(60, 30)
    notificationname.Position = UDim2.fromOffset(61, 4)
    notificationname.BackgroundTransparency = 1
    notificationname.Text = name
    notificationname.TextColor3 = mainapi.MainColor
    notificationname.TextSize = 19
    notificationname.TextXAlignment = Enum.TextXAlignment.Left
    notificationname.TextYAlignment = Enum.TextYAlignment.Center
    notificationname.FontFace = mainapi.Fonts.ProductSansMedium
    notificationname.Parent = notification
    local notificationtext = Instance.new("TextLabel")
    notificationtext.Size = UDim2.fromOffset(60, 30)
    notificationtext.Position = UDim2.fromOffset(61, 25)
    notificationtext.BackgroundTransparency = 1
    notificationtext.Text = text
    notificationtext.TextColor3 = Color3.new(1, 1, 1)
    notificationtext.TextSize = 17
    notificationtext.TextXAlignment = Enum.TextXAlignment.Left
    notificationtext.TextYAlignment = Enum.TextYAlignment.Center
    notificationtext.FontFace = mainapi.Fonts.ProductSans
    notificationtext.Parent = notification
    task.spawn(function()
        local info = TweenInfo.new(0.9, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
        tweenService:Create(notificationscale, info, {Scale = 1}):Play()
        tweenService:Create(notification, info, {BackgroundTransparency = 0.5}):Play()
        tweenService:Create(notificationname, info, {TextTransparency = 0}):Play()
        tweenService:Create(notificationtext, info, {TextTransparency = 0}):Play()
        tweenService:Create(notificationicon, info, {BackgroundTransparency = 0}):Play()
        task.wait(duration)
        tweenService:Create(notificationscale, info, {Scale = 1.1}):Play()
        tweenService:Create(notification, info, {BackgroundTransparency = 1}):Play()
        tweenService:Create(notificationname, info, {TextTransparency = 1}):Play()
        tweenService:Create(notificationtext, info, {TextTransparency = 1}):Play()
        tweenService:Create(notificationicon, info, {BackgroundTransparency = 1}):Play()
        task.delay(0.9, function()
            notification:Destroy()
        end)
        task.wait(0.3)
        table.remove(notifs, 1)
        if notifs[1] then
            mainapi:CreateNotification(notifs[1][1], notifs[1][2], notifs[1][3], true)
        end
    end)
end

mainapi.uninjectEvent = Instance.new("BindableEvent")
function mainapi:Uninject()
    mainapi.uninjectEvent:Fire()
    mainapi:Save()
    mainapi.Save = function() end
    for i, v in pairs(mainapi.Modules) do 
        if v.Enabled then v:Toggle(true) end
    end
    if mainapi.gui then mainapi.gui:Destroy() end
    if targetInfoConnection then targetInfoConnection:Disconnect() end
    if inputConnection then inputConnection:Disconnect() end
    shared.risegui = nil
    shared.RiseExecuted = nil
end

function mainapi:Save()
    if not mainapi.Loaded then return end
    local savetable = {}
    for i, v in pairs(mainapi.Modules) do
        local options = {}
        for i2, v2 in pairs(v.Options) do 
            if v2.Type == "Toggle" then 
                options[i2] = {Enabled = v2.Enabled}
            end
            if v2.Type == "Slider" or v2.Type == "Dropdown" then 
                options[i2] = {Value = v2.Value}
            end
        end
        savetable[i] = {Enabled = v.Enabled, Bind = v.Bind, Options = options}
    end
    savetable.CurrentTheme = mainapi.Categories.Themes.Theme
    writefile("risesix/profiles/"..(shared.RiseSave or game.PlaceId)..".txt", game:GetService("HttpService"):JSONEncode(savetable))
end

function mainapi:Load()
    local suc, json = false, {}
    if isfile("risesix/profiles/"..(shared.RiseSave or game.PlaceId)..".txt") then 
        suc, json = pcall(function() return game:GetService("HttpService"):JSONDecode(readfile("risesix/profiles/"..(shared.RiseSave or game.PlaceId)..".txt")) end)
        if suc then
            if json.CurrentTheme then 
                mainapi.Categories.Themes:SetTheme(json.CurrentTheme)
            end
            for i, v in pairs(json) do 
                local obj = mainapi.Modules[i]
                if obj then 
                    if v.Enabled then obj:Toggle(true) end
                    obj.Bind = v.Bind
                    for i2, v2 in pairs(v.Options) do 
                        local optionobj = obj.Options[i2]
                        if optionobj then 
                            if optionobj.Type == "Toggle" and v2.Enabled ~= optionobj.Enabled then 
                                optionobj:Toggle()
                            end
                            if optionobj.Type == "Slider" or optionobj.Type == "Dropdown" then 
                                optionobj:SetValue(v2.Value)
                            end
                        end
                    end
                end
            end
        end
    end
    for i, v in pairs(mainapi.Modules) do 
        if not json[i] and v.Default then 
            v:Toggle(true)
        end
    end
    mainapi.Loaded = true
end

inputConnection = inputService.InputBegan:Connect(function(inputObject)
    if inputService:GetFocusedTextBox() then return end
    if inputObject.KeyCode == Enum.KeyCode.Quote then 
        mainapi.Visible = not mainapi.Visible
        if mainapi.Settings.notifs then
            mainapi:CreateNotification("Toggled", "Toggled Click GUI "..(mainapi.Visible and "on" or "off"), 1)
        end
        if guiTween then guiTween:Cancel() end
        guiTween = tweenService:Create(clickguiscale, TweenInfo.new(0.3, mainapi.Visible and Enum.EasingStyle.Exponential or Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Scale = mainapi.Visible and 1 or 0})
        guiTween:Play()
        if mainapi.Visible then 
            clickgui.Visible = mainapi.Visible
        else
            guiTween.Completed:Connect(function()
                clickgui.Visible = mainapi.Visible
            end)
        end
    end
    if mainapi.CurrentlyBinding then 
        if inputObject.KeyCode ~= Enum.KeyCode.Unknown then
            mainapi.CurrentlyBinding.Bind = inputObject.KeyCode.Name == mainapi.CurrentlyBinding.Bind and "" or inputObject.KeyCode.Name
            mainapi.CurrentlyBinding = nil
        end
        return
    end
    for i, v in pairs(mainapi.Modules) do 
        if v.Bind == inputObject.KeyCode.Name then 
            v:Toggle()
        end
    end
end)

return mainapi