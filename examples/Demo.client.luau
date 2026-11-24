local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vulcan = require(ReplicatedStorage:WaitForChild("VulcanLibrary"))

local window = Vulcan.CreateWindow({ Title = "Vulcan Library" })
local effect = window:AddToggle({
    Text = "Efeito visual",
    Default = false,
    Callback = function(enabled)
        print("Efeito visual", enabled)
    end,
})

local amount = window:AddSlider({
    Text = "Bananas",
    Min = 0,
    Max = 20,
    Step = 1,
    Default = 5,
    Format = function(value)
        return string.format("%d %s", value, value == 1 and "banana" or "bananas")
    end,
    Callback = function(value)
        print("Bananas selecionadas", value)
    end,
})

window:AddButton({
    Text = "Restaurar",
    Callback = function()
        effect:Set(false)
        amount:Set(5)
    end,
})
