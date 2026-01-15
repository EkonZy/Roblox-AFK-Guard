# 🚨 Roblox Disconnect Monitor 🚨

![Lua](https://img.shields.io/badge/Lua-Language-blue) ![Platform](https://img.shields.io/badge/Plataforma-Roblox-red) ![Type](https://img.shields.io/badge/Tipo-Utility-green)

Um sistema completo para monitorar se você foi desconectado do Roblox (Kick, Ban, Idle, Erro de Conexão).
O sistema avisa você de duas formas poderosas:
1.  **🖥️ Alerta na Tela do PC**: Uma janela vermelha pula na frente do jogo tocando alarme.
2.  **📱 Notificação Discord**: Uma mensagem direta pro seu celular/discord com horário e motivo.

---

## 📥 Instalação (Recomendada)

Para que o script funcione corretamente, você **DEVE** definir a variável do Webhook **ACIMA** do `loadstring`, como no exemplo abaixo:

```lua
-- Coloque seu Webhook AQUI (Antes de carregar o script)
getgenv().webhook = "https://discord.com/api/webhooks/SEU_LINK_AQUI"

-- Carregar o Script
loadstring(game:HttpGet("https://raw.githubusercontent.com/brunofekon-crypto/Roblox-AFK-Guard/main/SessionGuard.lua"))()
```

> [!TIP]
> O script detecta **QUALQUER** tipo de desconexão (Kick, Ban, Internet caiu, Idle, Erro 277, etc) e te avisa na hora!

---

## 📲 Como Configurar o Aviso no Celular (Webhook)

Quer receber um **PING** no seu celular quando o jogo cair? Siga os passos:

1.  Crie um **Servidor no Discord** (ou use um servidor privado seu).
2.  Edite um Canal de Texto ⚙️ > Vá em **Integrações** > **Webhooks**.
3.  Clique em **Novo Webhook** e depois em **Copiar URL do Webhook**.
4.  Cole esse link na variável `webhook` do script (no passo de instalação acima).
5.  Baixe o App do Discord no celular e habilite as notificações! 🔔

---

## 🤖 Modo AFK (Recomendado)

Vai deixar farmando a noite toda?

Recomendamos fortemente que você coloque o script na pasta **`auto-execute`** do seu executor.

*   **Por que?** Se o jogo reiniciar, reconectar ou trocar de servidor, o script injeta sozinho novamente.
*   **Como:**
    1. Abra a pasta do seu executor.
    2. Vá em `scripts` -> `auto-execute`.
    3. Crie um arquivo de texto `.lua` ou `.txt`.
    4. Cole o código de instalação dentro e salve. Prontinho!

---

## 🖥️ Compatibilidade

> [!IMPORTANT]
> - **XENO Executor:** Funciona **100%** (Testado e Aprovado).
> - **Outros Executores de PC:** Podem funcionar se suportarem `writefile` e requisições HTTP, mas **não há garantia**.
> - **Mobile:** Não suportado oficialmente.

---

## 🔊 Monitor de Desktop (Janela Pop-up)

Para ter a janela que pula na tela e toca som, você precisa do arquivo `.bat` no seu computador.

1.  Baixe o arquivo `Monitor.bat` deste repositório.
2.  Inicie o `Monitor.bat` **antes de começar a jogar**.
3.  Deixe a janela verde aberta (pode minimizar se quiser).
   
Assim que o script Lua detectar a queda, ele avisa o `.bat`, que dispara o alarme!

---

## ✨ Funcionalidades

*   ✅ **Detecção Universal**: Detecta "Disconnected", "Kick", "Ban", "Idle (20 min)", "Error Code 267/268".
*   ✅ **Auto-Focus**: A janela de alerta força o foco e aparece por cima do jogo.
*   ✅ **Alarme Sonoro**: Toca beeps de alerta caso você esteja dormindo ou longe.
*   ✅ **Logs**: Mostra o horário exato e o motivo da desconexão.

---

### Observações
*   Este script requer um **Executor** que suporte as funções `writefile` (para o monitor PC) e `request` (para o Discord).
*   Testado em: Solara, Xeno, Synapse, Script-Ware.
