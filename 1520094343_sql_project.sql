/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */
/*
Tennis Court 1, Tennis Court 2, Massage Room 1, Massage Room 2, Squash Court
*/

SELECT facid, name, membercost FROM `Facilities` WHERE membercost <> 0

/* Q2: How many facilities do not charge a fee to members? */
/*
4
*/

SELECT COUNT(DISTINCT facid) AS 'Number_of_Free_Facilities' FROM `Facilities` WHERE membercost = 0

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
/*
facid 	name 	membercost 	monthlymaintenance
0 	Tennis Court 1 	5.0 	200
1 	Tennis Court 2 	5.0 	200
4 	Massage Room 1 	9.9 	3000
5 	Massage Room 2 	9.9 	3000
6 	Squash Court 	3.5 	80
*/

SELECT `facid`, `name`, `membercost`, `monthlymaintenance` FROM `Facilities` WHERE `membercost` < (`monthlymaintenance` * 0.2) AND `membercost` <> 0

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */
/*
facid Ascending 	name 	membercost 	guestcost 	initialoutlay 	monthlymaintenance
1 	Tennis Court 2 	5.0 	25.0 	8000 	200
5 	Massage Room 2 	9.9 	80.0 	4000 	3000
*/

SELECT * FROM `Facilities` WHERE `facid` IN (1, 5)

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */
/*
name 	monthlymaintenance 	level_of_cost 	
Tennis Court 1 	200 	expensive
Tennis Court 2 	200 	expensive
Badminton Court 	50 	cheap
Table Tennis 	10 	cheap
Massage Room 1 	3000 	expensive
Massage Room 2 	3000 	expensive
Squash Court 	80 	cheap
Snooker Table 	15 	cheap
Pool Table 	15 	cheap
*/

SELECT `name`, `monthlymaintenance`, CASE WHEN `monthlymaintenance` > 100 THEN 'expensive' ELSE 'cheap' END AS 'level_of_cost' FROM `Facilities`

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */
/*
firstname 	surname 	
Darren 	Smith
*/

SELECT `firstname`, `surname` FROM `Members` WHERE `joindate` = (SELECT MAX(`joindate`) FROM `Members`)

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
/*
Facility_Name 	Member_Name 	
Tennis Court 1 	Anne Baker
Tennis Court 2 	Anne Baker
Tennis Court 1 	Burton Tracy
Tennis Court 2 	Burton Tracy
Tennis Court 2 	Charles Owen
Tennis Court 1 	Charles Owen
Tennis Court 2 	Darren Smith
Tennis Court 1 	David Farrell
Tennis Court 2 	David Farrell
..........  ........
*/

SELECT Facilities.name AS 'Facility_Name', CONCAT( Members.firstname, ' ', Members.surname ) AS 'Member_Name'
FROM Bookings
JOIN Facilities ON Bookings.facid = Facilities.facid
JOIN Members ON Bookings.memid = Members.memid
WHERE Facilities.name LIKE 'tennis%'
GROUP BY 1 , 2
ORDER BY 2 

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
/*
 Time 	Book_ID 	Facility 	Member_or_Guest 	Total_Cost 	
2012-09-14 11:00:00 	2946 	Massage Room 2 	GUEST GUEST 	320.0
2012-09-14 16:00:00 	2942 	Massage Room 1 	GUEST GUEST 	160.0
2012-09-14 13:00:00 	2940 	Massage Room 1 	GUEST GUEST 	160.0
2012-09-14 09:00:00 	2937 	Massage Room 1 	GUEST GUEST 	160.0
2012-09-14 17:00:00 	2926 	Tennis Court 2 	GUEST GUEST 	150.0
2012-09-14 14:00:00 	2925 	Tennis Court 2 	GUEST GUEST 	75.0
2012-09-14 19:00:00 	2922 	Tennis Court 1 	GUEST GUEST 	75.0
2012-09-14 16:00:00 	2920 	Tennis Court 1 	GUEST GUEST 	75.0
2012-09-14 09:30:00 	2948 	Squash Court 	GUEST GUEST 	70.0
2012-09-14 14:00:00 	2941 	Massage Room 1 	Jemima Farrell 	39.6
2012-09-14 15:00:00 	2951 	Squash Court 	GUEST GUEST 	35.0
2012-09-14 12:30:00 	2949 	Squash Court 	GUEST GUEST 	35.0
*/

