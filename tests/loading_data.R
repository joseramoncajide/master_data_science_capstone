# Loading data

list.of.packages <- c("data.table", 
                      "dplyr",
                      "doParallel",
                      "ggplot2",
                      "zoo")

new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

# load packages
lapply(list.of.packages, library, character.only = T)

# library('data.table', quietly = TRUE)
# library('dplyr', quietly = TRUE)
# library('ggplot2', quietly = TRUE)
# library('doParallel', quietly = TRUE)                    
registerDoParallel(detectCores() - 1 )  ## registerDoMC( detectCores()-1 ) in Linux

options(rf.cores = detectCores() - 1, 
        mc.cores = detectCores() - 1)  ## Cores for parallel processing

file <- 'data/datos_encriptados.csv'

if (file.exists(file))
print(paste(round(file.info(file)$size  / 2^30, 4), 'gigabytes'))


readLines(file, n=2, skipNul = T)

DT <- fread(file, encoding='Latin-1')
sapply(DT,class)
tables()

str(DT)


# Conversión de fechas

DT$MES <- as.Date(as.yearmon(DT$MES, "%Y%m"))
summary(DT)

# Operaciones por mes
barplot(table(DT$MES))

# chr to Factor
tofactor <- c('DES_TIPO_EMISOR', 'ACTIVIDAD', 'DES_ACTIVIDAD','DES_PROVINCIA','DES_ESTABLECIMIENTO','DES_ENTORNO','DES_CLASE_OPERACION', 'DES_TIPO_ADQUIRENTE')
DT[,(tofactor):=lapply(.SD, as.factor),.SDcols=tofactor]

# ######### Provincias

# Convert factor with 'NO EXISTE LA PROVINCIA' to NA
levels(DT$DES_PROVINCIA)
levels(DT$DES_PROVINCIA)[levels(DT$DES_PROVINCIA)=='NO EXISTE LA PROVINCIA'] <- NA
sum(is.na(DT$DES_PROVINCIA))
# Porcentaja de observaciones sin provincia
sum(is.na(DT$DES_PROVINCIA))/nrow(DT)*100
# Número de observaciones por provincia
DT[, (.N), by = DES_PROVINCIA] %>% ggplot(aes(x = DES_PROVINCIA, y = N)) + geom_bar(stat="identity") + coord_flip()

# Número de observaciones por provincia y emisor en el que el emisor no es EURO 6000
DT[DES_TIPO_EMISOR != 'EURO 6000', .N, by = .(DES_PROVINCIA, DES_TIPO_EMISOR)] %>% ggplot(aes(x = DES_PROVINCIA, y = N, fill = DES_TIPO_EMISOR)) + geom_bar(stat="identity") + coord_flip()

# ######### DES_ACTIVIDAD
levels(DT$DES_ACTIVIDAD)
# Top 20 observaciones por DES_ACTIVIDAD
head(DT[, .N, by = DES_ACTIVIDAD], 20) %>% ggplot(aes(x = DES_ACTIVIDAD, y = N)) + geom_bar(stat="identity") + coord_flip()


setkey(DT,OP_ADQUIRENTE)

length(unique(DT$OP_ADQUIRENTE))

DT[,sum(IMPORTE),by=OP_ADQUIRENTE]
DT[,.SD[which.min(IMPORTE)],by=OP_ADQUIRENTE][]

# Importe medio por adquiriente
DT[,mean(na.omit(IMPORTE)), by=.(OP_ADQUIRENTE)] %>% ggplot(aes(x = OP_ADQUIRENTE, y = V1)) + geom_bar(stat="identity") + coord_flip()

# Importe medio por mes y adquiriente

DT[,mean(na.omit(IMPORTE)), by=.(MES,OP_ADQUIRENTE)] %>% ggplot(aes(x = MES, y = V1)) + geom_bar(stat="identity", position=position_dodge()) + facet_wrap(~ OP_ADQUIRENTE) 




# Máximo importe por adquiriente
DT[,list(IMPORTE = sum(IMPORTE)),by=OP_ADQUIRENTE][which.max(IMPORTE),]
DT[,.SD,by=OP_ADQUIRENTE][which.max(IMPORTE),]

# Observaciones por adquiriente
DT[,.N,by=OP_ADQUIRENTE]

table(DT$OP_ADQUIRENTE)

# Obervaciones con mayores importes

DT.ag <- aggregate(IMPORTE ~ OP_ADQUIRENTE, DT, max)
DT.max <- merge(DT.ag, DT)
# system.time(merge(aggregate(IMPORTE ~ OP_ADQUIRENTE, DT, max), DT))

# data.table way
DT[,.SD[which.max(IMPORTE)], by=.(OP_ADQUIRENTE)]

DT.max
class(DT.max)


DT.ag <- DT[,.SD[which.max(IMPORTE)], by=.(OP_ADQUIRENTE)]
system.time(DT[,.SD[which.max(IMPORTE)], by=.(OP_ADQUIRENTE)])
DT[,max(na.omit(IMPORTE)), by=.(OP_ADQUIRENTE)]

head(data)
str(data)

data$DES_ACTIVIDAD <- as.factor(data$DES_ACTIVIDAD)
levels(data$DES_ACTIVIDAD)
count <- table(data$DES_ACTIVIDAD)





data[, .SD[which.max(IMPORTE)], by = DES_ACTIVIDAD]


data[,grp.ranks:=rank(-1*IMPORTE,ties.method='min'),by=DES_ACTIVIDAD]
data
data[grp.ranks==1,]

barplot(count,las=2, cex.names = .40, horiz=TRUE)
labs <- paste(names(count), "cylinders")
text(cex=1, x=x-.25, y=-1.25, labs, xpd=TRUE, srt=45, pos=2)

data %>% group_by(OP_ADQUIRENTE) %>% summarise(mean(IMPORTE))

