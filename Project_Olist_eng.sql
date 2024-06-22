/*Case 1 : Order Analysis

Question1: Please examine the monthly order distribution.

All Orders:*/
SELECT COUNT(ORDER_ID) AS ORDER_COUNT,
	DATE_TRUNC('month',ORDER_APPROVED_AT) AS MONTH,
	DATE_PART('month',ORDER_APPROVED_AT) || '-' || DATE_PART('year',
ORDER_APPROVED_AT) AS MONTH_YEAR
FROM ORDERS
GROUP BY 2,3
ORDER BY 2
--Excluding Canceled Orders:
SELECT COUNT(ORDER_ID) AS ORDER_COUNT,
	DATE_TRUNC('month',ORDER_APPROVED_AT) AS MONTH,
	DATE_PART('month',ORDER_APPROVED_AT) || '-' || DATE_PART('year',
ORDER_APPROVED_AT) AS MONTH_YEAR
FROM ORDERS
WHERE ORDER_STATUS <> 'canceled'
GROUP BY 2,3
ORDER BY 2
/*Comment: 
When we analyze the number of orders, 
November 2017 was the month and year with the highest number of orders; 
September 2016 was the month with the least number of orders. */

/*Additional Study:
In this question, the total number of canceled products per month and 
to access information on which products have been canceled, you can access both the products
monthly as well as by product breakdown.*/

--Total Number of Products Canceled Monthly:
SELECT COUNT(ORDER_ID) AS ORDER_COUNT,
	DATE_TRUNC('month',ORDER_APPROVED_AT) AS MONTH,
	DATE_PART('month',ORDER_APPROVED_AT) || '-' || DATE_PART('year',
	ORDER_APPROVED_AT) AS MONTH_YEAR
FROM ORDERS
WHERE ORDER_STATUS = 'canceled' AND ORDER_APPROVED_AT IS NOT NULL
GROUP BY 2,3
ORDER BY 3

--Which Products are Canceled Monthly?
SELECT O.ORDER_ID,
	P.PRODUCT_CATEGORY_NAME,
	DATE_TRUNC('month',ORDER_APPROVED_AT) AS MONTH,
	DATE_PART('month',ORDER_APPROVED_AT) || '-' || DATE_PART('year',
	ORDER_APPROVED_AT) AS MONTH_YEAR,
	COUNT(O.ORDER_ID) OVER (PARTITION BY P.PRODUCT_CATEGORY_NAME)
FROM ORDERS AS O
INNER JOIN ORDER_ITEMS AS OI ON OI.ORDER_ID = O.ORDER_ID
INNER JOIN PRODUCTS AS P ON OI.PRODUCT_ID = P.PRODUCT_ID
WHERE ORDER_STATUS = 'canceled' AND ORDER_APPROVED_AT IS NOT NULL
GROUP BY 1,2,3,4
ORDER BY 5 DESC
/*Comment:
When we examine the data, the highest number of canceled products appears in February 2018 records.
The least canceled period of ordered products is January 2017.
When we look at the 5 most canceled products, the first place is "esporte_lazer-sports_leisure- sports leisure 
categorical products. Then, in turn, "utilidades_domesticas-housewares-household goods",
"beleza_saude-healty-beauty-health-and-beauty",
"informatica_acessorios-computer accessories-computer accessories" and "brinquedos-toys-toys".*/


/*Question2 : Examine the number of orders in the order status breakdown on a monthly basis. 
Are there any months with a dramatic decrease or increase? Comment by examining the data.*/

SELECT ORDER_STATUS,
DATE_PART('month',ORDER_APPROVED_AT) || '-' || DATE_PART('year',ORDER_APPROVED_AT) AS MONTH_YEAR,
COUNT(ORDER_ID) AS ORDER_COUNT
FROM ORDERS
GROUP BY 1,2
ORDER BY 2

/*Comment:
Most orders delivered in November 2017 and March 2018 in the "Delivered" category 
2 months in November 2017. However, November 2017 data shows a dramatic increase compared to the previous months. 
is seen in the "Canceled" category. The "Canceled" category shows a high number of canceled products in September. 
Afterwards, canceled orders decreased and the most dramatic decrease belongs to December 2017 data.
In the "Shipped" category, we can say that March 2018 data is on a dramatic rise. when we examine the data set 
The first and last registrations are from September. Therefore, for September 2016 and 2018 data
I can't make a clear comment.*/

