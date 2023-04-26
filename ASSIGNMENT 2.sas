/* Generated Code (IMPORT) */
/* Source File: AMZN.csv */
/* Source Path: /home/u59352098/MYCONTENT */
/* Code generated on: 9/9/21, 10:34 PM */

%web_drop_table(MYCON.AMAZON);




/*IMPORTING DATA*/

FILENAME REFFILE '/home/u59352098/MYCONTENT/AMZN.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=MYCON.AMAZON;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=MYCON.AMAZON; RUN;


%web_open_table(MYCON.AMAZON);



/*CHECKING AND TREATMENT OF MISSING VALUES*/
ods noproctitle;

proc sort data=MYCON.'AMAZON STOCK PRICES'n out=Work.preProcessedData;
	by Date;
run;

proc timedata data=Work.preProcessedData seasonality=12 out=WORK._tsoutput;
	id Date interval=month setmissing=missing;
	var 'Adj Close'n / accumulate=none transform=none;
run;

data work.tsPrep0002(rename=());
	set WORK._tsoutput;
run;

proc delete data=Work.preProcessedData;
run;

proc delete data=WORK._tsoutput;
run;


/*SERIES OF ADJ CLOSE*/
ods graphics / reset width=6.4in height=4.8in imagemap;

proc sort data=MYCON.AMAZON out=_SeriesPlotTaskData;
	by Date;
run;

proc sgplot data=_SeriesPlotTaskData;
	title height=14pt "SERIES OF ADJ CLOSE";
	series x=Date y='Adj Close'n /;
	xaxis grid label="Date";
	yaxis grid;
run;

ods graphics / reset;
title;

proc datasets library=WORK noprint;
	delete _SeriesPlotTaskData;
	run;


/*CREATING NEW VARIABLE RETURNS*/
/*FORECASTING DATA PREPARATION*/
ods noproctitle;

proc sort data=MYCON.'AMAZON STOCK PRICES'n out=Work.preProcessedData;
	by Date;
run;

proc timedata data=Work.preProcessedData seasonality=12 out=WORK._tsoutput;
	id Date interval=month setmissing=missing;
	var 'Adj Close'n / accumulate=none transform=log dif=1;
run;

data work.tsPrep0004(rename=('Adj Close'n='log_Adj Close'n));
	set WORK._tsoutput;
run;

proc delete data=Work.preProcessedData;
run;

proc delete data=WORK._tsoutput;
run;

/*DATA TRANSFORMATION*/

ods noproctitle;

proc sort data=MYCON.'AMAZON STOCK PRICES'n out=Work.preProcessedData;
	by Date;
run;

proc timedata data=Work.preProcessedData seasonality=12 out=WORK._tsoutput;
	id Date interval=month setmissing=missing;
	var 'Adj Close'n / accumulate=none transform=log dif=1;
run;

data work.tsPrep0004(rename=('Adj Close'n='log_Adj Close'n));
	set WORK._tsoutput;
run;

proc delete data=Work.preProcessedData;
run;

proc delete data=WORK._tsoutput;
run;


/*SERIES OF RETURNS*/
ods graphics / reset width=6.4in height=4.8in imagemap;

proc sort data=MYCON.'NEW AMAZON RETURN'n out=_SeriesPlotTaskData;
	by Date;
run;

proc sgplot data=_SeriesPlotTaskData;
	title height=14pt "SERIES OF RETURNS";
	series x=Date y='tr2_Adj Close'n /;
	xaxis grid label="Date";
	yaxis grid label="Returns";
run;

ods graphics / reset;
title;

proc datasets library=WORK noprint;
	delete _SeriesPlotTaskData;
	run;
	
	
	






/*QUESTION 2*/

/*First Approach*/
data Appl; 
  set   MYCON.APPLE  (keep=Date 'Adj Close'n); 
  Stock = "Appl"; 
run; 
 
data Amzn; 
  set  MYCON.AMAZON (keep=Date 'Adj Close'n); 
  Stock = "Amzn"; 
run; 
 
data combined_long; 
	set Appl Amzn; 
run;


/*Second Approach*/
data combined_wide;
  Merge Appl(Rename = ('Adj Close'n= ApplAdjClose))
  Amzn(Rename = ('Adj Close'n= AmznAdjClose));
  by Date;
  Drop Stock;
run;



/*Two Series on one Graph*/
/*Combined long with stock as group*/
ods graphics / reset width=6.4in height=4.8in imagemap;

proc sort data=MYCON.COMBINED_LONG out=_SeriesPlotTaskData;
	by Date;
run;

proc sgplot data=_SeriesPlotTaskData;
	title height=14pt "COMBINED LONG WITH STOCK AS GROUP VARIABLE";
	series x=Date y='Adj Close'n / group=Stock;
	xaxis grid;
	yaxis grid;
run;

ods graphics / reset;
title;

proc datasets library=WORK noprint;
	delete _SeriesPlotTaskData;
	run;











/*Combined wide with two variables*/
ods graphics / reset width=6.4in height=4.8in imagemap;

proc sort data=MYCON.COMBINED_WIDE out=_SeriesPlotTaskData;
	by Date;
run;

proc sgplot data=_SeriesPlotTaskData;
    title height=14pt "COMBINED WIDE WITH TWO Y VARIABLES";
	series x=Date y=ApplAdjClose /;
	series x=Date y=AmznAdjClose /;
	xaxis grid;
	yaxis grid;
run;

ods graphics / reset;

proc datasets library=WORK noprint;
	delete _SeriesPlotTaskData;
	run;







