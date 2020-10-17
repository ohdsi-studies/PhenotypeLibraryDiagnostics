# This file contains code to be used by the study coordinator to download the files from the SFTP server, and to upload them to the results database.

library(OhdsiSharing)

localFolder <- "s:/PhenotypeLibraryResults"
# dir.create(localFolder)

# Download files from SFTP server -----------------------------------------------------------------
connection <- sftpConnect(privateKeyFileName = "c:/home/keyfiles/study-coordinator-pldiag.dat",
                          userName = "study-coordinator-pldiag")

# sftpMkdir(connection, "phenotypeLibrary")

sftpCd(connection, "phenotypeLibrary")
files <- sftpLs(connection)
files

sftpGetFiles(connection, files$fileName, localFolder = localFolder)

# DANGER!!! Remove files from server:
sftpRm(connection, files$fileName)

sftpDisconnect(connection)


# Test results locally -----------------------------------------------------------------------------------
CohortDiagnostics::preMergeDiagnosticsFiles(localFolder)
CohortDiagnostics::launchDiagnosticsExplorer(localFolder)

# Upload results to database -----------------------------------------------------------------------
library(DatabaseConnector)
connectionDetails <- createConnectionDetails(dbms = "postgresql",
                                             server = paste(Sys.getenv("phenotypeLibraryDbServer"),
                                                            Sys.getenv("phenotypeLibraryDbDatabase"),
                                                            sep = "/"),
                                             port = Sys.getenv("phenotypeLibraryDbPort"),
                                             user = Sys.getenv("phenotypeLibraryDbUser"),
                                             password = Sys.getenv("phenotypeLibraryDbPassword"))
resultsSchema <- Sys.getenv("phenotypeLibraryDbResultsSchema")

# Only the first time:
# CohortDiagnostics::createResultsDataModel(connectionDetails = connectionDetails, schema = resultsSchema)

uploadedFolder <- file.path(localFolder, "uploaded")
if (!file.exists(uploadedFolder)) {
  dir.create(uploadedFolder)
}
zipFilesToUpload <- list.files(path = localFolder, 
                               pattern = ".zip", 
                               recursive = FALSE)

for (i in (1:length(zipFilesToUpload))) {
  CohortDiagnostics:: uploadResults(connectionDetails = connectionDetails,
                schema = resultsSchema,
                zipFileName = file.path(localFolder, zipFilesToUpload[i]))
  # Move to uploaded folder:
  file.rename(file.path(localFolder, zipFilesToUpload[i]), file.path(uploadedFolder, zipFilesToUpload[i]))
}

# Only after the first time:
# CohortDiagnostics::uploadPrintFriendly(connectionDetails = connectionDetails,
#                                        schema = resultsSchema)

# Grant rights to all:
# connection <- connect(connectionDetails)
# specs <- CohortDiagnostics::getResultsDataModelSpecifications()
# tablesInSpecs <- c(unique(specs$tableName), "cohort_extra")
# tablesOnServer <- getTableNames(connection, "results")
# myTables <-  tablesInSpecs[tablesInSpecs%in% tolower(tablesOnServer)]
# for (table in myTables) {
#   print(table)
#   sql <- sprintf("GRANT ALL PRIVILEGES ON %s.%s TO rw_grp;", "results", table)
#   sql <- sprintf("GRANT ALL PRIVILEGES ON %s.%s TO phoebe;", "results", table)
#   executeSql(connection, sql, progressBar = FALSE, reportOverallTime = FALSE)
# }
# disconnect(connection)

CohortDiagnostics::launchDiagnosticsExplorer(connectionDetails = connectionDetails,
                                             resultsDatabaseSchema = resultsSchema,
                                             vocabularyDatabaseSchema = "vocabulary")
