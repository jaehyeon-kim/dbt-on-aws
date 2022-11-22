# Find the user currently in use by AWS
data "aws_caller_identity" "current" {}

# Region in which to deploy the solution
data "aws_region" "current" {}

locals {
  name        = basename(path.cwd) == "infra" ? basename(dirname(path.cwd)) : basename(path.cwd)
  region      = data.aws_region.current.name
  environment = "dev"

  default_bucket = {
    name = "${local.name}-${data.aws_caller_identity.current.account_id}-${local.region}"
  }

  glue = {
    tables = [
      { name = "name_basics", header = ["nconst", "primaryName", "birthYear", "deathYear", "primaryProfession", "knownForTitles"] },
      { name = "title_akas", header = ["titleId", "ordering", "title", "region", "language", "types", "attributes", "isOriginalTitle"] },
      { name = "title_basics", header = ["tconst", "titleType", "primaryTitle", "originalTitle", "isAdult", "startYear", "endYear", "runtimeMinutes", "genres"] },
      { name = "title_crew", header = ["tconst", "directors", "writers"] },
      { name = "title_episode", header = ["tconst", "parentTconst", "seasonNumber", "episodeNumber"] },
      { name = "title_principals", header = ["tconst", "ordering", "nconst", "category", "job", "characters"] },
      { name = "title_ratings", header = ["tconst", "averageRating", "numVotes"] }
    ]
  }

  tags = {
    Name        = local.name
    Environment = local.environment
  }
}
