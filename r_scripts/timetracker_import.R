
timetracker_import_fun <- function(){
  library(jsonlite)
  library(tidyverse)
  library(readxl)
  dir.create("Processed Data")
  
  # Import metadata ---------------------------------------------------------
  metadata_tracker_paths <- list.files(
    path = "~/Dropbox/World Bank CSCB Field Folder/Field Data/TimeTracker Data",
    recursive = TRUE,
    pattern = ".xlsx",
    full.names = TRUE
  ) 
  meta_timetracker = read_xlsx(metadata_tracker_paths) %>% 
    rename( "HHID" = `HH ID`)
  
  
  # Import timeseries data --------------------------------------------------
  
  tracker_paths <- list.files(
    path = "~/Dropbox/World Bank CSCB Field Folder/Field Data/TimeTracker Data",
    recursive = TRUE,
    pattern = ".txt",
    full.names = TRUE
  )
  
  
  
  timetracker_data <- rbindlist(lapply(tracker_paths,
                                       function(x){
                                         fromJSON(x) %>% as.data.frame() %>% 
                                           dplyr::mutate(tracker_paths = x)}),fill=TRUE) %>% 
    # distinct() %>% 
    dplyr::rename(HHID = user) %>% 
    dplyr::mutate(endTimeog_og = endTime,
                  endTimeog = gsub("2017","2021",endTime),
                  startTimeog_og = startTime,
                  startTimeog = gsub("2017","2021",startTime) ,
                  endTime = parse_date_time(endTimeog,orders = "%a %b %d %H:%M:%S %z %Y",tz = "Africa/Nairobi"),
                  startTime = parse_date_time(startTimeog,orders = "%a %b %d %H:%M:%S %z %Y",tz = "Africa/Nairobi"),
                  endTime = case_when(tracker_paths %like% "12DACON" ~ endTime -14*60*60, #Has -11 so moving to +3
                                      tracker_paths %like% "51DAIN" ~ endTime + 5*60*60,
                                      TRUE ~ endTime),
                  startTime = case_when(tracker_paths %like% "12DACON" ~ startTime - 14*60*60, #Has -11 so moving to +3
                                        tracker_paths %like% "51DAIN" ~ startTime + 5*60*60,
                                        TRUE ~ startTime),
                  HHID = case_when(tracker_paths %like% "12DACON" ~ "12_DA_CON",
                                   tracker_paths %like% "51DAIN" ~ "51_DA_IN",
                                   tracker_paths %like% "21JKIN" ~ "21_JK_IN",
                                   TRUE ~ HHID)) %>% #Has +8 so moving to +3
    dplyr::filter(endTime > parse_date_time("May 12 17:10:43 GMT-11:00 2021",orders = "%b %d %H:%M:%S %z %Y",tz = "Africa/Nairobi"),
                  startTime > parse_date_time("May 12 17:10:43 GMT-11:00 2021",orders = "%b %d %H:%M:%S %z %Y",tz = "Africa/Nairobi")) %>% 
    dplyr::select(-tracker_paths) %>% 
    distinct()
  
  
  filename = paste0("~/Dropbox/World Bank Gender Cobenefits/Data Analysis cscb/Results/timetracker_data",  Sys.Date(), ".xlsx")
  write_xlsx(timetracker_data,filename)
  
  return(timetracker_data)
}
