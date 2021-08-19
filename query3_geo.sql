with t1 as (
   select
       snap.user_id
       , snap.snapshot_date
       , snap.provider_id
       , c.pay_group
       , coalesce(ep.location_id, -1) as location_id
   from
     "SNOWCAT"."PROD"."DIM_PROVIDER_ACCOUNT"
       left join dim_provider_account pa on pa.customer_user_id = snap.customer_user_id and pa.provider_id = snap.provider_id
       left join dim_customer_persona ep on ep.customer_user_id = snap.customer_user_id and ep.provider_id = snap.provider_id
       left join dim_company c on c.id = pa.company_id
   where
       snap.snapshot_date >= '2020-01-01'
       and is_eligible_by_status_strict = True
)
, geo as (
   select
       pay_group
       , provider_id
       , coalesce (location_id, -1) as location_id
       , state
   from
      "SNOWCAT"."PROD"."RPT_PAY_GROUP_GEOLOCATION"
)
, t2 as (
   select
       t1.*
       , state
   from
       t1
       left join geo on geo.provider_id = t1.provider_id and geo.pay_group = t1.pay_group and geo.location_id = t1.location_id
)
select
   snapshot_date
   , provider_id
   , state
   , count(distinct user_id) as eligible
from
   t2
group by
   snapshot_date
   , provider_id
   , state
order by
   provider_id, snapshot_date;

