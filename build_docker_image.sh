#!/usr/bin/env bash

# build docker image, remove all intermediate containers and tag successfull build with ora11gxe:latest tag
docker build --force-rm=true -t ora11gxe:latest .
