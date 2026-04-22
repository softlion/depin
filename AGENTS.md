# Goal and Organization
## Repository Goal
This repository is a collection of installers for unrelated projects, that install vendor softwares in docker containers.

The target OS for the containers is always the latest linux 64 bits (debian based, like raspberry pi OS).
Many projects also support Balena OS (for unlocked nebra and sensecap devices), but starting from 2026/04/22 I deprecate it: any update will remove that support.

## Repository Organization
This repository contains one folder per project, each project is unique and unrelated to the others.
Read the README.md and AGENTS.md in each folder for more information.

# Summary of projets

## Wingbits
Custom installer for the wingbits miner software in a docker container.

## Presearch
Custom installer for the presearch miner software in a docker container.

# Common Considerations

- Security: the containers are not designed to be run on untrusted networks. Even if they are designed to expose the minimal amount of ports and features. The original software is also left untouched when possible, and fetched only from the official repositories.
- Concurrency: the containers from different projects are designed to be run in parallel.
- Idempotency: the installers are designed to be run multiple times without side effects.
- Updates: the installers are designed to install the latest version of the software, even if the software is already installed. If the latest version is already installed, the installer will do nothing. If only a configuration has changed, the software will still be updated.
