# glue role for interactive session
resource "aws_iam_role" "glue_interactive_session" {
  name = "${local.name}-glue-interactive-session"

  assume_role_policy = data.aws_iam_policy_document.glue_interactive_session_assume_role_policy.json
  managed_policy_arns = [
    aws_iam_policy.glue_interactive_session.arn,
    aws_iam_policy.glue_dbt.arn
  ]

  tags = local.tags
}

data "aws_iam_policy_document" "glue_interactive_session_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "lakeformation.amazonaws.com",
        "glue.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_policy" "glue_interactive_session" {
  name   = "${local.name}-glue-interactive-session"
  path   = "/"
  policy = data.aws_iam_policy_document.glue_interactive_session.json
  tags   = local.tags
}

resource "aws_iam_policy" "glue_dbt" {
  name   = "${local.name}-glue-dbt"
  path   = "/"
  policy = data.aws_iam_policy_document.glue_dbt.json
  tags   = local.tags
}

data "aws_iam_policy_document" "glue_interactive_session" {
  statement {
    sid = "AllowStatementInASessionToAUser"

    actions = [
      "glue:ListSessions",
      "glue:GetSession",
      "glue:ListStatements",
      "glue:GetStatement",
      "glue:RunStatement",
      "glue:CancelStatement",
      "glue:DeleteSession"
    ]

    resources = [
      "arn:aws:glue:${local.region}:${data.aws_caller_identity.current.account_id}:session/*",
    ]
  }

  statement {
    actions = ["glue:CreateSession"]

    resources = ["*"]
  }

  statement {
    actions = ["iam:PassRole"]

    resources = ["arn:aws:iam::*:role/${local.name}-glue-interactive-session*"]

    condition {
      test     = "StringLike"
      variable = "iam:PassedToService"

      values = ["glue.amazonaws.com"]
    }
  }

  statement {
    actions = ["iam:PassRole"]

    resources = ["arn:aws:iam::*:role/service-role/${local.name}-glue-interactive-session*"]

    condition {
      test     = "StringLike"
      variable = "iam:PassedToService"

      values = ["glue.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "glue_dbt" {
  statement {
    actions = [
      "glue:SearchTables",
      "glue:BatchCreatePartition",
      "glue:CreatePartitionIndex",
      "glue:DeleteDatabase",
      "glue:GetTableVersions",
      "glue:GetPartitions",
      "glue:DeleteTableVersion",
      "glue:UpdateTable",
      "glue:DeleteTable",
      "glue:DeletePartitionIndex",
      "glue:GetTableVersion",
      "glue:UpdateColumnStatisticsForTable",
      "glue:CreatePartition",
      "glue:UpdateDatabase",
      "glue:CreateTable",
      "glue:GetTables",
      "glue:GetDatabases",
      "glue:GetTable",
      "glue:GetDatabase",
      "glue:GetPartition",
      "glue:UpdateColumnStatisticsForPartition",
      "glue:CreateDatabase",
      "glue:BatchDeleteTableVersion",
      "glue:BatchDeleteTable",
      "glue:DeletePartition",
      "glue:GetUserDefinedFunctions"
    ]

    resources = [
      "arn:aws:glue:${local.region}:${data.aws_caller_identity.current.account_id}:catalog",
      "arn:aws:glue:${local.region}:${data.aws_caller_identity.current.account_id}:table/*/*",
      "arn:aws:glue:${local.region}:${data.aws_caller_identity.current.account_id}:database/*",
    ]
  }

  statement {
    actions = [
      "lakeformation:UpdateResource",
      "lakeformation:ListResources",
      "lakeformation:BatchGrantPermissions",
      "lakeformation:GrantPermissions",
      "lakeformation:GetDataAccess",
      "lakeformation:GetTableObjects",
      "lakeformation:PutDataLakeSettings",
      "lakeformation:RevokePermissions",
      "lakeformation:ListPermissions",
      "lakeformation:BatchRevokePermissions",
      "lakeformation:UpdateTableObjects"
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ]

    resources = ["arn:aws:s3:::${local.default_bucket.name}"]
  }

  statement {
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:GetObject",
      "s3:DeleteObject"
    ]

    resources = ["arn:aws:s3:::${local.default_bucket.name}/*"]
  }
}

# glue crawler
resource "aws_glue_catalog_database" "imdb_db" {
  name        = "imdb"
  description = "Database that contains IMDb staging/intermediate model datasets"
}

resource "aws_glue_catalog_database" "imdb_db_marts" {
  name        = "imdb_analytics"
  description = "Database that contains IMDb marts model datasets"
}

resource "aws_glue_crawler" "imdb_crawler" {
  count = length(local.glue.tables)

  name          = local.glue.tables[count.index].name
  database_name = aws_glue_catalog_database.imdb_db.name
  role          = aws_iam_role.imdb_crawler.arn
  classifiers   = [aws_glue_classifier.imdb_crawler[count.index].id]

  s3_target {
    path = "s3://${local.default_bucket.name}/${local.glue.tables[count.index].name}"
  }

  tags = local.tags
}

resource "aws_glue_classifier" "imdb_crawler" {
  count = length(local.glue.tables)

  name = local.glue.tables[count.index].name

  csv_classifier {
    contains_header = "PRESENT"
    delimiter       = "\t"
    header          = local.glue.tables[count.index].header
  }
}

resource "aws_iam_role" "imdb_crawler" {
  name = "${local.name}-imdb-crawler"

  assume_role_policy = data.aws_iam_policy_document.imdb_crawler_assume_role_policy.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole",
    aws_iam_policy.imdb_crawler.arn
  ]

  tags = local.tags
}

data "aws_iam_policy_document" "imdb_crawler_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "glue.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_policy" "imdb_crawler" {
  name   = "${local.name}-imdb-crawler"
  path   = "/"
  policy = data.aws_iam_policy_document.imdb_crawler.json
  tags   = local.tags
}

data "aws_iam_policy_document" "imdb_crawler" {
  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ]

    resources = ["arn:aws:s3:::${local.default_bucket.name}"]
  }

  statement {
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:GetObject",
      "s3:DeleteObject"
    ]

    resources = ["arn:aws:s3:::${local.default_bucket.name}/*"]
  }
}

# athena workgroup
resource "aws_athena_workgroup" "imdb" {
  name = "${local.name}-imdb"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = false

    result_configuration {
      output_location = "s3://${local.default_bucket.name}/athena/"

      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }
  }

  force_destroy = true

  tags = local.tags
}

# s3 bucket
resource "aws_s3_bucket" "default_bucket" {
  bucket = local.default_bucket.name

  force_destroy = true

  tags = local.tags
}

resource "aws_s3_bucket_acl" "default_bucket" {
  bucket = aws_s3_bucket.default_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default_bucket" {
  bucket = aws_s3_bucket.default_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
