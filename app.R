library(shiny)
library(DBI)
library(RPostgres)
library(bslib)

get_con <- function() {
  dbConnect(
    RPostgres::Postgres(),
    host = Sys.getenv("SUPABASE_HOST"),
    port = as.integer(Sys.getenv("SUPABASE_PORT")),
    dbname = Sys.getenv("SUPABASE_DB"),
    user = Sys.getenv("SUPABASE_USER"),
    password = Sys.getenv("SUPABASE_PASSWORD"),
    sslmode = "require"
  )
}

ui <- page_fluid(
  theme = bs_theme(
    version = 5,
    bootswatch = "flatly",
    primary = "#2C6E49",
    base_font = font_google("Inter")
  ),
  
  tags$head(
    tags$style(HTML("
      body {
        background-color: #F7F9FC;
      }
      .app-title {
        font-size: 2.1rem;
        font-weight: 700;
        margin-bottom: 0.3rem;
      }
      .app-subtitle {
        color: #5B6573;
        margin-bottom: 1.2rem;
      }
      .card-like {
        background: white;
        border-radius: 16px;
        padding: 20px 22px;
        box-shadow: 0 6px 18px rgba(0,0,0,0.06);
        margin-bottom: 18px;
      }
      .section-title {
        font-size: 1.25rem;
        font-weight: 700;
        margin-bottom: 12px;
      }
      .btn {
        border-radius: 12px !important;
      }
      .form-control, .form-select {
        border-radius: 12px !important;
      }
      .shiny-notification {
        border-radius: 12px;
      }
      table {
        background: white;
      }
    "))
  ),
  
  div(class = "app-title", "Park Quality Tracker"),
  div(class = "app-subtitle", "Submit park quality issues and monitor database summaries in near real time."),
  
  layout_columns(
    col_widths = c(4, 8),
    
    div(
      class = "card-like",
      div(class = "section-title", "Submit a New Report"),
      
      selectInput(
        "park_name",
        "Park",
        choices = c("Central Park", "Prospect Park", "Bryant Park", "Riverside Park")
      ),
      
      selectInput(
        "issue_type",
        "Issue Type",
        choices = c("Trash Overflow", "Trail Flooding", "Injury", "Playground Damage", "Restroom Cleanliness")
      ),
      
      numericInput(
        "severity",
        "Severity (1-5)",
        value = 3,
        min = 1,
        max = 5,
        step = 1
      ),
      
      textInput(
        "reported_by",
        "Reported By",
        value = ""
      ),
      
      textInput(
        "notes",
        "Notes",
        value = ""
      ),
      
      div(
        style = "display:flex; gap:10px; margin-top:12px;",
        actionButton("submit", "Submit Report", class = "btn-primary"),
        actionButton("refresh", "Refresh Dashboard", class = "btn-outline-secondary")
      )
    ),
    
    div(
      class = "card-like",
      div(class = "section-title", "Reports by Park"),
      tableOutput("park_counts")
    ),
    
    div(
      class = "card-like",
      div(class = "section-title", "Reports by Issue Type"),
      tableOutput("issue_counts")
    ),
    
    div(
      class = "card-like",
      div(class = "section-title", "Recent Reports"),
      tableOutput("recent_reports")
    )
  )
)

server <- function(input, output, session) {
  
  refresh_trigger <- reactiveVal(0)
  
  observeEvent(input$refresh, {
    refresh_trigger(refresh_trigger() + 1)
  })
  
  observeEvent(input$submit, {
    
    if (trimws(input$reported_by) == "") {
      showNotification("Please enter a name in Reported By.", type = "error")
      return()
    }
    
    con <- get_con()
    
    dbExecute(
      con,
      "
      INSERT INTO public.quality_reports
      (park_name, issue_type, severity, notes, reported_by)
      VALUES ($1, $2, $3, $4, $5)
      ",
      params = list(
        input$park_name,
        input$issue_type,
        input$severity,
        input$notes,
        input$reported_by
      )
    )
    
    dbDisconnect(con)
    
    showNotification("Report submitted successfully.", type = "message")
    
    updateTextInput(session, "reported_by", value = "")
    updateTextInput(session, "notes", value = "")
    
    refresh_trigger(refresh_trigger() + 1)
  })
  
  output$park_counts <- renderTable({
    refresh_trigger()
    
    con <- get_con()
    
    data <- dbGetQuery(
      con,
      "
      SELECT park_name, COUNT(*)::int AS reports
      FROM public.quality_reports
      GROUP BY park_name
      ORDER BY reports DESC
      "
    )
    
    dbDisconnect(con)
    data
  }, striped = TRUE, bordered = FALSE, spacing = "m", digits = 0)
  
  output$issue_counts <- renderTable({
    refresh_trigger()
    
    con <- get_con()
    
    data <- dbGetQuery(
      con,
      "
      SELECT issue_type, COUNT(*)::int AS reports
      FROM public.quality_reports
      GROUP BY issue_type
      ORDER BY reports DESC
      "
    )
    
    dbDisconnect(con)
    data
  }, striped = TRUE, bordered = FALSE, spacing = "m", digits = 0)
  
  output$recent_reports <- renderTable({
    refresh_trigger()
    
    con <- get_con()
    
    data <- dbGetQuery(
      con,
      "
      SELECT
        park_name,
        issue_type,
        severity,
        reported_by,
        notes,
        to_char(reported_at, 'YYYY-MM-DD HH24:MI:SS') AS reported_at
      FROM public.quality_reports
      ORDER BY reported_at DESC
      LIMIT 10
      "
    )
    
    dbDisconnect(con)
    data
  }, striped = TRUE, bordered = FALSE, spacing = "s")
}

shinyApp(ui, server)