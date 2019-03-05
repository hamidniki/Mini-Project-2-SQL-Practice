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

SELECT 
	name
FROM Facilities
WHERE membercost > 0


/* Q2: How many facilities do not charge a fee to members? */

SELECT 
	COUNT(DISTINCT facid) AS facility_count
FROM Facilities
WHERE membercost = 0


/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT 
	facid,
	name AS "facility name",
	membercost AS "member cost",
	monthlymaintenance AS "monthy maintenance"

FROM Facilities 
WHERE membercost > 0 AND (membercost/monthlymaintenance)*100 < 20 


/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT *
	FROM Facilities 
WHERE facid IN (1,5)

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT 
	name AS "Facility Name",
	monthlymaintenance AS "Monthly Maintenance",
	CASE WHEN monthlymaintenance >100 THEN 'expensive'
	ELSE 'cheap' END AS "Cheap or Expensive"
FROM Facilities

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT 
	firstname AS "First Name",
	surname AS "Last Name",
	joindate AS "Join Date"
FROM Members
ORDER BY joindate DESC

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT
	c.name AS "Court Name",
	concat(a.surname,', ',a.firstname) AS "Member Name(Last, First)"

FROM Members a
JOIN Bookings b
ON a.memid = b.memid
Left JOIN Facilities c
ON b.facid = c.facid
WHERE c.name like '%Tennis Court%'
ORDER BY 2

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT 
	facs.name AS Facility_Name,
	concat(mems.surname,', ',mems.firstname) AS "Member Name(Last, First)",
	CASE WHEN books.memid=0 THEN books.slots*facs.guestcost
	ELSE books.slots*facs.membercost END AS Booking_Cost
FROM Bookings books
JOIN Members mems
ON books.memid = mems.memid
JOIN Facilities facs
ON books.facid=facs.facid

WHERE CAST(books.starttime AS DATE) = '2012-09-14'
AND CASE WHEN books.memid=0 THEN books.slots*facs.guestcost
	ELSE books.slots*facs.membercost END > 30
ORDER BY Booking_Cost DESC

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT 
	sub.Facility_Name,
	concat(mems.surname,', ',mems.firstname) AS "Member Name(Last, First)",
	sub.Booking_Cost
	

FROM Bookings books
JOIN Members mems
ON books.memid = mems.memid

JOIN (SELECT
		a.bookid,
		b.name AS Facility_Name,
		CASE WHEN a.memid=0 THEN a.slots*b.guestcost
		ELSE a.slots*b.membercost END AS Booking_Cost
		FROM Bookings a
		JOIN Facilities b
		ON a.facid = b.facid) sub
ON books.bookid = sub.bookid

WHERE CAST(books.starttime AS DATE) = '2012-09-14' AND sub.Booking_Cost > 30 
ORDER BY sub.Booking_Cost DESC

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT 
	sub.Facility_Name,
	sub.Income - 3*sub.monthlymaintenance AS Revenue

FROM (SELECT
      	b.facid,
	b.name AS Facility_Name,
      	b.monthlymaintenance,
		SUM(CASE WHEN a.memid=0 THEN a.slots*b.guestcost
			ELSE a.slots*b.membercost END) AS Income
		FROM Bookings a
		JOIN Facilities b
		ON a.facid = b.facid
     	GROUP BY 1,2) sub
WHERE sub.Income - 3*sub.monthlymaintenance < 1000
ORDER BY 2
