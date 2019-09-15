library(configr)

source('R/yahoo_helpers.R')
source('R/plot_helpers.R')
source('R/scrape_helpers.R')
source('R/report_helpers.R')
source('R/get_custom_scoring.R')
source('R/aws_init.R')

config = read.config('config.yaml')

# Default to the current week, or week 1 if we're still in preseason
week = max(1, as.integer(as.double(Sys.Date() - as.Date(config$season_start) + 2) / 7) + 1)

print("Scraping season data...")
season_data = scrape_season()

print(paste("Scraping week ", week, " data...", sep=""))
weekly_data = scrape_weekly(week = week)

custom_scoring <- get_custom_scoring()
print("Generating season projections...")
season_projections <-  projections_table(season_data, scoring_rules = custom_scoring)
print("Generating weekly projections...")
weekly_projections <-  projections_table(weekly_data, scoring_rules = custom_scoring)

print("Decorating projections...")
season_projections <- season_projections %>% add_player_info()
weekly_projections <- weekly_projections %>% add_player_info()
# weekly_projections$rank = left_join(weekly_projections, season_projections, by = c("id", "avg_type", "pos"))$rank

print("Fetching league info...")
players <- get_players_for_all_teams(config$league_id)
my_team <- players %>% filter(team_id == config$my_team_id)

# Mark each player as available or not and assign owning team info
season_projections$available <- !(season_projections$id %in% players$id)
weekly_projections$available <- !(weekly_projections$id %in% players$id)
season_projections <- season_projections %>% left_join(players, by=c('id', 'position'))
weekly_projections <- weekly_projections %>% left_join(players, by=c('id', 'position'))

# Get the weighted averages
season_projections = season_projections %>% filter(avg_type == config$avg_type)
weekly_projections = weekly_projections %>% filter(avg_type == config$avg_type)

# Get available players and order by season projected points
season_available = season_projections %>% filter(available == TRUE) %>% arrange(desc(points))
weekly_available = weekly_projections %>% filter(available == TRUE) %>% arrange(desc(points))

# Get team projections
print(paste("Generating team_projections for week ", week, "...", sep=""))
team_projections = weekly_projections %>% filter(id %in% my_team$id) %>% arrange(desc(points))
team_season_projections = season_projections %>% filter(id %in% my_team$id) %>% arrange(desc(points))

# Get season remaining positional points per team
season_positional_points <- season_projections %>% group_by(team_id, owner, pos) %>%
  filter(owner != 'NA') %>% summarise(points = sum(points), na.rm = TRUE)

print(paste("Sending report for week ", week, "...", sep=""))
html = create_report(team_projections,
                     team_season_projections,
                     weekly_available,
                     season_available,
                     week = week)
writeLines(html, 'report.html')
email_report(html = html, to = config$email_to)