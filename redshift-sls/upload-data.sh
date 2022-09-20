#!/usr/bin/env bash

s3_bucket="redshift-sls-590312749310-ap-southeast-2"
hostname="datasets.imdbws.com"
declare -a file_names=(
  "name.basics.tsv.gz" \
  "title.akas.tsv.gz" \
  "title.basics.tsv.gz" \
  "title.crew.tsv.gz" \
  "title.episode.tsv.gz" \
  "title.principals.tsv.gz" \
  "title.ratings.tsv.gz"
  )

rm -rf imdb

for fn in "${file_names[@]}"
do
  download_url="https://$hostname/$fn"
  prefix=$(echo ${fn::-7} | tr '.' '_')
  echo "download imdb/$prefix/$fn from https://$hostname/$fn"
  while true;
  do
    mkdir -p imdb/$prefix
    axel -n 32 -a -o imdb/$prefix/$fn $download_url
    gzip -d imdb/$prefix/$fn
    num_files=$(ls imdb/$prefix | wc -l)
    if [ $num_files == 1 ]; then
      break
    fi
    rm -rf imdb/$prefix
  done
done

aws s3 sync ./imdb s3://$s3_bucket
