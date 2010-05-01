#!/bin/bash

for file in `ls ~/documents/workspace/Verizon/*.emx`
do
	echo processing $file
	./parseactivity.pl $file
done
