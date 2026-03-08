# Park Quality Tracker

**SYSEN 5460 – Data Science for Socio-Technical Systems Midterm Project**

## Overview

This project implements a lightweight data collection and monitoring tool for park maintenance issues. The application allows park staff to submit reports about quality or safety issues and view simple database summaries in near real time.

The system is built using **R Shiny** as the user interface and **Supabase PostgreSQL** as the cloud database backend. Reports submitted through the interface are written directly to the database and the dashboard queries the same database to display aggregated statistics and recent reports.

The goal of the project is to demonstrate how a small data application can support operational decision-making for public services such as park maintenance.

---

## Use Case

Park management teams often need a quick way to log issues observed in the field, such as safety concerns, infrastructure damage, or cleanliness problems.

This tool allows staff to:

Submit issue reports from different park locations
Track the frequency of issues by park
Track the frequency of issues by issue type
View the most recent reports submitted to the system

Although the data used in this project is synthetic, the structure reflects how a real operational tracking tool could work.

---

## System Architecture

The application has three main components.

### 1. User Interface (R Shiny)

The Shiny app provides a simple form for submitting issue reports. Users can select a park, choose the type of issue, assign a severity level, and provide optional notes.

### 2. Database (Supabase PostgreSQL)

All submitted reports are stored in a cloud PostgreSQL database hosted on Supabase. The application connects to the database using the `DBI` and `RPostgres` packages.

### 3. Dashboard Queries

The dashboard dynamically queries the database to display:

Counts of reports by park
Counts of reports by issue type
The ten most recent reports submitted

These queries update when new data is submitted.

---

## Application Features

The application includes the following functionality.

### Submit Issue Reports

Users can enter a new report through a simple form including:

Park name
Issue type
Severity level (1–5)
Reporter name
Optional notes

When the **Submit Report** button is clicked, the app inserts the data into the PostgreSQL database.

### View Summary Statistics

The dashboard automatically displays summary statistics including:

Number of reports by park
Number of reports by issue type

These statistics are generated using SQL aggregation queries.

### View Recent Reports

The app displays the ten most recent submissions from the database, allowing users to quickly review current activity.

---

## Database Schema

The application uses a single table.

### Table: `quality_reports`

| Column      | Type      | Description                       |
| ----------- | --------- | --------------------------------- |
| id          | BIGSERIAL | Unique identifier for each report |
| park_name   | TEXT      | Name of the park                  |
| issue_type  | TEXT      | Category of issue                 |
| severity    | INTEGER   | Issue severity (1–5)              |
| notes       | TEXT      | Optional description of the issue |
| reported_by | TEXT      | Name or role of the reporter      |
| reported_at | TIMESTAMP | Time the report was submitted     |

---

## Required Environment Variables

Database credentials are stored in environment variables rather than in the code to prevent exposing sensitive information.

The following variables must be defined in `.Renviron`:

```
SUPABASE_HOST
SUPABASE_PORT
SUPABASE_DB
SUPABASE_USER
SUPABASE_PASSWORD
```

Example configuration:

```
SUPABASE_HOST=aws-0-us-west-2.pooler.supabase.com
SUPABASE_PORT=5432
SUPABASE_DB=postgres
SUPABASE_USER=postgres.projectref
SUPABASE_PASSWORD=your_database_password
```

After editing `.Renviron`, restart the R session for the variables to take effect.

---

## Installation

Install the required R packages:

```r
install.packages(c(
  "shiny",
  "DBI",
  "RPostgres",
  "bslib"
))
```

---

## Running the Application

After setting environment variables and installing dependencies, run the application with:

```r
shiny::runApp()
```

The Shiny interface will open in the browser.

---

## Project Structure

```
project-folder
│
├── app.R
├── README.md
├── codebook.md
└── .gitignore
```

### Files

**app.R**
Main Shiny application containing the UI and server logic.

**README.md**
Project description and instructions.

**codebook.md**
Documentation describing the database schema and variables.

**.gitignore**
Ensures sensitive files such as `.Renviron` are not uploaded to GitHub.

---

## Security Notes

Database credentials are never stored directly in the code.
The `.Renviron` file containing credentials is excluded from version control using `.gitignore`.

This allows other users to run the application by supplying their own database credentials.

---

## Possible Extensions

Future improvements could include:

Adding interactive visualizations (e.g., charts using `plotly`)
Mapping park locations using geographic coordinates
Allowing filtering by date range or severity level
Adding authentication for different staff roles

These features would help expand the system into a more complete park operations dashboard.

---

## Author

Selena Miao
Cornell University
SYSEN 5460 – Data Science for Socio-Technical Systems

---

