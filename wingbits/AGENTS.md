Read the README.md file for full information.

The wingbits software has 2 containers:
- ultrafeeder: from the ultrafeeder project, untouched except for the configuration
- wingbits: custom built and pushed to Docker Hub

ultrafeeder read data from an ADSB device and sends it ONLY to the wingbits container using the BEAST protocol.
wingbits receives that data, processes it, and publishes it to the wingbits API.

The wingbits container also manages a secure GPS device ("GeoSigner"), and needs a config to bind the data to the user owning the device.

# Wingbits Container
The docker file is in this folder "dockerfile".
The docker container is built and published to Docker Hub using the GitHub Action .github/workflows/build-wingbits-docker.yaml

# Supported OS and Architectures for the containers
- debian linux (latest version) / raspberry pi os (latest version)
- arm64
- amd64

# Original wingbits installer

Login on wingbits.com, select a station, in the menu choose BYOD install.

It will gives you a linux command like this:
`curl -sL https://gitlab.com/wingbits/config/-/raw/master/download.sh | sudo loc="x.xxxxxx, x.xxxxxx" id="XXXXXXXXXX" bash`

So the original installer is a bash script which is available at https://gitlab.com/wingbits/config/-/raw/master/download.sh

## Differences with the original installer

### Features not activated

#### Using GeoSigner ID for /etc/wingbits/device
The original installer uses a GeoSigner ID to bind the data to the user.  
This installer uses the legacy "3 word" station ID.  

You must not change the station ID once it is bound, and this installer is only for existing BYOD stations (no new BYOD stations can be installed), 
so we don't use the GeoSigner ID and keep going with the legacy station ID.

#### wb-config tool
Not supported, as we use ultrafeeder.

# Original wingbits software

The version of the software is fetched from https://install.wingbits.com/$TARGETOS-$TARGETARCH.json, for example:
https://install.wingbits.com/linux-amd64.json
https://install.wingbits.com/linux-arm64.json

where "linux-amd64" is the TARGETPLATFORM (when splitted: $TARGETOS-$TARGETARCH)

The json contains something like this:
```json
{
"Version": "v1.10.21",
"Sha256": "831/mFJI5O4RoikxLogur7BkZdVymBrjlc4/yYMq+cw=",
"Channel": "stable",
"Date": "2026-04-21T10:30:57.873024055Z"
}
```

The original executable is fetched from https://install.wingbits.com/$VERSION/$TARGETOS-$TARGETARCH.gz, for ex https://install.wingbits.com/v1.10.21/linux-arm64.gz