/*Additional Study:
This question also analyzed the total number of orders by order status.*/

WITH STATUS_ORDER AS
	(SELECT ORDER_STATUS,
		DATE_PART('month',ORDER_APPROVED_AT) || '-' || DATE_PART('year',
		ORDER_APPROVED_AT) AS MONTH_YEAR,
		COUNT(ORDER_ID) AS ORDER_COUNT
		FROM ORDERS
		GROUP BY 1,2
		ORDER BY 2)
SELECT *,
	SUM(ORDER_COUNT) OVER (PARTITION BY ORDER_STATUS) AS TOTAL_ORDER_BY_STATUS
FROM STATUS_ORDER

/*Question 3: 
a) Examine the number of orders by product category.
b) What are the prominent categories on special occasions? For example, New Year, Valentine's Day...*/

--a) Number of Orders by Product Category:
SELECT T.PRODUCT_CATEGORY_NAME_ENGLISH,
	COUNT(O.ORDER_ID) AS ORDER_COUNT
FROM PRODUCTS P
JOIN TRANSLATE AS T ON T.PRODUCT_CATEGORY_NAME = P.PRODUCT_CATEGORY_NAME
LEFT JOIN ORDER_ITEMS AS OI ON P.PRODUCT_ID = OI.PRODUCT_ID
LEFT JOIN ORDERS AS O ON O.ORDER_ID = OI.ORDER_ID
WHERE O.ORDER_STATUS <> 'canceled'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10

/*Additional Study: 
In this question, the number of orders both in monthly breakdown and in breakdown of categorical products ordered 
analyzed. Thus, it can be examined in more detail which products were ordered the most in which months.*/

--Aylık Olarak Ve Ürün Kategorisi Kırılımlı En Çok Sipariş Edilen İlk 10 Ürün:
SELECT T.PRODUCT_CATEGORY_NAME_ENGLISH,
	DATE_TRUNC('month',ORDER_APPROVED_AT) AS MONTH,
	COUNT(O.ORDER_ID) AS ORDER_COUNT
FROM PRODUCTS P
JOIN TRANSLATE AS T ON T.PRODUCT_CATEGORY_NAME = P.PRODUCT_CATEGORY_NAME
LEFT JOIN ORDER_ITEMS AS OI ON P.PRODUCT_ID = OI.PRODUCT_ID
LEFT JOIN ORDERS AS O ON O.ORDER_ID = OI.ORDER_ID
WHERE O.ORDER_STATUS <> 'canceled'
	AND ORDER_APPROVED_AT IS NOT NULL
GROUP BY 1,2
ORDER BY 2,3 DESC
LIMIT 10

--b) Categories that stand out on special occasions:
/*Mother's Day,
It is the 2nd Sunday of May.
For this dataset covering the years 15-09-2016-03.09.2018, Mother's Day on 8.05.2016 is not included in this dataset.
Therefore, only the dates in 2017 and 2018 were analyzed. The dates examined were: 14.05.2017 and 13.05.2018
Father's Day
14.08.2016 is not available in the dataset. Therefore, only dates in 2017 and 2018 were analyzed.
Dates examined 13.08.2017-12.08.2018 
In Brazil, Valentine's Day is celebrated every year on June 12. Therefore, instead of February 14th,
12.06.2017 and 12.06.2018 were analyzed.
Because, for this data set covering the years 15-09-2016-03.09.2018, the valentines on 12.06.2016
not included in this dataset. In addition to the special days mentioned above, 
November and December were also analyzed for Christmas and New Year's days.
For this dataset, the years 2016 and 2017 could be analyzed.*/


--Mother's Day:
SELECT T.PRODUCT_CATEGORY_NAME_ENGLISH,
	CAST(ORDER_APPROVED_AT AS date),
	COUNT(O.ORDER_ID) AS ORDER_COUNT
FROM PRODUCTS P
JOIN TRANSLATE AS T ON T.PRODUCT_CATEGORY_NAME = P.PRODUCT_CATEGORY_NAME
LEFT JOIN ORDER_ITEMS AS OI ON P.PRODUCT_ID = OI.PRODUCT_ID
LEFT JOIN ORDERS AS O ON O.ORDER_ID = OI.ORDER_ID
WHERE O.ORDER_STATUS <> 'canceled'
	AND CAST(ORDER_APPROVED_AT AS date) = '2017-05-14'
	OR CAST(ORDER_APPROVED_AT AS date) = '2018-05-13'
