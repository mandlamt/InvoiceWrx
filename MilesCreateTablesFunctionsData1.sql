declare @db varchar(100) = (select db_name());

if @db like 'WBSACFG%'
begin

IF EXISTS (SELECT * FROM   sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[shoprite_checkers_generate_data]') AND type IN ( N'FN', N'IF', N'TF', N'FS', N'FT' ))
BEGIN
   drop function dbo.shoprite_checkers_generate_data;
END;


IF EXISTS ( SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.shoprite_checkers_get_data'))
BEGIN
   drop procedure dbo.shoprite_checkers_get_data;
END;

IF EXISTS (SELECT * FROM   sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[shoprite_checkers_get_sum2]') AND type IN ( N'FN', N'IF', N'TF', N'FS', N'FT' ))
BEGIN
   drop function shoprite_checkers_get_sum2;
END;
IF EXISTS (SELECT * FROM   sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[shoprite_checkers_get_sum]') AND type IN ( N'FN', N'IF', N'TF', N'FS', N'FT' ))
BEGIN
   drop function shoprite_checkers_get_sum;
END;

IF EXISTS   (SELECT object_id FROM sys.tables  WHERE name = 'shoprite_checkers_cat_map')
BEGIN
	drop table dbo.shoprite_checkers_cat_map;
END;

IF EXISTS   (SELECT object_id FROM sys.tables  WHERE name = 'shoprite_checkers_julien_calendar')
BEGIN
	drop table dbo.shoprite_checkers_julien_calendar;
END;
--SELECT object_id,* FROM sys.tables  WHERE name = 'shoprite_checkers_cat_map'
-- CREATE TABLES AND FUNCTIONS
create table dbo.shoprite_checkers_cat_map(
category varchar(256) NOT NULL UNIQUE,
category_map varchar(256) NOT NULL
);

create table dbo.shoprite_checkers_julien_calendar(
jul_id INT IDENTITY PRIMARY KEY,
month_name varchar(32) NOT NULL,
month_year varchar(32) NULL,
weeks varchar(32) NULL,
month_start DATE,
month_end DATE,
transfer_date DATE,
extracted BIT NOT NULL DEFAULT 0,
reserved1 varchar(256) NULL,
reserved2 varchar(256) NULL
);


INSERT INTO shoprite_checkers_julien_calendar(month_name,month_year,month_start,month_end,transfer_date) 
VALUES('July','2020','2020-06-20','2020-07-26','2020-08-01');
INSERT INTO shoprite_checkers_julien_calendar(month_name,month_year,month_start,month_end,transfer_date) 
VALUES('August','2020','2020-07-27','2020-08-23','2020-09-01');
INSERT INTO shoprite_checkers_julien_calendar(month_name,month_year,month_start,month_end,transfer_date) 
VALUES('September','2020','2020-08-24','2020-09-27','2020-10-01');
INSERT INTO shoprite_checkers_julien_calendar(month_name,month_year,month_start,month_end,transfer_date) 
VALUES('October','2020','2020-09-28','2020-10-25','2020-11-01');
INSERT INTO shoprite_checkers_julien_calendar(month_name,month_year,month_start,month_end,transfer_date) 
VALUES('November','2020','2020-10-26','2020-11-22','2020-12-01');
INSERT INTO shoprite_checkers_julien_calendar(month_name,month_year,month_start,month_end,transfer_date) 
VALUES('December','2020','2020-11-23','2020-12-27','2021-01-01');
INSERT INTO shoprite_checkers_julien_calendar(month_name,month_year,month_start,month_end,transfer_date) 
VALUES('January','2021','2020-12-28','2021-01-24','2021-02-01');
INSERT INTO shoprite_checkers_julien_calendar(month_name,month_year,month_start,month_end,transfer_date) 
VALUES('February','2021','2021-01-25','2021-02-21','2021-03-01');
INSERT INTO shoprite_checkers_julien_calendar(month_name,month_year,month_start,month_end,transfer_date) 
VALUES('March','2021','2021-02-22','2021-03-28','2021-04-01');
INSERT INTO shoprite_checkers_julien_calendar(month_name,month_year,month_start,month_end,transfer_date) 
VALUES('April','2021','2021-03-29','2021-04-25','2021-05-01');
INSERT INTO shoprite_checkers_julien_calendar(month_name,month_year,month_start,month_end,transfer_date) 
VALUES('May','2021','2021-04-26','2021-05-23','2021-06-01');
INSERT INTO shoprite_checkers_julien_calendar(month_name,month_year,month_start,month_end,transfer_date) 
VALUES('June','2021','2021-05-24','2021-07-04','2021-07-05');
INSERT INTO shoprite_checkers_julien_calendar(month_name,month_year,month_start,month_end,transfer_date) 
VALUES('July','2021','2021-07-05','2021-08-01','2021-08-02');
INSERT INTO shoprite_checkers_julien_calendar(month_name,month_year,month_start,month_end,transfer_date) 
VALUES('August','2021','2021-08-02','2021-08-28','2021-09-01');
INSERT INTO shoprite_checkers_julien_calendar(month_name,month_year,month_start,month_end,transfer_date) 
VALUES('September','2021','2021-08-29','2021-10-02','2021-10-03');
INSERT INTO shoprite_checkers_julien_calendar(month_name,month_year,month_start,month_end,transfer_date) 
VALUES('October','2021','2021-10-03','2021-10-30','2021-11-01');
INSERT INTO shoprite_checkers_julien_calendar(month_name,month_year,month_start,month_end,transfer_date) 
VALUES('November','2021','2021-10-31','2021-11-27','2021-12-01');
INSERT INTO shoprite_checkers_julien_calendar(month_name,month_year,month_start,month_end,transfer_date) 
VALUES('December','2021','2021-11-28','2022-01-01','2022-01-02');
INSERT INTO shoprite_checkers_julien_calendar(month_name,month_year,month_start,month_end,transfer_date) 
VALUES('January','2022','2022-01-02','2022-01-29','2022-02-01');
INSERT INTO shoprite_checkers_julien_calendar(month_name,month_year,month_start,month_end,transfer_date) 
VALUES('February','2022','2022-01-30','2022-02-26','2022-03-01');
INSERT INTO shoprite_checkers_julien_calendar(month_name,month_year,month_start,month_end,transfer_date) 
VALUES('March','2022','2022-02-27','2022-04-02','2022-04-03');
INSERT INTO shoprite_checkers_julien_calendar(month_name,month_year,month_start,month_end,transfer_date) 
VALUES('April','2022','2022-04-03','2022-04-30','2022-05-01');
INSERT INTO shoprite_checkers_julien_calendar(month_name,month_year,month_start,month_end,transfer_date) 
VALUES('May','2022','2022-05-01','2022-05-28','2022-06-01');
INSERT INTO shoprite_checkers_julien_calendar(month_name,month_year,month_start,month_end,transfer_date) 
VALUES('June','2022','2022-05-29','2022-07-02','2022-07-03');

INSERT INTO shoprite_checkers_julien_calendar(month_name,month_year,month_start,month_end,transfer_date) 
VALUES('July','2022','2022-07-03','2022-07-31','2022-08-01');
INSERT INTO shoprite_checkers_julien_calendar(month_name,month_year,month_start,month_end,transfer_date) 
VALUES('August','2022','2022-08-01','2022-08-28','2022-09-01');
INSERT INTO shoprite_checkers_julien_calendar(month_name,month_year,month_start,month_end,transfer_date) 
VALUES('September','2022','2022-08-29','2022-10-02','2022-10-03');
INSERT INTO shoprite_checkers_julien_calendar(month_name,month_year,month_start,month_end,transfer_date) 
VALUES('October','2022','2022-10-03','2022-10-30','2022-11-01');
INSERT INTO shoprite_checkers_julien_calendar(month_name,month_year,month_start,month_end,transfer_date) 
VALUES('November','2022','2022-10-31','2022-11-27','2022-12-01');
INSERT INTO shoprite_checkers_julien_calendar(month_name,month_year,month_start,month_end,transfer_date) 
VALUES('December','2022','2022-11-28','2023-01-01','2023-01-02');
INSERT INTO shoprite_checkers_julien_calendar(month_name,month_year,month_start,month_end,transfer_date) 
VALUES('January','2023','2023-01-02','2023-01-29','2023-02-01');
INSERT INTO shoprite_checkers_julien_calendar(month_name,month_year,month_start,month_end,transfer_date) 
VALUES('February','2023','2023-01-30','2023-02-26','2023-03-01');
INSERT INTO shoprite_checkers_julien_calendar(month_name,month_year,month_start,month_end,transfer_date) 
VALUES('March','2023','2023-02-27','2023-04-02','2023-04-03');
INSERT INTO shoprite_checkers_julien_calendar(month_name,month_year,month_start,month_end,transfer_date) 
VALUES('April','2023','2023-04-03','2023-04-30','2023-05-01');
INSERT INTO shoprite_checkers_julien_calendar(month_name,month_year,month_start,month_end,transfer_date) 
VALUES('May','2023','2023-05-01','2023-05-28','2023-06-01');
INSERT INTO shoprite_checkers_julien_calendar(month_name,month_year,month_start,month_end,transfer_date) 
VALUES('June','2023','2023-05-29','2023-07-02','2023-07-03');
--select * from shoprite_checkers_julien_calendar where jul_id<=26
--UPDATE shoprite_checkers_julien_calendar SET extracted=1 where jul_id<=26

/*
2023 FY	Weeks	Month End
July	4	31-Jul-22
August	4	28-Aug-22
September	5	02-Oct-22
October	4	30-Oct-22
November	4	27-Nov-22
December	5	01-Jan-23
January	4	29-Jan-23
February	4	26-Feb-23
March	5	02 Apr 23
April	4	30-Apr-23
May	4	28-May-23
June	5	02-Jul-23
*/


-- select * from shoprite_checkers_julien_calendar
UPDATE dbo.shoprite_checkers_julien_calendar SET extracted=1 where jul_id<=25;
-- UPDATE shoprite_checkers_julien_calendar SET extracted=0 where jul_id>15;
 -- SERVICETYPE
/*Certificate of Fitness
Fee
Repair and Maintenance
Summer Tires
Accessory Purchase
Managed Maintenance
Vehicle Purchase
License renewal
Damage Repair */
/*
INSERT INTO shoprite_checkers_cat_map(category,category_map) VALUES('Certificate of Fitness','Repairs');
INSERT INTO shoprite_checkers_cat_map(category,category_map) VALUES('Damage Repair','Repairs');
INSERT INTO shoprite_checkers_cat_map(category,category_map) VALUES('Repair and Maintenance','Repairs');
INSERT INTO shoprite_checkers_cat_map(category,category_map) VALUES('Managed Maintenance','Service');
INSERT INTO shoprite_checkers_cat_map(category,category_map) VALUES('License renewal','Service');
INSERT INTO shoprite_checkers_cat_map(category,category_map) VALUES('Accessory Purchase','Service');
INSERT INTO shoprite_checkers_cat_map(category,category_map) VALUES('Fee','Service');
INSERT INTO shoprite_checkers_cat_map(category,category_map) VALUES('Summer Tires','Tyres');
*/
INSERT INTO shoprite_checkers_cat_map(category,category_map) VALUES('Fuel Purchase','Breakdown');
INSERT INTO shoprite_checkers_cat_map(category,category_map) VALUES('Damage repair','Repairs');
INSERT INTO shoprite_checkers_cat_map(category,category_map) VALUES('Maintenance','Repairs');
INSERT INTO shoprite_checkers_cat_map(category,category_map) VALUES('Refurbishment','Repairs');
INSERT INTO shoprite_checkers_cat_map(category,category_map) VALUES('Repairs (Accident Mgmt)','Accident');
INSERT INTO shoprite_checkers_cat_map(category,category_map) VALUES('Service Interval','Service');
INSERT INTO shoprite_checkers_cat_map(category,category_map) VALUES('Service parts','Service');
INSERT INTO shoprite_checkers_cat_map(category,category_map) VALUES('Tyre action','Tyres');
INSERT INTO shoprite_checkers_cat_map(category,category_map) VALUES('Tyre replacement','Tyres');
--INSERT INTO shoprite_checkers_cat_map(category,category_map) VALUES('Accident','Repairs (Accident Mgmt)');

-- select distinct(SERVICETYPE) from PLN_INVOICEDITEM WHERE CUSTOMER_ID = 5001057 
end
else begin
  print('wrong database!');
end



