# This file contains code to be used by the study coordinator to download the files from the SFTP server, and to upload them to the results database.

library(OhdsiSharing)
connection <- sftpConnect(privateKeyFileName = "c:/home/keyfiles/study-coordinator-pldiag",
                          userName = "study-coordinator-pldiag")
# sftpMkdir(connection, "phenotypeLibrary")



sftpDisconnect(connection)
