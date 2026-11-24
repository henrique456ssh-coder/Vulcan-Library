local libraryUrl = "https://raw.githubusercontent.com/henrique456ssh-coder/Vulcan-Library/main/VulcanLibrary.luau"
assert(type(loadstring) == "function", "Este executor precisa disponibilizar loadstring.")

local downloaded, source = pcall(function()
    return game:HttpGet(libraryUrl)
end)
assert(downloaded, "Falha ao baixar a Vulcan Library. " .. tostring(source))
assert(type(source) == "string" and #source > 0, "O download da Vulcan Library retornou vazio.")

local chunk, compileError = loadstring(source, "@VulcanLibrary")
assert(chunk, "Falha ao compilar a Vulcan Library. " .. tostring(compileError))
local loaded, Vulcan = pcall(chunk)
assert(loaded, "Falha ao iniciar a Vulcan Library. " .. tostring(Vulcan))
assert(type(Vulcan) == "table" and type(Vulcan.CreateWindow) == "function", "Resposta inválida da biblioteca.")

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

return window
