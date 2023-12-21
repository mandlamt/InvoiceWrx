-- select * from shoprite_checkers_julien_calendar
-- UPDATE shoprite_checkers_julien_calendar SET extracted=1 where jul_id<=33;
-- UPDATE shoprite_checkers_julien_calendar SET extracted=0
-- Nov2021
--Declare @start_date as date = '2021-10-31'
-- Declare @end_date as date = '2021-11-28'

-- Dec2021
--Declare @start_date as date = '2021-11-28'
--Declare @end_date as date = '2022-01-01'

-- Jan 2022
-- Declare @start_date as date = '2022-01-02'
-- Declare @end_date as date = '2022-01-29'

-- Feb 2022
-- Declare @start_date as date = '2022-01-30'
-- Declare @end_date as date = '2022-02-26'

-- Mar 2022
 --Declare @start_date as date = '2022-02-27'
 --Declare @end_date as date = '2022-04-02'

 --  April  2022 	
--Declare @start_date as date = '2022-04-03'
--Declare @end_date as date = '2022-04-30'

 --  May  2022 	
--Declare @start_date as date = '2022-05-01'
--Declare @end_date as date = '2022-05-28'
 --  June  2022 	
--Declare @start_date as date = '2022-05-29' 
--Declare @end_date as date = '2022-07-02'

 --  July  2022 	
--Declare @start_date as date = '2022-07-03' 
--Declare @end_date as date = '2022-07-31'

  --  17	November	2021 	
 --Declare @start_date as date = '2021-10-31'	
 --Declare @end_date as date = '2021-11-27'

--  January  2023 	
--Declare @start_date as date = '2023-01-02' 
--Declare @end_date as date = '2023-01-29'
	

--Declare @start_date as date = '2023-01-30' 
--Declare @end_date as date = '2023-02-26'

Declare @start_date as date = '2023-02-27' 
Declare @end_date as date = '2023-04-02'

DECLARE @temp_records_complete TABLE
(
client_code VARCHAR(10),
period_month VARCHAR(10),
qddm_regno VARCHAR(120),
make_model VARCHAR(512),
vehicle_category VARCHAR(120),
first_reg_date VARCHAR(120),
fleet_age int,
contract_type VARCHAR(120),
customer_branch varchar(120),
accident_cost DECIMAL(12,2),
breakdown_cost DECIMAL(12,2),
repair_cost DECIMAL(12,2),
service_cost DECIMAL(12,2),
tyre_cost DECIMAL(12,2),
maitenance_total_cost DECIMAL(12,2) NOT NULL DEFAULT 0.0,
all_data TEXT
)
insert into @temp_records_complete
-- ***** modified select start
			select distinct 
				   cu.reference ,
				   format(@end_date,'yyyy/MM/dd'),-- old forart yyyyMMdd
				   fvh.LICENSEPLATE,
				   CONCAT(fvh.MAKE,' ',fvh.MODEL,' ',fvh.TYPENAME) ,
				   fvh.NATURE,
				   fvh.FIRSTREGISTRATIONDATE,
				   ls.DURATION ,
				   --ls.CALCDURATION,
				   ls.PRODUCTCATEGORY,
				   convert(varchar,ua.REFERENCE) ,
				   0.0 ,
				   0.0 ,
				   0.0 ,
				   0.0 , 
				   0.0 ,
				   0.0 ,
				   null

			from SUN_CONTRACT ct
			join PLN_INVOICEDITEM ii on ii.CONTRACT_ID = ct.CONTRACT_ID
			join PLN_CUSTOMER cu on cu.CUSTOMER_ID = ct.CUSTOMER_ID
			join PLN_LEASESERVICE ls on ls.LEASESERVICE_ID = ct.LEASESERVICE_ID
			join PLN_FLEETVEHICLE fvh on fvh.FLEETVEHICLE_ID = ii.FLEETVEHICLE_ID
			left join PLN_UNITACCOUNT ua on ua.UNITACCOUNT_ID = ct.UNITACCOUNT_ID
			JOIN PLN_ORDERITEM oi ON oi.ORDERITEMNUMBER = ii.ORDERITEMNUMBER
			JOIN ORDERS od ON od.ORDERS_ID=oi.ORDERITEM_ID
			where ct.CUSTOMER_ID = 5001057
				  and ct.FROMDATE <= convert(varchar,@start_date,121) and ct.todate > convert(varchar,@end_date,121) and ISRELEVANT = 1
				 -- and INVOICEDITEMDATE >=@start_date AND INVOICEDITEMDATE <= @end_date
				  and od.ORDERDATE >=@start_date AND od.ORDERDATE <= @end_date
				  and fvh.NATURE in ('Light Commercial Vehicle','Passenger Car','BUS')
				  and ls.PRODUCTCATEGORY='Fleet Management';

