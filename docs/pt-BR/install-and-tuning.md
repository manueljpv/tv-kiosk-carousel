# Instalação e otimização do mini PC

Passo a passo para transformar um mini PC reaproveitado em uma tela de TV que liga sozinha e roda um carrossel de páginas no Chrome. Todos os endereços, nomes e usuários abaixo são exemplos fictícios.

Valores de exemplo usados neste documento:

| Item | Exemplo |
|---|---|
| Usuário | `kiosk` |
| Nome do computador | `tv-kiosk` |
| IP fixo do mini PC | `192.0.2.20/24` |
| Gateway | `192.0.2.1` |
| DNS interno | `192.0.2.53` (mais `8.8.8.8` como reserva) |
| Site mostrado no carrossel | `http://192.0.2.10:8080` |
| Faixas de confiança (SSH) | `192.0.2.0/24`, `198.51.100.0/24`, `203.0.113.0/24` |
| MAC (fictício) | `02:00:00:00:00:01` |

## 1. Sistema

- Linux Mint 21.3 Xfce (base Ubuntu 22.04), X11, login automático do usuário `kiosk` (LightDM).
- Fuso horário correto e relógio sincronizado (confira com `timedatectl`).
- Disco pequeno basta: cerca de 10 GB ficam em uso depois das otimizações.

## 2. Rede com IP fixo

Faça a reserva do IP no DHCP do roteador/firewall (usando o MAC da placa de rede) e fixe o mesmo IP no Linux:

```
sudo nmcli connection modify "Wired connection 1" \
  ipv4.method manual \
  ipv4.addresses 192.0.2.20/24 \
  ipv4.gateway 192.0.2.1 \
  ipv4.dns "192.0.2.53 8.8.8.8" \
  ipv4.ignore-auto-dns yes
sudo nmcli connection up "Wired connection 1"
```

Conferência: `ip -4 -brief addr show` deve mostrar o IP fixo.

## 3. Acesso remoto

SSH como acesso principal e RustDesk como último recurso. Detalhes em [remote-access.md](remote-access.md). Configure isso logo no início, para fazer o resto sem precisar de teclado e mouse no equipamento.

## 4. Otimizações do sistema

### 4.1 Energia e tela: o equipamento nunca dorme

Bloqueie os alvos de suspensão do systemd:

```
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
```

Instale o arquivo [`config/logind-99-always-on.conf`](../../config/logind-99-always-on.conf) em `/etc/systemd/logind.conf.d/99-always-on.conf`.

No Xfce, desligue os temporizadores do gerenciador de energia e o bloqueio de tela (canal `xfce4-power-manager`):

```
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-enabled -s false
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/blank-on-ac -s 0
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-on-ac-sleep -s 0
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-on-ac-off -s 0
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/inactivity-on-ac -s 14
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/presentation-mode -s true
```

(`inactivity-on-ac = 14` significa "nunca" nessa interface.) Se alguma dessas propriedades ainda não existir, crie com `-n -t <tipo>`.

O script `start.sh` também executa `xset s off -dpms s noblank` ao iniciar o carrossel.

### 4.2 Programas que iniciam sozinhos: desativar

Para cada item abaixo, crie `~/.config/autostart/<nome>.desktop` contendo apenas as linhas abaixo (ele sobrepõe o padrão do sistema):

```
[Desktop Entry]
Type=Application
Name=<nome>
Hidden=true
```

Itens: mintwelcome, mintupdate, mintreport, blueman, warpinator-autostart, print-applet, onboard-autostart, orca-autostart, caribou-autostart, geoclue-demo-agent, org.gnome.Evolution-alarm-notify, sticky, xscreensaver e light-locker.

Atenção: sem o `mintupdate` não aparece aviso de atualização. As atualizações passam a ser manuais (`sudo apt update && sudo apt upgrade`).

### 4.3 Serviços desnecessários: desativar

```
sudo systemctl disable --now bluetooth blueman-mechanism cups.socket cups.path cups cups-browsed ModemManager avahi-daemon.socket avahi-daemon kerneloops
```

Se o equipamento tiver ZFS instalado, desative também: `zfs-zed`, `zfs-share`, `zfs-mount`, `zfs-volume-wait`, `zfs-import-cache`, `zfs-load-module`.

