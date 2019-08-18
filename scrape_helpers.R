library(ffanalytics)

scrape_weekly <- function(season = NULL, week = NULL, data_path = 'data') {
  # Default to the current season
  if(is.null(season)) 
    season <- as.numeric(format(Sys.Date(), "%Y"))
  
  # Default to the current week
  if(is.null(week)) 
    week = as.integer(as.double(Sys.Date() - as.Date("2019-09-05")) / 7) + 1
  
  file_name = file.path(data_path, paste(Sys.Date(), '_week-', week, '.Rda', sep=""))
  
  # If the file exists, load and return it
  if (file.exists(file_name))
    return(readRDS(file_name))
  
  cat(paste("Scraping weekly data..."))
  weeklyData <- scrape_data(src = c(#'CBS',
                                    #'ESPN',
                                    #'FantasyData',
                                    #'FantasyPros',
                                    'FantasySharks',
                                    'FFToday',
                                    #'FleaFlicker',
                                    'NumberFire',
                                    'Yahoo',
                                    'FantasyFootballNerd',
                                    'NFL'), 
                           pos = c("QB", "RB", "WR", "TE", "K", "DST"),
                           season = season, week = week)
  saveRDS(weeklyData, file=file_name)
  return(weeklyData)
}

scrape_season <- function(season = NULL, data_path = 'data') {
  # Default to the current season
  if(is.null(season)) 
    season <- as.numeric(format(Sys.Date(), "%Y"))
  
  file_name = file.path(data_path, paste(Sys.Date(), '_season.Rda', sep=""))
  
  # If the file exists, load and return it
  if (file.exists(file_name))
    return(readRDS(file_name))
  
  cat(paste("Scraping season data..."))
  seasonData <- scrape_data(src = c('CBS',
                                    #'ESPN',
                                    #'FantasyData',
                                    'FantasyPros',
                                    'FantasySharks',
                                    #'FFToday',
                                    #'FleaFlicker',
                                    'NumberFire',
                                    'FantasyFootballNerd',
                                    'NFL',
                                    'RTSports',
                                    'Walterfootball',
                                    'Yahoo'),
                            pos = c("QB", "RB", "WR", "TE", "K", "DST"),
                            season = season, week = 0)
  saveRDS(seasonData, file=file_name)
  
  return(seasonData)
}
