
/*Identification ts3*/
ods noproctitle;
ods graphics / imagemap=on;

proc arima data=ASSIGN.SIM plots
     (only)=(series(acf pacf) residual(acf pacf wn) );
	identify var='ts3.sim'n minic;
	estimate method=ML;
	forecast lead=0 back=0 alpha=0.05;
	outlier;
	run;
quit;


/*Diagnostics*/
ods noproctitle;
ods graphics / imagemap=on;

proc arima data=ASSIGN.SIM plots
     (only)=(series(acf pacf) residual(acf pacf wn) );
	identify var='ts3.sim'n minic;
	estimate p=(1) method=ML;
	forecast lead=0 back=0 alpha=0.05;
	outlier;
	run;
quit;




/*Identfication ts4*/
ods noproctitle;
ods graphics / imagemap=on;

proc arima data=ASSIGN.SIM plots
     (only)=(series(acf pacf) residual(acf pacf wn) );
	identify var='ts4.sim'n;
	estimate method=ML;
	forecast lead=0 back=0 alpha=0.05;
	outlier;
	run;
quit;

/*Diagnostics*/
ods noproctitle;
ods graphics / imagemap=on;

proc arima data=ASSIGN.SIM plots
     (only)=(series(acf pacf) residual(acf pacf wn) );
	identify var='ts4.sim'n minic;
	estimate p=(1 2) method=ML;
	forecast lead=0 back=0 alpha=0.05;
	outlier;
	run;
quit

/*Identfication ts5*/
ods noproctitle;
ods graphics / imagemap=on;

proc arima data=ASSIGN.SIM plots
     (only)=(series(acf pacf) residual(acf pacf wn) );
	identify var='ts5.sim'n;
	estimate method=ML;
	forecast lead=0 back=0 alpha=0.05;
	outlier;
	run;
quit;

/*Diagnostics*/
proc arima data=ASSIGN.SIM plots
     (only)=(series(acf pacf) residual(acf pacf wn) );
	identify var='ts5.sim'n minic;
	estimate p=(1) method=ML;
	forecast lead=0 back=0 alpha=0.05;
	outlier;
	run;
quit;


/*Identfication ts6*/
ods noproctitle;
ods graphics / imagemap=on;

proc arima data=ASSIGN.SIM plots
     (only)=(series(acf pacf) residual(acf pacf wn) );
	identify var='ts6.sim'n;
	estimate method=ML;
	forecast lead=0 back=0 alpha=0.05;
	outlier;
	run;
quit;

/*Diagnostics*/
proc arima data=ASSIGN.SIM plots
     (only)=(series(acf pacf) residual(acf pacf wn) );
	identify var='ts6.sim'n minic;
	estimate p=(1 2 3) method=ML;
	forecast lead=0 back=0 alpha=0.05;
	outlier;
	run;
quit;


