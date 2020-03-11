#!/bin/sh

vendor/bin/ppm start --config=./docker/ppm.json --workers=${PROCESS_NUM:-3}
