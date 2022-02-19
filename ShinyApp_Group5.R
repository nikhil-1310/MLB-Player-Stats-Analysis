# Load required libraries
#install.packages("DT")
library(shiny)
library(shinydashboard)
library(leaflet)
library(DBI)
library(odbc)
library(DT)
library(ggplot2)
library(tidyverse)


# Read database credentials
source("./credentials_v4.R")


ui <- dashboardPage(
  skin="green",
  dashboardHeader(title = "MLB Player Stats Analysis"),
  #Sidebar content
  dashboardSidebar(
    sidebarMenu(
      menuItem("Welcome", tabName = "summary", icon = icon("dashboard")),
      menuItem("Player Details", tabName = "playerinfo", icon = icon("search")),
      menuItem("Team's performance", tabName = "gameinfo", icon = icon("calendar")),
      menuItem("Add New Game info", tabName = "insert", icon = icon("cog")),
      menuItem("Change score of past game", tabName = "update", icon = icon("cog")),
      menuItem("Remove Game data", tabName = "delete", icon = icon("list-alt")),
      menuItem("Analytics/Graph", tabName = "analytics", icon = icon("bar-chart-o"))
               
    )
  ),
  dashboardBody(
    
    tabItems(
      # content for first tab
      tabItem(tabName = "summary",
              fluidRow(column(width = 12, align='center', style="background-color:grey",
                               box(width = 15, solidHeader = TRUE,
                                   img(src="https://upload.wikimedia.org/wikipedia/en/thumb/a/a6/Major_League_Baseball_logo.svg/1200px-Major_League_Baseball_logo.svg.png", height=400, width=600, align = "right"),
                                   h3("Welcome Team Managers!", style = "font-size:50px;"),
                                   h4(style="color:black","The shiny app displays Team and Player performance from 2015-2021. As the Manager you can review not only your team, but all teams and players throughout the MLB in that period of time. The app is ready for realtime data."),
                                   h4(style="color:black", "The app has the following functions:"),
                                   h4(style="color:black", "1. Search players performance per team"),
                                   h4(style="color:black", "2. Search for past games by team"),
                                   h4(style="color:black", "3. Add/update/remove game scores"),
                                   h4(style="color:black", "4. Analyze total players per team vs total wins")),
                                   
                               box(column(width = 10, align = 'center',
                                          p(style="color:black","Arizona Diamonbacks - ARI"),
                                          p(style="color:black","Atlanta Braves - ATL"),
                                          p(style="color:black","Baltimore Orioles - BAL"),
                                          p(style="color:black","Boston Red Sox - BOS"),
                                          p(style="color:black","Chicago Cubs - CHC"),
                                          p(style="color:black","Chicago White Sox - CHW"),
                                          p(style="color:black","Cincinnati Reds - CIN"),
                                          p(style="color:black","Cleveland Guardians - CLE"),
                                          p(style="color:black","Colorado Rockies - COL"),
                                          p(style="color:black","Detriot Tigers - DET"),
                                          p(style="color:black","Houston Astros - HOU"),
                                          p(style="color:black","Kansas City Royals - KRC"),
                                          p(style="color:black","Los Angeles Angels - LAA"),
                                          p(style="color:black","Los Angeles Dodgers - LAD"),
                                          p(style="color:black","Miami Marlins - MIA")
                                          )
                               ),
                               box(column(width = 10, align = 'center',
                                          p(style="color:black","Milwaukee Brewers - MIL"),
                                          p(style="color:black","Minnesota Twins - MIN"),
                                          p(style="color:black","New York Mets - NYM"),
                                          p(style="color:black","New York Yankees - NYY"),
                                          p(style="color:black","Oakland Athletics - OAK"),
                                          p(style="color:black","Philadelphia Phillies - PHI"),
                                          p(style="color:black","Pittsburgh Pirates - PIT"),
                                          p(style="color:black","San Diego Padres - SDP"),
                                          p(style="color:black","Seattle Mariners - SEA"),
                                          p(style="color:black","San Francisco Giants - SFG"),
                                          p(style="color:black","St Louis Cardinals - STL"),
                                          p(style="color:black","Tampa Bay Rays - TBR"),
                                          p(style="color:black","Texas Rangers - TEX"),
                                          p(style="color:black","Toronto Blue Jays - TOR"),
                                          p(style="color:black", "Washington Nationals - WSN")
                                  )
                               )
              )
              
      )),
      # content for second tab
      tabItem(tabName = "playerinfo", 
              fluidRow(column(width = 12, style="background-color:grey", 
                               box(width = 15,solidHeader = TRUE,
                           h2("Player performance indicators per team"),
                           textInput("team_names", h3("Enter Team name:")),
                           actionButton("Go", "Search"),
                           h2("Player Details"),
                           DT::dataTableOutput("mytable")
                               )
                )
              )
      ),
      
      # content for third tab
      tabItem(tabName = "gameinfo", 
              fluidRow( column(width = 12, style="background-color:grey", 
                               box(width = 15, solidHeader = TRUE,
                                   h2("Provide Team name for Game details by date"),
                                   textInput("team", "Team (e.g. CHC for Chicago Cubs)"),
                                   actionButton("Go2", "Submit"),
                                   h2("Game Details"),
                                   DT::dataTableOutput("mytable2")
                               )
              )
              )
      ),
      
      # content for fourth tab
      tabItem(tabName = "insert", 
              fluidRow( column(width = 12, style="background-color:grey", 
                               box(width = 15, solidHeader = TRUE,
                                   h2("Provide details of new game"),
                                   textInput("date3", "Date (YYYY-MM-DD)"),
                                   textInput("team3", "Team"),
                                   textInput("opp", "Opponent"),
                                   textInput("result3", "Enter score (e.g. W 4-3)"),
                                   actionButton("Go3", "Submit"),
                                   textOutput("text2")
                               )
              )
              )
      ),
      
      # content for fifth tab
      tabItem(tabName = "update", 
              fluidRow( column(width = 12, style="background-color:grey", 
                               box(width = 15, solidHeader = TRUE,
                                   h2("Provide information to modify game score"),
                                   textInput("date2", "Date (YYYY-MM-DD)"),
                                   textInput("team2", "Team"),
                                   textInput("result2", "Enter new score (e.g. W 4-3)"),
                                   actionButton("Go4", "Update"),
                                   textOutput("text1")
                               )
              )
              )
      ),
      
      # content for sixth tab
      tabItem(tabName = "delete", 
              fluidRow( column(width = 12, style="background-color:grey", 
                               box(width = 15, solidHeader = TRUE,
                                   h2("Provide information to remove game score"),
                                   textInput("date4", "Date (YYYY-MM-DD)"),
                                   textInput("team4", "Team"),
                                   actionButton("Go5", "Delete"),
                                   textOutput("text3")
                               )
              )
              )
      ),
      # content for seventh tab
      tabItem(tabName = "analytics", 
              fluidRow(column(width = 12, style="background-color:grey", 
                               box(width = 15, solidHeader = TRUE,
                                   h2("Total players/wins per team from 2015 - 2021"),
                                   actionButton("Go6", "Display"),
                                   plotOutput("Hist"),
                                   plotOutput('Wins')
                               )
              )
              )
      )
    )
  )
)

