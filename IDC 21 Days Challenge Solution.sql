CREATE DATABASE if Not exists IDC_SQL_DATA;
USE IDC_SQL_DATA;

-- Daliy Challenge Day-1 
-- List all unique hospital servie available  in the Hospital
SELECT DISTINCT service as services_available FROM services_weekly;

-- Daily Challenge Day 2
-- Find all patients admitted to 'Surgery' service with a satisfaction score below 70.
SELECT patient_id,name,age,satisfaction FROM patients
WHERE service = 'surgery' AND satisfaction < 70; 

-- Daily Challenge Day 3 
-- Retrieve the top 5 weeks with the highest patient refusals across all services..
SELECT week,service,patients_refused,patients_request FROM
services_weekly ORDER BY patients_refused DESC LIMIT 5;

-- Daily Challenge Day 4 
-- Find the 3rd to 7th highest patient satisfaction scores from the patients table...
SELECT Patient_id , name, service, satisfaction FROM patients 
ORDER BY satisfaction DESC LIMIT 5 OFFSET 2;

-- Daily Challenge Day-5
/*Calculate the total number of patients admitted, total patients refused, 
and the average patient satisfaction across all services and 
weeks. Round the average satisfaction to 2 decimal places.*/
SELECT 
    SUM(patients_admitted) as total_patients_admitted, 
	SUM(patients_refused) as total_patients_refused,
	ROUND(AVG(patient_satisfaction),2) as avg_patients_satisfaction_score   
FROM services_weekly;


-- Daily Challenge Day-6
/*For each hospital service, calculate the total number of patients admitted, 
total patients refused, and the admission rate (percentage of requests that were admitted)
.Order by admission rate descending.*/
SELECT 
	service, SUM(patients_admitted) total_patients_admitted,
    SUM(patients_refused) total_patients_refused,
    ROUND(SUM(patients_admitted)*100/SUM(patients_request),2) as adimission_rate 
FROM services_weekly 
GROUP BY service 
ORDER BY adimission_rate DESC;

-- Daily Challenge Day-7
/* Identify services that refused more than 100 patients in total and 
had an average patient satisfaction below 80. Show service name, total refused, and average satisfaction.*/
SELECT 
    service,
    SUM(patients_refused) AS total_patient_refused,
    AVG(patient_satisfaction) AS avg_score
FROM services_weekly
GROUP BY service
HAVING total_patient_refused > 100 AND avg_score < 80; 

-- Practice question Day 8
-- Convert all patient name to uppercase
SELECT UPPER(name) FROM patients;
-- Find the length of each staff memeber name
SELECT staff_name, length(staff_name) name_length FROM staff;

-- Daily Challenge 8
/* Create a patient summary that shows patient_id, full name in uppercase, 
service in lowercase, age category (if age >= 65 then 'Senior', if age >= 18 
then 'Adult', else 'Minor'), and name length. Only show patients whose name length is greater than 10 characters. */
SELECT 
    UPPER(patient_id) patient_id,
    UPPER(name) name,
    lower(service) service, 
CASE 
 WHEN age > 65 THEN 'Senior'
 WHEN age > 18 THEN 'Adult'
 ELSE 'minor' END AS age_category,
 length(name) as name_length 
 FROM patients WHERE length(name) >10;
 
-- Daily Challenge 9
/* Q1. Calculate the average length of stay (in days) for each service, showing only services 
where the average stay is more than 7 days. 
 Q2. Also show the count of patients 
and order by average stay descending.*/
SELECT 
   service,
   AVG(DATEDIFF(departure_date,arrival_date)) as avg_stay,
   COUNT(patient_id)
FROM patients GROUP BY service HAVING avg_stay > 7 ORDER BY avg_stay DESC;

-- Daily Challenge Day 10
/* Create a service performance report showing service name, total patients admitted, 
and a performance category based on the following: 'Excellent' if avg satisfaction >= 85,
'Good' if >= 75, 'Fair' if >= 65, otherwise 'Needs Improvement'. Order by average satisfaction descending.*/
SELECT 
    service,
    SUM(patients_admitted),
CASE WHEN AVG(patient_satisfaction) >= 85 THEN 'Excellent'
WHEN AVG(patient_satisfaction) >= 75 THEN 'Good'
WHEN AVG(patient_satisfaction) >= 65 THEN 'Fair'
ELSE 'Need Improvement' END as performance 
FROM services_weekly GROUP BY service ORDER BY AVG(patient_satisfaction) desc;

