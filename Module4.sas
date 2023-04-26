/*===Work with SAS functions==============================;
SAS functions are built-in routines for data manipulations.They are used to
convert, replace, extract from, and in general, create or calculate new values from, existing data values.
You can also use SAS functions to generate random variables.

function_name(argument1, argument2,...); 

*===Converting data======;
Automatic character-to-numeric conversion occurs when a character value is 
1. assigned to a previously defined numeric variable, such as the numeric variable Rate:
Rate=payrate;
2. used in an arithmetic operation: Salary=payrate*hours;
3. compared to a numeric value, using a comparison operator: if payrate>=rate;
4. specified in a function that requires numeric arguments: NewRate=sum(payrate,raise);

The automatic conversion
- uses the w.d informat, where w is the width of the character value that is being converted
- produces a numeric missing value from any character value that does not conform to
standard numeric notation (such as values containing special characters:%, $, commas ',', 
or digits with an optional decimal point).

Note that the WHERE statement does not perform automatic conversions in comparisons.*/

data newtemp1;
set sasuser.temp;
Salary=payrate*hours;
run;

/*============INPUT()======================*/
/*<variable>=INPUT(source, informat); /*character to numeric*/
/*source can be a character value, a constant, or an expression*/

/*When using the INPUT() function, the format of result depends on the type of informat.*/
data newtemp1;
set sasuser.temp;
Salary=input(payrate,2.)*hours;
run;

/*=======================================================;
Numeric data values are converted to character values whenever they are
used in a character context.
For example, the numeric values of the variable Site are converted to character values if you
1. assign the numeric value to a previously defined character variable, such as the
character variable SiteCode: SiteCode=site 
2. use the numeric value with an operator that requires a character value, such as the
concatenation operator: SiteCode=site||dept;
3. specify the numeric value in a function that requires character arguments, such as the
SUBSTR function: Region=substr(site,1,4);*/

/*============PUT()======================*/
/*<variable>=PUT(source, format); /*numeric to character*/
/*source can be a numeric value, a constant, or an expression*/
/*In the PUT() function, the format you use must be of the same type as the source variable type*/
/*When using the PUT() function, the result is always a character string.*/
data newtemp2;
set sasuser.temp;
Assignment=site||'/'||dept;
run;

data newtemp2;
set sasuser.temp;
Assignment=put(site,2.)||'/'||dept;
run;

data a;
input name $ id gender $ mid1 mid2 final $ dob mmddyy8. major $25.;
format dob mmddyy10.;
cards;
Steve  2342 M 75 82 85.5 01/28/82 Economics
Jen 2783 F 67 65 70.8 04/08/84 Mathematics
Chris 3218 M 89 93 90.5 08/23/83 Electronic Engineering
Matt 3569 M 82 . 95.1 06/01/83 Music
Vivien 1498 F 77 85 83.3 11/05/82 History
Amy 4136 F . 82 87.7 10/27/84 Political Science
Nicole 4057 F 91 92 90.4 05/02/83 Finance
run;

data a1;
set a;
id1=put(id,4.);
final1=input(final,4.1);
drop id final;
run;

/*===Date functions================================;*/
/*SAS date values are numeric. A date value is the number of days from January 1, 1960 to a given date.*/
*===year(),qrt(),month(),day(),week();
data sch1;
set sasuser.sch;
dy=day(airdate);
mn=month(airdate);
yr=year(airdate);
run;

data sch2;
set sch1;
airdate1=mdy(mn,dy,yr);
format airdate1 mmddyy10.;
run;

data schwkend;
set sasuser.sch;
if weekday(airdate)=7 or weekday(airdate)=1;
run;

data newtemp3;
set sasuser.temp;
editDate=date();*today();
format editdate date9.;
run;

/*===INTCK Function====;
*===intck('interval',from date,to date)===;
*The INTCK function returns the number of time intervals that occur in a given time span. You can
use it to count the passage of days, weeks, months, and so on. The intervals are counted from fixed interval
beginnings,not in multiples of an interval unit from the 'from date'. 
Week intervals are counted by Sundays,not by multiples of 7 days;
Month intervals are counted by the first day of each month,not by multiples of 30 or 31 days;
Year intervals are counted by January 1st, not by multiples of 360 or 365 days;*/

