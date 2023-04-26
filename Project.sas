data TD; 
  set project.TD; 
  Stock = "TD"; 
run; 
 
data SDD; 
  set  project.SDD; 
  Stock = "SDD"; 
run; 

data JD; 
  set  project.JD; 
  Stock = "JD"; 
run;

data combined_wide;
  Merge TD SDD JD;
  by Date;
run;


*DATA DESCRIPTION;
proc univariate data= project.gernicorp;
var TD SD JD;
run;


proc arima data=project.gernicorp;
identify var=SD stationarity=(adf=(12));
    run;

proc arima data=project.gernicorp;
identify var=SD (1) stationarity=(adf=12);
    run;
    
proc arima data=project.gernicorp;
identify var=SD  stationarity=(adf=12);
    run;





*Tiny;
proc arima data=project.gernicorp plots
    (only)=(series(corr crosscorr) residual(corr normal) 
		forecast(forecastonly));
	identify var=TD (1) minic stationarity=(adf=12);
	estimate q=(1) method=ML noint;
	forecast lead=0 back=0 alpha=0.05 out=project.forec1 id=Date interval=month;
	outlier;
	run;

proc arima data=project.gernicorp plots
    (only)=(series(corr crosscorr) residual(corr normal) 
		forecast(forecastonly));
	identify var=TD(1) minic stationarity=(adf=12);
	estimate p=(1,2,3,4) q=(1,2) method=ML noint;
	forecast lead=10 back=10 alpha=0.05 out=project.forec1 id=Date interval=month;
	outlier;
	run;
	
	proc arima data=project.gernicorp plots
    (only)=(series(corr crosscorr) residual(corr normal) 
		forecast(forecastonly));
	identify var=TD(1) minic stationarity=(adf=12);
	estimate p=(1,2) q=(1,2) method=ML noint;
	forecast lead=10 back=10 alpha=0.05 out=project.forec1 id=Date interval=month;
	outlier;
	run;
	
	data project.sqer1;
	set project.forec1;
	squaredEr1=residual**2;
	keep squaredEr1;
	run;
		
proc means data=project.sqer1 mean;
run;
	
*Standard;

proc arima data=project.gernicorp plots
    (only)=(series(corr crosscorr) residual(corr normal) 
		forecast(forecastonly));
	identify var=SD (1) minic stationarity=(adf=12);
	estimate p=(1 2) method=ML;
	forecast lead=10 back=10 alpha=0.05 out=project.forec2 id=Date interval=month;
	outlier;
	run;
	
	data project.sqer2;
	set project.forec2;
	squaredEr2=residual**2;
	keep squaredEr2;
	run;
		
proc means data=project.sqer2 mean;
run;

*Jumbo;

proc arima data=project.gernicorp plots
    (only)=(series(corr crosscorr) residual(corr normal) 
		forecast(forecastonly));
	identify var=JD (1) minic stationarity=(adf=12);
	estimate p=(1 2 3 4) q=(1) method=ML;
	forecast lead=10 back=10 alpha=0.05 out=project.forec id=Date interval=month;
	outlier;
	run;
	
	data project.sqer;
	set project.forec;
	squaredEr=residual**2;
	keep squaredEr;
	run;
		
proc means data=project.sqer mean;
run;	
	


*hpfengine;
proc hpfesmspec repository=work.repository
               name=Winter
               label = "Winter Multiplicative Model";
  esm method=winters;
run;

proc hpfesmspec repository=work.repository
               name=Holt
               label = "Holt Linear Smoothing";
   esm method=linear;            
run;

proc hpfarimaspec repository=work.repository
        name=Arma
        label ="ARIMA(0,1,1) No Intercept";
dependent symbol=TD q=(1) diflist=1 noint;
run;

proc hpfselect repository=work.repository
     name=myselect
     label="My Selection List";
   select select=mape;
   spec Winter Holt Arma;
run;

proc hpfengine data=project.td
 repository=work.repository
 globalselection=myselect
 print=(select summary estimates)
 plot=forecasts;
 id date interval=months; 
 forecast tD;
 run;
 
   

*STANDADRD HPFENGINE*
*hpfengine;
proc hpfesmspec repository=work.repository
               name=Winter
               label = "Winter Multiplicative Model";
  esm method=winters;
run;

proc hpfesmspec repository=work.repository
               name=Holt
               label = "Holt Linear Smoothing";
   esm method=linear;            
run;

proc hpfarimaspec repository=work.repository
        name=Arma
        label ="ARIMA(2,1,0) No Intercept";
dependent symbol=TD p=(2) diflist=1 noint;
run;

proc hpfselect repository=work.repository
     name=myselect
     label="My Selection List";
   select select=mape;
   spec Winter Holt Arma;
run;

proc hpfengine data=project.sdd
 repository=work.repository
 globalselection=myselect
 print=(select summary estimates)
 plot=forecasts;
 id date interval=months; 
 forecast sd;
 run;


*JUMBO HPFENGINE*
*hpfengine;
proc hpfesmspec repository=work.repository
               name=Winter
               label = "Winter Multiplicative Model";
  esm method=winters;
run;

proc hpfesmspec repository=work.repository
               name=Holt
               label = "Holt Linear Smoothing";
   esm method=linear;            
run;

proc hpfarimaspec repository=work.repository
        name=Arma
        label ="ARIMA(4,1,1) No Intercept";
dependent symbol=TD p=(4) q=(1) diflist=1 noint;
run;

proc hpfselect repository=work.repository
     name=myselect
     label="My Selection List";
   select select=mape;
   spec Winter Holt Arma;
run;

proc hpfengine data=project.jd
 repository=work.repository
 globalselection=myselect
 print=(select summary estimates)
 plot=forecasts;
 id date interval=months; 
 forecast jd;
 run;

