# This script can be run from the command line. Just type: Rscript data_preparation.R 

# Clean up
rm(list = ls()); gc();

# ----------------------------------------------------------------------------
# 										Environment Setup
# ----------------------------------------------------------------------------

# Install required packages if necessary
list.of.packages <- c("data.table","lubridate") 
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

# Load packages
lapply(list.of.packages, library, character.only = T)

rm(list = c('list.of.packages', 'new.packages'))

# ----------------------------------------------------------------------------
# 										Loading data
# ----------------------------------------------------------------------------

# Path to the data file
file <- file.path('data/datos.csv')

if (file.exists(file)) {
  cat('Reading', file)
  print(paste(round(file.info(file)$size  / 2^30, 4), 'gigabytes'))
  readLines(file, n=2, skipNul = T)
  DT <- fread(file, encoding='Latin-1', na.strings=c("","NA"))
  rm(file)
}

# ----------------------------------------------------------------------------
# 										Data manipulation
# ----------------------------------------------------------------------------

# Create a date field from ANO, MES and DIA
DT[,FECHA:=as.Date(paste(ANO, MES, DIA, sep="-" ), tz = "Europe/Madrid")]

# Convert char vars to factors
variables <- c('ANO','MES','DIA','OP_ADQUIRENTE','DES_TIPO_EMISOR','DES_PROVINCIA', 'DES_TIPO_ADQUIRENTE', 'DES_AMBITO', 'OP_COD_PAIS_COMERCIO','DES_MARCA','DES_GAMA','DES_PRODUCTO', 'TIPO_TARJETA', 'DES_CREDEB','DES_CLASE_OPERACION', 'DES_PAGO','DES_RESULTADO','PER_TIPO_PERS','PER_COD_PAIS_NAC', 'OF_COD_PAIS_RES','PER_ID_SEXO','PER_EST_CIVIL','PER_MARCA_EMP','PER_MARCA_FALL')
DT[,(variables):=lapply(.SD, as.factor),.SDcols=variables]
rm(variables)

# Convert char vars to numeric
variables <- c('NOPER','IMPOPER')
DT[,(variables):=lapply(.SD, as.numeric),.SDcols=variables]
rm(variables)

# Convert char vars to date
DT[,PER_FECHA_NAC:=as.Date(PER_FECHA_NAC, format = "%Y%m%d", tz = "Europe/Madrid")]
DT[,PER_FECHA_ALTA:=as.Date(PER_FECHA_ALTA, format = "%Y%m%d", tz = "Europe/Madrid")]

# Reorder columns
setcolorder(DT, c(ncol(DT), 1:(ncol(DT)-1)))

# Assign NA to variable DES_PROVINCIA with value eq 'NO EXISTE LA PROVINCIA'
levels(DT$DES_PROVINCIA)[levels(DT$DES_PROVINCIA)=='NO EXISTE LA PROVINCIA'] <- NA

# Assign readable names to hardcoded bank organizations
setkey(DT,OP_ADQUIRENTE)
op_adquiriente <- seq(from = 1000, to=length(unique(DT$OP_ADQUIRENTE))+999, by =1)
DT[,OP_ADQUIRENTE:=factor(OP_ADQUIRENTE,labels=op_adquiriente)]
adquiriente <- paste("Entidad", op_adquiriente)
DT[,ADQUIERENTE:=factor(ADQUIERENTE,labels=adquiriente)]

# Remove observations where PER_ID_PERSONA has not been provided and the transaction was nos succesful
DT <- DT[!is.na(PER_ID_PERSONA) & DES_RESULTADO == "OK"]

# The cleaned data frame is stores in a serialized R object for later usage
saveRDS(DT, file = "./data/DT.rds", compress = T)

# ----------------------------------------------------------------------------
# 										Feature creation
# ----------------------------------------------------------------------------

# Create the new variables
DT.c <- DT[, list(F1=median(na.omit(IMPOPER[which(DES_AMBITO == "On us")])),
                  F2=median(na.omit(IMPOPER[which(DES_AMBITO == "Inter-Sistemas")])),
                  F3=median(na.omit(IMPOPER[which(DES_AMBITO == "Intra-Sistema")]), na.rm = T),
                  F4=length(unique(.N[which(DES_AMBITO == "On us")])),
                  F5=length(unique(.N[which(DES_AMBITO == "Inter-Sistemas")])),
                  F6=length(unique(.N[which(DES_AMBITO == "Intra-Sistema")]))
),
by=.(PER_ID_PERSONA)]

# Remove rows with any posible NA value
DT.c[is.na(DT.c)] <- 0
head(DT.c)


setkey(DT.c, PER_ID_PERSONA)

# Save new data frame as R object
saveRDS(DT.c, file = "./data/DTc.rds", compress = T)

# ----------------------------------------------------------------------------
# 										Normalization
# ----------------------------------------------------------------------------

# Keek PER_ID_PERSONA as row names and remove the variable
DT.s <- as.data.frame(DT.c)
row.names(DT.s) <- DT.s$PER_ID_PERSONA
DT.s$PER_ID_PERSONA <- NULL

# Adjusting values measured on different scales to a notionally common scale
DT.s <- as.data.frame(scale(DT.s))

# Write a CSV file to disk with the scaled data frame that will be stored in Hadoop for later processing by Apache Spark
write.table(DT.s[complete.cases(DT.s),], file.path('data/scaled.csv'), row.names = T, col.names = FALSE, sep=",")

# ----------------------------------------------------------------------------
# 										Automatic data uploading
# ----------------------------------------------------------------------------

# cmd<-"tar -zcvf data_scaled.tar.gz data/data_scaled.csv"  
# system(cmd, wait=T)

# # Firt install 'sshpass' to provide your password (no recommended)
# yum -y install sshpass or apt-get install sshpass
# cmd<-"sshpass -p "password" scp -P 22010 data_scaled.tar.gz kschool06@cms.hadoop.flossystems.net:data_science/ data_scaled.tar.gz"
# system(cmd, wait=T)

