# README — Monitoramento e Controle Inteligente de Temperatura (STM8S003F3P6)

> Documento de referência completo do firmware. Gerado em 13/10/2026 para
> servir como registro autônomo do trabalho — dispensa consultar o chat da IA.

---

## 1. Visão geral do projeto

Sistema embarcado que mede temperatura com **LM35** (10 mV/°C) e regula a
velocidade de uma **ventoinha 5 V** por PWM, chaveada por MOSFET **2N7000**
em low-side. Mostra dados em **LCD 16×2 via I²C** (backpack PCF8574,
endereço 0x27), tem **LED de status** e **botão** que força potência máxima.

| Item | Valor |
|---|---|
| MCU | STM8S003F3P6 (TSSOP-20, 8 KB flash, 1 KB RAM) |
| Clock | HSI interno 16 MHz (`CLK_PRESCALER_HSIDIV1`) |
| IDE/toolchain | ST Visual Develop (STVD) + Cosmic CXSTM8 + STM8S SPL |
| Projeto STVD | `trabalho_microcontroladores\lcd16x2_i2c.stp` (workspace `LCD16x2_I2C.stw`) |
| Fonte editado | **apenas `main.c`** (nenhuma outra configuração foi alterada) |

**Estado atual do firmware (13/10/2026):**

- [x] Código completo (leitura, controle, PWM, LCD, botão, LED, falhas)
- [x] Compilado e linkado com o compilador real do projeto, sem erros nem warnings, nas duas configurações: **Debug 4.867 B / Release 4.425 B** (limite: 8.128 B)
- [ ] **Teste físico na bancada** — tudo abaixo já está pronto para testar, mas NÃO foi validado em hardware real

---

## 2. Hardware — mapa de pinos validado

Pinagem conferida contra o datasheet do TSSOP-20 (biblioteca oficial KiCad +
núcleo sduino, testado em hardware real — ver §10 Fontes).

| Sinal | Esquemático | Real (TSSOP-20) | Função no firmware | Status |
|---|---|---|---|---|
| `TEMP` | PD2, pino 19 | igual | **AIN3** → ADC1 canal 3 | ✅ válido |
| `PWM` | PC3, pino 13 | igual | **TIM1_CH3** → PWM | ✅ válido |
| `BTN` | PA3, pino 10 | igual | entrada digital c/ pull-up interno | ✅ válido |
| `SCL` | PB4, pino 12 | igual | I²C por hardware | ✅ válido |
| `SDA` | PB5, pino 11 | igual | I²C por hardware | ✅ válido |
| `SWIM` | PD1, pino 18 | igual | gravação (ST-Link) | ✅ válido |
| `LED` | PD4, **pino 2** | **pino 2 é PD5; PD4 é pino 1** | saída digital | ⚠️ ver abaixo |
| VDD | **pino 21** | pino 9 | alimentação | ⚠️ erro de símbolo |

### ⚠️ Inconsistências encontradas no esquemático v1.0

1. **LED (importante):** o símbolo do MCU rotula "PD4" no pino 2, mas no
   TSSOP-20 oficial o pino 2 é **PD5** (PD4 é o pino 1). O firmware usa
   **PD4** (`main.c:77-78`). Se o LED não acender na bancada:
   - trocar `LED_GPIO_PIN` de `GPIO_PIN_4` para `GPIO_PIN_5` e recompilar;
   - e corrigir o número do pino no símbolo do KiCad (PD4 → pino 1).
2. **VDD rotulado "pino 21":** TSSOP-20 não existe pino 21; VDD é o pino 9
   (VSS é o pino 8 — este está correto no esquemático). Sem impacto no
   firmware; corrigir no KiCad.
3. **Botão sem pull-up externo** no esquemático (fecha direto para GND) — o
   firmware habilita o **pull-up interno** do PA3, que resolve. Correto, mas
   vale registrar.
4. **Observações a confirmar na bancada** (pendências do documento de contexto):
   - corrente da ventoinha: o 2N7000 suporta **200 mA contínuos** — típico de
     ventoinha pequena de 5 V (~80–150 mA), mas confirmar no datasheet da
     ventoinha usada (corrente de partida também);
   - orientação do **1N4007** (flyback em paralelo com a ventoinha): a barra
     (cátodo) deve apontar para o +5 V — no PDF parece correto, confirmar;
   - alimentação 5 V estável e com corrente suficiente (MCU + LCD + ventoinha);
   - endereço I²C do backpack: **0x27** (A0–A2 abertos). Se o LCD não
     responder, rodar o `I2C_Scan.c` que já está no projeto.

### Circuito (como o firmware enxerga)

