#!/bin/bash

set -e
echo "Building binutils.."
echo "Approximate build time:\t1 SBU"
echo "Required disk space:\t602 MB"

# 5.2 Binutils package contains a linker, an assembler, and other
#		tools for handling object files

tar -xf /sources
