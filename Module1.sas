/*========Base Programming=======================================*/
/*Data steps and Proc steps*/

proc print data=sashelp.class;
run;

data teens;
set sashelp.class;
run;


proc print data=sashelp.class;
var name sex age;
where age>=13;
run;


data teens;
set sashelp.class;
keep name sex height weight;
where age>=13;
run;

*proc sort and proc contents;

data female;
set sashelp.class;
keep name height weight;
where sex='F' & height>63;
run;

proc sort data=female;by height;run;

proc sort data=sashelp.class out=sorted_class;
by sex descending age;
run;

proc contents data=sashelp.class;run;

*add labels to variables;

proc print data=sashelp.class label;
label name='First Name';
run;

data class;
set sashelp.class;
label name='First Name' height='Height (inches)' weight='Weight (lbs)';
run;
proc print data=class label;run;







*========Titles and Footnotes============================;

data teens;
set sashelp.class;
keep name sex height weight;
where age>=13;
title1 'Report for Teens';/*add my first titel*/
title3 'Class 2016';
footnote 'Child obesidy study for a project with Youngstown State University';
run;
proc print;
run;

title1;
title3;
footnote;

*SAS options and formats;

data a;set sashelp.stocks (firstobs=100);
format date mmddyy10.;
run;
proc print;run;

proc print data=sashelp.class (obs=5);
run;


data a;set sashelp.stocks (obs=100);
format date mmddyy10.;
run;
proc print;run;


data a;set sashelp.stocks (firstobs=51 obs=100);
format date mmddyy10.;
run;
proc print;run;


proc print data=a(firstobs=5 obs=10);
run;


data b;
set sashelp.stocks;
*where stock='IBM' or stock='Intel';
where stock in ('IBM','Intel');
run;
proc print;run;



/*use cards/datalines to directly input data in SAS (instream data)*/
data trial;
input id $ hour;
datalines;/*lines; or cards;*/
A1023 7
B2418 8
C0796 6
D0821 5
;
run;

proc print data=trial;
sum hour;
run;

options yearcutoff=1900;
data trial_a;
input id $ hours date mmddyy8.;
datalines;
A1023 7 05/09/16 
B2418 8 05/10/16
C0796 6 05/11/16
;
proc print;format date mmddyy10.;run;


data college;
input name $ id $ gender $ mid1 mid2 final dob mmddyy8. major $;
format dob mmddyy10.;
cards;
Steve  2342 M 75 82 85 01/28/82 Economics
Jen 2783 F 67 65 70 04/08/84 Mathematics
Chris 3218 M 89 93 90 08/23/83 Electronic Engineering
Matt 3569 M 82 . 95 06/01/83 Music
Vivien 1498 F 77 85 83 11/05/82 History
Amy 4136 F . 82 87 10/27/84 Political Science
;
run;


proc print data=a;run;*print the data to make sure that it's read correctly;

data averagescores;
set college;
wavg=0.3*mid1+0.3*mid2+0.4*final;
keep name id gender wavg dob major;
run;
proc print;run;







*===Read a data file using column input;
DATA sales;
   INFILE '/courses/dbd74ce5ba27fe300/datafiles/OnionRing.dat';/*SAS studio data directory*/
   INPUT VisitingTeam $ 1-20 ConcessionSales 21-24 BleacherSales 25-28
         OurHits 29-31 TheirHits 32-34 OurRuns 35-37 TheirRuns 38-40;
RUN;

PROC PRINT DATA = sales;
   TITLE 'SAS Data Set ''Sales''';
RUN;

*Read a data file using formatted input;

DATA contest;
   INFILE '/courses/dbd74ce5ba27fe300/datafiles/Pumpkin.dat' ;
   INPUT Name $16. Age 3. +1 Type $1. +1 Date MMDDYY10.(Score1 Score2 Score3 Score4 Score5) (4.1);
   format date mmddyy10.;

RUN;
* Print the data set to make sure the file was read correctly;
PROC PRINT DATA = contest;
   TITLE 'Pumpkin Carving Contest';
RUN;



* Read a data file using mixing input styles;
FILENAME natparks '/courses/dbd74ce5ba27fe300/datafiles/NatPark.dat';
DATA nationalparks;
   INFILE natparks;
   INPUT ParkName $ 1-22 State $ Year @40 Acreage COMMA9.;
RUN;
PROC PRINT DATA = nationalparks;
   TITLE 'Selected National Parks';
   format acreage comma9.;
RUN;


*===Create a permanent library==========;
*===Students won't be able to create their own permanent libraries in SAS OnDemand===;
Libname mysas 'f:/ECON6990/sas_data';/*SAS 9.4*/

libname myclass '/courses/dbd74ce5ba27fe300/';/*SAS Studio*/


*Read a text file;

filename cpidata '/courses/dbd74ce5ba27fe300/datafiles/CPI.txt';


data myclass.cpi;
infile cpidata;
input date yymmdd10. cpi;
format date yymmdd10.;
mn=month(date);
yr=year(date);
lgcpi=log(cpi);
lagcpi=lag(lgcpi);
pi=100*(lgcpi-lagcpi);
run;

data deflation;
infile cpidata;
input date yymmdd10. cpi;
format date yymmdd10.;
pi=dif(cpi)/lag(cpi)*100;
if pi<0;
run;

