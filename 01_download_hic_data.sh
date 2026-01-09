#!/bin/bash

RUN=$1
RUNDIR=$2
RUNID=$(bs list run | grep $RUN | awk '{print $4}')
mkdir -p $RUNDIR/$RUN

#this creates the list of all the lanes for downloading

bs list dataset --input-run $RUNID | awk '{print $2;}' > $RUN.prefix.txt 
sed -i '1,3d' $RUN.prefix.txt

for PREFIX in $(cat $RUN.prefix.txt); do
ID=$(bs list dataset --input-run $RUNID | grep $PREFIX | awk '{print $4;}')
echo $PREFIX $ID ">>" $RUNDIR/$RUN/$PREFIX
bs download dataset -i $ID -o $RUNDIR/$RUN/$PREFIX # olivia_update: removed "--input-run $RUNID"
done
