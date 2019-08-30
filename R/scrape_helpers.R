library(ffanalytics)
library(configr)
library(aws.s3)

scrape_weekly <- function(season = NULL, week = NULL, data_path = 'data', force=FALSE) {
  config = read.config(file = 'config.yaml')

  # Default to the current season
  if(is.null(season)) 
    season <- as.numeric(format(Sys.Date(), "%Y"))
  
  # Default to week 1
  if(is.null(week)) 
    week = 1
  
  file_name = file.path(data_path, paste(Sys.Date(), '_week-', week, '.Rds', sep=""))
  
  # If the file exists, load and return it
  if (!force && object_exists(object=file_name, bucket=config$aws_bucket))
    return(s3readRDS(object=file_name, bucket=config$aws_bucket))
  
  cat(paste("Scraping weekly data..."))
  weeklyData <- scrape_data(src = c(#'CBS',
                                    #'ESPN',
                                    #'FantasyData',
                                    #'FantasyPros',
                                    'FantasySharks',
                                    'FFToday',
                                    'FleaFlicker',
                                    'NumberFire',
                                    'Yahoo',
                                    'FantasyFootballNerd',
                                    'NFL'), 
                           pos = c("QB", "RB", "WR", "TE", "K", "DST"),
                           season = season, week = week)
  s3saveRDS(weeklyData, object=file_name, bucket=config$aws_bucket)
  return(weeklyData)
}

scrape_season <- function(season = NULL, data_path = 'data', force=FALSE) {
  config = read.config(file = 'config.yaml')

  # Default to the current season
  if(is.null(season)) 
    season <- as.numeric(format(Sys.Date(), "%Y"))
  
  file_name = file.path(data_path, paste(Sys.Date(), '_season.Rds', sep=""))
  
  # If the file exists, load and return it
  if (!force && object_exists(object=file_name, bucket=config$aws_bucket))
    return(s3readRDS(object=file_name, bucket=config$aws_bucket))
  
  cat(paste("Scraping season data..."))
  seasonData <- scrape_data(src = c('CBS',
                                    #'ESPN',
                                    #'FantasyData',
                                    'FantasyPros',
                                    'FantasySharks',
                                    'FFToday',
                                    #'FleaFlicker',
                                    'NumberFire',
                                    'FantasyFootballNerd',
                                    'NFL',
                                    'RTSports',
                                    'Walterfootball',
                                    'Yahoo'),
                            pos = c("QB", "RB", "WR", "TE", "K", "DST"),
                            season = season, week = 0)
  s3saveRDS(seasonData, object=file_name, bucket=config$aws_bucket)
  
  return(seasonData)
}
