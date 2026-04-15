-- Защита от двойного запуска (чтобы меню не плодилось, если ты запустишь скрипт дважды)
if getgenv().EwasionScriptLoaded then
    -- Rayfield сам умеет уничтожать старые окна, но на всякий случай
    warn("Скрипт уже запущен!") 
    return 
end
getgenv().EwasionScriptLoaded = true

-- Глобальные переменные для наших циклов
getgenv().AutoRoll = false
getgenv().AutoSprouts = false
local SeedList = {
    "Strawberry", "Carrot", "Tomato", "Corn", "Blueberry", 
    "Potato", "Sugarcane", "Watermelon", "Blackberry", 
    "Beet", "Kiwi", "Pineapple", "Pricly Pear"
}

-- Тут будем хранить те семена, которые ты выбрал в меню
getgenv().SelectedSeeds = {}

-- Загружаем Rayfield UI
local LocalPlayer = game:GetService("Players").LocalPlayer
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Создаем главное окно
local Window = Rayfield:CreateWindow({
    Name = "Ewasion Hub 🚀",
    LoadingTitle = "Грузим рофляново...",
    LoadingSubtitle = "by ewasion137",
    ConfigurationSaving = {
       Enabled = false,
       FolderName = nil, 
       FileName = "EwasionHub"
    },
    Discord = {
       Enabled = false,
       Invite = "noinvitelink", 
       RememberJoins = true 
    },
    KeySystem = false, 
})

-- Создаем вкладку
local MainTab = Window:CreateTab("Главная", 4483362458) 

-- ТУТ БУДЕТ ЛОГИКА АВТО-РОЛЛА
MainTab:CreateToggle({
    Name = "Моментальный Auto Roll",
    CurrentValue = false,
    Flag = "AutoRollToggle",
    Callback = function(Value)
        getgenv().AutoRoll = Value
        
        if getgenv().AutoRoll then
            task.spawn(function()
                while getgenv().AutoRoll do
                    -- pcall защищает скрипт от краша, если сервер выдаст ошибку
                    local success, err = pcall(function()
                        game:GetService("ReplicatedStorage").Communication.DoRoll:InvokeServer()
                    end)
                    
                    -- Небольшая задержка, чтобы не нагружать твой ПК и пинг
                    task.wait(0.1) 
                end
            end)
        end
    end,
})

-- ТУТ БУДЕТ ЛОГИКА АВТО-РОСТКОВ
MainTab:CreateToggle({
    Name = "Auto Click Sprouts",
    CurrentValue = false,
    Flag = "AutoSproutsToggle",
    Callback = function(Value)
        getgenv().AutoSprouts = Value
        
        if getgenv().AutoSprouts then
            task.spawn(function()
                while getgenv().AutoSprouts do
                    task.wait(0.2)
                    -- СЮДА ВСТАВИМ ЛОГИКУ ПОИСКА РОСТКОВ
                    -- Как только скажешь, как они называются и что внутри (ClickDetector/ProximityPrompt)
                end
            end)
        end
    end,
})

MainTab:CreateDropdown({
    Name = "Выбор семян для автопокупки",
    Options = SeedList,
    CurrentOption = {},
    MultipleOptions = true, -- Включаем мульти-выбор!
    Flag = "SeedDropdown",
    Callback = function(Options)
        getgenv().SelectedSeeds = Options -- Сохраняем выбранные семена в переменную
    end,
})

-- Функция, которая пытается вытащить название семени из пня
local function CheckStumpForSeed(stump)
    if stump and stump:FindFirstChild("Model") and stump.Model:FindFirstChild("BuyableDisplay") then
        local title = stump.Model.BuyableDisplay:FindFirstChild("Title")
        if title then
            -- Проходим по всем детям Title (скорее всего там SurfaceGui и TextLabel)
            for _, obj in pairs(title:GetDescendants()) do
                if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("StringValue") then
                    return obj.Text or obj.Value -- Вернет что-то типа "Strawberry Seeds"
                end
            end
        end
    end
    return ""
end

-- Тоггл автопокупки
MainTab:CreateToggle({
    Name = "Автопокупка выбранных семян",
    CurrentValue = false,
    Flag = "AutoBuyToggle",
    Callback = function(Value)
        getgenv().AutoBuy = Value
        
        if getgenv().AutoBuy then
            task.spawn(function()
                while getgenv().AutoBuy do
                    local success, err = pcall(function()
                        -- Ищем твой плот по твоему нику
                        local playerPlot = workspace.Plots:FindFirstChild(LocalPlayer.Name)
                        
                        if playerPlot then
                            -- Проверяем все 8 пней
                            for i = 1, 8 do
                                local stump = playerPlot:FindFirstChild("Stump_" .. tostring(i))
                                local textOnDisplay = CheckStumpForSeed(stump)
                                
                                -- Проверяем, есть ли текст с пня в нашем списке выбранных семян
                                for _, chosenSeed in pairs(getgenv().SelectedSeeds) do
                                    -- Если в тексте "Strawberry Seeds" есть слово "Strawberry"
                                    if string.find(textOnDisplay, chosenSeed) then
                                        
                                        -- ПОКУПАЕМ!
                                        -- ВАЖНО: Ниже я написал пример. 
                                        -- Тебе нужно узнать через SimpleSpy, какие аргументы принимает BuySeeds!
                                        
                                        local BuyRemote = game:GetService("ReplicatedStorage").Communication.BuySeeds
                                        
                                        -- Вариант 1 (передает номер пня, например 1, 2, 3):
                                        BuyRemote:InvokeServer(i) 
                                        
                                        -- Вариант 2 (передает название семени):
                                        -- BuyRemote:InvokeServer(chosenSeed) 
                                        
                                        -- Вариант 3 (передает саму модельку пня):
                                        -- BuyRemote:InvokeServer(stump)
                                    end
                                end
                            end
                        end
                    end)
                    
                    task.wait(1) -- Сканируем пни раз в секунду
                end
            end)
        end
    end,
})

Rayfield:Notify({
    Title = "Скрипт загружен!",
    Content = "Дарооууу! Погнали.",
    Duration = 5,
    Image = 4483362458,
})