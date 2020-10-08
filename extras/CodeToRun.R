library(PhenotypeLibraryDiagnostics)

# Optional: specify where the temporary files will be created:
options(andromedaTempFolder = "s:/andromedaTemp")

# Maximum number of cores to be used:
maxCores <- parallel::detectCores()

# Details for connecting to the server:
connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "pdw",
                                                                server = keyring::key_get("pdwServer"),
                                                                user = NULL,
                                                                password = NULL,
                                                                port = keyring::key_get("pdwPort"))

# For Oracle: define a schema that can be used to emulate temp tables:
oracleTempSchema <- NULL

# Provide data-base specific information here
outputFolder <- "s:/PhenotypeLibraryDiagnosticsOutput/ccae"
cdmDatabaseSchema <- "CDM_IBM_CCAE_V1247.dbo"
cohortDatabaseSchema <- "scratch.dbo"
cohortTable <- "mschuemi_skeleton_ccae"
databaseId <- "CCAE"
databaseName <- "IBM MarketScan Commercial Claims and Encounters Database"
databaseDescription <- "IBM MarketScan® Commercial Claims and Encounters Database (CCAE) represent data from individuals enrolled in United States employer-sponsored insurance health plans. The data includes adjudicated health insurance claims (e.g. inpatient, outpatient, and outpatient pharmacy) as well as enrollment data from large employers and health plans who provide private healthcare coverage to employees, their spouses, and dependents. Additionally, it captures laboratory tests for a subset of the covered lives. This administrative claims database includes a variety of fee-for-service, preferred provider organizations, and capitated health plans." 

# For uploading the results. You should have received the key file from the study coordinator:
keyFileName <- "c:/home/keyFiles/study-data-site-pldiag.dat"
userName <- "study-data-site-pldiag"

# Use this to run the cohort diagnostics. The results will be stored in the diagnosticsExport subfolder of the outputFolder. This can be shared between sites.
runPhenotypeLibraryDiagnostics(connectionDetails = connectionDetails,
                               cdmDatabaseSchema = cdmDatabaseSchema,
                               cohortDatabaseSchema = cohortDatabaseSchema,
                               cohortTable = cohortTable,
                               oracleTempSchema = oracleTempSchema,
                               outputFolder = outputFolder,
                               databaseId = databaseId,
                               databaseName = databaseName,
                               databaseDescription = databaseDescription,
                               createCohorts = TRUE,
                               runInclusionStatistics = TRUE,
                               runTimeDistributions = TRUE,
                               runBreakdownIndexEvents = TRUE,
                               runIncidenceRates = TRUE,
                               runCohortOverlap = TRUE,
                               runCohortCharacterization = TRUE,
                               runTemporalCohortCharacterization = TRUE,
                               minCellCount = 5)

# (Optionally) to view the results locally:
CohortDiagnostics::preMergeDiagnosticsFiles(file.path(outputFolder, "diagnosticsExport"))

CohortDiagnostics::launchDiagnosticsExplorer(file.path(outputFolder, "diagnosticsExport"))

# Upload results to OHDSI SFTP server:
uploadResults(outputFolder, keyFileName, userName)
