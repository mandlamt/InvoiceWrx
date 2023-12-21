-- FML-3081 Adhoc bulk job - Extend MM contracts due and past term
-- Mandla Mtombeni

-- REMOVED (THEMBA/ARESH(BI)/WOUTER)
--PRODUCTNAME(LeaseComponentName),  SettlementDiscountPercentage : To remove duplicate

-- MODIFIED (ARESH(BI))
-- TRANSITIONDATE to MAX(L.TRANSITIONDATE) to pick the latest (MAX) date: To remove duplicate

-- MODIFIED (ARESH(BI))
-- OPTIMIZE FIELDS TO MATCH DATA

-- ADDED (WOUTER)
-- SCRIPT TO CANCELL OUT SPECIAL CHARACTERS - PARTS BRAND AND SHORT DESCRIPTION: To cancell line break

-- MODIFIED (WOUTER)
-- SCRIPT TO CANCELL OUT SPECIAL CHARACTERS - PARTS BRAND AND SHORT DESCRIPTION: To cancell line break

-- MODIFIED (WOUTER)
-- SCRIPT TO CANCELL OUT SPECIAL CHARACTERS - PARTS BRAND AND SHORT DESCRIPTION: To cancell line break ENHACED WITH CHAR (3)

-- REMOVED (THEMBA/WOUTER)
--SHORT DESCRIPTION : TO REMOVE LINE BREAKS - NEED TO OPTIMIZE FOR FUTURE USE

