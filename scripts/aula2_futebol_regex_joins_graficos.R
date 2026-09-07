# ==================================================================
# Disciplina: Modelagem
# Aula 2 - Expressoes regulares (regex), joins e graficos com ggplot2
# Tema: Resultados de partidas internacionais de futebol (1872-2026)
#
# Fonte dos dados:
# - results.csv / goalscorers.csv : Mart Jurisoo, "International
#   football results from 1872 to 2026"
#   https://github.com/martj42/international_results
# ==================================================================

library(tidyverse)

# ! Aqui usamos read_csv() (pacote readr, parte do tidyverse) em vez do
# ! read.csv() da Aula 1. Motivo: nomes de torneios como "Copa America"
# ! tem acento, e read_csv() garante a leitura correta como UTF-8 em
# ! qualquer sistema operacional. read.csv() depende da configuracao
# ! regional (locale) do computador e pode gerar caracteres corrompidos.

dados <- read_csv("./dados/results.csv", show_col_types = FALSE)
dados


# ------------------------------------------------------------
#* REGular EXpressions
#* REGEX
# ------------------------------------------------------------

grepl("Korea", "South Korea")
grepl("Korea", "Brazil")
grepl("Korea", c("South Korea", "Brazil")) %>% any()

grep("Korea", c("South Korea", "Brazil", "North Korea"))

#? Um dos usos mais uteis de regex em bases historicas de futebol e
#? encontrar selecoes que mudaram de nome ao longo do tempo.

selecoes <- unique(c(dados$home_team, dados$away_team))
length(selecoes)   #? quantas selecoes/times distintos existem na base

grep("German", selecoes, value = TRUE)        #? "Germany" e "German DR" (Alemanha Oriental)
grep("Korea", selecoes, value = TRUE)         #? Coreia do Sul e do Norte
grep("Yugoslavia|Serbia", selecoes, value = TRUE)
grep("Czech", selecoes, value = TRUE)         #? Tchecoslovaquia e Republica Tcheca

#* Esses casos existem porque paises se dividiram, se uniram ou mudaram
#* de nome (Alemanha, ex-Iugoslavia, ex-Tchecoslovaquia, ex-URSS...).
#* Se uma analise quiser tratar "Germany" e "German DR" como a mesma
#* entrada (decisao de modelagem que depende do objetivo do estudo!),
#* regex + gsub() e a ferramenta natural para isso:

dados %>%
  mutate(
    home_team_agrupado = gsub("German DR", "Germany", home_team)
  ) %>%
  filter(grepl("German", home_team)) %>%
  select(home_team, home_team_agrupado) %>%
  distinct()

#? Regex tambem serve para VALIDAR um padrao esperado em uma coluna.
#? Todas as datas deveriam seguir o formato AAAA-MM-DD:

dados$date[1:5]
all(grepl("^\\d{4}-\\d{2}-\\d{2}$", dados$date))   #? TRUE = nenhuma data fora do padrao

#? filtrando partidas de competicoes que comecam com "Copa"
dados %>%
  filter(grepl("^Copa", tournament)) %>%
  distinct(tournament)

#? filtrando qualquer coisa relacionada a "World Cup" (mas nao as eliminatorias)
dados %>%
  filter(grepl("World Cup", tournament) & !grepl("qualification", tournament)) %>%
  distinct(tournament)


# ------------------------------------------------------------
#? JOIN
# ------------------------------------------------------------

dados <- read_csv("./dados/results.csv", show_col_types = FALSE) %>%
  mutate(gols_totais = home_score + away_score)

dados %>% head()

#? Resumo: media de gols totais por torneio
resumo_torneio <- dados %>%
  group_by(tournament) %>%
  summarise(media_gols = mean(gols_totais)) %>%
  rename(
    torneio = tournament
  )


left_join(
  dados, resumo_torneio,
  by = c("tournament" = "torneio")
) %>% head()


#* left_join
# vai manter todas as partidas de "dados" (o que estiver a esquerda)

