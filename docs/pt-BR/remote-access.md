# Acesso remoto

Ordem de uso:

1. **SSH (acesso principal).** Permite administrar o equipamento sem interferir no que está na TV: quem está olhando a tela não percebe nada.
2. **RustDesk (último recurso).** Mostra a tela de verdade. Use quando precisar ver o que a TV exibe ou quando o SSH não estiver respondendo.

Valores de exemplo: usuário `kiosk`, IP `192.0.2.20`, faixas de confiança `192.0.2.0/24`, `198.51.100.0/24` e `203.0.113.0/24`.

## 1. SSH

### Instalação

```
sudo apt install openssh-server
sudo systemctl enable --now ssh
systemctl is-active ssh
```

### Firewall: SSH só das faixas de confiança

```
sudo ufw allow from 192.0.2.0/24 to any port 22 proto tcp
sudo ufw allow from 198.51.100.0/24 to any port 22 proto tcp
sudo ufw allow from 203.0.113.0/24 to any port 22 proto tcp
```

Qualquer outra origem fica bloqueada (veja [install-and-tuning.md](install-and-tuning.md), seção 7).

### Acesso

```
ssh kiosk@192.0.2.20
```

### Boa prática (opcional): chave SSH em vez de senha

No seu computador:

```
ssh-keygen -t ed25519
ssh-copy-id kiosk@192.0.2.20
```

Teste o login com a chave. Só depois de confirmar que funciona, desative a senha em `/etc/ssh/sshd_config.d/99-key-only.conf`:

```
PasswordAuthentication no
```

e aplique com `sudo systemctl reload ssh`. Mantenha uma sessão aberta durante o teste.

### Mexer no quiosque sem aparecer na TV

Os scripts já usam `export DISPLAY=:0`, então funcionam por SSH sem abrir janelas no terminal.

O que **não** interfere no que está na tela:

- editar o `~/kiosk/urls.txt`;
- editar o agendamento (`crontab -e`);
- ajustar configurações, instalar pacotes e conferir logs;
- consultar o estado (`pgrep -fa kiosk.sh`, `crontab -l`, `sudo ufw status`).

O que faz a TV piscar:

- **Reiniciar o carrossel** (`~/kiosk/stop.sh` e depois `~/kiosk/start.sh`), necessário depois de mudar o `urls.txt`. Faça em horário em que ninguém esteja olhando ou avise antes.
- **Mostrar uma tela de aviso** (`~/kiosk/notice.sh`). Aparece por 20 segundos.

Dica: para mostrar na TV algo de teste sem sair do SSH, use o `notice.sh` em vez de abrir o Chrome à mão.

## 2. RustDesk

Pacote `.deb` oficial do projeto RustDesk (releases do GitHub):

```
sudo apt install ./rustdesk-<versão>-x86_64.deb
sudo systemctl enable --now rustdesk
```

Defina uma senha fixa para acesso sem supervisão (digite a senha no terminal, nunca em um script versionado):

```
sudo rustdesk --password
```

Para obter o ID do equipamento:

```
sudo rustdesk --get-id
```

Notas:

- Por padrão, o RustDesk usa os servidores públicos do próprio projeto, e por isso só faz conexões de saída e não precisa de regra de entrada no firewall. Um servidor próprio pode ser montado depois, como melhoria.
- Guarde o ID e a senha no gerenciador de senhas da equipe, não em documentos nem no repositório.
- Para conexão direta pelo IP na rede interna, o RustDesk escuta as portas UDP 21119 e 41216; libere-as no ufw apenas para as faixas de confiança, e só se for realmente necessário.
- Se o serviço estiver como `active` mas a conexão cair, o SSH continua sendo o caminho para reiniciar o serviço: `sudo systemctl restart rustdesk`.