-- ***MACROCOMM REPORT USES 18 FIELDS VS PRIOR EXTRACT OF 72 FIELDS. OPTIMISING TO MATCH MACROCOMM DATA*** (WOUTER,ANEESA,ERLO(MACROCOMM)

-- Modified (WOUTER)
-- Structured according to the Macrocomm Field names. NATURE|MAKE|MODEL|LICENSEPLATE|QUOTATIONTEMPLATE|PRODUCTCATEGORY|WORKORDER_ID|ORDERNUMBER|ORDERDATE|SupplierName|CompCategory|SHORTDESCRIPTION|CHARGEONAMOUNT|SAVINGS|SAVINGSREASON|QUANTITY|INVOICENUMBER

-- Modified (WOUTER)
-- Added Fields WorkOrderDistance and WORKORDERSTATUS  -  EXTRACT MODIFIED TO USE 20 FIELDS.

-- PROG Begins here
drop PROCEDURE dbo.shoprite_maintenance_get_data
GO

CREATE PROCEDURE dbo.shoprite_maintenance_get_data
AS BEGIN
        -- Checking if the temp tables exists and if it does then it drops the table---
--***Bol 'true' for rebill and 'false' for FML Fund Payment***



IF OBJECT_ID('tempdb..#TEMP_CONTRACT_DETAILS') IS NOT NULL DROP TABLE #TEMP_CONTRACT_DETAILS
    IF OBJECT_ID('tempdb..#RMTASKS') IS NOT NULL DROP TABLE #RMTASKS
    IF OBJECT_ID('tempdb..#TEMP_ORDERITEMS') IS NOT NULL DROP TABLE #TEMP_ORDERITEMS
    
    SELECT C.CONTRACT_ID
          ,C.REFERENCE AS CONTRACTREFERENCE
          ,C.UNITACCOUNT_ID
          ,UA.NAME AS UNITACCOUNTNAME
          ,UA.REFERENCE AS UNITACCOUNTREFERENCE
          ,C.STARTDATE
          ,C.FROMDATE
          ,C.ENDDATE
          ,C.TODATE
          ,PC.TRADINGNAME AS CUSTOMERNAME
          ,PC.CUSTOMER_ID
          ,FV.FLEETVEHICLE_ID
          ,FV.NATURE
         --,case when (FV.NATURE) like '%Vehicle%'
         --            or (FV.NATURE) like '%Car%'
         --       then 'Must have 17 Diget Vin'                                             --Vin must be 17 Characters
         --  when (FV.NATURE) like '%Forklift%'
         --        OR (FV.NATURE) like '%Specialized Equipment%'
         --        OR (FV.NATURE) like '%Undefined%'
         --       then 'Not mandatory to have Vin, Could have serial'                           --Not Mandatory
         --  when (FV.NATURE) like '%TRAILER%'
         --        OR (FV.NATURE) like '%ARMOUR%'
         --       then 'Between 12 and 17 Diget Vin'                                            --Variable Vin Formating
         --    else 'OTHER'
         -- end                                          AS 'Vin Validation'
          ,FV.MAKE
          ,FV.MODEL
          ,FV.FIRSTREGISTRATIONDATE
          ,FV.LICENSEPLATE
          ,FV.CHASSISNUMBER
          ,FV.ENGINENUMBER
          ,FV.LASTKNOWNDISTANCE
          ,FV.LASTKNOWNDISTANCEDATE
          ,FV.DESCRIPTION AS MODELDESCRIPTION
          ,C.STATUS
          ,QT.NAME AS QUOTATIONTEMPLATE
          ,LS.PRODUCTCATEGORY
          ,LS.DURATION
          ,LS.DISTANCE
          --,MLS.PRODUCTNAME as LeaseComponentName
    INTO #TEMP_CONTRACT_DETAILS
    FROM SUN_CONTRACT       C     
    join SUN_QUOTE          SQ on SQ.QUOTE_ID = C.QUOTE_ID
    join QUOTATIONTEMPLATE  QT On QT.QUOTATIONTEMPLATE_ID = SQ.QUOTATIONTEMPLATE_ID
    join PLN_CUSTOMER       PC on PC.CUSTOMER_ID = C.CUSTOMER_ID
    join PLN_FLEETVEHICLE   FV on FV.FLEETVEHICLE_ID   = C.FLEETVEHICLE_ID
    join PLN_LEASESERVICE   LS on ls.LEASESERVICE_ID = C.LEASESERVICE_ID
    --LEFT JOIN MON_LSCOMPONENTS   MLS ON MLS.LSCOMPONENTS_ID = LS.LSCOMPONENTS_ID and MLS.SERVICETYPEGROUPCODE = 1008
    LEFT JOIN PLN_UNITACCOUNT UA ON UA.UNITACCOUNT_ID = C.UNITACCOUNT_ID
    WHERE C.ISACTIVE = 1
    --AND 
    --PC.TRADINGNAME like '%SHOPRITE%'
    --AND C.CONTRACT_ID = 5000001
    --AND PC.CUSTOMER_ID = 5020907

    SELECT ORMT.ORDERRMTASK_ID
          ,ORMT.ORDERRMTASKNUMBER
          ,ORMT.LABOURRATE
          ,ORMT.LABOURCOST
          ,ORMT.CHARGEONAMOUNT
          ,ORMT.LABOURDISCOUNT
          ,ORMT.PARTPRICE
          ,ORMT.PARTDISCOUNT
          ,ORMT.PARTCOST
          , CHARGEOUTREASON.description as CHARGEOUTREASON
          , SAVINGSREASON.description as SAVINGSREASON
          --,DBO.GETENUMML(d_rmtask.CHARGEOUTREASON, 1)         AS CHARGEOUTREASON
          ,d_rmtask.SAVINGS
          --,DBO.GETENUMML(d_rmtask.SAVINGSREASON, 1)               AS SAVINGSREASON             
            ,ORMT.QUANTITY
    INTO #RMTASKS
    FROM MON_ORDERRMTASKS     ORMT        --on PO.ORDERRMTASK_ID        = ORMT.ORDERRMTASK_ID
    join D_ORDERRMTASK        d_rmtask    on d_rmtask.ORDERRMTASK_ID  = ORMT.ORDERRMTASKNUMBER
    left outer join DBO.sysenumeration CHARGEOUTREASON  on CHARGEOUTREASON.sysenumeration_id = d_rmtask.CHARGEOUTREASON
    left outer join DBO.sysenumeration SAVINGSREASON  on SAVINGSREASON.sysenumeration_id = d_rmtask.SAVINGSREASON




    SELECT PO.ORDERITEM_ID
          ,PO.ORDERITEMNUMBER
          ,PO.ORDERRMTASK_ID
          ,PO.COMPLETIONDATE
          ,PO.APPROVALDATE
          ,PO.SERVICETYPE
          ,PO.DESCRIPTION AS PartBrand
          ,PO.ACTIONONVPGROUP
          ,PO.PARTDESCRIPTION  as CompCategory
          ,PO.SHORTDESCRIPTION
          ,PO.AMOUNTEXCLVAT
          ,PO.AMOUNTINCLVAT
          ,OI.ACTIONONVP_ID
          ,d_orders.customerpo
          ,case when UPPER(PO.ACTIONONVPGROUP) like '%MAINT%'
                     or UPPER(PO.ACTIONONVPGROUP) like '%SERVICE%'
                then 'MAINTENANCE'
           when UPPER(PO.ACTIONONVPGROUP) like '%REPAIR%'
                     or UPPER(PO.ACTIONONVPGROUP) like '%DAMAGE%'
                     or UPPER(PO.ACTIONONVPGROUP) like '%REFURBISH%'
                then 'REPAIR'
                  when UPPER(PO.ACTIONONVPGROUP) like '%TYRE%'
                     or UPPER(PO.ACTIONONVPGROUP) like '%TIRE%'
                then 'TYRES'
             else 'OTHER'
          end                                          as MainCategory
          , COMPONENTCLASS.description as   SubCategory   
          --,DBO.GETENUMML(D_VP.COMPONENTCLASS, 1)  AS SubCategory
          ,localInvoice.invoicenumber as InvoiceNumber 
          ,ICS.invoicestate_enumid
          ,ENUM1.DESCRIPTION AS invoicestate
          ,ics.coststatedate as invoicestatedate

    INTO #TEMP_ORDERITEMS
    FROM PLN_ORDERITEM            PO          --on PO.ORDERITEM_ID    = WO.ORDERITEM_ID
    JOIN ORDERITEM                OI          ON OI.ORDERITEM_ID    = PO.ORDERITEMNUMBER AND OI.ACTIONONVP_ID IS NOT NULL
    JOIN [ACTIONONVP]            AVP         ON OI.actiononvp_id = AVP.actiononvp_id 
    JOIN [VEHICLEPART]           VP          ON AVP.vehiclepart_id = VP.vehiclepart_id AND VP.vehiclepart_id is not NULL
    JOIN [D_VEHICLEPART]         D_VP        ON VP.vehiclepart_id = D_VP.vehiclepart_id
    LEFT JOIN d_orders ON d_orders.orders_id=OI.orders_id
    left outer join invoiceditem AS II       ON II.orderitem_id = OI.orderitem_id
    LEFT OUTER JOIN incomingcoststate AS ICS ON ICS.incomingcoststate_id = II.incomingcoststate_id
    LEFT OUTER JOIN sysenumeration AS ENUM1 ON ENUM1.sysenumeration_id = ICS.invoicestate_enumid
    LEFT JOIN (   SELECT incomingcoststate.invoicenumber,orderitem.orders_id,orderitem.orderitem_id FROM orderitem  
    LEFT JOIN invoiceditem ON invoiceditem.orderitem_id = orderitem.orderitem_id
    LEFT join incomingcoststate ON incomingcoststate.incomingcoststate_id = invoiceditem.incomingcoststate_id) localInvoice ON localInvoice.orders_id=PO.ORDERITEM_ID AND localInvoice.orderitem_id=PO.ORDERITEMNUMBER
    left outer join DBO.sysenumeration COMPONENTCLASS  on COMPONENTCLASS.sysenumeration_id = D_VP.COMPONENTCLASS

/*Insert Temp Table */

    SELECT  Distinct -- 83147
          -- TCD.*
         TCD.CONTRACT_ID
        ,TCD.CONTRACTREFERENCE
        ,TCD.UNITACCOUNT_ID
        ,TCD.UNITACCOUNTNAME
        ,TCD.UNITACCOUNTREFERENCE
        ,TCD.STARTDATE
        ,TCD.FROMDATE
        ,TCD.ENDDATE
        ,TCD.TODATE
        ,TCD.CUSTOMERNAME
        ,TCD.FLEETVEHICLE_ID
        ,TCD.NATURE
        ,TCD.MAKE
        ,TCD.MODEL
        ,TCD.FIRSTREGISTRATIONDATE
        ,TCD.LICENSEPLATE
        ,TCD.CHASSISNUMBER
        ,TCD.ENGINENUMBER
        ,TCD.LASTKNOWNDISTANCE
        ,TCD.LASTKNOWNDISTANCEDATE
        ,TCD.MODELDESCRIPTION
        ,TCD.STATUS
        ,TCD.QUOTATIONTEMPLATE
        ,TCD.PRODUCTCATEGORY
        ,TCD.DURATION
        ,TCD.DISTANCE
        --,TCD.LeaseComponentName
        ,WO.WORKORDER_ID
        ,WO.ORDERNUMBER
        ,WO.USER_ID
        ,USR.IDENTIFICATION
        ,WO.ORDERITEM_ID as WorkOrderItemID
        ,WO.CUSTOMER_ID
        ,WO.SUPPLIER_ID
        ,WO.FLEETVEHICLE_ID as WorkOrderFleetVehicleID
        ,WO.ORDERDATE
        ,WO.AUTHREFERENCE
        ,WO.ENDDATE as WorkOrderEndDate
        ,WO.DISTANCE as WorkOrderDistance
        ,WO.STATUS as WORKORDERSTATUS
        ,MAX(L.TRANSITIONDATE) as TRANSITIONDATE
        ,TRANSITIONSTATE.description as TRANSITIONSTATE
        --,DBO.GETENUM(L.TRANSITIONSTATE)
        ,UPPER (S.TRADINGNAME) AS TRADINGNAME
        ,UPPER(S.LEGALNAME) AS LEGALNAME
        --,SettlementDiscount.SettlementDiscountPercentage
        ,TOI.ORDERITEM_ID
        ,TOI.ORDERITEMNUMBER
        ,TOI.ORDERRMTASK_ID
        ,TOI.COMPLETIONDATE
        ,TOI.APPROVALDATE
        ,TOI.SERVICETYPE
        --,TOI.PartBrand
                ,REPLACE(
                            REPLACE(
                                REPLACE(
                                    REPLACE(
                                        REPLACE(
                                            REPLACE(
                                                REPLACE(
                                                     REPLACE(
                                                        REPLACE(
                                                            REPLACE(
                                                                REPLACE(
                                                                REPLACE(RTRIM(TOI.SHORTDESCRIPTION),
                                                            '&',' and '), -- ampersand
                                                        char(10), ' '), --new line
                                                    '/', ' '), -- forward slash
                                                '\',' '), -- backward slash
                                            ')',' '), -- close bracket
                                        char(13),' '), -- carriage return
                                    ',',' '), -- comma
                                '%', ' percentage '), -- %
                            ';', ' '), -- ;
                        char(39), ''), -- single quote '
                    char(9), ' '), -- horizontal tab
                char(3), ' ') -- end of text
                                                                                                                                as PartBrand
        ,TOI.ACTIONONVPGROUP
        ,TOI.CompCategory
        --,TOI.SHORTDESCRIPTION
        --,' ' 
        ,REPLACE(
                          REPLACE(
                              REPLACE(
                                  REPLACE(
                                      REPLACE(
                                          REPLACE(
                                              REPLACE(
                                                   REPLACE(
                                                      REPLACE(
                                                          REPLACE(
                                                              REPLACE(
                                                              REPLACE(RTRIM(TOI.SHORTDESCRIPTION),
                                                          '&',' and '), -- ampersand
                                                      char(10), ' '), --new line
                                                  '/', ' '), -- forward slash
                                              '\',' '), -- backward slash
                                          ')',' '), -- close bracket
                                      char(13),' '), -- carriage return
                                  ',',' '), -- comma
                              '%', ' percentage '), -- %
                          ';', ' '), -- ;
                      char(39), ''), -- single quote '
                  char(9), ' '), -- horizontal tab
              char(3), ' ') -- end of text
                                                                                                                              as SHORTDESCRIPTION
        ,TOI.AMOUNTEXCLVAT
        ,TOI.AMOUNTINCLVAT
        ,TOI.ACTIONONVP_ID
        ,TOI.MainCategory
        ,TOI.SubCategory
        ,(CASE
            WHEN (TOI.InvoiceNumber ) IS NULL
            THEN 'NOT INVOICED'
            ELSE 'INVOICE CAPTURED'
            END) AS 'INV/NOTINV'
        ,RMT.ORDERRMTASKNUMBER
        ,RMT.LABOURRATE
        ,RMT.LABOURCOST
        ,RMT.CHARGEONAMOUNT
        ,RMT.LABOURDISCOUNT
        ,RMT.PARTPRICE
        ,RMT.PARTDISCOUNT
        ,RMT.PARTCOST
        ,RMT.CHARGEOUTREASON
        ,ISNULL (RMT.SAVINGS,0)                     AS SAVINGS
        ,RMT.SAVINGSREASON           
        ,RMT.QUANTITY
        ,TOI.InvoiceNumber 
        ,TOI.customerpo
        ,case when ((RMT.CHARGEONAMOUNT)-(TOI.AMOUNTEXCLVAT)) = 0
                then 'TRUE'
                     else 'FALSE'
          end                                          as Recharge_Indicator
        ,invoicestate
        ,invoicestatedate
        
    INTO #temp_MM_Total 
    FROM SUN_WORKORDER            WO
    JOIN PLN_SUPPLIER             S           ON S.SUPPLIER_ID      = WO.SUPPLIER_ID  
    JOIN #TEMP_ORDERITEMS         TOI         ON TOI.ORDERITEM_ID   = WO.ORDERITEM_ID
    JOIN #TEMP_CONTRACT_DETAILS   TCD         ON TCD.CONTRACT_ID    = WO.CONTRACT_ID
    JOIN #RMTASKS                 RMT         ON RMT.ORDERRMTASK_ID = TOI.ORDERRMTASK_ID
    JOIN PLN_USER                 USR         ON USR.USER_ID        = WO.USER_ID
    

    LEFT OUTER JOIN RELOBJECT R ON R.OBJECT_ID     = WO.ORDERITEM_ID     AND ( R.SYSREPOBJECT_ID = 266 )
    LEFT OUTER JOIN LIFECYCLE L ON L.LIFECYCLE_ID  = R.LIFECYCLE_ID
    --left join (select ltr.COL2,MAX(SUBSTRING(ltr.result0,3,len(ltr.result0))) as SettlementDiscountPercentage
    --          from LOOKUPTABLE lt
    --          join LOOKUPTABLEROW ltr on ltr.LOOKUPTABLE_ID = lt.LOOKUPTABLE_ID
    --          where lt.NAME like 'Supplier Early Payment Discount'
    --          and ltr.col3 IN (501481,  501492)
    --          --and SUBSTRING(ltr.result0,3,len(ltr.result0))  <> '0.0' 
    --          ) as SettlementDiscount on SettlementDiscount.COL2 = S.SUPPLIER_ID
    
    left outer join DBO.sysenumeration TRANSITIONSTATE  on TRANSITIONSTATE.sysenumeration_id = L.TRANSITIONSTATE
    WHERE  WO.STATUS <> 'History'
   --WHERE WO.STATUS NOT IN ('Disapproved')
    and WO.STATUSCODE = L.TRANSITIONSTATE
    and TCD.CUSTOMERNAME LIKE '%shoprite%'
    --AND  ORDERNUMBER = '6528834'
   -- AND WO.ORDERDATE < '2023-10-01 00:00:00'
  --  AND WO.ORDERDATE >= '2023-09-01 00:00:00'
    --and 
        --WO.WORKORDER_ID = '6422555'
        --AND TCD.UNITACCOUNTNAME LIKE '%3562%'
    --AND TCD.LICENSEPLATE ='CF84018'
    --and TOI.customerpo like '%231065%' 
    
GROUP BY 
         TCD.CONTRACT_ID
        ,TCD.CONTRACTREFERENCE
        ,TCD.UNITACCOUNT_ID
        ,TCD.UNITACCOUNTNAME
        ,TCD.UNITACCOUNTREFERENCE
        ,TCD.STARTDATE
        ,TCD.FROMDATE
        ,TCD.ENDDATE
        ,TCD.TODATE
        ,TCD.CUSTOMERNAME
        ,TCD.FLEETVEHICLE_ID
        ,TCD.NATURE
        ,TCD.MAKE
        ,TCD.MODEL
        ,TCD.FIRSTREGISTRATIONDATE
        ,TCD.LICENSEPLATE
        ,TCD.CHASSISNUMBER
        ,TCD.ENGINENUMBER
        ,TCD.LASTKNOWNDISTANCE
        ,TCD.LASTKNOWNDISTANCEDATE
        ,TCD.MODELDESCRIPTION
        ,TCD.STATUS
        ,TCD.QUOTATIONTEMPLATE
        ,TCD.PRODUCTCATEGORY
        ,TCD.DURATION
        ,TCD.DISTANCE
        --,TCD.LeaseComponentName
        ,WO.WORKORDER_ID
        ,WO.ORDERNUMBER
        ,WO.USER_ID
        ,USR.IDENTIFICATION
        ,WO.ORDERITEM_ID
        ,WO.CUSTOMER_ID
        ,WO.SUPPLIER_ID
        ,WO.FLEETVEHICLE_ID
        ,WO.ORDERDATE
        ,WO.AUTHREFERENCE
        ,WO.ENDDATE 
        ,WO.DISTANCE
        ,WO.STATUS
        ,TRANSITIONSTATE.description 
        --,DBO.GETENUM(L.TRANSITIONSTATE)
        ,S.TRADINGNAME
        ,S.LEGALNAME
        --,SettlementDiscount.SettlementDiscountPercentage
        ,TOI.ORDERITEM_ID
        ,TOI.ORDERITEMNUMBER
        ,TOI.ORDERRMTASK_ID
        ,TOI.COMPLETIONDATE   -- add field case - completed
        ,TOI.APPROVALDATE
        ,TOI.SERVICETYPE
        ,TOI.PartBrand
        ,TOI.ACTIONONVPGROUP
        ,TOI.CompCategory
        ,TOI.SHORTDESCRIPTION
        ,TOI.AMOUNTEXCLVAT
        ,TOI.AMOUNTINCLVAT
        ,TOI.ACTIONONVP_ID
        ,TOI.MainCategory
        ,TOI.SubCategory
        ,RMT.ORDERRMTASKNUMBER
        ,RMT.LABOURRATE
        ,RMT.LABOURCOST
        ,RMT.CHARGEONAMOUNT
        ,RMT.LABOURDISCOUNT
        ,RMT.PARTPRICE
        ,RMT.PARTDISCOUNT
        ,RMT.PARTCOST
        ,RMT.CHARGEOUTREASON
        ,RMT.SAVINGS
        ,RMT.SAVINGSREASON           
        ,RMT.QUANTITY
        ,TOI.InvoiceNumber 
        ,TOI.customerpo
        -- add invoice paid
        ,invoicestate
        --,INV/NOTINV
        ,invoicestatedate
    

    SELECT 
    --'CONTRACT_ID|CONTRACTREFERENCE|UNITACCOUNT_ID|UNITACCOUNTNAME|UNITACCOUNTREFERENCE|STARTDATE|FROMDATE|ENDDATE|TODATE|CUSTOMERNAME|FLEETVEHICLE_ID|NATURE|MAKE|MODEL|FIRSTREGISTRATIONDATE|LICENSEPLATE|CHASSISNUMBER|ENGINENUMBER|LASTKNOWNDISTANCE|LASTKNOWNDISTANCEDATE|MODELDESCRIPTION|STATUS|QUOTATIONTEMPLATE|PRODUCTCATEGORY|DURATION|DISTANCE|WORKORDER_ID|ORDERNUMBER|USER_ID|USERNAME|WorkOrderItemID|CUSTOMER_ID|SUPPLIER_ID|WorkOrderFleetVehicleID|ORDERDATE|AUTHREFERENCE|WorkOrderEndDate|WorkOrderDistance|WORKORDERSTATUS|TRANSITIONDATE|TRANSITIONSTATUS|SupplierName|SupplierGroup|ORDERITEM_ID|ORDERITEMNUMBER|ORDERRMTASK_ID|COMPLETIONDATE|APPROVALDATE|SERVICETYPE|PartBrand|ACTIONONVPGROUP|CompCategory|SHORTDESCRIPTION|AMOUNTEXCLVAT|AMOUNTINCLVAT|ACTIONONVP_ID|MainCategory|SubCategory|ORDERRMTASKNUMBER|LABOURRATE|LABOURCOST|CHARGEONAMOUNT|LABOURDISCOUNT|PARTPRICE|PARTDISCOUNT|PARTCOST|CHARGEOUTREASON|SAVINGS|SAVINGSREASON|QUANTITY|INVOICENUMBER|CUSTOMERPO'
    'NATURE|MAKE|MODEL|LICENSEPLATE|UNITACCOUNTNAME|CUSTOMER|AMOUNTEXCLVAT|QUOTATIONTEMPLATE|PRODUCTCATEGORY|WORKORDER_ID|ORDERNUMBER|WORKORDERSTATUS|WORKORDERDISTANCE|ORDERDATE|SUPPLIERNAME|COMPCATAGORY|SHORTDESCRIPTION|CHARGEONAMOUNT|SAVINGS|SAVINGSREASON|QUANTITY|INVOICENUMBER|CUSTOMERPO|SERVICETYPE|INVOICESTATUS|INVOICESTATUSDATE|RECHARGEIND'
    UNION ALL
    SELECT  CONCAT(mmt.NATURE
            ,'|',mmt.MAKE
            ,'|',mmt.MODEL
            ,'|',mmt.LICENSEPLATE
            ,'|',mmt.UNITACCOUNTNAME
            ,'|',mmt.CUSTOMERNAME
            ,'|',mmt.AMOUNTEXCLVAT
            ,'|',mmt.QUOTATIONTEMPLATE
            ,'|',mmt.PRODUCTCATEGORY
            ,'|',mmt.WORKORDER_ID
            ,'|',mmt.ORDERNUMBER
            ,'|',mmt.WORKORDERSTATUS
            ,'|',mmt.WorkOrderDistance
            ,'|',mmt.ORDERDATE
            ,'|',mmt.TRADINGNAME
            ,'|',mmt.CompCategory
            ,'|',mmt.SHORTDESCRIPTION
            ,'|',mmt.CHARGEONAMOUNT
            ,'|',mmt.SAVINGS
            ,'|',mmt.SAVINGSREASON
            ,'|',mmt.QUANTITY
            ,'|',mmt.InvoiceNumber 
            ,'|',mmt.customerpo 
            ,'|',mmt.SERVICETYPE 
            ,'|',mmt.invoicestate
            ,'|',mmt.invoicestatedate
            --,'|',add (mmt.SAVINGS)
            ,'|',mmt.Recharge_Indicator

    ) as 'all_data'
    FROM #Temp_MM_Total mmt
    -- Date Fildering
    --WHERE mmt.ORDERDATE >= '2022-08-01' AND mmt.ORDERDATE <= '2022-08-31' 

    DROP TABLE #RMTASKS
    DROP TABLE #TEMP_CONTRACT_DETAILS
    DROP TABLE #TEMP_ORDERITEMS
    DROP TABLE #Temp_MM_Total
     
RETURN;
END;
GO
-- exec dbo.shoprite_maintenance_get_data