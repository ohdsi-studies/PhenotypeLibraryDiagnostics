# install.packages("DatabaseConnector")
# remotes::install_github("ohdsi/CohortDiagnostics")

# where are the cohort diagnostics output?
folderWithZipFilesToUpload <- "D:\\studyResults\\PhenotypeLibraryDiagnostics\\"

# what is the name of the schema you want to upload to?
resultsSchema <- 'phenotypelibrary' # change to your schema

# Postgres server: connection details to OHDSI Phenotype library. Please change to your postgres connection details
connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = Sys.getenv("shinydbDbms", unset = "postgresql"),
  server = paste(
    Sys.getenv("phenotypeLibraryServer"),
    Sys.getenv("phenotypeLibrarydb"),
    sep = "/"
  ),
  port = Sys.getenv("phenotypeLibraryDbPort"),
  user = Sys.getenv("phenotypeLibrarydbUser"),
  password = Sys.getenv("phenotypeLibrarydbPw")
)


# trying to keep track of files that were recently uploaded in current R session
if (exists("listOfZipFilesToUpload")) {
  listOfZipFilesToUpload2 <- listOfZipFilesToUpload
  if (!exists("listOfZipFilesToUpload2")) {
    listOfZipFilesToUpload2 <- c()
  }
} else {
  listOfZipFilesToUpload <- c()
  listOfZipFilesToUpload2 <- c()
}

# reading the tables in cohort diagnostics results data model
tablesInResultsDataModel <-
  CohortDiagnostics::getResultsDataModelSpecifications() |>
  dplyr::select(.data$tableName) |>
  dplyr::distinct() |>
  dplyr::arrange() |>
  dplyr::pull()
tablesInResultsDataModel <- c(tablesInResultsDataModel)


# back up annotation tables
# annotationTables <- tablesInResultsDataModel[stringr::str_detect(string = tablesInResultsDataModel,
#                                                                  pattern = "annotation")]
# 
# connection = DatabaseConnector::connect(connectionDetails = connectionDetails)
# for (i in (1:length(annotationTables))) {
#   writeLines(paste0("Backing up ", annotationTables[[i]]))
#   data <- DatabaseConnector::renderTranslateQuerySql(
#     connection = connection,
#     sql = "SELECT * FROM @results_database_schema.@annotation_table;",
#     results_database_schema = resultsSchema, 
#     annotation_table = annotationTables[[i]],
#     snakeCaseToCamelCase = TRUE
#   ) |> 
#     dplyr::tibble() |> 
#     dplyr::arrange(1)
#   assign(x = annotationTables[[i]],
#          value = data)
#   readr::write_excel_csv(x = get(annotationTables[[i]]), 
#                          file = file.path(rstudioapi::getActiveDocumentContext()$path |> dirname(),
#                                           paste0(annotationTables[[i]], ".csv")), 
#                          append = FALSE)
# }
# DatabaseConnector::disconnect(connection = connection)

# 
# # commenting this function as it maybe accidentally run - loosing data.
# 
# # Drop All tables one by one - have you backed up annotation yet?
# ## Drop and replace schema - rarely used
# sqlDrop <-
#   "DROP SCHEMA IF EXISTS @results_database_schema CASCADE;  "
# DatabaseConnector::renderTranslateExecuteSql(
#   connection = DatabaseConnector::connect(connectionDetails = connectionDetails),
#   sql = sqlDrop,
#   results_database_schema = resultsSchema
# )
# 
# sqlCreate <-
#   paste0("SELECT CREATE_SCHEMA('@results_database_schema');")
# DatabaseConnector::renderTranslateExecuteSql(
#   connection = DatabaseConnector::connect(connectionDetails = connectionDetails),
#   sql = sqlCreate,
#   results_database_schema = resultsSchema
# )
connection <-
  DatabaseConnector::connect(connectionDetails = connectionDetails)
