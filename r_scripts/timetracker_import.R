timetracker_import_fun <- function(){
  library(jsonlite)
  library(tidyverse)
  
  tracker_paths <- list.files(
    path = "~/Dropbox/World Bank CSCB Field Folder/Field Data/TimeTracker Data",
    recursive = TRUE,
    pattern = ".txt",
    full.names = TRUE
  )
  
  timetracker_data <- rbindlist(lapply(tracker_paths,fromJSON)) %>% 
    distinct() %>% 
    dplyr::mutate(endTime = parse_date_time(endTime,orders = "%a %b %d %H:%M:%S %z %Y",tz = "Africa/Nairobi"),
                  startTime = parse_date_time(startTime,orders = "%a %b %d %H:%M:%S %z %Y",tz = "Africa/Nairobi")) %>% 
    dplyr::rename(hhid = user)
  
  filename = paste0("~/Dropbox/World Bank CSCB Field Folder/Field Data/QA Reports/timetracker_data",  Sys.Date(), ".xlsx")
  write_xlsx(timetracker_data,filename)
  
  return(timetracker_data)
}
