use excelr;

select*from finance_1;
select*from finance_2;

# Total Loan Amount
Select sum(loan_amnt) total_loan_amount from finance_1;

# Total loan issued
Select distinct count(member_id) as number_of_loan_issued
from finance_1;

# Cumulative interest rate
Select avg(int_rate) as cumulative_interest_rate
from finance_1;

# Average funded amount
Select avg(funded_amnt) as average_funded_amount
from finance_1;

# KPI 1 Year wise loan amount Stats

SELECT 
    SUBSTRING(issue_d, - 4) AS issue_years,
    SUM(loan_amnt) AS total_amount
FROM
    finance_1
GROUP BY issue_years
ORDER BY total_amount DESC;

# with All year total :- 

SELECT issue_years, SUM(total_amount) AS total_amount
FROM (
    SELECT SUBSTRING(issue_d, -4) AS issue_years, SUM(loan_amnt) AS total_amount
    FROM finance_1
    GROUP BY issue_years
    UNION ALL
    SELECT 'All Years' AS issue_years, SUM(loan_amnt) AS total_amount
    FROM finance_1
) combined
GROUP BY issue_years
ORDER BY issue_years;

#KPI 2 Grade and sub grade wise revol_bal
Select f1.grade, f1.sub_grade, sum(f2.revol_bal) as revolving_bal
from finance_1 as f1 inner join finance_2 as f2
on f1.id = f2.id
group by f1.grade, f1.sub_grade;


#KPI 3 Total Payment for Verified Status Vs Total Payment for Non Verified Status
select f1.verification_status, sum(f2.total_pymnt) as total_payment
from finance_1 as f1 inner join finance_2 as f2
on f1.id = f2.id
group by f1.verification_status;

## Specific with respect to Verified status and non verified status

SELECT
    f1.verification_status,
    SUM(f2.total_pymnt) AS total_payment
FROM
    finance_1 AS f1
INNER JOIN
    finance_2 AS f2
ON
    f1.id = f2.id
WHERE
    f1.verification_status = 'Verified'
    OR f1.verification_status = 'Not Verified'
GROUP BY
    f1.verification_status;

# KPI 4 State wise and last_credit_pull_d wise loan status

SELECT
    fn1.addr_state AS State,
    fn2.last_credit_pull_d AS Last_Credit_Pull_D,
    fn1.loan_status AS LoanStatus,
    COUNT(*) AS LoanCount
FROM
    finance_1 AS fn1
JOIN
    finance_2 AS fn2
ON
    fn1.id = fn2.id
GROUP BY
    fn1.addr_state, fn2.last_credit_pull_d, fn1.loan_status
ORDER BY
    fn1.addr_state, fn2.last_credit_pull_d, fn1.loan_status;
 -- *   
SELECT
    YEAR(issue_d) AS payment_year,
    MONTH(issue_d) AS payment_month,
    f1.home_ownership,
    COUNT(f1.home_ownership) AS home_ownership_count
FROM
    finance_1 AS f1
INNER JOIN
    finance_2 AS f2 ON f1.id = f2.id
GROUP BY
    payment_year, payment_month, f1.home_ownership
ORDER BY
    payment_year, payment_month;
   -- 
   SELECT
    last_pymnt_d as payment_year
FROM
    finance_2
WHERE
    last_pymnt_d IS NOT NULL;

-- 
SELECT
    YEAR(f2.last_pymnt_d) AS payment_year,
   monthname(f2.last_pymnt_d) AS payment_month,
    f1.home_ownership,
    COUNT(f1.home_ownership) AS home_ownership_count
FROM
    fc_2 AS f2
JOIN finance_1 AS f1 ON f2.id = f1.id
GROUP BY
  payment_year,payment_month, f1.home_ownership
ORDER BY
    payment_year, payment_month;	


# KPI 5 Home ownership Vs last payment date stats
select year(f2.last_pymnt_d) as payment_year, MONTH(f2.last_pymnt_d) as payment_month, 
f1.home_ownership, count(f1.home_ownership) as home_ownership
from fc_2 as f2 join finance_1 as f1
on f2.id = f1.id
group by year(f2.last_pymnt_d), MONTH(date_format(f2.last_pymnt_d, '%b' )), f1.home_ownership
order by payment_year;

WITH cte AS (
    SELECT
        fn1.home_ownership,
        SUBSTRING(last_pymnt_d, -4) AS payment_year,
        MONTHNAME(STR_TO_DATE(last_pymnt_d, '%d-%m-%Y')) AS payment_month
    FROM
        finance_1 AS fn1
    JOIN
        finance_2 AS fn2 ON fn1.id = fn2.id
    WHERE
        home_ownership IN ('rent', 'mortgage', 'own')
)
SELECT
    home_ownership,
    COUNT(*) AS num_loan
FROM
    cte
GROUP BY
    home_ownership;
#############################################################
select year(f2.last_pymnt_d) payment_year, f1.home_ownership, count(f1.home_ownership) home_ownership
from finance_1 as f1 inner join finance_2 as f2
on f1.id = f2.id
group by year(f2.last_pymnt_d), f1.home_ownership
order by payment_year;

select year(f2.last_pymnt_d) payment_year, monthname(f2.last_pymnt_d) payment_month, f1.home_ownership, count(f1.home_ownership) home_ownership
from finance_1 as f1 inner join finance_2 as f2
on f1.id = f2.id
group by year(f2.last_pymnt_d), monthname(f2.last_pymnt_d), f1.home_ownership
order by payment_year;

/* Yearly Interest Received */

select year(last_pymnt_d) as received_year, cast(sum(total_rec_int) as decimal (10,2)) as interest_received
from finance_2
group by received_year
order by received_year;

/* Term Wise Popularity */
select term, sum(loan_amnt) total_amount from finance_1
group by term;

/* Top 5 States */ 
select addr_state as state_name, count(*) as customer_count
from finance_1
group by addr_state
order by customer_count desc
limit 5;