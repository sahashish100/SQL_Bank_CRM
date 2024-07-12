use `crm bank`;

--                               BANK CRM

--                           Objective Questions
 
 -- 2.	Identify the top 5 customers with the highest Estimated Salary in the last quarter of the year. (SQL)
 
 with year_quarter_data as(
 select * , quarter(str_to_date(`Bank DOJ`, '%d/%m/%Y')) as Quarter , year(str_to_date(`Bank DOJ`, '%d/%m/%Y')) as Year
 from `crm bank`.`customerinfo`)
 select * from
 (select ï»¿CustomerId , Year , Quarter , EstimatedSalary as highest_Estimated_Salary , 
 dense_rank() over(partition by Year order by EstimatedSalary desc) as salary_rank
 from year_quarter_data 
 where Quarter = 4) t1
 where salary_rank <=5 ;
 
 
-- 3.	Calculate the average number of products used by customers who have a credit card. (SQL)
 
 select avg(NumOfProducts) as Average_Num_Of_Products 
 from bank_churn
 where HasCrCard =1 ;
 
 
 -- 5.	Compare the average credit score of customers who have exited and those who remain. (SQL)
 
 select Exited, avg(CreditScore) as Avg_Credit_Score
 from bank_churn 
 group by Exited ;
 
 
 -- 6.	Which gender has a higher average estimated salary, and how does it relate to the number of active accounts? (SQL)

select c.GenderID , round(avg(c.EstimatedSalary),2) as Avg_Estimated_Salary , sum(b.IsActiveMember) as Active_Member 
from customerinfo c
join bank_churn b 
on b.ï»¿CustomerId = c.ï»¿CustomerId
group by 1 ;


-- 7.Segment the customers based on their credit score and identify the segment with the highest exit rate. (SQL)
 
 with Credit_Segment as (
select count(*) as Total_Customer , sum(Exited) as Exited_Customer , case 
when CreditScore between 800 and 850 then "Excellent" 
when CreditScore between 740 and 799 then "Very Good" 
when CreditScore between 670 and 739 then "Good" 
when CreditScore between 580 and 669 then "Fair" 
when CreditScore between 300 and 579 then "Poor"
else "Unknown"
end as Credit_Score_Bucket
from bank_churn 
group by Credit_Score_Bucket )

select Credit_Score_Bucket , Total_Customer , Exited_Customer , round(( Exited_Customer / Total_Customer)*100,2) as Exit_Rate
from Credit_Segment
order by Exit_Rate desc 
limit 1 ;


-- 8.	Find out which geographic region has the highest number of active customers with a tenure greater than 5 years. (SQL) 

select c.GeographyID , sum(b.IsActiveMember) as HighestActiveCustomer
from customerinfo c 
join bank_churn b
on b.ï»¿CustomerId = c.ï»¿CustomerId
where Tenure > 5
group by GeographyID
order by HighestActiveCustomer desc
limit 1 ;


-- 9.	What is the impact of having a credit card on customer churn, based on the available data?


SELECT HasCrCard, COUNT(ï»¿CustomerId) AS TotalCustomers,
    SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) AS ChurnedCustomers,
    SUM(CASE WHEN Exited = 0 THEN 1 ELSE 0 END) AS RetainedCustomers,
    ROUND((SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) * 100.0) / COUNT(ï»¿CustomerId), 2) AS ChurnRate
FROM Bank_Churn
GROUP BY HasCrCard;


-- 11. Examine the trend of customers joining over time and identify any seasonal patterns (yearly or monthly).
--     Prepare the data through SQL and then visualize it. 

with t1 as (
select  count(*) as Customer_Joined , year(str_to_date(`Bank DOJ`,'%d/%m/%Y')) as Year , month(str_to_date(`Bank DOJ`,'%d/%m/%Y')) as Month
from customerinfo 
group by Year , Month 
order by Year , Month )
select * , concat(Year ,'/', Month) as Year_Months
from t1 ;


