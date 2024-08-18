options(shiny.port = 8050, shiny.autoreload = TRUE)

library(shiny)
library(ggplot2)
library(tidyverse)


#Preprocessing
data_people <- read.csv("../data/raw/death_by_cause.csv") |>
  janitor::clean_names() |>
  mutate(ref_date = as.Date(ref_date),
         cause_of_death = str_split_i(cause_of_death_icd_10, "\\[", 1) |> str_trim(),
         geo = str_split_i(geo, ",", 1) |> str_trim()) |>
  drop_na("value") |>
  filter(value != 0) |>
  filter(!cause_of_death %in% c("COVID-19, virus not identified", "COVID-19, virus identified")) |> #Filter disaggregated COVID values
  select(ref_date, geo, value, cause_of_death)

#For filters
all_causes_of_death <- unique(data_people$cause_of_death) |> sort()
all_dates <- unique(data_people$ref_date) |> sort()
all_provinces <- unique(data_people$geo) |> sort()


sidebar <- sidebarPanel(

  selectInput("cause_of_death", label = "Cause of Death", choices = all_causes_of_death, multiple=TRUE, selected = all_causes_of_death),
  actionButton("clear_all_causes", "Clear Causes"),
  actionButton("select_all_causes", "Select All Causes"),
  selectInput("geo", label = "Province", choices = all_provinces, selected = "Canada"),
  sliderInput("ref_date", "Date", min=min(all_dates), max=max(all_dates), value=c(min(all_dates), max(all_dates)), ticks=TRUE),
)

main <- mainPanel(
  plotOutput("deaths_over_time_plot", width = "1000px"),
  plotOutput("deaths_by_cause_plot", width = "1000px")
)

# Layout
ui <- fluidPage(
  titlePanel(h1("Canadian Death Dashboard", align="center")),
  theme = bslib::bs_theme(bootswatch = 'darkly'),
  sidebarLayout(
    sidebar,
    main,
    position = c("left", "right"),
    fluid = TRUE
  )
)



# Server side callbacks/reactivity
server <- function(input, output, session) {

  observeEvent(input$clear_all_causes, {
    updateSelectInput(session, "cause_of_death", selected = character(0))
  })

  observeEvent(input$select_all_causes, {
    updateSelectInput(session, "cause_of_death", selected = all_causes_of_death)
  })

  output$deaths_over_time_plot <- renderPlot({
    render_line_chart(input$geo, input$cause_of_death, input$ref_date[1], input$ref_date[2])
  })

  output$deaths_by_cause_plot <- renderPlot({
    render_pie_chart(input$geo, input$cause_of_death, input$ref_date[1], input$ref_date[2])

  })
}

filter_data <- function(province, causes, start_date, end_date) {
  data_people |>
    filter(geo == province) |>
    filter(cause_of_death %in% causes) |>
    filter(ref_date > start_date, ref_date <= end_date)
}

render_line_chart <- function(province, causes, start_date, end_date) {
  ggplot(filter_data(province, causes, start_date, end_date)
         ,aes(x = ref_date, y = value, colour = cause_of_death)) +
    geom_point() +
    geom_line() +
    scale_x_date(date_breaks = "1 year", date_labels =  "%b %Y") +
    labs(x = "Date", y = "Number of Deaths per Week", colour = "Cause of Death") +
    ggtitle("Deaths over Time") +
    scale_y_log10() +
    theme_dark()

  }

render_pie_chart <- function(province, causes, start_date, end_date) {
  ggplot(filter_data(province, causes, start_date, end_date) |>
           filter(cause_of_death != "Total, all causes of death") |>
           group_by(cause_of_death) |>
           summarize(total_deaths = sum(value)), aes(x="", y=total_deaths, fill=cause_of_death)) +
  geom_bar(stat="identity", width=1) +
  coord_polar("y", start=0) +
  labs(y = "Number of Deaths", fill = "Cause of Death") +
  ggtitle("Total Deaths by Cause") +
  theme_dark()
}

shinyApp(ui, server)
