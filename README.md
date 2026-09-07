# MODELAGEM — Aulas de R

Material da disciplina Modelagem: dados, scripts e gráficos das aulas
práticas de R sobre futebol internacional.

Os scripts seguem o formato usado no material da disciplina FCM2026
(https://github.com/profthomasvilches/FCM2026/tree/main/Aulas_R) —
comentários marcados com `#!`, `#?`, `#*`, progressão de fundamentos
para regex, joins e gráficos.

## Estrutura

```
dados/       results.csv e goalscorers.csv
scripts/     aula1_futebol_fundamentos.R e aula2_futebol_regex_joins_graficos.R
outputs/     graficos gerados pela aula 2
```

## Dados

Os dois arquivos em `dados/` vêm do dataset público "International
football results from 1872 to 2026", de Mart Jürisoo
(https://github.com/martj42/international_results). `results.csv` traz
cerca de 49.500 partidas de seleções, com data, mandante, visitante,
placar, competição e se o jogo foi em campo neutro; `goalscorers.csv`
traz um gol por linha, usado na aula 2 para levantar os artilheiros de
Copa do Mundo. O registro de artilheiros costuma ser mais incompleto
nas partidas mais antigas.

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
