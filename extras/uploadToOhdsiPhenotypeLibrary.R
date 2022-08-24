# Using the official uploading functions to get data from zip files into the postgres database
library(CohortDiagnostics)
if (exists("listOfZipFilesToUpload")) {
  listOfZipFilesToUpload2 <- listOfZipFilesToUpload
  if (!exists("listOfZipFilesToUpload2")) {
    listOfZipFilesToUpload2 <- c()
  }
} else {
  listOfZipFilesToUpload <- c()
  listOfZipFilesToUpload2 <- c()
}

tablesInResultsDataModel <-
  CohortDiagnostics::getResultsDataModelSpecifications() |>
  dplyr::select(.data$tableName) |>
  dplyr::distinct() |>
  dplyr::arrange() |>
  dplyr::pull()

tablesInResultsDataModel <- c(tablesInResultsDataModel)

# Postgres server:
connectionDetails <- createConnectionDetails(
  dbms = Sys.getenv("shinydbDbms", unset = "postgresql"),
  server = paste(
    Sys.getenv("shinydbServer"),
    Sys.getenv("shinydbDatabase"),
    sep = "/"
  ),
  port = Sys.getenv("shinydbPort"),
  user = Sys.getenv("shinydbUser"),
  password = Sys.getenv("shinydbPW")
)
resultsSchema <- 'phenotypelibrary'
# 
# # commenting this function as it maybe accidentally run - loosing data.
# 
# # Drop All tables one by one - have you backed up annotation yet?
# ## Drop and replace schema - rarely used
# ## sqlDrop <-
# ##   "DROP SCHEMA IF EXISTS @results_database_schema CASCADE;  "
# ## DatabaseConnector::renderTranslateExecuteSql(
# ##   connection = DatabaseConnector::connect(connectionDetails = connectionDetails),
# ##   sql = sqlDrop,
# ##   results_database_schema = resultsSchema
# ## )
# ## 
# 
# ## sqlCreate <-
# ##   paste0("SELECT CREATE_SCHEMA('@results_database_schema');")
# ## DatabaseConnector::renderTranslateExecuteSql(
# ##   connection = DatabaseConnector::connect(connectionDetails = connectionDetails),
# ##   sql = sqlCreate,
# ##   results_database_schema = resultsSchema
# ## )
# 
# connection <-
#   DatabaseConnector::connect(connectionDetails = connectionDetails)
# for (i in (1:length(tablesInResultsDataModel))) {
#   # don't drop annotation tables as they are not loaded from source
#   isNotAnnotationTable <- stringr::str_detect(string = tablesInResultsDataModel[[i]],
#                                               pattern = "annotation",
#                                               negate = TRUE)
#   if (isNotAnnotationTable) {
#     writeLines(paste0("Dropping table ", tablesInResultsDataModel[[i]]))
#     DatabaseConnector::renderTranslateExecuteSql(
#       connection = connection,
#       sql = "DROP TABLE IF EXISTS @database_schema.@table_name CASCADE;",
#       database_schema = resultsSchema,
#       table_name = tablesInResultsDataModel[[i]]
#     )
#   }
# }
# 
# CohortDiagnostics::createResultsDataModel(connectionDetails = connectionDetails, schema = resultsSchema)
# 
# sqlGrant <-
#   "grant select on all tables in schema @results_database_schema to phenotypelibrary;"
# DatabaseConnector::renderTranslateExecuteSql(
#   connection = DatabaseConnector::connect(connectionDetails = connectionDetails),
#   sql = sqlGrant,
#   results_database_schema = resultsSchema
# )
# 
# sqlGrantTable <- "GRANT ALL ON  @results_database_schema.annotation TO  phenotypelibrary;
#                    GRANT ALL ON  @results_database_schema.annotation_link TO  phenotypelibrary;
#                    GRANT ALL ON  @results_database_schema.annotation_attributes TO  phenotypelibrary;"
# 
# DatabaseConnector::renderTranslateExecuteSql(
#   connection = DatabaseConnector::connect(connectionDetails = connectionDetails),
#   sql = sqlGrantTable,
#   results_database_schema = resultsSchema
# )

Sys.setenv("POSTGRES_PATH" = Sys.getenv('POSTGRES_PATH'))

folderWithZipFilesToUpload <- "D:\\studyResults\\PhenotypeLibraryDiagnostics\\"
listOfZipFilesToUpload <-
  list.files(
    path = folderWithZipFilesToUpload,
    pattern = ".zip",
    full.names = TRUE,
    recursive = TRUE
  )

listOfZipFilesToUpload <-
  setdiff(listOfZipFilesToUpload, listOfZipFilesToUpload2)
for (i in (1:length(listOfZipFilesToUpload))) {
  CohortDiagnostics::uploadResults(
    connectionDetails = connectionDetails,
    schema = resultsSchema,
    zipFileName = listOfZipFilesToUpload[[i]]
  )
}
listOfZipFilesToUpload2 <-
  c(listOfZipFilesToUpload, listOfZipFilesToUpload2) %>% unique() %>% sort()

# Maintenance
connection <-
  DatabaseConnector::connect(connectionDetails = connectionDetails)
for (i in (1:length(tablesInResultsDataModel))) {
  # vacuum
  DatabaseConnector::renderTranslateExecuteSql(
    connection = connection,
    sql = "VACUUM VERBOSE ANALYZE @database_schema.@table_name;",
    database_schema = resultsSchema,
    table_name = tablesInResultsDataModel[[i]]
  )
}

# CohortDiagnostics::launchDiagnosticsExplorer(connectionDetails = connectionDetails,
#                                              resultsDatabaseSchema = resultsSchema)
