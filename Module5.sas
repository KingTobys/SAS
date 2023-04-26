/*ARRAY*/

/*A SAS array - use it to perform the same actions on a group of variables

array month(1:5) Jan Feb Mar Apr May;
array name is "month" 
the sequence of variable names Jan Feb Mar Apr May is the "array list" 
the variables in the array list are the "array elements" 
each array element in this example has a position number in the array list from 1 to 5 

Examples:
array x(1:6) a b c d e f; x(5) is variable e
array x(0:5) a b c d e f; x(4) is variable e
array quiz(20) q1-q20; 
array quiz(1:20) q1-q20; 
array quiz(*) q1-q20;  
array color(1:3) $ 1 red blue green; 
array pop(1:5) yr95-yr99; pop(2) is yr96
array pop(95:99) yr95-yr99; pop(96) is yr96
array x(*) _numeric_; all numeric variables 
array y(*) _character_;  all character variables 
array z(*) _all_;    all variables  
array cols{4} c1 c2 c3 c4 (1 2 3 4); assigne initial values
array var[4] (1, 2, 3, 4); without a list of array elements
array cross(2,3) v1-v6; two-dimentional arrays (please read chapter 15 for more details)
*/


/*Examples from SAS companies sample library: http://support.sas.com/ctx/samples/index.jsp?sid=139&tab=code*/
/*Example 1: Iterative DO loop using WHILE*/
data one;
  drop i;
  input v1-v4;
  array v(4);
  count=0;
  do i=1 to dim(v) while (v{i}=1);
    count +1;
  end;
datalines;
1 1 0 1
1 1 1 0
1 0 1 1
0 1 0 0
;
run;
proc print;
run;



/*Example 2: change the data value of numeric variables*/
data poll;
  drop i;
  input x1 x2 x3 x4 $ x5  x6 $ x7;
  array y(*) x3-numeric-x7;
   do i=1 to dim(y);
     y(i)=y(i) *100;
   end;
datalines;
1 2 3 yes 4  no 5
11 22 33 abstain 44 yes 55
;

proc print;
run;



/*Example 3: Convert all numeric missing values to zero. */
data numbers;                                                           
input var1 var2 var3;                                                   
datalines;                                                              
7 1 4                                                                   
. 0 8                                                                   
9 9 .                                                                   
5 6 2                                                                   
8 3 0                                                                   
;                                                                   
run;
                                                                        
data nomiss(drop=i);                                                    
  set numbers;                                                            
  array testmiss(*) _numeric_;                                            
  do i = 1 to dim(testmiss);                                              
    if testmiss(i)=. then testmiss(i)=0;                                    
  end;                                                                    
run;                                                                    

proc print;
run;


/* Example 4: Convert selected numeric values from zero to missing*/

data deptnum;                              
  input dept qtr1 qtr2 qtr3 qtr4;            
datalines;                                 
101 3 0 4 9                                
410 8 7 5 8                                
600 0 0 6 7                                
700 6 5 0 9                                
901 3 8 7 0                                
;
run;                                       
                                           
data nozero(drop=i);                       
  set deptnum; 
  /* Note numeric variables DEPT and QTR4 will not be affected */                               
  array testzero(*) qtr1-qtr3;       
  do i = 1 to dim(testzero);                 
    if testzero(i)=0 then testzero(i)=.;       
  end;                                       
run;

proc print;
run;

proc means data=nozero;
var qtr1-qtr3;
run;


/*Example 5: Using arrays to create new variables*/
data diff;
set deptnum;
array qtr(4) qtr1-qtr4;
array qdif(3) qd2-qd4;
do j=1 to 3;
qdif(j)=qtr(j+1)-qtr(j);
end;
drop j;
run;


/*Example 6: Using _TEMPORARY_ arrays*/
data test;
  input var1 var2 var3;
datalines;                
10 20 30
100 . 300
. 40 400
;
run;

