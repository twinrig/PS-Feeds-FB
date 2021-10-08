--  Prep Object for run
delete from fb.incoming_files;
delete from fb.xml_incoming;
delete from fb.cfs_incoming_staging;
-- Get list of files to load
insert into fb.incoming_files (filename)
    Select pg_ls_dir('/mnt/fb/_v2/exports/cfsfacebook');

-- Load raw xml to table
do
$$
    declare trow record;
    BEGIN
        for trow in
            select '/mnt/fb/_v2/exports/cfsfacebook/' || filename as filename from fb.incoming_files where right(filename,4) = '.xml'
        loop
            insert into fb.xml_incoming (filename, xml_incoming)
                select trow.filename,pg_read_file(trow.filename,3,1000000000)::xml;
        end loop;
    end
$$;

-- Parse xml to staging
insert into fb.cfs_incoming_staging (
       filename, fb_page_id, vehicle_id, dealer_id, dealer_name, dealer_phone, dealer_communication_channel, dealer_privacy_policy_url, addr1,
       city, region, postal_code, country, latitude, longitude, date_first_on_lot, vin, car_history_link, state_of_vehicle, body_style, year,
       make, model, fuel_type, transmission, drivetrain, exterior_color, interior_color, title, description, url, price, carfax_dealership_id,
       msrp, mileage, images,md5_check)
Select filename, fb_page_id, vehicle_id, dealer_id, dealer_name, dealer_phone, dealer_communication_channel, dealer_privacy_policy_url, addr1,
       city, region, postal_code, country, latitude, longitude, date_first_on_lot, vin, car_history_link, state_of_vehicle, body_style, year,
       make, model, fuel_type, transmission, drivetrain, exterior_color, interior_color, title, description, url, price, carfax_dealership_id,
       msrp, json_build_object('value',mileage,'unit',mileage_unit) as mileage,
       json_build_array(json_build_object('url',image_1),json_build_object('url',image_2),json_build_object('url',image_3),json_build_object('url',image_4),
           json_build_object('url',image_5),json_build_object('url',image_6),json_build_object('url',image_7),json_build_object('url',image_8),
           json_build_object('url',image_9),json_build_object('url',image_10),json_build_object('url',image_11),json_build_object('url',image_12),
           json_build_object('url',image_13),json_build_object('url',image_14),json_build_object('url',image_15),json_build_object('url',image_16),
           json_build_object('url',image_17),json_build_object('url',image_18),json_build_object('url',image_19),json_build_object('url',image_20)),
       md5( coalesce(addr1::varchar,'') || coalesce(city::varchar,'') || coalesce(region::varchar,'') ||
         coalesce(postal_code::varchar,'') || coalesce(country::varchar,'') || coalesce(date_first_on_lot::varchar,'') ||
         coalesce(vin::varchar,'') || coalesce(car_history_link::varchar,'') || coalesce(state_of_vehicle::varchar,'') ||
         coalesce(body_style::varchar,'') || coalesce(year::varchar,'') || coalesce(make::varchar,'') || coalesce(model::varchar,'') ||
         coalesce(fuel_type::varchar,'') || coalesce(transmission::varchar,'') || coalesce(drivetrain::varchar,'') ||
         coalesce(exterior_color::varchar,'') || coalesce(interior_color::varchar,'') || coalesce(title::varchar,'') ||
         coalesce(description::varchar,'') || coalesce(url::varchar,'') || coalesce(price::varchar,'') ||
         coalesce(carfax_dealership_id::varchar,'') || coalesce(msrp::varchar,'') || coalesce(mileage::varchar,'') ||
         coalesce(image_1::varchar,'') || coalesce(image_2::varchar,'') || coalesce(image_3::varchar,'') || coalesce(image_4::varchar,'') ||
         coalesce(image_5::varchar,'') || coalesce(image_6::varchar,'') || coalesce(image_7::varchar,'') || coalesce(image_8::varchar,'') ||
         coalesce(image_9::varchar,'') || coalesce(image_10::varchar,'') || coalesce(image_11::varchar,'') || coalesce(image_12::varchar,'') ||
         coalesce(image_13::varchar,'') || coalesce(image_14::varchar,'') || coalesce(image_15::varchar,'') || coalesce(image_16::varchar,'') ||
         coalesce(image_17::varchar,'') || coalesce(image_18::varchar,'') || coalesce(image_19::varchar,'') || coalesce(image_20::varchar,'')
           )
