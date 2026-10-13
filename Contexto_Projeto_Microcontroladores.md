# Contexto do projeto --- Monitoramento e Controle Inteligente de Temperatura

## 1. Objetivo

Desenvolver um sistema embarcado com o microcontrolador **STM8S003F3P6**
para monitorar a temperatura medida por um sensor **LM35** e regular
automaticamente a velocidade de uma ventoinha de 5 V. O sistema também
terá um display LCD 16×2 com interface I²C, um LED de status e um botão
que força a ventoinha a operar em potência máxima.

A IA que receber este documento deverá ajudar a desenvolver o firmware
em C, explicar as decisões técnicas e orientar a implementação passo a
passo. O código precisa corresponder ao circuito real e à
biblioteca/ferramenta de compilação efetivamente utilizada.

## 2. Componentes identificados no esquemático atual

-   **Microcontrolador:** STM8S003F3P (o projeto prevê o STM8S003F3P6).
-   **Sensor de temperatura:** LM35, alimentado em +5 V, com capacitor
    de desacoplamento de 100 nF entre alimentação e GND. A saída é
    identificada como `TEMP`.
-   **Ventoinha:** motor/ventoinha de 5 V.
-   **Chaveamento da ventoinha:** MOSFET 2N7000 em configuração de
    chaveamento pelo lado do GND (low-side). O sinal de controle é
    `PWM`, passando por resistor de 100 Ω até o gate; há resistor de 10
    kΩ do gate para GND. O esquema mostra também um diodo 1N4007 em
    paralelo com o motor e capacitor de 100 µF na alimentação da
    ventoinha.
-   **Display:** LCD 16×2 com interface I²C, alimentado em +5 V. As
    linhas `SCL` e `SDA` têm resistores de pull-up de 4,7 kΩ para +5 V.
-   **Botão:** `Max_Cooler`, identificado pelo sinal `BTN`, conectado ao
    GND quando pressionado.
-   **LED de status:** sinal `LED`, resistor de 1 kΩ em série com o LED
    e retorno ao GND.

## 3. Ligações indicadas no esquemático

As conexões abaixo foram lidas visualmente do PDF. **Confirme-as no
arquivo original do KiCad e no datasheet do encapsulamento antes de
fechar o firmware.**

  -----------------------------------------------------------------------
  Sinal                   Pino indicado no        Função prevista
                          símbolo do MCU          
  ----------------------- ----------------------- -----------------------
  `BTN`                   PA3, pino físico        Leitura do botão de
                          indicado como 10        potência máxima

  `SCL`                   PB4, pino indicado como Clock do barramento I²C
                          12                      do LCD

  `SDA`                   PB5, pino indicado como Dados do barramento I²C
                          11                      do LCD

  `PWM`                   PC3, pino indicado como Controle da ventoinha
                          13                      por PWM

  `TEMP`                  PD2, pino indicado como Leitura analógica da
                          19                      saída do LM35

  `LED`                   PD4, pino indicado como LED de status
                          2                       

  Alimentação do MCU      VDD e VSS conforme      Alimentação e terra
                          símbolo                 
  -----------------------------------------------------------------------

A numeração de pinos apresentada é a que aparece no esquemático e deve
ser conferida com o pinout oficial do STM8S003F3P6. Não presuma que um
pino aceita ADC, PWM ou I²C apenas pelo nome da porta: valide a função
periférica no datasheet e na biblioteca de firmware.

## 4. Comportamento desejado do sistema

1.  Inicializar clock, GPIOs, ADC, temporizador/PWM, I²C e display LCD.
2.  Ler periodicamente a saída analógica do LM35.
3.  Converter a leitura do ADC em tensão e depois em temperatura em °C.
4.  Ajustar o duty cycle do PWM conforme a temperatura: quanto maior a
    temperatura, maior a velocidade da ventoinha.
5.  Mostrar no LCD a temperatura e, se houver espaço, o percentual de
    acionamento da ventoinha e/ou o modo atual.
6.  Acender o LED de status para indicar que o sistema está funcionando.
    A IA deve propor e documentar claramente o significado do LED.
7.  Quando o botão `BTN` for pressionado, comandar a ventoinha em
    potência máxima, independentemente da temperatura. Ao soltar o
    botão, voltar ao controle automático.
8.  Tratar leituras inválidas ou condições fora da faixa plausível de
    temperatura de forma segura e documentada.

## 5. Requisitos para a lógica de controle

A faixa exata de temperatura e os percentuais de PWM ainda precisam ser
definidos. Não invente esses valores como se fossem especificações do
projeto. Proponha valores iniciais configuráveis, identifique-os como
parâmetros provisórios e explique como ajustá-los durante os testes.

Como ponto de partida, considerar uma estratégia simples por faixas ou
uma relação linear entre temperatura mínima e máxima. Evitar que a
ventoinha fique alternando rapidamente entre velocidades perto de um
limite; avaliar histerese, filtragem por média de leituras ou uma
combinação simples dessas técnicas.