-- 15.Using SQL, write a query to find out the gender-wise average income of males and females in each geography id. 
-- Also, rank the gender according to the average value. (SQL)

select GenderID , GeographyID ,  round(avg(EstimatedSalary),2) as Income ,
dense_rank() over (partition by GeographyID order by avg(EstimatedSalary) desc) as `Rank`
from customerinfo
group by 1,2 ;

-- 16.Using SQL, write a query to find out the average tenure of the people who have exited in each 
-- age bracket (18-30, 30-50, 50+).

select case
when c.age between 18 and 30 then "18-30"
when c.age between 30 and 50 then "30-50"
else "50+"
end as Age_Bracket , avg(b.Tenure) as Average_Tenure
from bank_churn b join
customerinfo c 
on b.ï»¿CustomerId = c.ï»¿CustomerId
where b.Exited =1
group by Age_Bracket;


-- 17 . Is there any direct correlation between salary and the balance of the customers?
--  And is it different for people who have exited or not?

with final_data as (
select b.ï»¿CustomerId , b.Exited , b.Balance , c.EstimatedSalary
 from bank_churn b
 join customerinfo c
 on b.ï»¿CustomerId = c.ï»¿CustomerId )
 select * from final_data 
 where Exited = 1
 order by EstimatedSalary desc ;  

 
 --  18. Is there any correlation between the salary and the Credit score of customers? 

with final_data as (
select b.ï»¿CustomerId , b.CreditScore ,  c.EstimatedSalary
 from bank_churn b
 join customerinfo c
 on b.ï»¿CustomerId = c.ï»¿CustomerId )
 select CreditScore , min(EstimatedSalary) , max(EstimatedSalary)  from final_data 
 group by 1
 order by CreditScore ;


-- 19.Rank each bucket of credit score as per the number of customers who have churned the bank.

select case 
when CreditScore between 800 and 850 then "Excellent" 
when CreditScore between 740 and 799 then "Very Good" 
when CreditScore between 670 and 739 then "Good" 
when CreditScore between 580 and 669 then "Fair" 
when CreditScore between 300 and 579 then "Poor"
else "Unknown"
end as Credit_Score_Bucket ,sum(Exited) as Total_Customer ,
dense_rank() over(order by sum(Exited) desc) as Credit_Score_Rank
from bank_churn 
group by 1;

-- 20.According to the age buckets find the number of customers who have a credit card. 
-- Also retrieve those buckets that have lesser than average number of credit cards per bucket.  


select case
when c.age between 18 and 30 then "18-30"
when c.age between 30 and 50 then "30-50"
else "50+"
end as Age_Bracket , count(c.ï»¿CustomerId) as Credit_Card_Holder 
from bank_churn b join
customerinfo c 
on b.ï»¿CustomerId = c.ï»¿CustomerId
where HasCrCard =1 
group by Age_Bracket ;

with credit_card_holder as (
select case
when c.age between 18 and 30 then "18-30"
when c.age between 30 and 50 then "30-50"
else "50+"
end as Age_Bracket , count(c.ï»¿CustomerId) as Credit_Card_Holder 
from bank_churn b join
customerinfo c 
on b.ï»¿CustomerId = c.ï»¿CustomerId 
group by Age_Bracket ),

avg_holder as (
select round(avg(Credit_Card_Holder),2) as Average_Credit_Card_Holder
from credit_card_holder )

select cc.Age_Bracket , cc.Credit_Card_Holder , a.Average_Credit_Card_Holder
from credit_card_holder as cc ,avg_holder as a
where cc.Credit_Card_Holder < a.Average_Credit_Card_Holder ;


-- 21.Rank the Locations as per the number of people who have churned the bank and average balance of the customers.

