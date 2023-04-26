* Checking trends of graphs and initial stationarity and indication of which case to use;
ods noproctitle;
ods graphics / imagemap=on;

proc timeseries data=MYCON.WALMART plots=(series corr);
	var 'Adj Close'n / transform=none dif=0;
run;

/* Unit root test analysis */
proc arima data=MYCON.WALMART plots=none;
	ods select StationarityTests;
	identify var='Adj Close'n stationarity=(adf=12);
	run;
quit;







* Adding minic and checking stationarity with adf and pp;
ods noproctitle;
ods graphics / imagemap=on;

proc arima data=MYCON.WALMART plots
    (only)=(series(corr crosscorr) residual(corr normal) 
		forecast(forecastonly));
	*identify var='Adj Close'n(1) minic stationarity=(adf=12);
	identify var='Adj Close'n(1) minic stationarity=(pp);
	estimate method=ML;
	run;
quit;