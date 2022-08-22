source(Sys.getenv("startUpScriptLocation"))

######
executeOnMultipleDataSources <- function(x) {
  library(magrittr)
  if (x$generateCohortTableName) {
    cohortTableName <- paste0(stringr::str_squish("_pl"),
                              stringr::str_squish(x$databaseId))
  }
  
  # this function gets details of the data source from cdm source table in omop, if populated.
  # The assumption is the cdm_source.sourceDescription has text description of data source.
  
  # Details for connecting to the server:
  connectionDetails <-
    DatabaseConnector::createConnectionDetails(
      dbms = x$cdmSource$dbms,
      server = x$cdmSource$server,
      user = keyring::key_get(service = x$userService),
      password =  keyring::key_get(service = x$passwordService),
      port = x$cdmSource$port
    )
  # The name of the database schema where the CDM data can be found:
  cdmDatabaseSchema <- x$cdmSource$cdmDatabaseSchema
  vocabDatabaseSchema <- x$cdmSource$vocabDatabaseSchema
  cohortDatabaseSchema <- x$cdmSource$cohortDatabaseSchema
  
  databaseId <- x$databaseId
  databaseName <- x$databaseName
  databaseDescription <- x$databaseDescription
  
  PhenotypeLibraryDiagnostics::executePhenotyeLibraryDiagnostics(
    connectionDetails = connectionDetails,
    cdmDatabaseSchema = cdmDatabaseSchema,
    cohortDatabaseSchema = cohortDatabaseSchema,
    cohortTable = cohortTableName,
    verifyDependencies = x$verifyDependencies,
    outputFolder = x$outputFolder,
    databaseId = databaseId,
    databaseName = databaseName,
    databaseDescription = databaseDescription
  )
}
