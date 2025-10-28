# Tronador Gist Files

This directory contains files that can be uploaded to GitHub Gist for easy distribution and inclusion in projects.

## .tronador

This is the base Makefile that users can include in their projects to get access to all Tronador DevOps Accelerator features.

### How to Upload to GitHub Gist

1. Go to https://gist.github.com/
2. Create a new gist with the filename `.tronador`
3. Copy the contents of this file into the gist
4. Make the gist public
5. After creating the gist, note the Gist ID from the URL
6. Update the usage instructions in README.yaml with the actual Gist ID

### Usage

Once uploaded to a GitHub Gist, users can include it in their Makefile with:

```make
-include $(shell curl -sSL -o .tronador "https://gist.githubusercontent.com/cloudopsworks/GIST_ID/raw/.tronador"; echo .tronador)
```

Replace `GIST_ID` with the actual Gist ID.

### Alternative

Users can also use the short URL if configured:

```make
-include $(shell curl -sSL -o .tronador "https://cowk.io/acc"; echo .tronador)
```
