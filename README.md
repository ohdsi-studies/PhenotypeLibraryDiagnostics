Phenotype Library Diagnostics
=============================

<img src="https://img.shields.io/badge/Study%20Status-Started-blue.svg" alt="Study Status: Started">

- Analytics use case(s): **Characterization**
- Study type: **Clinical Application**
- Tags: **-**
- Study lead: **Gowtham Rao**
- Study lead forums tag: **[gowtham_rao](https://forums.ohdsi.org/u/gowtham_rao)**
- Study start date: **October 8, 2020**
- Study end date: **-**
- Protocol: **-**
- Publications: **-**
- Results explorer: **-**

Generating cohort diagnostics for the cohort definitions in the OHDSI Phenotype Library.

# Development status

Under development. Do not use.

# Instructions for installing and running the study package

Below are the instructions for installing and then running the package. For your convience, you can also find this code in [extras/CodeTorun.R](https://github.com/ohdsi-studies/PhenotypeLibraryDiagnostics/blob/master/extras/CodeToRun.R).

## How to install the study package

There are several ways in which one could install the `PhenotypeLibraryDiagnostics` package. However, we recommend using the `renv` package:

1. See the instructions [here](https://ohdsi.github.io/Hades/rSetup.html) for configuring your R environment, including Java and RStudio.

2. In RStudio, create a new project: File -> New Project... -> New Directory -> New Project. If asked if you want to use `renv` with the project, answer ‘no’.

3. Execute the following R code:

```r
# Install the latest version of renv:
install.packages("renv")

# Download the lock file:
download.file("https://raw.githubusercontent.com/ohdsi-studies/PhenotypeLibraryDiagnostics/master/renv.lock", "renv.lock")
  
# Build the local library. This may take a while:
renv::init()
```

## How to run the study package

1. Edit the script below to ensure that the variables contain the correct values for your environment, then execute:

```r
library(PhenotypeLibraryDiagnostics)

# Specify where the temporary files will be created:
options(andromedaTempFolder = "s:/andromedaTemp")

# Maximum number of cores to be used:
maxCores <- parallel::detectCores()

# Details for connecting to the server. See 
# http://ohdsi.github.io/DatabaseConnector/reference/createConnectionDetails.html for more details:
connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "postgresql",
                                                                server = "localhost/ohdsi",
                                                                user = "joe",
                                                                password = "secret",
                                                                port = 5432)

# For Oracle and BigQuery: define a schema that can be used to emulate temp tables. 
# You should have write access to this schema:
oracleTempSchema <- NULL

# A folder on the local file system to store results:
outputFolder <- "s:/PhenotypeLibraryDiagnosticsOutput"

# The database schema where the observational data in CDM is located. For SQL Server
# this should include both the database and schema, for example 'cdm.dbo'.
# You should have read access to this schema:
cdmDatabaseSchema <- "cdm"

# The database schema where the cohorts can be instantiated. For SQL Server
# this should include both the database and schema, for example 'cdm.dbo'.
# You should have write access to this schema:
cohortDatabaseSchema <- "scratch.dbo"

# The name of the table that will be created in the cohortDatabaseSchema:
cohortTable <- "pl_cohort"

# Some meta-data about your database. The databaseId is a short (<= 20 characters)
# name for your database. The databaseName is the full name, and databaseDescription 
# provides a short (1 paragraph) description. These values will be displayed in the 
# Shiny results app for all to see.
databaseId <- "CCAE"
databaseName <- "IBM MarketScan Commercial Claims and Encounters Database"
databaseDescription <- "IBM MarketScan® Commercial Claims and Encounters Database (CCAE) represent data from individuals enrolled in United States employer-sponsored insurance health plans. The data includes adjudicated health insurance claims (e.g. inpatient, outpatient, and outpatient pharmacy) as well as enrollment data from large employers and health plans who provide private healthcare coverage to employees, their spouses, and dependents. Additionally, it captures laboratory tests for a subset of the covered lives. This administrative claims database includes a variety of fee-for-service, preferred provider organizations, and capitated health plans." 

# For uploading the results. You should have received the key file from the study coordinator:
keyFileName <- "c:/home/keyFiles/study-data-site-pldiag.dat"
userName <- "study-data-site-pldiag"

# This statement instatiates the cohorts, performs the diagnostics, and writes the results to
# a zip file containing CSV files. This will probaby take a long time to run:
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
```

## Sharing the results with the study coordinator

1. Upload results to the OHDSI SFTP server:

```r

uploadResults(outputFolder, keyFileName, userName)
```