GROUP BY 1,2
ORDER BY 2,3 DESC
/*Comment: 
May 2017 and May 2018 data analyzed,
"health and beauty products" and "housewares" categories on Mother's Day
are seen as the most ordered categories.*/

--Father's Day:
SELECT T.PRODUCT_CATEGORY_NAME_ENGLISH,
	CAST(ORDER_APPROVED_AT AS date),
	COUNT(O.ORDER_ID) AS ORDER_COUNT
FROM PRODUCTS P
JOIN TRANSLATE AS T ON T.PRODUCT_CATEGORY_NAME = P.PRODUCT_CATEGORY_NAME
LEFT JOIN ORDER_ITEMS AS OI ON P.PRODUCT_ID = OI.PRODUCT_ID
LEFT JOIN ORDERS AS O ON O.ORDER_ID = OI.ORDER_ID
WHERE O.ORDER_STATUS <> 'canceled'
	AND CAST(ORDER_APPROVED_AT AS date) = '2017-08-13'
	OR CAST(ORDER_APPROVED_AT AS date) = '2018-08-12'
GROUP BY 1,2
ORDER BY 2,3 DESC
/*Comment: 
When August 2017 and August 2018 data are analyzed, 
it is seen that "health and beauty" products and "bed bath table" categories
stand out as the most ordered categories on Father's Day.*/

--New Year/Christmas:
WITH NT AS
	(SELECT T.PRODUCT_CATEGORY_NAME_ENGLISH,
			DATE_TRUNC('month',ORDER_APPROVED_AT) AS MONTH,
			COUNT(O.ORDER_ID) AS ORDER_COUNT
		FROM PRODUCTS P
JOIN TRANSLATE AS T ON T.PRODUCT_CATEGORY_NAME = P.PRODUCT_CATEGORY_NAME
	LEFT JOIN ORDER_ITEMS AS OI ON P.PRODUCT_ID = OI.PRODUCT_ID
	LEFT JOIN ORDERS AS O ON O.ORDER_ID = OI.ORDER_ID
WHERE O.ORDER_STATUS <> 'canceled'
GROUP BY 1,2
ORDER BY 2,3 DESC)
SELECT * FROM NT
WHERE MONTH IN ('2016-12-01','2017-12-01')
ORDER BY 3 DESC
/*Comment: 
In December 2016, only 1 product was sold and the reasons for this need to be looked into.
In 2017, 'Bed_Bath_Table' was sold the most with 568 units. 
This was followed by "sport_leisure-sports" products with 507 units, 
3rd place is occupied by "health_beauty-health beauty" products.
Since 2018 data on New Year and Christmas dates are not available 
Comparison with 2017 could not be made.
In general, it can be interpreted that personal gifts are sold more during Christmas and New Year's Eve.*/

--Valentine's Day:
SELECT T.PRODUCT_CATEGORY_NAME_ENGLISH,
	CAST(ORDER_APPROVED_AT AS date),
	COUNT(O.ORDER_ID) AS ORDER_COUNT
FROM PRODUCTS P
JOIN TRANSLATE AS T ON T.PRODUCT_CATEGORY_NAME = P.PRODUCT_CATEGORY_NAME
LEFT JOIN ORDER_ITEMS AS OI ON P.PRODUCT_ID = OI.PRODUCT_ID
LEFT JOIN ORDERS AS O ON O.ORDER_ID = OI.ORDER_ID
WHERE O.ORDER_STATUS <> 'canceled'
	AND CAST(ORDER_APPROVED_AT AS date) = '2017-06-12'
	OR CAST(ORDER_APPROVED_AT AS date) = '2018-06-12'
GROUP BY 1,2
ORDER BY 2,3 DESC
/*Comment:
For Valentine's Day, the categories "housewares" in 2017 and "health_beauty" in 2018 are among the best-selling products. 
"Bed bath table" is the 2nd best-selling product in both years.
Almost 3 times more of this product in 2018 compared to 2017  increased its sales.*/

/*Question 4 : Examine the number of orders based on days of the week (Monday, Thursday, ....) 
and days of the month (such as the 1st, 2nd of the month). */

--Number of orders by days of the week:
SELECT TO_CHAR("order_approved_at",'day') AS DAYS,
	COUNT(ORDER_ID) AS ORDER_COUNT
