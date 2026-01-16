--[[
    Roblox Disconnect Monitor
    Authors: Antigravity & User
    Description: Monitors CoreGui for Disconnection prompts and sends Webhook alerts.
    Usage: getgenv().webhook = "URL"; loadstring(...)()
]]

local Settings = {
    WebhookUrl = "", -- Placeholder (overridden by getgenv().webhook)
    UseWebhook = true
}

local CoreGui = game:GetService("CoreGui")
local RobloxPromptGui = CoreGui:WaitForChild("RobloxPromptGui", 10)

if not RobloxPromptGui then
    warn("Failed to find RobloxPromptGui. This script requires an executor with CoreGui access.")
    return
end

local promptOverlay = RobloxPromptGui:WaitForChild("promptOverlay", 10)

local function onPromptShown()
    task.wait(0.5)
    
    local prompt = promptOverlay:FindFirstChild("ErrorPrompt")
    if prompt then
        
        local titleText = "Unknown Title"
        local messageText = "Unknown Message"

        local function findText(parent, name)
            local obj = parent:FindFirstChild(name, true)
            return (obj and obj:IsA("TextLabel") and obj.Text) or nil
        end

        titleText = findText(prompt, "TitleText") or findText(prompt, "Title") or titleText
        messageText = findText(prompt, "ErrorMessage") or findText(prompt, "Message") or messageText
        
        local fullText = (titleText .. " " .. messageText):lower()
        
        if string.find(fullText, "disconnect") or string.find(fullText, "desconectado") or
           string.find(fullText, "kick") or string.find(fullText, "expulso") or
           string.find(fullText, "ban") or string.find(fullText, "idle") or
           string.find(fullText, "inatividade") or string.find(fullText, "conn") or 
           string.find(fullText, "error") or string.find(fullText, "erro") then
            
            print("------------------------------------------------")
            warn("⚠️ DISCONNECTION DETECTED (Generic) ⚠️")
            print("Title: " .. titleText)
            print("Message: " .. messageText)
            print("Timestamp: " .. os.date("%X"))
            print("------------------------------------------------")
            
            pcall(function()
                local currentTime = os.date("%X")
                local notification = "Status: Desconectado\nMotivo: " .. messageText .. "\nHora: " .. currentTime
                
                if writefile then
                    writefile("disconnect_log.txt", notification)
                    print("✅ Arquivo de sinal criado! O arquivo .bat deve detectar agora.")
                else
                    warn("❌ Seu executor não suporta 'writefile'.")
                end
                -- 2. Send Discord Webhook
                local targetWebhook = Settings.WebhookUrl
                
                -- Priority Check: Global Variable overrides settings
                if getgenv and getgenv().webhook and getgenv().webhook ~= "" then
                    targetWebhook = getgenv().webhook
                    print("✅ Webhook detectado via Executor (Global Variable)")
                elseif _G.webhook and _G.webhook ~= "" then
                    targetWebhook = _G.webhook
                    print("✅ Webhook detectado via _G")
                end

                -- Debug Print (Masked)
                if targetWebhook and targetWebhook ~= "" then
                    print("ℹ️ Tentando enviar para: " .. targetWebhook:sub(1, 30) .. "...")
                else
                    warn("⚠️ NENHUM Webhook encontrado! Defina getgenv().webhook = 'url' antes de executar.")
                end

                if Settings.UseWebhook and targetWebhook ~= "" then
                    local req = (syn and syn.request) or (http and http.request) or http_request or fluxus.request or request
                    
                    if req then
                        req({
                            Url = targetWebhook,
                            Method = "POST",
                            Headers = {
                                ["Content-Type"] = "application/json"
                            },
                            Body = game:GetService("HttpService"):JSONEncode({
                                content = "🚨 **ALERTA: Voce foi desconectado do Roblox as (" .. currentTime .. ")** 🚨\n> **Motivo:** " .. messageText
                            })
                        })
                        print("✅ Notificacao enviada para o Discord!")
                    else
                        warn("❌ Executor nao suporta requisicoes HTTP (request/syn.request).")
                    end
                end
            end)
            
        else
             print("[Debug] Prompt Detected but unknown content: " .. fullText)
        end
    end
end

