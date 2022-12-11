library(shiny)
library(tidyverse)

library(data.table)


# Get all file names
list_csv_files <- list.files(path = "data/")
list_csv_files = paste("data/", list_csv_files, sep="")
# Drop the sp500.csv
list_csv_files = list_csv_files[-which(list_csv_files=="data/sp500.csv")]

# Read all csv files into one stock_data
print("Reading S&P 500 CSV... This may takes a minute, please be patient.")
stock_data = readr::read_csv(list_csv_files, id = "tick", show_col_types = FALSE)
stock_symbol = readr::read_csv("data/sp500.csv", show_col_types = FALSE)
print("...")
print("Still processing CSV... Almost there!")
# Change the tick column to match its company
stock_data$tick = sub("data/", "", stock_data$tick)
stock_data$tick = sub(".csv", "", stock_data$tick)
print("Done!")
# Sample query: count all days of records for each company.
# stock_data |> group_by(tick) |> summarise(n=n()) |> print()


ui = fluidPage(
      navbarPage(title="SP 500 Stock Price",
                      tabPanel(title="Visualization",
                               titlePanel(title="SP 500 Companies Historical Prices Visualization"),
                               sidebarLayout(
                                 sidebarPanel(
                                   selectInput(inputId = "type", 
                                               label="Select Type", 
                                               choices = c("Close vs. Time", "Volume vs Time."), 
                                               selected="Close vs Time"),
                                   
                                   selectInput(inputId = "sector", 
                                               label="Select Sector (if selected, stock list will be updated accordingly)", 
                                               choices = sort(c("ALL", unique(stock_symbol$`GICS Sector`)) )),
                                 
                                   dateInput(
                                     inputId="dateFrom",
                                     label="From",
                                     value = "2000-01-01",
                                     min = NULL,
                                     max = NULL,
                                     format = "yyyy-mm-dd",
                                     startview = "month",
                                     weekstart = 0,
                                     language = "en",
                                     width = NULL,
                                     autoclose = TRUE,
                                     datesdisabled = NULL,
                                     daysofweekdisabled = NULL
                                   ),
                                   dateInput(
                                     inputId="dateTo",
                                     label="To",
                                     value = format(Sys.time(), "%Y-%m-%d"),
                                     min = NULL,
                                     max = NULL,
                                     format = "yyyy-mm-dd",
                                     startview = "month",
                                     weekstart = 0,
                                     language = "en",
                                     width = NULL,
                                     autoclose = TRUE,
                                     datesdisabled = NULL,
                                     daysofweekdisabled = NULL
                                   ),
                                   selectInput(inputId = "stock1", 
                                               label="Stock", 
                                               choices = unique(stock_data$tick))
                                 ),
                                 mainPanel(plotOutput("plot"))
                                 )
                               ),
                      tabPanel(title="About"),
                      tabPanel(title = "Credits"))
)


# Define server logic required to draw a histogram
server <- function(input, output) {
    # Defines what to display for the output
    # if (): set x scale
    updateStockBySector = reactive({
      if (input$sector != "ALL"){
        stock_data |> 
          left_join(stock_symbol, by=c("tick" = "Symbol")) |>
          filter(`GICS Sector` == input$sector) 
      } else{
        stock_data
      }
    })
    
    observeEvent(
      eventExpr = input$sector,
      handlerExpr = {
        updateSelectInput(inputId = "stock1",
                          choices = sort(unique(updateStockBySector()$tick)))
      }
    )
    
    output$plot <- renderPlot({
      stock_data |>
        filter(tick == input$stock1) |>
        filter(Date >= as.Date(input$dateFrom) & Date <= as.Date(input$dateTo)) |>
        ggplot() +
        aes(x = Date, y = Close, colour=tick) +
        geom_line() + 
        labs(title = input$type) +
        xlab("Time") + ylab("Price (in USD)")+
        scale_x_date(date_breaks = "years" , date_labels = "%Y")
    #   ggplot(data=faithful, mapping=aes(x=waiting)) +
    #     geom_histogram(bins=input$bins, fill=input$plotColor)
    })
}

# Run the application 
shinyApp(ui = ui, server = server)