/* The _TEMPORARY_ array values are used to populate the missing values         */
/* in the TEST data set.  The data set variables are put into an array and      */
/* there is a one to one correlation between the existing values and the values */
/* in the _TEMPORARY_ array. A DO loop is used to evaluate if the value is      */
/* missing and if so, assign the new value.                                     */


data new(drop=i);
  set test;
  array newval(3)_TEMPORARY_ (.1 .2 .3) ;
  array now(3) var1 var2 var3;
  do i=1 to 3;
    if now(i)=. then now(i)=newval(i);
  end;
run;

proc print;
run;




/*Example 7: using array to convert the values of a variable*/

data weight;
input name $ mn1 mn2 mn3 mn4;
cards;
John 238 223 214 199
Karen 183 175 176 168
Sam 165 168 172 178
;
run;

Data a;
set weight;
mnkg=mn1/2.206;month=1;output;
mnkg=mn2/2.206;month=2;output;
mnkg=mn3/2.206;month=3;output;
mnkg=mn4/2.206;month=4;output;
keep name mnkg month;
run;
proc print;run;


Data aa;
set weight;
array mn{4} mn1-mn4;
do month=1 to 4;
mnkg=mn(month)/2.206;
output;
end;
drop mn1-mn4;
run;
proc print;run;


data price;
input date mmddyy10. pr1 pr2 pr3;
format date date9.;
cards;
05/01/2015 70 12 108
06/01/2015 72 11 112
07/01/2015 75 14 114
;
data bb;
set price;
array pr(3) pr1-pr3;
array rt(3);
do k=1 to 3;
rt(k)=100*(log(pr(k))-log(lag(pr(k))));
end;
run;


/* Example 8: Expand single observations into multiple observations*/
data times;
  input date date9. day_1 day_2 day_3 day_4 day_5 day_6 day_7;
  format date date9.;
datalines;
03APR2000    4.00    9.75    9.25    4.00    9.75    5.75     0
10APR2000    8.75    7.75    0.00    0.50    2.25    9.75     0
17APR2000    4.25    6.50    8.25    0.00    8.00    2.00     0
24APR2000    3.25    6.50    8.00    8.75    4.00    9.50     0
;

data new ;
  set times;

  /* Group the days into an array */
  array day_(*) day_1-day_7;

  /* Move the information into a single variable, write the observation */
  /* to the output data set and increment the DATE variable.            */
  do i = 1 to dim(day_);
    hours=day_(i);
    output;
    date+1;
  end;

  /* Choose the variables to keep in the output data set */
  keep date hours;
run;

proc print;
run;











/*=======Reading external data files into SAS to create SAS data sets================*/
/*
Standard Numeric Data---
Standard numeric data values can contain only
 -numbers
 -decimal points
 -numbers in scientific, or E, notation (23E4)
 -minus signs and plus signs.
Some examples of standard numeric data are 15, -15, 15.4, +.05, 1.54E3, and -1.54E-3.\

Nonstandard Numeric Data---
Nonstandard numeric data includes
 -values that contain special characters, such as percent signs (%), dollar signs ($), and commas (,)
 -date and time values
 -data in fraction, integer binary, real binary, and hexadecimal forms.
*/


*===Read raw data in fixed fields====;
DATA sales;
   INFILE '/courses/dbd74ce5ba27fe300/datafiles/OnionRing.dat';
   INPUT VisitingTeam $ 1-20 ConcessionSales 21-24 BleacherSales 25-28
         OurHits 29-31 TheirHits 32-34 OurRuns 35-37 TheirRuns 38-40;
RUN;

PROC PRINT DATA = sales;
   TITLE 'SAS Data Set ''Sales''';
RUN;

*===Column pointers: @n and +n ====;
DATA sales;
   INFILE '/courses/dbd74ce5ba27fe300/datafiles/OnionRing.dat';
   INPUT VisitingTeam $20. +1 ConcessionSales 4. @25 BleacherSales 4.
         OurHits 29-31 TheirHits 32-34 OurRuns 35-37 TheirRuns 38-40;
