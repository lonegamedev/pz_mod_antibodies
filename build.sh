#!/bin/bash

if ! command -v virtualenv &> /dev/null; then
    echo "Error: virtualenv is not installed. Please install it using 'pip install virtualenv'."
    exit 1
fi

python -m virtualenv venv
source venv/bin/activate
pip install -r requirements.txt

python build.py \
    --MOD_ID="lgd_antibodies" \
    --MOD_NAME="Antibodies" \
    --MOD_VERSION="1.90" \
    --MOD_OPTIONS_VERSION="1_80" \
    --MOD_POSTER_FILTER="" \
    --WORKSHOP_ID="2392676812" \
    --WORKSHOP_VISIBILITY="listed" \
    --WORKSHOP_DESCRIPTION="./workshop_description.txt" \
    --WORKSHOP_TAGS="./workshop_tags.txt"

deactivate
