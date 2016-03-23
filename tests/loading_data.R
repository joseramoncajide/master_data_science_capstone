# Loading data
library('data.table')
library('dplyr')
data <- fread('data/datos_encriptados.csv')
head(data)
data %>% group_by(OP_ADQUIRENTE) %>% summarise(mean(IMPORTE))