UPDATE @temp_records_complete SET accident_cost=(dbo.shoprite_checkers_get_sum (@start_date,@end_date,'SHOPRITE CHECKERS','5001057',qddm_regno,'Accident') )
UPDATE @temp_records_complete SET breakdown_cost=(dbo.shoprite_checkers_get_sum2 (@start_date,@end_date,'SHOPRITE CHECKERS','5001057',qddm_regno,'Breakdown') )
--UPDATE @temp_records_complete SET breakdown_cost=(dbo.shoprite_checkers_get_sum (@start_date,@end_date,'SHOPRITE CHECKERS','5001057',qddm_regno,'Breakdown') )
UPDATE @temp_records_complete SET repair_cost  = (dbo.shoprite_checkers_get_sum (@start_date,@end_date,'SHOPRITE CHECKERS','5001057',qddm_regno,'Repairs') ) 
UPDATE @temp_records_complete SET service_cost=(dbo.shoprite_checkers_get_sum (@start_date,@end_date,'SHOPRITE CHECKERS','5001057',qddm_regno,'Service') )
UPDATE @temp_records_complete SET tyre_cost=(dbo.shoprite_checkers_get_sum (@start_date,@end_date,'SHOPRITE CHECKERS','5001057',qddm_regno,'Tyres') )
/*
UPDATE @temp_records_complete SET all_data=CONCAT(client_code,'|',period_month,'|',qddm_regno,'|',make_model,'|',vehicle_category,'|',
first_reg_date,'|',CAST(fleet_age as VARCHAR(32)),'|',contract_type,'|',customer_branch,'|',
CAST(accident_cost as VARCHAR(32)),'|',CAST(breakdown_cost as VARCHAR(32)),'|',CAST(repair_cost as VARCHAR(32)),'|',
CAST(service_cost as VARCHAR(32)),'|',CAST(tyre_cost as VARCHAR(32)),'|',CAST(maitenance_total_cost as VARCHAR(32)));

UPDATE @temp_records_complete SET all_data=CONCAT(all_data,'|',( select Count(*) from @temp_records_complete ));
select * from @temp_records_complete*/

DECLARE @temp_records_complete_tyre TABLE
(
client_code VARCHAR(10),
period_month VARCHAR(10),
qddm_regno VARCHAR(120),
make_model VARCHAR(512),
vehicle_category VARCHAR(120),
first_reg_date VARCHAR(120),
fleet_age int,
contract_type VARCHAR(120),
customer_branch varchar(120),
cost DECIMAL(12,2)
)
INSERT INTO @temp_records_complete_tyre
select   cu.reference ,
				   format(@end_date,'yyyy/MM/dd'),-- old forart yyyyMMdd
				   fvh.LICENSEPLATE,
				   CONCAT(fvh.MAKE,' ',fvh.MODEL,' ',fvh.TYPENAME) ,
				   fvh.NATURE,
				   fvh.FIRSTREGISTRATIONDATE,
				   ls.DURATION ,
				   --ls.CALCDURATION,
				   ls.PRODUCTCATEGORY,
				   convert(varchar,ua.REFERENCE) ,
				   -- lsc.name,
				   lsc.LEASEPRICE
				from LEASESERVICECOMPONENT  lsc
			JOIN SUN_CONTRACT ct ON ct.LEASESERVICE_ID = lsc.LEASESERVICE_ID
			join PLN_LEASESERVICE ls on ls.LEASESERVICE_ID = ct.LEASESERVICE_ID
			join PLN_CUSTOMER cu on cu.CUSTOMER_ID = ct.CUSTOMER_ID
			join PLN_FLEETVEHICLE fvh on fvh.FLEETVEHICLE_ID = ct.FLEETVEHICLE_ID
			left join PLN_UNITACCOUNT ua on ua.UNITACCOUNT_ID = ct.UNITACCOUNT_ID
			where lsc.name = 'Tyres'
			and ls.name = 'Operating Lease'
			and ct.CUSTOMER_ID = 5001057
			and ct.todate = '3000-12-31 00:00:00.000'
			and isrelevant = 1 and fvh.LICENSEPLATE IS NOT NULL AND fvh.NATURE  in ('Light Commercial Vehicle','Passenger Car','BUS')