RUN;

PROC PRINT DATA = sales;
   TITLE 'SAS Data Set ''Sales''';
RUN;


*===Reading Nonstandard Numeric Data
The COMMAw.d informat is used to read numeric values and to remove embedded
 blanks
 commas
 dashes
 dollar signs
 percent signs
 right parentheses
 left parentheses, which are converted to minus signs;

DATA nationalparks;
   INFILE '/courses/dbd74ce5ba27fe300/datafiles/NatPark1.dat';
   INPUT ParkName $ 1-21 +1 State $8. @32 Year 4. @40 Acreage COMMA9.;
RUN;
PROC PRINT DATA = nationalparks;
   TITLE 'Selected National Parks';
RUN;

/*===PAD====;
When you use column input or formatted input to read fixed-field data in variable-length records,
you can avoid problems by using the PAD option in the INFILE statement.The PAD option pads
each record with blanks so that all data lines have the same length.*/
DATA nationalparks;
   INFILE '/courses/dbd74ce5ba27fe300/datafiles/NatPark2.dat' PAD;
   INPUT ParkName $ 1-21 +1 State $8. @32 Year 4. @40 Acreage COMMA9.;
   format acreage comma9.;
RUN;
PROC PRINT DATA = nationalparks;
   TITLE 'Selected National Parks';
RUN;


*===Read free-format data====;
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
/*Because list input, by default, does not specify column locations,
 -all fields must be separated by at least one blank or other delimiter
 -fields must be read in the order from left to right
 -you cannot skip or re-read fields.*/

*Read a data file using formatted input and list input;

DATA contest;
   INFILE '/courses/dbd74ce5ba27fe300/datafiles/Pumpkin.dat';
   INPUT Name $16. Age 3. +1 Type $1. +1 Date MMDDYY10.(Score1 Score2 Score3 Score4 Score5) (4.1);
   format date mmddyy10.;
RUN;
* Print the data set to make sure the file was read correctly;
PROC PRINT DATA = contest;
   TITLE 'Pumpkin Carving Contest';
RUN;

/*================================
MISSOVER 
prevents an INPUT statement from reading a new input data record if it does not find values 
in the current input line for all the variables in the statement. 
When an INPUT statement reaches the end of the current input data record, 
variables without any values assigned are set to missing.
*/
DATA class101;
   INFILE '/courses/dbd74ce5ba27fe300/datafiles/AllScores.dat';
   INPUT Name $ Test1 Test2 Test3 Test4 Test5;
RUN; 
PROC PRINT;RUN;


/* read comma-delimited files*/
data class;
infile '/courses/dbd74ce5ba27fe300/datafiles/class.txt' dsd;/*DSD stands for delimiter sensitive data*/
input name: $12. absences quiz dob mmddyy8.;
format dob yymmdd10.;
run;
proc print;run;

DATA music;
   INFILE '/courses/dbd74ce5ba27fe300/datafiles/Bands.csv' DSD MISSOVER;
   INPUT BandName :$30. GigDate: MMDDYY10. EightPM NinePM TenPM ElevenPM;
RUN;
PROC PRINT DATA = music;
   TITLE 'Customers at Each Gig';
RUN;

*===Modified list input====;
*===With the colon format modifier (:), you can read character variables whose values have
more than eight characters and numeric variables that contain special characters, like $, %, commas.
To use the colon format modifier with list input, place the colon between the variable name
and the informat. As in simple list input, at least one blank (or other defined delimiter character)
must separate each value from the next, and character values cannot contain embedded blanks
(or other defined delimiter characters). Consider this DATA step:
;
data january_sales;
   input Item: $12. Amount : comma5.;
   datalines;
Trucks 1,382 
Vans 1,235 
Sedans 2,391 
SportUtility 987
;  

