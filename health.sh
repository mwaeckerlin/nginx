#!/bin/sh

wget -qO- http://localhost | grep -q '<html'
