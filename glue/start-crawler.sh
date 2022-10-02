#!/usr/bin/env bash

cd glue
imdb_crawler_name=$(terraform -chdir=./infra output --raw imdb_crawler_name)
aws glue start-crawler --name $imdb_crawler_name