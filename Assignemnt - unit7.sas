proc arima data=MYCON.EXCHUS;
 

proc sgplot data=MYCON.EXCHUS;
	series x=date y=EXCHUS /;
	xaxis grid;
	yaxis grid;
run;


proc arima data=MYCON.EXCHUS;
   identify var=EXCHUS( 1 );
   estimate noint method= ml;
   outlier  alpha=0.01;
run;


data MYCON.EXCHUS;
   set MYCON.EXCHUS;
   if  14<=_n_ <= 26 then LS = 1;
   else LS = 0.0;
    if 27<=_n_ <= 320 then LS1 = 1;
   else LS1 = 0.0;
    if _n_ >= 321 then LS2 = 1;
   else LS2 = 0.0;
run;


/*-- Airline Model with Outliers --*/
proc arima data=MYCON.EXCHUS;
   identify var=logEXCHUS(1)
            crosscorr=( LS(1) LS1(1) LS2(1))
            noprint;
   estimate noint
            input=(LS LS1 LS2)
            method=ml plot;
run;



proc sql;
  INSERT INTO MYCON.EXCHUS (year, month, date,  LS)
  VALUES (1961, 1, "01JAN1961"d, 0,1)
  VALUES (1961, 2, "01FEB1961"d, 0,1)
  VALUES (1961, 3, "01MAR1961"d, 0,1)
  VALUES (1961, 4, "01APR1961"d, 0,1)
  VALUES (1961, 5, "01MAY1961"d, 0,1)
  VALUES (1961, 6, "01JUN1961"d, 0,1);
QUIT;

proc arima data=work.airline_outlier;
   identify var=logair(1, 12)
            crosscorr=( AO(1, 12) LS(1, 12) )
            noprint;
   estimate q= (1)(12) noint
            input=( AO LS )
            method=ml plot;
   outlier maxnum=3 alpha=0.01;
   forecast lead=6 id=date interval=month printall;
run;
