## sync event database files of 2018 into data bucket
aws s3 sync \
  s3://gdelt-open-data \
  s3://redshift-sls-590312749310-ap-southeast-2 \
  --exclude "*" --include "events/2018*" \
  --source-region us-east-1 --region ap-southeast-2

## upload lookup tables
s3_bucket="redshift-sls-590312749310-ap-southeast-2"
lookup_url="https://www.gdeltproject.org/data/lookups"
declare -a file_names=(
  "CAMEO.eventcodes.txt" \
  "CAMEO.country.txt" \
  "FIPS.country.txt" \
  "CAMEO.type.txt" \
  "CAMEO.knowngroup.txt" \
  "CAMEO.ethnic.txt" \
  "CAMEO.religion.txt" \
  "CAMEO.goldsteinscale.txt"
  )

for fn in "${file_names[@]}"
do
  download_url=$(echo $lookup_url/$fn)
  prefix=$(echo ${fn::-4} | tr '[:upper:]' '[:lower:]' | tr '.' '_')
  echo "upload $fn into s3://$s3_bucket/$prefix/$fn"
  curl $download_url -o $fn --silent
  aws s3 cp ./$fn s3://$s3_bucket/$prefix/$fn
  rm $fn
done