FROM ORDERS
WHERE ORDER_STATUS <> 'canceled'
	AND ORDER_APPROVED_AT IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC
/*Comment: 
According to the result, the most ordered day is "Tuesday" and the least ordered day is "Sunday". 
This may be due to the fact that customers spend time outside and shop in stores on Sundays. */


/*Additional Study: 
This question also examined the number of categorical products sold by day.
The total number of orders by days of the week and products were also analyzed. 
With this query, it can be examined in more detail on which days and how many products are sold.*/
SELECT T.PRODUCT_CATEGORY_NAME_ENGLISH,
	TO_CHAR("order_approved_at",'day') AS DAYS,
	COUNT(O.ORDER_ID) AS ORDER_COUNT
FROM PRODUCTS P
JOIN TRANSLATE AS T ON T.PRODUCT_CATEGORY_NAME = P.PRODUCT_CATEGORY_NAME
LEFT JOIN ORDER_ITEMS AS OI ON P.PRODUCT_ID = OI.PRODUCT_ID
LEFT JOIN ORDERS AS O ON O.ORDER_ID = OI.ORDER_ID
WHERE O.ORDER_STATUS <> 'canceled'
GROUP BY 1,2
ORDER BY 2,3 DESC

--Number of orders based on days of the month (1st, 2nd, 3rd):
SELECT EXTRACT('DAY'FROM ORDER_APPROVED_AT)AS DAYS,
	COUNT(ORDER_ID) AS ORDER_COUNT
FROM ORDERS
WHERE ORDER_STATUS <> 'canceled' and ORDER_APPROVED_AT IS NOT NULL
GROUP BY 1
ORDER BY 1
/*Comment:
According to the output, the order numbers are closer to each other, especially on the middle 
days of the month. There is a serious decrease towards the end of the month.
When we look at the beginning and end of the month, the order demand decreases by almost half.*/


/*Case 2 : Customer Analysis 

Question1: In which cities do customers shop more?
Determine the city of the customer as the city where he/she places the most orders and make the analysis accordingly.*/ 
WITH CC AS
	(SELECT CUSTOMER_UNIQUE_ID, CUSTOMER_CITY, COUNT(ORDER_ID),
ROW_NUMBER() OVER (PARTITION BY CUSTOMER_UNIQUE_ID ORDER BY COUNT(ORDER_ID) DESC)AS RN
		FROM CUSTOMERS C
		LEFT JOIN ORDERS O ON O.CUSTOMER_ID = C.CUSTOMER_ID
		GROUP BY 1,2
		ORDER BY 3 DESC),
	NT AS
	(SELECT CUSTOMER_UNIQUE_ID, CUSTOMER_CITY
		FROM CC
		WHERE RN = 1)
SELECT C.CUSTOMER_CITY,
	COUNT(DISTINCT ORDER_ID) AS ORDERCOUNT
FROM NT
LEFT JOIN CUSTOMERS C ON C.CUSTOMER_UNIQUE_ID = NT.CUSTOMER_UNIQUE_ID
LEFT JOIN ORDERS O ON O.CUSTOMER_ID = C.CUSTOMER_ID
GROUP BY 1
ORDER BY 2 DESC
--Comment: Customers in Sao Paulo shop the most.


/*Case 3: Vendor Analysis

Question 1: Who are the sellers who deliver orders to customers the fastest? Bring Top 5. 
Examine and comment on the number of orders of these sellers and the reviews and ratings of their products.

To calculate the seller's speed, the difference between the date the customer purchased and the date the customer
received it was calculated. When I wrote the query, the number of orders of the fastest sellers was 1,
so a realistic analysis could not be made. Therefore, the average number of orders per vendor was calculated. 
As a result of this calculation, there are 32 orders per seller on average.
Therefore, among the sellers who received approximately 30 orders or more 
The fastest seller evaluation was made by selecting the top 5.
When we examine the data set, there are 3095 sellers in total.
If the total number of orders is 99441, an average calculation was made over 99441. */

