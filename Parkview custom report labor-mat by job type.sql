

--	Testing:	Devtest\sql2017 - Parkview_10012020
--	OR
--				pds-lt-01\sql2017 - ParkviewFacProd210625

declare @jobTypes table(
	jobTypeCode	varchar(50)
)
insert into @jobTypes
select CODE
from aims.cod 
where [TYPE] = 'j'	
	and code = 'JGREMO'	

declare @facilities table(
	facilityCode varchar(50)
)
insert into @facilities
select CODE
from aims.cod 
where [TYPE] = 'y'

declare @costCenters table(
	costCenterCode varchar(50)
)
insert into @costCenters
select CODE
from aims.cod 
where [TYPE] = 'a'

declare  @start datetime = '1/1/2021'
		,@end	datetime = '1/1/2021'

select 
	 jobType.[NAME]						as [Job Type]
	,facName.[NAME]						as Facility
	,cc.[NAME]							as [Cost Center]
	,datename(month,wko.REQST_DATETIME)	as [Reporting Month]
	,wko.WO_NUMBER						as [WO #]
	,wkoType.[code]						as [WO Type]
	,wkoStatus.[NAME]					as [WO Status]
	,wko.REQST_DATETIME					as [Requested Date]
	,case 
		when wko.WO_STATUS in ('CL','PS')
			then convert(varchar(50),wko.STAT_DATETIME)
		else '' 
	 end								as [Closed Date]
	,case when wct.RATE_MULTI <= 1.0	
		then wct.[HOURS]
		else 0.0
	 end								as [Reg Hrs]
	,case when wct.RATE_MULTI > 1.0 
		then wct.[HOURS]
		else 0.0
	 end								as [OT Hrs]
	,case when wct.COSTING_TYPE = 'h' 
		then wct.[HOURS] * wct.CHG_RATE * wct.RATE_MULTI
		else wct.CHG_RATE
	 end								as [Labor $]
	,case when wct.[ACTION] is not null 
		then wct.[ACTION] 
		else resp.[NAME]
	 end								as [Response / Action]
	,wct.DONE_DATETIME					as [Labor Date]
	,coalesce(empName.[name]
				,vndName.[name] 
				,cVndName.[name])		as [E/V/C]
	,'Period ' 
		+ convert(varchar(20),convert(date,@start),101)
		+ ' - ' 
		+ convert(varchar(20),convert(date,@end),101)
										as periodDates
from aims.WKO					as wko
	join aims.WCT				as wct on wko.FACILITY = wct.FACILITY and wko.WO_NUMBER = wct.WO_NUMBER
		left join aims.cod		as resp on wct.RESPONSE = resp.CODE and resp.[TYPE] = 'r'
	join aims.COD				as jobType on wko.PROC_JOBTY = jobType.CODE and jobType.[TYPE] = 'j'
	join aims.cod				as facName on wko.FACILITY = facName.[CODE] and facName.[TYPE] = 'y'
	join aims.cod				as wkoType on wko.WO_TYPE = wkoType.CODE and wkoType.[TYPE] = 't'
	join aims.COD				as wkoStatus on wko.WO_STATUS = wkoStatus.CODE and wkoStatus.[TYPE] = 'w'
	left join aims.COD			as empName on wct.FACILITY = empName.FACILITY and wct.EMPLOYEE = empName.CODE and empName.[TYPE] = 'e'
	left join aims.COD			as vndName on wct.EMPLOYEE = vndName.CODE and vndName.[TYPE] = 'd' 
	left join aims.cnt			as cnt on (wct.FACILITY = cnt.FACILITY or cnt.facility = 'Main') and wct.EMPLOYEE = cnt.CONTROL_ID	
		left join aims.cod		as cVndName on cnt.[PROVIDER] = cVndName.CODE and cVndName.[TYPE] = 'd'
	left join aims.COD			as cc on wko.FACILITY = cc.FACILITY and wko.CHG_CTR = cc.CODE and cc.[TYPE] = 'a'
where convert(date,wct.DONE_DATETIME)  
			between convert(date,@start) and convert(date,@end)
	and 
	wko.PROC_JOBTY in (select jobTypeCode from @jobTypes)
	and 
	wko.FACILITY in (select facilityCode from @facilities)
	and 
	wko.CHG_CTR in (select costCenterCode from @costCenters)
order by 
	 jobType.[NAME]						
	,facName.[NAME]					
	,cc.[NAME]
	,wct.DONE_DATETIME							



--	Report-Friendly code
/*

select 
	 jobType.[NAME]						as [Job Type]
	,facName.[NAME]						as Facility
	,cc.[NAME]							as [Cost Center]
	,datename(month,wko.REQST_DATETIME)	as [Reporting Month]
	,wko.WO_NUMBER						as [WO #]
	,wkoType.[code]						as [WO Type]
	,wkoStatus.[NAME]					as [WO Status]
	,wko.REQST_DATETIME					as [Requested Date]
	,case 
		when wko.WO_STATUS in ('CL','PS')
			then convert(varchar(50),wko.STAT_DATETIME)
		else '' 
	 end								as [Closed Date]
	,case when wct.RATE_MULTI <= 1.0	
		then wct.[HOURS]
		else 0.0
	 end								as [Reg Hrs]
	,case when wct.RATE_MULTI > 1.0 
		then wct.[HOURS]
		else 0.0
	 end								as [OT Hrs]
	,case when wct.COSTING_TYPE = 'h' 
		then wct.[HOURS] * wct.CHG_RATE * wct.RATE_MULTI
		else wct.CHG_RATE
	 end								as [Labor $]
	,case when wct.[ACTION] is not null 
		then wct.[ACTION] 
		else resp.[NAME]
	 end								as [Response / Action]
	,wct.DONE_DATETIME					as [Labor Date]
	,coalesce(empName.[name]
				,vndName.[name] 
				,cVndName.[name])		as [E/V/C]
	,'Period ' 
		+ convert(varchar(20),convert(date,@start),101)
		+ ' - ' 
		+ convert(varchar(20),convert(date,@end),101)
										as periodDates
from aims.WKO					as wko
	join aims.WCT				as wct on wko.FACILITY = wct.FACILITY and wko.WO_NUMBER = wct.WO_NUMBER
		left join aims.cod		as resp on wct.RESPONSE = resp.CODE and resp.[TYPE] = 'r'
	join aims.COD				as jobType on wko.PROC_JOBTY = jobType.CODE and jobType.[TYPE] = 'j'
	join aims.cod				as facName on wko.FACILITY = facName.[CODE] and facName.[TYPE] = 'y'
	join aims.cod				as wkoType on wko.WO_TYPE = wkoType.CODE and wkoType.[TYPE] = 't'
	join aims.COD				as wkoStatus on wko.WO_STATUS = wkoStatus.CODE and wkoStatus.[TYPE] = 'w'
	left join aims.COD			as empName on wct.FACILITY = empName.FACILITY and wct.EMPLOYEE = empName.CODE and empName.[TYPE] = 'e'
	left join aims.COD			as vndName on wct.EMPLOYEE = vndName.CODE and vndName.[TYPE] = 'd' 
	left join aims.cnt			as cnt on (wct.FACILITY = cnt.FACILITY or cnt.facility = 'Main') and wct.EMPLOYEE = cnt.CONTROL_ID	
		left join aims.cod		as cVndName on cnt.[PROVIDER] = cVndName.CODE and cVndName.[TYPE] = 'd'
	left join aims.COD			as cc on wko.FACILITY = cc.FACILITY and wko.CHG_CTR = cc.CODE and cc.[TYPE] = 'a'
where convert(date,wct.DONE_DATETIME)  
			between convert(date,@start) and convert(date,@end)
	and 
	wko.PROC_JOBTY in (@jobTypes)
	and 
	wko.FACILITY in (@facilities)
	and 
	wko.CHG_CTR in (@costCenters)
order by 
	 jobType.[NAME]						
	,facName.[NAME]					
	,cc.[NAME]
	,wct.DONE_DATETIME	

*/




	