-- // create db schemas
create schema if not exists staging;
create schema if not exists marts;

-- // create db user and group
create user dbt with password '<password>';
create group dbt with user dbt;

-- // grant permissions to new schemas
grant usage on schema staging to group dbt;
grant create on schema staging to group dbt;
grant all on all tables in schema staging to group dbt;

grant usage on schema marts to group dbt;
grant create on schema marts to group dbt;
grant all on all tables in schema marts to group dbt;

-- reassign schema ownership to dbt
alter schema staging owner to dbt;
alter schema marts owner to dbt;

-- // copy data to tables
-- name_basics
drop table if exists staging.name_basics;
create table staging.name_basics (
    nconst text,
    primaryName text,
    birthYear text,
    deathYear text,
    primaryProfession text,
    knownForTitles text
);

copy staging.name_basics
from 's3://<s3-bucket-name>/name_basics'
iam_role default
delimiter '\t'
region 'ap-southeast-2'
ignoreheader 1;

-- title_akas
drop table if exists staging.title_akas;
create table staging.title_akas (
    titleId text,
    ordering int,
    title varchar(max),
    region text,
    language text,
    types text,
    attributes text,
    isOriginalTitle boolean
);

copy staging.title_akas
from 's3://<s3-bucket-name>/title_akas'
iam_role default
delimiter '\t'
region 'ap-southeast-2'
ignoreheader 1;

-- title_basics
drop table if exists staging.title_basics;
create table staging.title_basics (
    tconst text,
    titleType text,
    primaryTitle varchar(max),
    originalTitle varchar(max),
    isAdult boolean,
    startYear text,
    endYear text,
    runtimeMinutes text,
    genres text
);

copy staging.title_basics
from 's3://<s3-bucket-name>/title_basics'
iam_role default
delimiter '\t'
region 'ap-southeast-2'
ignoreheader 1;

-- title_crew
drop table if exists staging.title_crew;
create table staging.title_crew (
    tconst text,
    directors varchar(max),
    writers varchar(max)
);

copy staging.title_crew
from 's3://<s3-bucket-name>/title_crew'
iam_role default
delimiter '\t'
region 'ap-southeast-2'
ignoreheader 1;

-- title_episode
drop table if exists staging.title_episode;
create table staging.title_episode (
    tconst text,
    parentTconst text,
    seasonNumber int,
    episodeNumber int
);

copy staging.title_episode
from 's3://<s3-bucket-name>/title_episode'
iam_role default
delimiter '\t'
region 'ap-southeast-2'
ignoreheader 1;

-- title_principals
drop table if exists staging.title_principals;
create table staging.title_principals (
    tconst text,
    ordering int,
    nconst text,
    category text,
    job varchar(max),
    characters varchar(max)
);

copy staging.title_principals
from 's3://<s3-bucket-name>/title_principals'
iam_role default
delimiter '\t'
region 'ap-southeast-2'
ignoreheader 1;

-- title_ratings
drop table if exists staging.title_ratings;
create table staging.title_ratings (
    tconst text,
    averageRating float,
    numVotes int
);

copy staging.title_ratings
from 's3://<s3-bucket-name>/title_ratings'
iam_role default
delimiter '\t'
region 'ap-southeast-2'
ignoreheader 1;