WITH SELLERS_TB AS
	(SELECT OI.SELLER_ID, O.ORDER_ID AS ORD, ORDER_APPROVED_AT,
	ORDER_DELIVERED_CARRIER_DATE,
	(ORDER_DELIVERED_CUSTOMER_DATE - ORDER_PURCHASE_TIMESTAMP) AS DELIVERY_TIME,
	R.REVIEW_SCORE AS RW
FROM ORDERS O
	LEFT JOIN ORDER_ITEMS OI ON OI.ORDER_ID = O.ORDER_ID
	LEFT JOIN SELLERS S ON S.SELLER_ID = OI.SELLER_ID
	LEFT JOIN REVIEWS R ON R.ORDER_ID = O.ORDER_ID
WHERE ORDER_DELIVERED_CUSTOMER_DATE IS NOT NULL
	AND ORDER_PURCHASE_TIMESTAMP IS NOT NULL
	AND ORDER_STATUS <> 'canceled'
	GROUP BY 1,2,3,4,6
	ORDER BY 5)
SELECT SELLER_ID,
	AVG(DELIVERY_TIME) AVG_DELIVERY,
	COUNT(ORD) ORDER_COUNT,
	ROUND(AVG(RW),1) AS AVG_REVIEW_SCORES
FROM SELLERS_TB
GROUP BY 1
HAVING COUNT(*) >= 30
ORDER BY 2
LIMIT 5

/*Comment: 
When the comments and scores of the 5 fastest sellers are analyzed, although there are a few negative comments, 
in general they received comments and high ratings for early and on-time delivery.
Their ratings seem to be quite good. The scores are directly proportional to the comments. 
We can say that the scores of sellers who deliver fast are also high. Amount of sales 
they don't seem to be making a lot of sales. We cannot say that there is a positive relationship between speed 
and the number of orders.
Because it is seen that the order quantities of fast sellers are less than the entire data set.
In order to interpret and confirm this, we can additionally observe that the sellers with the highest number of orders
we looked at how many days they delivered products to their customers.*/

/*Additional Study:
What is the average number of days it takes the sellers with the most orders to deliver orders to their customers */

WITH SELLERS_DT AS
	(SELECT DISTINCT OI.SELLER_ID,O.ORDER_ID,
	O.ORDER_DELIVERED_CUSTOMER_DATE - O.ORDER_PURCHASE_TIMESTAMP AS DELIVERY_TIME
		FROM ORDERS O
		LEFT JOIN ORDER_ITEMS OI ON OI.ORDER_ID = O.ORDER_ID
		LEFT JOIN SELLERS S ON S.SELLER_ID = OI.SELLER_ID
		WHERE ORDER_STATUS <> 'canceled' )
SELECT SELLER_ID,
	COUNT(ORDER_ID) AS CC,
	AVG(DELIVERY_TIME)
FROM SELLERS_DT
GROUP BY 1
HAVING COUNT(*) >= 100
ORDER BY 2 DESC
/*Comment: 
With this query, the top 30 sellers were found and the delivery speed of the products to the customers 
of the sellers who sell the most was analyzed. The average of all the times these sellers delivered 
their orders was taken. Fast delivery of products 
an evaluation was made by looking at whether it had an impact on their sales.
According to the result, it is seen that the sellers who sell a lot of products were generally able to
deliver the products between 9 days and 21 days. Therefore, there does not seem to be a more significant relationship 
between making a lot of sales and speed of delivery.*/

/*Question 2: Which sellers sell products from more categories? 
Do sellers with more categories also have more orders? */
WITH NTB AS
	(SELECT S.SELLER_ID, COUNT(P.PRODUCT_CATEGORY_NAME) AS COUNT_PR_CAT_NAMES
		FROM PRODUCTS P
		LEFT JOIN ORDER_ITEMS OI ON OI.PRODUCT_ID = P.PRODUCT_ID
		LEFT JOIN SELLERS S ON S.SELLER_ID = OI.SELLER_ID
		GROUP BY 1
		ORDER BY 2 DESC),
	NTB2 AS
	(SELECT DISTINCT OI.SELLER_ID,
			O.ORDER_ID
		FROM ORDERS O
		LEFT JOIN ORDER_ITEMS OI ON OI.ORDER_ID = O.ORDER_ID
		LEFT JOIN SELLERS S ON S.SELLER_ID = OI.SELLER_ID
		WHERE ORDER_STATUS <> 'canceled' )
SELECT NTB.SELLER_ID,
	COUNT(ORDER_ID) AS TOTAL_ORDERS,
	COUNT_PR_CAT_NAMES
FROM NTB2
LEFT JOIN NTB ON NTB.SELLER_ID = NTB2.SELLER_ID
GROUP BY 1,3
ORDER BY 2 DESC

