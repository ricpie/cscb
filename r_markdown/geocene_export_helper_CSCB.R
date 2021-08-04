#Import Geocene Studies data, organize it so it looks like Sumsarizer data.
#***Data from other campaigns, stove types, and stove groups will be ignored!!***
rm(list = ls())


###***Enter parameter file name for data to be analyzed***###
parameter_filename <- "parameter_file_CSCB.R" 
processor1 ='firefinder_50'
processor2 =''


# Include libraries
source('r_scripts/load.R')
source('r_scripts/load_data.R')
source_url("https://raw.githubusercontent.com/ricpie/sums_analysis/master/r_scripts/load.R",prompt=FALSE)#SHA = NULL
source(paste0('r_files/',parameter_filename))

# odk_data <- load_meta_json("~/Dropbox/Peru 2019 NAMA Internal/Analysis/SUMS Tracking data/Perú_NAMA_SUMs_v3_results.json")
# odk_data <- load_meta_json("~/Dropbox/Peru 2019 NAMA Internal/Analysis/SUMS Tracking data/Perú_NAMA_SUMs_v3_results_v2.json")


stove_types <- paste(stove_codes$stove,  collapse = "|")
stove_groups <-paste(stove_group_codes$group,collapse = "|")

# The name of the unzipped folder containing the Geocene Studies export
studies_export_folder = '~/Dropbox/World Bank Gender Cobenefits/Data Analysis cscb/Geocene Studies Output'
save_folder = 'SUMSARIZED' #Data is saved to this folder, to be consistent with past codes.

dot_data_files = list.files(paste0(studies_export_folder,'/metrics'),pattern='.csv|.CSV', full.names = T,recursive = F)

# Define which files should be considered exclude raw data files from Dots
save_path = grep(dir(paste0('../',studies_export_folder)),pattern = 'mission|Icon\r|event',inv = T,value = T)

# Read in the missions and events CSVs
events = fread(paste(studies_export_folder, 'events.csv', sep = '/'))
events = events[processor_name==processor1 | processor_name==processor2]
events$start_time = as.POSIXct(events$start_time, "%Y-%m-%dT%H:%M:%S", tz = "UTC")
events$stop_time = as.POSIXct(events$stop_time, "%Y-%m-%dT%H:%M:%S", tz = "UTC")


# Define a function to read Dot raw data files
read_dot_data_file = function(dot_data_file) {
  if (file.info(dot_data_file)$size>100){
    tsdata = fread(dot_data_file,stringsAsFactors = F,header = T)
    tsdata$timestamp = as.POSIXct(tsdata$timestamp, "%Y-%m-%dT%H:%M:%S", tz = "UTC")
    tsdata = cbind(tsdata, filename = tools::file_path_sans_ext(dot_data_file))
  }else{tsdata=NULL}
  return(tsdata)
}

# Apply the function to read Dot data to all Dot data files and
# convert individual dataframes into a single data frame
dot_data = rbindlist(lapply(dot_data_files, read_dot_data_file), fill = T)
dot_data[,filename:=NULL]
# dot_data = rbindlist(ldply(dot_data_files, read_dot_data_file,.parallel = TRUE), fill = T)



# Combine mission and tag metadata.  Parse tags. Need Stove Type, Group variable, HHID form the tags

make_tags = function(tags){
  tags<-tags[grep(":", tag)]  #Keep only tags with a colon.
  tags<-tags[str_count(tags$tag, ":")<2]  #Keep only tags with less than two colons.
  tag_dicts = strsplit(tags$tag, ":")
  tag_dicts = as.data.table(matrix(unlist(tag_dicts), ncol=2, byrow=TRUE))
  names(tag_dicts) = c('tag_category','tag_value')
  tag_dicts$tag_value <- gsub( " ", "",tag_dicts$tag_value)
  
  tags = cbind(tags,tag_dicts)[,c('mission_id','tag_category','tag_value')]
  wide_tags = dcast(unique(tags,by=c('mission_id','tag_category')), mission_id ~ tag_category, value.var = 'tag_value')
  return(wide_tags)
}

tags = make_tags(fread(paste(studies_export_folder, 'tags.csv', sep = '/')))
tags[,hhid:=paste0(hhid,hhi,hhig,hiid,hid)]
tags[,hhid:=gsub("NA","",hhid)]
tags[,hhi:=NULL]
tags[,hhig:=NULL]
tags[,hiid:=NULL]
tags[,hid:=NULL]

missions = fread(paste(studies_export_folder, 'missions.csv', sep = '/'))
missions = merge(missions,tags,by='mission_id')
missions = missions[,c("mission_id","mission_name","meter_name",
                       "meter_id","notes","group","campaign","type",
                       "creator_username",
                       "hhid","stovetype")]

missions$stove_type<-mgsub::mgsub(missions$stovetype, stove_codes$stove, stove_codes$stove_descriptions)
missions$group<-mgsub::mgsub(missions$group, stove_group_codes$group, stove_group_codes$stove_groups)

missions[,stove_type:=gsub(" ","",stove_type)]
missions[,filename:=paste(type,hhid,stove_type,group,sep = "_")]
missions[, hhid:=NULL]
missions[, shared_cooking_area:=NULL]
missions[, stove_type:=NULL]

# Combine time series data and mission+tag metadata 
temp = merge(dot_data, as.data.table(missions), by = c('mission_id'))

# Join the events table with the time series data into one large wide table
temp[, helpTimestamp := timestamp]
events[, start_time := as.POSIXct(start_time)]
events[, stop_time := as.POSIXct(stop_time)]
setkey(events, mission_id, start_time, stop_time)
all_data=foverlaps(temp, events, by.x=c('mission_id','timestamp','helpTimestamp'),type='any')
all_data[, helpTimestamp := NULL ]
all_data[, start_time:=NULL]
all_data[, stop_time:=NULL]
setnames(all_data, old=c("meter_name"), new=c("logger_id"))



# -----------------
# For SUMSarizer users, create a table that looks like SUMSarizer's old output
sumsarizer_output = data.table(filename = all_data$filename,
                               timestamp = all_data$timestamp,
                               value = all_data$value,
                               pred = all_data$event_kind,
                               mission_id = all_data$mission_id,
                               logger_id = all_data$logger_id,
                               datapoint_id = paste(all_data$processor_name,all_data$model_name,all_data$alltags)
)
sumsarizer_output$pred[grepl('COOKING|cooking',sumsarizer_output$pred)] = TRUE
sumsarizer_output$pred[sumsarizer_output$pred == 'COOKING'] = TRUE
sumsarizer_output$pred[is.na(sumsarizer_output$pred)] = FALSE

uniquefiles <- unique(sumsarizer_output[,filename])
#Save each file separately with the new correct name.  
for (i in 1:length(uniquefiles)[1]) {
  output_temp <- sumsarizer_output[filename == uniquefiles[i]]
  write.csv(output_temp, file = paste0(save_folder,"/",output_temp$filename[1],".csv"),row.names = FALSE)
}
getwd()
# Clean up the files
# rm(list=setdiff(ls(), c('all_data', 'dot_data', 'events', 'missions', 'sumsarizer_output')))



