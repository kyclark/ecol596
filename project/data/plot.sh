#!/bin/bash

for file in *.fa; do
    echo $file
    echo set term png tiny\; plot \"$file\" with lines > do.sh
    gnuplot do.sh > $(basename $file '.fa').png
done
