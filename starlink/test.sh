#!/bin/sh
 
NAME="Starlink CVS"
 
# Exit immediately if command fails
set -e
 
# Print command executed to stdout
set -v
# Make env for build.
DISPLAY=earth.bnsc.rl.ac.uk:0.0
export DISPLAY
BUILD_SYSTEM=BUILDDIR
export BUILD_SYSTEM
MY_CVS_ROOT=$CVSROOT
export MY_CVS_ROOT
BUILD_HOME=$BUILD_SYSTEM/build-home
export BUILD_HOME
STARCONF_DEFAULT_STARLINK=$BUILD_SYSTEM/build-root
export STARCONF_DEFAULT_STARLINK
STARCONF_DEFAULT_PREFIX=$BUILD_SYSTEM/build-root
export STARCONF_DEFAULT_PREFIX
PATH=$STARCONF_DEFAULT_PREFIX/buildsupport/bin:$PATH
export PATH
PATH=$STARCONF_DEFAULT_PREFIX/bin:$PATH
export PATH

# Test it
make check