### 4.4 Programas desnecessários: remover

Sempre simule antes de remover:

```
sudo apt-get -s purge <pacote>
sudo apt-get purge <pacote>
```

Removidos neste projeto: Firefox, Thunderbird, LibreOffice (todos os pacotes), Rhythmbox, Celluloid, Hypnotix, Transmission, HexChat, Pix, Drawing, Document Scanner, Redshift, Warpinator, Onboard, OpenVPN e plugins, e kernels antigos. Isso liberou cerca de 3,4 GB.

Mantidos de propósito: Python, fontes, temas, Timeshift e Synaptic.

## 5. Vídeo

### Sem monitor, o acesso remoto mostra "No Displays"

Uma saída "fantasma" (VGA) aparece como conectada, mas não mantém a tela viva. Solução: forçar o HDMI-1 como sempre ativo pelo parâmetro de kernel. Em `/etc/default/grub`:

```
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash video=HDMI-A-1:1920x1080@60e"
```

Depois:

```
sudo cp /etc/default/grub /etc/default/grub.bak-hdmi
sudo update-grub
```

(Faça o backup antes de editar.) Sem monitor, a tela virtual sobe em 1024x768, o que basta para acesso remoto.

A TV deve ficar sempre na mesma porta HDMI (HDMI-1). Em outra porta o sistema passaria a ver duas telas e as imagens podem se sobrepor.

### Resolução

O sistema pode ficar guardado em 1024x768 depois de um teste sem monitor. O script [`display.sh`](../../scripts/display.sh) reaplica 1920x1080 no HDMI-1 ao iniciar o carrossel e a cada volta.

### Imagem cortada nos cantos (overscan)

Na própria TV, ajuste o formato da imagem para o modo que não corta (em várias marcas, "Just Scan", "Tela cheia" ou "1:1"). Não é problema do Linux.

## 6. Google Chrome e chaveiro

```
sudo apt install ./google-chrome-stable_current_amd64.deb
sudo apt install xdotool unclutter
```

Na primeira abertura o Chrome pede uma senha de chaveiro ("Choose password for new keyring"), por causa do login automático. Deixe a senha em branco e confirme "Use Unsafe Storage". O quiosque também usa `--password-store=basic` e um perfil próprio em `~/kiosk/chrome-profile`. Não guarde senhas pessoais nesse Chrome.

## 7. Firewall (ufw)

Política: bloquear a entrada e liberar a saída. O Chrome e os sites do carrossel só usam conexões de saída, por isso não são afetados.

```
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow from 192.0.2.0/24 to any port 22 proto tcp
sudo ufw allow from 198.51.100.0/24 to any port 22 proto tcp
sudo ufw allow from 203.0.113.0/24 to any port 22 proto tcp
sudo ufw enable
```

Antes de ativar, mantenha uma sessão SSH aberta como garantia. Estado: `sudo ufw status verbose`.

O RustDesk, usando os servidores públicos, só faz conexões de saída e não precisa de regra de entrada.

## 8. Carrossel

Crie a pasta `~/kiosk` e copie para ela:

| Origem | Destino |
|---|---|
| `scripts/kiosk.sh`, `display.sh`, `stop.sh`, `start.sh`, `auto.sh`, `notice.sh` | `~/kiosk/` (torne executáveis com `chmod +x ~/kiosk/*.sh`) |
| `web/welcome.html` | `~/kiosk/welcome.html` |
| `config/urls.txt.example` | `~/kiosk/urls.txt` (edite com as suas URLs) |
| `config/kiosk.desktop` | `~/.config/autostart/kiosk.desktop` |
| `config/crontab.example` | cole no `crontab -e` do usuário |

Como funciona:

- **`kiosk.sh`:** espera a rede, ajusta a tela, abre o Chrome em tela cheia com as URLs de `urls.txt` e, a cada 45 segundos, foca a janela, vai para a próxima aba (`Ctrl+Tab`, se houver mais de uma) e recarrega (`F5`). Se o Chrome fechar, o script recomeça sozinho.
- **`start.sh`:** liga o carrossel se ainda não estiver rodando. Serve para o cron, para o SSH e para hora extra.
- **`stop.sh`:** encerra tudo. Usado pelo cron no fim do expediente e como saída de emergência.
- **`auto.sh`:** chamado no login. Só liga dentro do horário (segunda a sexta, das 08:00 às 18:00). Se o equipamento reiniciar fora do horário, o carrossel não abre.
- **`notice.sh` + `welcome.html`:** mostram uma tela de boas-vindas ou despedida por 20 segundos sobre o carrossel, abrindo a página como uma aba nova e fechando com `Ctrl+W`. Enquanto isso, o `kiosk.sh` pausa a troca de abas por meio do arquivo `/tmp/kiosk-pause`. O idioma das mensagens vem da variável `KIOSK_LANG` (`en`, `pt` ou `es`), definida no início do crontab.
- **Cron:** liga e encerra no horário e dispara as telas de aviso. Para mudar o horário, `crontab -e`.

Depois de mudar o `urls.txt`, reinicie o carrossel: `~/kiosk/stop.sh` e depois `~/kiosk/start.sh`. O `urls.txt` é lido apenas na inicialização.

### Uso no dia a dia

- **Ligar à mão (hora extra, fim de semana):** `~/kiosk/start.sh`. Fora do horário normal não aparece tela de boas-vindas. Um carrossel ligado depois do horário fica ligado até alguém rodar `~/kiosk/stop.sh`.
- **Mostrar uma tela de aviso na hora:** `~/kiosk/notice.sh welcome` ou `~/kiosk/notice.sh goodbye`. Só funciona com o carrossel rodando.
- **Ligar e desligar a TV:** feito à mão pela equipe. O mini PC não controla a TV. Ao fechar o carrossel, a área de trabalho do Linux aparece na TV.

## 9. Como validar

Reinicie o equipamento com a TV conectada na HDMI-1, sem tocar em nada. O esperado é o Chrome abrir sozinho em tela cheia, com as páginas trocando a cada 45 segundos, a imagem completa e nítida.

Comandos de verificação:

```
DISPLAY=:0 xrandr --listmonitors                        # HDMI-1 em 1920x1080
systemctl is-active ssh rustdesk NetworkManager cron    # todos "active"
pgrep -fa kiosk.sh                                      # quiosque em execução (dentro do horário)
ip -4 -brief addr show                                  # IP fixo
sudo ufw status verbose                                 # ativo, SSH só nas faixas liberadas
crontab -l                                              # agendamento
timedatectl                                             # fuso e relógio sincronizado
```

O disparo pelo próprio cron só pode ser validado no primeiro dia útil: boas-vindas às 08:00 e 13:00 e despedida às 17:59:40. Para simular o ambiente reduzido do cron sem mexer no agendamento:

```
env -i HOME=$HOME PATH=/usr/bin:/bin /bin/sh -c '/home/kiosk/kiosk/notice.sh goodbye'
```

## 10. Problemas comuns

| Sintoma | Causa provável | O que fazer |
|---|---|---|
| Acesso remoto mostra "No Displays" | Sem monitor, a saída ativa não existe | Aplicar o parâmetro `video=HDMI-A-1:1920x1080@60e` (seção 5) |
| Imagem cortada nos cantos | Overscan da TV | Mudar o formato da imagem na TV |
| Resolução 1024x768 mesmo com a TV em Full HD | Modo guardado de um teste sem monitor | O `display.sh` já reaplica 1920x1080; conferir com `xrandr --listmonitors` |
| Chrome pede senha de chaveiro | Login automático sem chaveiro destravado | Senha em branco e "Use Unsafe Storage" (seção 6) |
| Imagens sobrepostas em duas telas | TV ligada em outra porta HDMI | Voltar a TV para a HDMI-1 |
| Carrossel não abre depois de reiniciar | Reiniciou fora do horário | `~/kiosk/start.sh` |
| Alt+F4 ou F11 e o Chrome volta sozinho | O `kiosk.sh` reabre o Chrome | Use `~/kiosk/stop.sh` |
| Página com token deixa de abrir | Token expirado ou removido | Gerar outro token e atualizar o `urls.txt` |
| Aparecem avisos do sistema sobre o carrossel | `mintupdate` ou outro aplicativo | Desativar o item em `~/.config/autostart` (seção 4.2) |