from fb.xml_incoming,
       xmltable ('//listings/listing'
                 passing xml_incoming
                 columns fb_page_id bigint PATH 'fb_page_id',
                         vehicle_id bigint PATH 'vehicle_id',
                         dealer_id bigint PATH 'dealer_id',
                         dealer_name text PATH 'dealer_name',
                         dealer_phone text PATH 'dealer_phone',
                         dealer_communication_channel text PATH 'dealer_communication_channel',
                         dealer_privacy_policy_url text PATH 'dealer_privacy_policy_url',
                         addr1 text PATH 'address/component[@name="addr1"]',
                         city text PATH 'address/component[@name="city"]',
                         region text PATH 'address/component[@name="region"]',
                         postal_code text PATH 'address/component[@name="postal_code"]',
                         country text PATH 'address/component[@name="country"]',
                         latitude numeric PATH 'latitude',
                         longitude numeric PATH 'longitude',
                         date_first_on_lot date PATH 'date_first_on_lot',
                         stock_number text PATH 'stock_number',
                         vin text PATH 'vin',
                         car_history_link text PATH 'car_history_link',
                         state_of_vehicle text PATH 'state_of_vehicle',
                         body_style text PATH 'body_style',
                         year int PATH 'year',
                         make text PATH 'make',
                         model text PATH 'model',
                         trim text PATH 'trim',
                         fuel_type text PATH 'fuel_type',
                         transmission text PATH 'transmission',
                         drivetrain text PATH 'drivetrain',
                         exterior_color text PATH 'exterior_color',
                         interior_color text PATH 'interior_color',
                         title text PATH 'title',
                         description text PATH 'description',
                         url text PATH 'url',
                         price text PATH 'price',
                         carfax_dealership_id bigint PATH 'carfax_dealership_id',
                         msrp text PATH 'msrp',
                         mileage text PATH 'mileage/value',
                         mileage_unit text PATH 'mileage/unit',
                         image_1 text PATH 'image[1]/url',
                         image_2 text PATH 'image[2]/url',
                         image_3 text PATH 'image[3]/url',
                         image_4 text PATH 'image[4]/url',
                         image_5 text PATH 'image[5]/url',
                         image_6 text PATH 'image[6]/url',
                         image_7 text PATH 'image[7]/url',
                         image_8 text PATH 'image[8]/url',
                         image_9 text PATH 'image[9]/url',
                         image_10 text PATH 'image[10]/url',
                         image_11 text PATH 'image[11]/url',
                         image_12 text PATH 'image[12]/url',
                         image_13 text PATH 'image[13]/url',
                         image_14 text PATH 'image[14]/url',
                         image_15 text PATH 'image[15]/url',
                         image_16 text PATH 'image[16]/url',
                         image_17 text PATH 'image[17]/url',
                         image_18 text PATH 'image[18]/url',
                         image_19 text PATH 'image[19]/url',
                         image_20 text PATH 'image[20]/url');

-- Compare Staging to existing & insert into audit
insert into audittracking.audit (audit_id, object_id, object_assembly, referer, user_id, change_type,date_created,  "Approved", change_patch)
    select uuid_generate_v4(), o.id,'Chassis.Entities.Feed.CfsIncoming','',null,'Modified', now()  at time zone 'UTC', false,
            json_object( cast( '{' || trim(
                        case when o.description <> n.description then 'description, ' || to_json( o.description::varchar) || ',' else ''  end ||
                        case when o.addr1 <> n.addr1 then 'addr1, ' || to_json( o.addr1::varchar) || ',' else ''  end ||
                        case when o.city <> n.city then 'city, ' || to_json( o.city::varchar) || ',' else ''  end ||
                        case when o.region <> n.region then 'region, ' || to_json( o.region::varchar) || ',' else ''  end ||
                        case when o.postal_code <> n.postal_code then 'postal_code, ' || to_json( o.postal_code::varchar) || ',' else ''  end ||
                        case when o.country <> n.country then 'country, ' || to_json( o.country::varchar) || ',' else ''  end ||
                        case when o.date_first_on_lot <> n.date_first_on_lot then 'date_first_on_lot, ' || to_json( o.date_first_on_lot::varchar) || ',' else ''  end ||
                        case when o.vin <> n.vin then 'vin, ' || to_json( o.vin::varchar) || ',' else ''  end ||
                        case when o.car_history_link <> n.car_history_link then 'car_history_link, ' || to_json( o.car_history_link::varchar) || ',' else ''  end ||
                        case when o.state_of_vehicle <> n.state_of_vehicle then 'state_of_vehicle, ' || to_json( o.state_of_vehicle::varchar) || ',' else ''  end ||
                        case when o.body_style <> n.body_style then 'body_style, ' || to_json( o.body_style::varchar) || ',' else ''  end ||
                        case when o.year <> n.year then 'year, ' || to_json( o.year::varchar) || ',' else ''  end ||
                        case when o.make <> n.make then 'make, ' || to_json( o.make::varchar) || ',' else ''  end ||
                        case when o.model <> n.model then 'model, ' || to_json( o.model::varchar) || ',' else ''  end ||
                        case when o.fuel_type <> n.fuel_type then 'fuel_type, ' || to_json( o.fuel_type::varchar) || ',' else ''  end ||
                        case when o.transmission <> n.transmission then 'transmission, ' || to_json( o.transmission::varchar) || ',' else ''  end ||
                        case when o.drivetrain <> n.drivetrain then 'drivetrain, ' || to_json( o.drivetrain::varchar) || ',' else ''  end ||
                        case when o.exterior_color <> n.exterior_color then 'exterior_color, ' || to_json( o.exterior_color::varchar) || ',' else ''  end ||
                        case when o.interior_color <> n.interior_color then 'interior_color, ' || to_json( o.interior_color::varchar) || ',' else ''  end ||
                        case when o.title <> n.title then 'title, ' || to_json( o.title::varchar) || ',' else ''  end ||
                        case when o.description <> n.description then 'description, ' || to_json( o.description::varchar) || ',' else ''  end ||
                        case when o.url <> n.url then 'url, ' || to_json( o.url::varchar) || ',' else ''  end ||
                        case when o.price <> n.price then 'price, ' || to_json( o.price::varchar) || ',' else ''  end ||
                        case when o.carfax_dealership_id <> n.carfax_dealership_id then 'carfax_dealership_id, ' || to_json( o.carfax_dealership_id::varchar) || ',' else ''  end ||
                        case when o.msrp <> n.msrp then 'msrp, ' || to_json( o.msrp::varchar) || ',' else ''  end ||
                        case when o.mileage::text <> n.mileage::text then 'mileage, ' || to_json( o.mileage::varchar) || ',' else ''  end ||
                        case when o.images::text <> n.images::text then 'images, ' || to_json( o.images::varchar) || ',' else ''  end
        ,',')|| '}' as text[]))
