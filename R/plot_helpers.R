library(ggplot2)
library(ggthemes)

team_projections_plot <- function(dt,week) {
  x_max <- max(dt$ceiling,na.rm=TRUE)+3
  x_min <- min(dt$floor,na.rm=TRUE)-3
  ggplot(dt, aes(x=points, y=rank(-dt$points), color=as.factor(pos))) +
    geom_errorbarh(aes(xmin=floor,xmax=ceiling),height=.3) +
    geom_point(size=5,color="white") +
    geom_text(aes(x=points,label=round(points,0)),size=3,show.legend = FALSE) +
    geom_text(aes(x=ceiling, label=paste(first_name, last_name)),
              hjust=-0.2, angle=(0), size=3,show.legend = FALSE) +
    #geom_text(aes(x=floor,label=Status),color="red",fontface="bold",
    #          hjust=1.2, angle=(0), size=3,show.legend = FALSE) +
    theme_minimal() +
    theme(
      #plot.background = element_blank(),
      #panel.grid.major.x = element_line(color="grey"),
      #panel.grid.minor.y = element_line(color="grey"),
      #panel.border=element_rect(color="grey",fill=NA),
      #panel.background = element_blank(),
      legend.position = c(0.95, 0.1)
    ) + scale_y_reverse() +
    ylab("Team rank") + xlab("Median FPTS Projection with Confidence Interval") +
    labs(title = paste("Week ", week," Projections",sep="")) +
    coord_cartesian(xlim =c(x_min,x_max)) +
    scale_color_tableau()
}


gold_mining_plot <- function(dt, positions, rows = 30, color_column = 'tier') {
  filtered_dt <- dt %>% filter(position %in% positions)
  filtered_dt$relative_rank <- rank(-filtered_dt$points)
  filtered_dt <- filtered_dt %>% filter(filtered_dt$relative_rank < rows)
  
  max_positional_ceiling <- max(filtered_dt$ceiling, na.rm=TRUE)
  x_max <- max(filtered_dt$ceiling,na.rm=TRUE)+10
  x_min <- min(filtered_dt$floor,na.rm=TRUE)

  ggplot(filtered_dt, aes(x=points, y=relative_rank, color=as.factor(!!as.name(color_column)))) +
    geom_errorbarh(aes(xmin=floor,xmax=ceiling),height=.3) +
    geom_point(size=5,color="white") +
    geom_text(aes(x=points,label=round(points,0)),size=3,show.legend = FALSE) +
    geom_text(aes(x=ceiling, label=paste(first_name, last_name,paste("(", pos, ")", sep=""))),
              hjust=-0.2, angle=(0), size=3,show.legend = FALSE) +
    #geom_text(aes(x=floor,label=Status),color="red",fontface="bold",
    #          hjust=1.2, angle=(0), size=3,show.legend = FALSE) +
    theme_minimal() +
    theme(
      #plot.background = element_blank(),
      #panel.grid.major.x = element_line(color="grey"),
      #panel.grid.minor.y = element_line(color="grey"),
      #panel.border=element_rect(color="grey",fill=NA),
      #panel.background = element_blank(),
      legend.position = c(0.95, 0.1)
    ) + scale_y_reverse() +
    ylab("Rank") + xlab("Median FPTS Projection with Confidence Interval") +
    labs(title = paste("Point Projections, (", paste(positions, collapse=", "), ")",sep="")) +
    coord_cartesian(xlim =c(x_min, x_max)) +
    scale_color_tableau()
}