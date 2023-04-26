
*Creating initial ACF,PACF, and IACF;
proc arima data=MYCON.MIDS;
 identify var= log_y (1);
run;


*Checking stationarity;
proc arima data=MYCON.MIDS;
 identify var= log_y stationarity= (adf=12);
run;




*Estimating Candidate Models;
proc arima data=MYCON.MIDS;
 identify var= log_y (1) minic;
 estimate q=(1 2) noconstant  ;
run;

proc arima data=MYCON.MIDS;
 identify var= y (1) minic;
 estimate  q= (1) noconstant;
run;

proc arima data=MYCON.MIDS;
 identify var= y (1) minic;
 estimate p=(1 2) q= (1) noconstant;
run;

proc arima data=MYCON.MIDS;
 identify var= y (1) minic;
 estimate p=(1 ) q= (1 2) noconstant;
run;

proc arima data=MYCON.MIDS;
 identify var= y (1) minic;
 estimate p=(1 2) q= (1 2 3 4) noconstant;
run;

* Creating forecast;
proc arima data=MYCON.MIDS;
 identify var= log_y (1) noprint;
 estimate   q= (1) noconstant;
 forecast lead=12 id=date interval=month;
run;


*holding back to Create MSE;
proc arima data=MYCON.MIDS;
  identify var= log_y (1) noprint;
 estimate  q= (1) noconstant;
 forecast lead=12 back =12 out=MyCon.forecs id=date interval=month NOOUTALL;
run;

*Creating squared Error;
data mycon.SQER;
 set Mycon.forecs;
 squaredEr= residual**2;
 keep squaredEr;
run;

*Find mean of squared residuals;
proc means data=mycon.SQER mean;
run; 




*Varince estimate;
*0.000061;

data MYcon.levelforecast;
 set mycon.forecs;
 air_forecast = exp(Forecast + .5*.000061);
 run;
