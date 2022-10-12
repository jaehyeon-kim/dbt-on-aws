# glue databases
resource "aws_glue_catalog_database" "imdb_db" {
  name         = "imdb"
  location_uri = "s3://${local.default_bucket.name}/imdb"
  description  = "Database that contains IMDb staging/intermediate model datasets"
}

resource "aws_glue_catalog_database" "imdb_db_marts" {
  name         = "imdb_analytics"
  location_uri = "s3://${local.default_bucket.name}/imdb_analytics"
  description  = "Database that contains IMDb marts model datasets"
}
