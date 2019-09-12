library(ggplot2)
library(DT)

shinyApp(
  ui <- fluidPage(
    titlePanel("Explorer"),
    fluidRow(
      column(4, selectInput("position",
                            "Position",
                            c("All", 
                              unique(as.character(weekly_available$position))))
      )
    ),
    DT::dataTableOutput("dataTable")
  ),
  server <- function(input, output) {
    observeEvent(input$button, {
      cat("Showing", input$x, "rows\n")
    })
    output$dataTable <- renderDataTable(DT::datatable({
      data <- weekly_available
      if (input$position != "All") {
        data <- data[data$position == input$position,]
      }
      
      data$show <- actionButton(data$id, "Show")
      data
    }, escape = FALSE))
  }
)