data anniv40;
set sasuser.mechanics(keep=id lastname firstname hired);
years=intck('year',hired,'01jul2016'd);
if years=40 and month(hired)=month('01jul2016'd);
proc print data=anniv40;
title '40-Year Anniversaries This Month';
run;

*===INTNX Function====;
*===intnx('interval',start_from,increment,<alignment>)===;
*The INTNX function is similar to the INTCK function. The INTNX function applies multiples of a
given interval to a date, time, or datetime value and returns the resulting value. You can use the
INTNX function to identify past or future days, weeks, months, and so on;

data exintnx;
monthb=intnx('month','20jul16'd,3,'b');/* 'b'-beginning of a month*/
monthm=intnx('month','20jul16'd,3,'m');/* 'm'-middle of a month*/
monthe=intnx('month','20jul16'd,3,'e');/* 'e'-end of a month*/
months=intnx('month','20jul16'd,3,'s');/* 's'-same day of a month, which is the default value*/
format monthb monthm monthe months date9.;
run;

/*===DATDIF and YRDIF Functions===
The DATDIF and YRDIF functions calculate the difference in days and years between two SAS
dates, respectively. Both functions accept start dates and end dates that are specified as SAS
date values. Also, both functions use a basis argument that describes how SAS calculates the
date difference.
DATDIF(start, end, basis);
YRDIF(start,end,basis);
Basis includes '30/360', 'ACT/ACT','ACT/360',and 'ACT/365'.*/

data _null_;
   sdate='20mar2013'd;
   edate='20jul16'd;
   y1=yrdif(sdate, edate, '30/360');
   y2=yrdif(sdate, edate, 'ACT/ACT');
   y3=yrdif(sdate, edate, 'ACT/360');
   y4=yrdif(sdate, edate, 'ACT/365');
   put y1= / y2= / y3= / y4= ;
run;

*===SCAN Function====
The SCAN function enables you to separate a character value into words and to return a
specified word;

/*Default Delimiters
If you do not specify delimiters when using the SCAN function, default delimiters are used. The
default delimiters are
blank . < ( + | & ! $ * ) ; ^ - / , % */

*scan(a character value,n,delimiter), the delimiter must be quoted in single quotation marks ('');

data students(drop=student_name);
set sasuser.students;
length lastname firstname $ 12;
LastName=scan(student_name,1);
FirstName=scan(student_name,3);
run;

*===SUBSTR function====
It enables you to extract any number of characters from a character string,
starting at a specified position in the string;
*substr(variable or a character string,position,<n>);
data students1;
set students;
initials=substr(firstname,1,1)||substr(lastname,1,1);
run;

data temp(drop=exchange);
set sasuser.temp;
exchange=substr(phone,1,3);
if exchange='622' then substr(phone,1,3)='433';
run;

*===TRIM Function====
The TRIM function enables you to remove trailing blanks from character values;
data newtemp;
set sasuser.temp;
newAddress=address||', '||city||', '||zip;
drop address city state zip;
run;

data newtemp1;
set sasuser.temp;
newAddress=trim(address)||', '||trim(city)||', '||zip;
drop address city state zip;
run;

*===an alternative is use CATX function====;
data newtemp2(drop=address city state zip);
set sasuser.temp;
newAddress=catx(', ',address,city,zip);
run;


/*===INDEX Function====
The INDEX function enables you to search a character value for a specified string. The INDEX
function searches values from left to right, looking for the first occurrence of the string. It returns
the position of the string's first character; if the string is not found, it returns a value of 0.*/

data job1;
set sasuser.temp;
index_position=index(job,'word processing');
if index_position> 0;
run;

*===Note that the character string is case sensitive====;

*===Alternatively, you may use FIND fuction====;
data job2;
set sasuser.temp;
index_index=index(job,'word processing');
index_find=find(job,'word processing','i t');
run;

*===UPCASE,LOWCASE,and PROPCASE====;
data cases;
set sasuser.temp;
jobup=upcase(job);
joblow=lowcase(job);
jobprop=propcase(job);
run;

*===TRANWRD====
The TRANWRD function replaces or removes all occurrences of a pattern of characters within a
character string. The translated characters can be located anywhere in the string;
data students2;
set sasuser.students;
name=tranwrd(student_name,'Ms.','Miss');
run;

data class;
input name $ gender $ gpa dob mmddyy8.;
datalines;
Joe m 3.6 10/23/83
Linda f 3.72 08/18/84
Bob m 3.25 02/14/82
Tom m 3.66 06/01/83
Carrie f 2.78 12/24/82
;run;

