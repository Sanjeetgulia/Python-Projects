--SQL Advance Case Study


--Q1--BEGIN 
 
	SELECT
	State, Date
	FROM DIM_LOCATION AS T1
	INNER JOIN FACT_TRANSACTIONS AS T2
	ON T1.IDLocation = T2.IDLocation
	WHERE YEAR(Date) BETWEEN 2005 AND GETDATE()


--Q1--END

--Q2--BEGIN
	
	SELECT TOP 1
	State,
	SUM(Quantity) AS TOT_QUANTITY
	FROM DIM_LOCATION AS T5
	INNER JOIN (
				SELECT
				T3.IDManufacturer, Manufacturer_Name, IDModel, IDLocation, Quantity
				FROM DIM_MANUFACTURER AS T3
				INNER JOIN (
							SELECT
							T1.IDModel, IDManufacturer, IDLocation, Quantity
							FROM DIM_MODEL AS T1
							INNER JOIN FACT_TRANSACTIONS AS T2
							ON T1.IDModel = T2.IDModel
							) AS T4
				ON T3.IDManufacturer = T4.IDManufacturer
				) AS T6
	ON T5.IDLocation = T6.IDLocation
	WHERE Manufacturer_Name = 'SAMSUNG' AND Country = 'US'
	GROUP BY  State
	ORDER BY TOT_QUANTITY DESC    

--Q2--END

--Q3--BEGIN      

	SELECT 
	MODEL_NAME,
	[STATE],
	ZIPCODE,
	COUNT(QUANTITY) AS [NO._OF_TRANSACTIONS]
	FROM DIM_LOCATION AS X
	INNER JOIN FACT_TRANSACTIONS AS Y
	ON X.IDLocation = Y.IDLocation
	INNER JOIN DIM_MODEL AS Z
	ON Y.IDModel = Z.IDModel
	GROUP BY Model_Name, ZipCode, [STATE]

--Q3--END

--Q4--BEGIN	SELECT TOP 1
	Model_Name,
	Unit_price
	FROM DIM_MODEL
	ORDER BY Unit_price 

--Q4--END

--Q5--BEGIN

	SELECT TOP 5                             
	T1.IDManufacturer, T1.IDModel,
	SUM(QUANTITY) AS TOT_QUANTITY,
	AVG(Unit_price) AS AVG_PRICE 
	FROM DIM_MODEL AS T1
	LEFT JOIN FACT_TRANSACTIONS AS T2
	ON T1.IDModel = T2.IDModel             
	GROUP BY T1.IDModel, T1.IDManufacturer
	ORDER BY TOT_QUANTITY DESC , AVG_PRICE DESC
	         
--Q5--END

--Q6--BEGIN

	SELECT
	Customer_Name, AVG_AMT, YEAR
	FROM DIM_CUSTOMER AS X 
	INNER JOIN (
				SELECT
				AVG(TotalPrice) AS AVG_AMT, YEAR, IDCustomer
				FROM FACT_TRANSACTIONS AS T1
				INNER JOIN DIM_DATE AS T2
				ON T1.Date = T2.DATE
				WHERE YEAR = 2009
				GROUP BY YEAR, IDCustomer
				HAVING AVG(TotalPrice) > 500
				) AS Y
	ON X.IDCustomer = Y.IDCustomer


--Q6--END
	
--Q7--BEGIN  

		SELECT * FROM ( 	
		    SELECT TOP 5
			IDModel 
			FROM FACT_TRANSACTIONS
			WHERE YEAR(Date) = '2008'
			GROUP BY IDModel , YEAR(DATE)
			ORDER BY SUM(Quantity) DESC ) AS T1
			   INTERSECT
		SELECT * FROM (
			SELECT TOP 5                                  
			IDModel
			FROM FACT_TRANSACTIONS
			WHERE YEAR(Date) = '2009'
			GROUP BY IDModel,  YEAR(DATE)
			ORDER BY SUM(Quantity) DESC ) AS T2
			   INTERSECT
		SELECT * FROM (
			SELECT TOP 5
			IDModel 
			FROM FACT_TRANSACTIONS
			WHERE YEAR(Date) = '2010'
			GROUP BY IDModel, YEAR(DATE) 
			ORDER BY SUM(Quantity) DESC ) AS T3





