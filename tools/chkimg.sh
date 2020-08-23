#!/bin/bash
if [ -f img.lst ]; then	rm img.lst
fi

for i in `find ../release -depth -type d` 
do
	if [ "${i/..\/release/}" != "" ]; then 
		echo mkdir ${i/..\/release/}>>img.lst
	fi
done

for i in `find ../release -depth -type f` 
do 
	echo put $i ${i/..\/release/}>>img.lst
done

./dmimg ../us/sd_nedo.vhd conf img.lst
