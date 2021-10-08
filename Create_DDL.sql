-- auto-generated definition
create schema audittracking;
create extension postgres_fdw;
create server audittracking foreign data wrapper postgres_fdw options (host 'localhost', port '5432', dbname 'chassis_audittracking');
create user mapping for chammer server audittracking options (user 'chammer', password 'Tmax9899');
IMPORT FOREIGN SCHEMA public FROM SERVER  audittracking into audittracking;






create schema if not exists fb;
grant all on schema fb to psapi;

---------------------------------------------------------------------------------------------------------
drop table if exists fb.incoming_files;
drop table if exists fb.xml_incoming;
drop table if exists fb.cfs_incoming;
drop table if exists fb.cfs_incoming_staging;

---------------------------------------------------------------------------------------------------------

create table fb.cfs_incoming_staging
(
    filename varchar,
	fb_page_id bigint not null,
	vehicle_id bigint not null,
	dealer_id bigint not null,
	dealer_name varchar,
	dealer_phone varchar,
	dealer_communication_channel varchar,
	dealer_privacy_policy_url varchar,
	addr1 varchar,
	city varchar,
	region varchar,
	postal_code varchar,
	country varchar,
	latitude numeric,
	longitude numeric,
	date_first_on_lot date,
	vin varchar,
	car_history_link varchar,
	state_of_vehicle varchar,
	body_style varchar,
	year integer,
	make varchar,
	model varchar,
	fuel_type varchar,
	transmission varchar,
	drivetrain varchar,
	exterior_color varchar,
	interior_color varchar,
	title varchar,
	description varchar,
	url varchar,
	price varchar,
	carfax_dealership_id bigint,
	msrp varchar,
	images json,
	mileage json,
	md5_check text
);

alter table fb.cfs_incoming_staging owner to chammer;

create index IX_cfs_incoming_staging_vehicleid_md5 on fb.cfs_incoming_staging (vehicle_id,md5_check);
---------------------------------------------------------------------------------------------------------

create table if not exists fb.cfs_incoming
(
	id uuid default uuid_generate_v4() not null
		constraint "PK_cfs_incoming_id"
			primary key,
	filename varchar,
	modification_complete boolean default false,
	modification_by varchar,
	date_modified timestamp(0) with time zone,
	fb_page_id bigint not null,
	vehicle_id bigint not null,
	dealer_id bigint not null,
	dealer_name varchar,
	dealer_phone varchar,
	dealer_communication_channel varchar,
	dealer_privacy_policy_url varchar,
	addr1 varchar,
	city varchar,
	region varchar,
	postal_code varchar,
	country varchar,
	latitude numeric,
	longitude numeric,
	date_first_on_lot date,
	vin varchar,
	car_history_link varchar,
	state_of_vehicle varchar,
	body_style varchar,
	year integer,
	make varchar,
	model varchar,
	fuel_type varchar,
	transmission varchar,
	drivetrain varchar,
	exterior_color varchar,
	interior_color varchar,
	title varchar,
	description varchar,
	url varchar,
	price varchar,
	carfax_dealership_id bigint,
	msrp varchar,
	images json,
	mileage json,
	md5_check text
);

alter table fb.cfs_incoming owner to chammer;
drop index  fb.ix_cfs_incoming_vehicle_id;
create index ix_cfs_incoming_vehicle_id_modification_complete on fb.cfs_incoming (vehicle_id,modification_complete);
create index ix_cfs_incoming_Dealer_id_modification_complete on fb.cfs_incoming (dealer_id,modification_complete);
create index IX_cfs_incoming_staging_vehicleid_md5 on fb.cfs_incoming_staging (vehicle_id,md5_check);

grant delete, insert, references, select, trigger, truncate, update on fb.cfs_incoming to psapi;

---------------------------------------------------------------------------------------------------------

create table fb.incoming_files
(
    filename varchar
);

alter table fb.incoming_files owner to chammer;

grant delete, insert, references, select, trigger, truncate, update on fb.incoming_files to psapi;

---------------------------------------------------------------------------------------------------------

create table fb.xml_incoming
(
	id uuid default uuid_generate_v4() not null,
	filename varchar,
	xml_incoming xml
);

alter table fb.xml_incoming owner to chammer;

grant delete, insert, references, select, trigger, truncate, update on fb.xml_incoming to psapi;