server <- function(input, output) {
  
  observeEvent(input$Go, {
    # open DB connection
    db <- dbConnector(
      server   = getOption("database_server"),
      database = getOption("database_name"),
      uid      = getOption("database_userid"),
      pwd      = getOption("database_password"),
      port     = getOption("database_port")
    )
    on.exit(dbDisconnect(db), add = TRUE)
     
    #browser()
    query <- paste("select MLB_Players.Player, sum(PerformanceIndicators.R) as Runs,
                    sum(PerformanceIndicators.H) as Hits,
                    sum(PerformanceIndicators.AB) as AtBats,
                    sum(PerformanceIndicators.SO) as Strikeouts
                    from PerformanceIndicators, MLB_Players
                    where PerformanceIndicators.ID=MLB_Players.ID
                    and MLB_Players.Team like '%", input$team_names, "%'
                    group by MLB_Players.Player;", sep="")
    print(query)
    data <- dbGetQuery(db, query)
    output$mytable = DT::renderDataTable({
      data
    })
    
  })
  
  observeEvent(input$Go2, {
    # open DB connection
    db <- dbConnector(
      server   = getOption("database_server"),
      database = getOption("database_name"),
      uid      = getOption("database_userid"),
      pwd      = getOption("database_password"),
      port     = getOption("database_port")
    )
    on.exit(dbDisconnect(db), add = TRUE)
    
    #browser()
    query <- paste("select * from MLB_Game where Team like '%",input$team,"%';", sep="")
    print(query)
    data <- dbGetQuery(db, query)
    output$mytable2 = DT::renderDataTable({
      data
    })
    
  })
  
  observeEvent(input$Go3, {
    # open DB connection
    db <- dbConnector(
      server   = getOption("database_server"),
      database = getOption("database_name"),
      uid      = getOption("database_userid"),
      pwd      = getOption("database_password"),
      port     = getOption("database_port")
    )
    on.exit(dbDisconnect(db), add = TRUE)
    
    #browser()
    query <- paste("Insert into MLB_Game values('",input$date3,"','",input$team3,"','", input$opp,"','", input$result3,"');", sep="")
    print(query)
    data <- dbGetQuery(db, query)
    output$text2 <- renderText({"Success! Inserted data"})
    
  })
  
  observeEvent(input$Go4, {
    # open DB connection
    db <- dbConnector(
      server   = getOption("database_server"),
      database = getOption("database_name"),
      uid      = getOption("database_userid"),
      pwd      = getOption("database_password"),
      port     = getOption("database_port")
    )
    on.exit(dbDisconnect(db), add = TRUE)
    
    #browser()
    query <- paste("update MLB_Game set Result='",input$result2, "' where Date like '%",input$date2,"%' and Team like '%",input$team2,"%';", sep="")
    print(query)
    data <- dbGetQuery(db, query)
    output$text1 <- renderText({"Success! Result is updated"})
    
  })
  
  observeEvent(input$Go5, {
    # open DB connection
    db <- dbConnector(
      server   = getOption("database_server"),
      database = getOption("database_name"),
      uid      = getOption("database_userid"),
      pwd      = getOption("database_password"),
      port     = getOption("database_port")
    )
    on.exit(dbDisconnect(db), add = TRUE)
    
    #browser()
    query <- paste("delete from MLB_Game where Date like '%",input$date4,"%' and Team like '%",input$team4,"%';", sep="")
    print(query)
    data <- dbGetQuery(db, query)
    output$text3 <- renderText({"Success! Deleted data"})
    
  })
  
  observeEvent(input$Go6, {
    # open DB connection
    db <- dbConnector(
      server   = getOption("database_server"),
      database = getOption("database_name"),
      uid      = getOption("database_userid"),
      pwd      = getOption("database_password"),
      port     = getOption("database_port")
    )
    on.exit(dbDisconnect(db), add = TRUE)
    
    #browser()
    query <- paste("select * from MLB_Team3")
    print(query)
    data1 <- dbGetQuery(db, query)
    output$Hist <- renderPlot({ggplot(data = data1, aes(x = Team, y = TotalPlayers, fill = TotalPlayers < median(TotalPlayers))) + geom_histogram(stat = "identity", show.legend = FALSE)})
    query2 <- paste("select MLB_Team3.Team, count(MLB_Game.Team) AS Wins from MLB_Team3, MLB_Game
    where MLB_Game.Team=MLB_Team3.Team and MLB_Game.Result like '%W%'
    group by MLB_Team3.Team;")
    print(query2)
    data2 <- dbGetQuery(db, query2)
    output$Wins <- renderPlot({ggplot(data = data2, aes(x = Team, y = Wins, fill = Wins > median(Wins))) + geom_histogram(stat = "identity", show.legend = FALSE)})
  })
  
}
shinyApp(ui, server)

