source('yahoo_helpers.R')

league_id <-'390.l.371449'
my_team_id <- '390.l.371449.t.3'
season_start <- '2019-09-05'

# Default to the current week, or week 1 if we're still in preseason
week = max(1, as.integer(as.double(Sys.Date() - as.Date(season_start)) / 7) + 1)

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
season_projections <- season_projections %>% add_ecr() %>% add_risk() %>%
  add_adp() %>% add_aav() %>% add_player_info()
weekly_projections <- weekly_projections %>% add_player_info()

print("Fetching league info...")
players <- get_players_for_all_teams(league_id)
my_team <- players %>% filter(team_id == my_team_id)

# Mark each player as available or not
season_projections$available <- !(season_projections$id %in% players$id)
weekly_projections$available <- !(weekly_projections$id %in% players$id)

# Get available players and order by season projected points
season_available = season_projections %>% filter(avg_type == 'weighted') %>% 
  filter(available == TRUE) %>% arrange(desc(points))
weekly_available = weekly_projections %>% filter(avg_type == 'weighted') %>% 
  filter(available == TRUE) %>% arrange(desc(points))

# Optimize lineup
print(paste("Generating optimal lineup for week ", week, "...", sep=""))
optimal_lineup = weekly_projections %>% filter(avg_type == 'weighted') %>%  
  filter(id %in% my_team$id) %>% arrange(desc(points))