from fb.cfs_incoming_staging as n
join fb.cfs_incoming         as o   on n.vehicle_id = o.vehicle_id
where n.md5_check  <> o.md5_check;

-- Update staging to existing
update fb.cfs_incoming as ci
    set addr1 = cis.addr1,
        city = cis.city,
        region = cis.region,
        postal_code = cis.postal_code,
        country = cis.country,
        date_first_on_lot = cis.date_first_on_lot,
        vin = cis.vin,
        car_history_link = cis.car_history_link,
        state_of_vehicle = cis.state_of_vehicle,
        body_style = cis.body_style,
        year = cis.year,
        make = cis.make,
        model = cis.model,
        fuel_type = cis.fuel_type,
        transmission = cis.transmission,
        drivetrain = cis.drivetrain,
        exterior_color = cis.exterior_color,
        interior_color = cis.interior_color,
        title = cis.title,
        description = cis.description,
        url = cis.url,
        price = cis.price,
        carfax_dealership_id = cis.carfax_dealership_id,
        msrp = cis.msrp,
        mileage = cis.mileage,
        images = cis.images,
        filename = cis.filename,
        md5_check = cis.md5_check,
        modification_complete = false
    from fb.cfs_incoming_staging as cis
    where cis.vehicle_id = ci.vehicle_id
      and cis.md5_check  <> ci.md5_check;

-- Insert new records from staging to existing
insert into fb.cfs_incoming (filename, fb_page_id, vehicle_id, dealer_id, dealer_name, dealer_phone, dealer_communication_channel,
                             dealer_privacy_policy_url, addr1, city, region, postal_code, country, latitude, longitude, date_first_on_lot,
                             vin, car_history_link, state_of_vehicle, body_style, year, make, model, fuel_type, transmission, drivetrain,
                             exterior_color, interior_color, title, description, url, price, carfax_dealership_id,msrp, images, mileage, md5_check)
    select s.filename, s.fb_page_id, s.vehicle_id, s.dealer_id, s.dealer_name, s.dealer_phone, s.dealer_communication_channel, s.dealer_privacy_policy_url,
           s.addr1, s.city, s.region, s.postal_code, s.country, s.latitude, s.longitude, s.date_first_on_lot, s.vin, s.car_history_link, s.state_of_vehicle,
           s.body_style, s.year, s.make, s.model, s.fuel_type, s.transmission, s.drivetrain, s.exterior_color, s.interior_color, s.title, s.description, s.url,
           s.price, s.carfax_dealership_id, s.msrp, s.mileage, s.images, s.md5_check
    from fb.cfs_incoming_staging as s
    left outer join fb.cfs_incoming as i on i.vehicle_id = s.vehicle_id
    where i.vehicle_id is null;
    