```
LM35 (10 mV/°C) ── TEMP ──> PD2/AIN3 (ADC 10 bits, VREF = VDD)

PC3/TIM1_CH3 ── PWM ── R 100Ω ── gate 2N7000 ── source ── GND
                                            └─ R 10kΩ gate→GND (pull-down)
Nível ALTO em PC3 = MOSFET conduzindo = ventoinha LIGADA
(dreno no negativo da ventoinha; +5 V no positivo; 1N4007 + 100 µF em paralelo)

PA3 ── BTN ── botão ── GND  (pressionado = nível baixo; pull-up interno)

PD4 ── R 1kΩ ── LED ── GND  (nível alto = aceso)
```

---

## 3. Arquitetura do firmware

### Arquivos do projeto (build STVD)

| Arquivo | Papel | Situação |
|---|---|---|
| `main.c` | **firmware do trabalho** (reescrito) | novo |
| `delay.c/.h` | delays calibrados p/ 16 MHz | inalterado |
| `LCD_PCF8574_I2C.c/.h` | driver do LCD via PCF8574 | inalterado |
| `stm8_interrupt_vector.c` | vetores de interrupção (padrão) | inalterado |
| `STStdPerLib/src/stm8s_{clk,gpio,i2c}.c` | SPL usada pelo driver | inalterado |
| `I2C_Scan.c` | utilitário de varredura I²C (fora do build) | inalterado |

### Estrutura do `main.c` (funções e linhas)

| Linha | Função | O que faz |
|---|---|---|
| 141 | `Clock_Config()` | HSI 16 MHz sem divisão (delay.c e I²C dependem) |
| 148 | `GPIO_Config()` | LED saída PP; botão entrada c/ pull-up; PD2 flutuante; PC3 saída |
| 181 | `ADC_Config()` | ADC1 por registradores: canal 3, fADC 2 MHz, alinhado à direita |
| 214 | `PWM_Config()` | TIM1 por registradores: PWM 1 kHz no canal 3 (PC3), inicia 0% |
| 257 | `Temperatura_Ler()` | média de 16 conversões → décimos de °C; detecta falha |
| 310 | `Controle_Duty()` | histerese + rampa linear + prioridade do botão → 0–100% |
| 353 | `Fan_SetDuty()` | duty → CCR3 do TIM1 (true 100% quando duty=100) |
| 374 | `Botao_Pressionado()` | lê PA3 (1 = pressionado) |
| 397 | `NumeroParaTexto()` / `CompletarLinha()` | formatação p/ LCD (sem printf) |
| 422 | `LCD_LinhaTemperatura()` | linha 1: `Temp: 25.4°C` (0xDF = °) |
| 446 | `LCD_LinhaVentoinha()` | linha 2: `Fan: 45% AUTO` / `100% MAX` / `OFF` |
| 485 | `LCD_MostrarErro()` | `Falha no sensor!` / `Ventoinha: 100%` |
| 497 | `Tratar_FalhaSensor()` | fan 100%, LED pisca, repete leitura até normalizar |
| 517 | `main()` | inicializa tudo e roda laço a cada 250 ms |

### Lógica de controle

```
temperatura < 28,0 °C  ──────────────► ventoinha DESLIGADA (0%)
28,0–30,0 °C           ──────────────► histerese (mantém o estado anterior)
30,0 °C (ligando)      ──────────────► liga em 35% (DUTY_MINIMO_PCT)
30,0–50,0 °C           ─ rampa linear ► 35% → 100%
≥ 50,0 °C              ──────────────► 100%
botão pressionado      ──────────────► 100% (prioridade total, "MAX")
falha do sensor        ──────────────► 100% + LED piscando (falha "esfriando")
```

- **Filtragem:** média de 16 amostras do ADC por ciclo (anti-ruído).
- **Histerese:** 2 °C entre ligar (30) e desligar (28) evita oscilação.
- **LED:** aceso fixo = operação normal; piscando rápido = falha do sensor.
- **Laço principal:** 250 ms (leitura → controle → PWM → LCD).

### Conversão ADC → temperatura (fórmula)

ADC de 10 bits (0–1023), fundo de escala = VREF = VDD ≈ 5 V:

```
tensão [mV]  = bruto × VREF_MV / 1023
temperatura [°C] = tensão [mV] / 10        (LM35: 10 mV por °C)

⇒  T em DÉCIMOS de °C = bruto × VREF_MV / 1023   (número = mV, sem float)
```

Resolução: 5000/1023 ≈ 4,9 mV/LSB ≈ **0,49 °C por bit**. Precisão absoluta
depende do VDD real (±5% no VDD ≈ ±1,2 °C a 25 °C) — ajustar `VREF_MV`.

---

## 4. Parâmetros PROVISÓRIOS (ajustar na bancada)

