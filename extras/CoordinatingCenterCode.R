# This file contains code to be used by the study coordinator to download the files from the SFTP server, and to upload them to the results database.

library(OhdsiSharing)

localFolder <- "s:/PhenotypeLibraryResults"
# dir.create(localFolder)

# Download files from SFTP server -----------------------------------------------------------------
connection <- sftpConnect(privateKeyFileName = "c:/home/keyfiles/study-coordinator-pldiag",
                          userName = "study-coordinator-pldiag")

# sftpMkdir(connection, "phenotypeLibrary")

sftpCd(connection, "phenotypeLibrary")
files <- sftpLs(connection)
files

sftpGetFiles(connection, files$fileName, localFolder = localFolder)

# DANGER!!! Remove files from server:
sftpRm(connection, files$fileName)

sftpDisconnect(connection)


# Upload results to database -----------------------------------------------------------------------

# TODO
