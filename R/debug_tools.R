get_raw_data <- function(dt, player_ids) {
  rbindlist(dt, fill=TRUE) %>% filter(id %in% player_ids)
}

filter_scrape_sources <- function(dt, sources) {
  dt %>% 
    rbind %>%
    filter(data_src %in% sources) %>%
    split(dt$position)
}