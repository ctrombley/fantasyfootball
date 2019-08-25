get_raw_data <- function(dt, player_ids) {
  rbindlist(dt, fill=TRUE) %>% filter(id %in% player_ids)
}