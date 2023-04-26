*===User-defined formats=====;
*==========================================================;
/*Keep and Drop (variables) used either as options or as statements*/

data a (keep=name id gender wavg);
input name $ id $ gender $ mid1 mid2 final dob mmddyy8. major $25.;
format dob mmddyy10.;
wavg=mid1*0.3+mid2*0.3+final*0.4;
*keep name id gender wavg;
cards;
Steve  2342 M 75 82 85 01/28/82 Economics
Jen 2783 F 67 65 70 04/08/84 Mathematics
Chris 3218 M 89 93 90 08/23/83 Electronic Engineering
Matt 3569 M 82 . 95 06/01/83 Music
Vivien 1498 F 77 85 83 11/05/82 History
Amy 4136 F . 82 87 10/27/84 Political Science
;
run;
proc print;run;


/*PROC FORMAT*/
proc format;
value grfmt 90-high='A'
           80-<90='B'
           70-<80='C'
           60-<70='D'
           low-<60='F';

value $gdfmt 'F'='Female'
             'M'='Male';
run;

proc print data=a;
format wavg grfmt. gender $gdfmt.;
run;

*============================================;
DATA carsurvey;    
   INFILE '/courses/dbd74ce5ba27fe300/datafiles/Cars.dat';
   INPUT Age Sex Income Color $;
PROC FORMAT;
   VALUE gender 1 = 'Male'
                2 = 'Female';
   VALUE agegroup 13 -< 20 = 'Teen'
                  20 -< 65 = 'Adult'
                  65 - HIGH = 'Senior';
   VALUE $col  'W' = 'Moon White'
               'B' = 'Sky Blue'
               'Y' = 'Sunburst Yellow'
               'G' = 'Rain Cloud Gray';
* Print data using user-defined and standard (DOLLAR8.) formats;
PROC PRINT DATA = carsurvey;
   FORMAT Sex gender. Age agegroup. Color $col. Income DOLLAR8.;
   TITLE 'Survey Results Printed with User-Defined Formats';
RUN;

*Save formats permanently;
data carsurvey1;
set carsurvey;
FORMAT Sex gender. Age agegroup. Color $col. Income DOLLAR8.;
run;

proc contents data=carsurvey1;
run;








/*proc means - descriptive statistics*/
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
;
run;

proc sort data=a;by gender;run;

proc means data=a;
by gender;
run;


proc means data=a noprint;
class gender;*by gender;
var final;/*can include more than one variable*/
title 'summary of final grade';
output out=a_stats n=num mean=avrg min=mn max=mx std=sigma;
run;

proc print data=a_stats;run;


*================================================;

DATA sales;    
   INFILE '/courses/dbd74ce5ba27fe300/datafiles/Flowers.dat';    
   INPUT CustomerID $ @9 SaleDate MMDDYY10. Petunia SnapDragon Marigold;    
   Month = MONTH(SaleDate);
   run; 
PROC SORT DATA = sales;    
   BY Month; 
run;
* Calculate means by Month for flower sales;
PROC MEANS DATA = sales;    
   BY Month;  *CLASS Month;  
   VAR Petunia SnapDragon Marigold;
   TITLE 'Summary of Flower Sales by Month';
RUN;


PROC SORT DATA = sales;
   BY CustomerID;
run;
* Calculate means by CustomerID, output sum and mean to new data set;
PROC MEANS DATA = sales noprint;
   BY CustomerID;
   VAR Petunia SnapDragon Marigold;
   OUTPUT OUT = totals  MEAN =MeanPetunia MeanSnapDragon MeanMarigold
      SUM = Petunia SnapDragon Marigold;
PROC PRINT DATA = totals;
   TITLE 'Sum of Flower Data over Customer ID';
   *FORMAT MeanPetunia MeanSnapDragon MeanMarigold 3.;
RUN;



/*PROC SUMMARY*/
proc summary data=sales PRINT;
by CustomerID;
run;

title 'CLASS and a Summary Data Set';
proc summary data=sashelp.class(where=(age in(12,13,14)));
class age sex;
var height;
output out=clsummry mean=ht_mean std=ht_sd;
run;
PROC PRINT;RUN;


















/* PROC FREQ */

DATA orders;
   INFILE '/courses/dbd74ce5ba27fe300/datafiles/Coffee.dat';
   INPUT Coffee $ Window $ @@;
