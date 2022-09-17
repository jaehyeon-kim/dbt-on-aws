-- // create db schemas
create external schema gdelt_external
    from data catalog
    database 'gdelt'
    iam_role 'arn:aws:iam::<account-id>:role/<role-name>'
    create external database if not exists;

create schema gdelt;

-- // create db user and group
create user dbt with password '<password>';
create group dbt with user dbt;

-- // grant permissions to new schemas
grant usage on schema gdelt_external to group dbt;
grant create on schema gdelt_external to group dbt;
grant all on all tables in schema gdelt_external to group dbt;

grant usage on schema gdelt to group dbt;
grant create on schema gdelt to group dbt;
grant all on all tables in schema gdelt to group dbt;

-- reassign schema ownership to dbt
alter schema gdelt_external owner to dbt;
alter schema gdelt owner to dbt;
