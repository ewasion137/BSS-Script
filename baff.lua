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
    "Potato", "Sugarcane", "Watermelon", "Blackberry", "Beet", 
    "Kiwi", "Pineapple", "Pricly Pear"
}
getgenv().SelectedSeed = SeedList[1] 

-- Загружаем Rayfield UI
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

MainTab:CreateDropdown({
    Name = "Выбрать семя для автопокупки",
    Options = SeedList,
    CurrentOption = {getgenv().SelectedSeed},
    MultipleOptions = false,
    Flag = "SeedSelector",
    Callback = function(Option)
        getgenv().SelectedSeed = Option[1]
        print("Выбрано для покупки: " .. getgenv().SelectedSeed)
    end,
})

-- Создаем тумблер Автопокупки
MainTab:CreateToggle({
    Name = "Автопокупка семян",
    CurrentValue = false,
    Flag = "AutoBuyToggle",
    Callback = function(Value)
        getgenv().AutoBuy = Value
        
        if getgenv().AutoBuy then
            task.spawn(function()
                local playerPlotName = game.Players.LocalPlayer.Name
                
                while getgenv().AutoBuy do
                    task.wait(0.5) -- Проверяем пеньки каждые полсекунды
                    
                    -- Ищем твой плот в Workspace
                    local myPlot = workspace:FindFirstChild("Plots") and workspace.Plots:FindFirstChild(playerPlotName)
                    
                    if myPlot then
                        -- Перебираем пеньки от 1 до 8
                        for i = 1, 8 do
                            local stumpName = "Stump_" .. tostring(i)
                            local stump = myPlot:FindFirstChild(stumpName)
                            
                            if stump and stump:FindFirstChild("Model") then
                                -- Ищем табличку с названием
                                local display = stump.Model:FindFirstChild("BuyableDisplay")
                                local title = display and display:FindFirstChild("Title")
                                
                                -- Если табличка есть и у нее есть текст (TextLabel)
                                if title and title:IsA("TextLabel") or title:IsA("TextButton") then
                                    
                                    -- Проверяем, написано ли там название выбранного семени
                                    -- string.find ищет, например, "Strawberry" внутри "Strawberry Seeds"
                                    if string.find(title.Text, getgenv().SelectedSeed) then
                                        
                                        -- Нашли нужное семя! Пытаемся его купить:
                                        
                                        -- Вариант 1: Если там ProximityPrompt (нужно зажать клавишу)
                                        local prompt = stump:FindFirstChildWhichIsA("ProximityPrompt", true)
                                        if prompt then
                                            fireproximityprompt(prompt)
                                        end
                                        
                                        -- Вариант 2: Если там ClickDetector (нужно кликнуть мышкой)
                                        local clickDetector = stump:FindFirstChildWhichIsA("ClickDetector", true)
                                        if clickDetector then
                                            fireclickdetector(clickDetector)
                                        end
                                        
                                    end
                                end
                            end
                        end
                    end
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

Rayfield:Notify({
    Title = "Скрипт загружен!",
    Content = "Дарооууу! Погнали.",
    Duration = 5,
    Image = 4483362458,
})