DECLARE @temp_records_complete_repair TABLE
(
client_code VARCHAR(10),
period_month VARCHAR(10),
qddm_regno VARCHAR(120),
make_model VARCHAR(512),
vehicle_category VARCHAR(120),
first_reg_date VARCHAR(120),
fleet_age int,
contract_type VARCHAR(120),
customer_branch varchar(120),
cost DECIMAL(12,2)
)
INSERT INTO @temp_records_complete_repair
select   cu.reference ,
				   format(@end_date,'yyyy/MM/dd'),-- old forart yyyyMMdd
				   fvh.LICENSEPLATE,
				   CONCAT(fvh.MAKE,' ',fvh.MODEL,' ',fvh.TYPENAME) ,
				   fvh.NATURE,
				   fvh.FIRSTREGISTRATIONDATE,
				   ls.DURATION ,
				   --ls.CALCDURATION,
				   ls.PRODUCTCATEGORY,
				   convert(varchar,ua.REFERENCE) ,
				   -- lsc.name,
				   lsc.LEASEPRICE
				from LEASESERVICECOMPONENT  lsc
			JOIN SUN_CONTRACT ct ON ct.LEASESERVICE_ID = lsc.LEASESERVICE_ID
			join PLN_LEASESERVICE ls on ls.LEASESERVICE_ID = ct.LEASESERVICE_ID
			join PLN_CUSTOMER cu on cu.CUSTOMER_ID = ct.CUSTOMER_ID
			join PLN_FLEETVEHICLE fvh on fvh.FLEETVEHICLE_ID = ct.FLEETVEHICLE_ID
			left join PLN_UNITACCOUNT ua on ua.UNITACCOUNT_ID = ct.UNITACCOUNT_ID
			where lsc.name = 'Repair and Maintenance'
			and ls.name = 'Operating Lease'
			and ct.CUSTOMER_ID = 5001057
			and ct.todate = '3000-12-31 00:00:00.000'
			and isrelevant = 1 and fvh.LICENSEPLATE IS NOT NULL AND fvh.NATURE  in ('Light Commercial Vehicle','Passenger Car','BUS');
/*
select * from @temp_records_complete;
select * from @temp_records_complete_tyre;
select * from @temp_records_complete_repair;
*/
UPDATE  main SET main.tyre_cost = main.tyre_cost+tyre.cost
FROM @temp_records_complete main
INNER JOIN @temp_records_complete_tyre tyre ON tyre.qddm_regno=main.qddm_regno;

UPDATE  main SET main.repair_cost = main.repair_cost+repair.cost
FROM @temp_records_complete main
INNER JOIN @temp_records_complete_repair repair ON repair.qddm_regno=main.qddm_regno;


DECLARE @temp_records_complete_temp TABLE
(
client_code VARCHAR(10),
period_month VARCHAR(10),
qddm_regno VARCHAR(120),
make_model VARCHAR(512),
vehicle_category VARCHAR(120),
first_reg_date VARCHAR(120),
fleet_age int,
contract_type VARCHAR(120),
customer_branch varchar(120),
accident_cost DECIMAL(12,2),
breakdown_cost DECIMAL(12,2),
repair_cost DECIMAL(12,2),
service_cost DECIMAL(12,2),
tyre_cost DECIMAL(12,2),
maitenance_total_cost DECIMAL(12,2) NOT NULL DEFAULT 0.0,
all_data TEXT
)


