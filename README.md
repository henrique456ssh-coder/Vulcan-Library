# Vulcan Library

Biblioteca de interface em Luau para carregar no executor com `loadstring` e `game:HttpGet`. A janela usa tema vulcânico, arraste por mouse ou toque, toggles, botões com impressão digital e sliders com valor dentro da barra. Versão `1.1.0`.

## Índice

- [Carregar a biblioteca](#carregar-a-biblioteca)
- [Criar a janela](#criar-a-janela)
- [Toggle](#toggle)
- [Botão](#botão)
- [Slider](#slider)
- [Controlar a janela](#controlar-a-janela)
- [Exemplo completo](#exemplo-completo)
- [Referência rápida](#referência-rápida)
- [Resolver erros](#resolver-erros)

## Carregar a biblioteca

Cole e execute o código abaixo com o jogo carregado.

```lua
local Vulcan = loadstring(game:HttpGet("https://raw.githubusercontent.com/henrique456ssh-coder/Vulcan-Library/main/VulcanLibrary.luau"))()
```

Essa URL entrega o código-fonte público da biblioteca. `Vulcan` recebe a tabela com `CreateWindow` e `Version`. O executor precisa fornecer `loadstring` e `game:HttpGet`.

Cole a criação da janela logo abaixo desse carregamento e acrescente os controles desejados no mesmo script. As variáveis `local` ficam disponíveis dentro dessa execução.

O [arquivo de demonstração](examples/Demo.client.luau) também inclui verificações para falhas de download, compilação e inicialização.

## Criar a janela

```lua
local window = Vulcan.CreateWindow({
    Title = "Minha Hub",
    Name = "MinhaVulcanHub",
})
```

| Opção | Tipo | Padrão | Efeito |
| --- | --- | --- | --- |
| `Title` | `string` | `"Vulcan Library"` | Texto exibido no cabeçalho. |
| `Name` | `string` | `"VulcanLibrary"` | Identificador da janela no `PlayerGui`. |

Use textos com pelo menos um caractere. `Vulcan.CreateWindow` usa ponto. Os métodos da janela e dos controles usam dois-pontos na sintaxe Luau.

## Toggle

Cole após a criação de `window`. O callback recebe `true` ao ativar e `false` ao desativar.

```lua
local toggle = window:AddToggle({
    Text = "Minha função",
    Default = false,
    Callback = function(enabled)
        print("Função ativada", enabled)
    end,
})
```

| Opção | Tipo | Padrão | Efeito |
| --- | --- | --- | --- |
| `Text` | `string` | `"Toggle"` | Nome exibido ao lado do switch. |
| `Default` | `boolean` | `false` | Estado inicial. |
| `Callback` | `function(enabled)` | Opcional | Ação executada quando o estado muda. |

### Ler e mudar o estado

```lua
print(toggle:Get())     -- Lê true ou false.
toggle:Set(true)        -- Ativa e chama o callback se o estado mudou.
toggle:Set(false)       -- Desativa e chama o callback se o estado mudou.
toggle:Set(true, true)  -- Ativa sem chamar o callback.
```

## Botão

O callback executa ao clicar ou tocar no botão.

```lua
local button = window:AddButton({
    Text = "Executar ação",
    Callback = function()
        print("Botão pressionado")
    end,
})
```

| Opção | Tipo | Padrão | Efeito |
| --- | --- | --- | --- |
| `Text` | `string` | `"Botão"` | Texto exibido no botão. |
| `Callback` | `function()` | Opcional | Ação executada ao pressionar. |

`AddButton` retorna a instância `TextButton`. Toggles e sliders retornam tabelas com `Get` e `Set`.

## Slider

O callback recebe o número selecionado. `Format` define o texto exibido dentro da barra.

```lua
local slider = window:AddSlider({
    Text = "Slider",
    Min = 0,
    Max = 20,
    Step = 1,
    Default = 5,
    Format = function(value)
        return string.format("%d %s", value, value == 1 and "banana" or "bananas")
    end,
    Callback = function(value)
        print("Quantidade selecionada", value)
    end,
})
```

| Opção | Tipo | Padrão | Efeito |
| --- | --- | --- | --- |
| `Text` | `string` | `"Slider"` | Nome exibido acima da barra. |
| `Min` | `number` | `0` | Menor valor permitido. |
| `Max` | `number` | `20` | Maior valor permitido. |
| `Step` | `number` | `math.min(1, Max - Min)` | Incremento entre valores. |
| `Default` | `number` | `Min` | Valor inicial, ajustado ao intervalo e ao incremento. |
| `Format` | `function(value)` | Opcional | Retorna o texto exibido na barra. |
| `Callback` | `function(value)` | Opcional | Ação executada quando o valor muda. |

Use números finitos. `Max` deve ser maior que `Min`. `Step` deve ser positivo e caber em `Max - Min`. A diferença e sua divisão por `Step` também precisam ser finitas.

### Ler e mudar o valor

```lua
print(slider:Get())   -- Lê o valor atual.
slider:Set(10)       -- Atualiza e chama o callback se o valor mudou.
slider:Set(5, true)  -- Atualiza sem chamar o callback.
```

Valores são limitados ao intervalo e arredondados ao incremento a partir de `Min`. O limite `Max` também pode ser selecionado. Para um slider de `0` a `20` com `Step = 1`, `Set(12.4)` seleciona `12` e `Set(100)` seleciona `20`.

### Usar casas decimais

```lua
local intensity = window:AddSlider({
    Text = "Intensidade",
    Min = 0,
    Max = 1,
    Step = 0.05,
    Default = 0.5,
    Format = function(value)
        return string.format("%.2f", value)
    end,
    Callback = function(value)
        print("Intensidade", value)
    end,
})
```

## Controlar a janela

Copie os comandos que deseja executar após criar `window`.

### Alterar o título

```lua
window:SetTitle("Novo título")
```

### Minimizar e restaurar

```lua
window:SetMinimized(true)   -- Recolhe os controles e mantém o cabeçalho.
window:SetMinimized(false)  -- Expande os controles.
```

### Ocultar e mostrar

```lua
window:SetVisible(false)  -- Oculta toda a janela.
window:SetVisible(true)   -- Mostra novamente.
```

Guarde a referência `window` no script para mostrar uma janela oculta. Minimizar mantém os botões do cabeçalho acessíveis.

### Fechar

```lua
window:Destroy()
```

`Destroy` remove a interface e desconecta seus eventos de entrada. Para abrir novamente, crie outra janela com `Vulcan.CreateWindow`.

## Exemplo completo

Copie este bloco inteiro para carregar a biblioteca e criar uma janela com toggle, slider e botão de restauração.

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

## Referência rápida

| Chamada | Opções |
| --- | --- |
| `Vulcan.Version` | String com a versão da biblioteca. |
| `Vulcan.CreateWindow(options)` | `Title` define o título. `Name` distingue a janela no `PlayerGui`. |
| `window:AddToggle(config)` | `Text`, `Default` e `Callback(enabled)`. |
| `window:AddSlider(config)` | `Text`, `Min`, `Max`, `Step`, `Default`, `Format(value)` e `Callback(value)`. |
| `window:AddButton(config)` | `Text` e `Callback()`. Retorna o `TextButton`. |
| `toggle:Get()` | Retorna o estado booleano atual. |
| `toggle:Set(value, silent)` | Atualiza o estado do toggle. |
| `slider:Get()` | Retorna o valor numérico atual. |
| `slider:Set(value, silent)` | Atualiza o valor do slider. |
| `window:SetTitle(text)` | Atualiza o título da janela. |
| `window:SetVisible(value)` | `true` mostra a janela e `false` oculta. |
| `window:SetMinimized(value)` | `true` recolhe a janela e `false` expande. |
| `window:Destroy()` | Fecha a janela e desconecta os eventos de entrada. |

Toggles e sliders retornam controles com `Get()` e `Set(value, silent)`. Passe `true` como segundo argumento de `Set` para atualizar o controle sem chamar o callback. Os callbacks também são chamados quando o jogador altera o valor na interface.

Use nomes diferentes em `CreateWindow` para manter várias janelas abertas. Executar novamente com o mesmo nome substitui a janela criada pela biblioteca.

A interface fica no `PlayerGui` e permanece após o respawn. Fechar a janela encerra seus eventos de entrada. Os valores padrão aparecem sem executar os callbacks. `Set` chama o callback quando o valor muda.

Substitua os `print` pela ação desejada em cada callback. A biblioteca agenda os callbacks com `task.spawn`. Faça sua ação depender do valor recebido como argumento. O modo silencioso atualiza o controle sem executar a ação personalizada.

## Resolver erros

| Mensagem ou sintoma | O que verificar |
| --- | --- |
| `loadstring` indisponível | O executor precisa fornecer essa função para compilar o código baixado. |
| Falha em `HttpGet` ou no download | Confirme a conexão e a URL do arquivo `VulcanLibrary.luau`. |
| `attempt to index nil` em `window` | Coloque o carregamento, `CreateWindow` e os controles no mesmo script, nessa ordem. |
| `Name já pertence a outra interface.` | Escolha outro `Name` na criação da janela. |
| `PlayerGui indisponível.` | Aguarde o jogo carregar e execute novamente. |
| `Esta janela já foi fechada.` | Crie outra janela antes de adicionar controles. |
| Erro sobre `Min`, `Max` ou `Step` | Confira os tipos e os limites descritos na seção do slider. |
| O callback inicial parece ausente | Execute sua ação inicial no próprio script. `Default` define o estado visual ao criar o controle. |
| Carregou a biblioteca e a janela ainda não apareceu | Acrescente `Vulcan.CreateWindow` após o carregamento. |

## Verificação

A sintaxe, o carregamento e os controles foram verificados com simulação local das APIs Roblox. A execução em um executor real ainda precisa ser validada.
