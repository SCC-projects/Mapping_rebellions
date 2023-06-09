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

#data load
Data <- read_delim("data.csv", delim = ";", 
                   escape_double = FALSE, col_types = cols(`Date/ start` = col_character(), 
                                                           Year = col_character()), trim_ws = TRUE)

#additional year setting
Data$Year<- gsub('.{6}$', '', Data$Year)
Data$Year<-as.numeric(Data$Year)

#add id
Data$id <- seq.int(nrow(Data))

#setting numeric lat-long props
Data$Longitude<- gsub('.{3}$', '', Data$Longitude)
Data$Latitude<- gsub('.{3}$', '', Data$Latitude)
Data$Latitude<-as.numeric(Data$Latitude)
Data$Longitude<-as.numeric(Data$Longitude)

dataset <- as.data.table(Data)


####ui####
ui <- fluidPage(
  tags$link(rel = "stylesheet", type = "text/css", href = "style.css"),
  theme = shinytheme("cosmo"),
  sidebarLayout(position = "left", fluid = T,
                sidebarPanel(width = 3, style = "overflow-y:scroll; height: 800px;  position:relative;",
                             fluidRow(h3("ENCYCLOPAEDIA of Rebellions"),
                                      h4("Read more about revolts and revolutions"),
                                      p("Click on the box below to see the entire list of entries in chronological order. 
                                        You can also type a location (e.g. Barcelona), or a year (e.g. 1638) or a category of event (e.g. uprising) 
                                        to filter the appropriate results."),
                                      br()),
                             div(style = "max-height: 700px; position:relative;",
                                 fluidRow(
                                   selectizeInput('data', "", unique(dataset$Revolt),multiple=F, selected = NULL, options = list(placeholder = "Type name of the revolt")))                             
                             )),
                mainPanel(width = 9, 
                          fluidPage(
                            uiOutput('Revolt')
                          ))),
  fluidRow(tags$footer(HTML("
           <div class='footer-dark'>
            <div class='container'>
                <div class='row'>
                  <div class='col-6 col-md-4' >
                  <ul>
                        <li><a href='http://www.resistance.uevora.pt' class='image'><img src='img/resistancelogo_m.png', height = 30></a></li>
                        <li><a href='https://www.en.cidehus.uevora.pt' class='image'><img src='img/CIDEHUS.png' style = 'padding-top: 10px', height = 40></a></li>
                        <li><a href='https://www.iscte-iul.pt' class='image'><img src='img/ISCTE-IUL.png', style = 'padding-top: 10px', height = 40></a></li>
                        <li><a href='https://www.lhlt.mpg.de/en' class='image'><img src='img/mpifullwhite.png', height = 30></a></li>
                        <li>2019. This work is licensed under a CC BY 4.0 license</li>

                    </ul>
                    </div>
                        <div class='col-6 col-md-4'>
                        <ul>
                            <li><a href='http://www.resistance.uevora.pt'>Contacts</a></li>
                             <li><a href=''>Legal Information</a></li>
                              <li><a href=''>Licence</a></li>
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
                                  </div>
                                  </div>
                                  </div>"))))


#####ui ends####

server <- function(input, output, session) { 
  
  #setting the reactive dataset  
  dsub <- reactive({
    DataSearch <- paste(input$data, collapse = "|")
    DataSearch <- gsub(",", "|",DataSearch)
    dataset[grepl(DataSearch,Revolt)]
  })
  
  
  #render a main window with the data 
  output$Revolt <- renderUI({
    tabItem(tabName = "",
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
                      tags$b("Leadership:"), dsub()$Leader, em(".", .noWS = c("before")),
                      tags$b("Relevance:"), dsub()$Relevance, em(".", .noWS = c("before"))))),
              h4("Further reading "),
              panel(renderText(dsub()$References)),
              panel(div(p(tags$b("Author:"), dsub()$Author))),
              h4("Recommended citation for Encyclopaedia entries (example):"),
              panel(div(p('Herreros, Benita (2023). "Huarochiri uprising 1750", in J. V. Serrão and M. S. Cunha (coord), 
                          Rebellions in the Early Modern Iberian World.  <https://mappingrebellions.com/encyclopaedia.html>')))
              
            )
    )
  })
  
}

shinyApp(ui, server)