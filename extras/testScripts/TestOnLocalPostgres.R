library(PhenotypeLibraryDiagnostics)

options(andromedaTempFolder = "s:/andromedaTemp")
maxCores <- parallel::detectCores()
oracleTempSchema <- NULL

connectionDetails <- createConnectionDetails(dbms = "postgresql",
                                             server = "localhost/ohdsi",
                                             user = "postgres",
                                             password = Sys.getenv("pwPostgres"))
outputFolder <- "s:/phenotypeLibraryOutput/Synpuf"
cdmDatabaseSchema <- "cdm_synpuf"
cohortDatabaseSchema <- "scratch"
cohortTable <- "cd_cohort"
databaseId <- "Synpuf"
databaseName <- "Centers for Medicare and Medicaid Services (CMS) Medicare Claims Synthetic Public Use Files (SynPUF)"
databaseDescription <- "The CMS Linkable 2008–2010 Medicare DE-SynPUF originated from a disjoint (mutually exclusive from existing samples) 5% random sample of beneficiaries from the 100% Beneficiary Summary File for 2008. To exclude any overlap with the beneficiaries in the existing 5% CMS research sample, 3 the beneficiaries in that other sample were excluded, and a 5-in-95 random draw was made with the remaining 95% of beneficiaries. A variety of statistical disclosure limitation techniques were used to protect the confidentiality of Medicare beneficiaries in the CMS Linkable 2008–2010 Medicare DE-SynPUF. The DE-SynPUF was created by starting with an actual beneficiary as a “seed” for a synthetic beneficiary. Synthetic beneficiaries and their claims are based on actual seed beneficiaries. Disclosure is reduced through multiple deterministically or stochastically applied treatment mechanisms. First, hot decking based procedures are used to find donors for beneficiary-level variables and individual claims. Second, other synthetic processes are used to protect other elements of the data. Disclosure limitation methods used in the process include variable reduction, suppression, substitution, synthesis, date perturbation, and coarsening. Please refer to the CMS Linkable 2008–2010 Medicare Data Entrepreneurs’ Synthetic Public Use File (DE-SynPUF) User Manual for details regarding how DE-SynPUF was created."

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