resumo_torneio <- dados %>%
  group_by(tournament) %>%
  summarise(media_gols = mean(gols_totais)) %>%
  filter(tournament != "Friendly") %>%
  rename(
    torneio = tournament
  )

#? repare que, para as partidas amistosas ("Friendly"), a coluna
#? media_gols volta como NA, pois essa linha nao existe mais em resumo_torneio
left_join(
  dados, resumo_torneio,
  by = c("tournament" = "torneio")
) %>%
  filter(tournament == "Friendly") %>%
  head()

#* right_join

resumo_torneio <- dados %>%
  group_by(tournament) %>%
  summarise(media_gols = mean(gols_totais)) %>%
  mutate(
    tournament = ifelse(tournament == "Friendly", "PIANCATELLI", tournament)
  ) %>%
  rename(
    torneio = tournament
  )

right_join(
  dados, resumo_torneio,
  by = c("tournament" = "torneio")
) %>% tail()

#* inner_join
# mantem so o que e comum aos dois lados

inner_join(
  dados, resumo_torneio,
  by = c("tournament" = "torneio")
) %>% head()

#* full_join
# mantem tudo dos dois lados, preenchendo com NA quando nao ha correspondencia

full_join(
  dados, resumo_torneio,
  by = c("tournament" = "torneio")
) %>% tail()


# --------------
#! Tomar cuidado com as relacoes N:N!
#! Por padrao, o R multiplica linhas quando ha mais de uma
#! combinacao possivel para a mesma chave

resumo_torneio <- dados %>%
  group_by(tournament) %>%
  summarise(media_gols = mean(gols_totais)) %>%
  mutate(
    tournament = ifelse(tournament == "Friendly", "FIFA World Cup", tournament)
  ) %>%
  rename(
    torneio = tournament
  )

#? agora existem DUAS linhas de resumo_torneio com torneio == "FIFA World Cup"
#? (a original e a que era "Friendly"). Isso duplica as partidas de Copa!
nrow(dados %>% filter(tournament == "FIFA World Cup"))
nrow(
  left_join(dados, resumo_torneio, by = c("tournament" = "torneio")) %>%
    filter(tournament == "FIFA World Cup")
)

#? o argumento relationship = "many-to-one" faz o dplyr AVISAR/travar
#? quando a relacao nao e a esperada, evitando esse tipo de erro silencioso
resumo_torneio_correto <- dados %>%
  group_by(tournament) %>%
  summarise(media_gols = mean(gols_totais)) %>%
  rename(torneio = tournament)

left_join(
  dados, resumo_torneio_correto,
  by = c("tournament" = "torneio"),
  relationship = "many-to-one"
) %>% head(10)


# -----------
#? bind_rows

bind_rows(dados, dados) %>% nrow()

df1 <- dados %>% slice(1:10) %>% select(-away_score)
df2 <- dados %>% slice(11:20) %>% select(-home_score)

bind_rows(df1, df2)   #? colunas que nao existem em um dos data frames viram NA


# ------------------------------------------------------------
#* Aplicacao pratica de JOIN: quem fez mais gols em Copas do Mundo?
# ------------------------------------------------------------

golscorers <- read_csv("./dados/goalscorers.csv", show_col_types = FALSE)
golscorers %>% head()

#? goalscorers.csv tem um gol por linha, mas nao tem a coluna "tournament".
#? Vamos buscar essa informacao em "dados", usando tres colunas como chave
#? (date, home_team e away_team identificam a partida)

gols_com_torneio <- golscorers %>%
  left_join(
    dados %>% select(date, home_team, away_team, tournament),
    by = c("date", "home_team", "away_team"),
    relationship = "many-to-one"
  )

artilheiros_copa <- gols_com_torneio %>%
  filter(tournament == "FIFA World Cup", !is.na(scorer), own_goal == FALSE) %>%
  count(scorer, sort = TRUE, name = "gols") %>%
  slice(1:10)

artilheiros_copa

