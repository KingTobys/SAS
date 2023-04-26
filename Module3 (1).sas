/*===BASE Programming===*/
*Creating and Managing Variables===;

data cars1;
set sashelp.cars;
if (type='Sedan' or origin='Europe') and enginesize<2;
run;
proc print;
run;

data cars2;
set sashelp.cars;
if type^='Sedan' and origin='Europe' and enginesize<2;
proc print;
run;

data cars3;
set sashelp.cars;
if origin not in ('Europe','USA') & not (enginesize<2);
keep type origin enginesize;
run;proc print;run;


data cars4;
set sashelp.cars;
length powerlevel $8;
if enginesize<2 then powerlevel='WEAK';
else if 2<=enginesize<4 then powerlevel='LOW';
else if 4<=enginesize<6 then powerlevel='MEDIUM';
else if 6<=enginesize<8 then powerlevel='HIGH';
else powerlevel='VROOMING';
KEEP TYPE ORIGIN ENGINESIZE POWERLEVEL;
proc print;
run;

*===Delete observations====;
data a1;
set sashelp.cars;
if mpg_highway<30 then delete;
run;
proc print;run;

*===SELECT statement===;
data cars5;
set sashelp.cars;
length powerlevel $8;
select;
when (enginesize<2) powerlevel='WEAK';
when(2<=enginesize<4) powerlevel='LOW';
when(4<=enginesize<6) powerlevel='MEDIUM';
when(6<=enginesize<8) powerlevel='HIGH';
OTHERWISE powerlevel='VROOMING';
END;
KEEP TYPE ORIGIN ENGINESIZE POWERLEVEL;
PROC PRINT;
RUN;

*===POINT & END ===;
data class1;
obsnum=8;
set sashelp.class point=obsnum;
output;
stop;
run;

data class2;
set sashelp.class end=last;
index_last=last;
if last;
run;


*===SUM statement and Retain statement=========;
data myclass.totalcost;
set sasuser.repair;
tcost+cost;
run;
proc print;run;

data totalcost;
set sasuser.repair;
retain tcost 100;
tcost+cost;
run;
proc print data=totalcost;run;



/*===First & Last logic variables===*/
data a;
input name $ id $ gender $ mid1 mid2 final dob mmddyy8. major $25.;
format dob mmddyy10.;
cards;
Steve  2342 M 75 82 85 01/28/82 Economics
Jen 2783 F 67 65 70 04/08/84 Mathematics
Chris 3218 M 89 93 90 08/23/83 Electronic Engineering
Matt 3569 M 82 . 95 06/01/83 Music
Vivien 1498 F 77 85 83 11/05/82 History
Amy 4136 F . 82 87 10/27/84 Political Science
run;

proc sort data=a;by gender;run;

data a1;
set a;by gender;
fid=first.gender;
lid=last.gender;
keep name gender fid lid;
run;



/*First & LAST*/
data numbers;
set a;by gender;
fid=first.gender;
lid=last.gender;
if first.gender then count=0;
count+1;
if last.gender then output;
keep name id gender fid lid count;
run;



/**first time repair*/
proc sort data=sasuser.repair out=repair1; by unit date;run;

data firstrep;
set repair1;
by unit;
if first.unit then output;
label date='First Repair Date';
keep unit date;
run;
proc print data=firstrep label;run;



/*for each unit, count the # of times it was repaired and calculate total cost and average
cost for each unit*/
data repcosts;
set repair1;
by unit;
if first.unit then do; numreps=0;sumcost=0;end;
numreps+1;sumcost+cost;
if last.unit then do;avgcost=sumcost/numreps;output;end;
keep unit numreps sumcost avgcost;
run;
proc print data=repcosts;run;










*===SET statement for combining data sets===;


data purple;
input B C;
datalines;
2 11
5 9
5 6 
9 3
10 1
11 7
;run;

data yellow;
input A B;
cards;
3 1
5 3
7 5
9 7
10 10
;run;


data brown;
set purple;
set yellow;
run;
proc print;run;


/*SET, concatenate datasets*/

data brown1;
set purple yellow;
by b;
run;

data brown2;
set purple yellow;by b;
if b<6 then do;c=c+1;total=b+c;end;
else do;c=c*2;total=b+c-5;end;
run;

