local NoxLibrary = {}
local tw = game:GetService("TweenService")
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local plrs = game:GetService("Players")
local cg = game:GetService("CoreGui")
local http = game:GetService("HttpService")

local folderName = "NoxAssets"
local jsonName = "m3font.json"
local ttfName = "GoogleSans.ttf"
local fontUrl = "https://github.com/fiangg20/Fian_gg-Repo/raw/refs/heads/main/GoogleSansFlex_24pt-Regular.ttf"

if not isfolder(folderName) then makefolder(folderName) end

if not isfile(folderName .. "/" .. ttfName) then
    local fontFile = game:HttpGet(fontUrl)
    writefile(folderName .. "/" .. ttfName, fontFile)
end

local assetURL = getcustomasset(folderName .. "/" .. ttfName)
local fontJsonData = {
    name = "CustomFamily_GoogleSans",
    faces = {
        {
            name = "Regular",
            weight = 400,
            style = "normal",
            assetId = assetURL
        }
    }
}

local pathJSON = folderName .. "/" .. jsonName
writefile(pathJSON, http:JSONEncode(fontJsonData))
local m3Font = Font.new(getcustomasset(pathJSON))

local lucideIcons = {}
local success, result = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/fiangg20/Fian_gg-Repo/refs/heads/main/lucideicn.lua"))()
end)

if success and type(result) == "table" then
    lucideIcons = result
else
    warn("[Nox] Failed to load lucide icons. Icons may not work properly.")
end

local function parseIcon(iconStr)
    if not iconStr or iconStr == "" then return nil end

    if string.find(iconStr, "rbxassetid://") or string.find(iconStr, "rbxasset://") then
        return iconStr
    end

    if lucideIcons[iconStr] then
        return lucideIcons[iconStr]
    end

    warn("[Nox] Icon '" .. iconStr .. "' not found in lucide icons. Please check the icon name or use a valid asset ID.")
    return nil 
end

local cp = {
    ["Purple"] = {bg=Color3.fromRGB(28,27,31), fg=Color3.fromRGB(230,225,229), pri=Color3.fromRGB(208,188,255), onpri=Color3.fromRGB(56,30,114), inact=Color3.fromRGB(43,41,48), out=Color3.fromRGB(147,143,153)},
    ["Blue"] = {bg=Color3.fromRGB(26,28,30), fg=Color3.fromRGB(226,226,230), pri=Color3.fromRGB(162,201,255), onpri=Color3.fromRGB(0,50,90), inact=Color3.fromRGB(40,42,46), out=Color3.fromRGB(141,145,153)},
    ["Red"] = {bg=Color3.fromRGB(32,26,25), fg=Color3.fromRGB(237,224,222), pri=Color3.fromRGB(255,180,168), onpri=Color3.fromRGB(105,0,5), inact=Color3.fromRGB(50,40,38), out=Color3.fromRGB(160,140,137)},
    ["Green"] = {bg=Color3.fromRGB(26,28,25), fg=Color3.fromRGB(225,227,223), pri=Color3.fromRGB(143,215,135), onpri=Color3.fromRGB(0,57,10), inact=Color3.fromRGB(40,43,40), out=Color3.fromRGB(142,145,143)},
    ["Orange"] = {bg=Color3.fromRGB(32,27,24), fg=Color3.fromRGB(236,224,219), pri=Color3.fromRGB(255,183,123), onpri=Color3.fromRGB(76,38,0), inact=Color3.fromRGB(50,42,38), out=Color3.fromRGB(159,141,132)},
    ["Default"] = {bg=Color3.fromRGB(0,0,0), fg=Color3.fromRGB(230,225,229), pri=Color3.fromRGB(208,188,255), onpri=Color3.fromRGB(56,30,114), inact=Color3.fromRGB(28,28,30), out=Color3.fromRGB(147,143,153)}
}

local objs = {bg={}, fg={}, pri={}, onpri={}, inact={}, out={}, s_trk={}, s_thm={}, tab_btn={}, tbox={}, icon={}, dlg_bg={}, dlg_fg={}, sl_val={}}

local function t(o, p, v, d)
    tw:Create(o, TweenInfo.new(d or 0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {[p] = v}):Play()
end

local function RippleEffect(btn, input, color)
    if input.UserInputType.Name ~= "MouseButton1" and input.UserInputType.Name ~= "Touch" then return end
        
    local targetParent = btn:FindFirstChild("RippleContainer") or btn
        
    local mask = Instance.new("CanvasGroup", targetParent)
    mask.Name = "RippleMask"
    mask.Size = UDim2.new(1, 0, 1, 0)
    mask.BackgroundTransparency = 1
    mask.BorderSizePixel = 0
    mask.ZIndex = 50

    local corner = btn:FindFirstChildOfClass("UICorner") or targetParent:FindFirstChildOfClass("UICorner")
    if corner then
        local c = corner:Clone()
        c.Parent = mask
    end
        
    local ripple = Instance.new("Frame", mask)
    ripple.BackgroundColor3 = color or curTheme.fg
    ripple.BackgroundTransparency = 0.85 
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    ripple.BorderSizePixel = 0
    Instance.new("UICorner", ripple).CornerRadius = UDim.new(1, 0) 
        
    local x = input.Position.X - targetParent.AbsolutePosition.X
    local y = input.Position.Y - targetParent.AbsolutePosition.Y
    ripple.Position = UDim2.new(0, x, 0, y)
    ripple.Size = UDim2.new(0, 0, 0, 0)
        
    local maxSize = math.max(targetParent.AbsoluteSize.X, targetParent.AbsoluteSize.Y) * 1.5
        
    tw:Create(ripple, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, maxSize, 0, maxSize),
        BackgroundTransparency = 1
    }):Play()
        
    task.delay(0.4, function() mask:Destroy() end)
end

