for (i in (1:length(x))) {
  cohortTableName <- paste0(stringr::str_squish("pl_"),
                            stringr::str_squish(x[[i]]$databaseId))
  
  # Details for connecting to the server:
  connectionDetails <-
    DatabaseConnector::createConnectionDetails(
      dbms = x[[i]]$cdmSource$dbms,
      server = x[[i]]$cdmSource$serverFinal,
      user = keyring::key_get(service = x[[i]]$userService),
      password =  keyring::key_get(service = x[[i]]$passwordService),
      port = x[[i]]$cdmSource$port
    )
  
  cohortTableNames <-
    CohortGenerator::getCohortTableNames(cohortTable = cohortTableName)
  
  try(CohortGenerator::dropCohortStatsTables(
    connectionDetails = connectionDetails,
    cohortDatabaseSchema = x[[i]]$cdmSource$cohortDatabaseSchemaFinal,
    cohortTableNames = cohortTableNames,
    dropCohortTable = TRUE
  ))
}
