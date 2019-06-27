#!/usr/bin/env bash

OBSERVATORY_PORT=9999

echo "Installing coverage package..."

pub global activate coverage &>/dev/null

echo "Collecting coverage data on port $OBSERVATORY_PORT..."

dart --disable-service-auth-codes \
    --enable-vm-service=$OBSERVATORY_PORT \
    --pause-isolates-on-exit \
    test/all.dart &

pub global run coverage:collect_coverage \
    --port=$OBSERVATORY_PORT \
    --out=tmp/coverage.json \
    --wait-paused \
    --resume-isolates

echo "Generating LCOV report..."

pub global run coverage:format_coverage \
    --lcov \
    --in=tmp/coverage.json \
    --out=tmp/lcov.info \
    --packages=.packages \
    --report-on=lib

echo "Send coverage data to codecov..."

bash <(curl -s https://codecov.io/bash) -f tmp/lcov.info
