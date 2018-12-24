SELECT A.value             AS ASSETID,
C.EM_AM_SOL_ID          AS BRANCHCODE,
D.NAME                  AS AssetType,
D.DESCRIPTION           AS Description,
A.DESCRIPTION           AS Details,
B.EM_AM_PRODUCT_CODE    AS AssetSubtype,
A.DATEPURCHASED         AS purchasedate,
COALESCE(Z.depreciationFY,0) as depre,
a.em_am_usage_date AS USAGEDATE,
A.ISFULLYDEPRECIATED,
PV.bv as  PRESENTVALUE,
SUM(ROUND(A.EM_AM_PURCHASE_COST+COALESCE(A.EM_AM_ADDITIONAL_COST,0)-COALESCE(A.EM_AM_CREDIT_TAKEN,0),2)) AS Purchasecost,
C.name                                                                                                   AS BRANCHNAME,
CASE
   WHEN A.ISDISPOSED='Y'
   THEN 'B'
   ELSE 'A'
END                                         AS STATUS,
ROUND(100/a.annualamortizationpercentage,0) AS DYEARS ,
A.ANNUALAMORTIZATIONPERCENTAGE              AS DEPRPERCENT,
ROUND(SUM((COALESCE(A.em_am_purchase_cost,0)+COALESCE(A.EM_AM_ADDITIONAL_COST,0)-COALESCE(A.EM_AM_CREDIT_TAKEN,0))-(COALESCE(A.em_am_bookvalue,0))),2) AS AccDep,
case when A.EM_AM_USAGE_DATE is null then EXTRACT( MONTH FROM A.DATEPURCHASED) else
EXTRACT( MONTH FROM A.EM_AM_USAGE_DATE)  end AS MONTH,
case when A.EM_AM_USAGE_DATE is null then EXTRACT( YEAR FROM A.DATEPURCHASED) else
EXTRACT( YEAR FROM A.EM_AM_USAGE_DATE)  end AS YEAR,
case when A.EM_AM_USAGE_DATE is null then EXTRACT( DAY FROM A.DATEPURCHASED) else
EXTRACT( DAY FROM A.EM_AM_USAGE_DATE)  end AS DAY,
COALESCE(PV.bv-COALESCE(Z.depreciationFY,0),0) as  WDBASONN
FROM a_asset A
left join
(select sum(amortizationamt) as depreciationFY,a_asset_id from a_amortizationline where
em_am_dateacct>to_date('01-07-2018','DD-MM-YYYY') and  em_am_dateacct<=to_date('30-10-2018','DD-MM-YYYY') group by a_asset_id) Z
on A.a_asset_id=Z.a_asset_id
left join
(select coalesce(em_am_book_value,0) as bv,a_asset_id from a_amortizationline where
em_am_dateacct=to_date('30-09-2018','DD-MM-YYYY') ) PV
on A.a_asset_id=PV.a_asset_id
, m_product B
, AD_org C
, a_asset_group D
WHERE
A.m_product_id=B.m_product_id and
A.Ad_org_id=C.AD_ORG_ID and
B.EM_AM_A_ASSET_GROUP_ID=D.A_ASSET_GROUP_ID 
and A.Ad_Org_Id ='8D8C4DA4E0EA471C949D2778597638ED'
--and A.Ad_Org_Id = Case When $P{AD_ORG_ID} Is Not Null Then $P{AD_ORG_ID} Else C.Ad_Org_Id End
and A.isactive='Y'
and a.isdisposed<>'Y'
and a.em_am_istrnso<>'Y'
--and a.a_asset_id='4998C7AAF2ED4743B2543F2691682652'
GROUP BY A.A_ASSET_ID,
C.EM_AM_SOL_ID,
D.DESCRIPTION,
B.EM_AM_PRODUCT_CODE,
D.NAME,
A.DATEPURCHASED,
A.AMORTIZATIONSTARTDATE,
A.DESCRIPTION,
PV.bv,
A.EM_AM_PURCHASE_COST,
A.ANNUALAMORTIZATIONPERCENTAGE,
A.em_am_usage_date,
A.ISFULLYDEPRECIATED,
Z.depreciationFY,
A.ISDISPOSED,
C.name,
A.value;