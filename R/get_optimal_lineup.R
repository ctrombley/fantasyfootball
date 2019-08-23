slots <- c("QB", "RB", "RB", "WR", "WR","TE", "WR/RB/TE", "WR/RB/TE", "DST")

week <- 1
#team = get_players_for_team('390.l.371449.t.3')
remaining <- data.frame(optimal_lineup)
optimal <- slice(optimal_lineup, 0)
for (slot in slots) {
  positions <- unlist(strsplit(slot, "/"))
  selected <- remaining %>% filter(position %in% positions) %>% top_n(1, wt=points) 
  remaining <- remaining %>% filter(id != selected$id)
  optimal <- optimal %>% bind_rows(selected)
}