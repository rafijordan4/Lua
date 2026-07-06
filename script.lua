-- ============================================================
-- SOULGPT PANEL v3.0 - FULL
-- Load with: loadstring(game:HttpGet("https://raw.githubusercontent.com/rafijordan4/Lua/main/script.lua"))()
-- Config diambil dari IM.json di repo yang sama
-- ============================================================

-- ============================================================
-- 1. SERVICE DECLARATIONS
-- ============================================================
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local ClipboardService = game:GetService("ClipboardService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- ============================================================
-- 2. KONFIGURASI URL (GANTI DENGAN USERNAME REPO KAMU)
-- ============================================================
local REPO_RAW = "https://raw.githubusercontent.com/rafijordan4/Lua/main/"
local CONFIG_URL = REPO_RAW .. "IM.json"

-- ============================================================
-- 3. LOAD CONFIG DARI IM.json
-- ============================================================
local CONFIG = {}
local configLoaded = false

local function loadConfig()
    print("⏳ Loading config from IM.json...")
    local success, response = pcall(function()
        return game:HttpGet(CONFIG_URL)
    end)
    
    if success and response then
        local decoded = HttpService:JSONDecode(response)
        if decoded then
            CONFIG = decoded
            configLoaded = true
            print("✅ Config loaded from IM.json!")
            print("   Model:", CONFIG.GROQ_MODEL)
            print("   Debug:", CONFIG.DEBUG_MODE)
            return
        end
    end
    
    -- Fallback jika gagal
    warn("⚠️ Failed to load IM.json! Using fallback config.")
    CONFIG = {
        GROQ_API_KEY = "",
        GROQ_URL = "https://api.groq.com/openai/v1/chat/completions",
        GROQ_MODEL = "llama3-70b-8192",
        PANEL_TITLE = "⚡ SoulGPT Panel v3.0",
        DONASI_USERNAME = "Rafi_jordan4",
        DONASI_TIKTOK = "@rafi_gemoy9",
        DEBUG_MODE = true
    }
end

loadConfig()

-- ============================================================
-- 4. EXTRACT CONFIG
-- ============================================================
local GROQ_API_KEY = CONFIG.GROQ_API_KEY or ""
local GROQ_URL = CONFIG.GROQ_URL or "https://api.groq.com/openai/v1/chat/completions"
local GROQ_MODEL = CONFIG.GROQ_MODEL or "llama3-70b-8192"
local PANEL_TITLE = CONFIG.PANEL_TITLE or "⚡ SoulGPT Panel v3.0"
local DONASI_USERNAME = CONFIG.DONASI_USERNAME or "Rafi_jordan4"
local DONASI_TIKTOK = CONFIG.DONASI_TIKTOK or "@rafi_gemoy9"
local DEBUG_MODE = CONFIG.DEBUG_MODE or false

-- ============================================================
-- 5. DEBUG HELPER
-- ============================================================
local function debugLog(...)
    if DEBUG_MODE then
        print("[DEBUG] SoulGPT:", ...)
    end
end

debugLog("Panel initializing...")
debugLog("Model:", GROQ_MODEL)
debugLog("API Key length:", string.len(GROQ_API_KEY))
debugLog("Config loaded from JSON:", configLoaded)

-- ============================================================
-- 6. CREATE UI
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SoulGPTPanel"
screenGui.Parent = Player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

debugLog("ScreenGui created")

-- ============================================================
-- 7. MAIN FRAME
-- ============================================================
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 520, 0, 440)
mainFrame.Position = UDim2.new(0.5, -260, 0.5, -220)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BackgroundTransparency = 0.92
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Thickness = 1.5
stroke.Color = Color3.fromRGB(100, 200, 255)
stroke.Transparency = 0.4
stroke.Parent = mainFrame

-- ============================================================
-- 8. TITLE BAR
-- ============================================================
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 44)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
titleBar.BackgroundTransparency = 0.5
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 14)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = PANEL_TITLE
titleLabel.TextColor3 = Color3.fromRGB(220, 240, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -40, 0, 6)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
closeBtn.BackgroundTransparency = 0.6
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

-- ============================================================
-- 9. DRAGGABLE SYSTEM
-- ============================================================
local dragging = false
local dragStart, startPos

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

