#Parameter file for analysis
#Set path to tracking sheet relative to 'SUMS processing' directory
path_tracking_sheet <- NA
metadata_date_ignore <- 1

project_name <- "WB_CSCB"
#Text associating a given stove code with the full name to use in figures.
stove_codes <- data.frame(stove = as.factor(c("TSF","LPG","KCJ", 
                                              "ELE","bio","MTSF",
                                              "Biogas","Biogas.csv", "MCJ",
                                              "MCS","TradBiomass", "TradCharcoal")),
                          stove_descriptions = as.factor(c("Trad Biomass","LPG","Trad Charcoal",
                                                           "Electric","Biogas","TradBiomass",
                                                           "Biogas","Biogas", "TradCharcoal",
                                                           "TradCharcoal","TradBiomass","TradCharcoal")))

stove_group_codes <- data.frame(group = as.factor(c("control","intervention")),  #Use these if there are different study arms.
                                stove_groups = as.factor(c("control","intervention"))) #group variable in filter_sumsarized.R

# #Visual flags:
# visual_flags = read_xlsx("../r_files/SUMs_CSCB_visual_flags.xlsx") %>% 
#   clean_names() %>% 
#   dplyr::mutate(file_name = gsub("_","-",file_name)) %>% 
#   tidyr::separate(file_name, c("HHID", "group","stove","dl","loggerid"), "-", extra = "merge") %>% 
#   dplyr::mutate(stove = gsub("con","",stove,ignore.case = T),
#                 stove = gsub("in","",stove,ignore.case = T),
#                 stove = gsub("2","",stove,ignore.case = T),
#                 stove = gsub("1","",stove,ignore.case = T),
#                 start_time_bad = start_time,
#                 end_time_bad = end_time) 
  
  # dplyr::mutate(valid_flag = case_when())

cooking_group <- 30 # x minute window for grouping events together.
cooking_duration_minimum <- 9  #Minutes
cooking_duration_maximum <- 1440 #Minutes
logging_duration_minimum <- 1 #days.  Single file duration must be this long to be included in the analysis.
total_days_logged_minimum <- 5 #Must have at least this many days for a households's stove to be included in the analysis.



#Not yet implemented.
start_date_range <- "2018-2-1" #Year-Month-Day format.  Do not include data before this in the analysis
end_date_range <- "2022-10-1" #Do not include data after this in the analysis


# Remove data from files selected as bad (they match the following strings, so they should be specific to the 
#given file, not generic enough to remove more files than intended)
bad_files <- paste(c("0_0_3_P83601_IndiaDMYminave","|0_0_3_P46673_Indiaminaves","|AKOKA DOWNLOAD 5_CC/"
                     ,"|Shomolu fourth download LPG/"),collapse="")

# Exclude data from the following households from the entire analysis.
HHID_remove <- paste(c("^01_MN_IN$","|^03_LW_CON$","|^15_SW_CON$","|^35_SW_CON$","|^40_SW_CON$"),collapse="")

stoves_remove <-paste(c("xabc","|xxabc"),collapse="")
