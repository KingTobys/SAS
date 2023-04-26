/*===creat a single observation from multiple records====
There are two types of line pointer controls.
 - The forward slash (/) specifies a line location that is relative to the current one.
 - The #n specifies the absolute number of the line to which you want to move the pointer.
*/

DATA highlow;
   INFILE '/courses/dbd74ce5ba27fe300/datafiles/Temperature.dat';
   INPUT City $ State $ 
         / NormalHigh NormalLow
         #3 RecordHigh RecordLow;
RUN;
PROC PRINT DATA = highlow;
   TITLE 'High and Low Temperatures for July';
RUN;

*=========================================================;
data patients;
INFILE '/courses/dbd74ce5ba27fe300/datafiles/patients.dat';
input #4 ID $5.
#1 Fname $ Lname $
#2 Address $23.
#3 City $ State $ Zip $
#4 @7 Doctor $6.;
run;

data patients1;
INFILE '/courses/dbd74ce5ba27fe300/datafiles/patients.dat';
input #4 ID $5.
#1 Fname $ Lname $
 /  Address $23.
 /  City $ State $ Zip $
 /  @7 Doctor $6.;
run;



/*===Create Multiple Observations from a Single Record====;*/
/*===
SAS provides two line-hold specifiers.
 The trailing at sign (@) holds the input record for the execution of the next INPUT
statement.
 The double trailing at sign (@@) holds the input record for the execution of the next
INPUT statement, even across iterations of the DATA step.

It's easy to distinguish between the trailing @@ and the trailing @ by remembering that
 the double trailing at sign (@@) holds a record across multiple iterations of the DATA
step until the end of the record is reached.
 the single trailing at sign (@) releases a record when control returns to the top of the
DATA step.
====;*/
DATA rainfall;
   INFILE '/courses/dbd74ce5ba27fe300/datafiles/Precipitation.dat';
   INPUT City $ State $ NormalRain MeanDaysRain @@;
RUN;
PROC PRINT DATA = rainfall;
   TITLE 'Normal Total Precipitation and';
   TITLE2 'Mean Days with Precipitation for July';
RUN;


data prescription1;
infile '/courses/dbd74ce5ba27fe300/datafiles/prescription1.dat';
input ID $ @;
do Quarter=1 to 4;
input Cost:  comma. @;
output;
end;
format Cost dollar9.2;
proc print;
run;


data prescription2;
infile '/courses/dbd74ce5ba27fe300/datafiles/prescription2.dat' missover;
input ID $ Cost: comma. @;
quarter=0;
do while (Cost ne .);
quarter+1;
output;
input Cost:  comma. @;
end;
format Cost dollar9.2;
proc print;
run;


* Use a trailing @, then delete surface streets;
DATA freeways;
   INFILE '/courses/dbd74ce5ba27fe300/datafiles/Traffic.dat';
   INPUT Type $ @;
   IF Type = 'surface' THEN DELETE;
   INPUT Name $ 9-38 AMTraffic PMTraffic;
RUN;
PROC PRINT DATA = freeways;
   TITLE 'Traffic for Freeways';
RUN;

/*===Reading Hierachical Files====*/
data census1(drop=type);
infile '/courses/dbd74ce5ba27fe300/datafiles/census.dat';
retain Address;
input type $1. @;
if type='H' then input @3 address $16.;
if type='P' then do;
input @3 name $10. @13 age 3. @16 gender $1.;
output;
end;
run;
proc print;
run;

/*Remember like the double trailing @@, the single trailing @
 enables the next INPUT statement to read from the same record
 releases the current record when a subsequent INPUT statement executes without a linehold
specifier.
*/

data count(drop=type);
infile '/courses/dbd74ce5ba27fe300/datafiles/census.dat' end=last;
retain Address;
input type $1. @;
if type='H' then do;
if _n_>1 then output;
total=0;
input address $ 3-17;
end;
else if type='P' then total+1;
if last then output;
run;
proc print;
run;


/*=====Statistical Graphics=====*/
*===PROC SGPLOT====;
DATA chocolate;
   INFILE '/courses/dbd74ce5ba27fe300/datafiles/Choc.dat';
   INPUT AgeGroup $ FavoriteFlavor $ Uniqueness @@;
RUN;
proc print;run;

* Bar charts for favorite flavor;
PROC SGPLOT DATA = chocolate;
   VBAR FavoriteFlavor / GROUP = AgeGroup;
   LABEL FavoriteFlavor = 'Flavor of Chocolate';
   TITLE 'Favorite Chocolate Flavors by Age Group';
RUN;

PROC SGPLOT DATA = chocolate;
   VBAR FavoriteFlavor / RESPONSE = Uniqueness  STAT = MEAN;
   LABEL FavoriteFlavor = 'Flavor of Chocolate';
   TITLE 'Uniqueness Ratings for Chocolate Flavors';
RUN;


*=======================================================;
DATA bikerace;
   INFILE '/courses/dbd74ce5ba27fe300/datafiles/Criterium.dat';
   INPUT Division $ NumberLaps @@;
RUN;
* Create histogram;
PROC SGPLOT DATA = bikerace;
   HISTOGRAM NumberLaps;
   DENSITY NumberLaps;
   DENSITY NumberLaps / TYPE = KERNEL;
   TITLE 'Bicycle Criterium Results';
RUN;
* Create box plot;
PROC SGPLOT DATA = bikerace;
   VBOX NumberLaps / CATEGORY = Division;
   TITLE 'Bicycle Criterium Results';
RUN;

*===========SCATTER DIAGRAMS=================================;
DATA onionrings;
   INFILE '/courses/dbd74ce5ba27fe300/datafiles/Onions.dat';
   INPUT VisTeam $ 1-20 CSales BSales OurHits VisHits OurRuns VisRuns;
   Action = OurHits + VisHits + OurRuns + VisRuns;
RUN;

* Plot Bleacher Sales by Action;
PROC SGPLOT DATA = onionrings;
   SCATTER X = Action Y = BSales;
   SCATTER X = Action Y = CSales;
   XAXIS LABEL = 'Hits + Runs' VALUES = (0 TO 40 BY 10);
   YAXIS LABEL = 'Number Sold';
   LABEL BSales = 'Sales in Bleachers'
         CSales = 'Sales at Stands';
   TITLE 'Onion Ring Sales vs. Game Action';
RUN;
TITLE;


*=========Series Plots======================================;
DATA temperatures;
   INFILE '/courses/dbd74ce5ba27fe300/datafiles/Temps.dat';
   INPUT Month IntFalls Raleigh Yuma @@;
RUN;

* Plot average high temperatures by city;
PROC SGPLOT DATA = temperatures;
   SERIES X = Month Y = IntFalls;
   SERIES X = Month Y = Raleigh;
   SERIES X = Month Y = Yuma;
   REFLINE 32 75 / TRANSPARENCY = 0.5 LABEL = ('32 degrees' '75 degrees');
   XAXIS TYPE = DISCRETE;
   YAXIS LABEL = 'Average High Temperature (F)';
   TITLE 'Temperatures by Month for International Falls, '
      'Raleigh, and Yuma';
RUN;

