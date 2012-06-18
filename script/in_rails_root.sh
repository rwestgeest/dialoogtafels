#!/bin/sh
DIR="$( cd "$( dirname "$0" )/.." && pwd )"
sudo -u deployer /bin/bash -i -l -c "cd $DIR; $1"
