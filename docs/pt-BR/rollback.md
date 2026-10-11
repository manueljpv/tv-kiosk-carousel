# Como reverter cada mudança

Antes de começar, crie um ponto de restauração com o Timeshift (RSYNC no disco do sistema). Ele resolve a maioria dos problemas:

```
sudo timeshift --create --comments "antes da mudança" --tags D
sudo timeshift --list
```

| Mudança | Como reverter |
|---|---|
| Telas de boas-vindas e despedida | `crontab -e` e apague as três linhas do bloco "Welcome and goodbye screens". Os arquivos `notice.sh` e `welcome.html` podem ficar na pasta sem efeito. |
| Pausa do `kiosk.sh` para o aviso | Remova a linha com `/tmp/kiosk-pause` do `kiosk.sh`. |
| Horário automático | `crontab -r` apaga todo o agendamento do usuário (ou `crontab -e` para tirar só uma linha). Para voltar a abrir o carrossel em qualquer reinício, troque o `Exec` do `kiosk.desktop` para `/home/kiosk/kiosk/start.sh`. |
| Quiosque no login | `rm ~/.config/autostart/kiosk.desktop` e `~/kiosk/stop.sh` para parar o que estiver rodando. |
| Firewall | `sudo ufw disable` (desliga) ou `sudo ufw reset` (apaga todas as regras). Para tirar só uma regra: `sudo ufw status numbered` e `sudo ufw delete <número>`. |
| HDMI forçado | `sudo cp /etc/default/grub.bak-hdmi /etc/default/grub && sudo update-grub`, depois reiniciar. |
| Suspensão e hibernação | `sudo systemctl unmask sleep.target suspend.target hibernate.target hybrid-sleep.target` e `sudo rm /etc/systemd/logind.conf.d/99-always-on.conf`. |
| Itens de início automático | Apague o `.desktop` correspondente em `~/.config/autostart/`. |
| Serviços desativados | `sudo systemctl enable --now bluetooth cups cups-browsed avahi-daemon ModemManager` (e `cups.socket`, `avahi-daemon.socket`). |
| IP fixo | `sudo nmcli connection modify "Wired connection 1" ipv4.method auto ipv4.ignore-auto-dns no ipv4.addresses "" ipv4.gateway "" ipv4.dns ""` e `sudo nmcli connection up "Wired connection 1"`. |
| Programas removidos | `sudo apt install <pacote>`. Um kernel antigo removido não deve ser reinstalado. |
| SSH | `sudo systemctl disable --now ssh` e `sudo ufw delete <número>` das regras da porta 22. Antes, confirme que o RustDesk funciona. |