with customer_rank as(
select c.GeographyID , count(c.ï»¿CustomerId) as Total_Exited_Customer , round(avg(b.Balance),2) as Avg_Balance ,
dense_rank() over(order by count(c.ï»¿CustomerId)desc) as Churn_Rank ,
dense_rank() over(order by avg(b.Balance) desc) as Balance_Rank
from customerinfo c 
join bank_churn b 
on c.ï»¿CustomerId = b.ï»¿CustomerId
where Exited =1
group by 1 )
select * 
from customer_rank
order by Churn_Rank , Balance_Rank;


-- 22.As we can see that the “CustomerInfo” table has the CustomerID and Surname, 
-- now if we have to join it with a table where the primary key is also a combination of CustomerID and Surname, 
-- come up with a column where the format is “CustomerID_Surname”.

select ï»¿CustomerId , Surname , concat(ï»¿CustomerId, "_", Surname) as CustomerId_Surname
from customerinfo; 


-- 23.Without using “Join”, can we get the “ExitCategory” from ExitCustomers table to Bank_Churn table? 
-- If yes do this using SQL. 

Select
    bc.ï»¿CustomerId , bc.CreditScore , bc.Tenure , bc.Balance , bc.NumOfProducts , 
    bc.HasCrCard , bc.IsActiveMember , bc.Exited,
	( SELECT ec.ExitCategory
     FROM exitcustomer ec
     WHERE ec.ï»¿ExitID = bc.Exited ) AS ExitCategory
FROM bank_Churn bc;


-- 25.Write the query to get the customer IDs, their last name, and whether they are active or not 
-- for the customers whose surname ends with “on”. 

select c.ï»¿CustomerId , c.Surname , 
case when b.IsActiveMember =1 then 'Active Member'
	 else 'Inactive Member'
     end as Avtive_Status
from customerinfo c 
join bank_churn b 
on c.ï»¿CustomerId = b.ï»¿CustomerId
where Surname like '%on' ;


--                    Subjective Question 


-- 9.Utilize SQL queries to segment customers based on demographics and account details.
 
with segmented_customers as (
select c.ï»¿CustomerId , c.Surname,
  CASE WHEN c.Age BETWEEN 18 AND 30 THEN '18-30'
    WHEN c.Age BETWEEN 31 AND 50 THEN '31-50'
    ELSE '50+' END AS AgeBracket,
  CASE WHEN c.GenderID = 1 THEN 'Male'
    WHEN c.GenderID = 2 THEN 'Female' END AS Gender,
  CASE WHEN c.GeographyID = 1 THEN 'France'
    WHEN c.GeographyID = 2 THEN 'Spain'
    WHEN c.GeographyID = 3 THEN 'Germany' END AS GeographyLocation,
  CASE WHEN b.HasCrCard = 1 THEN 'Credit Card Holder'
    ELSE 'Non Credit Card Holder' END AS CreditCardOwnership,
  CASE WHEN b.Balance < 20000 THEN 'Low Balance'
    WHEN b.Balance BETWEEN 20000 AND 80000 THEN 'Medium Balance'
    ELSE 'High Balance' END AS BalanceSegment,
  CASE WHEN b.Tenure < 3 THEN 'New'
    WHEN b.Tenure BETWEEN 3 AND 7 THEN 'Moderate'
    ELSE 'Long-term' END AS TenureSegment,
  CASE WHEN b.IsActiveMember = 1 THEN 'Active Member'
    ELSE 'Inactive Member' END AS ActiveStatus
FROM CustomerInfo c
JOIN Bank_Churn b ON c.ï»¿CustomerId = b.ï»¿CustomerId)

SELECT AgeBracket, BalanceSegment, COUNT(*) AS CustomerCount
FROM segmented_customers
GROUP BY AgeBracket, BalanceSegment
ORDER BY AgeBracket, BalanceSegment ;


-- 14.In the “Bank_Churn” table how can you modify the name of the “HasCrCard” column to “Has_creditcard”?
 
alter table bank_churn 
rename column HasCrCard to Has_creditcard ;