for (i in (1:length(tablesInResultsDataModel))) {
  writeLines(paste0("Dropping table ", tablesInResultsDataModel[[i]]))
  DatabaseConnector::renderTranslateExecuteSql(
    connection = connection,
    sql = "DROP TABLE IF EXISTS @database_schema.@table_name CASCADE;",
    database_schema = resultsSchema,
    table_name = tablesInResultsDataModel[[i]]
  )
}

CohortDiagnostics::createResultsDataModel(connectionDetails = connectionDetails, databaseSchema = resultsSchema)

sqlGrant <-
  "grant select on all tables in schema @results_database_schema to phenotypelibrary;"
DatabaseConnector::renderTranslateExecuteSql(
  connection = DatabaseConnector::connect(connectionDetails = connectionDetails),
  sql = sqlGrant,
  results_database_schema = resultsSchema
)

sqlGrantTable <- "GRANT ALL ON  @results_database_schema.annotation TO  phenotypelibrary;
                  GRANT ALL ON  @results_database_schema.annotation_link TO  phenotypelibrary;
                  GRANT ALL ON  @results_database_schema.annotation_attributes TO  phenotypelibrary;"

DatabaseConnector::renderTranslateExecuteSql(
  connection = DatabaseConnector::connect(connectionDetails = connectionDetails),
  sql = sqlGrantTable,
  results_database_schema = resultsSchema
)

Sys.setenv("POSTGRES_PATH" = Sys.getenv('POSTGRES_PATH'))

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
  c(listOfZipFilesToUpload, listOfZipFilesToUpload2) |>  unique() |> sort()


# reupload annotation tables
# connection = DatabaseConnector::connect(connectionDetails = connectionDetails)
# for (i in (1:length(annotationTables))) {
#   if (!exists(annotationTables[[i]])) {
#     if (file.exists(file.path(rstudioapi::getActiveDocumentContext()$path |> dirname(),
#                               paste0(annotationTables[[i]], ".csv")))) {
#       data <-
#         readr::read_csv(
#           file = file.path(
#             rstudioapi::getActiveDocumentContext()$path |> dirname(),
#             paste0(annotationTables[[i]], ".csv")
#           ),
#           col_types = readr::cols()
#         )
#       assign(x = annotationTables[[i]],
#              value = data)
#     } else {
#       writeLines(paste0("Annotation table not found: ", paste0(annotationTables[[i]], ".csv")))
#     }
#   }
#   
#   if (exists(annotationTables[[i]])) {
#     DatabaseConnector::renderTranslateExecuteSql(connection = connection,
#                                                  sql = "DELETE FROM @results_database_schema.@annotation_table;",
#                                                  results_database_schema = resultsSchema, 
#                                                  annotation_table = annotationTables[[i]])
#     DatabaseConnector::insertTable(
#       connection = connection,
#       databaseSchema = resultsSchema,
#       tableName = annotationTables[[i]],
#       dropTableIfExists = FALSE,
#       createTable = FALSE,
#       data = get(annotationTables[[i]])|> dplyr::distinct(),
#       tempTable = FALSE,
#       bulkLoad = (Sys.getenv("bulkLoad") == TRUE),
#       camelCaseToSnakeCase = TRUE
#     )
#   }
# }
# DatabaseConnector::disconnect(connection = connection)

# Maintenance

for (i in (1:length(tablesInResultsDataModel))) {
  # vacuum
  try(if (DatabaseConnector::existsTable(
    connection = connection,
    databaseSchema = resultsSchema,
    tableName = tablesInResultsDataModel[[i]]
  )) {
    DatabaseConnector::renderTranslateExecuteSql(
      connection = connection,
      sql = "VACUUM VERBOSE ANALYZE @database_schema.@table_name;",
      database_schema = resultsSchema,
      table_name = tablesInResultsDataModel[[i]]
    )
  })
  
}

# CohortDiagnostics::launchDiagnosticsExplorer(connectionDetails = connectionDetails,
#                                              resultsDatabaseSchema = resultsSchema)
