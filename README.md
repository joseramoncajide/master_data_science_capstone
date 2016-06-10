XXX project for the Kschool Master in Data Science
===================

Uso:

    dataDrivenModelReport(importPath, exportPath, archive = F, openreport = F)

Parámentros:

    importPath: directorio con los archivos csv que contienen las rutas de conversión de los usuarios
    exportPath: directorio de generación del informe en Excel
    archive: indicar T para archivar los csv procesados
    openreport: inficar T para arbrir el informe en Excel tras su generación

**Para generar el paquete:**
cd /Users/JOSE/Documents/git/eam_clientes/pccomponentes
R CMD build pccomponentes

Instalación
===================
Acceder a `run.R`


RUN ONCE (install requiered packages)

    list.of.packages <- c('ggplot2', 'ChannelAttribution', 'dplyr', 'reshape2', 'ggthemes', 'markovchain', 'RColorBrewer', 'xlsx')
    new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
    if(length(new.packages)) install.packages(new.packages)
    rm(list.of.packages)
    install.packages("../pccomponentes_0.1.0.tar.gz", repos = NULL, type="source", dependencies = T)


RUN 

    #`enter code here`detach("package:pccomponentes", unload=TRUE)
    library('pccomponentes', warn.conflicts = F)
    setwd("~/Documents/git/eam_clientes/pccomponentes/modelo_atribucion/")
    importPath<-'./data/raw/'
    exportPath<-'./data/'
    dataDrivenModelReport(importPath, exportPath, archive = T, openreport = T)
    
    
    
