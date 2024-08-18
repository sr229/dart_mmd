#!/bin/bash

export PATH="$PATH":"$HOME/.pub-cache/bin"

dart pub global activate fvm && dart pub global activate melos; \
    fvm use; \
    melos bootstrap;