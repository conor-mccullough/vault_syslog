# How-To

This provisions a standalone Vault instance with a Raft back-end. 

`bootstrap.sh` automatically configures, initialises and unseals Vault, so it should be ready to go out of the box.

Each value marked 'CHANGEME' needs to be modified prior to running:

1. A license key needs to be added
2. You need to actually create the key in AWS
3. The path needs to be updated to point towards the location of the key on your local machine


