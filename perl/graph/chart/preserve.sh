#!/bin/bash
cd /home/ig/perl/graph/chart
for file in `ls graphs/*`
do
    cp $file graphs/backups/$file.`date +'%d'`
done
