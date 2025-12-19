#!/bin/bash
for i in terraform* ansible*
do
	echo "Updating repository $i"
	cd $i
	pwd
	git submodule update --remote
	echo "Updating repository $i finished"
	cd ../
done	  
echo "All repositories have been synchronized"