/*Comment:
The sellers with the highest number of categorical sales were found with the above query.
We can say that there is a significant relationship between them.
It seems that the higher the number of categorical products, the higher the number of orders. */

/*Case 4 : Payment Analysis

Question 1 : In which region do users who pay in more installments live the most?
Interpret this output.

Before writing the query related to this question, the answers to the following questions were found.
I wrote a query based on how many people live in which region and how many customers placed their orders 
with how many installments. According to the result and percentage calculation, 
almost half of the customers (including canceled orders) made a single shot.
Therefore, the number of installments was taken as 2 and above.*/

SELECT COUNT(C.CUSTOMER_ID),
	C.CUSTOMER_STATE,
	P.PAYMENT_INSTALLMENTS
FROM ORDERS O
LEFT JOIN CUSTOMERS C ON C.CUSTOMER_ID = O.CUSTOMER_ID
LEFT JOIN PAYMENT P ON P.ORDER_ID = O.ORDER_ID
WHERE P.PAYMENT_INSTALLMENTS>=2
GROUP BY 2,3
ORDER BY 1 DESC
--Conclusion 1- SP: São Paulo 
/*Comment: 
The interpretation of this question can be interpreted with the outputs of different questions related to this question. 
In previous queries, we found that customers in Sao Paulo made the most purchases. According to the result of this query, 
Sao Paulo is also the city that uses the most installments.
The query result of the following question also shows that the most used card type is credit card. 
Therefore, we can say that people in the city of sao paulo use their credit card for shopping in installments.*/


/*Question 2: Calculate the number of successful orders and total amount of successful payments by payment type. 
Rank them from the most used payment type to the least used payment type.*/
SELECT PAYMENT_TYPE,
	COUNT(O.ORDER_ID) ORDER_COUNT,
	SUM(PAYMENT_VALUE)AS TOTAL_PAYMENT
FROM ORDERS O
LEFT JOIN CUSTOMERS C ON C.CUSTOMER_ID = O.CUSTOMER_ID
LEFT JOIN PAYMENT P ON P.ORDER_ID = O.ORDER_ID
WHERE O.ORDER_STATUS <> 'canceled'
GROUP BY 1
ORDER BY 2 DESC
--Conclusion: The most used payment type is "credit card". 

/*Question 3: Make a category-based analysis of orders paid in single check and installments.
Which categories use installment payment the most?*/

--Categorical Products Paid by Single Check:
SELECT T.PRODUCT_CATEGORY_NAME_ENGLISH,
	COUNT(PD.PRODUCT_CATEGORY_NAME),
	SUM(PAYMENT_VALUE)
FROM ORDERS O
LEFT JOIN ORDER_ITEMS OI ON OI.ORDER_ID = O.ORDER_ID
LEFT JOIN PAYMENT P ON P.ORDER_ID = OI.ORDER_ID
LEFT JOIN PRODUCTS PD ON PD.PRODUCT_ID = OI.PRODUCT_ID
INNER JOIN TRANSLATE T ON T.PRODUCT_CATEGORY_NAME = PD.PRODUCT_CATEGORY_NAME
WHERE O.ORDER_STATUS <> 'canceled'
	AND PAYMENT_INSTALLMENTS = 1
GROUP BY 1
ORDER BY 3 DESC

--Categorical Products Paid in Installments:
SELECT T.PRODUCT_CATEGORY_NAME_ENGLISH,
	COUNT(PD.PRODUCT_CATEGORY_NAME)
FROM ORDERS O
LEFT JOIN ORDER_ITEMS OI ON OI.ORDER_ID = O.ORDER_ID
LEFT JOIN PAYMENT P ON P.ORDER_ID = OI.ORDER_ID
LEFT JOIN PRODUCTS PD ON PD.PRODUCT_ID = OI.PRODUCT_ID
INNER JOIN TRANSLATE T ON T.PRODUCT_CATEGORY_NAME = PD.PRODUCT_CATEGORY_NAME
WHERE O.ORDER_STATUS <> 'canceled'
	AND PAYMENT_INSTALLMENTS > 1
	AND PD.PRODUCT_CATEGORY_NAME IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC

--Additional Study: Payment in Installments -Query based on number of installments and category:
SELECT P.PAYMENT_INSTALLMENTS,
	PD.PRODUCT_CATEGORY_NAME,
	T.PRODUCT_CATEGORY_NAME_ENGLISH,
	COUNT(PD.PRODUCT_CATEGORY_NAME),
	SUM(PAYMENT_VALUE)
