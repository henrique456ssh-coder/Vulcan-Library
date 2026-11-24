# Vulcan Library

Biblioteca de interface em Luau para Roblox Studio. A janela usa tema vulcânico e pode ser arrastada pelo cabeçalho com mouse ou toque. Os controles incluem um toggle, um botão com impressão digital e um slider com valor dentro da barra.

## Instalação no Roblox Studio

1. Crie um `ModuleScript` chamado `VulcanLibrary` em **ReplicatedStorage** e cole o conteúdo de [VulcanLibrary.luau](VulcanLibrary.luau).
2. Crie um `LocalScript` em **StarterPlayer → StarterPlayerScripts** e cole o conteúdo de [Demo.client.luau](examples/Demo.client.luau).
3. Pressione **Play**. O exemplo registra as alterações no painel **Output**.

## API

| Chamada | Opções |
| --- | --- |
| `Vulcan.CreateWindow(options)` | `Title` define o título. `Name` distingue a janela no `PlayerGui`. |
| `window:AddToggle(config)` | `Text`, `Default` e `Callback(enabled)`. |
| `window:AddSlider(config)` | `Text`, `Min`, `Max`, `Step`, `Default`, `Format(value)` e `Callback(value)`. |
| `window:AddButton(config)` | `Text` e `Callback()`. Retorna o `TextButton`. |
| `window:SetMinimized(value)` | `true` recolhe a janela e `false` expande. |
| `window:Destroy()` | Fecha a janela e desconecta os eventos de entrada. |

Toggles e sliders retornam controles com `Get()` e `Set(value, silent)`. Passe `true` como segundo argumento de `Set` para atualizar o controle sem chamar o callback. Os callbacks também são chamados quando o jogador altera o valor na interface.

Use nomes diferentes em `CreateWindow` para manter várias janelas abertas. Executar novamente com o mesmo nome substitui a janela criada pela biblioteca.
