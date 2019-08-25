library(configr)

get_optimal_lineup <- function(team_projections, weekly_available, week = 1) {
  team_and_available = rbind(team_projections, weekly_available)
  remaining <- data.frame(team_and_available)
  optimal <- slice(team_and_available, 0)
  for (slot in config$roster_positions) {
    positions <- unlist(strsplit(slot, "/"))
    selected <- remaining %>% filter(position %in% positions) %>% top_n(1, wt=points)
    remaining <- remaining %>% filter(id != selected$id)
    optimal <- optimal %>% bind_rows(selected)
  }

  return(optimal)
}