FROM ORDERS O
LEFT JOIN ORDER_ITEMS OI ON OI.ORDER_ID = O.ORDER_ID
LEFT JOIN PAYMENT P ON P.ORDER_ID = OI.ORDER_ID
LEFT JOIN PRODUCTS PD ON PD.PRODUCT_ID = OI.PRODUCT_ID
INNER JOIN TRANSLATE T ON T.PRODUCT_CATEGORY_NAME = PD.PRODUCT_CATEGORY_NAME
WHERE O.ORDER_STATUS <> 'canceled'
	AND PAYMENT_INSTALLMENTS > 1
GROUP BY 1,2,3
ORDER BY 5 DESC



SELECT P.PAYMENT_INSTALLMENTS, PD.PRODUCT_CATEGORY_NAME,
T.PRODUCT_CATEGORY_NAME_ENGLISH,
COUNT(PD.PRODUCT_CATEGORY_NAME),
SUM(PAYMENT_VALUE)
FROM ORDERS O
LEFT JOIN ORDER_ITEMS OI ON OI.ORDER_ID = O.ORDER_ID
LEFT JOIN PAYMENT P ON P.ORDER_ID = OI.ORDER_ID
LEFT JOIN PRODUCTS PD ON PD.PRODUCT_ID = OI.PRODUCT_ID
INNER JOIN TRANSLATE T ON T.PRODUCT_CATEGORY_NAME = PD.PRODUCT_CATEGORY_NAME
WHERE O.ORDER_STATUS <> 'canceled'
AND PAYMENT_INSTALLMENTS = 1
GROUP BY 1,2,3
ORDER BY 5 DESC

/*Comment: 

When we look at the total of the products paid in installments, the categories "bed_bath_table-banya-bed-table", "health_beauty",
"furniture_decor", "watches_gifts"; 
The products paid with one shot are also computer accessories, office furniture, health beauty, bed-bath table and sports products.
In this printout, there are common products for both single payment and products paid in installments. In this case,
we can't say that product prices have a direct effect on the payment in installments or single payment.
For example, while there are 3000 computer accessories that are paid in installments,
The number of computer accessories purchased with a single payment is 4995. 
When we look at the sports products, the number of products paid with a single shot is 4954, 
while the number of installment payments is 3939.*/ 

---**************************************************************************************
/*RFM ANALYSIS
RFM Analysis of the E-Commerce Data dataset was performed.
Before starting the RFM Analysis, the data in the table were analyzed.
There are 541909 data in the dataset between 12.01.2010-09.12.2011.
Since "customerid-customer id", "invoicedate" and "unitprice" information is needed for RFM Analysis,
especially if there are null values in these data, these values are not included in the calculation. 
Also, if there are negative values in the "quantity-quantity-purchased" column,
they are not included in the data set to be calculated.
According to the research I did in Kaggle, 
since the invoices starting with "c" in the invoiceno column are "canceled-order canceled",
these values in this column were also excluded from the data set to be calculated */


----***RFM--SCORES***
WITH RECENCY AS
	(WITH REC_VAL AS
			(SELECT * FROM RFM
				WHERE QUANTITY > 0 AND UNITPRICE > 0 
AND INVOICENO not ilike 'c%'
				AND CUSTOMERID IS NOT NULL) 
SELECT DISTINCT CUSTOMERID, ('2011-12-09'-MAX(INVOICEDATE::date))AS RECENCY_VALUE
	FROM REC_VAL
	GROUP BY 1
	ORDER BY 2 DESC),
FREQUENCY AS
	(WITH FREQ_VAL AS
			(SELECT * FROM RFM
				WHERE QUANTITY > 0 AND UNITPRICE > 0
				AND INVOICENO not ilike 'c%'
				AND CUSTOMERID IS NOT NULL) 
SELECT DISTINCT CUSTOMERID, COUNT(INVOICENO)AS FREQUENCY_VALUE
	FROM FREQ_VAL
	GROUP BY 1
	ORDER BY 2 DESC),
MONETARY AS
	(WITH MON_VAL AS
			(SELECT * FROM RFM
				WHERE QUANTITY > 0 AND UNITPRICE > 0
				AND INVOICENO not ilike 'c%'
				AND CUSTOMERID IS NOT NULL) 
SELECT CUSTOMERID, SUM(UNITPRICE)AS MONETARY_VALUE
	FROM MON_VAL
	GROUP BY 1
	ORDER BY 2 DESC)
