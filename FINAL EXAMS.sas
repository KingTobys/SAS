
data MYCON.INF_CPI;
	set MYCON.FE;
	tr1_CPIAUCSL=lag1(CPIAUCSL);
	tr2_CPIAUCSL=(log(CPIAUCSL)-log(lag1(CPIAUCSL)))*100;
run;



proc univariate data=mycon.inf_cpi;
run;




proc arima data=MYCON.INF_CPI;
	identify var=tr2_CPIAUCSL;
	estimate  method =ML;
	forecast lead=5 back=5 alpha=0.05;
	run;


proc arima data=MYCON.INF_CPI;
	identify var=tr2_CPIAUCSL(1) minic stationarity=(adf=12);
	estimate  method =ML;
	forecast lead=5 back=5 alpha=0.05;
	run;
	
proc arima data=MYCON.INF_CPI;
	identify var=tr2_CPIAUCSL (1) minic stationarity=(adf=3);
	estimate q=(1 2 3) noint method =ML;
	forecast lead=5 back=5 alpha=0.05;
	run;


proc arima data=MYCON.INF_CPI;
	identify var=tr2_CPIAUCSL (1) minic stationarity=(adf=3);
	estimate q=(1 2 3 4) noint method =ML;
	forecast lead=12 back=0 alpha=0.05;
	run;
	
proc arima data=MYCON.INF_CPI;
	identify var=tr2_CPIAUCSL (1) minic stationarity=(adf=3);
	estimate p=(1 2) q=(1 2 3 4) noint method =ML;
	forecast lead=5 back=5 alpha=0.05;
	run;
	
	