Todos no topo do `main.c`, seção `PARAMETROS PROVISORIOS`. **Não são
especificação do projeto** — são ponto de partida (o documento de contexto
exige que sejam tratados assim).

| Linha | #define | Padrão | Efeito / como ajustar |
|---|---|---|---|
| 95 | `VREF_MV` | 5000 | Tensão real do VDD em mV. Medir com multímetro e corrigir (1% erro → 1% erro na temp.) |
| 98 | `TEMP_DESLIGA_X10` | 280 (28 °C) | Temperatura que desliga a ventoinha |
| 99 | `TEMP_LIGA_X10` | 300 (30 °C) | Temperatura que liga. LIGA−DESLIGA = histerese |
| 100 | `TEMP_MAXIMA_X10` | 500 (50 °C) | A partir daqui, 100% |
| 106 | `DUTY_MINIMO_PCT` | 35 | Duty com a ventoinha ligada. Se ela travar/girar fraco, aumentar |
| 113 | `PWM_FREQUENCIA_HZ` | 1000 | Frequência do PWM. 25000 = silencioso (o 100 µF filtra → tensão ~DC) |
| 116 | `ADC_AMOSTRAS` | 16 | Amostras por média |
| 119 | `LOOP_MS` | 250 | Período do laço principal |
| 123/124 | `TEMP_{MINIMA,MAXIMA}_VALIDA_X10` | 20/1500 | Faixa plausível (LM35: 2–150 °C). Fora = falha |
| 77–78 | `LED_GPIO_PIN` | `GPIO_PIN_4` | Se o LED não acender: trocar para `GPIO_PIN_5` (ver §2) |

Valores em décimos de grau (X10) de propósito — aritmética inteira em
microcontrolador de 8 bits, sem ponto flutuante.

---

## 5. Decisão técnica: ADC1/TIM1 por registradores (importante!)

**O problema:** o STM8S003 tem só 8 KB de flash e o linker do Cosmic
(`clnk`) inclui **o arquivo `.c` inteiro** quando ele está listado no
projeto — não descarta funções não usadas. Testado de verdade: adicionando
`stm8s_adc1.c` + `stm8s_tim1.c` ao projeto, a build **Debug** (padrão do
STVD, sem otimização) estoura os 8 KB em ~140 bytes (dava 8.194 B).

**A solução adotada:** ADC1 e TIM1 configurados por escrita direta nos
registradores dentro do `main.c` (seções `ADC_Config` e `PWM_Config`,
comentadas bit a bit). GPIO/CLK/I²C/LCD continuam usando a SPL que já
estava no projeto. Resultado:

| Config | Tamanho | Limite |
|---|---|---|
| Debug (sem otimização, `-no`) | 4.867 B | 8.128 B ✅ |
| Release (otimizado) | 4.425 B | 8.128 B ✅ |

**Consequência prática: NÃO adicionar `stm8s_adc1.c`/`stm8s_tim1.c` ao
projeto STVD**, nem descomentar os includes deles em
`STStdPerLib/inc/stm8s_conf.h`, sem antes medir o tamanho do firmware.

Detalhes de registradores usados (documentados no próprio main.c):
- **ADC1**: `CR1` (ADON liga/inicia; SPSEL=100 → fADC=2 MHz), `CR2`
  (ALIGN=1 → alinhado à direita), `CSR` (canal=3; bit7 EOC), `DRH:DRL`
  (resultado). Sequência: ADON=1 liga → ADON=1 de novo inicia → espera
  EOC → lê DRH:DRL.
- **TIM1**: `PSCRH/L`=0 (16 MHz), `ARRH/L`=15999 (1 kHz), `CCMR2`=0x68
  (OC3M=110 PWM modo 1 + OC3PE preload), `CCER2`=CC3E (saída CH3 no PC3),
  `BKR`=MOE (**obrigatório** — timer avançado), `CR1`=ARPE|CEN.
  Duty: `CCR3/(ARR+1)`; `Fan_SetDuty(100)` usa CCR=ARR+1 → 100% real.

---

## 6. Como compilar e gravar

### Compilar (fluxo normal)

