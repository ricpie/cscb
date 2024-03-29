#Parameter file for analysis for Boston College Smokeless Village study
#Set path to tracking sheet relative to 'SUMS processing' directory
path_tracking_sheet <- NA #Set to NA if none available
path_tracking_sheet_json <- "~/Dropbox/Peru 2019 NAMA Internal/Analysis/SUMS Tracking data/Perú_NAMA_SUMs_v3_results.json"

project_name <- "NAMA Piloto Solar"

#Text associating a given stove code with the full name to use in figures.
stove_codes <- data.frame(stove = as.factor(c("Solar","Tradicional","Ventilador","GLP","Carbon",
                                              "stove_type:solar","stove_type:tradicional-fogon","stove_type:tradicional-lowtemp",
                                              "Mejorada","stove_type:ventilador","stove_type:GLP","stove_type:Carbon","stove_type:tradicional-secundaria","Tradicional2")),
                          stove_descriptions = as.factor(c("Solar","Tradicional","Ventilador","GLP","Carbon","Solar","Tradicional","Tradicional","Mejorada","Ventilador","GLP","Carbon","Tradicional2","Tradicional")))

stove_group_codes <- data.frame(group = as.factor(c("stove_type:ventilador","stove_type:solar","control","Ventilador","Solar","Control")),  #Use these if there are different study arms.
                                stove_groups = as.factor(c("Ventilador","Solar","Control","Ventilador","Solar","Control"))) #group variable in filter_sumsarized.R

region_codes <- data.frame(region_code = as.factor(c("01","02","03","04","05","06","07","08","09","10","11","12")),  #Use these if there are different study arms.
                                region = as.factor(c("LaLibertad","Pasco","Puno","Moquegua","Tacna","Arequipa","Huancavelica","Junin","Huanuco","Ucayali","Loreto","SanMartin"))) #group variable in filter_sumsarized.R

campaign_name = "Piloto Solar y Ventilador"


cooking_group <- 40 # x minute window for grouping events together.
cooking_duration_minimum <- 1  #Minutes
cooking_duration_maximum <- 1440 #Minutes
logging_duration_minimum <- 1 #days.  Single file duration must be this long to be included in the analysis.
#If set to zero, it will not trim out any data, instead leaving the complete data sets available for analysis.  Trimming is done
#to account for placement times/dates.
total_days_logged_minimum <- 5 #Must have at least this many days for a households's stove to be included in the analysis. Default value is 5.
metadata_date_ignore <- 1

start_date_range <- "2018-5-1" #Year-Month-Day format.  Do not include data before this in the analysis
end_date_range <- "2020-12-1" #Do not include data after this in the analysis

timezone = -5 #Timezone relative to GMT.  Shifts the time by this many hours.

# Remove data from files selected as bad (they match the following strings, so they should be specific to the 
#given file, not generic enough to remove more files than intended)
bad_files <- paste(c("Excl","|AMB","|Eliminar","|Pre_Pilot-04_TMS_DL-01"
                     ,"|Pre_Pilot-04_TMS_DL-01","|AMB"),collapse="")

# Exclude data from the following households from the entire analysis. e.g.SHO_03 is removed
HHID_remove <- paste(c("^SHO_03$","|^SHO_04$","|^MUS_01$","|^AMB$"),collapse="")




