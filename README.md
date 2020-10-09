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

# How to install the `PhenotypeLibraryDiagnostics` study package

There are several ways in which one could install the `PhenotypeLibraryDiagnostics` package. However, we recommend using the `renv` package:

1. See the instructions [here](https://ohdsi.github.io/Hades/rSetup.html) for configuring your R environment, including Java and RStudio.

2. In RStudio, create a new project. If asked if you want to use `renv` with the project, answer ‘no’.

3. Execute the following R code:

```r
# Install the latest version of renv:
install.packages("renv")

# Download the lock file:
download.file("https://raw.githubusercontent.com/ohdsi-studies/PhenotypeLibraryDiagnostics/master/renv.lock", "renv.lock")
  
# Build the local library. This may take a while:
renv::init()
```

# How to run the `PhenotypeLibraryDiagnostics` study package

To do

