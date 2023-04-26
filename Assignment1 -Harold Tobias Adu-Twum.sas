*/Name: Harold Tobias Adu-Twum
  Homework: 1
  Course: SAS Programming Data Analysis*/





*Question 1;
proc print data=sashelp.cars;
where origin ="Europe";
by make;
var make model type mpg_city mpg_highway;
title "Car Brands and Models in Europe";
run;





*Question 2;
proc print data=sashelp.cars;
run;

data suv;
set sashelp.cars;
where type= 'SUV' & origin='USA' & drivetrain='All';
drop type;
label MSRP = 'MSRP of SUV';
run;

PROC PRINT DATA=SUV LABEL;
RUN;

*Question 3;
proc sort data=sashelp.cars out=sorted_cars (keep=origin type cylinders mpg_city);
by origin type cylinders;
run;

*Question 4;
data usacars;
set sashelp.cars;
where origin='USA' & invoice/msrp >=0.8 & cylinders>=6 and mpg_highway>=30;
run;


*Question 5;
data class_col;
infile '/home/u59352098/my_shared_file_links/ohu0/datafiles/class_col.txt';
input Name $ 1-18 ID $ 19-22 +1 Gender $1. +1 GPA 3.1 +1 Major $22. +1 DOB mmddyy10.;
format DOB date9.;
run;

proc print data=class_col;
run;
   





