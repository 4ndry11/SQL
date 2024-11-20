with facebook_data as (select ad_date, campaign_name, adset_name, 
		spend, impressions, reach, clicks, leads, value, url_parameters, 
		'facebook' as media_source
		from facebook_ads_basic_daily
		inner join facebook_adset 
		on facebook_adset.adset_id = facebook_ads_basic_daily.adset_id 
		inner join facebook_campaign 
		on facebook_campaign.campaign_id = facebook_ads_basic_daily.campaign_id)
		/*Соединил данные из трех таблиц по рекламным кампаниям фейсбук в одну*/,
	all_data as(select *
		from facebook_data
		union
		select ad_date, campaign_name, adset_name, spend, impressions, reach, 
		clicks, leads, value, url_parameters, 'google' as media_source
		from google_ads_basic_daily)
/*Соединил данные про рекламные кампании с платформ гугл и фейсбук в одну таблицу*/,
	data as(select date_trunc('months',ad_date) as ad_month, 
			case 
				when lower(substring(url_parameters,'utm_campaign=([^&#$]+)')) = 'nan'
				then null
				else lower(substring(url_parameters,'utm_campaign=([^&#$]+)'))
			end as utm_campaign,
		    sum(coalesce(spend, 0)) as sum_spend,
		    sum(coalesce(impressions, 0)) as sum_impressions,
		    sum(coalesce(reach, 0)) as sum_reach,
		    sum(coalesce(leads, 0)) as sum_leads,
		    sum(coalesce(value, 0)) as sum_value,
		    SUM(COALESCE(clicks, 0)) as sum_clicks,
		    sum(coalesce(spend, 0)) /
		    case 
		    	when SUM(COALESCE(clicks, 0)) = 0 
		    	then 1
		    	else sum(coalesce(clicks, 0))
		    	end as CPC,
		    sum(coalesce(impressions, 0))/
		    case 
		    	when sum(coalesce(clicks, 0)) = 0 
		    	then 1
		    	else sum(coalesce(clicks, 0))
		    	end as CTR,
		    1000 * sum(coalesce(spend, 0))/
		    case 
		    	when SUM(COALESCE(impressions, 0)) = 0 
		    	then 1
		    	else sum(coalesce(impressions, 0))
		    	end as CPM,
		    100*(sum(coalesce(value, 0)) - sum(coalesce(spend, 0))) /
		    case 
		    	when sum(coalesce(spend, 0)) = 0 
		    	then 1
		    	else sum(coalesce(spend, 0))
		    	end as ROMI
		from all_data
		group by date_trunc('months',ad_date), lower(substring(url_parameters,'utm_campaign=([^&#$]+)')))
select d1.ad_month, d1.utm_campaign, d1.sum_spend, d1.sum_impressions, d1.sum_reach, d1.sum_leads, 
d1.sum_value, d1.sum_clicks, d1.cpc, d1.ctr, d1.cpm, d1.romi, 
round((d2.cpm - d1.cpm :: numeric)/d1.cpm*100,2) as difference_cpm_percentage,
round((d2.ctr - d1.ctr :: numeric)/d1.ctr*100,2) as difference_ctr_percentage,
round((d2.romi - d1.romi :: numeric)/d1.romi*100,2) as difference_romi_percentage
from data d1
left join data d2 on d1.ad_month= d2.ad_month - interval '1 month'
where d1.romi >0 