#* Atencao: o registro de artilheiros em partidas muito antigas pode ser
#* incompleto na fonte original - todo dataset tem limitacoes, e dizer
#* isso em voz alta faz parte do trabalho de quem faz analise de dados.


# ==================================================================
#? GGPLOT2 - graficos variados
# ==================================================================

dados <- read_csv("./dados/results.csv", show_col_types = FALSE) %>%
  mutate(
    data_partida = as.Date(date),
    ano          = year(data_partida),
    decada       = (ano %/% 10) * 10,
    gols_totais  = home_score + away_score,
    saldo        = home_score - away_score,
    resultado    = case_when(
      home_score > away_score ~ "Vitoria mandante",
      home_score < away_score ~ "Vitoria visitante",
      TRUE                    ~ "Empate"
    )
  )

# --------------------------------------------------
# Grafico 1 - Histograma: distribuicao do total de gols por partida
# --------------------------------------------------

ggplot(dados, aes(x = gols_totais)) +
  geom_histogram(binwidth = 1, fill = "#2c7fb8", color = "black") +
  labs(
    x = "Total de gols na partida (mandante + visitante)",
    y = "Numero de partidas",
    title = "Distribuicao do total de gols por partida (1872-2026)"
  ) +
  theme_bw() +
  theme(
    axis.title = element_text(size = 14, face = "bold"),
    axis.text  = element_text(size = 12, face = "plain"),
    plot.title = element_text(size = 14, face = "bold")
  )

ggsave("./outputs/01_histograma_gols_totais.png", width = 6, height = 4)


# --------------------------------------------------
# Grafico 2 - Dispersao: gols do mandante x gols do visitante
# --------------------------------------------------

ggplot(dados, aes(x = home_score, y = away_score, color = neutral)) +
  geom_jitter(alpha = 0.15, width = 0.2, height = 0.2) +
  labs(
    x = "Gols do mandante",
    y = "Gols do visitante",
    color = "Campo neutro?",
    title = "Placar do mandante vs. placar do visitante"
  ) +
  guides(color = guide_legend(override.aes = list(alpha = 1, size = 3))) +
  theme_bw() +
  theme(
    axis.title = element_text(size = 14, face = "bold"),
    axis.text  = element_text(size = 12, face = "plain")
  )

ggsave("./outputs/02_dispersao_placar.png", width = 6, height = 4)


# --------------------------------------------------
# Grafico 3 - Boxplot + jitter: gols totais nos principais torneios
# --------------------------------------------------

top_torneios <- dados %>%
  count(tournament, sort = TRUE) %>%
  slice(1:8) %>%
  pull(tournament)

dados %>%
  filter(tournament %in% top_torneios) %>%
  ggplot(aes(x = tournament, y = gols_totais, color = tournament)) +
  geom_jitter(alpha = 0.25) +
  geom_boxplot(color = "black", alpha = 0.0, outlier.shape = NA) +
  labs(
    x = NULL, y = "Total de gols na partida",
    title = "Gols totais nos 8 torneios com mais partidas"
  ) +
  theme_bw() +
  theme(
    axis.title   = element_text(size = 14, face = "bold"),
    axis.text.y  = element_text(size = 12, face = "plain"),
    axis.text.x  = element_text(angle = 90, vjust = 0.5, hjust = 1.0, size = 10),
    legend.position = "none"
  )

ggsave("./outputs/03_boxplot_torneios.png", width = 7, height = 5)


# --------------------------------------------------
# Grafico 4 - Camadas: dispersao classificada por categoria de placar
# --------------------------------------------------

dados %>%
  mutate(
    categoria_gols = case_when(
      gols_totais <= 1 ~ "Poucos gols (0-1)",
      gols_totais <= 3 ~ "Gols normais (2-3)",
      gols_totais <= 5 ~ "Muitos gols (4-5)",
      TRUE             ~ "Goleada (6+)"
    )
  ) %>%
  arrange(gols_totais) %>%
  ggplot(aes(x = home_score, y = away_score, color = categoria_gols)) +
  geom_jitter(alpha = 0.3, width = 0.2, height = 0.2) +
  labs(x = "Gols do mandante", y = "Gols do visitante", color = "Categoria") +
  theme_bw() +
  theme(
    axis.title = element_text(size = 14, face = "bold"),
    axis.text  = element_text(size = 12, face = "plain")
  )

