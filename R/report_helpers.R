library(ggplot2)
library(ggthemes)
library(shiny)
library(aws.s3)
library(aws.ses)
library(configr)

source('R/plot_helpers.R')
source('R/get_optimal_lineup.R')

s3_base_url <- function() {
  config <- read.config('config.yaml')
  bucket <- config$aws_bucket
  s3_base_url<- paste0('https://', bucket, '.s3.amazonaws.com/')
  
  return(s3_base_url)
}

publish_plot <- function(object, plot_fn, plot_args, data_path = 'data') {
  config <- read.config('config.yaml')
  
  file_path <- file.path(data_path, object)
  dir.create(dirname(file_path), showWarnings = FALSE)
  
  ggsave(
    file_path,
    do.call(plot_fn, plot_args),
    width = 5,
    height = 5,
    dpi = 300
  )
  
  put_object(file_path, object, config$aws_bucket)
  
  return(paste0(s3_base_url(), object))
}

publish_gold_mining_plots <- function(dt, name_prefix) {
  unique_roster_positions = unique(config$roster_positions)
  
  urls = map(unique_roster_positions, function(positions) {
    date <- Sys.Date()
    positions <- unlist(strsplit(positions, "/"))
    s3_object <- paste0(date, '/', name_prefix, '_', paste(positions, collapse='_'), '.png')
    
    color_column <- if(length(positions) > 1) 'position' else 'tier'
    
    url <- publish_plot(object = s3_object,
                        plot_fn = gold_mining_plot,
                        plot_args = list(dt, positions, color_column = color_column))
    return(url)
  })
  
  return(urls)
}

create_report <- function(team_projections, weekly_available, season_available, week = 1) {
  date <- Sys.Date()
  
  # Get the optimal lineup
  optimal_lineup <- get_optimal_lineup(team_projections, weekly_available, week = week)
  
  
  # Publish the team projections plot
  team_projections_object = paste0(date, '/team_projections.png')
  team_projections_url = publish_plot(object = team_projections_object,
                                      plot_fn = team_projections_plot,
                                      plot_args = list(team_projections, week))
  
  
  # Publish the weekly gold mining plots
  weekly_gold_mining_urls <- publish_gold_mining_plots(weekly_available, 'weekly_gold_mining')
    
  # Publish the season gold mining plots
  season_gold_mining_urls <- publish_gold_mining_plots(season_available, 'season_gold_mining')
    
  template <- htmlTemplate(filename = 'template.html',
                           week = week,
                           optimal_lineup = optimal_lineup,
                           team_projections_url = team_projections_url,
                           weekly_gold_mining_urls = weekly_gold_mining_urls,
                           season_gold_mining_urls = season_gold_mining_urls,
                           text_ = NULL,
                           document_ = "auto") 
  html <- paste0(template)
  return(html)
}

email_report <- function(to, html) {
  send_email(html = html,
             subject = 'Fantasy Update',
             from = 'fantasyfootball@trombs.com',
             to = to)
}