data class1;
set class;
gpa1=round(gpa,.2);
run;
proc print;run;

proc contents data=class1;run;









*=====================================================;
/*===============Do Loops=============================*/
*Do loops enable us to execute SAS statements repeatedly and avoid redundancy in writing SAS codes;

data investments;
input id $ amount rate;
format amount dollar6. rate 5.3;
cards;
c1001 5000 0.08
c1002 8000 0.05
c1003 10000 0.12
c1004 8000 0.10
c1005 7000 0.075
;
run;

data investments0;
set investments;
earned=amount*(1+rate/12)**12-amount;
run;
proc print;run;

data investments1;
set investments;
Earned=0;
earned+(amount+earned)*(rate/12);
earned+(amount+earned)*(rate/12);
earned+(amount+earned)*(rate/12);
earned+(amount+earned)*(rate/12);
earned+(amount+earned)*(rate/12);
earned+(amount+earned)*(rate/12);
earned+(amount+earned)*(rate/12);
earned+(amount+earned)*(rate/12);
earned+(amount+earned)*(rate/12);
earned+(amount+earned)*(rate/12);
earned+(amount+earned)*(rate/12);
earned+(amount+earned)*(rate/12);
run;

data investments1;
set investments;
Earned=0;
do count=1 to 12;
earned+(amount+earned)*(rate/12);
end;
run;
proc print;run;
*===========================================;
data monthnum(drop=count);
set investments;
Earned=0;
Month=0;
do count=1 to 12;
earned+(amount+earned)*(rate/12);
Month+1;
end;
run;
proc print;run;
*========================================;
data investout;
set investments;
Earned=0;
do month=1 to 12;
earned+(amount+earned)*(rate/12);
output;
end;
run;
proc print;run;
*==========================================;
data investout1;
set investments;
Earned=0;
do count=-2,2,3,4,5;
earned+(amount+earned)*(rate/12);
output;
end;
run;


*===Nesting Do Loops===;
data one;
do group=1 to 3;
do rcd=1 to 10;
/*do obs=1 to 10 for group 1, then do obs=1 to 10 for group 2*/
response=10+group+2*normal(0);
/*normal() function generates random numbers from the standard normal distribution*/
output;
end;
end;
run;
proc print;run;
*=============================;
data earn1(drop=month);
do year=1 to 20;
Capital+2000;
output;
do month=1 to 12;
capital+capital*(.075/12);
end;
output;
end;
run;
proc print;run;

proc sort data=earn1;by year;run;
data interest;
set earn1;
by year;
interest=capital-lag(capital);
if last.year then output;
run;
proc print;run;
*======================================;
*========================================;
data funds;
input name $ rate years;
cards;
DIA 0.08 5
SPY 0.12 8
QQQ 0.15 10
;
RUN;
data compare(drop=years);
set funds;
Investment=5000;
do year=1 to years;
investment+rate*investment;
output;
end;
format investment dollar10.2;
run;
proc print;run;

*===Do Until and Do While===============================;
data invest;
do until(Capital<=50000);
capital+2000;
capital+capital*.10;
Year+1;
output;
end;
run;
proc print;run;

data invest1;
do while(Capital>=50000);
capital+2000;
capital+capital*.10;
Year+1;
output;
end;
run;
proc print;run;

*===Do Until expression is evaluated at the end of a Do Loop, whereas Do While expression is evaluated at the top of a Do Loop;

*===Do Loop is excuted until the expression condition is met OR the index value reaches its STOP value, whichever occurs first======================;
data invest(drop=i);
do i=1 to 10 until(Capital>=50000);
Year+1;
capital+5000;
capital+capital*.10;
end;
run;

*==================================================;
data sample;
   input x;
   exit=10;
   count=0;
   do i=1 to exit;
      y=x*normal(0);
         /* if y>25,           */ 
         /* changing i's value */
         /* stops execution    */
      if y>25 then i=exit;
	  count+1;
      output;
   end;
   datalines;
10
20
300
;
run;
proc print;run;

*===Create data sets===;
data earn1;
do year=1 to 20;
Capital+2000;
output;
do month=1 to 12;
capital+capital*(.075/12);
end;
output;
end;
run;

data initial1;
do sample=2 to 40 by 2;
set earn1 point=sample;
output;
end;
stop;
run;
*========================================;