-- Daily Challenge Day 11
/* Find all unique combinations of service and event type from 
the services_weekly table where events are not null or none,
 along with the count of occurrences for each combination. Order by count descending.*/
 SELECT  
    service,
    event,
    COUNT(*) event_count 
FROM services_weekly WHERE event is NOT NULL AND 
event<>'none' GROUP BY service,event ORDER BY event_count DESC;

-- Daily Challenge Day 12
/* Analyze the event impact by comparing weeks with events vs weeks without events. 
Show: event status ('With Event' or 'No Event'), count of weeks, average patient satisfaction, 
and average staff morale. Order by average patient satisfaction descending.*/
SELECT 
    CASE
        WHEN event IS NULL OR event = 'none' THEN 'With Event'
        ELSE 'No Event'
    END AS event_status,
    COUNT(week) AS week_count,
    ROUND(AVG(patient_satisfaction)) AS avg_patient_satisfaction,
    ROUND(AVG(staff_morale)) AS avg_staff_morale
FROM services_weekly
GROUP BY event_status
ORDER BY avg_patient_satisfaction DESC;

-- Daily Challenge Day 13
/* Create a comprehensive report showing patient_id, patient name, age, service, 
and the total number of staff members available in their service. Only include patients 
from services that have more than 5 staff members. Order by number of staff descending, then by patient name. */
SELECT 
    patient_id,
    name,
    age,
    p.service,
    COUNT(staff_id) AS total_staff
FROM patients p JOIN staff s ON s.service = p.service
GROUP BY patient_id , name , age , p.service
HAVING total_staff > 5 ORDER BY total_staff DESC , name;


-- Daily Challenge Day 14
/* Create a staff utilisation report showing all staff members 
(staff_id, staff_name, role, service) and the count of weeks they were 
present (from staff_schedule). Include staff members even if they have no schedule records. Order by weeks present descending.*/ 

SELECT 
    s.staff_id,
    s.staff_name,
    s.role,
    s.service,
    COALESCE(SUM(ss.present), 0) AS week_present
FROM staff s LEFT JOIN staff_schedule ss ON ss.staff_id = s.staff_id
GROUP BY s.staff_id , s.staff_name , s.role , s.service
ORDER BY week_present DESC;

-- Daily Challenge Day 15
/* Create a comprehensive service analysis report for week 20 showing: 
service name, total patients admitted that week, total patients refused, 
average patient satisfaction, count of staff assigned to service, and count of 
staff present that week. Order by patients admitted descending. */
SELECT sw.service,MAX(patients_admitted) as total_patient_admitted
,MAX(patients_refused) as total_patient_refused,
AVG(patient_satisfaction) as avg_satisfcation,
COUNT(distinct s.staff_id) as total_staff_assigned,
COUNT(CASE WHEN ss.present = 1 AND ss.week = 20 THEN ss.staff_id END) as total_present_staff
FROM services_weekly sw JOIN staff s ON s.service = sw.service JOIN staff_schedule ss ON ss.staff_id = s.staff_id
 WHERE sw.week = 20 GROUP BY sw.service ORDER BY total_patient_admitted DESC;
 
 
-- Daily Challenge Day 16 
 /* Find all patients who were admitted to services that had at least one week 
where patients were refused AND the average patient satisfaction for that 
service was below the overall hospital average satisfaction. 
Show patient_id, name, service, and their personal satisfaction score. */
SELECT patient_id,name,satisfaction FROM patients p  
WHERE p.service IN ( SELECT distinct service FROM services_weekly 
WHERE patients_refused >0 ) AND p.service IN (SELECT service FROM services_weekly GROUP BY service 
HAVING AVG(patient_satisfaction) < (SELECT AVG(patient_satisfaction) FROM services_weekly));

