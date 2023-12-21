--- no movement for first period

update partialterm set movement = updPT.investment * -1
from partialterm pt1
join (

		select distinct 
			  c.contract_id
			, c.reference
			, c.startdate
			, ls.leaseservice_id
			, lsc.leaseservicecomponent_id
			, pt.partialterm_id
			, pt.type
			, finmvt.mvt movement
			, finInv.investment
			, (floor(isnull(finmvt.mvt,0)) + floor(finInv.investment))*-1 diff		
		from contract c			
		join 			
			(select  c.contract_id		
					, sum(pt.MOVEMENT) mvt
			FROM CONTRACT C		
			JOIN D_CONTRACT DC ON DC.CONTRACT_ID = C.CONTRACT_ID		
			JOIN CONTRACTVERSION CV ON CV.CONTRACT_ID = C.CONTRACT_ID AND CV.ISRELEVANT = 1 AND  validto > c.startdate	-- and CV.VALIDFROM <= getdate() 	
			JOIN QUOTE Q ON Q.QUOTE_ID = CV.QUOTE_ID		
			JOIN LEASESERVICE LS ON LS.LEASESERVICE_ID = Q.LEASESERVICE_ID		
			JOIN LEASESERVICECOMPONENT LSC ON LSC.LEASESERVICE_ID = LS.LEASESERVICE_ID AND LSC.SERVICETYPE_ENUMID = 430		
			JOIN RENTALPROFILE RP ON RP.RENTALPROFILE_ID = LSC.RENTALPROFILE_ID and rp.rentalcategory_enumid = 2930		 	
			LEFT JOIN PARTIALTERM PT ON PT.leaseservicecomponent_id = LSC.leaseservicecomponent_id  AND PT.type = 2927 
			  AND PT.STARTDATE = case when cv.validfrom = '1800-01-01 00:00:00.000' then c.startdate else cv.validfrom end		
			where C.CONTRACTSTATE_ENUMID IN (566,2664) 	--and c.contract_id = 5021519	 
			and isnull(pt.MOVEMENT,0) <= -100 or pt.MOVEMENT is null	
			group by c.contract_id		
			) finmvt on finmvt.contract_id = c.contract_id		
		
		 join (select c.contract_id			
				  , lsc.investment	
			 from contract c		
				JOIN CONTRACTVERSION CV ON CV.CONTRACT_ID = C.CONTRACT_ID AND CV.ISRELEVANT = 1 AND CV.VALIDFROM <= getdate() and cv.validto > getdate()	
				JOIN QUOTE Q ON Q.QUOTE_ID = CV.QUOTE_ID	
				JOIN LEASESERVICE LS ON LS.LEASESERVICE_ID = Q.LEASESERVICE_ID	
				JOIN LEASESERVICECOMPONENT LSC ON LSC.LEASESERVICE_ID = LS.LEASESERVICE_ID AND LSC.SERVICETYPE_ENUMID = 430 	
				JOIN RENTALPROFILE RP ON RP.RENTALPROFILE_ID = LSC.RENTALPROFILE_ID and rp.rentalcategory_enumid = 2930		
			) finInv on finInv.contract_id = c.contract_id 		
		JOIN CONTRACTVERSION CV ON CV.CONTRACT_ID = C.CONTRACT_ID AND CV.ISRELEVANT = 1 --AND CV.VALIDFROM <= getdate() and validto > getdate()	
		JOIN QUOTE Q ON Q.QUOTE_ID = CV.QUOTE_ID		
		JOIN LEASESERVICE LS ON LS.LEASESERVICE_ID = Q.LEASESERVICE_ID		
		JOIN LEASESERVICECOMPONENT LSC ON LSC.LEASESERVICE_ID = LS.LEASESERVICE_ID AND LSC.SERVICETYPE_ENUMID = 430		
		JOIN RENTALPROFILE RP ON RP.RENTALPROFILE_ID = LSC.RENTALPROFILE_ID	and rp.rentalcategory_enumid = 2930	
		LEFT JOIN PARTIALTERM PT ON PT.leaseservicecomponent_id = LSC.leaseservicecomponent_id AND PT.STARTDATE = c.startdate
		WHERE  C.CONTRACTSTATE_ENUMID IN (566,2664) 	
		and PT.type = 2927
		and floor(isnull(finmvt.mvt,0)) + floor(finInv.investment) >1000
) updPT on updPT.partialterm_id = pt1.partialterm_id

--update partialterm set movement = movement * -1 where partialterm_id = 