# ==================================================================
# Disciplina: Modelagem
# Aula 1 - Fundamentos de R e manipulacao de dados com dplyr
# Tema: Resultados de partidas internacionais de futebol (1872-2026)
#
# Fonte dos dados: Mart Jurisoo, "International football results
# from 1872 to 2026", disponivel em:
# https://github.com/martj42/international_results
# (dataset publico, tambem hospedado no Kaggle)
# ==================================================================

# ! Antes de comecar, garanta que o pacote tidyverse esta instalado
#install.packages("tidyverse")

library(tidyverse)


# ------------------------------
# Revisao rapida: vetores e operacoes basicas em R
# ------------------------------

a = 2
a
a = 3
a

a <- 2
a == 2
a/2


# vamos simular os gols de um time em 4 jogos
golsA  <- c(2, 0, 3, 1)
golsB  <- c(1, 1, 0, 1)

golsA - golsB      # saldo de gols, jogo a jogo
sum(golsA)         # total de gols marcados no periodo
mean(golsA)        # media de gols por jogo
sd(golsA)          # desvio padrao

hist(golsA)
plot(golsA)


# ---------------------------------------------------
# Importando os dados
# ---------------------------------------------------

dados <- read.csv("./dados/results.csv")
dados

glimpse(dados)
dplyr::glimpse(dados)

#? date       -> data da partida
#? home_team  -> selecao mandante
#? away_team  -> selecao visitante
#? home_score -> gols do mandante
#? away_score -> gols do visitante
#? tournament -> competicao (amistoso, copa do mundo, eliminatorias, etc)
#? neutral    -> a partida foi em campo neutro (TRUE/FALSE)?

dados$home_team

dados$home_score - dados$away_score

dados$gols_totais <- dados$home_score + dados$away_score

glimpse(dados)


#? Selecionar colunas usando DPLYR
select(dados, date, home_team, away_team, home_score, away_score)

teste1 <- select(dados, home_team)
teste1$home_team

#? PULL
teste2 <- pull(dados, home_team)
teste2

#? Filtrar dados
filter(dados, gols_totais > 8)

#? criar colunas
mutate(dados, saldo_gols = home_score - away_score)

#? resumir dados
summarise(dados, media_casa = mean(home_score), sd_casa = sd(home_score))

#* teste - calcular a media de gols do mandante e o desvio padrao
#* apenas para partidas de Copa do Mundo (FIFA World Cup)

df <- filter(dados, tournament == "FIFA World Cup")

#? resumir dados
summarise(df, media_casa = mean(home_score), sd_casa = sd(home_score))

#! PIPE %>% - dplyr, R Base |>

dados %>%
  filter(tournament == "FIFA World Cup") %>%
  summarise(media_casa = mean(home_score), sd_casa = sd(home_score))

#* criar mais de uma coluna ao mesmo tempo

dados %>%
  mutate(
    saldo_gols  = home_score - away_score,
    gols_totais = home_score + away_score
  ) %>%
  select(saldo_gols, gols_totais)


dados %>%
  pull(gols_totais) %>% max()

dados %>%
  select(gols_totais) %>% max()

dados %>%
  pull(gols_totais) |> max()


# -----------------
#? GROUP_BY

dados %>%
  group_by(tournament) %>%
  summarise(media_gols = mean(gols_totais), sd_gols = sd(gols_totais)) %>%
  arrange(desc(media_gols))


dados %>%
  group_by(tournament) %>%
  mutate(media_gols_torneio = mean(gols_totais)) %>%
  filter(gols_totais > media_gols_torneio) %>%
  select(-media_gols_torneio)


dados %>%
  group_by(home_team) %>%
  filter(home_score > mean(home_score))


#? rowwise

#? A funcao mutate e outras do pacote dplyr trabalham diretamente com as
#? colunas como se fossem operacoes de vetor

dados %>%
  mutate(
    placar = paste(home_score, "x", away_score)
  ) %>% head()

#? Na pratica, o dplyr faz isso:
paste(dados$home_score, "x", dados$away_score)

dados %>% pull(home_team) %>%
  paste("(mandante)")

#? o que significa que a funcao PRECISA aceitar um vetor inteiro de uma vez

#? Imagine que voce queira classificar cada partida como "Goleada" ou
#? "Jogo normal" de acordo com o total de gols marcados.

f <- function(gols){
  if(gols >= 5){        #? no caso, o limite escolhido foi 5 gols
    return("Goleada")
  } else {
    return("Jogo normal")
  }
}

f(6)   #? funciona normalmente para um unico valor (escalar)

x1 <- c(1, 6, 3, 8)
#! Nas versoes atuais do R (>= 4.3), usar um vetor com mais de um
#! elemento dentro de if() gera ERRO (em versoes antigas, gerava apenas
#! um aviso e o R usava somente o primeiro elemento do vetor).
#! A linha abaixo, portanto, PARA a execucao - rode-a sozinha (Ctrl+Enter)
#! para ver a mensagem de erro.
f(x1)

#! O codigo abaixo tambem NAO funciona, pelo mesmo motivo: o mutate
#! passa a coluna inteira (um vetor) de uma so vez para f()
dados %>%
  mutate(
    categoria = f(gols_totais)
  ) %>%
  select(gols_totais, categoria) %>% head(30)

#* O codigo abaixo funciona, pois o rowwise() faz o dplyr aplicar
#* a funcao f() uma linha (um escalar) de cada vez
#TODO
dados %>%
  rowwise() %>%
  mutate(
    categoria = f(gols_totais)
  ) %>%
  select(gols_totais, categoria) %>% head(30) %>%
  ungroup() %>%
  mutate(
    media_geral = mean(gols_totais)
  )

#? O codigo abaixo sai agrupado por linha (rowwise) ate o ungroup()

dados %>%
  rowwise() %>%
  mutate(
    categoria = f(gols_totais),
    media     = mean(gols_totais)
  ) %>%
  ungroup() %>%
  mutate(
    media_geral = mean(gols_totais)
  ) %>% head(30) %>%
  select(gols_totais, categoria, media, media_geral)

#* Na pratica, para este caso especifico, o jeito "tidyverse" mais correto
#* (e muito mais rapido, pois nao percorre linha a linha) seria usar
#* case_when() dentro de um mutate() normal - vamos ver isso na Aula 2.