run;
* Print tables for Window and Coffee; 
proc freq data=orders;
tables window coffee;
run;
* Print tables for Window by Coffee;
PROC FREQ DATA = orders;
   TABLES Window*Coffee;
   RUN;

*Crosstabulation with a quantitative variable;
PROC FORMAT;
VALUE AGE_FMT
      Low-12 = 'Less than or equal to 12 years of age'
	  13-14 = '13 - 14 years of age'
	  15-High = 'Over 15 years of age';
	  
value hifmt
      low-<60 = 'Less than 60 inches'
      60-65 = '60 - 65 inches'
      65<-high = 'Larger than 65 inches'; 
RUN;

 PROC FREQ DATA=SASHELP.CLASS;
 TABLES SEX*AGE /OUT=TABLE nocol norow nopercent;
 FORMAT AGE AGE_FMT.;
 RUN;

 PROC FREQ DATA=SASHELP.CLASS;
 TABLES SEX*AGE*height /OUT=TABLE nocol norow nopercent;
 FORMAT AGE AGE_FMT. height hifmt.;
 RUN;








/*ODS - Output Delivery System which determines where the output should go and what it should 
look like when it gets there.
Different types of ODS output are called destinations. ODS processes each set of data and sends 
it off to its proper destination. The appereance of your data is determined by templates,which 
are instructions telling ODS how to format your data.

Destinations:
Listing - standard SAS output (shown up in the output window)
HTML -    Hypertext Markup Language
RTF -     Rich Text Format
PRINTER   High-resolution printer output
PS        PostScript
PCL       Printer Control Language
PDF       Portable Document Format
OUTPUT    SAS output data set
MARKUP    Markup languages including XML
DOCUMENT  Output document

Table and Style templates
            
                ODS object
Data from procedure + table template + style template - ODS -> output
      
*/

DATA giant;
   INFILE '/courses/dbd74ce5ba27fe300/datafiles/Tomatoes.dat' DSD;/*DSD stands for delimiter sensitive data*/
   INPUT Name :$15. Color $ Days Weight;
run;

ODS TRACE ON;
PROC MEANS DATA = giant;
   BY Color;
RUN;
ODS TRACE OFF;



ODS TRACE ON;
PROC MEANS DATA = giant;
   BY Color;
   var days weight;
   TITLE 'Red Tomatoes';
   ODS SELECT Means.ByGroup1.Summary;
   output out=mean1 mean=mnd mnw;
RUN;
ODS TRACE OFF;



* Create the HTML files and remove procedure name;

ODS HTML file='/courses/dbd74ce5ba27fe300/marine.html'
         CONTENTS='/courses/dbd74ce5ba27fe300/marine_CONTENTS.html'
         FRAME='/courses/dbd74ce5ba27fe300/marine_FRAME.html'
         STYLE=barrettsblue;
ODS NOPROCTITLE;

DATA marine;
   INFILE '/courses/dbd74ce5ba27fe300/datafiles/SeaLife.dat';
   INPUT Name $ Family $ Length @@;
RUN;
PROC MEANS DATA = marine MEAN MIN MAX;
   CLASS Family;
   TITLE 'Whales and Sharks';
RUN;
PROC PRINT DATA = marine;
RUN;
* Close the HTML files;
ODS HTML CLOSE;




* Create the PDF file;
ODS PDF FILE = '/courses/dbd74ce5ba27fe300/Marine.pdf';
ODS NOPROCTITLE;
DATA marine;
   INFILE '/courses/dbd74ce5ba27fe300/datafiles/SeaLife.dat';
   INPUT Name $ Family $ Length @@;
RUN;
PROC MEANS DATA = marine MEAN MIN MAX;
   CLASS Family;
   TITLE 'Whales and Sharks';
RUN;
PROC PRINT DATA = marine;
RUN;
* Close the PDF file;
ODS PDF CLOSE;


* Create an RTF file;
ODS RTF FILE = '/courses/dbd74ce5ba27fe300/Marine.rtf' BODYTITLE COLUMNS=2;
ODS NOPROCTITLE;
DATA marine;
   INFILE '/courses/dbd74ce5ba27fe300/datafiles/SeaLife.dat';
   INPUT Name $ Family $ Length @@;
RUN;
PROC MEANS DATA = marine MEAN MIN MAX;
   CLASS Family;
   TITLE 'Whales and Sharks';
RUN;
PROC PRINT DATA = marine;
RUN;
* Close the RTF file;
ODS RTF CLOSE;

