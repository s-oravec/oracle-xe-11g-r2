#!/usr/bin/env bash

# run docker container named db from ora11gxe image in detached mode and publish all exposed ports
docker run -dP --name db ora11gxe