if (!require("pacman")) install.packages("pacman")
pacman::p_load(lubridate,plyr,dplyr,reshape2,devtools,shiny,shinydashboard,dygraphs,DT,shinyjs,tools,data.table,writexl,zoo,readxl,
               cronR,miniUI,shinyFiles,ggplot2,stringr,chron,doParallel,foreach,openxlsx,gridExtra,egg,cowplot,ggbiplot,corrgram,
               factoextra,scales,htmlwidgets,tidyfast,openair,tidyr,tidylog,readr,kableExtra,ggalt,janitor)

registerDoParallel(cores=detectCores()-2)

