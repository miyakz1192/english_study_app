#!/usr/bin/bash

cat /mnt/sentence_data.txt | while read line
do 
  sentence_no=`echo ${line} | awk -F :: '{print $1}'`
  en=`echo ${line} | awk -F :: '{print $3}'`
  while :
  do
    set -x 
    curl -X POST -H "Content-Type: application/json" -d "{\"en\": \"${en}\"}"  eng-app-wm-app-service:3000/words/${sentence_no}
    if [ $? -eq 0 ]; then
      set +x
      break
    fi
    set +x
    echo "WARNING: curl return non 0. retry it."
  done
done
