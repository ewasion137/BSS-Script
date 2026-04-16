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
                        -- Ищем плот (на всякий случай по Name и DisplayName)
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
-- 3. АВТО-ПОКУПКА СЕМЯН (ОТБАЛАНСИРОВАНА)
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
                                            -- Моментально покупаем при совпадении
                                            BuyRemote:FireServer(i)
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    -- УМЕНЬШИЛИ ДИЛЕЙ, чтобы скан пней летал со скоростью света
                    task.wait(0) 
                end
            end)
        end
    end,
})

Rayfield:Notify({
    Title = "Ewasion Hub загружен",
    Content = "Задержки оптимизированы. Погнали!",
    Duration = 3,
    Image = 4483362458,
})
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
                        -- Ищем плот (на всякий случай по Name и DisplayName)
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
-- 3. АВТО-ПОКУПКА СЕМЯН (ОТБАЛАНСИРОВАНА)
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
                                            -- Моментально покупаем при совпадении
                                            BuyRemote:FireServer(i)
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    -- УМЕНЬШИЛИ ДИЛЕЙ, чтобы скан пней летал со скоростью света
                    task.wait(0) 
                end
            end)
        end
    end,
})

Rayfield:Notify({
    Title = "Ewasion Hub загружен",
    Content = "Задержки оптимизированы. Погнали!",
    Duration = 3,
    Image = 4483362458,
})
-- В начале скрипта (где-то после создания MainTab) создаем переменную для тоггла, 
-- чтобы иметь возможность выключить его программно.

local AutoRollToggle -- Объявляем заранее

AutoRollToggle = MainTab:CreateToggle({
    Name = "Auto Roll (Стоп на Prickly Pear)",
    CurrentValue = false,
    Flag = "AutoRoll",
    Callback = function(Value)
        getgenv().AutoRoll = Value
        if getgenv().AutoRoll then
            task.spawn(function()
                while getgenv().AutoRoll do
                    local success, result = pcall(function()
                        -- DoRoll обычно является RemoteFunction и возвращает данные о выпавшем семени
                        return game:GetService("ReplicatedStorage").Communication.DoRoll:InvokeServer()
                    end)

                    if success and result then
                        -- Проверяем результат. Обычно это либо строка "Prickly Pear", 
                        -- либо таблица {Name = "Prickly Pear", ...}
                        local seedName = ""
                        if type(result) == "string" then
                            seedName = result
                        elseif type(result) == "table" and result.Name then
                            seedName = result.Name
                        end

                        -- Если нашли Prickly Pear
                        if string.find(seedName, "Prickly Pear") then
                            getgenv().AutoRoll = false
                            
                            -- Уведомление игрока
                            Rayfield:Notify({
                                Title = "УДАЧА! 🌵",
                                Content = "Выпал Prickly Pear! Авто-ролл остановлен.",
                                Duration = 10,
                                Image = 4483362458,
                            })

                            -- Выключаем галочку в меню визуально
                            AutoRollToggle:Set(false)
                            break -- Выходим из цикла
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