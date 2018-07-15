#!/bin/sh

wget -qO- http://localhost:8080 | grep -q '<html'