if promptOverlay then
    promptOverlay.ChildAdded:Connect(onPromptShown)
    
    if promptOverlay:FindFirstChild("ErrorPrompt") then
        onPromptShown()
    end
    
    print("✅ Disconnect Monitor Started. Waiting for disconnects...")
    
    pcall(function()
        local TweenService = game:GetService("TweenService")
        local UserInputService = game:GetService("UserInputService")
        local RunService = game:GetService("RunService")
        
        local screen = Instance.new("ScreenGui")
        screen.Name = "DisconnectMonitorHUD"
        screen.ResetOnSpawn = false
        screen.Parent = CoreGui
        
        local frame = Instance.new("Frame")
        frame.Name = "MainFrame"
        frame.Size = UDim2.new(0, 260, 0, 70)
        frame.Position = UDim2.new(0.5, -130, 0.1, 0)
        frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        frame.BackgroundTransparency = 1 
        frame.BorderSizePixel = 0
        frame.ClipsDescendants = false
        frame.Parent = screen
        
        local uiCorner = Instance.new("UICorner")
        uiCorner.CornerRadius = UDim.new(0, 10)
        uiCorner.Parent = frame
        
        local bgImage = Instance.new("ImageLabel")
        bgImage.Name = "Background"
        bgImage.Size = UDim2.new(1, 0, 1, 0)
        bgImage.Position = UDim2.new(0, 0, 0, 0)
        bgImage.BackgroundTransparency = 1 
        bgImage.ScaleType = Enum.ScaleType.Crop
        bgImage.ImageColor3 = Color3.fromRGB(255, 255, 255)
        bgImage.ZIndex = 1 
        bgImage.Parent = frame
        
        task.spawn(function()
            local imageUrl = "https://cdn.discordapp.com/attachments/1399234975261524000/1461185106462113846/Oh_My_God.png?ex=6969a22c&is=696850ac&hm=834e2e7127c9444030a85837aec7e47978847a6f6e6d9325e9ce32abb08aba1f&"
            local fileName = "disconnect_monitor_bg_v5.png"
            
            local success, response = pcall(function()
                return game:HttpGet(imageUrl)
            end)
            
            if success and type(response) == "string" and #response > 0 and writefile and getcustomasset then
                writefile(fileName, response)
                bgImage.Image = getcustomasset(fileName)
            else
                warn("Failed to download image: " .. tostring(response))
                bgImage.Image = imageUrl
            end
        end)
        
        local bgCorner = Instance.new("UICorner")
        bgCorner.CornerRadius = UDim.new(0, 10)
        bgCorner.Parent = bgImage
        
        local overlay = Instance.new("Frame")
        overlay.Size = UDim2.new(1, 0, 1, 0)
        overlay.BackgroundColor3 = Color3.new(0, 0, 0)
        overlay.BackgroundTransparency = 0.85
        overlay.ZIndex = 2
        overlay.Parent = frame
        local overlayCorner = Instance.new("UICorner")
        overlayCorner.CornerRadius = UDim.new(0, 10)
        overlayCorner.Parent = overlay
        
        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 3
        stroke.Parent = frame
        
        local gradient = Instance.new("UIGradient")
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 30)),
            ColorSequenceKeypoint.new(0.40, Color3.fromRGB(30, 30, 30)),
            ColorSequenceKeypoint.new(0.50, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.60, Color3.fromRGB(30, 30, 30)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 30))
        })
        gradient.Rotation = 0
        gradient.Parent = stroke
        
        task.spawn(function()
            local rotation = 0
            while frame.Parent do
                rotation = (rotation + 2) % 360 
                gradient.Rotation = rotation
                RunService.RenderStepped:Wait() 
            end
        end)
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = "Monitor Conectado!\n(Xeno Compatible)"
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 16
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.ZIndex = 2
        label.Parent = frame
        
        local padding = Instance.new("UIPadding")
        padding.PaddingLeft = UDim.new(0, 15)
        padding.Parent = label
        
        local textStroke = Instance.new("UIStroke")
        textStroke.Transparency = 0.5
        textStroke.Thickness = 2
        textStroke.Parent = label
        
        local dragging, dragInput, dragStart, startPos
        
        local function update(input)
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
        
        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position
                
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        
        frame.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                dragInput = input
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                update(input)
            end
        end)
        
        frame.Position = UDim2.new(0.5, -130, -0.2, 0)
        TweenService:Create(frame, TweenInfo.new(1, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -130, 0.1, 0)}):Play()
    end)    
else
    warn("Could not find promptOverlay.")
end