--Q7--END	
--Q8--BEGIN
 
	SELECT * 
	FROM (
			SELECT TOP 1
			Manufacturer_Name,
			Y.IDManufacturer,
			[YEAR],
			SUM_SALES
			FROM DIM_MANUFACTURER AS X
			INNER JOIN  (
						SELECT TOP 2
						IDManufacturer,
						YEAR(DATE) AS [YEAR],
						SUM(TotalPrice) AS SUM_SALES
						FROM FACT_TRANSACTIONS AS T1
						INNER JOIN DIM_MODEL AS T2
						ON T1.IDModel = T2.IDModel
						WHERE YEAR(Date) = 2009
						GROUP BY  IDManufacturer, YEAR(DATE)
					    ) AS Y
            ON X.IDManufacturer = Y.IDManufacturer
			ORDER BY SUM_SALES ASC
				
			UNION ALL                                      
			
			SELECT TOP 1
			Manufacturer_Name,
			Y.IDManufacturer,
			[YEAR],
			SUM_SALES
			FROM DIM_MANUFACTURER AS X
			INNER JOIN  (
						SELECT TOP 2
						IDManufacturer,
						YEAR(DATE) AS [YEAR],
						SUM(TotalPrice) AS SUM_SALES
						FROM FACT_TRANSACTIONS AS T1
						INNER JOIN DIM_MODEL AS T2
						ON T1.IDModel = T2.IDModel
						WHERE YEAR(Date) = 2010
						GROUP BY  IDManufacturer, YEAR(DATE)
						ORDER BY SUM_SALES DESC
					    ) AS Y
            ON X.IDManufacturer = Y.IDManufacturer  
			ORDER BY SUM_SALES ASC
	  ) AS Y





--Q8--END
--Q9--BEGIN

	SELECT 
	Manufacturer_Name, X1.IDManufacturer
	FROM DIM_MANUFACTURER AS X
	INNER JOIN	(
				SELECT
				IDManufacturer
				FROM DIM_MODEL AS T1
				INNER JOIN FACT_TRANSACTIONS AS T2
				ON T1.IDModel = T2.IDModel
				WHERE YEAR(Date) = 2010 
				) AS X1
	ON X.IDManufacturer = X1.IDManufacturer
	
	EXCEPT
				 				   
	SELECT 
	Manufacturer_Name, X1.IDManufacturer
	FROM DIM_MANUFACTURER AS X
	INNER JOIN	(
				SELECT
				IDManufacturer
				FROM DIM_MODEL AS T1
				INNER JOIN FACT_TRANSACTIONS AS T2
				ON T1.IDModel = T2.IDModel
				WHERE YEAR(Date) = 2009
				) AS X1
	ON X.IDManufacturer = X1.IDManufacturer



--Q9--END

--Q10--BEGIN

	SELECT 
	YEARS,
	IDCustomer,
	AVG(TotalPrice) AS AVG_SPEND,
	AVG(Quantity) AS AVG_QUANT,
	LAG(AVG(TOTALPRICE),1) OVER ( ORDER BY IDCUSTOMER) AS PREV,
	(AVG(TOTALPRICE) - LAG(AVG(TOTALPRICE),1) OVER ( ORDER BY IDCUSTOMER)) / (LAG(AVG(TOTALPRICE),1) OVER (ORDER BY IDCUSTOMER)) * 100 AS [YOY_CHANGE]
	FROM (
			SELECT TOP 10
			IDCustomer,
			YEAR(Date) AS [YEARS],
			TotalPrice,
			Quantity
			FROM FACT_TRANSACTIONS
			ORDER BY TotalPrice DESC
			) AS X
	GROUP BY IDCustomer, YEARS, TotalPrice



--Q10--END
	