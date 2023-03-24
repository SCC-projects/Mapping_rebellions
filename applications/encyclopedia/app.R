library(shinyjs)
library(dplyr)
library(shinydashboard)
library(tidyverse)
library(DT)
library(data.table)
library(htmltools)
library(shinyBS)
library(htmlwidgets)
library(shiny)
library(shinythemes)
library(leaflet)
library(shinyWidgets)

Data <- read_delim("data_ency_new_new.csv", delim = ";", 
                   escape_double = FALSE, col_types = cols(Year = col_character()), 
                   trim_ws = TRUE)
Data$Year<- gsub('.{6}$', '', Data$Year)
Data$id <- seq.int(nrow(Data))
Data$Year<-as.numeric(Data$Year)
Data$Leaders<-Data$Leader

Data$Latitude<-as.numeric(Data$Latitude)
Data$Longitude<-as.numeric(Data$Longitude)
Data$Longitude<- gsub('.{3}$', '', Data$Longitude)
Data$Latitude<- gsub('.{3}$', '', Data$Latitude)

Data$Latitude<-as.numeric(Data$Latitude)
Data$Longitude<-as.numeric(Data$Longitude)
dataset <- as.data.table(Data)


#####ui#####
ui <- fluidPage(
  theme = shinytheme("cosmo"),
  sidebarLayout(position = "left", fluid = T,
                sidebarPanel(width = 3, style = "overflow-y:scroll; height: 800px;  position:relative;",
                             fluidRow(h3("ENCYCLOPAEDIA of Rebellions"),
                                      h4("Read more about revolts and revolutions"),
                                      br()),
                             div(style = "max-height: 700px; position:relative;",
                                 fluidRow(
                                   selectizeInput('data', "", unique(dataset$Revolt),multiple=F, selected = NULL, options = list(placeholder = "Type name of the revolt"))),
                                 tags$head(
                                   tags$style(HTML("
         .shiny-output-error { visibility: hidden; },
         .shiny-output-error:before { visibility: hidden; }
     .item {
     }
     .selectize-dropdown-content .active {
       background: #f6b784 !important;
       color: white !important;
     }
.selectize-dropdown, .selectize-input { 
  line-height: 50px !important;
}
.selectize-dropdown, .selectize-dropdown.form-control{
    height: 90vh !important;
}
     .selectize-dropdown-content{
    max-height: 100% !important;
    height: 100% !important;
  ")))
                                 
      )),
                mainPanel(width = 9, 
                          fluidPage(
                            uiOutput('revolt_data')))),
  fluidRow(tags$footer(HTML("
                    <!-- Footer -->
<div class='footer-dark'>
            <div class='container'>
                <div class='row'>
                  <div class='col-6 col-md-4' >
                        <a href='http://www.resistance.uevora.pt' class='image'><img src='img/resistancelogo_m.png', style='margin-top: -17px; margin-bottom: -13px; padding-right:5px; padding-top:5px; padding-bottom: -30px', height = 40></a>
                    </div>
                        <div class='col-6 col-md-4'>
                        <ul>
                            <li><a href='http://www.resistance.uevora.pt'>Contacts</a></li>
                        </ul>
                    </div>
                  
                                  <div class='col-6 col-md-4'>
                                  <h3>Social Media</h3>
                                  <ul>
                                  <li><a href='http://www.resistance.uevora.pt/#'>Web-Site</a></li>
                                  <li><a href='https://twitter.com/R_esiste'>Twitter</a></li>
                                  <li><a href='https://www.youtube.com/c/ProjectoRESISTANCE'>YouTube</a></li>
                                  </ul>
                                  </div>
                                  <div class='col-6 col-md-4'>
                                  <a href='https://www.lhlt.mpg.de/en' class='image' style='color = white;'><img src='img/mpifullwhite.png', style='color = white; margin-top: -15px; margin-bottom: -5px; padding-right:-5px; padding-top:5px; padding-bottom: -40px', height = 40></a>
                                  </div>
                                  </div>
                                  </div>
                                  </div>
                           </footer>"))))

server <- function(input, output, session) { 

  dsub <- reactive({
    data_revolt <- paste0(c('xxx',input$data),collapse = "|")
    data_revolt <- gsub(",", "|",data_revolt)
    dataset[grepl(data_revolt,Revolt)]
  })
  
  output$revolt_data <- renderUI({
    tabItem(tabName = "Revolt%s",
            fluidPage(
              fluidRow(style='margin: 10px;',
                       box(                  
                         title = htmltools::span(
                           column(8, class="title-box"),
                           leaflet() %>%
                             setView(lng=dsub()$Longitude, lat=dsub()$Latitude, zoom = 5)%>%
                             addProviderTiles("CartoDB.Positron", group = "Light Theme", options = providerTileOptions(minZoom = 2, maxZoom = 10)) %>% 
                             addMarkers(lng=dsub()$Longitude, lat=dsub()$Latitude, popup=dsub()$Revolt)),
                         width=12, solidHeader = TRUE, status = "primary",
                         h3(dsub()$Revolt))),
              panel(
                title = "Synopsis", solidHeader = TRUE, status = "danger",
                renderText(dsub()$Synopsis)),
              h4("Additional info"),
              panel(
                div(p(tags$b("Starting date:"), dsub()$`Date/ start`, em(".", .noWS = c("before")),
                      tags$b("Ending:"), dsub()$`Date/ end`, em(".", .noWS = c("before")), 
                      tags$b("Duration:"), dsub()$Duration, em(".", .noWS = c("before")),
                      tags$b("Name in sources:"), dsub()$`Name in sources`, em(".", .noWS = c("before")),
                      tags$b("Location:"), dsub()$Location, em(".", .noWS = c("before")),
                      tags$b("Country (current):"), dsub()$Country, em(".", .noWS = c("before")),
                      tags$b("Monarchy:"), dsub()$Monarchy, em(".", .noWS = c("before")),
                      tags$b("Main participants:"), dsub()$Participants, em(".", .noWS = c("before")),
                      tags$b("Number of participants:"), dsub()$`Number of participants`, em(".", .noWS = c("before")),
                      tags$b("Main reasons & motivations:"), dsub()$Reasons, em(".", .noWS = c("before")),
                      tags$b("Leadership:"), dsub()$Leaders, em(".", .noWS = c("before"))))),
              h4("Further reading "),
              panel(renderText(dsub()$References)),
              panel(div(p(tags$b("Author:"), dsub()$Author)))
            )
    )
  })
  
}

shinyApp(ui, server)