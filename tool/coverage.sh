#!/usr/bin/env bash

# Fast fail the script on failures.
set -e

# Gather coverage and upload to Coveralls.
if [ "$CODECOV_TOKEN" ]; then
  OBS_PORT=9292

  echo "Installing coverage tool"
  pub global activate coverage &>/dev/null

  echo "Collecting coverage on port $OBS_PORT..."

  # Start tests in one VM.
  dart --enable-experiment=non-nullable \
    --disable-service-auth-codes \
    --enable-vm-service=$OBS_PORT \
    --pause-isolates-on-exit \
    test/all.dart &

  # Run the coverage collector to generate the JSON coverage report.
  echo "Generating LCOV report..."
  pub global run coverage:collect_coverage \
    --port=$OBS_PORT \
    --out=/tmp/coverage.json \
    --wait-paused \
    --resume-isolates &&

  pub global run coverage:format_coverage \
    --lcov \
    --in=/tmp/coverage.json \
    --out=/tmp/lcov.info \
    --packages=.packages \
    --report-on=lib \
    --check-ignore
fi