proc print data=january_sales;     
   title 'January Sales in Thousands';    
run;


*===With the ampersand format modifier (&) you can use list input to read data that contains
single embedded blanks. The only requirement is that there must be at least two blanks between the
variable with single embedded blanks in its values and the next variable.
To use the ampersand format modifier with list input, place the ampersand 
between the variable name and the informat. 
The following DATA step uses the ampersand format modifier with list input to create the data set CLUB2. 
Note that the data is not in fixed columns. Therefore, column input or formatted input is not appropriate.;
data club2;
   input IdNumber Name & $18. Team $ StartWeight EndWeight;
   datalines;    
1023 David Shaw   red 189 165
1049 Amelia Serrano  yellow 145 124    
1219 Alan Nance  red 210 192   
1246 Ravi Sinha  yellow 194 177    
1078 Ashley McKnight  red 127 118    
1221 Jim Brown  yellow 220 .    
;

proc print data=club2;
   title 'Weight Club Members';
run;

*===Another example====;
DATA giant;
   INFILE '/courses/dbd74ce5ba27fe300/datafiles/Tomatoes.dat' DSD;
   INPUT Name & $15. Color $ Days Weight;
   TITLE 'Heirloom Tomatoes';
PROC PRINT;RUN;

*===Note: with formatted input, the informat determines both the length of character variables and the
number of columns that are read. The same number of columns are read from each record.
The informat in modified list input determines only the length of the variable, not the number of
columns that are read.;

*===Creating Free-Format Data====;

data _null_;
set sasuser.students;
file '/courses/dbd74ce5ba27fe300/datafiles/students.txt' dsd;
put student_name student_company city_state;
run;













*===Reading Date and Time Values====;
proc options option=yearcutoff;
run;

*options yearcutoff=1950;

data class;
infile '/courses/dbd74ce5ba27fe300/datafiles/class.txt' dsd;
input name: $12. absences quiz dob mmddyy8.;
format dob yymmdd10.;
run;
proc print;run;
*===Note that the value of the YEARCUTOFF= system option affects only two-digit year values. A date value that contains a
four-digit year value will be interpreted correctly even if it does not fall within the 100-year span
set by the YEARCUTOFF= system option.;

/*SAS informat names indicate the form of date expression that can be read using that particular
informat. Here are some examples of common date and time informats:
 DATEw.
 DATETIMEw.
 MMDDYYw.
 TIMEw.
Date Expression         SAS Date Informat
10/15/99                   MMDDYYw.
15Oct99                    DATEw.
10-15-99                   MMDDYYw.
99/10/15                   YYMMDDw.
*/

*===When using a wrong date informat or date format====;
data class;
infile '/courses/dbd74ce5ba27fe300/datafiles/class.txt' dsd;
input name: $12. absences quiz dob mmddyy10.;
format dob yymmdd10.;
run;
proc print;run;


*===Date formats====;

DATA librarycards;
   INFILE '/courses/dbd74ce5ba27fe300/datafiles/Library.dat' TRUNCOVER;
   /*Forces the INPUT statement to stop reading when it gets to the end of a short line.
     This option will not skip information. Same results as using PAD*/
   INPUT Name $11. + 1 BirthDate MMDDYY10. +1 IssueDate ANYDTDTE10.
      DueDate DATE9.; *ANYDTDTE - reads and extracts the date value
      from various date, time, and datetime forms.;
   DaysOverDue = TODAY() - DueDate;
   Age = INT(YRDIF(BirthDate, TODAY(), 'ACTUAL'));
   /*INT is to retrive the integer part of a number.*/
   IF IssueDate > '01JAN2008'D THEN NewCard = 'yes';
RUN;
PROC PRINT DATA = librarycards;
   FORMAT BirthDate WORDDATE14. Issuedate MMDDYY8. DueDate WEEKDATE17.;
   TITLE 'SAS Dates Formats';
RUN;




