O firmware deve: - limitar o duty cycle ao intervalo permitido; - evitar
divisão por zero e conversões numéricas incorretas; - definir o
comportamento para temperatura abaixo da faixa, acima da faixa e leitura
inválida; - priorizar a potência máxima quando o botão estiver
pressionado; - manter o código simples, legível e adequado a um
microcontrolador com recursos limitados.

## 6. Cuidados importantes de hardware a verificar

-   **Compatibilidade do sinal do LM35 com o ADC:** confirmar a
    referência de tensão do ADC, resolução e alimentação do MCU. A saída
    do LM35 é de aproximadamente 10 mV/°C; a conversão deve usar a
    referência real do ADC.
-   **Pino ADC:** confirmar se o pino identificado como PD2/AIN
    correspondente é válido no modelo e encapsulamento usados.
-   **PWM:** confirmar se PC3 possui canal de temporizador PWM
    compatível com o STM8S003F3P6. Caso não possua, avaliar outro
    pino/canal disponível ou PWM por software, explicando os impactos.
-   **Acionamento do motor:** confirmar se o 2N7000 suporta a corrente
    de partida e de operação da ventoinha com a tensão de gate fornecida
    pelo MCU. Se necessário, recomendar um MOSFET logic-level
    apropriado, sem alterar silenciosamente o esquemático.
-   **Diodo de proteção:** confirmar a orientação do 1N4007 e sua
    adequação à carga. O diodo deve estar em polarização reversa durante
    o funcionamento normal da ventoinha.
-   **Alimentação e terra:** verificar corrente disponível na fonte de 5
    V, desacoplamento e GND comum entre o circuito de controle e a
    ventoinha.
-   **LCD I²C:** confirmar o controlador/backpack, endereço I²C e
    biblioteca disponível. O endereço não aparece definido no
    esquemático.
-   **Pull-ups I²C:** confirmar que os níveis elétricos são seguros para
    os pinos do MCU e que os pull-ups existentes não entram em conflito
    com módulos que já possuam resistores.
-   **Reset e alimentação do MCU:** verificar no esquemático completo os
    componentes necessários ao funcionamento confiável do STM8S003F3P6.

## 7. Ambiente de desenvolvimento e estilo do código

O ambiente de compilação ainda deve ser confirmado com o grupo. A
implementação pode usar **C com a biblioteca STM8S Standard Peripheral
Library (SPL)**, caso esse seja o ambiente adotado. Antes de produzir
código final, perguntar ou explicitar as suposições sobre: -
compilador/IDE (por exemplo, Cosmic, SDCC ou outro); - versão e
disponibilidade da SPL; - clock configurado no MCU; - referência e
resolução do ADC; - timer/canal e frequência PWM desejada; - biblioteca
e endereço I²C do LCD.

Não misturar APIs de compiladores ou bibliotecas diferentes no mesmo
código. Se algum dado indispensável estiver ausente, primeiro listar o
que precisa ser confirmado ou apresentar uma versão claramente marcada
como exemplo, com os pontos pendentes destacados.

## 8. O que esperamos da IA

Desenvolva a solução gradualmente:

1.  Revise o esquema e liste inconsistências ou pontos a validar,
    principalmente ADC, PWM, MOSFET, alimentação e pinagem.
2.  Proponha a arquitetura do firmware e um mapa de pinos confirmado.
3.  Explique o cálculo de temperatura a partir do ADC, mostrando a
    fórmula e as unidades.
4.  Implemente o código em C compatível com o compilador e as
    bibliotecas confirmadas.
5.  Separe o código em funções claras, por exemplo: inicialização,
    leitura e conversão do LM35, cálculo do PWM, leitura do botão,
    atualização do LCD e atualização do LED.
6.  Comente as partes importantes e explique o funcionamento em
    linguagem acessível a estudantes.
7.  Forneça um plano de testes em etapas: leitura ADC, validação da
    temperatura, PWM, botão de potência máxima, LCD e teste integrado.
8.  Indique instrumentos e medições úteis (multímetro, osciloscópio,
    quando disponível) e os resultados esperados.
9.  Não afirme que o código foi testado fisicamente. Diferencie o que
    foi validado por análise do que ainda precisa ser testado na
    bancada.

## 9. Informações ainda pendentes

-   Faixa de temperatura desejada para início e potência máxima da
    ventoinha.
-   Corrente nominal e corrente de partida da ventoinha.
-   Confirmação da pinagem e das funções periféricas no datasheet.
-   Frequência de PWM pretendida.
-   Compilador/IDE e biblioteca disponíveis.
-   Endereço I²C e controlador do LCD.
-   Definição exata do comportamento do LED.
-   Confirmação da alimentação e da referência do ADC.

## 10. Fonte do contexto

Este documento foi elaborado a partir do esquemático preliminar
"Monitoramento e Controle Inteligente de Temperatura", versão 1.0,
datado de 12/10/2026, fornecido pelo grupo em PDF. O esquemático é uma
referência do estado atual do projeto, não uma confirmação de que todas
as ligações já foram verificadas eletricamente.
