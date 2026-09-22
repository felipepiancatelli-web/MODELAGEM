# MODELAGEM — Aulas de R

Material da disciplina Modelagem: dados, scripts e gráficos das aulas
práticas de R sobre futebol internacional.

Os scripts seguem o formato usado no material da disciplina FCM2026
(https://github.com/profthomasvilches/FCM2026/tree/main/Aulas_R) —
comentários marcados com `#!`, `#?`, `#*`, progressão de fundamentos
para regex, joins e gráficos.

## Estrutura

```
dados/       results.csv, goalscorers.csv e cadastro.pdf
scripts/     aula1_futebol_fundamentos.R, aula2_futebol_regex_joins_graficos.R e aula3_extracao_pdf_regex.R
outputs/     graficos gerados pela aula 2
```

## Dados

`results.csv` e `goalscorers.csv` vêm do dataset público "International
football results from 1872 to 2026", de Mart Jürisoo
(https://github.com/martj42/international_results). O primeiro traz
cerca de 49.500 partidas de seleções, com data, mandante, visitante,
placar, competição e se o jogo foi em campo neutro; o segundo traz um
gol por linha, usado na aula 2 para levantar os artilheiros de Copa do
Mundo. O registro de artilheiros costuma ser mais incompleto nas
partidas mais antigas.

`cadastro.pdf`, usado na aula 3, é uma ficha fictícia com quatro
registros (nomes de personagens), digitada de propósito sem padrão
fixo de rótulos ou formatação — a bagunça é o material da aula.

## Aula 1 — Fundamentos

Vetores, importação de dados, dplyr básico (select, filter, mutate,
summarise, group_by) e o motivo de existir o rowwise(). Uma das linhas
gera erro de propósito, para mostrar por que mutate() sozinho falha ao
aplicar uma função com if() sobre uma coluna inteira — por isso essa
aula não deve ser rodada de uma vez (Run All), e sim linha a linha.

## Aula 2 — Regex, joins e gráficos

Expressões regulares em nomes de seleções que mudaram ao longo da
história (Alemanha e German DR, Coreia do Sul e do Norte, Iugoslávia e
Sérvia, Tchecoslováquia e República Tcheca), os quatro tipos de join e
sete gráficos com ggplot2: histograma, dispersão, boxplot, dispersão em
camadas, barras de erro por década, barras com as seleções de mais
vitórias e linha de tendência histórica de gols por partida.

## Aula 3 — Extração de PDF com regex

Leitura de um PDF em texto livre (`pdf_text()`, do pacote pdftools),
separação dos registros por lookahead antes de "Nome:"/"nome:" e
extração de campos com rótulos inconsistentes ("Tel" ou "Telefone",
"Data de nascimento" ou "Dt nasc"). A partir daí: normalização de CPF
e telefone para só dígitos, validação de CEP e CPF por regex, extração
do dia de nascimento (o único pedaço da data que é confiável em meio a
calendários fictícios) e a descoberta de que dois registros têm o
mesmo CPF escrito com pontuação diferente — o tipo de duplicata que só
aparece depois de normalizar o dado.