RunService.RenderStepped:Connect(function()
    if dragging then
        local delta = UserInputService:GetMouseDelta()
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- ============================================================
-- 10. TAB NAVIGATION
-- ============================================================
local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(1, 0, 0, 42)
tabFrame.Position = UDim2.new(0, 0, 0, 44)
tabFrame.BackgroundTransparency = 1
tabFrame.Parent = mainFrame

local tabs = {"🔑 API Keys", "🤖 AI Chat", "💖 Donasi"}
local tabButtons = {}
local contentFrames = {}

for i, tabName in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1/3, -6, 1, -6)
    btn.Position = UDim2.new((i-1)/3, 4, 0, 3)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    btn.BackgroundTransparency = 0.4
    btn.Text = tabName
    btn.TextColor3 = Color3.fromRGB(200, 200, 230)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamMedium
    btn.BorderSizePixel = 0
    btn.Parent = tabFrame
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    tabButtons[i] = btn
    
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, -10, 1, -100)
    content.Position = UDim2.new(0, 5, 0, 90)
    content.BackgroundTransparency = 1
    content.ScrollBarThickness = 4
    content.ScrollBarImageColor3 = Color3.fromRGB(100, 150, 255)
    content.BorderSizePixel = 0
    content.Visible = (i == 1)
    content.Parent = mainFrame
    contentFrames[i] = content
    
    -- ============================================================
    -- TAB 1: API KEYS
    -- ============================================================
    if i == 1 then
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 30)
        label.Position = UDim2.new(0, 0, 0, 5)
        label.BackgroundTransparency = 1
        label.Text = "🔐 Generate & Kelola API Key"
        label.TextColor3 = Color3.fromRGB(150, 200, 255)
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.Parent = content
        
        local genBtn = Instance.new("TextButton")
        genBtn.Size = UDim2.new(0.8, 0, 0, 40)
        genBtn.Position = UDim2.new(0.1, 0, 0, 40)
        genBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        genBtn.Text = "🚀 Generate API Key Baru"
        genBtn.TextColor3 = Color3.new(1,1,1)
        genBtn.TextScaled = true
        genBtn.Font = Enum.Font.GothamBold
        genBtn.BorderSizePixel = 0
        genBtn.Parent = content
        local genCorner = Instance.new("UICorner")
        genCorner.CornerRadius = UDim.new(0, 10)
        genCorner.Parent = genBtn
        
        local keyDisplay = Instance.new("TextBox")
        keyDisplay.Size = UDim2.new(0.8, 0, 0, 35)
        keyDisplay.Position = UDim2.new(0.1, 0, 0, 90)
        keyDisplay.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
        keyDisplay.Text = "Klik Generate untuk buat key"
        keyDisplay.TextColor3 = Color3.fromRGB(180, 200, 255)
        keyDisplay.TextScaled = true
        keyDisplay.Font = Enum.Font.GothamMedium
        keyDisplay.ClearTextOnFocus = false
        keyDisplay.BorderSizePixel = 1
        keyDisplay.BorderColor3 = Color3.fromRGB(60, 60, 100)
        keyDisplay.Parent = content
        local keyCorner = Instance.new("UICorner")
        keyCorner.CornerRadius = UDim.new(0, 6)
        keyCorner.Parent = keyDisplay
        
        local inputKey = Instance.new("TextBox")
        inputKey.Size = UDim2.new(0.8, 0, 0, 35)
        inputKey.Position = UDim2.new(0.1, 0, 0, 135)
        inputKey.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
        inputKey.PlaceholderText = "Masukkan API Key di sini..."
        inputKey.Text = ""
        inputKey.TextColor3 = Color3.fromRGB(200, 200, 255)
        inputKey.TextScaled = true
        inputKey.Font = Enum.Font.GothamMedium
        inputKey.ClearTextOnFocus = true
        inputKey.BorderSizePixel = 1
        inputKey.BorderColor3 = Color3.fromRGB(60, 60, 100)
        inputKey.Parent = content
        local inputCorner = Instance.new("UICorner")
        inputCorner.CornerRadius = UDim.new(0, 6)
        inputCorner.Parent = inputKey
        
        local saveBtn = Instance.new("TextButton")
        saveBtn.Size = UDim2.new(0.4, 0, 0, 35)
        saveBtn.Position = UDim2.new(0.3, 0, 0, 180)
        saveBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        saveBtn.Text = "💾 Simpan Key"
        saveBtn.TextColor3 = Color3.new(1,1,1)
        saveBtn.TextScaled = true
        saveBtn.Font = Enum.Font.GothamBold
        saveBtn.BorderSizePixel = 0
        saveBtn.Parent = content
        local saveCorner = Instance.new("UICorner")
        saveCorner.CornerRadius = UDim.new(0, 10)
        saveCorner.Parent = saveBtn
        
        local hackNotif = Instance.new("TextLabel")
        hackNotif.Size = UDim2.new(0.8, 0, 0, 30)
        hackNotif.Position = UDim2.new(0.1, 0, 0, 225)
        hackNotif.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        hackNotif.BackgroundTransparency = 0.3
        hackNotif.Text = "⚠️ Hack Gio Belum Aktif"
        hackNotif.TextColor3 = Color3.fromRGB(255, 200, 200)
        hackNotif.TextScaled = true
        hackNotif.Font = Enum.Font.GothamBold
        hackNotif.BorderSizePixel = 0
        hackNotif.Parent = content
        local hackCorner = Instance.new("UICorner")
        hackCorner.CornerRadius = UDim.new(0, 8)
        hackCorner.Parent = hackNotif
        
        genBtn.MouseButton1Click:Connect(function()
            local newKey = HttpService:GenerateGUID(false)
            keyDisplay.Text = newKey
            hackNotif.Text = "🔥 Hack Gio AKTIF! Key: " .. string.sub(newKey, 1, 8) .. "..."
            hackNotif.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
            local tween = TweenService:Create(hackNotif, TweenInfo.new(0.5), {BackgroundTransparency = 0})
            tween:Play()
            wait(2)
            tween = TweenService:Create(hackNotif, TweenInfo.new(0.5), {BackgroundTransparency = 0.3})
            tween:Play()
        end)
        
        saveBtn.MouseButton1Click:Connect(function()
            local key = inputKey.Text
            if key ~= "" then
                GROQ_API_KEY = key
                hackNotif.Text = "✅ API Key tersimpan! Sistem siap."
                hackNotif.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
                wait(1.5)
                hackNotif.Text = "🔒 Hack Gio Siap Digunakan"
                hackNotif.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
            else
                hackNotif.Text = "❌ Masukkan API Key terlebih dahulu!"
                hackNotif.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            end
        end)
    
    -- ============================================================
    -- TAB 2: AI CHAT
    -- ============================================================
    elseif i == 2 then
        local chatLabel = Instance.new("TextLabel")
        chatLabel.Size = UDim2.new(1, 0, 0, 30)
        chatLabel.Position = UDim2.new(0, 0, 0, 5)
        chatLabel.BackgroundTransparency = 1
        chatLabel.Text = "🤖 Chat AI (Groq - " .. GROQ_MODEL .. ")"
        chatLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
        chatLabel.TextScaled = true
        chatLabel.Font = Enum.Font.GothamBold
        chatLabel.Parent = content
        
        local chatDisplay = Instance.new("ScrollingFrame")
        chatDisplay.Size = UDim2.new(0.9, 0, 0, 140)
        chatDisplay.Position = UDim2.new(0.05, 0, 0, 40)
        chatDisplay.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
        chatDisplay.BackgroundTransparency = 0.5
        chatDisplay.BorderSizePixel = 1
        chatDisplay.BorderColor3 = Color3.fromRGB(60, 60, 100)
        chatDisplay.ScrollBarThickness = 4
        chatDisplay.Parent = content
        local chatCorner = Instance.new("UICorner")
        chatCorner.CornerRadius = UDim.new(0, 8)
        chatCorner.Parent = chatDisplay
        
        local chatContent = Instance.new("TextLabel")
        chatContent.Size = UDim2.new(1, -10, 0, 20)
        chatContent.Position = UDim2.new(0, 5, 0, 5)
        chatContent.BackgroundTransparency = 1
        chatContent.Text = "Ketik pertanyaan di bawah..."
        chatContent.TextColor3 = Color3.fromRGB(180, 180, 220)
        chatContent.TextScaled = true
        chatContent.TextWrapped = true
        chatContent.Font = Enum.Font.GothamMedium
        chatContent.Parent = chatDisplay
        
        local chatInput = Instance.new("TextBox")
        chatInput.Size = UDim2.new(0.7, 0, 0, 40)
        chatInput.Position = UDim2.new(0.05, 0, 0, 190)
        chatInput.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
        chatInput.PlaceholderText = "Tanya tentang Roblox..."
        chatInput.Text = ""
        chatInput.TextColor3 = Color3.fromRGB(200, 200, 255)
        chatInput.TextScaled = true
        chatInput.Font = Enum.Font.GothamMedium
        chatInput.ClearTextOnFocus = true
        chatInput.BorderSizePixel = 1
        chatInput.BorderColor3 = Color3.fromRGB(60, 60, 100)
        chatInput.Parent = content
        local chatInputCorner = Instance.new("UICorner")
        chatInputCorner.CornerRadius = UDim.new(0, 8)
        chatInputCorner.Parent = chatInput
        
        local sendBtn = Instance.new("TextButton")
        sendBtn.Size = UDim2.new(0.2, 0, 0, 40)
        sendBtn.Position = UDim2.new(0.77, 0, 0, 190)
        sendBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
        sendBtn.Text = "Kirim"
        sendBtn.TextColor3 = Color3.new(1,1,1)
        sendBtn.TextScaled = true
        sendBtn.Font = Enum.Font.GothamBold
        sendBtn.BorderSizePixel = 0
        sendBtn.Parent = content
        local sendCorner = Instance.new("UICorner")
        sendCorner.CornerRadius = UDim.new(0, 10)
        sendCorner.Parent = sendBtn
        
        local function askAI(query)
            if GROQ_API_KEY == "" then
                chatContent.Text = "⚠️ Masukkan API Key dulu di tab API Keys!"
                return
            end
            chatContent.Text = "⏳ Memproses..."
            local headers = {
                ["Authorization"] = "Bearer " .. GROQ_API_KEY,
                ["Content-Type"] = "application/json"
            }
            local body = {
                model = GROQ_MODEL,
                messages = {
                    {role = "system", content = "Kamu adalah asisten AI ahli Roblox dan coding Luau."},
                    {role = "user", content = query}
                },
                temperature = 0.7,
                max_tokens = 500
            }
            local success, response = pcall(function()
                return HttpService:PostAsync(GROQ_URL, HttpService:JSONEncode(body), Enum.HttpContentType.ApplicationJson, false, headers)
            end)
            if success then
                local data = HttpService:JSONDecode(response)
                if data and data.choices and data.choices[1] then
                    local reply = data.choices[1].message.content
                    chatContent.Text = "🤖 " .. reply
                else
                    chatContent.Text = "❌ Error: Response tidak valid."
                end
            else
                chatContent.Text = "❌ Gagal konek ke Groq. Cek API Key atau internet."
            end
        end
        
        sendBtn.MouseButton1Click:Connect(function()
            local query = chatInput.Text
            if query ~= "" then
                askAI(query)
            else
                chatContent.Text = "⚠️ Masukkan pertanyaan!"
            end
        end)
        
        chatInput.FocusLost:Connect(function(enterPressed)
            if enterPressed then
                sendBtn.MouseButton1Click:Fire()
            end
        end)
    
    -- ============================================================
    -- TAB 3: DONASI
    -- ============================================================
    elseif i == 3 then
        local donasiLabel = Instance.new("TextLabel")
        donasiLabel.Size = UDim2.new(1, 0, 0, 30)
        donasiLabel.Position = UDim2.new(0, 0, 0, 5)
        donasiLabel.BackgroundTransparency = 1
        donasiLabel.Text = "💖 Support Developer"
        donasiLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        donasiLabel.TextScaled = true
        donasiLabel.Font = Enum.Font.GothamBold
        donasiLabel.Parent = content
        
        local info1 = Instance.new("TextLabel")
        info1.Size = UDim2.new(0.9, 0, 0, 30)
        info1.Position = UDim2.new(0.05, 0, 0, 45)
        info1.BackgroundTransparency = 1
        info1.Text = "👤 Roblox User: " .. DONASI_USERNAME
        info1.TextColor3 = Color3.fromRGB(200, 200, 255)
        info1.TextScaled = true
        info1.Font = Enum.Font.GothamMedium
        info1.Parent = content
        
        local info2 = Instance.new("TextLabel")
        info2.Size = UDim2.new(0.9, 0, 0, 30)
        info2.Position = UDim2.new(0.05, 0, 0, 80)
        info2.BackgroundTransparency = 1
        info2.Text = "📱 TikTok: " .. DONASI_TIKTOK
        info2.TextColor3 = Color3.fromRGB(200, 200, 255)
        info2.TextScaled = true
        info2.Font = Enum.Font.GothamMedium
        info2.Parent = content         local copyBtn = Instance.new("TextButton")
        copyBtn.Size = UDim2.new(0.6, 0, 0, 45)
        copyBtn.Position = UDim2.new(0.2, 0, 0, 125)
        copyBtn.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
        copyBtn.Text = "📋 Salin Username Roblox"
        copyBtn.TextColor3 = Color3.new(0.1, 0.1, 0.1)
        copyBtn.TextScaled = true
        copyBtn.Font = Enum.Font.GothamBold
        copyBtn.BorderSizePixel = 0
        copyBtn.Parent = content
        local copyCorner = Instance.new("UICorner")
        copyCorner.CornerRadius = UDim.new(0, 12)
        copyCorner.Parent = copyBtn
        
        copyBtn.MouseButton1Click:Connect(function()
            ClipboardService:SetClipboard(DONASI_USERNAME)
            local notif = Instance.new("TextLabel")
            notif.Size = UDim2.new(0.6, 0, 0, 30)
            notif.Position = UDim2.new(0.2, 0, 0, 180)
            notif.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
            notif.BackgroundTransparency = 0.2
            notif.Text = "✅ Disalin! Kirim donasi ya ❤️"
            notif.TextColor3 = Color3.new(1,1,1)
            notif.TextScaled = true
            notif.Font = Enum.Font.GothamBold
            notif.BorderSizePixel = 0
            notif.Parent = content
            local notifCorner = Instance.new("UICorner")
            notifCorner.CornerRadius = UDim.new(0, 8)
            notifCorner.Parent = notif
            wait(2)
            notif:Destroy()
        end)
        
        local tiktokBtn = Instance.new("TextButton")
        tiktokBtn.Size = UDim2.new(0.6, 0, 0, 45)
        tiktokBtn.Position = UDim2.new(0.2, 0, 0, 185)
        tiktokBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        tiktokBtn.Text = "🎵 Buka TikTok " .. DONASI_TIKTOK
        tiktokBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        tiktokBtn.TextScaled = true
        tiktokBtn.Font = Enum.Font.GothamBold
        tiktokBtn.BorderSizePixel = 1
        tiktokBtn.BorderColor3 = Color3.fromRGB(255, 0, 80)
        tiktokBtn.Parent = content
        local tiktokCorner = Instance.new("UICorner")
        tiktokCorner.CornerRadius = UDim.new(0, 12)
        tiktokCorner.Parent = tiktokBtn
        
        tiktokBtn.MouseButton1Click:Connect(function()
            local notif = Instance.new("TextLabel")
            notif.Size = UDim2.new(0.8, 0, 0, 30)
            notif.Position = UDim2.new(0.1, 0, 0, 240)
            notif.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            notif.BackgroundTransparency = 0.2
            notif.Text = "🔗 Buka TikTok manual: " .. DONASI_TIKTOK
            notif.TextColor3 = Color3.new(1,1,1)
            notif.TextScaled = true
            notif.Font = Enum.Font.GothamBold
            notif.BorderSizePixel = 0
            notif.Parent = content
            local notifCorner = Instance.new("UICorner")
            notifCorner.CornerRadius = UDim.new(0, 8)
            notifCorner.Parent = notif
            wait(2.5)
            notif:Destroy()
        end)
    end
