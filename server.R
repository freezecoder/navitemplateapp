library(shiny)
library(htmltools)
library(shinydashboard)

##Custom navbarpage
navbarPageWithText <- function(..., text,inputs) {
  navbar <- navbarPage(...)
  textEl <- tags$p(class = "navbar-text", text)
  form <- tags$form(class = "navbar-form", inputs)
  navbar[[3]][[1]]$children[[1]] <- htmltools::tagAppendChild(
    navbar[[3]][[1]]$children[[1]], textEl)
  navbar[[3]][[1]]$children[[1]] <- htmltools::tagAppendChild(
    navbar[[3]][[1]]$children[[1]], form)
  navbar
}

dashpage <-function(){
  dashboardPage(
  dashboardHeader(title = "Simple tabs"),
  dashboardSidebar(
    sidebarMenu(
      id = "tabs",
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Widgets", tabName = "widgets", icon = icon("th"))
    ),
    actionButton('switchtab', 'Switch tab')
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "dashboard",
              h2("Dashboard tab content")
      ),
      tabItem(tabName = "widgets",
              h2("Widgets tab content")
      )
    )
  )
)
}

#The login page
loginpage<-function(){
  fluidPage("NaviApp",
          div(class="jumbotron",style="align:center;",
              h3("Welcome. Please log in"),
              textInput("userName","Username"),
              textInput("passwd","Password"),
              actionButton("logmein","Login")
          )
)
}

#the main UI page
loggedinpage<-function(){
  navbarPageWithText(div("NaviApp"),id="nv",
                                  footer=div(htmlOutput("breadcrumb")),
                                  text=div(class="badge","User: Albert"),
                                  inputs="",
                                  # inputs=textInput("globalsearch", NULL, "Search"),
                                  tabPanel(value="main","Samples",
                                           div(class="jumbotron",p("Tab 1. The main entry point showing the most top-level data. Information is high level and terse. Links to details will be provided")),
                                           dataTableOutput("iris_type")
                                  ),
                                  tabPanel(value="details","Details",
                                           div(class="jumbotron",
                                               "This would show some details of the selected item in first tab"), 
                                           dataTableOutput("filtered_data")
                                  ),
                                  tabPanel(value="analysis","Analysis",
                                           div(class="jumbotron","This would show some detailed analysis of stuff")
                                  ),
                                  tabPanel(value="about","About",
                                           div(class="jumbotron",p("This app shows navigation within a shiny app using links in a Data table.
                                                                   On clicking of the link the filtered set is refreshed.
                                                                   This app can serve as a base framework for more hierachichal navigation apps 
                                                                   "))
                                           )
                                  
                                           )
}

#Server code (goes in server.R)
server <- function(input, output,session) {
  
  #Authentication
  output$theapp<-renderUI({
    logged=1
    uname=isolate(input$userName)
    pwd=isolate(input$passwd)
    if (logged==1) {
      loggedinpage()
     # dashpage()
    }else {
      loginpage()
    }
  })
  
  #UI Outputs
  output$iris_type <- renderDataTable({
    foo=data.frame(Species=paste0("<a href='#details'>", unique(iris$Species), "</a>"))
    foo$other=2343
    foo
  },escape=F,
  callback = "function(table) {
  table.on('click.dt', 'tr', function() {
  Shiny.onInputChange('rows', table.row( this ).index());
  var tabs = $('.tabbable .nav.nav-tabs li a'); // this part updates the tab to index 1
  var navtabs=$('.navbar  li a');
  //$(navtabs[1]).click();
  });
}")
  output$filtered_data <- renderDataTable({
    if(is.null(input$rows)){
      iris
    }else{
      iris[iris$Species %in% unique(iris$Species)[as.integer(input$rows)+1], ]
    }
    },escape=F)
  
  
  #Change tab based on item clicked in table
  observeEvent(input$rows, {
    row <- input$rows 
    updateNavbarPage(session, "nv", selected = "details")
    print("navigating to details")
  })  
  
  #change dashboard tab
  observeEvent(input$switchtab, {
    newtab <- switch(input$tabs,
                     "dashboard" = "widgets",
                     "widgets" = "dashboard"
    )
    updateTabItems(session, "tabs", newtab)
  })
  
  
  output$breadcrumb<-renderText({
      paste(div(class="badge",input$nv))
  })
  
  }
