# fantasyfootball
Tools for playing fantasy football on Yahoo.  Based on the awesome [ffanalytics](https://github.com/FantasyFootballAnalytics/ffanalytics) R package.

## Getting started
You'll need an app created on the Yahoo Developer Network with read access to Fantasy Sports data.  Place the client ID and client secret into a file called `config.yaml` in the root of this repo:
```ruby
yahoo_oauth_key: <CLIENT_ID>
yahoo_oauth_secret: <CLIENT_SECRET>
```

At the beginning of the season, update `league_id`, `my_team_id`, and `season_start` in `main.rb`:
```
league_id <-'390.l.371449'
my_team_id <- '390.l.371449.t.3'
season_start <- '2019-09-05'
```

You can fetch the league ID and team ID by hitting the `user` endpoint:
```
source `yahoo_helpers.R`
get_user()
```

Next, source `main.R`.  You'll get challenged during the OAuth flow the first time you try and request league data.

The script will populate your workspace with lots of tibbles:
* weekly projections for all players (`weekly_projections`)
* weekly projections for available players (`weekly_available`)
* season (rest of the way) projections for all players (`season_projections`)
* season (rest of the way) projections for available players (`season_available`)
* weekly team projections (`optimal_lineup`)

It will also generate some plots:
* Gold mining for available players based on remaining season stats
* Team projections for the current week
