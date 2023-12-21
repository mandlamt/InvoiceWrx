-- THEMBA SIVATE
declare @db varchar(100) = (select db_name());

if @db NOT like 'WBSACFG%'
begin
 set noexec on
end;
GO

CREATE FUNCTION dbo.shoprite_checkers_get_sum ( @AuthStartDate DATETIME, @AuthEndDate DATETIME, @Debtor_Name VARCHAR (120),@AccountNumber VARCHAR (12), @registration_number varchar(32), @category_type varchar(64) )
RETURNS DECIMAL(12,2)
AS Begin

   DECLARE @sum DECIMAL(12,2)=0.0;
   select @sum= CONVERT(DECIMAL(14,2),SUM(PLN_INVOICEDITEM.AMOUNTEXCLVAT)) from PLN_INVOICEDITEM 
	INNER JOIN FLEETVEHICLE ON PLN_INVOICEDITEM.FLEETVEHICLE_ID = FLEETVEHICLE.FLEETVEHICLE_ID
	JOIN PLN_ORDERITEM ON PLN_ORDERITEM.ORDERITEMNUMBER=PLN_INVOICEDITEM.ORDERITEMNUMBER

	JOIN PLN_ORDERITEM oi ON oi.ORDERITEMNUMBER = PLN_INVOICEDITEM.ORDERITEMNUMBER
	JOIN ORDERS od ON od.ORDERS_ID=oi.ORDERITEM_ID

	WHERE CUSTOMER_ID = @AccountNumber
	AND od.ORDERDATE >= @AuthStartDate AND od.ORDERDATE <= @AuthEndDate
	AND FLEETVEHICLE.LICENSEPLATE=@registration_number
	AND PLN_INVOICEDITEM.INCIDENT_ID IS NULL
	AND PLN_ORDERITEM.ACTIONONVPGROUP IS NOT NULL
    AND PLN_ORDERITEM.ACTIONONVPGROUP IN  (SELECT category FROM shoprite_checkers_cat_map WHERE category_map=@category_type);

	if @sum IS NULL 
	BEGIN
	  SET @sum=0.0;
	END;
RETURN @sum;
END;
GO
CREATE FUNCTION dbo.shoprite_checkers_get_sum2 ( @AuthStartDate DATETIME, @AuthEndDate DATETIME, @Debtor_Name VARCHAR (120),@AccountNumber VARCHAR (12), @registration_number varchar(32), @category_type varchar(64) )
RETURNS DECIMAL(12,2)
AS Begin

   DECLARE @sum DECIMAL(12,2)=0.0;
   select @sum=CONVERT(DECIMAL(14,2),SUM(PLN_INVOICEDITEM.AMOUNTINCLVAT)) from PLN_INVOICEDITEM 
	INNER JOIN FLEETVEHICLE ON PLN_INVOICEDITEM.FLEETVEHICLE_ID = FLEETVEHICLE.FLEETVEHICLE_ID
	JOIN PLN_ORDERITEM ON PLN_ORDERITEM.ORDERITEMNUMBER=PLN_INVOICEDITEM.ORDERITEMNUMBER
	JOIN SUN_INCIDENT ON SUN_INCIDENT.INCIDENT_ID= PLN_INVOICEDITEM.INCIDENT_ID
	WHERE PLN_INVOICEDITEM.CUSTOMER_ID = @AccountNumber
	AND  INVOICEDITEMDATE >= @AuthStartDate  AND INVOICEDITEMDATE <= @AuthEndDate
	and PLN_INVOICEDITEM.INCIDENT_ID IS NOT NULL
	-- AND PLN_ORDERITEM.ACTIONONVPGROUP IS NOT NULL
	AND SUN_INCIDENT.INCIDENTTYPE='Breakdown'
    AND FLEETVEHICLE.LICENSEPLATE=@registration_number;

	if @sum IS NULL 
	BEGIN
	  SET @sum=0.0;
	END;
RETURN @sum;
END;
GO

CREATE PROCEDURE dbo.shoprite_checkers_get_data
AS BEGIN
     DECLARE @temp_records_complete TABLE ( all_data TEXT );
     DECLARE @cur_date DATE=GETDATE();
	 DECLARE @jul_id INT;
	 DECLARE @start_date DATE;
	 DECLARE @end_date DATE;
	 DECLARE @transfer_date DATE;
	 
	IF EXISTS (SELECT TOP 1 * FROM dbo.shoprite_checkers_julien_calendar WHERE extracted=0 AND transfer_date<= @cur_date )
	BEGIN
	   SELECT TOP 1   @jul_id=jul_id,
					  @start_date=month_start,
					  @end_date=month_end,
					  @transfer_date=transfer_date
				      FROM shoprite_checkers_julien_calendar WHERE extracted=0 AND transfer_date<= @cur_date ORDER BY transfer_date ASC;
    
	 -- LETS UPDATE THE TO EXTRACTED
	   UPDATE dbo.shoprite_checkers_julien_calendar SET extracted=1 WHERE jul_id=@jul_id;
	 -- LETS EXTRACT IT
	    SELECT 'Client Code|Tran_Month|Reg Nr|Make & Model|Vehicle Category|Date of First Reg|Fleet Age|Contract Type|Customer Branch|Accident Cost|Breakdown Cost|Repair Cost|Service Cost|Tyre Cost|Maintenance Total Cost|Record Count'
		UNION ALL
		SELECT all_data FROM  dbo.shoprite_checkers_generate_data (@start_date,@end_date,'SHOPRITE CHECKERS (PTY) LTD','5001057');	

	END
	ELSE
	BEGIN
	   SELECT 'not_ready_to_extract';
	END; 
     
RETURN;
END;
GO
-- exec shoprite_checkers_get_data
-- select * from shoprite_checkers_julien_calendar
-- UPDATE shoprite_checkers_julien_calendar SET extracted=1 where jul_id in(9)
-- UPDATE shoprite_checkers_julien_calendar SET extracted=0 where jul_id in(12)
-- END GET DATA

-- SELECT all_data FROM  shoprite_checkers_generate_data ('2021-10-31','2021-11-28','SHOPRITE CHECKERS (PTY) LTD','5001057');	

CREATE FUNCTION dbo.shoprite_checkers_generate_data (@start_date DATETIME, @end_date DATETIME, @Debtor_Name VARCHAR (120),@customer_id int /*5001057*/ )
RETURNS @temp_records_complete TABLE 
	(
			client_code VARCHAR(10),
			period_month VARCHAR(10),
			qddm_regno VARCHAR(32),
			make_model VARCHAR(512),
			vehicle_category VARCHAR(120),
			first_reg_date VARCHAR(32),
			fleet_age int,
			contract_type VARCHAR(32),
			customer_branch VARCHAR(120),
			accident_cost DECIMAL(12,2),
			breakdown_cost DECIMAL(12,2),
			repair_cost DECIMAL(12,2),
			service_cost DECIMAL(12,2),
			tyre_cost DECIMAL(12,2),
			maitenance_total_cost DECIMAL(12,2) NOT NULL DEFAULT 0.0,
            all_data TEXT
	)
AS BEGIN

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


RETURN;
END;

GO
set noexec off