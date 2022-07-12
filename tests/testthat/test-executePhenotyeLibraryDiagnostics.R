library(testthat)
testthat::test_that("Testing if package can execute", {
  # generate unique name for a cohort table
  sysTime <- as.numeric(Sys.time()) * 100000
  tableName <- paste0("cr", sysTime)
  tempTableName <- paste0("#", tableName, "_1")
  
  folder <- tempfile()
  dir.create(folder, recursive = TRUE)
  
  connectionDetails <- Eunomia::getEunomiaConnectionDetails()
  PhenotypeLibraryDiagnostics::executePhenotyeLibraryDiagnostics(
      connectionDetails = connectionDetails, 
      cdmDatabaseSchema = "main", 
      vocabularyDatabaseSchema = "main", 
      cohortDatabaseSchema = "main", 
      cohortTable = tempTableName,
      outputFolder = folder
  )
  
  unlink(x = folder, recursive = TRUE, force = TRUE)
})
