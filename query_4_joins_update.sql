with facebook_data as (select ad_date, campaign_name, adset_name, 
		spend, impressions, reach, clicks, leads, value, 'facebook' as media_source
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
		clicks, leads, value, 'google' as media_source
		from google_ads_basic_daily)
/*Соединил данные про рекламные кампании с платформ гугл и фейсбук в одну таблицу*/
select ad_date, media_source, campaign_name, adset_name, sum(spend) as sum_spend,
sum(impressions) as sum_impressions, sum(clicks) as sum_clicks, sum(value) as sum_value
from all_data
group by ad_date, media_source, campaign_name, adset_name
/*Агрегированные данные по дням, источнику, названию кампании, названию объявления*/

with facebook_data as (select ad_date, campaign_name, adset_name, 
		spend, impressions, reach, clicks, leads, value, 'facebook' as media_source
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
		clicks, leads, value, 'google' as media_source
		from google_ads_basic_daily)
/*Соединил данные про рекламные кампании с платформ гугл и фейсбук в одну таблицу*/
select campaign_name, sum(spend) as sum_spend, sum(impressions) as sum_impressions, 
sum(clicks) as sum_clicks, sum(value) as sum_value, 
round(((sum(value) :: numeric) -sum(spend))/sum(spend)*100,2) as ROMI
from all_data
group by campaign_name
having sum(spend) > 500000
order by round(((sum(value) :: numeric) -sum(spend))/sum(spend)*100,2) desc
limit 1
/*Максимальный РОМИ по рекламным кампаниям Promos*/

with facebook_data as (select ad_date, campaign_name, adset_name, 
		spend, impressions, reach, clicks, leads, value, 'facebook' as media_source
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
		clicks, leads, value, 'google' as media_source
		from google_ads_basic_daily)
/*Соединил данные про рекламные кампании с платформ гугл и фейсбук в одну таблицу*/
/*Соединил данные про рекламные кампании с платформ гугл и фейсбук в одну таблицу*/
select adset_name, sum(spend) as sum_spend,
sum(impressions) as sum_impressions, sum(clicks) as sum_clicks, sum(value) as sum_value,
round(((sum(value) :: numeric) -sum(spend))/sum(spend)*100,2) as ROMI
from all_data
where campaign_name = (select campaign_name
						from all_data
						group by campaign_name
						having sum(spend) > 500000
						order by round(((sum(value) :: numeric) -sum(spend))/sum(spend)*100,2) desc
						limit 1)
group by adset_name
/*В кампании Promos только один adset_name соответственно группа обїявлений с наибольшим РОМИ это Parents*/

