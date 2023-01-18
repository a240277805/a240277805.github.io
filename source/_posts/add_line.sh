#!/bin/bash

dir=$1

cd $dir

for file in `ls`;do
	echo ''
  echo "$file ..."
  sed -i 'N;2 i ---' $file
  sed -i 'N;2 i title:' $file
  sed -i 'N;2 i ---' $file
  head -n 5 $file
done
