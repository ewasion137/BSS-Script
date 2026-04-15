-- Защита от двойного запуска
if getgenv().EwasionScriptLoaded then
    warn("Скрипт уже запущен!") 
    return 
end
getgenv().EwasionScriptLoaded = true

-- Глобальные переменные
getgenv().AutoRoll = false
getgenv().AutoBuy = false
getgenv().AutoClick = false
getgenv().SelectedSeeds = {}

local LocalPlayer = game:GetService("Players").LocalPlayer

-- Загружаем Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Ewasion Hub 🚀",
    LoadingTitle = "Грузим рофляново...",
    LoadingSubtitle = "by ewasion137",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false, 
})

local MainTab = Window:CreateTab("Главная", 4483362458) 

-- ================================
-- 1. АВТО-РОЛЛ
-- ================================
MainTab:CreateToggle({
    Name = "Моментальный Auto Roll",
    CurrentValue = false,
    Flag = "AutoRoll",
    Callback = function(Value)
        getgenv().AutoRoll = Value
        if getgenv().AutoRoll then
            task.spawn(function()
                while getgenv().AutoRoll do
                    pcall(function()
                        game:GetService("ReplicatedStorage").Communication.DoRoll:InvokeServer()
                    end)
                    task.wait(0.1) 
                end
            end)
        end
    end,
})

-- ================================
-- 2. АВТО-КЛИКЕР РАСТЕНИЙ
-- ================================
MainTab:CreateToggle({
    Name = "Auto Click Plants (Ростки)",
    CurrentValue = false,
    Flag = "AutoClick",
    Callback = function(Value)
        getgenv().AutoClick = Value
        if getgenv().AutoClick then
            task.spawn(function()
                while getgenv().AutoClick do
                    pcall(function()
                        local playerPlot = workspace.Plots:FindFirstChild(LocalPlayer.Name)
                        if playerPlot and playerPlot:FindFirstChild("Tiles") then
                            local clickRemote = game:GetService("ReplicatedStorage").Communication.ClickPlant
                            
                            -- Перебираем все координаты (X: от -13 до 1, Y: от 0 до 17)
                            for x = -13, 1 do
                                for y = 0, 17 do
                                    local tileName = tostring(x) .. "_" .. tostring(y)
                                    local tile = playerPlot.Tiles:FindFirstChild(tileName)
                                    
                                    if tile then
                                        clickRemote:FireServer(tile)
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(0.5) -- Задержка между кругами, чтобы не кикнуло за спам ремутами
                end
            end)
        end
    end,
})

-- ================================
-- 3. АВТО-ПОКУПКА СЕМЯН
-- ================================
local SeedList = {
    "Strawberry", "Carrot", "Tomato", "Corn", "Blueberry", 
    "Potato", "Sugarcane", "Watermelon", "Blackberry", 
    "Beet", "Kiwi", "Pineapple", "Pricly Pear"
}

MainTab:CreateDropdown({
    Name = "Выбор семян для автопокупки",
    Options = SeedList,
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "SeedDrop",
    Callback = function(Options)
        getgenv().SelectedSeeds = Options
    end,
})

local function CheckStumpForSeed(stump)
    if stump and stump:FindFirstChild("Model") and stump.Model:FindFirstChild("BuyableDisplay") then
        local title = stump.Model.BuyableDisplay:FindFirstChild("Title")
        if title then
            for _, obj in pairs(title:GetDescendants()) do
                if (obj:IsA("TextLabel") or obj:IsA("StringValue")) and obj.Text then
                    return obj.Text
                end
            end
        end
    end
    return ""
end

MainTab:CreateToggle({
    Name = "Автопокупка выбранных семян",
    CurrentValue = false,
    Flag = "AutoBuy",
    Callback = function(Value)
        getgenv().AutoBuy = Value
        if getgenv().AutoBuy then
            task.spawn(function()
                while getgenv().AutoBuy do
                    pcall(function()
                        local playerPlot = workspace.Plots:FindFirstChild(LocalPlayer.Name)
                        if playerPlot then
                            local BuyRemote = game:GetService("ReplicatedStorage").Communication.BuySeeds
                            
                            -- Проверяем 8 пней
                            for i = 1, 8 do
                                local stump = playerPlot:FindFirstChild("Stump_" .. tostring(i))
                                local textOnDisplay = CheckStumpForSeed(stump)
                                
                                for _, chosenSeed in pairs(getgenv().SelectedSeeds) do
                                    if string.find(textOnDisplay, chosenSeed) then
                                        -- Покупаем! Отправляем серверу только номер пня (i)
                                        BuyRemote:FireServer(i)
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(1) -- Сканируем магазин раз в секунду
                end
            end)
        end
    end,
})

Rayfield:Notify({
    Title = "Ewasion Hub загружен",
    Content = "Все функции готовы к работе!",
    Duration = 3,
    Image = 4483362458,
})