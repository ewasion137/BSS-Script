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
-- 1. АВТО-РОЛЛ (ОТБАЛАНСИРОВАН)
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