ggsave("./outputs/04_dispersao_categorias.png", width = 6, height = 4)


# --------------------------------------------------
# Grafico 5 - Media +/- desvio padrao de gols totais por decada
# --------------------------------------------------

resumo_decada <- dados %>%
  filter(decada >= 1900, decada <= 2020) %>%
  group_by(decada) %>%
  summarise(
    media_gols = mean(gols_totais),
    sd_gols    = sd(gols_totais),
    n          = n()
  )

resumo_decada

ggplot(resumo_decada, aes(x = decada, y = media_gols)) +
  geom_line(color = "grey40") +
  geom_point(size = 2, color = "#d95f02") +
  geom_errorbar(
    aes(ymin = media_gols - sd_gols, ymax = media_gols + sd_gols),
    width = 0, color = "#d95f02"
  ) +
  labs(
    x = "Decada", y = "Gols por partida\n(media e desvio padrao)",
    title = "Evolucao do numero de gols por partida ao longo do tempo"
  ) +
  scale_x_continuous(breaks = seq(1900, 2020, 10)) +
  theme_bw() +
  theme(
    axis.title = element_text(size = 13, face = "bold"),
    axis.text  = element_text(size = 11, face = "plain"),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

ggsave("./outputs/05_erro_padrao_por_decada.png", width = 7, height = 4.5)


# --------------------------------------------------
# Grafico 6 - Barras: selecoes com mais vitorias na base
# --------------------------------------------------

vitorias_casa <- dados %>%
  filter(resultado == "Vitoria mandante") %>%
  count(home_team, name = "vitorias") %>%
  rename(selecao = home_team)

vitorias_fora <- dados %>%
  filter(resultado == "Vitoria visitante") %>%
  count(away_team, name = "vitorias") %>%
  rename(selecao = away_team)

top10_vitorias <- bind_rows(vitorias_casa, vitorias_fora) %>%
  group_by(selecao) %>%
  summarise(vitorias = sum(vitorias)) %>%
  arrange(desc(vitorias)) %>%
  slice(1:10)

ggplot(top10_vitorias, aes(x = reorder(selecao, vitorias), y = vitorias)) +
  geom_col(fill = "#238b45") +
  coord_flip() +
  labs(
    x = NULL, y = "Numero de vitorias (mandante + visitante)",
    title = "10 selecoes com mais vitorias (1872-2026)"
  ) +
  theme_bw() +
  theme(
    axis.title = element_text(size = 13, face = "bold"),
    axis.text  = element_text(size = 12, face = "plain")
  )

ggsave("./outputs/06_barras_top_vitorias.png", width = 6, height = 4.5)


# --------------------------------------------------
# Grafico 7 - Linha: media de gols por partida, ano a ano
# --------------------------------------------------

media_por_ano <- dados %>%
  filter(ano <= 2025) %>%
  group_by(ano) %>%
  summarise(media_gols = mean(gols_totais))

ggplot(media_por_ano, aes(x = ano, y = media_gols)) +
  geom_line(color = "grey50") +
  geom_smooth(method = "loess", se = FALSE, color = "#7570b3") +
  labs(
    x = "Ano", y = "Media de gols por partida",
    title = "Tendencia historica de gols por partida (1872-2025)"
  ) +
  theme_bw() +
  theme(
    axis.title = element_text(size = 13, face = "bold"),
    axis.text  = element_text(size = 11, face = "plain")
  )

ggsave("./outputs/07_linha_media_gols_por_ano.png", width = 7, height = 4.5)

#* Fim da Aula 2. Como exercicio: repita o Grafico 6 usando apenas
#* partidas de "FIFA World Cup" e compare com o ranking geral.
