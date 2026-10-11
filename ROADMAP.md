# Roadmap

**Português** · [English](ROADMAP.en.md) · [Español (Honduras)](ROADMAP.es-HN.md)

Melhorias previstas para o projeto e o que aprendemos até aqui. São ideias, sem prazo garantido, e a ordem não é definitiva.

## Curto prazo

Melhorias pequenas, que cabem nos scripts e na configuração atuais.

- [ ] **Feriados.** O cron só conhece dias da semana: o carrossel liga e as telas de aviso aparecem em qualquer dia útil, inclusive feriados. Criar uma lista de datas (`holidays.txt`) que o `auto.sh` e o `start.sh` consultem antes de ligar.
- [ ] **Atualizações automáticas de segurança.** Com o `mintupdate` desativado, as atualizações são manuais. Avaliar o `unattended-upgrades` apenas para segurança, com reinício controlado fora do horário de expediente.
- [ ] **Configuração em um só lugar.** Hoje o horário está no crontab e no `auto.sh`, e o intervalo no `kiosk.sh`. Reunir tudo em um arquivo `kiosk.conf` (horário, intervalo, idioma, lista de feriados).
- [ ] **Reinício periódico do Chrome.** Em carrosséis que ficam ligados por muitos dias, o Chrome pode consumir mais memória. Reiniciar só o quiosque (não o equipamento) uma vez por dia, fora do horário.
- [ ] **Tela de repouso fora do horário.** Ao encerrar o carrossel, a área de trabalho do Linux aparece na TV. Trocar por uma tela preta ou por uma imagem simples.
- [ ] **Atalho de teclado de saída.** Um atalho que rode o `stop.sh`, para quem estiver com teclado ligado ao equipamento.
- [ ] **Tempo por página.** Permitir um intervalo diferente para cada URL (por exemplo, `url;60`).
- [ ] **Testes automáticos.** Rodar `shellcheck` nos scripts a cada alteração (GitHub Actions).

## Longo prazo

Mudanças maiores, que exigem projeto próprio.

- [ ] **Ligar e desligar a TV automaticamente.** Hoje a TV é ligada e desligada à mão. Testar HDMI-CEC (`libcec`) para o mini PC controlar a TV, nos modelos que suportarem.
- [ ] **Servidor RustDesk próprio.** Hoje o RustDesk usa os servidores públicos do projeto. Montar um servidor próprio dá mais controle de acesso e de registros.
- [ ] **Vários equipamentos.** Padronizar a implantação em outros mini PCs idênticos: um script `install.sh` que aplica tudo, ou um playbook Ansible, e uma configuração por equipamento (IP, páginas, horário).
- [ ] **Monitorar o próprio carrossel.** Um sinal de "estou vivo" (heartbeat) enviado a uma ferramenta de monitoramento, com alerta se o carrossel parar ou a página sair do ar.
- [ ] **Menos dependências.** Trocar o `xdotool` (que simula teclas) por controle direto do Chrome (porta de depuração), e avaliar um ambiente gráfico mínimo em vez do Xfce completo.
- [ ] **Conteúdo por horário.** Páginas diferentes por período do dia ou da semana, e uma mensagem de aviso urgente que se sobreponha ao carrossel.

## O que aprendemos

- **Reaproveitar equipamento parado vale a pena.** Mini PCs esquecidos em um armário foram uma solução melhor que um notebook: menor, mais frio, com porta de rede cabeada e sem peça móvel. Antes de comprar ou adaptar, procure o que já existe.
- **Teste o HDMI com alguém ao lado do equipamento.** Um kernel mais novo travou o sistema ao conectar o cabo (e derrubou o acesso remoto). Fixar o kernel que funciona resolveu. Descarte as causas uma a uma, com testes, em vez de culpar cabo, TV ou navegador.
- **Simule antes de remover.** `apt -s purge` mostra o que sairá junto. Faça um ponto de restauração (Timeshift) antes de mexer no sistema.
- **Mantenha uma sessão SSH aberta ao ligar o firewall.** Se a regra estiver errada, você ainda consegue desfazer.
- **Mude uma coisa por vez e valide com um reinício.** Em um equipamento sem teclado e sem tela de apoio, o reinício é o teste que importa.
- **O cron só conhece minutos e um ambiente reduzido.** Para ajustar segundos use `sleep`, e teste o script com o ambiente mínimo (`env -i`) antes de confiar nele.
- **Um carrossel precisa se reiniciar sozinho.** Se o Chrome fechar, o script recomeça; fora do horário, o `auto.sh` impede que ele abra sem necessidade.
- **Tokens e URLs de dashboards são segredos.** Fique com o `urls.txt` real fora do repositório (`.gitignore`) e publique só o `urls.txt.example`.
- **Nem tudo é problema do Linux.** Imagem cortada nos cantos (overscan) se resolve na própria TV.
- **Documente enquanto faz.** O passo a passo, o que deu errado e como reverter são o que torna o projeto repetível em outro equipamento.
