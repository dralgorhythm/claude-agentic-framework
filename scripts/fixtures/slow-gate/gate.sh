#!/usr/bin/env bash
# Fixture: a "gate" that runs longer than a single gate should. Used by later
# units' harness cases (U5b) to prove a per-gate timeout produces an honest
# "ask" rather than a silent kill or an indefinite hang.
sleep 8
