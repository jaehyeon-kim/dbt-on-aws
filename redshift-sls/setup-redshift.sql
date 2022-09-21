-- // create db schemas
create schema if not exists imdb;
create schema if not exists marts;

-- // create db user and group
create user dbt with password '<password>';
create group dbt with user dbt;

-- // grant permissions to new schemas
grant usage on schema imdb to group dbt;
grant create on schema imdb to group dbt;
grant all on all tables in schema imdb to group dbt;

grant usage on schema marts to group dbt;
grant create on schema marts to group dbt;
grant all on all tables in schema marts to group dbt;

-- reassign schema ownership to dbt
alter schema imdb owner to dbt;
alter schema marts owner to dbt;

-- // copy data to tables
-- name_basics
drop table if exists imdb.name_basics;
create table imdb.name_basics (
    nconst text,
    primaryName text,
    birthYear text,
    deathYear text,
    primaryProfession text,
    knownForTitles text
);

copy imdb.name_basics
from 's3://<s3-bucket-name>/name_basics'
iam_role default
delimiter '\t'
region 'ap-southeast-2'
ignoreheader 1;

-- title_akas
drop table if exists imdb.title_akas;
create table imdb.title_akas (
    titleId text,
    ordering int,
    title varchar(max),
    region text,
    language text,
    types text,
    attributes text,
    isOriginalTitle boolean
);

copy imdb.title_akas
from 's3://<s3-bucket-name>/title_akas'
iam_role default
delimiter '\t'
region 'ap-southeast-2'
ignoreheader 1;

-- title_basics
drop table if exists imdb.title_basics;
create table imdb.title_basics (
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

copy imdb.title_basics
from 's3://<s3-bucket-name>/title_basics'
iam_role default
delimiter '\t'
region 'ap-southeast-2'
ignoreheader 1;

-- title_crew
drop table if exists imdb.title_crew;
create table imdb.title_crew (
    tconst text,
    directors varchar(max),
    writers varchar(max)
);

copy imdb.title_crew
from 's3://<s3-bucket-name>/title_crew'
iam_role default
delimiter '\t'
region 'ap-southeast-2'
ignoreheader 1;

-- title_episode
drop table if exists imdb.title_episode;
create table imdb.title_episode (
    tconst text,
    parentTconst text,
    seasonNumber int,
    episodeNumber int
);

copy imdb.title_episode
from 's3://<s3-bucket-name>/title_episode'
iam_role default
delimiter '\t'
region 'ap-southeast-2'
ignoreheader 1;

-- title_principals
drop table if exists imdb.title_principals;
create table imdb.title_principals (
    tconst text,
    ordering int,
    nconst text,
    category text,
    job varchar(max),
    characters varchar(max)
);

copy imdb.title_principals
from 's3://<s3-bucket-name>/title_principals'
iam_role default
delimiter '\t'
region 'ap-southeast-2'
ignoreheader 1;

-- title_ratings
drop table if exists imdb.title_ratings;
create table imdb.title_ratings (
    tconst text,
    averageRating float,
    numVotes int
);

copy imdb.title_ratings
from 's3://<s3-bucket-name>/title_ratings'
iam_role default
delimiter '\t'
region 'ap-southeast-2'
ignoreheader 1;