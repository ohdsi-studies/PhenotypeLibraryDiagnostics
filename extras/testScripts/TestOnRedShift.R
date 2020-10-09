library(PhenotypeLibraryDiagnostics)

options(andromedaTempFolder = "s:/andromedaTemp")
maxCores <- parallel::detectCores()
oracleTempSchema <- NULL

# Details specific to CCAE:
connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "redshift",
                                                                connectionString = keyring::key_get("redShiftConnectionStringCcae"),
                                                                user = keyring::key_get("redShiftUserName"),
                                                                password = keyring::key_get("redShiftPassword"))
outputFolder <- "s:/phenotypeLibraryOutput/CCAE"
cdmDatabaseSchema <- "cdm"
cohortDatabaseSchema <- "scratch_mschuemi"
cohortTable <- "examplePackage_ccae"
databaseId <- "CCAE"
databaseName <- "IBM MarketScan Commercial Claims and Encounters Database"
databaseDescription <- "IBM MarketScan® Commercial Claims and Encounters Database (CCAE) represent data from individuals enrolled in United States employer-sponsored insurance health plans. The data includes adjudicated health insurance claims (e.g. inpatient, outpatient, and outpatient pharmacy) as well as enrollment data from large employers and health plans who provide private healthcare coverage to employees, their spouses, and dependents. Additionally, it captures laboratory tests for a subset of the covered lives. This administrative claims database includes a variety of fee-for-service, preferred provider organizations, and capitated health plans." 


# Details specific to MDCD:
connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "redshift",
                                                                connectionString = keyring::key_get("redShiftConnectionStringMdcd"),
                                                                user = keyring::key_get("redShiftUserName"),
                                                                password = keyring::key_get("redShiftPassword"))
outputFolder <- "s:/phenotypeLibraryOutput/mdcd"
cdmDatabaseSchema <- "cdm"
cohortDatabaseSchema <- "scratch_mschuemi2"
cohortTable <- "mschuemi_skeleton_mdcd"
databaseId <- "IBM_MDCD"
databaseName <- "IBM Health MarketScan® Multi-State Medicaid Database"
databaseDescription <- "Truven Health MarketScan® Multi-State Medicaid Database (MDCD) adjudicated US health insurance claims for Medicaid enrollees from multiple states and includes hospital discharge diagnoses, outpatient diagnoses and procedures, and outpatient pharmacy claims as well as ethnicity and Medicare eligibility. Members maintain their same identifier even if they leave the system for a brief period however the dataset lacks lab data. [For further information link to RWE site for Truven MDCD."

# Details specific to JMDC:
connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "redshift",
                                                                connectionString = keyring::key_get("redShiftConnectionStringJmdc"),
                                                                user = keyring::key_get("redShiftUserName"),
                                                                password = keyring::key_get("redShiftPassword"))
outputFolder <- "s:/phenotypeLibraryOutput/jmdc"
cdmDatabaseSchema <- "cdm"
cohortDatabaseSchema <- "scratch_mschuemi"
databaseId <- "JMDC"
databaseName <- "Japan Medical Data Center"
databaseDescription <- "Japan Medical Data Center (JDMC) database consists of data from 60 Society-Managed Health Insurance plans covering workers aged 18 to 65 and their dependents (children younger than 18 years old and elderly people older than 65 years old). JMDC data includes membership status of the insured people and claims data provided by insurers under contract (e.g. patient-level demographic information, inpatient and outpatient data inclusive of diagnosis and procedures, and prescriptions as dispensed claims information). Claims data are derived from monthly claims issued by clinics, hospitals and community pharmacies; for claims only the month and year are provided however prescriptions, procedures, admission, discharge, and start of medical care as associated with a full date.\nAll diagnoses are coded using ICD-10. All prescriptions refer to national Japanese drug codes, which have been linked to ATC. Procedures are encoded using local procedure codes, which the vendor has mapped to ICD-9 procedure codes. The annual health checkups report a standard battery of measurements (e.g. BMI), which are not coded but clearly described."

# connection <- connect(connectionDetails)
# executeSql(connection, sprintf("DROP TABLE %s.%s;", cohortDatabaseSchema, cohortTable))
# disconnect(connection)

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

CohortDiagnostics::preMergeDiagnosticsFiles(file.path(outputFolder, "diagnosticsExport"))

CohortDiagnostics::launchDiagnosticsExplorer(file.path(outputFolder, "diagnosticsExport"))