proc print;run;

/*===proc append===check chapter 12 for details===*/


/*Match Merging*/
data a;
input name $ id $ gender $ mid1 mid2 final dob mmddyy8. major $25.;
format dob mmddyy10.;
cards;
Steve  2342 M 75 82 85 01/28/82 Economics
Jen 2783 F 67 65 70 04/08/84 Mathematics
Chris 3218 M 89 93 90 08/23/83 Electronic Engineering
Matt 3569 M 82 . 95 06/01/83 Music
Vivien 1498 F 77 85 83 11/05/82 History
Amy 4136 F . 82 87 10/27/84 Political Science
Nicole 4057 F 91 92 90 05/02/83 Finance
run;

data b;
input name $ hsgpa attdn $9.;
cards;
Steve  3.2 good
Vivien 2.9 good
Amy 3.3 good
Jen 3.0 poor
Chris 3.4 excellent
Matt 3.25 good
Jason 3.7 excellent
run;


data c;
merge a b;
by name;
run;


proc sort data=a;by name;run;
proc sort data=b;by name;run;


data c;
merge a(in=ina) b(in=inb);
indxa=ina;indxb=inb;
by name;
if ina=1 and inb=1;
run;
proc print;
run;




/*Merge data sets with same names of variables*/

data one;
input A $ B;
datalines;
n1 11
n2 6 
n4 3
n5 1
n3 7
;run;

data two;
input A $ B C;
cards;
n1 5 3   
n2 3 4
n3 5 5
n5 7 6
n6 10 7
;run;

proc sort data=one;by a;run;
proc sort data=two;by a;run;

data combined;
merge one two;
by a;
run;

data combined1;
merge one two(rename=(B=B1));
by a;
run;

/* Combine a single observation with many observations without a common variable */
* Output grand total of sales to a data set;
DATA shoes;
   INFILE '/courses/dbd74ce5ba27fe300/datafiles/Shoesales.dat';
   INPUT Style $ 1-15 ExerciseType $ Sales;
run;

PROC MEANS NOPRINT DATA = shoes;
   VAR Sales;
   OUTPUT OUT = summarydata SUM(Sales) = GrandTotal;
run;

PROC PRINT DATA = summarydata;
   TITLE 'Summary Data Set';
RUN;

* Combine the grand total with the original data;
DATA shoesummary;
   IF _N_ = 1 THEN SET summarydata;
   SET shoes;
   Percent = Sales/GrandTotal*100;
run;

PROC PRINT DATA = shoesummary;
   VAR Style ExerciseType Sales GrandTotal Percent;
   TITLE 'Overall Sales Share';
RUN;


/* One to Many Merge */	

PROC SORT DATA = shoes;
   BY ExerciseType;
RUN;

* Summarize sales by ExerciseType;
PROC MEANS NOPRINT DATA = shoes;
   VAR Sales;
   BY ExerciseType;
   OUTPUT OUT = summarydata SUM(Sales) = Total;
run;
   
PROC PRINT DATA = summarydata;
   TITLE 'Summary Data Set';
RUN;
* Merge the total with the original data set;
DATA shoesummary;
   MERGE shoes summarydata;
   BY ExerciseType;
   Percent = Sales / Total * 100;
run;

PROC PRINT DATA = shoesummary;
   BY ExerciseType;
   ID ExerciseType;
   VAR Style Sales Total Percent;
   TITLE 'Sales Share by Type of Exercise';
RUN;
	

/* Use OUPUT statement to create more than one SAS data set */	
DATA morning afternoon;
   INFILE '/courses/dbd74ce5ba27fe300/datafiles/Zoo.dat';
   INPUT Animal $ 1-9 Class $ 11-18 Enclosure $ FeedTime $;
   IF FeedTime = 'am' THEN OUTPUT morning;
      ELSE IF FeedTime = 'pm' THEN OUTPUT afternoon;
      ELSE IF FeedTime = 'both' THEN OUTPUT;
RUN;
PROC PRINT DATA = morning;
   TITLE 'Animals with Morning Feedings';
PROC PRINT DATA = afternoon;
   TITLE 'Animals with Afternoon Feedings';
RUN;

	