INSERT INTO @temp_records_complete_temp
SELECT client_code,period_month,qddm_regno,make_model,vehicle_category,first_reg_date,fleet_age,contract_type,customer_branch,
		0.0 , 0.0 ,cost ,0.0 , 0.0 , 0.0 ,null
FROM @temp_records_complete_repair where qddm_regno NOT IN (select qddm_regno from @temp_records_complete);

INSERT INTO @temp_records_complete_temp
SELECT client_code,period_month,qddm_regno,make_model,vehicle_category,first_reg_date,fleet_age,contract_type,customer_branch,
		0.0 , 0.0 ,0.0 ,0.0 , cost , 0.0 ,null
FROM @temp_records_complete_tyre 
where qddm_regno NOT IN (select qddm_regno from @temp_records_complete) AND qddm_regno NOT IN (select qddm_regno from @temp_records_complete_temp);

-- UPDATE BOTH TYRE AND REPAIR AMMOUNT
UPDATE  main SET main.tyre_cost = tyre.cost
FROM @temp_records_complete_temp main
INNER JOIN @temp_records_complete_tyre tyre ON tyre.qddm_regno=main.qddm_regno;

UPDATE  main SET main.repair_cost = repair.cost
FROM @temp_records_complete_temp main
INNER JOIN @temp_records_complete_repair repair ON repair.qddm_regno=main.qddm_regno;

-- Add records with no invoice entries
insert into @temp_records_complete
select * from @temp_records_complete_temp


UPDATE @temp_records_complete SET maitenance_total_cost=(accident_cost+breakdown_cost+repair_cost+service_cost+tyre_cost+maitenance_total_cost);

UPDATE @temp_records_complete SET all_data=CONCAT(client_code,'|',period_month,'|',qddm_regno,'|',make_model,'|',vehicle_category,'|',
first_reg_date,'|',CAST(fleet_age as VARCHAR(32)),'|',contract_type,'|',customer_branch,'|',
CAST(accident_cost as VARCHAR(32)),'|',CAST(breakdown_cost as VARCHAR(32)),'|',CAST(repair_cost as VARCHAR(32)),'|',
CAST(service_cost as VARCHAR(32)),'|',CAST(tyre_cost as VARCHAR(32)),'|',CAST(maitenance_total_cost as VARCHAR(32)));

UPDATE @temp_records_complete SET all_data=CONCAT(all_data,'|',( select Count(*) from @temp_records_complete ));
-- select * from @temp_records_complete;

select 'Client Code|Tran_Month|Reg Nr|Make & Model|Vehicle Category|Date of First Reg|Fleet Age|Contract Type|Customer Branch|Accident Cost|Breakdown Cost|Repair Cost|Service Cost|Tyre Cost|Maintenance Total Cost|Record Count'
union all
select all_data  from @temp_records_complete -- where breakdown_cost>0.0;
-- where qddm_regno='CF224796'
-- select distinct(qddm_regno) from @temp_records_complete
/*
DZ11YBGP
FG18LJGP
HBM232FS
HZ44XDGP
*/

-- CF106929

