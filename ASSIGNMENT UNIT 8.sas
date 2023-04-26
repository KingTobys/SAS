
proc sgplot data=MYCON.AMZNGARCH;
	series x=date y=Close/;
	xaxis grid;
	yaxis grid;
run;

data returns;
     set mycon.AMZNGARCH;
     ret = log(Close) - lag1(log(Close));
run;

proc sgplot data=Work.returns;
	series x=date y=ret/;
	xaxis grid;
	yaxis grid;
run;  

proc arima data=Work.returns;
   identify var=ret;
run;

proc arima data=Work.returns out= work.resids;
   identify var=ret;
   estimate P=(1) method= ml;
   forecast;
run;

data work.resids;
  set work.resids;
  sq_resids = RESIDUAL**2;
run;

proc arima data=Work.resids;
   identify var=sq_resids minic;
   estimate method= ml;
run;

proc autoreg data = work.returns outest = work.arch_est;
  model ret = / nlag = 1 garch = (p=1, q=1);
  output out = work.arch_res CPEV = htpred HT = ht p = yhat pm=ytrend residual= RESIDUAL;
run;

proc sgplot data=work.arch_res;
	series x=date y=ht/;
	xaxis grid;
	yaxis grid;
run;
   
data work.resids;
  set work.arch_res;
  sq_resids = RESIDUAL**2/ht;
run;

proc arima data=Work.resids;
   identify var=sq_resids minic;
   estimate method= ml;
run;     