1. Abrir o workspace `LCD16x2_I2C.stw` no ST Visual Develop.
2. O projeto `lcd16x2_i2c` já contém o `main.c` novo — nada a configurar.
3. `Project → Build` (F7). Valido nas configs **Debug** e **Release**.
4. Gravar com ST-Link via SWIM (pino 18/PD1): `Debug → Start Debugging` /
   "Program current target" — o `.s19` fica em `Debug\` ou `Release\`.

### Verificação por linha de comando (mesma usada na validação)

```bash
cd "C:/Users/alien/Desktop/microcontroladores/trabalho_microcontroladores/trabalho_microcontroladores"
CX="/c/Program Files (x86)/COSMIC/FSE_Compilers/CXSTM8/cxstm8.exe"
"$CX" +mods0 -no -l -dSTM8S103 "-iststdperlib/inc" -clbuild_test -cobuild_test main.c
```

(No Git Bash usar `/` no include path; o STVD usa `\` — funciona igual.)

**Nota:** o projeto STVD está configurado com device `STM8S103F3P` e compila
com `-dSTM8S103`, embora o chip seja STM8S003F3P6. Os registradores de
GPIO/ADC1/TIM1/I²C/CLK usados são **idênticos** nos dois chips — mantido
assim de propósito para não mexer no workflow; vale padronizar no relatório.

---

## 7. Plano de testes na bancada (etapa pendente)

| # | Teste | Procedimento | Resultado esperado |
|---|---|---|---|
| 1 | ADC/LM35 | Multímetro no pino TEMP (ambiente ~25 °C) | ~250 mV; LCD `Temp:` coerente ±2 °C |
| 2 | Calibração VREF | Medir o 5 V real da fonte | ajustar `VREF_MV` se ≠ 5,00 V |
| 3 | PWM frio | Osciloscópio/multímetro no gate do 2N7000 | 0 V (ventoinha parada), LCD `Fan: OFF` |
| 4 | PWM quente | Aquecer o LM35 (dedo/secador) | duty sobe na rampa 35→100%; `Fan: NN% AUTO` |
| 5 | Botão | Pressionar `Max_Cooler` | 100% e `MAX` no LCD; ao soltar volta ao AUTO |
| 6 | Histerese | Esfriar devagar | desliga em ~28 °C sem liga/desliga rápido |
| 7 | Falha do sensor | Desconectar o LM35 | `Falha no sensor!`, ventoinha 100%, LED piscando; reconecta → volta ao normal |
| 8 | LED | Durante os testes | fixo aceso em operação normal |
| 9 | Integrado | Ciclo completo de aquecimento/resfriamento | rampa suave, sem oscilação, LCD coerente |

**Instrumentos úteis:** multímetro (TEMP, VDD, gate), osciloscópio (forma de
onda do PWM no gate e no dreno), se possível termômetro de referência para
calibrar a leitura.

---

## 8. O que está validado × o que falta (honestidade técnica)

**Validado por análise/compilação (13/10/2026):**
- Pinagem contra datasheet (PD2=AIN3, PC3=TIM1_CH3, etc.);
- Compilação+link reais com CXSTM8/clnk nas duas configs, sem warnings;
- Orçamento de flash dentro do limite com folga;
- Lógica de controle revisada (histerese, rampa, clamps, sem divisão por
  zero, sem float, prioridade do botão).

**NÃO validado (requer bancada):**
- Comportamento elétrico real (ventoinha gira em 35%? 2N7000 aquece?);
- Se o LED está fisicamente em PD4 ou PD5 (ver §2, teste 1º);
- Precisão da temperatura (depende do VDD real → `VREF_MV`);
- Símbolo de grau 0xDF no LCD usado (se sair estranho, trocar por espaço);
- Endereço I²C 0x27 do backpack real;
- Faixas térmicas 28–50 °C adequadas ao sistema do grupo.

---

## 9. Histórico da sessão (o que a IA fez em 13/10/2026)

1. Analisou `Contexto_Projeto_Microcontroladores.md` e o
   `Esquemático Microcontroladores.pdf` (renderizado em imagem e lido).
2. Localizou o projeto STVD antigo em
   `trabalho_microcontroladores\trabalho_microcontroladores\`
   (base: demo de contador do LCD da aula 07) — **código antigo descartado**,
   arquivos de configuração do editor preservados.
3. Validou a pinagem com fontes externas (KiCad oficial + sduino + ST).
4. Reescreveu `main.c` (único arquivo modificado; `.stp` e `stm8s_conf.h`
   chegaram a ser editados para testar a via SPL e foram **revertidos ao
   estado original** após o estouro de flash — ver §5).
5. Compilou/linkou com o compilador real do projeto e mediu os tamanhos.
6. Escreveu este README e uma memória de projeto (persistente para a IA).

## 10. Fontes

- sduino (núcleo Arduino p/ STM8S, pinagem validada em hardware):
  https://github.com/tenbaht/sduino — arquivo `variants/standard/pins_arduino.h`
- Biblioteca oficial de símbolos KiCad (STM8S003F3):
  https://github.com/KiCad/kicad-symbols → `MCU_ST_STM8.lib`
- STMicroelectronics STM8S003F3 (datasheet):
  https://www.st.com/en/microcontrollers-microprocessors/stm8s003f3.html
- Documentação de referência STM8S: RM0016 (ADC1, TIM1, GPIO)
- Datasheet LM35 (TI): 10 mV/°C, faixa 2–150 °C com alimentação simples
