# MODELAGEM — Aulas de R

Repositório da disciplina **Modelagem**, organizado para reunir os
scripts, dados e resultados usados nas aulas práticas de R.

O estilo dos scripts (comentários com `#!`, `#?`, `#*`, `#TODO`, uso de
`tidyverse`/`dplyr`/`ggplot2`, progressão fundamentos → regex/joins →
gráficos) segue o mesmo formato usado no material de referência da
disciplina FCM2026:
https://github.com/profthomasvilches/FCM2026/tree/main/Aulas_R

## Estrutura do repositório

```
MODELAGEM/
├── dados/                                     # bases de dados usadas nas aulas
│   ├── results.csv                            # ~49.500 partidas de selecoes (1872-2026)
│   └── goalscorers.csv                        # ~47.900 gols individuais, com autor e minuto
├── scripts/
│   ├── aula1_futebol_fundamentos.R            # vetores, importacao, dplyr basico (select, filter, mutate, summarise, group_by, rowwise)
│   └── aula2_futebol_regex_joins_graficos.R   # regex, joins (left/right/inner/full) e 7 graficos com ggplot2
└── outputs/                                   # graficos gerados pelo script da aula 2 (.png)
```

## Sobre os dados

Os dados são o dataset público **"International football results from
1872 to 2026"**, compilado por Mart Jürisoo e disponível em:
https://github.com/martj42/international_results

Principais colunas de `results.csv`:

| Coluna       | Descrição                                   |
|--------------|----------------------------------------------|
| `date`       | Data da partida                               |
| `home_team`  | Seleção mandante                              |
| `away_team`  | Seleção visitante                             |
| `home_score` | Gols do mandante                              |
| `away_score` | Gols do visitante                             |
| `tournament` | Competição (amistoso, Copa do Mundo, etc.)    |
| `city`, `country` | Local da partida                        |
| `neutral`    | `TRUE` se a partida foi em campo neutro       |

`goalscorers.csv` traz um gol por linha (partida, autor do gol, minuto,
se foi gol contra ou pênalti), usado na Aula 2 para descobrir os
maiores artilheiros de Copas do Mundo via `left_join`.

> Como em qualquer base pública, há limitações (ex.: registro de
> artilheiros mais incompleto em partidas muito antigas) — isso é
> mencionado diretamente nos comentários do script, como boa prática
> de análise de dados.

## Como executar

1. Abra o RStudio e defina a raiz deste repositório como diretório de
   trabalho (ou crie um `.Rproj` aqui).
2. Instale o `tidyverse`, se ainda não tiver:
   ```r
   install.packages("tidyverse")
   ```
3. Abra `scripts/aula1_futebol_fundamentos.R` e rode linha a linha
   (Ctrl+Enter). **Atenção**: a aula 1 contém, de propósito, uma linha
   que gera erro (para ensinar por que `rowwise()` é necessário) — não
   use "Run All" nela, ela foi feita para ser executada em pedaços.
4. Rode `scripts/aula2_futebol_regex_joins_graficos.R` — este pode ser
   executado por inteiro (`source()` ou "Run All"); os 7 gráficos serão
   salvos automaticamente em `outputs/`.

## Aulas

- **Aula 1 — Fundamentos**: vetores, leitura de dados (`read.csv`),
  seleção/filtro/resumo com `dplyr` (`select`, `pull`, `filter`,
  `mutate`, `summarise`, pipe `%>%`), `group_by`, e o motivo de existir
  `rowwise()`.
- **Aula 2 — Regex, joins e gráficos**: expressões regulares aplicadas
  a nomes de seleções que mudaram ao longo da história (Alemanha,
  Coreia, Iugoslávia, Tchecoslováquia), os quatro tipos de `join`, o
  cuidado com relações N:N, e 7 gráficos variados com `ggplot2`
  (histograma, dispersão, boxplot, gráfico em camadas, barras de erro,
  barras e linha de tendência).
