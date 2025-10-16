# convert_to_sqlite.R
# Converts an RData or RDS file to a SQLite database

# Install required packages if not already installed
if (!requireNamespace("DBI", quietly = TRUE)) install.packages("DBI")
if (!requireNamespace("RSQLite", quietly = TRUE)) install.packages("RSQLite")

library(DBI)
library(RSQLite)

# Set your input and output file names here
input_file <- "input_data.RData"      # Change to your actual file name (can be .RData or .rds)
output_db  <- "output_database.sqlite"

# Connect to SQLite database (creates if it doesn't exist)
con <- dbConnect(RSQLite::SQLite(), output_db)

if (grepl("\\.RData$", input_file)) {
  load(input_file)
  # Get all objects in the environment
  objects <- ls()
  for (obj_name in objects) {
    obj <- get(obj_name)
    if (is.data.frame(obj)) {
      dbWriteTable(con, obj_name, obj, overwrite = TRUE)
    }
  }
} else if (grepl("\\.rds$", input_file)) {
  obj <- readRDS(input_file)
  if (is.data.frame(obj)) {
    dbWriteTable(con, "data", obj, overwrite = TRUE)
  } else {
    stop("The RDS file does not contain a data frame.")
  }
} else {
  stop("Unsupported file type. Please provide a .RData or .rds file.")
}

# List tables written to the database
print(dbListTables(con))

# Disconnect from the database
dbDisconnect(con)
