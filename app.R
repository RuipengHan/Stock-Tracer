library(shiny)
library(tidyverse)

library(data.table)


# Get all file names
list_csv_files <- list.files(path = "data/")
list_csv_files = paste("data/", list_csv_files, sep="")
# Drop the sp500.csv
list_csv_files = list_csv_files[-which(list_csv_files=="data/sp500.csv")]

# Read all csv files into one stock_data
stock_data = readr::read_csv(list_csv_files, id = "tick")
# stock_symbol = readr::read_csv("data/sp500.csv")


# Change the tick column to match its company
stock_data$tick = sub("data/", "", stock_data$tick)
stock_data$tick = sub(".csv", "", stock_data$tick)

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
                                               choices = unique(stock_data$tick), 
                                               selected="AAPL")
                                 ),
                                 mainPanel(plotOutput("plot"))
                                 )
                               ),
                      tabPanel(title="About"),
                      tabPanel(title = "Credits"))
)

# Define UI for application that draws a histogram
# ui <- fluidPage(
# 
#     # Application title
#     titlePanel("Welcome to my final project!"),
# 
#     # Sidebar with a slider input for number of bins 
#     sidebarLayout(
#         sidebarPanel(
#             sliderInput("bins",
#                         "Number of bins:",
#                         min = 1,
#                         max = 50,
#                         value = 30),
#             selectInput("plotColor",
#                         "Pick a color:",
#                         choices = c("dodgerblue", "darkorange"))
#         ),
# 
#         # Show a plot of the generated distribution
#         # Defines where to put the plot
#         mainPanel(
#            plotOutput("distPlot")
#         )
#     )
# )

# Define server logic required to draw a histogram
server <- function(input, output) {
    # Defines what to display for the output
    # if (): set x scale
    output$plot <- renderPlot({
      stock_data |>
        filter(tick == input$stock1) |>
        filter(Date >= as.Date(input$dateFrom) & Date <= as.Date(input$dateTo)) |>
        ggplot(aes(x = Date, y = Close)) +
        geom_line() + 
        ggtitle(input$type) +
        xlab("Time") + ylab("Price (in USD)")+
        scale_x_date(date_breaks = "years" , date_labels = "%Y")
    #   ggplot(data=faithful, mapping=aes(x=waiting)) +
    #     geom_histogram(bins=input$bins, fill=input$plotColor)
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
