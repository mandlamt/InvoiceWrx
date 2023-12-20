select qddm_deal 'Deal Number',
	   isnull(drm_name, drm_longname) 'Client Name',
	   NULL 'Selling Dealer',
	   NULL 'Sales Person',
	   qdqm_type 'Contract Type',
	   qddm_billcount,
	   qddm_regno 'Registration No',
	   qddm_chassisno 'Chassis No',
	   qdqm_start 'Start Date',
	   qddm_termdate 'Term Date',
	   bvvm_desc 'Vehicle_Description',
	   bvmom_desc 'Model',
	   qdqm_period 'Term',
	   qddm_billcount 'Current Age', 
	   qdqm_period - qddm_billcount 'Months Remaining',
	   qddm_numinst 'Months Billed',
	   qdqm_tkms 'NTE Kilometers',
	   qdqm_mkms 'Contract Ave Monthly Km',
	   qddm_odo 'Current ODO',
	   qddm_odo/nullif(qddm_billcount,0) 'Maintenance Per Month',
	   isnull((select sum(qddt_amount) from qddt where qddt_ref in ('CPK MAINT','MAINT') and qddt_fk_deal = deal.qddm_deal),0.00) 'Maintenance Income',
	   isnull((select sum(opmhd_amount) from MaintHistory where opmhd_fk_deal = qddm_deal),0) as 'Maintenance Expense',	
	   isnull((select sum(qddt_amount) from qddt where qddt_ref in ('CPK MAINT','MAINT') and qddt_fk_deal = deal.qddm_deal),0.00) - isnull((select sum(opmhd_amount) from MaintHistory where opmhd_fk_deal = qddm_deal),0) 'Maintenance Fund',
	   (select sk_value from sk where sk_id = 'utc_vat') 'Maintenance Fund VAT',
	   (isnull((select sum(qddt_amount) from qddt where qddt_ref in ('CPK MAINT','MAINT') and qddt_fk_deal = deal.qddm_deal),0.00) - isnull((select sum(opmhd_amount) from MaintHistory where opmhd_fk_deal = qddm_deal),0))*1.15 'Maintenance Fund (with VAT)',
	   case when qdqm_type in ('W-SP-MONTHLY','W-MP-MONTHLY')
	        then (qdqm_mainsell / qdqm_mkms)
	        when qdqm_type in ('W-SP-UPFRONT','W-MP-UPFRONT')
	        then (qdqm_mainsell / qdqm_mkms)
	        when qdqm_type in ('W-SP-CPK','W-MP-CPK')
	        then (qdqm_vbcpkmaintsell + qdqm_vbcpktyresell) / 100
	    else 0.00 end 'Contract CPK',
	    NULL 'Service Interval',
	    case when qdqm_type in ('W-SP-CPK','W-SP-UPFRONT','W-SP-MONTHLY')
	         then 'UD - BASIC'
	         when qdqm_type in ('W-MP-UPFRONT','W-MP-CPK','W-MP-MONTHLY')
	         then 'UD TRUST ULTIMATE'
	     else 'Other' end 'Plan Type'			    
from  qddm deal
		left join qdqm on qdqm_quote = qddm_fk_quote
		left join (select qddt_fk_deal,
						   sum(qddt_amount) ServiceAmount
				    from qddt
					where qddt_ref = 'SERVICES'
					group by qddt_fk_deal) AdminFee on AdminFee.qddt_fk_deal = qddm_deal
		left join drm on drm_accno =  qdqm_fk_accno
		left join bvvm on qdqm_fk_man = bvvm_fk_man and qdqm_fk_mod = bvvm_fk_mod and qdqm_fk_var = bvvm_var
		left join bvmm on bvvm_fk_man = bvmm_man
		left join bvmom on bvvm_fk_man = bvmom_fk_man and bvvm_fk_mod =bvmom_mod
		left join ( select current_dealno, maint_income, maint_expense
		            from Func_QD_ReloadedDealDetails( NULL, getdate())) ReloadedDeal on ReloadedDeal.current_dealno = qddm_deal
		where qddm_new = 'y'
		and qddm_term != 'y'
		and qdqm_type in ('W-SP-CPK','W-SP-MONTHLY','W-SP-UPFRONT','W-MP-CPK','W-MP-MONTHLY','W-MP-UPFRONT')