SELECT 
C.em_am_sol_id AS SOLID,
C.name                                                                                                   AS BRANCHNAME,
SUM(ROUND(A.EM_AM_PURCHASE_COST+COALESCE(A.EM_AM_ADDITIONAL_COST,0)-COALESCE(A.EM_AM_CREDIT_TAKEN,0),2)) AS PurchaseValue
COALESCE(Z.depreciationFY,0) as depre,
--A.EM_AM_BOOKVALUE                                                                                       AS PRESENTVALUE


FROM a_asset A
left join
(select sum(amortizationamt) as depreciationFY,a_asset_id from a_amortizationline where
em_am_dateacct>to_date('01-04-2018','DD-MM-YYYY') and  em_am_dateacct<=to_date('30-06-2018','DD-MM-YYYY') group by a_asset_id) Z
on A.a_asset_id=Z.a_asset_id
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
GROUP BY
C.EM_AM_SOL_ID,
D.NAME,
A.EM_AM_BOOKVALUE,
A.EM_AM_PURCHASE_COST,
Z.depreciationFY,
C.name,
A.value;