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
    primary_name text,
    birth_year text,
    death_year text,
    primary_profession text,
    known_for_titles text
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
    title_id text,
    ordering int,
    title varchar(max),
    region text,
    language text,
    types text,
    attributes text,
    is_original_title boolean
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
    title_type text,
    primary_title varchar(max),
    original_title varchar(max),
    is_adult boolean,
    start_year text,
    end_year text,
    runtime_minutes text,
    genres text
);

copy imdb.title_basics
from 's3://<s3-bucket-name>/title_basics'
iam_role default
delimiter '\t'
region 'ap-southeast-2'
ignoreheader 1;

-- title_crews
drop table if exists imdb.title_crews;
create table imdb.title_crews (
    tconst text,
    directors varchar(max),
    writers varchar(max)
);

copy imdb.title_crews
from 's3://<s3-bucket-name>/title_crew'
iam_role default
delimiter '\t'
region 'ap-southeast-2'
ignoreheader 1;

-- title_episodes
drop table if exists imdb.title_episodes;
create table imdb.title_episodes (
    tconst text,
    parent_tconst text,
    season_number int,
    episode_number int
);

copy imdb.title_episodes
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
    average_rating float,
    num_votes int
);

copy imdb.title_ratings
from 's3://<s3-bucket-name>/title_ratings'
iam_role default
delimiter '\t'
region 'ap-southeast-2'
ignoreheader 1;