SELECT R.CUSTOMERID,
	R.RECENCY_VALUE,
	F.FREQUENCY_VALUE,
	M.MONETARY_VALUE
FROM RECENCY AS R
INNER JOIN FREQUENCY AS F ON R.CUSTOMERID = F.CUSTOMERID
INNER JOIN MONETARY AS M ON R.CUSTOMERID = M.CUSTOMERID

---RFM ANALYSIS-NORMALIZATION-SCORING-COMBINATION OF SCORES and CUSTOMER SEGMENTATION 
WITH RFM AS
(WITH RECENCY AS
	(WITH REC_VAL AS
		(SELECT * FROM RFM WHERE QUANTITY > 0 AND UNITPRICE > 0
		AND INVOICENO not ilike 'c%'
		AND CUSTOMERID IS NOT NULL) SELECT DISTINCT CUSTOMERID,
		 ('2011-12-09'- MAX(INVOICEDATE::date))AS RECENCY_VALUE
	FROM REC_VAL
	GROUP BY 1
	ORDER BY 2 DESC),
FREQUENCY AS
	(WITH FREQ_VAL AS
		(SELECT * FROM RFM WHERE QUANTITY > 0
		AND UNITPRICE > 0 AND INVOICENO not ilike 'c%'
		AND CUSTOMERID IS NOT NULL) SELECT CUSTOMERID,
		COUNT(INVOICENO)AS FREQUENCY_VALUE
	FROM FREQ_VAL
	GROUP BY 1
	ORDER BY 2 DESC),
MONETARY AS
	(WITH MON_VAL AS  
(SELECT *FROM RFM WHERE QUANTITY > 0 AND UNITPRICE > 0
		AND INVOICENO not ilike 'c%'
		AND CUSTOMERID IS NOT NULL) SELECT CUSTOMERID,
		SUM(UNITPRICE)AS MONETARY_VALUE FROM MON_VAL
	GROUP BY 1
	ORDER BY 2 DESC)
 SELECT R.CUSTOMERID,
R.RECENCY_VALUE,
NTILE(5) OVER(ORDER BY RECENCY_VALUE DESC) AS RECENCY_SCORE,
F.FREQUENCY_VALUE,
NTILE(5) OVER(ORDER BY FREQUENCY_VALUE) AS FREQUENCY_SCORE,
M.MONETARY_VALUE,
NTILE(5) OVER(	ORDER BY MONETARY_VALUE) AS MONETARY_SCORE,
M.MONETARY_VALUE
FROM RECENCY AS R
INNER JOIN FREQUENCY AS F ON R.CUSTOMERID = F.CUSTOMERID
INNER JOIN MONETARY AS M ON R.CUSTOMERID = M.CUSTOMERID)
SELECT CUSTOMERID,
RECENCY_SCORE || '-' || FREQUENCY_SCORE || '-' || MONETARY_SCORE AS RFM_SCORE,
CASE
WHEN RECENCY_SCORE = 5 AND FREQUENCY_SCORE IN (4, 5) THEN 'Champions'
WHEN RECENCY_SCORE IN (3,4) AND FREQUENCY_SCORE IN (4, 5) THEN 'Loyal Customers'
WHEN RECENCY_SCORE IN (1, 2) AND FREQUENCY_SCORE = 5 THEN 'Cant Lose Them'
WHEN RECENCY_SCORE IN (1, 2)AND FREQUENCY_SCORE IN(3, 4) THEN 'At Risk'
WHEN RECENCY_SCORE IN (4, 5) AND FREQUENCY_SCORE IN (2, 3) THEN 'Potential Loyalist'
WHEN RECENCY_SCORE = 3 AND FREQUENCY_SCORE = 3 THEN 'Need Attention'
WHEN RECENCY_SCORE = 3 AND FREQUENCY_SCORE IN (1,2) THEN 'About to Sleep'
WHEN RECENCY_SCORE IN (1,2)AND FREQUENCY_SCORE IN (1,	2) THEN 'Hibernating'
WHEN RECENCY_SCORE = 4 AND FREQUENCY_SCORE = 1 THEN 'Promising'
WHEN RECENCY_SCORE = 5 AND FREQUENCY_SCORE = 1 THEN 'New Costumer'
END AS CUSTOMER_SEGMENT
FROM RFM
ORDER BY 2 DESC