-- @start_date,@end_date,'SHOPRITE CHECKERS','5001057',qddm_regno,'Repairs')
-- -- Nov2021
-- Declare @start_date as date = '2021-10-31'
-- Declare @end_date as date = '2021-11-28'
/*
select  PLN_INVOICEDITEM.AMOUNTEXCLVAT,* from PLN_INVOICEDITEM 
	INNER JOIN FLEETVEHICLE ON PLN_INVOICEDITEM.FLEETVEHICLE_ID = FLEETVEHICLE.FLEETVEHICLE_ID
	JOIN PLN_ORDERITEM ON PLN_ORDERITEM.ORDERITEMNUMBER=PLN_INVOICEDITEM.ORDERITEMNUMBER
	JOIN PLN_ORDERITEM oi ON oi.ORDERITEMNUMBER = PLN_INVOICEDITEM.ORDERITEMNUMBER
	JOIN ORDERS od ON od.ORDERS_ID=oi.ORDERITEM_ID
	WHERE CUSTOMER_ID ='5001057'
	-- AND INVOICEDITEMDATE >= '2021-10-31' AND INVOICEDITEMDATE <= '2021-11-28'
	and od.ORDERDATE >='2021-10-31' AND od.ORDERDATE <= '2021-11-28'
	AND FLEETVEHICLE.LICENSEPLATE='CF224796'
	AND PLN_INVOICEDITEM.INCIDENT_ID IS NULL
	AND PLN_ORDERITEM.ACTIONONVPGROUP IS NOT NULL
   --  AND PLN_ORDERITEM.ACTIONONVPGROUP IN  (SELECT category FROM shoprite_checkers_cat_map WHERE category_map='Repairs');


select  PLN_INVOICEDITEM.AMOUNTINCLVAT,* from PLN_INVOICEDITEM 
	INNER JOIN FLEETVEHICLE ON PLN_INVOICEDITEM.FLEETVEHICLE_ID = FLEETVEHICLE.FLEETVEHICLE_ID
	JOIN PLN_ORDERITEM ON PLN_ORDERITEM.ORDERITEMNUMBER=PLN_INVOICEDITEM.ORDERITEMNUMBER
	JOIN PLN_ORDERITEM oi ON oi.ORDERITEMNUMBER = PLN_INVOICEDITEM.ORDERITEMNUMBER
	JOIN ORDERS od ON od.ORDERS_ID=oi.ORDERITEM_ID
	WHERE CUSTOMER_ID ='5001057'
	-- AND INVOICEDITEMDATE >= '2021-10-31' AND INVOICEDITEMDATE <= '2021-11-28'
	and od.ORDERDATE >='2021-10-31' AND od.ORDERDATE <= '2021-11-28'
	AND FLEETVEHICLE.LICENSEPLATE='CF301014'
	AND PLN_INVOICEDITEM.INCIDENT_ID IS NULL
	AND PLN_ORDERITEM.ACTIONONVPGROUP IS NOT NULL


select   cu.reference ,
				 --  format(@end_date,'yyyyMMdd'),
				   fvh.LICENSEPLATE,
				   CONCAT(fvh.MAKE,' ',fvh.MODEL,' ',fvh.TYPENAME) ,
				   fvh.NATURE,
				   fvh.FIRSTREGISTRATIONDATE,
				   ls.DURATION ,
				   --ls.CALCDURATION,
				   ls.PRODUCTCATEGORY,
				   convert(varchar,ua.REFERENCE) ,
				   -- lsc.name,
				   lsc.LEASEPRICE
				from LEASESERVICECOMPONENT  lsc
			JOIN SUN_CONTRACT ct ON ct.LEASESERVICE_ID = lsc.LEASESERVICE_ID
			join PLN_LEASESERVICE ls on ls.LEASESERVICE_ID = ct.LEASESERVICE_ID
			join PLN_CUSTOMER cu on cu.CUSTOMER_ID = ct.CUSTOMER_ID
			join PLN_FLEETVEHICLE fvh on fvh.FLEETVEHICLE_ID = ct.FLEETVEHICLE_ID
			left join PLN_UNITACCOUNT ua on ua.UNITACCOUNT_ID = ct.UNITACCOUNT_ID
			where lsc.name = 'Repair and Maintenance'
			and ls.name = 'Operating Lease'
			and ct.CUSTOMER_ID = 5001057
			and ct.todate = '3000-12-31 00:00:00.000'
			AND  fvh.LICENSEPLATE='CF301014'
			and isrelevant = 1 and fvh.LICENSEPLATE IS NOT NULL AND fvh.NATURE  in ('Light Commercial Vehicle','Passenger Car','BUS');

			*/