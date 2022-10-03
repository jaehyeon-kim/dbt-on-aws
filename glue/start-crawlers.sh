#!/usr/bin/env bash

declare -a crawler_names=(
  "name_basics" \
  "title_akas" \
  "title_basics" \
  "title_crew" \
  "title_episode" \
  "title_principals" \
  "title_ratings"
  )

for cn in "${crawler_names[@]}"
do
  echo "start crawler $cn ..."
  aws glue start-crawler --name $cn
done