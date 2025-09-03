#!/bin/bash
set -e

# Build the EZOverlay application in release mode
cd EZOverlay
swift build --configuration release
