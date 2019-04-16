#!/bin/sh
CASEPATH=/case
ls -1 $PATH/casefile | awk -F "." '{print $1}' > $PATH/caselist.txt
