# Alternativas e lições aprendidas

## Por que não usamos um notebook

A primeira versão do projeto rodou em um notebook antigo conectado à TV, com tampa fechada e tela interna desligada. Funcionou, mas o arranjo era ruim: o notebook esquentava mesmo depois de manutenção e limpeza, e deixar um notebook fechado atrás da TV não é prático nem seguro. O que resolveu foi procurar equipamentos parados na própria empresa. Mini PCs de uso anterior em rede estavam parados em um armário. Eles são pequenos, aquecem pouco, têm porta de rede cabeada e já têm saídas de vídeo prontas para a TV. Reaproveitar equipamento parado foi mais simples, mais barato e mais confiável do que adaptar um notebook.

## Dois problemas que podem aparecer em outro equipamento

No notebook, que usava gráficos Intel de 10ª geração (Ice Lake), conectar o cabo HDMI com o sistema ligado travava a máquina por completo, a ponto de derrubar o acesso remoto. O problema era uma regressão em um kernel mais novo (série 7.x) com o driver de vídeo Intel; um kernel anterior (6.14) funcionava. A solução foi fixar o kernel que funcionava no GRUB e travar os pacotes de kernel que o atualizariam. Quem for reaproveitar hardware semelhante deve testar o HDMI com alguém ao lado do equipamento e, se travar, testar outro kernel antes de culpar o cabo, a TV ou o navegador. O Chrome e a aceleração por GPU foram descartados como causa.

O segundo problema foi o Wi-Fi, que por padrão tem economia de energia ligada e pode ficar instável em um equipamento que nunca descansa. Desligar a economia de energia do Wi-Fi no NetworkManager e manter as tentativas de reconexão ativas estabilizou a conexão. Sempre que possível, prefira cabo de rede para um equipamento que precisa ficar ligado todos os dias sem supervisão.
