library(data.table)
library(ffanalytics)
library(configr)

get_player_ids <- function(source, season = NULL, data_path = 'data', force=FALSE) {
  config = read.config(file = 'config.yaml')

  # Default to the current season
  if(is.null(season)) 
    season <- as.numeric(format(Sys.Date(), "%Y"))

  # Create a file name from the passed args
  file_name = file.path(data_path, paste('player_ids_', source, '_', season, '.Rds', sep=""))

  # If the file exists, load and return it
  if (!force && object_exists(object=file_name, bucket=config$aws_bucket))
    return(s3readRDS(object=file_name, bucket=config$aws_bucket))

  # Else, scrape player data from the given source
  scraped_data <- scrape_data(src = c(source),
                              pos = c("QB", "RB", "WR", "TE", "K", "DST"),
                              season = season, week = 0)

  # Add metadata
  scraped_data$DST <- mutate_at(scraped_data$DST, vars(team), .funs=toupper)
  scraped_data$DST <- merge(scraped_data$DST,ffanalytics::ff_player_data %>% filter(position == 'Def'), by='team')
  scraped_data$DST$id = scraped_data$DST$id.y
  scraped_data$DST$team = scraped_data$DST$team
  
  # Concatenate positional data frames and select out the ID mapping
  mapping = rbindlist(scraped_data, fill=TRUE) %>% select(player, id, src_id, team, pos)

  # Save it for future use and return the data
  s3saveRDS(mapping, object=file_name, bucket=config$aws_bucket)
  return(mapping)
}