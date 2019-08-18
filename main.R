source('yahoo_helpers.R')

league_id <-'390.l.371449'
my_team_id <- '390.l.371449.t.3'

print("Scraping data...")
season_data = scrape_season()

print("Scraping week 1 data...")
weekly_data = scrape_weekly(week=1)

print("Generating projections...")
custom_scoring <- get_custom_scoring()
season_projections <-  projections_table(season_data, scoring_rules = custom_scoring)
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
print("Generating optimized lineup...")
optimal_lineup = weekly_projections %>% filter(avg_type == 'weighted') %>%  
  filter(id %in% my_team$id) %>% arrange(desc(points))