-- Daily Challenge Day 17
/* Create a report showing each service with: service name, total patients admitted, 
the difference between their total admissions and the average admissions across all services,
 and a rank indicator ('Above Average', 'Average', 'Below Average'). Order by total patients admitted descending.*/
 SELECT * , CASE WHEN diff < 0 THEN 'Below Average'
 WHEN diff > 0 THEN 'Above Average' ELSE 'Average' END as rank_indicator FROM 
 (SELECT sw.service,SUM(patients_admitted) as total_patient_admitted,ROUND(MAX(avt.avg_patient),2) as avg_patient_admitted,
 (SUM(patients_admitted) - MAX(avg_patient)) as diff
 FROM services_weekly sw
 JOIN(SELECT distinct service, AVG(t.total_patient_admitted) OVER() as avg_patient FROM (SELECT service,
 SUM(patients_admitted) as total_patient_admitted FROM services_weekly GROUP BY service) t ) avt 
 ON avt.service = sw.service
 GROUP BY sw.service) a ORDER BY a.diff desc;
 

-- Daily Challenge Day 18
 /* Create a comprehensive personnel and patient list showing: identifier 
(patient_id or staff_id), full name, type ('Patient' or 'Staff'), and associated 
service. Include only those in 'surgery' or 'emergency' services. Order by type, then service, then name.*/
SELECT  patient_id as id, name, service, 'Patient'  AS type
FROM patients
WHERE service IN('surgery','emergency') 
UNION SELECT staff_id as id, staff_name as name, service, 'Staff' AS type
FROM staff
WHERE service IN('surgery','emergency') Order by type, service, name;

-- Daily Challenge Day 19
/* For each service, rank the weeks by patient satisfaction score (highest first). 
Show service, week, patient_satisfaction, patients_admitted, and the rank.
 Include only the top 3 weeks per service. */
SELECT * FROM (SELECT service , week , patient_satisfaction,patients_admitted, 
DENSE_RANK() OVER(Partition by service order by patient_satisfaction desc) as rnk
FROM services_weekly) t WHERE rnk < 4 ORDER BY service,rnk;




-- Daily Challenge Day 20
/* Create a trend analysis showing for each service and week: 
week number, patients_admitted, running total of patients admitted (cumulative), 
3-week moving average of patient satisfaction (current week and 2 prior weeks),
 and the difference between current week admissions and the service average. Filter for weeks 10-20 only.*/
SELECT service,week,patients_admitted, 
SUM(patients_admitted) OVER(partition by service ORDER BY week) as cumulative_total_of_patient_admitted,
ROUND(AVG(patient_satisfaction) OVER(partition by service ORDER BY week ROWS between 2 preceding and current row),2) as 3_week_avg, 
ROUND(patients_admitted - AVG(patients_admitted) OVER(partition by service),2) diff_from_service_avg  
FROM services_weekly WHERE week between 10 AND 20;

-- Daily Challenge Day 21
/* Create a comprehensive hospital performance dashboard using CTEs. Calculate: 
1) Service-level metrics (total admissions, refusals, avg satisfaction), 
2) Staff metrics per service (total staff, avg weeks present), 
3) Patient demographics per service (avg age, count). Then combine all three CTEs to create 
a final report showing service name, all calculated metrics, and an overall performance score
 (weighted average of admission rate and satisfaction). Order by performance score descending.*/
WIth service_level_metrics as (SELECT service, SUM(patients_admitted) as total_patient_admitted,
SUM(patients_refused) as total_patient_refused,
ROUND(AVG(patient_satisfaction),2) as avg_satisfaction_score
FROM services_weekly GROUP BY service),
staff_metrics as ( SELECT service , COUNT(Distinct staff_id) as total_staff, ROUND(AVG(total_present),2) as avg_week_present FROM(
 SELECT service,staff_id, SUM(present) as total_present FROM staff_schedule GROUP BY service,staff_id) t GROUP BY service),
patient_demographics as (SELECT service, ROUND(AVG(age),2) as avg_age , 
COUNT(patient_id) as no_of_patients FROM patients GROUP BY service) 
SELECT s.service, s.total_patient_admitted, s.total_patient_refused , ROUND((s.total_patient_admitted/
(s.total_patient_admitted+s.total_patient_refused))*100,2) as admission_rate,s.avg_satisfaction_score, st.total_staff, st.avg_week_present,
p.avg_age, ROUND((100*s.total_patient_admitted/(s.total_patient_admitted+s.total_patient_refused)/2),2) as performance_score
FROM service_level_metrics s JOIN staff_metrics st ON st.service = s.service JOIN patient_demographics p ON p.service =
st.service ORDER BY performance_score DESC;




 