end

-- ============================================================
-- 11. TAB SWITCHING
-- ============================================================
for i, btn in ipairs(tabButtons) do
    btn.MouseButton1Click:Connect(function()
        for j, frame in ipairs(contentFrames) do
            frame.Visible = (j == i)
        end
        for _, b in ipairs(tabButtons) do
            b.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            b.TextColor3 = Color3.fromRGB(200, 200, 230)
        end
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 120)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
end
tabButtons[1].BackgroundColor3 = Color3.fromRGB(60, 60, 120)
tabButtons[1].TextColor3 = Color3.fromRGB(255, 255, 255)

-- ============================================================
-- 12. ANIMASI MASUK
-- ============================================================
mainFrame.BackgroundTransparency = 1
mainFrame.Size = UDim2.new(0, 0, 0, 0)
local tweenIn = TweenService:Create(mainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
    BackgroundTransparency = 0.92,
    Size = UDim2.new(0, 520, 0, 440)
})
tweenIn:Play()

print("✅ SoulGPT Panel v3.0 Loaded! Selamat bereksperimen Alfatih.")
debugLog("Panel ready!")
debugLog("Config source: IM.json")
debugLog("Model:", GROQ_MODEL)
        
        
        
-- ============================================================
-- 2. EXTRACT CONFIG
-- ============================================================
local GROQ_API_KEY = CONFIG.GROQ_API_KEY or ""
local GROQ_URL = CONFIG.GROQ_URL or "https://api.groq.com/openai/v1/chat/completions"
local GROQ_MODEL = CONFIG.GROQ_MODEL or "llama3-70b-8192"
local PANEL_TITLE = CONFIG.PANEL_TITLE or "⚡ SoulGPT Panel"
local DONASI_USERNAME = CONFIG.DONASI_USERNAME or "Rafi_jordan4"
local DONASI_TIKTOK = CONFIG.DONASI_TIKTOK or "@rafi_gemoy9"
local DEBUG_MODE = CONFIG.DEBUG_MODE or false

