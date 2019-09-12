library(httr)
library(data.table)
library(configr)

source('R/get_player_ids.R')

get_auth_token <- function(oauth_key = NULL, oauth_secret = NULL, config_file = 'config.yaml')
{
  options("httr_oob_default" = T)
  
  if(is.null(oauth_key) || is.null(oauth_secret)) {
    config = read.config(file = config_file)
    oauth_key = config$yahoo_oauth_key
    oauth_secret = config$yahoo_oauth_secret
  }
  
  endpoint <- oauth_endpoint("get_request_token", "request_auth", "get_token",
                             base_url = "https://api.login.yahoo.com/oauth2")
  app <- oauth_app("yahoo", key = oauth_key, secret = oauth_secret)
  token <- oauth2.0_token(endpoint, app, scope = NULL, user_params = NULL,
                          type = NULL, use_oob = TRUE, as_header = TRUE,
                          use_basic_auth = TRUE, cache = TRUE,
                          config_init = list(), client_credentials = FALSE, credentials = NULL, oob_value = "oob")
  
  return(token)
}

get_players_for_team <- function(team_id) {
  # Make an API request to Yahoo's teams endpoint
  url <- sprintf("https://fantasysports.yahooapis.com/fantasy/v2/team/%s/roster/players?response=json", team_id)
  res <- GET(url, httr::config(token = get_auth_token()))

  # Deserialize the player data from the response
  player_data <- content(res)$fantasy_content$team[[2]]$roster$`0`$players 
  
  # Create a return table 
  players <- data.table(team_id=character(0),
                        name=character(0),
                        position=character(0),
                        src_id=character(0))
  
  # Populate the return table
  for (i in 1:player_data$count) {
    # Deal with the crazy formatting
    player <- as.list(unlist(player_data[[i]]$player[[1]]))
    
    name <- player$name.full
    position <- player$primary_position
    if (position=="DEF")
      src_id <- toupper(player$editorial_team_abbr)
    else
      src_id <- player$player_id

    
    if (is.null(position))
      position = "UNKNOWN"
    
    players <- rbindlist(list(players, list(team_id, name, position, src_id)))
  }
  
  # Merge in the canonical player ids
  player_ids = get_player_ids("Yahoo")
  players <- merge(player_ids, players, by="src_id", all.y=TRUE)
  
  # Select and reorder results
  players <- players %>% select(id, name, position, team_id, src_id)
  
  return(players)
}

get_teams <- function(league_id) {
  # Make an API request to Yahoo's league endpoint
  url <- sprintf("https://fantasysports.yahooapis.com/fantasy/v2/league/%s/teams?response=json", league_id)
  res <- GET(url, httr::config(token = get_auth_token()))
  
  # Deserialize the teams data from the response
  teams_data <- content(res)$fantasy_content$league[[2]]$teams
  
  # Create a return table 
  teams <- data.table(team_id=character(0),
                        name=character(0))
  
  for (i in 1:teams_data$count) {
    # Deal with the crazy formatting
    team = as.list(unlist(teams_data[[i]]$team))
    
    team_id <- team$team_key
    name <- team$name
    
    teams <- rbindlist(list(teams, list(team_id, name)))
  }  
  
  # Select and reorder results
  teams <- teams %>% select(team_id, name)
  
  return(teams)
}
  
get_players_for_all_teams <- function(league_id) {
  teams = get_teams(league_id)
  team_ids = teams[['team_id']]
  
  players = data.table()
  
  for (team_id in team_ids) {
    team_players = get_players_for_team(team_id)
    players <- rbind(players, team_players)
  }  
      
  return(players)
}

# Get the active league & team IDs here
get_user <- function() {
  # Make an API request to Yahoo's player endpoint
  url <- sprintf("https://fantasysports.yahooapis.com/fantasy/v2/users;use_login=1/games;game_keys=nfl/teams?response=json")
  res <- GET(url, httr::config(token = get_auth_token()))
  return(content(res))
}

