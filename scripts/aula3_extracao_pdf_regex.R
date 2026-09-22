# ==================================================================
# Disciplina: Modelagem
# Aula 3 - Extracao de dados de PDF com regex
# Tema: cadastro.pdf - fichas de cadastro em texto livre e sem padrao
#
# O PDF nao tem uma tabela: e so texto corrido, com rotulos que mudam
# de um registro para o outro ("Nome"/"nome", "Tel"/"Telefone",
# "Data de nascimento"/"Dt nasc"...). E exatamente esse tipo de bagunca
# que aparece quando se extrai dado de um documento real, e regex e a
# ferramenta certa pra arrumar isso.
# ==================================================================

#install.packages("pdftools")
library(tidyverse)
library(pdftools)


# ---------------------------------------------------
# Lendo o PDF
# ---------------------------------------------------

texto <- pdf_text("./dados/cadastro.pdf") %>% paste(collapse = "\n")

cat(texto)

#? O pdf_text() devolve o texto do jeito que ele aparece no PDF: tudo
#? junto, sem nenhuma estrutura de tabela. Precisamos separar cada
#? ficha de cadastro e depois separar os campos dentro de cada ficha.


# ---------------------------------------------------
#* Separando os registros
# ---------------------------------------------------

#* Cada ficha comeca com "Nome:" (ou "nome:", em minusculo, num dos
#* registros). Usamos isso como ponto de corte: o (?=...) e um
#* "lookahead" - ele acha o local sem "consumir" o texto, entao a
#* palavra "Nome:" fica no comeco de cada pedaco.

registros <- str_split(texto, "(?=(?i)nome:)")[[1]]
registros <- registros[trimws(registros) != ""]

length(registros)   #? 4 fichas


# ---------------------------------------------------
#? Extraindo os campos de cada registro
# ---------------------------------------------------

extrair_campo <- function(bloco, padrao){
  m <- str_match(bloco, padrao)
  if(is.na(m[1, 2])) return(NA_character_)
  trimws(m[1, 2])
}

#? (?i) no comeco do padrao = ignora maiuscula/minuscula
#? o "." por padrao nao "pula" quebra de linha, entao (.*) para
#? sozinho no fim da linha onde o campo foi escrito

extrair_campo(registros[1], "(?i)nome:\\s*(.*)")
extrair_campo(registros[2], "(?i)(?:data de nascimento|dt\\.?\\s*nasc)\\s*:\\s*(.*)")

#* No registro do Gandalf, o CEP esta na MESMA linha do endereco
#* ("...Terra media CEP: 88837-000"). Por isso tiramos o pedaco
#* "CEP: ..." de dentro do endereco depois de extrair.

extrair_campo(registros[2], "(?i)endere[cç]o:\\s*(.*)")


# ---------------------------------------------------
#* Montando a tabela
# ---------------------------------------------------

so_digitos <- function(x) gsub("[^0-9]", "", x)

formatar_cpf <- function(digitos){
  ifelse(
    nchar(digitos) == 11,
    sprintf("%s.%s.%s-%s", substr(digitos,1,3), substr(digitos,4,6), substr(digitos,7,9), substr(digitos,10,11)),
    NA_character_
  )
}

formatar_telefone <- function(digitos){
  case_when(
    nchar(digitos) == 11 ~ sprintf("(%s) %s-%s", substr(digitos,1,2), substr(digitos,3,7), substr(digitos,8,11)),
    nchar(digitos) == 10 ~ sprintf("(%s) %s-%s", substr(digitos,1,2), substr(digitos,3,6), substr(digitos,7,10)),
    TRUE ~ NA_character_
  )
}

cadastro <- map_dfr(registros, function(bloco){
  nome_bruto <- extrair_campo(bloco, "(?i)nome:\\s*(.*)")
  tibble(
    nome            = str_remove(nome_bruto, "\\s*\\(aka[^)]*\\)"),
    apelido         = extrair_campo(bloco, "\\(aka ([^)]+)\\)"),
    data_nascimento = extrair_campo(bloco, "(?i)(?:data de nascimento|dt\\.?\\s*nasc)\\s*:\\s*(.*)"),
    endereco        = str_remove(extrair_campo(bloco, "(?i)endere[cç]o:\\s*(.*)"), "(?i)\\s*cep:.*$"),
    cep             = extrair_campo(bloco, "(?i)cep:\\s*([0-9.\\-]+)"),
    telefone        = extrair_campo(bloco, "(?i)tel(?:efone)?:\\s*([0-9()\\s-]+)"),
    cpf             = extrair_campo(bloco, "(?i)cpf:\\s*([0-9.\\-]+)")
  )
}) %>%
  mutate(
    cpf_digitos         = so_digitos(cpf),
    cpf_formatado       = formatar_cpf(cpf_digitos),
    cpf_valido          = nchar(cpf_digitos) == 11,
    telefone_digitos    = so_digitos(telefone),
    telefone_formatado  = formatar_telefone(telefone_digitos),
    cep_valido          = grepl("^\\d{5}-\\d{3}$", cep),
    dia_nascimento      = str_extract(data_nascimento, "^\\d{1,2}")
  )

glimpse(cadastro)

#* Sobre "dia_nascimento": as datas estao em formatos e ate calendarios
#* diferentes ("281d.C", "10.175d.G.", "12/dec/1217"...). Nao da pra
#* converter isso pra uma data real do R sem inventar regra - mas o
#* DIA sempre vem primeiro, entao pelo menos essa parte da pra extrair
#* com seguranca. Tentar arrancar mais do que isso viraria suposicao,
#* nao extracao.


# ---------------------------------------------------
#? Consultas de teste
# ---------------------------------------------------

#? 1. nome, apelido e CPF ja formatado
cadastro %>% select(nome, apelido, cpf_formatado)

#? 2. registros com CEP fora do padrao brasileiro (99999-999)
cadastro %>% filter(!cep_valido) %>% select(nome, cep)

#? 3. enderecos "sem numero" (regex \\b ancora a palavra inteira,
#?    pra nao pegar "SN" dentro de outra palavra por acaso)
cadastro %>% filter(grepl("\\bSN\\b", endereco)) %>% select(nome, endereco)

#? 4. ordem alfabetica pelo nome
cadastro %>% arrange(nome) %>% select(nome)

#* 5. CPFs duplicados depois de normalizar - sem tirar pontuacao,
#* "000.321.333-90" e "00032133390" parecem diferentes. Comparando
#* so os digitos, sao o MESMO CPF (Gandalf e Paul Atreides!).
cadastro %>%
  count(cpf_digitos, name = "vezes") %>%
  filter(vezes > 1)

cadastro %>%
  filter(cpf_digitos %in% (cadastro %>% count(cpf_digitos) %>% filter(n > 1) %>% pull(cpf_digitos))) %>%
  select(nome, cpf, cpf_digitos)

#? 6. resumo geral
cadastro %>% summarise(
  registros    = n(),
  cpfs_validos = sum(cpf_valido),
  ceps_validos = sum(cep_valido)
)