-- ============================================================
-- 3. DEBUG
-- ============================================================
local function debugLog(...)
    if DEBUG_MODE then print("[DEBUG] SoulGPT:", ...) end
end

debugLog("Panel loaded!")

-- ============================================================
-- 4. CREATE UI
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SoulGPTPanel"
screenGui.Parent = Player.PlayerGui
screenGui.ResetOnSpawn = false

-- ============================================================
-- 5. MAIN FRAME
-- ============================================================
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 520, 0, 440)
mainFrame.Position = UDim2.new(0.5, -260, 0.5, -220)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BackgroundTransparency = 0.92
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Thickness = 1.5
stroke.Color = Color3.fromRGB(100, 200, 255)
stroke.Transparency = 0.4
stroke.Parent = mainFrame

-- ============================================================
-- 6. TITLE BAR
-- ============================================================
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 44)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
titleBar.BackgroundTransparency = 0.5
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 14)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = PANEL_TITLE
titleLabel.TextColor3 = Color3.fromRGB(220, 240, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -40, 0, 6)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
closeBtn.BackgroundTransparency = 0.6
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

-- ============================================================
-- 7. DRAGGABLE SYSTEM
-- ============================================================
local dragging = false
local dragStart, startPos

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

RunService.RenderStepped:Connect(function()
    if dragging then
        local delta = UserInputService:GetMouseDelta()
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- ============================================================
-- 8. TAB NAVIGATION
-- ============================================================
local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(1, 0, 0, 42)
tabFrame.Position = UDim2.new(0, 0, 0, 44)
tabFrame.BackgroundTransparency = 1
tabFrame.Parent = mainFrame

local tabs = {"🔑 API Keys", "🤖 AI Chat", "💖 Donasi"}
local tabButtons = {}
local contentFrames = {}

for i, tabName in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1/3, -6, 1, -6)
    btn.Position = UDim2.new((i-1)/3, 4, 0, 3)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    btn.BackgroundTransparency = 0.4
    btn.Text = tabName
    btn.TextColor3 = Color3.fromRGB(200, 200, 230)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamMedium
    btn.BorderSizePixel = 0
    btn.Parent = tabFrame
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    tabButtons[i] = btn
    
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, -10, 1, -100)
    content.Position = UDim2.new(0, 5, 0, 90)
    content.BackgroundTransparency = 1
    content.ScrollBarThickness = 4
    content.ScrollBarImageColor3 = Color3.fromRGB(100, 150, 255)
    content.BorderSizePixel = 0
    content.Visible = (i == 1)
    content.Parent = mainFrame
    contentFrames[i] = content
    
    -- ============================================================
    -- TAB 1: API KEYS
    -- ============================================================
    if i == 1 then
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 30)
        label.Position = UDim2.new(0, 0, 0, 5)
        label.BackgroundTransparency = 1
        label.Text = "🔐 Generate & Kelola API Key"
        label.TextColor3 = Color3.fromRGB(150, 200, 255)
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.Parent = content
        
        local genBtn = Instance.new("TextButton")
        genBtn.Size = UDim2.new(0.8, 0, 0, 40)
        genBtn.Position = UDim2.new(0.1, 0, 0, 40)
        genBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        genBtn.Text = "🚀 Generate API Key Baru"
        genBtn.TextColor3 = Color3.new(1,1,1)
        genBtn.TextScaled = true
        genBtn.Font = Enum.Font.GothamBold
        genBtn.BorderSizePixel = 0
        genBtn.Parent = content
        local genCorner = Instance.new("UICorner")
        genCorner.CornerRadius = UDim.new(0, 10)
        genCorner.Parent = genBtn
        
        local keyDisplay = Instance.new("TextBox")
        keyDisplay.Size = UDim2.new(0.8, 0, 0, 35)
        keyDisplay.Position = UDim2.new(0.1, 0, 0, 90)
        keyDisplay.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
        keyDisplay.Text = "Klik Generate untuk buat key"
        keyDisplay.TextColor3 = Color3.fromRGB(180, 200, 255)
        keyDisplay.TextScaled = true
        keyDisplay.Font = Enum.Font.GothamMedium
        keyDisplay.ClearTextOnFocus = false
        keyDisplay.BorderSizePixel = 1
        keyDisplay.BorderColor3 = Color3.fromRGB(60, 60, 100)
        keyDisplay.Parent = content
        local keyCorner = Instance.new("UICorner")
        keyCorner.CornerRadius = UDim.new(0, 6)
        keyCorner.Parent = keyDisplay
        
        local inputKey = Instance.new("TextBox")
        inputKey.Size = UDim2.new(0.8, 0, 0, 35)
        inputKey.Position = UDim2.new(0.1, 0, 0, 135)
        inputKey.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
        inputKey.PlaceholderText = "Masukkan API Key di sini..."
        inputKey.Text = ""
        inputKey.TextColor3 = Color3.fromRGB(200, 200, 255)
        inputKey.TextScaled = true
        inputKey.Font = Enum.Font.GothamMedium
        inputKey.ClearTextOnFocus = true
        inputKey.BorderSizePixel = 1
        inputKey.BorderColor3 = Color3.fromRGB(60, 60, 100)
        inputKey.Parent = content
        local inputCorner = Instance.new("UICorner")
        inputCorner.CornerRadius = UDim.new(0, 6)
        inputCorner.Parent = inputKey
        
        local saveBtn = Instance.new("TextButton")
        saveBtn.Size = UDim2.new(0.4, 0, 0, 35)
        saveBtn.Position = UDim2.new(0.3, 0, 0, 180)
        saveBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        saveBtn.Text = "💾 Simpan Key"
        saveBtn.TextColor3 = Color3.new(1,1,1)
        saveBtn.TextScaled = true
        saveBtn.Font = Enum.Font.GothamBold
        saveBtn.BorderSizePixel = 0
        saveBtn.Parent = content
        local saveCorner = Instance.new("UICorner")
        saveCorner.CornerRadius = UDim.new(0, 10)
        saveCorner.Parent = saveBtn
        
        local hackNotif = Instance.new("TextLabel")
        hackNotif.Size = UDim2.new(0.8, 0, 0, 30)
        hackNotif.Position = UDim2.new(0.1, 0, 0, 225)
        hackNotif.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        hackNotif.BackgroundTransparency = 0.3
        hackNotif.Text = "⚠️ Hack Gio Belum Aktif"
        hackNotif.TextColor3 = Color3.fromRGB(255, 200, 200)
        hackNotif.TextScaled = true
        hackNotif.Font = Enum.Font.GothamBold
        hackNotif.BorderSizePixel = 0
        hackNotif.Parent = content
        local hackCorner = Instance.new("UICorner")
        hackCorner.CornerRadius = UDim.new(0, 8)
        hackCorner.Parent = hackNotif
        
        genBtn.MouseButton1Click:Connect(function()
            local newKey = HttpService:GenerateGUID(false)
            keyDisplay.Text = newKey
            hackNotif.Text = "🔥 Hack Gio AKTIF! Key: " .. string.sub(newKey, 1, 8) .. "..."
            hackNotif.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
            local tween = TweenService:Create(hackNotif, TweenInfo.new(0.5), {BackgroundTransparency = 0})
            tween:Play()
            wait(2)
            tween = TweenService:Create(hackNotif, TweenInfo.new(0.5), {BackgroundTransparency = 0.3})
            tween:Play()
        end)
        
        saveBtn.MouseButton1Click:Connect(function()
            local key = inputKey.Text
            if key ~= "" then
                GROQ_API_KEY = key
                hackNotif.Text = "✅ API Key tersimpan! Sistem siap."
                hackNotif.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
                wait(1.5)
                hackNotif.Text = "🔒 Hack Gio Siap Digunakan"
                hackNotif.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
            else
                hackNotif.Text = "❌ Masukkan API Key terlebih dahulu!"
                hackNotif.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            end
        end)
    
    -- ============================================================
    -- TAB 2: AI CHAT
    -- ============================================================
    elseif i == 2 then
        local chatLabel = Instance.new("TextLabel")
        chatLabel.Size = UDim2.new(1, 0, 0, 30)
        chatLabel.Position = UDim2.new(0, 0, 0, 5)
        chatLabel.BackgroundTransparency = 1
        chatLabel.Text = "🤖 Chat AI (Groq - " .. GROQ_MODEL .. ")"
        chatLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
        chatLabel.TextScaled = true
        chatLabel.Font = Enum.Font.GothamBold
        chatLabel.Parent = content
        
        local chatDisplay = Instance.new("ScrollingFrame")
        chatDisplay.Size = UDim2.new(0.9, 0, 0, 140)
        chatDisplay.Position = UDim2.new(0.05, 0, 0, 40)
        chatDisplay.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
        chatDisplay.BackgroundTransparency = 0.5
        chatDisplay.BorderSizePixel = 1
        chatDisplay.BorderColor3 = Color3.fromRGB(60, 60, 100)
        chatDisplay.ScrollBarThickness = 4
        chatDisplay.Parent = content
        local chatCorner = Instance.new("UICorner")
        chatCorner.CornerRadius = UDim.new(0, 8)
        chatCorner.Parent = chatDisplay
        
        local chatContent = Instance.new("TextLabel")
        chatContent.Size = UDim2.new(1, -10, 0, 20)
        chatContent.Position = UDim2.new(0, 5, 0, 5)
        chatContent.BackgroundTransparency = 1
        chatContent.Text = "Ketik pertanyaan di bawah..."
        chatContent.TextColor3 = Color3.fromRGB(180, 180, 220)
        chatContent.TextScaled = true
        chatContent.TextWrapped = true
        chatContent.Font = Enum.Font.GothamMedium
        chatContent.Parent = chatDisplay
        
        local chatInput = Instance.new("TextBox")
        chatInput.Size = UDim2.new(0.7, 0, 0, 40)
        chatInput.Position = UDim2.new(0.05, 0, 0, 190)
        chatInput.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
        chatInput.PlaceholderText = "Tanya tentang Roblox..."
        chatInput.Text = ""
        chatInput.TextColor3 = Color3.fromRGB(200, 200, 255)
        chatInput.TextScaled = true
        chatInput.Font = Enum.Font.GothamMedium
        chatInput.ClearTextOnFocus = true
        chatInput.BorderSizePixel = 1
        chatInput.BorderColor3 = Color3.fromRGB(60, 60, 100)
        chatInput.Parent = content
        local chatInputCorner = Instance.new("UICorner")
        chatInputCorner.CornerRadius = UDim.new(0, 8)
        chatInputCorner.Parent = chatInput
        
        local sendBtn = Instance.new("TextButton")
        sendBtn.Size = UDim2.new(0.2, 0, 0, 40)
        sendBtn.Position = UDim2.new(0.77, 0, 0, 190)
        sendBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
        sendBtn.Text = "Kirim"
        sendBtn.TextColor3 = Color3.new(1,1,1)
        sendBtn.TextScaled = true
        sendBtn.Font = Enum.Font.GothamBold
        sendBtn.BorderSizePixel = 0
        sendBtn.Parent = content
        local sendCorner = Instance.new("UICorner")
        sendCorner.CornerRadius = UDim.new(0, 10)
        sendCorner.Parent = sendBtn
        
        local function askAI(query)
            if GROQ_API_KEY == "" then
                chatContent.Text = "⚠️ Masukkan API Key dulu di tab API Keys!"
                return
            end
            chatContent.Text = "⏳ Memproses..."
            local headers = {
                ["Authorization"] = "Bearer " .. GROQ_API_KEY,
                ["Content-Type"] = "application/json"
            }
            local body = {
                model = GROQ_MODEL,
                messages = {
                    {role = "system", content = "Kamu adalah asisten AI ahli Roblox dan coding Luau."},
                    {role = "user", content = query}
                },
                temperature = 0.7,
                max_tokens = 500
            }
            local success, response = pcall(function()
                return HttpService:PostAsync(GROQ_URL, HttpService:JSONEncode(body), Enum.HttpContentType.ApplicationJson, false, headers)
            end)
            if success then
                local data = HttpService:JSONDecode(response)
                if data and data.choices and data.choices[1] then
                    local reply = data.choices[1].message.content
                    chatContent.Text = "🤖 " .. reply
                else
                    chatContent.Text = "❌ Error: Response tidak valid."
                end
            else
                chatContent.Text = "❌ Gagal konek ke Groq. Cek API Key atau internet."
            end
        end
        
        sendBtn.MouseButton1Click:Connect(function()
            local query = chatInput.Text
            if query ~= "" then
                askAI(query)
            else
                chatContent.Text = "⚠️ Masukkan pertanyaan!"
            end
        end)
        
        chatInput.FocusLost:Connect(function(enterPressed)
            if enterPressed then
                sendBtn.MouseButton1Click:Fire()
            end
        end)
    
    -- ============================================================
    -- TAB 3: DONASI
    -- ============================================================
    elseif i == 3 then
        local donasiLabel = Instance.new("TextLabel")
        donasiLabel.Size = UDim2.new(1, 0, 0, 30)
        donasiLabel.Position = UDim2.new(0, 0, 0, 5)
        donasiLabel.BackgroundTransparency = 1
        donasiLabel.Text = "💖 Support Developer"
        donasiLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        donasiLabel.TextScaled = true
        donasiLabel.Font = Enum.Font.GothamBold
        donasiLabel.Parent = content
        
        local info1 = Instance.new("TextLabel")
        info1.Size = UDim2.new(0.9, 0, 0, 30)
        info1.Position = UDim2.new(0.05, 0, 0, 45)
        info1.BackgroundTransparency = 1
        info1.Text = "👤 Roblox User: " .. DONASI_USERNAME
        info1.TextColor3 = Color3.fromRGB(200, 200, 255)
        info1.TextScaled = true
        info1.Font = Enum.Font.GothamMedium
        info1.Parent = content
        
        local info2 = Instance.new("TextLabel")
        info2.Size = UDim2.new(0.9, 0, 0, 30)
        info2.Position = UDim2.new(0.05, 0, 0, 80)
        info2.BackgroundTransparency = 1
        info2.Text = "📱 TikTok: " .. DONASI_TIKTOK
        info2.TextColor3 = Color3.fromRGB(200, 200, 255)
        info2.TextScaled = true
        info2.Font = Enum.Font.GothamMedium
        info2.Parent = content
        
        local copyBtn = Instance.new("TextButton")
        copyBtn.Size = UDim2.new(0.6, 0, 0, 45)
        copyBtn.Position = UDim2.new(0.2, 0, 0, 125)
        copyBtn.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
        copyBtn.Text = "📋 Salin Username Roblox"
        copyBtn.TextColor3 = Color3.new(0.1, 0.1, 0.1)
        copyBtn.TextScaled = true
        copyBtn.Font = Enum.Font.GothamBold
        copyBtn.BorderSizePixel = 0
        copyBtn.Parent = content
        local copyCorner = Instance.new("UICorner")
        copyCorner.CornerRadius = UDim.new(0, 12)
        copyCorner.Parent = copyBtn
        
        copyBtn.MouseButton1Click:Connect(function()
            ClipboardService:SetClipboard(DONASI_USERNAME)
            local notif = Instance.new("TextLabel")
            notif.Size = UDim2.new(0.6, 0, 0, 30)
            notif.Position = UDim2.new(0.2, 0, 0, 180)
            notif.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
            notif.BackgroundTransparency = 0.2
            notif.Text = "✅ Disalin! Kirim donasi ya ❤️"
                        notif.TextColor3 = Color3.new(1,1,1)
            notif.TextScaled = true
            notif.Font = Enum.Font.GothamBold
            notif.BorderSizePixel = 0
            notif.Parent = content
            local notifCorner = Instance.new("UICorner")
            notifCorner.CornerRadius = UDim.new(0, 8)
            notifCorner.Parent = notif
            wait(2)
            notif:Destroy()
        end)
        
        local tiktokBtn = Instance.new("TextButton")
        tiktokBtn.Size = UDim2.new(0.6, 0, 0, 45)
        tiktokBtn.Position = UDim2.new(0.2, 0, 0, 185)
        tiktokBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        tiktokBtn.Text = "🎵 Buka TikTok " .. DONASI_TIKTOK
        tiktokBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        tiktokBtn.TextScaled = true
        tiktokBtn.Font = Enum.Font.GothamBold
        tiktokBtn.BorderSizePixel = 1
        tiktokBtn.BorderColor3 = Color3.fromRGB(255, 0, 80)
        tiktokBtn.Parent = content
        local tiktokCorner = Instance.new("UICorner")
        tiktokCorner.CornerRadius = UDim.new(0, 12)
        tiktokCorner.Parent = tiktokBtn
        
        tiktokBtn.MouseButton1Click:Connect(function()
            local notif = Instance.new("TextLabel")
            notif.Size = UDim2.new(0.8, 0, 0, 30)
            notif.Position = UDim2.new(0.1, 0, 0, 240)
            notif.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            notif.BackgroundTransparency = 0.2
            notif.Text = "🔗 Buka TikTok manual: " .. DONASI_TIKTOK
            notif.TextColor3 = Color3.new(1,1,1)
            notif.TextScaled = true
            notif.Font = Enum.Font.GothamBold
            notif.BorderSizePixel = 0
            notif.Parent = content
            local notifCorner = Instance.new("UICorner")
            notifCorner.CornerRadius = UDim.new(0, 8)
            notifCorner.Parent = notif
            wait(2.5)
            notif:Destroy()
        end)
    end
end

-- ============================================================
-- 9. TAB SWITCHING
-- ============================================================
for i, btn in ipairs(tabButtons) do
    btn.MouseButton1Click:Connect(function()
        for j, frame in ipairs(contentFrames) do
            frame.Visible = (j == i)
        end
        for _, b in ipairs(tabButtons) do
            b.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            b.TextColor3 = Color3.fromRGB(200, 200, 230)
        end
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 120)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
end
tabButtons[1].BackgroundColor3 = Color3.fromRGB(60, 60, 120)
tabButtons[1].TextColor3 = Color3.fromRGB(255, 255, 255)

-- ============================================================
-- 10. ANIMASI MASUK
-- ============================================================
mainFrame.BackgroundTransparency = 1
mainFrame.Size = UDim2.new(0, 0, 0, 0)
local tweenIn = TweenService:Create(mainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
    BackgroundTransparency = 0.92,
    Size = UDim2.new(0, 520, 0, 440)
})
tweenIn:Play()

print("✅ SoulGPT Panel v2.0 Loaded! Selamat bereksperimen Alfatih.")
debugLog("Panel ready!")
