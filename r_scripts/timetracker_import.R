timetracker_import_fun <- function(){
  library(jsonlite)
  
  tracker_paths <- list.files(
    path = "~/Dropbox/World Bank CSCB Field Folder/Field Data/TimeTracker Data",
    recursive = TRUE,
    pattern = ".txt",
    full.names = TRUE
  )
  
  timetracker_data <- rbindlist(lapply(tracker_paths,fromJSON)) %>% 
    distinct()
    
  
}