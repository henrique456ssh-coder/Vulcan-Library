# Vulcan Library

Biblioteca de interface em Luau para carregar no executor com `loadstring` e `game:HttpGet`. A janela usa tema vulcânico, arraste por mouse ou toque, toggles, botões com impressão digital e sliders com valor dentro da barra. Versão `1.1.0`.

## Abrir o exemplo no executor

Cole e execute o código abaixo com o jogo carregado.

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/henrique456ssh-coder/Vulcan-Library/main/examples/Demo.client.luau"))()
```

O [exemplo completo](examples/Demo.client.luau) verifica o download, compila a biblioteca e cria uma janela com toggle, slider de bananas e botão Restaurar. Os callbacks imprimem o estado no console. O executor precisa fornecer `loadstring` e `game:HttpGet`.

## Criar a própria interface

```lua
local Vulcan = loadstring(game:HttpGet("https://raw.githubusercontent.com/henrique456ssh-coder/Vulcan-Library/main/VulcanLibrary.luau"))()
local window = Vulcan.CreateWindow({ Title = "Vulcan Library" })

local toggle = window:AddToggle({
    Text = "Minha função",
    Default = false,
    Callback = function(enabled)
        print("Toggle", enabled)
    end,
})

local slider = window:AddSlider({
    Text = "Slider",
    Min = 0,
    Max = 20,
    Step = 1,
    Default = 5,
    Format = function(value)
        return tostring(value) .. " bananas"
    end,
    Callback = function(value)
        print("Slider", value)
    end,
})

window:AddButton({
    Text = "Restaurar",
    Callback = function()
        toggle:Set(false)
        slider:Set(5)
    end,
})
```

Carregar [VulcanLibrary.luau](VulcanLibrary.luau) retorna a tabela da biblioteca. `CreateWindow` cria a interface. Coloque suas funções nos callbacks dos controles.

## API

| Chamada | Opções |
| --- | --- |
| `Vulcan.CreateWindow(options)` | `Title` define o título. `Name` distingue a janela no `PlayerGui`. |
| `window:AddToggle(config)` | `Text`, `Default` e `Callback(enabled)`. |
| `window:AddSlider(config)` | `Text`, `Min`, `Max`, `Step`, `Default`, `Format(value)` e `Callback(value)`. |
| `window:AddButton(config)` | `Text` e `Callback()`. Retorna o `TextButton`. |
| `window:SetTitle(text)` | Atualiza o título da janela. |
| `window:SetVisible(value)` | `true` mostra a janela e `false` oculta. |
| `window:SetMinimized(value)` | `true` recolhe a janela e `false` expande. |
| `window:Destroy()` | Fecha a janela e desconecta os eventos de entrada. |

Toggles e sliders retornam controles com `Get()` e `Set(value, silent)`. Passe `true` como segundo argumento de `Set` para atualizar o controle sem chamar o callback. Os callbacks também são chamados quando o jogador altera o valor na interface.

Use nomes diferentes em `CreateWindow` para manter várias janelas abertas. Executar novamente com o mesmo nome substitui a janela criada pela biblioteca.

A interface fica no `PlayerGui` e permanece após o respawn. Fechar a janela encerra seus eventos de entrada. Os valores padrão aparecem sem executar os callbacks. `Set` chama o callback quando o valor muda.

## Verificação

A sintaxe, o carregamento e os controles foram verificados com simulação local das APIs Roblox. A execução em um executor real ainda precisa ser validada.