SELECT Bookings.starttime AS Time,
		Bookings.bookid AS 'Book_ID',
		Facilities.name AS Facility,
		CONCAT(Members.firstname, ' ', Members.surname) AS 'Member_or_Guest',
		CASE WHEN Bookings.memid = 0 THEN (Facilities.guestcost * Bookings.slots) 
		ELSE (Facilities.membercost * Bookings.slots) END AS 'Total_Cost'
FROM Bookings 
JOIN Facilities 
ON Bookings.facid = Facilities.facid AND ((Bookings.memid <> 0 AND Facilities.membercost * Bookings.slots > 30) OR (Bookings.memid = 0 AND Facilities.guestcost * Bookings.slots > 30))
JOIN Members
ON Bookings.memid = Members.memid
WHERE Bookings.starttime LIKE '2012-09-14%'
ORDER BY 5 DESC

/* Q9: This time, produce the same result as in Q8, but using a subquery. */
/*
 Time 	BookID 	Facility 	Member_or_Guest 	Total_Cost Descending 	
2012-09-14 11:00:00 	2946 	Massage Room 2 	GUEST GUEST 	320.0
2012-09-14 13:00:00 	2940 	Massage Room 1 	GUEST GUEST 	160.0
2012-09-14 16:00:00 	2942 	Massage Room 1 	GUEST GUEST 	160.0
2012-09-14 09:00:00 	2937 	Massage Room 1 	GUEST GUEST 	160.0
2012-09-14 17:00:00 	2926 	Tennis Court 2 	GUEST GUEST 	150.0
2012-09-14 16:00:00 	2920 	Tennis Court 1 	GUEST GUEST 	75.0
2012-09-14 19:00:00 	2922 	Tennis Court 1 	GUEST GUEST 	75.0
2012-09-14 14:00:00 	2925 	Tennis Court 2 	GUEST GUEST 	75.0
2012-09-14 09:30:00 	2948 	Squash Court 	GUEST GUEST 	70.0
2012-09-14 14:00:00 	2941 	Massage Room 1 	Jemima Farrell 	39.6
2012-09-14 12:30:00 	2949 	Squash Court 	GUEST GUEST 	35.0
2012-09-14 15:00:00 	2951 	Squash Court 	GUEST GUEST 	35.0
*/

SELECT Cost.Time,
		Cost.BookID,
		Cost.Facility,
		CONCAT(Members.firstname, ' ', Members.surname) AS 'Member_or_Guest',
		Cost.Total_Cost
FROM
(SELECT Bookings.memid AS memid,
 		Bookings.starttime AS Time,
 		Bookings.bookid AS BookID,
		Facilities.name AS Facility,
		CASE WHEN Bookings.memid = 0 THEN Facilities.guestcost * Bookings.slots
		ELSE Facilities.membercost * Bookings.slots END AS 'Total_Cost'
FROM Bookings
JOIN Facilities
ON Bookings.facid = Facilities.facid
WHERE Bookings.starttime LIKE '2012-09-14%') AS Cost
JOIN Members
ON Cost.memid = Members.memid
WHERE Cost.Total_Cost > 30
ORDER BY Cost.Total_Cost DESC

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
/*
 FacilityID 	Facility 	Revenue Descending 	
8 	Pool Table 	270.0
7 	Snooker Table 	240.0
3 	Table Tennis 	180.0
*/

SELECT *
FROM (
SELECT Facilities.facid AS FacilityID,
		Facilities.name AS Facility,
		SUM(CASE WHEN Bookings.memid = 0 THEN Facilities.guestcost * Bookings.slots
		ELSE Facilities.membercost * Bookings.slots END) AS Revenue
FROM Bookings
JOIN Facilities
ON Bookings.facid = Facilities.facid
GROUP BY FacilityID ) AS subquery
WHERE subquery.Revenue < 1000
ORDER BY subquery.Revenue DESC