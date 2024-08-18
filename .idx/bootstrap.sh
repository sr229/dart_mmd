#!/bin/bash

export PATH="$PATH:$HOME/.pub-cache/bin"

echo 'export PATH="$PATH:$HOME/.pub-cache/bin"' >> $HOME/.bashrc

dart pub global activate fvm && dart pub global activate melos; \
    fvm use -f; \
    melos bootstrap;