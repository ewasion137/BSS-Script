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
getgenv().RollDelay = 0.3
getgenv().StopRollSeed = "Kiwi" -- По умолчанию останавливаемся на киви для теста

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
-- 1. АВТО-КЛИКЕР РАСТЕНИЙ
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
                        local playerPlot = workspace.Plots:FindFirstChild(LocalPlayer.Name) or workspace.Plots:FindFirstChild(LocalPlayer.DisplayName)
                        
                        if playerPlot and playerPlot:FindFirstChild("Tiles") then
                            local clickRemote = game:GetService("ReplicatedStorage").Communication.ClickPlant
                            
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
                    task.wait(0.1) 
                end
            end)
        end
    end,
})

-- ================================
-- 2. АВТО-ПОКУПКА СЕМЯН
-- ================================
local SeedList = {
    "Strawberry", "Carrot", "Tomato", "Corn", "Blueberry", 
    "Potato", "Sugarcane", "Watermelon", "Blackberry", 
    "Beet", "Kiwi", "Pineapple", "Prickly Pear"
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

local function GetTextsFromStump(stump)
    local texts = {}
    if stump then
        local model = stump:FindFirstChild("Model")
        if model then
            local display = model:FindFirstChild("BuyableDisplay")
            if display then
                for _, obj in pairs(display:GetDescendants()) do
                    if (obj:IsA("TextLabel") or obj:IsA("TextButton")) and obj.Text and obj.Text ~= "" and obj.Text ~= "Label" then
                        table.insert(texts, obj.Text)
                    end
                end
                local title = display:FindFirstChild("Title")
                if title and title:IsA("TextLabel") then
                    table.insert(texts, title.Text)
                end
            end
        end
    end
    return texts
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
                        local playerPlot = workspace.Plots:FindFirstChild(LocalPlayer.Name) or workspace.Plots:FindFirstChild(LocalPlayer.DisplayName)
                        
                        if playerPlot then
                            local BuyRemote = game:GetService("ReplicatedStorage").Communication.BuySeeds
                            
                            for i = 1, 8 do
                                local stump = playerPlot:FindFirstChild("Stump_" .. tostring(i))
                                local stumpTexts = GetTextsFromStump(stump)
                                
                                for _, textOnDisplay in pairs(stumpTexts) do
                                    for _, chosenSeed in pairs(getgenv().SelectedSeeds) do
                                        if string.find(string.lower(textOnDisplay), string.lower(chosenSeed)) then
                                            BuyRemote:FireServer(i)
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(0) 
                end
            end)
        end
    end,
})

-- ================================
-- 3. АВТО-РОЛЛ С ОСТАНОВКОЙ
-- ================================
MainTab:CreateDropdown({
    Name = "Остановить ролл, если выпадет:",
    Options = SeedList,
    CurrentOption = {"Kiwi"}, -- Тестовое значение
    MultipleOptions = false,
    Flag = "StopRollDrop",
    Callback = function(Option)
        -- Rayfield отдает массив даже если MultipleOptions = false, поэтому берем Option[1]
        getgenv().StopRollSeed = type(Option) == "table" and Option[1] or Option
    end,
})

-- Переменная для тумблера, чтобы скрипт мог его сам отключить
local AutoRollToggle 

AutoRollToggle = MainTab:CreateToggle({
    Name = "Auto Roll",
    CurrentValue = false,
    Flag = "AutoRoll",
    Callback = function(Value)
        getgenv().AutoRoll = Value
        if getgenv().AutoRoll then
            task.spawn(function()
                while getgenv().AutoRoll do
                    -- Ловим то, что сервер нам отвечает
                    local success, rollResult = pcall(function()
                        return game:GetService("ReplicatedStorage").Communication.DoRoll:InvokeServer()
                    end)
                    
                    if success then
                        -- Выводим в F9, чтобы понять, какой формат у ответа
                        print("[Дебаг Ролла] Выпало:", tostring(rollResult))
                        
                        -- Если сервер прислал название (строку)
                        if rollResult and type(rollResult) == "string" then
                            -- Сравниваем в нижнем регистре
                            if string.find(string.lower(rollResult), string.lower(getgenv().StopRollSeed)) then
                                print("🎉 УРА! ВЫПАЛО:", getgenv().StopRollSeed, "- СТОПАЕМ РОЛЛ!")
                                
                                -- Выключаем цикл
                                getgenv().AutoRoll = false
                                -- Визуально отключаем тумблер в менюшке
                                AutoRollToggle:Set(false)
                                
                                -- Красивая уведомлялка
                                Rayfield:Notify({
                                    Title = "ДЖЕКПОТ! 🎯",
                                    Content = "Авто-ролл остановлен! Выпало: " .. getgenv().StopRollSeed,
                                    Duration = 10,
                                    Image = 4483362458,
                                })
                            end
                        end
                    end
                    
                    task.wait(getgenv().RollDelay) 
                end
            end)
        end
    end,
})

MainTab:CreateSlider({
    Name = "Задержка ролла (сек)",
    Info = "0.3 = 300мс. Чем меньше, тем быстрее!",
    Range = {0, 1},
    Increment = 0.001,
    Suffix = "сек",
    CurrentValue = 0.3,
    Flag = "RollDelay",
    Callback = function(Value)
        getgenv().RollDelay = Value
    end,
})

Rayfield:Notify({
    Title = "Ewasion Hub загружен",
    Content = "Задержки оптимизированы. Погнали!",
    Duration = 3,
    Image = 4483362458,
})