local function CreateNox(data)
    data = data or {}
    local titleText = data.Title or "Nox"
    local finalSizeX = data.SizeX or 380
    local finalSizeY = data.SizeY or 520
    local toggleKey = data.ToggleKey
    local initTheme = data.Theme or "Default" 
    local enableSearch = data.Search or false
    local searchPlaceholder = data.SearchPlaceholder or "Search..."
    local searchCb = data.OnSearch
    local searchAvatar = data.SearchAvatar or "rbxthumb://type=AvatarHeadShot&id=" .. plrs.LocalPlayer.UserId .. "&w=48&h=48"

    if cp[initTheme] then
        curTheme = cp[initTheme]
    else
        warn("[Nox] Invalid theme '" .. tostring(initTheme) .. "'.")
        curTheme = cp["Default"]
    end

    local lib = {}
    local resizeHandle

    local old = cg:FindFirstChild(titleText or "Nox")
    if old then old:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = titleText or "Nox"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 1e6
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = cg

    local notifCont = Instance.new("Frame", gui)
    notifCont.Name = "NotifyContainer"
    notifCont.Size = UDim2.new(1, 0, 1, 0)
    notifCont.BackgroundTransparency = 1
    notifCont.ZIndex = 1000

    local notifPad = Instance.new("UIPadding", notifCont)
    notifPad.PaddingBottom = UDim.new(0, 32)

    local notifLayout = Instance.new("UIListLayout", notifCont)
    notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    notifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    notifLayout.SortOrder = Enum.SortOrder.LayoutOrder
    notifLayout.Padding = UDim.new(0, 8)
    
    local win = Instance.new("Frame", gui)
    win.Size = UDim2.new(0, finalSizeX, 0, 0) 
    win.Position = UDim2.new(0.5, -finalSizeX/2, 0.5, -finalSizeY/2)
    win.BackgroundColor3 = curTheme.bg
    win.BorderSizePixel = 0
    win.ClipsDescendants = true
    win.Transparency = 1
    table.insert(objs.bg, win)
    Instance.new("UICorner", win).CornerRadius = UDim.new(0, 16)

    local top = Instance.new("TextLabel", win)
    top.Size = UDim2.new(1, -120, 0, 45) 
    top.Position = UDim2.new(0, 24, 0, 10)
    top.BackgroundTransparency = 1
    top.RichText = true
    top.Text = titleText or "Nox"
    top.TextColor3 = curTheme.fg
    top.FontFace = Font.new(m3Font.Family, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
    top.TextSize = 22
    top.TextXAlignment = Enum.TextXAlignment.Left
    table.insert(objs.fg, top)

    local ctrlCont = Instance.new("Frame", win)
    ctrlCont.Size = UDim2.new(0, 100, 0, 32)
    ctrlCont.AnchorPoint = Vector2.new(1, 0)
    ctrlCont.Position = UDim2.new(1, -12, 0, 16) 
    ctrlCont.BackgroundTransparency = 1

    local ctrlLayout = Instance.new("UIListLayout", ctrlCont)
    ctrlLayout.FillDirection = Enum.FillDirection.Horizontal
    ctrlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    ctrlLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ctrlLayout.Padding = UDim.new(0, 8)

    local function createCtrlBtn(name, icon)
        local btn = Instance.new("TextButton", ctrlCont)
        btn.Name = name
        btn.Size = UDim2.new(0, 32, 0, 32)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
        
        local icn = Instance.new("ImageLabel", btn)
        icn.Size = UDim2.new(0, 18, 0, 18)
        icn.AnchorPoint = Vector2.new(0.5, 0.5)
        icn.Position = UDim2.new(0.5, 0, 0.5, 0)
        icn.BackgroundTransparency = 1
        icn.Image = icon
        icn.ImageColor3 = curTheme.out
        table.insert(objs.icon, icn)

        btn.MouseEnter:Connect(function() 
            t(btn, "BackgroundTransparency", 0.9, 0.2)
            t(btn, "BackgroundColor3", curTheme.out, 0.2)
        end)
        btn.MouseLeave:Connect(function() 
            t(btn, "BackgroundTransparency", 1, 0.2) 
        end)
        btn.InputBegan:Connect(function(input)
            RippleEffect(btn, input, curTheme.out)
        end)
        
        return btn, icn
    end

    local iconMin = parseIcon("minimize") or ""
    local iconMax = parseIcon("maximize") or ""
    local iconClose = parseIcon("x") or ""

    local btnMinMax, icnMinMax = createCtrlBtn("Minimize and Maximize", iconMin)
    local btnClose, icnClose = createCtrlBtn("Close", iconClose)

    local isMin = false
    local isMax = false
    local preSize = UDim2.new(0, finalSizeX, 0, finalSizeY) 
    local prePos = win.Position

    local function toggleWindow()
        if isMin then
            isMin = false
            icnMinMax.Image = iconMin
            t(win, "Size", preSize, 0.4)
            if resizeHandle then resizeHandle.Visible = true end
        else
            if not isMax then preSize = win.Size end
            isMin = true
            isMax = false
            icnMinMax.Image = iconMax
            t(win, "Size", UDim2.new(0, win.Size.X.Offset, 0, 64), 0.4)
            if resizeHandle then resizeHandle.Visible = false end
        end
    end

    btnMinMax.MouseButton1Click:Connect(toggleWindow)

    if toggleKey then
        uis.InputBegan:Connect(function(input, gameProcessed)
            if not gameProcessed and input.KeyCode == toggleKey then
                toggleWindow()
            end
        end)
    end

    local searchBar = nil

    btnClose.MouseButton1Click:Connect(function()
        lib:AddDialog({
            Title = "Close " .. (titleText or "Nox") .. "?",
            Description = "Are you sure you want to close " .. (titleText or "Nox") .. "? Any unsaved changes will be lost.",
            Buttons = {
                {Text = "Cancel", Type = "text", Callback = nil},
                {Text = "Close", Type = "text", Callback = function()
                    local closeAnim = tw:Create(win, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
                        Size = UDim2.new(0, win.Size.X.Offset, 0, 64),
                        Transparency = 1
                    })
                    local fadeLabel = tw:Create(top, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
                        TextTransparency = 1
                    })
                    local fadeSearch = tw:Create(searchBar, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
                        BackgroundTransparency = 1
                    })
                    local minMaxFade = tw:Create(btnMinMax, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
                        BackgroundTransparency = 1
                    })
                    local fadeClose = tw:Create(btnClose, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
                        BackgroundTransparency = 1
                    })
                    closeAnim:Play()
                    fadeLabel:Play()
                    fadeSearch:Play()
                    minMaxFade:Play()
                    fadeClose:Play()
                    task.wait(0.4)
                    gui:Destroy()
                end}
            },
        })
    end)

    local searchOffset = 0
    if enableSearch then
        searchOffset = 66

        searchBar = Instance.new("Frame", win)
        searchBar.Size = UDim2.new(1, -48, 0, 56) 
        searchBar.Position = UDim2.new(0, 24, 0, 55)
        searchBar.BackgroundColor3 = curTheme.inact:Lerp(curTheme.bg, 0.6)
        searchBar.BorderSizePixel = 0
        searchBar.ZIndex = 60
        table.insert(objs.inact, searchBar)

        Instance.new("UICorner", searchBar).CornerRadius = UDim.new(1, 0)

        local searchIcn = Instance.new("ImageLabel", searchBar)
        searchIcn.Size = UDim2.new(0, 24, 0, 24) 
        searchIcn.AnchorPoint = Vector2.new(0, 0.5)
        searchIcn.Position = UDim2.new(0, 16, 0.5, 0)
        searchIcn.BackgroundTransparency = 1
        searchIcn.Image = parseIcon("search") or "" 
        searchIcn.ImageColor3 = curTheme.out
        searchIcn.ZIndex = 61
        table.insert(objs.icon, searchIcn)

        local avatarImg
        local rightMargin = -16 

        if searchAvatar and searchAvatar ~= "" then
            avatarImg = Instance.new("ImageLabel", searchBar)
            avatarImg.Size = UDim2.new(0, 30, 0, 30) 
            avatarImg.AnchorPoint = Vector2.new(1, 0.5)
            avatarImg.Position = UDim2.new(1, -16, 0.5, 0)
            avatarImg.BackgroundColor3 = curTheme.bg
            avatarImg.Image = searchAvatar
            avatarImg.ClipsDescendants = true
            avatarImg.ZIndex = 61
            Instance.new("UICorner", avatarImg).CornerRadius = UDim.new(1, 0)
            rightMargin = -56 
        end

        local searchBox = Instance.new("TextBox", searchBar)
        searchBox.Size = UDim2.new(1, rightMargin - 48, 1, 0)
        searchBox.Position = UDim2.new(0, 48, 0, 0)
        searchBox.BackgroundTransparency = 1
        searchBox.Text = ""
        searchBox.PlaceholderText = searchPlaceholder
        searchBox.PlaceholderColor3 = curTheme.out
        searchBox.TextColor3 = curTheme.fg
        searchBox.FontFace = m3Font
        searchBox.TextSize = 15
        searchBox.TextXAlignment = Enum.TextXAlignment.Left
        searchBox.ZIndex = 61

        local clearBtn = Instance.new("ImageButton", searchBar)
        clearBtn.Size = UDim2.new(0, 20, 0, 20)
        clearBtn.AnchorPoint = Vector2.new(1, 0.5)
        clearBtn.Position = UDim2.new(1, -16, 0.5, 0)
        clearBtn.BackgroundTransparency = 1
        clearBtn.Image = parseIcon("x") or ""
        clearBtn.ImageColor3 = curTheme.out
        clearBtn.ImageTransparency = 1
        clearBtn.Active = false
        clearBtn.ZIndex = 61
        table.insert(objs.icon, clearBtn)

        local dockedBg = Instance.new("Frame", win)
        dockedBg.Size = UDim2.new(1, -48, 0, 0)
        dockedBg.Position = UDim2.new(0, 24, 0, 115)
        dockedBg.BackgroundColor3 = curTheme.inact:Lerp(curTheme.bg, 0.4)
        dockedBg.BorderSizePixel = 0
        dockedBg.ZIndex = 50
        dockedBg.Visible = false
        dockedBg.ClipsDescendants = true
        table.insert(objs.inact, dockedBg)

        local dockedCorner = Instance.new("UICorner", dockedBg)
        dockedCorner.CornerRadius = UDim.new(0, 16)

        local dockedScroll = Instance.new("ScrollingFrame", dockedBg)
        dockedScroll.Size = UDim2.new(1, 0, 1, 0)
        dockedScroll.BackgroundTransparency = 1
        dockedScroll.ScrollBarThickness = 2
        dockedScroll.ZIndex = 51
        dockedScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        dockedScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        
        local dockedLayout = Instance.new("UIListLayout", dockedScroll)
        dockedLayout.SortOrder = Enum.SortOrder.LayoutOrder

        searchBox:GetPropertyChangedSignal("Text"):Connect(function()
            local query = string.lower(searchBox.Text)
            local hasText = #query > 0

            clearBtn.Active = hasText
            t(clearBtn, "ImageTransparency", hasText and 0 or 1, 0.2)
            if avatarImg then
                t(avatarImg, "ImageTransparency", hasText and 1 or 0, 0.2)
                t(avatarImg, "BackgroundTransparency", hasText and 1 or 0, 0.2)
            end

            for _, child in ipairs(dockedScroll:GetChildren()) do
                if child:IsA("TextButton") or child:IsA("TextLabel") then child:Destroy() end
            end

            if hasText then
                dockedBg.Visible = true
                local resultsCount = 0

                for _, item in ipairs(lib.SearchRegistry) do
                    if item.type == "item" and item.isSearchable and string.find(item.text, query) then
                        resultsCount += 1
                        
                        local resBtn = Instance.new("TextButton", dockedScroll)
                        resBtn.Size = UDim2.new(1, 0, 0, 48)
                        resBtn.BackgroundColor3 = curTheme.fg
                        resBtn.BackgroundTransparency = 1
                        resBtn.Text = item.rawText
                        resBtn.TextColor3 = curTheme.fg
                        resBtn.FontFace = m3Font
                        resBtn.TextSize = 14
                        resBtn.TextXAlignment = Enum.TextXAlignment.Left
                        resBtn.ZIndex = 52
                        resBtn.LayoutOrder = resultsCount
                        table.insert(objs.fg, resBtn)
                        
                        local resPad = Instance.new("UIPadding", resBtn)
                        resPad.PaddingLeft = UDim.new(0, 16)
                        resPad.PaddingRight = UDim.new(0, 16)

                        resBtn.MouseEnter:Connect(function() t(resBtn, "BackgroundTransparency", 0.9, 0.2) end)
                        resBtn.MouseLeave:Connect(function() t(resBtn, "BackgroundTransparency", 1, 0.2) end)

                        resBtn.MouseButton1Click:Connect(function()
                            searchBox.Text = "" 
                            searchBox:ReleaseFocus()
                            dockedBg.Visible = false
                            
                            if item.parentTab then
                                lib:SelectTab(item.parentTab.Text)
                            end
                            
                            task.spawn(function()
                                game:GetService("RunService").RenderStepped:Wait() 
                                game:GetService("RunService").RenderStepped:Wait() 
                                
                                local container = item.parentTab and lib.TabContainers[lib.ActiveTabIndex] or defaultCont
                                local targetEl = item.obj
                                
                                if container and targetEl then
                                    local targetY = targetEl.AbsolutePosition.Y - container.AbsolutePosition.Y + container.CanvasPosition.Y
                                    local centeredY = targetY - (container.AbsoluteSize.Y / 2) + (targetEl.AbsoluteSize.Y / 2)
                                    
                                    local maxScroll = math.max(0, container.AbsoluteCanvasSize.Y - container.AbsoluteSize.Y)
                                    centeredY = math.clamp(centeredY, 0, maxScroll)
                                    
                                    tw:Create(container, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
                                        CanvasPosition = Vector2.new(0, centeredY)
                                    }):Play()
                                end
                            end)
                        end)
                    end
                end

                if resultsCount == 0 then
                    local emptyLbl = Instance.new("TextLabel", dockedScroll)
                    emptyLbl.Size = UDim2.new(1, 0, 0, 48)
                    emptyLbl.BackgroundTransparency = 1
                    emptyLbl.Text = "No results found for '"..searchBox.Text.."'"
                    emptyLbl.TextColor3 = curTheme.out
                    emptyLbl.FontFace = m3Font
                    emptyLbl.TextSize = 14
                end

                local finalHeight = math.clamp(math.max(1, resultsCount) * 48, 48, 200)
                tw:Create(dockedBg, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
                    Size = UDim2.new(1, -48, 0, finalHeight)
                }):Play()
            else
                tw:Create(dockedBg, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
                    Size = UDim2.new(1, -48, 0, 0)
                }):Play()
                task.delay(0.2, function()
                    if #searchBox.Text == 0 then dockedBg.Visible = false end
                end)
            end

            if searchCb then searchCb(searchBox.Text) end
        end)

        clearBtn.MouseButton1Click:Connect(function()
            searchBox.Text = ""
            searchBox:CaptureFocus()
        end)
        
        searchBox.Focused:Connect(function()
            t(searchBar, "BackgroundColor3", curTheme.inact, 0.2)
            t(searchIcn, "ImageColor3", curTheme.pri, 0.2)
        end)

        searchBox.FocusLost:Connect(function()
            t(searchBar, "BackgroundColor3", curTheme.inact:Lerp(curTheme.bg, 0.6), 0.2)
            t(searchIcn, "ImageColor3", curTheme.out, 0.2)
            
            task.delay(0.1, function()
                if not searchBox:IsFocused() then
                    tw:Create(dockedBg, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
                        Size = UDim2.new(1, -48, 0, 0)
                    }):Play()
                    task.delay(0.2, function() dockedBg.Visible = false end)
                end
            end)
        end)
    end

    local tabArea = Instance.new("Frame", win)
    tabArea.Size = UDim2.new(1, 0, 0, 40) 
    tabArea.Position = UDim2.new(0, 0, 0, 55 + searchOffset) 
    tabArea.BackgroundTransparency = 1
    tabArea.ClipsDescendants = true
    tabArea.Visible = false

    local sep = Instance.new("Frame", tabArea)
    sep.Size = UDim2.new(1, 0, 0, 1)
    sep.AnchorPoint = Vector2.new(0, 1)
    sep.Position = UDim2.new(0, 0, 1, 0)
    sep.BackgroundColor3 = curTheme.inact
    sep.BorderSizePixel = 0
    table.insert(objs.inact, sep)

    local tabListCont = Instance.new("ScrollingFrame", tabArea)
    tabListCont.Size = UDim2.new(1, 0, 1, 0)
    tabListCont.BackgroundTransparency = 1
    tabListCont.ScrollBarThickness = 0
    tabListCont.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabListCont.AutomaticCanvasSize = Enum.AutomaticSize.X

    local dragTab = false
    local isDraggingTabAction = false
    local dragTabStartX = 0
    local dragTabStartCanvasX = 0

    local function startTabDrag(input)
        if input.UserInputType.Name:find("MouseButton1") or input.UserInputType.Name:find("Touch") then
            dragTab = true
            isDraggingTabAction = false
            dragTabStartX = input.Position.X
            dragTabStartCanvasX = tabListCont.CanvasPosition.X
        end
    end

    tabListCont.InputBegan:Connect(startTabDrag)

    uis.InputChanged:Connect(function(input)
        if dragTab and (input.UserInputType.Name:find("MouseMovement") or input.UserInputType.Name:find("Touch")) then
            local delta = dragTabStartX - input.Position.X
            if math.abs(delta) > 5 then
                isDraggingTabAction = true
                tabListCont.CanvasPosition = Vector2.new(dragTabStartCanvasX + delta, 0)
            end
        end
    end)

    uis.InputEnded:Connect(function(input)
        if input.UserInputType.Name:find("MouseButton1") or input.UserInputType.Name:find("Touch") then
            dragTab = false
        end
    end)

    local tabListInner = Instance.new("Frame", tabListCont)
    tabListInner.Size = UDim2.new(1, 0, 1, 0)
    tabListInner.BackgroundTransparency = 1
    tabListInner.AutomaticSize = Enum.AutomaticSize.X

    local tPad = Instance.new("UIPadding", tabListInner)
    tPad.PaddingLeft = UDim.new(0, 24)
    tPad.PaddingRight = UDim.new(0, 24)

    local tabList = Instance.new("UIListLayout", tabListInner)
    tabList.FillDirection = Enum.FillDirection.Horizontal
    tabList.SortOrder = Enum.SortOrder.LayoutOrder
    tabList.HorizontalAlignment = Enum.HorizontalAlignment.Center

    indicator = Instance.new("Frame", tabListCont)
    indicator.Size = UDim2.new(0, 0, 0, 3)
    indicator.AnchorPoint = Vector2.new(0.5, 1)
    indicator.Position = UDim2.new(0, 0, 1, 0)
    indicator.BackgroundColor3 = curTheme.pri
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)
    table.insert(objs.pri, indicator)

    local defaultCont = Instance.new("ScrollingFrame", win)
    defaultCont.Size = UDim2.new(1, 0, 1, -(70 + searchOffset))
    defaultCont.Position = UDim2.new(0, 0, 0, 60 + searchOffset)
    defaultCont.BackgroundTransparency = 1
    defaultCont.ScrollBarThickness = 0
    defaultCont.CanvasSize = UDim2.new(0, 0, 0, 0)
    defaultCont.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local dPad = Instance.new("UIPadding", defaultCont)
    dPad.PaddingLeft = UDim.new(0, 24)
    dPad.PaddingRight = UDim.new(0, 24)
    dPad.PaddingBottom = UDim.new(0, 20)
    dPad.PaddingTop = UDim.new(0, 20)

    local defLayout = Instance.new("UIListLayout", defaultCont)
    defLayout.SortOrder = Enum.SortOrder.LayoutOrder
    defLayout.Padding = UDim.new(0, 18)

    local contClip = Instance.new("Frame", win)
    contClip.Size = UDim2.new(1, 0, 1, -(100 + searchOffset))
    contClip.Position = UDim2.new(0, 0, 0, 100 + searchOffset)
    contClip.BackgroundTransparency = 1
    contClip.ClipsDescendants = true
    contClip.Visible = false

    lib.Tabs = {}
    lib.TabContainers = {}
    lib.ActiveTabIndex = 0
    lib.CurrentBuildContainer = defaultCont
    lib.UseTabs = false
    lib.ElementCounter = 0
    lib.SearchRegistry = {}
    lib.CurrentSearchTab = nil
    lib.CurrentSearchSection = nil

    function lib:RegisterElement(uiElement, searchText, elementType)
        table.insert(lib.SearchRegistry, {
            obj = uiElement,
            type = elementType or "item",
            rawText = searchText or "",
            text = searchText and string.lower(searchText) or "",
            isSearchable = (searchText ~= nil and searchText ~= ""),
            parentSection = lib.CurrentSearchSection,
            parentTab = lib.CurrentSearchTab
        })
    end

    function lib:ChangePalette(name)
        if not cp[name] then return end
        curTheme = cp[name]
        
        local d = 0.5
        for _,v in pairs(objs.bg) do t(v, "BackgroundColor3", curTheme.bg, d) end
        for _,v in pairs(objs.fg) do t(v, "TextColor3", curTheme.fg, d) end
        for _,v in pairs(objs.pri) do 
            if v:IsA("TextLabel") then
                t(v, "TextColor3", curTheme.pri, d)
            elseif v:IsA("TextButton") and v.Text ~= "" then
                t(v, "TextColor3", curTheme.pri, d)
            else
                t(v, "BackgroundColor3", curTheme.pri, d)
            end
        end

        if objs.tonal_bg then
            for _,v in pairs(objs.tonal_bg) do
                t(v, "BackgroundColor3", curTheme.inact:Lerp(curTheme.pri, 0.15), d)
            end
        end

        for _,v in pairs(objs.onpri) do 
            if v:IsA("ImageLabel") or v:IsA("ImageButton") then
                t(v, "ImageColor3", curTheme.onpri, d)
            else
                t(v, "TextColor3", curTheme.onpri, d) 
            end
        end
        
        for _,v in pairs(objs.inact) do t(v, "BackgroundColor3", curTheme.inact, d) end
        for _,x in pairs(objs.s_trk) do t(x.obj, "BackgroundColor3", x.state and curTheme.pri or curTheme.inact, d) end
        for _,x in pairs(objs.s_thm) do t(x.obj, "BackgroundColor3", x.state and curTheme.onpri or curTheme.out, d) end
        for _,x in pairs(objs.tab_btn) do 
            t(x.lbl, "TextColor3", x.active and curTheme.pri or curTheme.out, d)
            if x.icon then t(x.icon, "ImageColor3", x.active and curTheme.pri or curTheme.out, d) end
        end
        for _, icn in pairs(objs.icon) do 
            if icn:IsA("UIStroke") then
                t(icn, "Color", curTheme.out, d)
            elseif icn:IsA("ImageLabel") or icn:IsA("ImageButton") then
                t(icn, "ImageColor3", curTheme.out, d)
            elseif icn:IsA("TextLabel") then
                t(icn, "TextColor3", curTheme.out, d)
            end
        end
        for _, v in pairs(objs.sl_val) do t(v, "TextColor3", curTheme.out, d) end

        for _,v in pairs(objs.dlg_bg) do t(v, "BackgroundColor3", curTheme.bg:Lerp(curTheme.pri, 0.11), d) end
        for _,v in pairs(objs.dlg_fg) do t(v, "TextColor3", curTheme.fg, d) end
        
        for _, tb in pairs(objs.tbox) do
            t(tb.lbl, "TextColor3", tb.focused and curTheme.pri or curTheme.out, d)
            t(tb.box, "TextColor3", curTheme.fg, d)
            t(tb.line, "BackgroundColor3", tb.focused and curTheme.pri or curTheme.out, d)
            t(tb.bg, "BackgroundColor3", curTheme.inact, d)
        end
    end

    function lib:AddTheme(themeName, themeData)
        local def = cp["Default"]

        cp[themeName] = {
            bg = themeData.Background or themeData.bg or def.bg,
            fg = themeData.Text or themeData.TextColor or themeData.fg or def.fg,
            pri = themeData.Primary or themeData.PrimaryColor or themeData.pri or def.pri,
            onpri = themeData.TextOnPrimary or themeData.onpri or def.onpri,
            inact = themeData.Surface or themeData.Inactive or themeData.inact or def.inact,
            out = themeData.Outline or themeData.Border or themeData.out or def.out
        }
    end

    function lib:SelectTab(txt)
        local targetIdx = 1
        for i, tData in ipairs(lib.Tabs) do
            if tData.btn.Text == txt then targetIdx = i break end
        end
        
        if targetIdx == lib.ActiveTabIndex then return end
        
        local dir = (targetIdx > lib.ActiveTabIndex) and 1 or -1
        if lib.ActiveTabIndex == 0 then dir = 0 end 
        
        local oldCont = (lib.ActiveTabIndex > 0) and lib.TabContainers[lib.ActiveTabIndex] or defaultCont
        local newCont = lib.TabContainers[targetIdx]

        for i, tData in ipairs(lib.Tabs) do
            local btn = tData.btn
            if i == targetIdx then
                tData.data.active = true
                t(tData.data.lbl, "TextColor3", curTheme.pri, 0.3)
                if tData.data.icon then t(tData.data.icon, "ImageColor3", curTheme.pri, 0.3) end
                            
                task.spawn(function()
                    rs.RenderStepped:Wait() 
                    rs.RenderStepped:Wait()
                    local btnCenterX = (btn.AbsolutePosition.X - tabListCont.AbsolutePosition.X) + tabListCont.CanvasPosition.X + (btn.AbsoluteSize.X / 2)
                    
                    local contentWidth = tData.data.lbl.TextBounds.X
                   
                    tw:Create(indicator, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
                         Position = UDim2.new(0, btnCenterX, 1, 0),
                         Size = UDim2.new(0, contentWidth, 0, 3)
                    }):Play()
                end)
            else
                tData.data.active = false
                t(tData.data.lbl, "TextColor3", curTheme.out, 0.3)
                if tData.data.icon then t(tData.data.icon, "ImageColor3", curTheme.out, 0.3) end
            end
        end

        if oldCont and dir ~= 0 and oldCont ~= defaultCont then
            newCont.Position = UDim2.new(dir, dir * 50, 0, 0)
            newCont.Visible = true
            t(oldCont, "Position", UDim2.new(-dir, -dir * 50, 0, 0), 0.4)
            t(newCont, "Position", UDim2.new(0, 0, 0, 0), 0.4)
            local savedOld = oldCont
            task.delay(0.4, function() 
                if lib.TabContainers[lib.ActiveTabIndex] ~= savedOld then savedOld.Visible = false end 
            end)
        else
            newCont.Position = UDim2.new(0, 0, 0, 0)
            newCont.Visible = true
            if oldCont and oldCont ~= defaultCont then oldCont.Visible = false end
        end
        
        lib.ActiveTabIndex = targetIdx
    end

    function lib:AddTab(data)
        local txt = data.Title or "Tab"
        local iconId = parseIcon(data.Icon)

        if not lib.UseTabs then
            lib.UseTabs = true
            tabArea.Visible = true
            contClip.Visible = true
            defaultCont.Visible = false
        end

        local btn = Instance.new("TextButton", tabListInner)
        btn.BackgroundTransparency = 1
        btn.FontFace = m3Font
        btn.Text = txt
        btn.TextSize = 14
        btn.TextTransparency = 1
        btn.TextColor3 = curTheme.out
        btn.Size = UDim2.new(0, 20, 1, 0) 
        btn.AutomaticSize = Enum.AutomaticSize.X 

        lib.CurrentSearchTab = btn 
        lib.CurrentSearchSection = nil

        local uip = Instance.new("UIPadding", btn)
        uip.PaddingLeft = UDim.new(0, 16)
        uip.PaddingRight = UDim.new(0, 16)

        local contentContainer = Instance.new("Frame", btn)
        contentContainer.Size = UDim2.new(1, 0, 1, 0)
        contentContainer.BackgroundTransparency = 1
        contentContainer.ZIndex = 2

        local contentLayout = Instance.new("UIListLayout", contentContainer)
        contentLayout.FillDirection = Enum.FillDirection.Horizontal
        contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        contentLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Padding = UDim.new(0, 8)

        local iconImg = nil
        if iconId and iconId ~= "" then
            iconImg = Instance.new("ImageLabel", contentContainer)
            iconImg.BackgroundTransparency = 1
            iconImg.Image = iconId
            iconImg.Size = UDim2.new(0, 18, 0, 18)
            iconImg.ImageColor3 = curTheme.out
            iconImg.LayoutOrder = 1
            iconImg.ZIndex = 2
        end
        
        local txtLbl = Instance.new("TextLabel", contentContainer)
        txtLbl.BackgroundTransparency = 1
        txtLbl.Text = txt
        txtLbl.FontFace = m3Font
        txtLbl.TextSize = 14
        txtLbl.RichText = true
        txtLbl.TextColor3 = curTheme.out
        txtLbl.AutomaticSize = Enum.AutomaticSize.XY
        txtLbl.LayoutOrder = 2
        txtLbl.ZIndex = 2
                
        local tData = {obj = btn, active = false, icon = iconImg, lbl = txtLbl}
        table.insert(objs.tab_btn, tData)
        
        local c = Instance.new("ScrollingFrame", contClip)
        c.Size = UDim2.new(1, 0, 1, 0)
        c.BackgroundTransparency = 1
        c.ScrollBarThickness = 0
        c.CanvasSize = UDim2.new(0, 0, 0, 0)
        c.AutomaticCanvasSize = Enum.AutomaticSize.Y
        c.Visible = false
        
        local cPad = Instance.new("UIPadding", c)
        cPad.PaddingLeft = UDim.new(0, 24)
        cPad.PaddingRight = UDim.new(0, 24)
        cPad.PaddingBottom = UDim.new(0, 20)
        cPad.PaddingTop = UDim.new(0, 20)

        local cLayout = Instance.new("UIListLayout", c)
        cLayout.SortOrder = Enum.SortOrder.LayoutOrder
        cLayout.Padding = UDim.new(0, 18)

        table.insert(lib.Tabs, {btn = btn, data = tData})
        table.insert(lib.TabContainers, c)
        
        lib.CurrentBuildContainer = c 

        btn.MouseButton1Click:Connect(function() 
            if not isDraggingTabAction then
                lib:SelectTab(txt) 
            end
        end)

        if #lib.Tabs == 1 then lib:SelectTab(txt) end
        
        return {
            SetText = function(self, newTxt)
                btn.Text = newTxt
                txtLbl.Text = newTxt
                if lib.ActiveTabIndex > 0 and lib.Tabs[lib.ActiveTabIndex].btn == btn then
                    lib:SelectTab(newTxt)
                end
            end
        }
    end

    function lib:Notify(data)
        local msg = data.Text or "Notification"
        local actions = data.Actions or {}
        local dur = data.Duration or 4
        
        local snk = Instance.new("Frame")
        snk.BackgroundColor3 = curTheme.bg:Lerp(Color3.new(1, 1, 1), 0.15)
        snk.Size = UDim2.new(0, 0, 0, 48)
        snk.AutomaticSize = Enum.AutomaticSize.X
        snk.BackgroundTransparency = 1 
        Instance.new("UICorner", snk).CornerRadius = UDim.new(0, 4)
        
        local layout = Instance.new("UIListLayout", snk)
        layout.FillDirection = Enum.FillDirection.Horizontal
        layout.VerticalAlignment = Enum.VerticalAlignment.Center
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        
        local hasAction = actionTxt and actionTxt ~= ""
        
        local pad = Instance.new("UIPadding", snk)
        pad.PaddingLeft = UDim.new(0, 16)
        pad.PaddingRight = UDim.new(0, 12) 
        
        local msgLbl = Instance.new("TextLabel", snk)
        msgLbl.BackgroundTransparency = 1
        msgLbl.Text = msg
        msgLbl.TextColor3 = curTheme.fg
        msgLbl.FontFace = m3Font
        msgLbl.RichText = true
        msgLbl.TextSize = 14
        msgLbl.AutomaticSize = Enum.AutomaticSize.X
        msgLbl.Size = UDim2.new(0, 0, 1, 0)
        msgLbl.LayoutOrder = 1
        
        local spacer = Instance.new("Frame", snk)
        spacer.BackgroundTransparency = 1
        spacer.Size = UDim2.new(0, 24, 1, 0)
        spacer.LayoutOrder = 2
        
        if #actions > 0 then
            for i = 1, math.min(#actions, 2) do 
                local actData = actions[i]
                local actBtn = Instance.new("TextButton", snk)
                actBtn.BackgroundTransparency = 1
                actBtn.Text = actData.Text or "Action"
                actBtn.TextColor3 = curTheme.pri
                actBtn.FontFace = Font.new(m3Font.Family, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
                actBtn.TextSize = 14
                actBtn.AutomaticSize = Enum.AutomaticSize.X
                actBtn.Size = UDim2.new(0, 0, 1, 0)
                actBtn.LayoutOrder = 2 + i
                
                local actPad = Instance.new("UIPadding", actBtn)
                actPad.PaddingRight = UDim.new(0, 12) 
                
                actBtn.MouseButton1Click:Connect(function()
                    if actData.Callback then actData.Callback() end
                    
                    tw:Create(snk, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0, 20)
                    }):Play()
                    
                    for _, v in pairs(snk:GetDescendants()) do
                        if v:IsA("TextLabel") or v:IsA("TextButton") then
                            tw:Create(v, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
                        elseif v:IsA("ImageButton") then
                            tw:Create(v, TweenInfo.new(0.3), {ImageTransparency = 1}):Play()
                        end
                    end
                    task.wait(0.3)
                    snk:Destroy()
                end)
            end
        else
            spacer.Size = UDim2.new(0, 12, 1, 0)
        end
        
        local closeBtn = Instance.new("ImageButton", snk)
        closeBtn.BackgroundTransparency = 1
        closeBtn.Image = parseIcon("x") or ""
        closeBtn.ImageColor3 = curTheme.out
        closeBtn.Size = UDim2.new(0, 24, 0, 24)
        closeBtn.LayoutOrder = 4
        
        closeBtn.MouseButton1Click:Connect(function()
            tw:Create(snk, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 20)
            }):Play()
            
            for _, v in pairs(snk:GetDescendants()) do
                if v:IsA("TextLabel") or v:IsA("TextButton") then
                    tw:Create(v, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
                elseif v:IsA("ImageButton") then
                    tw:Create(v, TweenInfo.new(0.3), {ImageTransparency = 1}):Play()
                end
            end
            
            task.wait(0.3)
            snk:Destroy()
        end)
        
        snk.Parent = notifCont
        
        snk.Position = UDim2.new(0, 0, 0, 20)
        tw:Create(snk, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0,
            Position = UDim2.new(0, 0, 0, 0)
        }):Play()
        
        for _, v in pairs(snk:GetDescendants()) do
            if v:IsA("TextLabel") or v:IsA("TextButton") then
                v.TextTransparency = 1
                tw:Create(v, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
            elseif v:IsA("ImageButton") then
                v.ImageTransparency = 1
                tw:Create(v, TweenInfo.new(0.4), {ImageTransparency = 0}):Play()
            end
        end
        
        task.spawn(function()
            while dur > 0 do
                dur = dur - task.wait(0.1)
            end
            
            tw:Create(snk, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 20)
            }):Play()
            
            for _, v in pairs(snk:GetDescendants()) do
                if v:IsA("TextLabel") or v:IsA("TextButton") then
                    tw:Create(v, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
                elseif v:IsA("ImageButton") then
                    tw:Create(v, TweenInfo.new(0.3), {ImageTransparency = 1}):Play()
                end
            end
            
            task.wait(0.3)
            snk:Destroy()
        end)
    end

    function lib:AddDivider()
        lib.ElementCounter += 1
        local div = Instance.new("Frame", lib.CurrentBuildContainer)
        div.Size = UDim2.new(1, 0, 0, 1)
        div.LayoutOrder = lib.ElementCounter
        div.BackgroundColor3 = curTheme.inact
        div.BorderSizePixel = 0
        table.insert(objs.inact, div)
        lib:RegisterElement(div, nil, "item")
    end

    function lib:AddSection(data)
        local txt = data.Text or "Section"
        lib.ElementCounter += 1

        local r = Instance.new("Frame", lib.CurrentBuildContainer)
        r.LayoutOrder = lib.ElementCounter
        r.Size = UDim2.new(1, 0, 0, 28)
        r.BackgroundTransparency = 1

        local lbl = Instance.new("TextLabel", r)
        lbl.Size = UDim2.new(1, -8, 1, 0)
        lbl.Position = UDim2.new(0, 4, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.RichText = true
        lbl.Text = txt
        lbl.TextColor3 = curTheme.out
        lbl.FontFace = Font.new(m3Font.Family, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
        lbl.TextSize = 14
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextYAlignment = Enum.TextYAlignment.Bottom

        table.insert(objs.icon, lbl) 
        lib:RegisterElement(r, txt, "item")

        return {
            SetText = function(self, newTxt)
                lbl.Text = newTxt
            end
        }
    end

    function lib:AddLabel(data)
        local txt = data.Text or "Label"
        local iconId = parseIcon(data.Icon)
        lib.ElementCounter += 1

        local r = Instance.new("Frame", lib.CurrentBuildContainer)
        r.LayoutOrder = lib.ElementCounter
        r.Size = UDim2.new(1, 0, 0, 32)
        r.BackgroundTransparency = 1

        local leftOffset = 0
        
        if iconId and iconId ~= "" then
            local icn = Instance.new("ImageLabel", r)
            icn.Size = UDim2.new(0, 20, 0, 20)
            icn.AnchorPoint = Vector2.new(0, 0.5)
            icn.Position = UDim2.new(0, 0, 0.5, 0)
            icn.BackgroundTransparency = 1
            icn.Image = iconId
            icn.ImageColor3 = curTheme.out
            table.insert(objs.icon, icn)
            leftOffset = 32
        end

        local l = Instance.new("TextLabel", r)
        l.Size = UDim2.new(1, -leftOffset, 1, 0)
        l.Position = UDim2.new(0, leftOffset, 0, 0)
        l.BackgroundTransparency = 1
        l.Text = txt
        l.RichText = true
        l.TextColor3 = curTheme.fg
        l.FontFace = m3Font
        l.TextSize = 14
        l.TextXAlignment = Enum.TextXAlignment.Left
        table.insert(objs.fg, l)
        lib:RegisterElement(r, txt, "item")

        return {
            SetText = function(self, newTxt)
                l.Text = newTxt
            end
        }
    end

    function lib:AddDialog(data)
        local title = data.Title
        local desc = data.Description
        local dialogBtns = data.Buttons or {{Text = "OK", Type = "text", Callback = nil}}
    
        local overlay = Instance.new("Frame", gui)
        overlay.Size = UDim2.new(1, 0, 1, 0)
        overlay.BackgroundColor3 = curTheme.bg
        overlay.BackgroundTransparency = 1
        overlay.Active = true
        overlay.Visible = true
        
        local dlgBox = Instance.new("Frame", overlay)
        dlgBox.Size = UDim2.new(0, 312, 0, 0) 
        dlgBox.AnchorPoint = Vector2.new(0.5, 0.5)
        dlgBox.Position = UDim2.new(0.5, 0, 0.5, 20)
        dlgBox.BackgroundColor3 = curTheme.bg:Lerp(curTheme.pri, 0.11)
        dlgBox.AutomaticSize = Enum.AutomaticSize.Y
        dlgBox.BackgroundTransparency = 1
        table.insert(objs.dlg_bg, dlgBox)
        
        Instance.new("UICorner", dlgBox).CornerRadius = UDim.new(0, 28)
     
        local dPad = Instance.new("UIPadding", dlgBox)
        dPad.PaddingLeft = UDim.new(0, 24)
        dPad.PaddingRight = UDim.new(0, 24)
        dPad.PaddingTop = UDim.new(0, 24)
        dPad.PaddingBottom = UDim.new(0, 24)
        
        local dLayout = Instance.new("UIListLayout", dlgBox)
        dLayout.SortOrder = Enum.SortOrder.LayoutOrder
        dLayout.Padding = UDim.new(0, 16)
        
        local dTitle = Instance.new("TextLabel", dlgBox)
        dTitle.Size = UDim2.new(1, 0, 0, 0)
        dTitle.AutomaticSize = Enum.AutomaticSize.Y
        dTitle.BackgroundTransparency = 1
        dTitle.Text = title or "Dialog Title"
        dTitle.RichText = true
        dTitle.TextColor3 = curTheme.fg
        dTitle.FontFace = Font.new(m3Font.Family, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
        dTitle.TextSize = 24 
        dTitle.TextXAlignment = Enum.TextXAlignment.Left
        dTitle.TextWrapped = true
        dTitle.TextTransparency = 1
        dTitle.LayoutOrder = 1
        table.insert(objs.dlg_fg, dTitle)
        
        local dDesc = Instance.new("TextLabel", dlgBox)
        dDesc.Size = UDim2.new(1, 0, 0, 0)
        dDesc.AutomaticSize = Enum.AutomaticSize.Y
        dDesc.BackgroundTransparency = 1
        dDesc.Text = desc or "Dialog description text goes here."
        dDesc.TextColor3 = curTheme.out
        dDesc.RichText = true
        dDesc.FontFace = m3Font
        dDesc.TextSize = 14 
        dDesc.TextXAlignment = Enum.TextXAlignment.Left
        dDesc.TextWrapped = true
        dDesc.TextTransparency = 1
        dDesc.LayoutOrder = 2
     
        local actCont = Instance.new("Frame", dlgBox)
        actCont.Size = UDim2.new(1, 0, 0, 40)
        actCont.BackgroundTransparency = 1
        actCont.LayoutOrder = 3
        
        local actLayout = Instance.new("UIListLayout", actCont)
        actLayout.FillDirection = Enum.FillDirection.Horizontal
        actLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        actLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        actLayout.SortOrder = Enum.SortOrder.LayoutOrder
        actLayout.Padding = UDim.new(0, 8)
    
        local function closeDialog()
            t(overlay, "BackgroundTransparency", 1, 0.3)
            tw:Create(dlgBox, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
                Position = UDim2.new(0.5, 0, 0.5, 20),
                BackgroundTransparency = 1
            }):Play()
            
            t(dTitle, "TextTransparency", 1, 0.2)
            t(dDesc, "TextTransparency", 1, 0.2)
        for _, b in pairs(actCont:GetChildren()) do
                if b:IsA("TextButton") then t(b, "TextTransparency", 1, 0.2) t(b, "BackgroundTransparency", 1, 0.2) end
            end
            
            task.delay(0.3, function() 
                overlay:Destroy()
            end)
        end
        
       local function makeBtn(bData)
            local btn = Instance.new("TextButton", actCont)
            local isFilled = string.lower(bData.Type or "text") == "filled"
            
            btn.BackgroundTransparency = isFilled and 0 or 1
            btn.BackgroundColor3 = isFilled and curTheme.pri or curTheme.bg
            btn.Text = bData.Text or "Button"
            btn.FontFace = Font.new(m3Font.Family, Enum.FontWeight.Medium, Enum.FontStyle.Normal)
            btn.TextSize = 14
            btn.TextColor3 = isFilled and curTheme.onpri or curTheme.pri
            btn.Size = UDim2.new(0, 0, 0, 40)
            btn.AutomaticSize = Enum.AutomaticSize.X
            btn.TextTransparency = 1
            Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
             
            if isFilled then
                table.insert(objs.pri, btn)
            end
            table.insert(objs.pri, btn)
            
            local padding = Instance.new("UIPadding", btn)
            padding.PaddingLeft = UDim.new(0, 16)
            padding.PaddingRight = UDim.new(0, 16)
            
            btn.MouseEnter:Connect(function()
                local hBg = isFilled and curTheme.fg or curTheme.pri
                local hTr = isFilled and 0 or 0.92
                t(btn, "BackgroundTransparency", hTr, 0.2)
                t(btn, "BackgroundColor3", hBg, 0.2)
            end)
            btn.MouseLeave:Connect(function()
                local iBg = isFilled and curTheme.pri or curTheme.bg
                local iTr = isFilled and 0 or 1
                t(btn, "BackgroundTransparency", iTr, 0.2)
                t(btn, "BackgroundColor3", iBg, 0.2)
            end)
            
            btn.MouseButton1Click:Connect(function()
                closeDialog()
                if bData.Callback then bData.Callback() end
            end)
        end
         
        for _, bData in ipairs(dialogBtns) do 
            makeBtn(bData) 
        end
         
        t(overlay, "BackgroundTransparency", 0.6, 0.4)
        tw:Create(dlgBox, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundTransparency = 0
        }):Play()
        
        t(dTitle, "TextTransparency", 0, 0.4)
        t(dDesc, "TextTransparency", 0, 0.4)
        for _, b in pairs(actCont:GetChildren()) do
            if b:IsA("TextButton") then t(b, "TextTransparency", 0, 0.4) end
        end
    end

    function lib:AddTextBox(data)
        local labelTxt = data.Title or "TextBox"
        local supportTxt = data.SupportText
        local leadingIconId = parseIcon(data.Icon)
        local cb = data.Callback
        lib.ElementCounter += 1

        local wrapper = Instance.new("Frame", lib.CurrentBuildContainer)
        wrapper.LayoutOrder = lib.ElementCounter
        wrapper.Size = UDim2.new(1, 0, 0, 0)
        wrapper.AutomaticSize = Enum.AutomaticSize.Y
        wrapper.BackgroundTransparency = 1
        
        local wrapLayout = Instance.new("UIListLayout", wrapper)
        wrapLayout.SortOrder = Enum.SortOrder.LayoutOrder
        wrapLayout.Padding = UDim.new(0, 4)

        local frame = Instance.new("Frame", wrapper)
        frame.LayoutOrder = 1
        frame.Size = UDim2.new(1, 0, 0, 56)
        frame.AutomaticSize = Enum.AutomaticSize.Y
        frame.BackgroundColor3 = curTheme.inact
        frame.BorderSizePixel = 0
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)
        table.insert(objs.inact, frame)
        
        local flatBot = Instance.new("Frame", frame)
        flatBot.Size = UDim2.new(1, 0, 0, 4)
        flatBot.Position = UDim2.new(0, 0, 1, -4)
        flatBot.BackgroundColor3 = curTheme.inact
        flatBot.BorderSizePixel = 0
        table.insert(objs.inact, flatBot)

        local leftOffset = 16
        if leadingIconId and leadingIconId ~= "" then
            local lIcn = Instance.new("ImageLabel", frame)
            lIcn.Size = UDim2.new(0, 20, 0, 20)
            lIcn.AnchorPoint = Vector2.new(0, 0.5)
            lIcn.Position = UDim2.new(0, 12, 0.5, 0)
            lIcn.BackgroundTransparency = 1
            lIcn.Image = leadingIconId
            lIcn.ImageColor3 = curTheme.out
            table.insert(objs.icon, lIcn)
            leftOffset = 44
        end

        local lbl = Instance.new("TextLabel", frame)
        lbl.Size = UDim2.new(1, -(leftOffset + 40), 0, 20)
        lbl.AnchorPoint = Vector2.new(0, 0)
        lbl.Position = UDim2.new(0, leftOffset, 0, 18)
        lbl.BackgroundTransparency = 1
        lbl.Text = labelTxt
        lbl.RichText = true
        lbl.TextColor3 = curTheme.out
        lbl.FontFace = m3Font
        lbl.TextSize = 15
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local tbox = Instance.new("TextBox", frame)
        tbox.Size = UDim2.new(1, -(leftOffset + 36), 0, 24)
        tbox.Position = UDim2.new(0, leftOffset, 0, 26)
        tbox.BackgroundTransparency = 1
        tbox.Text = ""
        tbox.PlaceholderText = ""
        tbox.TextColor3 = curTheme.fg
        tbox.FontFace = m3Font
        tbox.TextSize = 15
        tbox.TextXAlignment = Enum.TextXAlignment.Left
        tbox.TextYAlignment = Enum.TextYAlignment.Top
        tbox.ClearTextOnFocus = false
        
        tbox.TextWrapped = true
        tbox.AutomaticSize = Enum.AutomaticSize.Y
        
        local tbPad = Instance.new("UIPadding", tbox)
        tbPad.PaddingBottom = UDim.new(0, 8)

        local clearBtn = Instance.new("ImageButton", frame)
        clearBtn.Size = UDim2.new(0, 18, 0, 18)
        clearBtn.AnchorPoint = Vector2.new(1, 0.5)
        clearBtn.Position = UDim2.new(1, -12, 0.5, 0)
        clearBtn.BackgroundTransparency = 1
        clearBtn.Image = parseIcon("circle-x") or ""
        clearBtn.ImageColor3 = curTheme.out
        clearBtn.ImageTransparency = 1 
        clearBtn.Active = false
        table.insert(objs.icon, clearBtn)

        local botLine = Instance.new("Frame", frame)
        botLine.Size = UDim2.new(1, 0, 0, 1)
        botLine.AnchorPoint = Vector2.new(0, 1)
        botLine.Position = UDim2.new(0, 0, 1, 0)
        botLine.BackgroundColor3 = curTheme.out
        botLine.BorderSizePixel = 0

        if supportTxt and supportTxt ~= "" then
            local suppLbl = Instance.new("TextLabel", wrapper)
            suppLbl.LayoutOrder = 2
            suppLbl.Size = UDim2.new(1, -32, 0, 16)
            suppLbl.Position = UDim2.new(0, 16, 0, 0) 
            suppLbl.BackgroundTransparency = 1
            suppLbl.Text = supportTxt
            suppLbl.RichText = true
            suppLbl.TextColor3 = curTheme.out
            suppLbl.FontFace = m3Font
            suppLbl.TextSize = 12
            suppLbl.TextXAlignment = Enum.TextXAlignment.Left
            table.insert(objs.fg, suppLbl)
        end

        local tbData = {box = tbox, line = botLine, lbl = lbl, bg = frame, focused = false}
        table.insert(objs.tbox, tbData)

        local function updateState()
            local hasText = #tbox.Text > 0
            local isFoc = tbData.focused

        if isFoc or hasText then
                tw:Create(lbl, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {
                    Position = UDim2.new(0, leftOffset, 0, 6),
                    TextSize = 11,
                    TextColor3 = isFoc and curTheme.pri or curTheme.out
                }):Play()
            else
                tw:Create(lbl, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {
                    Position = UDim2.new(0, leftOffset, 0, 18),
                    TextSize = 15,
                    TextColor3 = curTheme.out
                }):Play()
            end

            if hasText then
                clearBtn.Active = true
                tw:Create(clearBtn, TweenInfo.new(0.2), {ImageTransparency = 0}):Play()
            else
                clearBtn.Active = false
                tw:Create(clearBtn, TweenInfo.new(0.2), {ImageTransparency = 1}):Play()
            end

            t(botLine, "BackgroundColor3", isFoc and curTheme.pri or curTheme.out, 0.2)
            tw:Create(botLine, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {Size = UDim2.new(1, 0, 0, isFoc and 2 or 1)}):Play()
        end

        tbox.Focused:Connect(function()
            tbData.focused = true; updateState()
        end)

        tbox.FocusLost:Connect(function(enter)
            tbData.focused = false; updateState()
            if cb then cb(tbox.Text, enter) end
        end)

        tbox:GetPropertyChangedSignal("Text"):Connect(updateState)

        clearBtn.MouseButton1Click:Connect(function()
            tbox.Text = ""
            updateState()
            tbox:CaptureFocus()
        end)

        frame.MouseEnter:Connect(function()
            if not tbData.focused then
                t(frame, "BackgroundColor3", curTheme.inact:Lerp(curTheme.fg, 0.05), 0.2)
                t(flatBot, "BackgroundColor3", curTheme.inact:Lerp(curTheme.fg, 0.05), 0.2)
            end
        end)
        frame.MouseLeave:Connect(function()
            t(frame, "BackgroundColor3", curTheme.inact, 0.2)
            t(flatBot, "BackgroundColor3", curTheme.inact, 0.2)
        end)

        lib:RegisterElement(wrapper, labelTxt, "item")

        return {
            SetText = function(self, newTxt) lbl.Text = newTxt end,
            SetValue = function(self, newVal)
                tbox.Text = tostring(newVal); updateState()
            end
        }
    end

    function lib:AddButton(data)
        local txt = data.Text or "Button"
        local btnType = data.Type or "filled"
        local wdth = data.Width
        local cb = data.Callback
        lib.ElementCounter += 1

        local container = Instance.new("Frame", lib.CurrentBuildContainer)
        container.LayoutOrder = lib.ElementCounter
        container.Size = UDim2.new(1, 0, 0, 44)
        container.BackgroundTransparency = 1

        local b = Instance.new("TextButton", container)

        if wdth then
            b.Size = UDim2.new(0, wdth, 1, 0)
            b.AnchorPoint = Vector2.new(0.5, 0.5)
            b.Position = UDim2.new(0.5, 0, 0.5, 0)
        else
            b.Size = UDim2.new(1, 0, 1, 0)
            b.Position = UDim2.new(0, 0, 0, 0)
        end
        
        b.Text = ""
        b.AutoButtonColor = false
        Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)

        local txl = Instance.new("TextLabel", b)
        txl.Size = UDim2.new(1, 0, 1, 0)
        txl.BackgroundTransparency = 1
        txl.Text = txt
        txl.RichText = true
        txl.FontFace = m3Font
        txl.TextSize = 15

        local bType = string.lower(btnType or "filled")
        local idleBgColor, hoverBgColor, idleTrans
        
        if bType == "tonal" then
            idleBgColor = curTheme.inact:Lerp(curTheme.pri, 0.15)
            hoverBgColor = curTheme.inact:Lerp(curTheme.pri, 0.25)
            idleTrans = 0
            b.BackgroundTransparency = idleTrans
            b.BackgroundColor3 = idleBgColor
            
            txl.TextColor3 = curTheme.fg
            table.insert(objs.fg, txl) 
            
            if not objs.tonal_bg then objs.tonal_bg = {} end
            table.insert(objs.tonal_bg, b)
            
        elseif bType == "outlined" then
            idleBgColor = curTheme.inact:Lerp(curTheme.fg, 0.05)
            hoverBgColor = idleBgColor
            idleTrans = 1
            b.BackgroundTransparency = idleTrans
            b.BackgroundColor3 = idleBgColor
            
            txl.TextColor3 = curTheme.pri
            table.insert(objs.pri, txl)
            
            local stroke = Instance.new("UIStroke", b)
            stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            stroke.Color = curTheme.out
            stroke.Transparency = 0.3
            stroke.Thickness = 1
            table.insert(objs.icon, stroke) 
            
        elseif bType == "text" then
            idleBgColor = curTheme.inact:Lerp(curTheme.fg, 0.05)
            hoverBgColor = idleBgColor
            idleTrans = 1
            b.BackgroundTransparency = idleTrans
            b.BackgroundColor3 = idleBgColor
            
            txl.TextColor3 = curTheme.pri
            table.insert(objs.pri, txl)
            
        else
            idleBgColor = curTheme.pri
            hoverBgColor = curTheme.fg
            idleTrans = 0
            b.BackgroundTransparency = idleTrans
            b.BackgroundColor3 = idleBgColor
            
            txl.TextColor3 = curTheme.onpri
            table.insert(objs.onpri, txl)
            table.insert(objs.pri, b)
        end

        b.MouseEnter:Connect(function() 
            local hBg
            if bType == "tonal" then hBg = curTheme.inact:Lerp(curTheme.pri, 0.25)
            elseif bType == "outlined" or bType == "text" then hBg = curTheme.inact:Lerp(curTheme.fg, 0.05)
            else hBg = curTheme.fg end
            
            t(b, "BackgroundColor3", hBg, 0.2)
            if bType == "outlined" or bType == "text" then
                t(b, "BackgroundTransparency", 0.9, 0.2)
            end
        end)

        b.MouseLeave:Connect(function() 
            local iBg, iTr
            if bType == "tonal" then iBg = curTheme.inact:Lerp(curTheme.pri, 0.15); iTr = 0
            elseif bType == "outlined" or bType == "text" then iBg = curTheme.inact:Lerp(curTheme.fg, 0.05); iTr = 1
            else iBg = curTheme.pri; iTr = 0 end
            
            t(b, "BackgroundColor3", iBg, 0.2)
            t(b, "BackgroundTransparency", iTr, 0.2)
        end)

        b.InputBegan:Connect(function(input)
            RippleEffect(b, input, curTheme.onpri)
        end)
        
        b.MouseButton1Click:Connect(function() 
            if cb then cb() end 
        end)

        lib:RegisterElement(container, txt, "item")
        
        return {
            SetText = function(self, newTxt)
                txl.Text = newTxt
            end
        }
    end

    function lib:AddSwitch(data)
        local txt = data.Title or "Switch"
        local def = data.Default or false
        local iconId = parseIcon(data.Icon)
        local cb = data.Callback
        lib.ElementCounter += 1
        local st = def or false
        local r = Instance.new("Frame", lib.CurrentBuildContainer)
        r.LayoutOrder = lib.ElementCounter
        r.Size = UDim2.new(1, 0, 0, 48)
        r.BackgroundTransparency = 1

        local leftOffset = 0
        
        if iconId and iconId ~= "" then
            local icn = Instance.new("ImageLabel", r)
            icn.Size = UDim2.new(0, 20, 0, 20)
            icn.AnchorPoint = Vector2.new(0, 0.5)
            icn.Position = UDim2.new(0, 0, 0.5, 0)
            icn.BackgroundTransparency = 1
            icn.Image = iconId
            icn.ImageColor3 = curTheme.out
            table.insert(objs.icon, icn)
            leftOffset = 32
        end

        local l = Instance.new("TextLabel", r)
        l.Size = UDim2.new(1, -(60 + leftOffset), 1, 0)
        l.Position = UDim2.new(0, leftOffset, 0, 0)
        l.BackgroundTransparency = 1
        l.Text = txt
        l.TextColor3 = curTheme.fg
        l.FontFace = m3Font
        l.RichText = true
        l.TextSize = 16
        l.TextXAlignment = Enum.TextXAlignment.Left
        table.insert(objs.fg, l)

        local trk = Instance.new("TextButton", r)
        trk.Size = UDim2.new(0, 52, 0, 32)
        trk.AnchorPoint = Vector2.new(1, 0.5)
        trk.Position = UDim2.new(1, 0, 0.5, 0)
        trk.BackgroundColor3 = st and curTheme.pri or curTheme.inact
        trk.Text = ""
        trk.AutoButtonColor = false
        Instance.new("UICorner", trk).CornerRadius = UDim.new(1, 0)
        local tData = {obj=trk, state=st}
        table.insert(objs.s_trk, tData)

        local thm = Instance.new("Frame", trk)
        thm.AnchorPoint = Vector2.new(0.5, 0.5)
        thm.Size = st and UDim2.new(0, 24, 0, 24) or UDim2.new(0, 16, 0, 16)
        thm.Position = st and UDim2.new(0, 36, 0.5, 0) or UDim2.new(0, 16, 0.5, 0)
        thm.BackgroundColor3 = st and curTheme.onpri or curTheme.out
        Instance.new("UICorner", thm).CornerRadius = UDim.new(1, 0)
        local thData = {obj=thm, state=st}
        table.insert(objs.s_thm, thData)

        trk.MouseButton1Click:Connect(function()
            st = not st
            tData.state = st; thData.state = st
            t(trk, "BackgroundColor3", st and curTheme.pri or curTheme.inact, 0.3)
            tw:Create(thm, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
                Size = st and UDim2.new(0, 24, 0, 24) or UDim2.new(0, 16, 0, 16),
                Position = st and UDim2.new(0, 36, 0.5, 0) or UDim2.new(0, 16, 0.5, 0),
                BackgroundColor3 = st and curTheme.onpri or curTheme.out
            }):Play()
            if cb then cb(st) end
        end)

        lib:RegisterElement(r, txt, "item")

        return {
            SetText = function(self, newTxt)
                l.Text = newTxt
            end,
            SetValue = function(self, newState)
                if st == newState then return end
                st = newState
                tData.state = st; thData.state = st
                t(trk, "BackgroundColor3", st and curTheme.pri or curTheme.inact, 0.3)
                tw:Create(thm, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
                    Size = st and UDim2.new(0, 24, 0, 24) or UDim2.new(0, 16, 0, 16),
                    Position = st and UDim2.new(0, 36, 0.5, 0) or UDim2.new(0, 16, 0.5, 0),
                    BackgroundColor3 = st and curTheme.onpri or curTheme.out
                }):Play()
                if cb then cb(st) end
            end
        }
    end

    function lib:AddSlider(data)
        local txt = data.Title or "Slider"
        local m = data.Min or 0
        local mx = data.Max or 100
        local df = data.Default or m
        local lblval = data.ShowValue
        if lblval == nil then lblval = true end
        local sizeStr = data.Size or "xs"
        local iconId = parseIcon(data.Icon)
        local cb = data.Callback
        lib.ElementCounter += 1
        
        local v = math.clamp(df or m, m, mx)
        local drag = false

        local sType = string.lower(sizeStr or "xs")
        local configs = {
            xs = {h = 16, cr = 8,  th = 44, icn = 0},
            s  = {h = 24, cr = 8,  th = 44, icn = 0},
            m  = {h = 40, cr = 12, th = 52, icn = 24},
            l  = {h = 56, cr = 16, th = 68, icn = 24},
            xl = {h = 96, cr = 28, th = 108, icn = 32}
        }
        local cfg = configs[sType] or configs.xs

        local r = Instance.new("Frame", lib.CurrentBuildContainer)
        r.LayoutOrder = lib.ElementCounter
        r.Size = UDim2.new(1, 0, 0, 35 + cfg.th) 
        r.BackgroundTransparency = 1

        local vl = Instance.new("TextLabel", r)
        vl.Size = UDim2.new(1, -50, 0, 20) 
        vl.BackgroundTransparency = 1
        vl.Text = txt
        vl.TextColor3 = curTheme.fg
        vl.FontFace = m3Font
        vl.RichText = true
        vl.TextSize = 14
        vl.TextXAlignment = Enum.TextXAlignment.Left
        table.insert(objs.fg, vl)

        local valLbl = Instance.new("TextLabel", r)
        valLbl.Size = UDim2.new(0, 50, 0, 20)
        valLbl.AnchorPoint = Vector2.new(1, 0)
        valLbl.Position = UDim2.new(1, 0, 0, 0)
        valLbl.BackgroundTransparency = 1
        valLbl.Visible = lblval
        valLbl.Text = string.format("%.2f", v)
        valLbl.TextColor3 = curTheme.out
        valLbl.FontFace = Font.new(m3Font.Family, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
        valLbl.RichText = true
        valLbl.TextSize = 14
        valLbl.TextXAlignment = Enum.TextXAlignment.Right
        table.insert(objs.sl_val, valLbl)

        local hb = Instance.new("TextButton", r)
        hb.Size = UDim2.new(1, 0, 0, cfg.th)
        hb.Position = UDim2.new(0, 0, 0, 25)
        hb.BackgroundTransparency = 1
        hb.Text = ""

        local act = Instance.new("CanvasGroup", hb)
        act.AnchorPoint = Vector2.new(0, 0.5)
        act.Position = UDim2.new(0, 0, 0.5, 0)
        act.BackgroundColor3 = curTheme.pri
        act.BorderSizePixel = 0
        local actuic = Instance.new("UICorner", act)
        actuic.CornerRadius = UDim.new(0, cfg.cr)
        actuic.TopRightRadius = UDim.new(0, 2)
        actuic.BottomRightRadius = UDim.new(0, 2)
        table.insert(objs.pri, act)

        if cfg.icn > 0 and iconId and iconId ~= "" then
            local slIcn = Instance.new("ImageLabel", act)
            slIcn.Size = UDim2.new(0, cfg.icn, 0, cfg.icn)
            slIcn.AnchorPoint = Vector2.new(0, 0.5)
            slIcn.Position = UDim2.new(0, 12, 0.5, 0)
            slIcn.BackgroundTransparency = 1
            slIcn.Image = iconId
            slIcn.ImageColor3 = curTheme.onpri
            table.insert(objs.onpri, slIcn)
        end

        local inact = Instance.new("CanvasGroup", hb)
        inact.AnchorPoint = Vector2.new(1, 0.5)
        inact.Position = UDim2.new(1, 0, 0.5, 0)
        inact.BackgroundColor3 = curTheme.inact
        inact.BorderSizePixel = 0
        local inactuic = Instance.new("UICorner", inact)
        inactuic.CornerRadius = UDim.new(0, cfg.cr)
        inactuic.TopLeftRadius = UDim.new(0, 2)
        inactuic.BottomLeftRadius = UDim.new(0, 2)
        table.insert(objs.inact, inact)

        local dot = Instance.new("Frame", inact)
        dot.Size = UDim2.new(0, 4, 0, 4)
        dot.AnchorPoint = Vector2.new(1, 0.5)
        dot.Position = UDim2.new(1, -8, 0.5, 0)
        dot.BackgroundColor3 = curTheme.pri
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
        table.insert(objs.pri, dot)

        local thm = Instance.new("Frame", hb)
        thm.Size = UDim2.new(0, 4, 0, cfg.th)
        thm.AnchorPoint = Vector2.new(0.5, 0.5)
        thm.BackgroundColor3 = curTheme.pri
        Instance.new("UICorner", thm).CornerRadius = UDim.new(0, 2)
        table.insert(objs.pri, thm)

        local totalGap = 12
        local halfGap = totalGap / 2 

        local function upd(inp, isClick)
            local pc = math.clamp((inp.Position.X - hb.AbsolutePosition.X) / hb.AbsoluteSize.X, 0, 1)
            v = m + ((mx - m) * pc)
            valLbl.Text = string.format("%.2f", v)
            
            local tx = hb.AbsoluteSize.X * pc
            local newActSize = UDim2.new(0, math.max(0, tx - halfGap), 0, cfg.h)
            local newInactSize = UDim2.new(0, math.max(0, hb.AbsoluteSize.X - tx - halfGap), 0, cfg.h)
            local newThmPos = UDim2.new(0, tx, 0.5, 0)

            local animTime = isClick and 0.3 or 0.05
            local tweenInfo = TweenInfo.new(animTime, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

            tw:Create(act, tweenInfo, {Size = newActSize}):Play()
            tw:Create(inact, tweenInfo, {Size = newInactSize}):Play()
            tw:Create(thm, tweenInfo, {Position = newThmPos}):Play()
        end

        task.defer(function()
            local p = (v - m) / (mx - m)
            local tX = hb.AbsoluteSize.X * p
            act.Size = UDim2.new(0, math.max(0, tX - halfGap), 0, cfg.h)
            inact.Size = UDim2.new(0, math.max(0, hb.AbsoluteSize.X - tX - halfGap), 0, cfg.h)
            thm.Position = UDim2.new(0, tX, 0.5, 0)
        end)

        hb:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            local p = (v - m) / (mx - m)
            local tX = hb.AbsoluteSize.X * p
            act.Size = UDim2.new(0, math.max(0, tX - halfGap), 0, cfg.h)
            inact.Size = UDim2.new(0, math.max(0, hb.AbsoluteSize.X - tX - halfGap), 0, cfg.h)
            thm.Position = UDim2.new(0, tX, 0.5, 0)
        end)

        hb.InputBegan:Connect(function(i) 
            if i.UserInputType.Name:find("MouseButton1") or i.UserInputType.Name:find("Touch") then 
                drag = true
                upd(i, true) 
            end 
        end)
        
        uis.InputChanged:Connect(function(i) 
            if drag and (i.UserInputType.Name:find("MouseMovement") or i.UserInputType.Name:find("Touch")) then 
                upd(i, false) 
            end 
        end)
        
        uis.InputEnded:Connect(function(i) 
            if i.UserInputType.Name:find("MouseButton1") or i.UserInputType.Name:find("Touch") then 
                if drag then
                    drag = false 
                    if cb then cb(v) end
                end
            end 
        end)

        lib:RegisterElement(r, txt, "item")

        return {
            SetText = function(self, newTxt) vl.Text = newTxt end,
            SetValue = function(self, newVal)
                v = math.clamp(newVal, m, mx)
                valLbl.Text = string.format("%.2f", v)
                
                local p = (v - m) / (mx - m)
                local tX = hb.AbsoluteSize.X * p
                act.Size = UDim2.new(0, math.max(0, tX - halfGap), 0, cfg.h)
                inact.Size = UDim2.new(0, math.max(0, hb.AbsoluteSize.X - tX - halfGap), 0, cfg.h)
                thm.Position = UDim2.new(0, tX, 0.5, 0)
                
                if cb then cb(v) end
            end
        }
    end

    function lib:AddDropdown(data)
        local labelTxt = data.Title or "Dropdown"
        local options = data.Options or {}
        local defaultIdx = data.Default or 1
        local leadingIconId = parseIcon(data.Icon)
        local cb = data.Callback
        lib.ElementCounter += 1
        local selectedIdx = defaultIdx or 1
        local currentOptions = options or {}
        local isOpen = false
    
        local frame = Instance.new("Frame", lib.CurrentBuildContainer)
        frame.LayoutOrder = lib.ElementCounter
        frame.Size = UDim2.new(1, 0, 0, 56)
        frame.AutomaticSize = Enum.AutomaticSize.Y
        frame.BackgroundColor3 = curTheme.inact
        frame.BorderSizePixel = 0
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)
        table.insert(objs.inact, frame)
    
        local flatBot = Instance.new("Frame", frame)
        flatBot.Size = UDim2.new(1, 0, 0, 4)
        flatBot.Position = UDim2.new(0, 0, 1, -4)
        flatBot.BackgroundColor3 = curTheme.inact
        flatBot.BorderSizePixel = 0
        table.insert(objs.inact, flatBot)

        local leftOffset = 16
        if leadingIconId and leadingIconId ~= "" then
            local lIcn = Instance.new("ImageLabel", frame)
            lIcn.Size = UDim2.new(0, 20, 0, 20)
            lIcn.AnchorPoint = Vector2.new(0, 0.5)
            lIcn.Position = UDim2.new(0, 12, 0.5, 0)
            lIcn.BackgroundTransparency = 1
            lIcn.Image = leadingIconId
            lIcn.ImageColor3 = curTheme.out
            table.insert(objs.icon, lIcn)
            leftOffset = 44
        end
    
        local lbl = Instance.new("TextLabel", frame)
        lbl.Size = UDim2.new(1, -(leftOffset + 40), 0, 20)
        lbl.Position = UDim2.new(0, leftOffset, 0, 6)
        lbl.BackgroundTransparency = 1
        lbl.Text = labelTxt
        lbl.RichText = true
        lbl.TextColor3 = curTheme.out
        lbl.FontFace = m3Font
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left
    
        local valLbl = Instance.new("TextLabel", frame)
        valLbl.Size = UDim2.new(1, -(leftOffset + 36), 0, 24)
        valLbl.Position = UDim2.new(0, leftOffset, 0, 26)
        valLbl.BackgroundTransparency = 1
        valLbl.Text = currentOptions[selectedIdx] or ""
        valLbl.TextColor3 = curTheme.fg
        valLbl.FontFace = m3Font
        valLbl.RichText = true
        valLbl.TextSize = 15
        valLbl.TextXAlignment = Enum.TextXAlignment.Left
        
        valLbl.TextWrapped = true
        valLbl.AutomaticSize = Enum.AutomaticSize.Y
        
        local valPad = Instance.new("UIPadding", valLbl)
        valPad.PaddingBottom = UDim.new(0, 8) 
        
        table.insert(objs.fg, valLbl)
    
        local icn = Instance.new("ImageLabel", frame)
        icn.Size = UDim2.new(0, 24, 0, 24)
        icn.AnchorPoint = Vector2.new(1, 0.5)
        icn.Position = UDim2.new(1, -12, 0.5, 0)
        icn.BackgroundTransparency = 1
        icn.Image = parseIcon("chevron-down") or ""
        icn.ImageColor3 = curTheme.out
        table.insert(objs.icon, icn)
    
        local btn = Instance.new("TextButton", frame)
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
    
        local botLine = Instance.new("Frame", frame)
        botLine.Size = UDim2.new(1, 0, 0, 1)
        botLine.AnchorPoint = Vector2.new(0, 1)
        botLine.Position = UDim2.new(0, 0, 1, 0)
        botLine.BackgroundColor3 = curTheme.out
        botLine.BorderSizePixel = 0

        local function updateState()
            t(botLine, "BackgroundColor3", isOpen and curTheme.pri or curTheme.out, 0.2)
            tw:Create(botLine, TweenInfo.new(0.2, Enum.EasingStyle.Exponential), {Size = UDim2.new(1, 0, 0, isOpen and 2 or 1)}):Play()
            t(lbl, "TextColor3", isOpen and curTheme.pri or curTheme.out, 0.2)
            tw:Create(icn, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {Rotation = isOpen and 180 or 0}):Play()
            if isOpen then t(icn, "ImageColor3", curTheme.pri, 0.2) else t(icn, "ImageColor3", curTheme.out, 0.2) end
        end
    
        local menuObj = nil
        local trackConn = nil
        local closeOverlay = nil
        
        local function closeMenu()
            if not isOpen then return end
            isOpen = false
            updateState()
            
            if trackConn then trackConn:Disconnect() end
            if closeOverlay then closeOverlay:Destroy(); closeOverlay = nil end
            
            if menuObj then
                t(menuObj, "BackgroundTransparency", 1, 0.2)
                for _, child in pairs(menuObj:GetChildren()) do
                    if child:IsA("TextButton") then
                        t(child, "TextTransparency", 1, 0.2)
                        t(child, "BackgroundTransparency", 1, 0.2)
                    end
                end
                task.delay(0.2, function()
                    if menuObj then menuObj:Destroy() menuObj = nil end
                end)
            end
        end
    
        btn.MouseButton1Click:Connect(function()
            if isOpen then
                closeMenu()
            else
                isOpen = true
                updateState()
                
                closeOverlay = Instance.new("TextButton", gui)
                closeOverlay.Size = UDim2.new(1, 0, 1, 0)
                closeOverlay.BackgroundTransparency = 1
                closeOverlay.Text = ""
                closeOverlay.ZIndex = 499
                closeOverlay.MouseButton1Click:Connect(closeMenu)

                menuObj = Instance.new("ScrollingFrame", gui)
                menuObj.Size = UDim2.new(0, frame.AbsoluteSize.X, 0, math.min(#currentOptions * 48, 144))
                menuObj.Position = UDim2.new(0, frame.AbsolutePosition.X, 0, frame.AbsolutePosition.Y + frame.AbsoluteSize.Y)
                menuObj.BackgroundColor3 = curTheme.bg:Lerp(curTheme.pri, 0.08)
                menuObj.BorderSizePixel = 0
                menuObj.ZIndex = 500
                menuObj.ScrollBarThickness = 2
                menuObj.ScrollBarImageColor3 = curTheme.out
                menuObj.BackgroundTransparency = 1
                menuObj.ClipsDescendants = true
                menuObj.AutomaticCanvasSize = Enum.AutomaticSize.Y
                menuObj.CanvasSize = UDim2.new(0, 0, 0, 0)
                
                local mCorner = Instance.new("UICorner", menuObj)
                mCorner.CornerRadius = UDim.new(0, 4) 
                mCorner.BottomLeftRadius = UDim.new(0, 4)
                mCorner.BottomRightRadius = UDim.new(0, 4)
                table.insert(objs.dlg_bg, menuObj) 

                trackConn = rs.RenderStepped:Connect(function()
                    if not isOpen or not menuObj then trackConn:Disconnect() return end
                    menuObj.Position = UDim2.new(0, frame.AbsolutePosition.X, 0, frame.AbsolutePosition.Y + frame.AbsoluteSize.Y)
                end)
    
                local mLayout = Instance.new("UIListLayout", menuObj)
                mLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
                for i, opt in ipairs(currentOptions) do
                    local optBtn = Instance.new("TextButton", menuObj)
                    optBtn.Size = UDim2.new(1, 0, 0, 48)
                    
                    if i == selectedIdx then
                        optBtn.BackgroundColor3 = curTheme.inact:Lerp(curTheme.pri, 0.15)
                        optBtn.BackgroundTransparency = 1
                    else
                        optBtn.BackgroundColor3 = curTheme.inact:Lerp(curTheme.fg, 0.05)
                        optBtn.BackgroundTransparency = 1
                    end

                    optBtn.Text = opt
                    optBtn.FontFace = m3Font
                    optBtn.TextSize = 14
                    optBtn.TextColor3 = curTheme.fg
                    optBtn.TextXAlignment = Enum.TextXAlignment.Left
                    optBtn.LayoutOrder = i
                    optBtn.ZIndex = 501
                    optBtn.TextTransparency = 1
                    optBtn.AutoButtonColor = false
                    table.insert(objs.dlg_fg, optBtn)
                    
                    local p = Instance.new("UIPadding", optBtn)
                    p.PaddingLeft = UDim.new(0, 16)
                    p.PaddingRight = UDim.new(0, 16)
    
                    optBtn.MouseEnter:Connect(function() 
                        if i ~= selectedIdx then t(optBtn, "BackgroundTransparency", 0.7, 0.1) end
                    end)
                    optBtn.MouseLeave:Connect(function() 
                        if i ~= selectedIdx then t(optBtn, "BackgroundTransparency", 1, 0.1) end
                    end)

                    optBtn.InputBegan:Connect(function(input)
                        RippleEffect(optBtn, input, curTheme.fg)
                    end)
    
                    optBtn.MouseButton1Click:Connect(function()
                        selectedIdx = i
                        valLbl.Text = opt
                        if cb then cb(opt) end
                        closeMenu()
                    end)
                end
    
                tw:Create(menuObj, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
                for i, child in ipairs(menuObj:GetChildren()) do
                    if child:IsA("TextButton") then
                        t(child, "TextTransparency", 0, 0.3)
                        if child.LayoutOrder == selectedIdx then
                            t(child, "BackgroundTransparency", 0, 0.3)
                        end
                    end
                end
            end
        end)

        frame.MouseEnter:Connect(function()
            if not isOpen then
                t(frame, "BackgroundColor3", curTheme.inact:Lerp(curTheme.fg, 0.05), 0.2)
                t(flatBot, "BackgroundColor3", curTheme.inact:Lerp(curTheme.fg, 0.05), 0.2)
            end
        end)
        frame.MouseLeave:Connect(function()
            t(frame, "BackgroundColor3", curTheme.inact, 0.2)
            t(flatBot, "BackgroundColor3", curTheme.inact, 0.2)
        end)

        lib:RegisterElement(frame, labelTxt, "item")

        return {
            SetText = function(self, newTxt) lbl.Text = newTxt end,
            SetValue = function(self, newOpt)
                valLbl.Text = newOpt
                if cb then cb(newOpt) end
            end,
            Refresh = function(self, newOptions, newDefaultIdx)
                currentOptions = newOptions or {}
                selectedIdx = newDefaultIdx or 1
                valLbl.Text = currentOptions[selectedIdx] or ""
                if isOpen then closeMenu() end
            end
        }
    end

    resizeHandle = Instance.new("TextButton", win)
    resizeHandle.Size = UDim2.new(0, 30, 0, 30)
    resizeHandle.AnchorPoint = Vector2.new(1, 1)
    resizeHandle.Position = UDim2.new(1, 0, 1, 0)
    resizeHandle.BackgroundTransparency = 1
    resizeHandle.Text = ""
    resizeHandle.ZIndex = 100

    local resizing = false
    local resDragStart, resStartSize

    resizeHandle.InputBegan:Connect(function(i)
        if isMin or isMax then return end 
        if i.UserInputType.Name:find("MouseButton1") or i.UserInputType.Name:find("Touch") then
            resizing = true
            resDragStart = i.Position
            resStartSize = win.AbsoluteSize
        end
    end)

    uis.InputChanged:Connect(function(i)
        if resizing and (i.UserInputType.Name:find("MouseMovement") or i.UserInputType.Name:find("Touch")) then
            local delta = i.Position - resDragStart
            local newX = math.max(320, resStartSize.X + delta.X)
            local newY = math.max(400, resStartSize.Y + delta.Y)
            win.Size = UDim2.new(0, newX, 0, newY)
        end
    end)

    uis.InputEnded:Connect(function(i)
        if i.UserInputType.Name:find("MouseButton1") or i.UserInputType.Name:find("Touch") then
            resizing = false
        end
    end)

    win:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        if lib.ActiveTabIndex > 0 and lib.Tabs[lib.ActiveTabIndex] then
            task.spawn(function()
                rs.RenderStepped:Wait() 
                rs.RenderStepped:Wait()
                local btn = lib.Tabs[lib.ActiveTabIndex].btn
                local btnCenterX = (btn.AbsolutePosition.X - tabListCont.AbsolutePosition.X) + tabListCont.CanvasPosition.X + (btn.AbsoluteSize.X / 2)
                local contentWidth = lib.Tabs[lib.ActiveTabIndex].data.lbl.TextBounds.X
                indicator.Position = UDim2.new(0, btnCenterX, 1, 0)
                indicator.Size = UDim2.new(0, contentWidth, 0, 3)
            end)
        end
    end)

    local d, di, ds, sp
    win.InputBegan:Connect(function(i) 
        if i.UserInputType.Name:find("MouseButton1") or i.UserInputType.Name:find("Touch") then 
            if isMax then return end 
            d = true; ds = i.Position; sp = win.Position 
        end 
    end)
    
    win.InputEnded:Connect(function(i) 
        if i.UserInputType.Name:find("MouseButton1") or i.UserInputType.Name:find("Touch") then 
            d = false 
        end 
    end)
    
    uis.InputChanged:Connect(function(i) 
        if i.UserInputType.Name:find("MouseMovement") or i.UserInputType.Name:find("Touch") then 
            di = i 
        end 
    end)
    
    rs.RenderStepped:Connect(function() 
        if d and di and not resizing then 
            win.Position = UDim2.new(sp.X.Scale, sp.X.Offset + (di.Position - ds).X, sp.Y.Scale, sp.Y.Offset + (di.Position - ds).Y) 
        end 
    end)

    tw:Create(win, TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, finalSizeX, 0, finalSizeY),
        Transparency = 0
    }):Play()

    return setmetatable(lib, {
        __index = {
            SetTitle = function(self, newTitle)
                top.Text = newTitle
            end
        }
    })
end

function NoxLibrary.Create(data)
    return CreateNox(data)
end

return NoxLibrary
