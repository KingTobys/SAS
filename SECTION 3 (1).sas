*We start with a $1,000,000 portfolio;
*We want to evaluate the 5% Value at Risk;
*or 99% of the time we will not lose any more than this amount;










*load the data and calculate returns;
*AMAZON;
data mycon.AMZNVAR;
  set mycon.AMZNVAR;
  AMZNVAR_return = log('Adj Close'n) - log(lag1('Adj Close'n));
  run;
*APPLE;
data mycon.APPVAR;
  set mycon.APPVAR;
  APPVAR_return = log(Close) - log(lag1(Close));
run;
  
*10 year constant maturity treasury bonds;  
data mycon.bond_yield;
  set mycon.bond_yield;
  bond_return = log(1/DGS10) - log(lag1(1/DGS10));
run;

*merge the data sets together by Date and find the portfolio returns;
*note that we are not calculating the portfolio itself here;
*because prices change over time, we would need to adjust holdings over time;
*In the last line we are removing missing observations;

data mycon.garch_data;
  merge mycon.AMZNVAR (keep = AMZNVAR_return Date) 
  mycon.APPVAR (keep = APPVAR_return Date) 
  mycon.bond_yield (keep = bond_return Date) ;
  by Date;
  portfolio_return = .2*bond_return + .3*AMZNVAR_return + .5*APPVAR_return;
  if cmiss(of _all_) then delete;
  run;

proc univariate data=mycon.garch_data;
run;

proc univariate data=mycon.appvar;
run;

proc univariate data=mycon.AMZNVAR;
run;

proc univariate data=mycon.Bond_yield;
run;

*proc means calculates kurtosis -3;
*This is close to Table 1 in Engles paper;
*There are some differences likely due to treatment of missing values;
*or how daily returns were calculated;
proc means data = mycon.garch_data mean std skewness kurtosis p5;
run;

* This will generate Figure 1;
* set size of graphics ;
ods graphics / width=9cm height=8cm;
ods layout gridded columns=2 ;
ods region;
proc sgplot data=MYCON.garch_data;
	series x=date y=AMZNVAR_return/;
	xaxis grid;
	yaxis grid;
run;

ods region;
proc sgplot data=MYCON.garch_data;
	series x=date y=bond_return/;
	xaxis grid;
	yaxis grid;
run;

ods region;
proc sgplot data=MYCON.garch_data;
	series x=date y=APPVAR_return/;
	xaxis grid;
	yaxis grid;
run;

ods region;
proc sgplot data=MYCON.garch_data;
	series x=date y=portfolio_return/;
	xaxis grid;
	yaxis grid;
run;

ods layout end;
ods graphics on / reset=all;

*Based just on the distribution of the returns;
*we find the 5th percentile. 95% of the data is above this return;
*Take the 5th percentile and multiply it by $1,000,000 to get the value at Risk;
proc means data = mycon.garch_data p5 noprint;
  Var portfolio_return;
output out = VaR_quantile p1 = p5;
run;

data NULL;
  set work.var_quantile;
  VaR = p5*1000000;
run;
proc print;
run;

*Same calculation but for past year;
proc means data = mycon.garch_data p5 noprint;
  where Date GT '12NOV2020'd;
  Var portfolio_return;
output out = VaR_quantile p1 = p5;
run;

data NULL;
  set work.var_quantile;
  VaR = p5*1000000;
run;
proc print;
run;

*Same calculation since Jan 1 2000;
proc means data = mycon.garch_data p5 noprint;
  where Date GT '01JAN2000'd;
  Var portfolio_return;
output out = VaR_quantile p1 = p5;
run;

data NULL;
  set work.var_quantile;
  VaR = p5*1000000;
  put VaR;
run;
proc print;
run;

*Check for ARCH effects;
*ARMA(0,0) mean model;
proc arima data=mycon.garch_data;
   identify var=portfolio_return minic;
   estimate  method= ml;
run;



proc arima data=mycon.garch_data out= work.resids plots = NONE;
   identify var=portfolio_return;
   estimate  method= ml;
   forecast;
run;

*Square the residuals;
data work.resids;
  set work.resids;
  sq_resids = RESIDUAL**2;
run;


*Evidence of ARCH effects;
*Look at ACF and Q-tests;
*The Q tests from SAS are Table 2;
proc arima data=Work.resids plots
     (only)=(series(acf));
   identify var=sq_resids minic;
   estimate method= ml;
run;


proc sql;
  INSERT INTO mycon.garch_data (Date)
  VALUES ("13nov2021"d);
QUIT;
  

*Estimate a AR(1)-GARCH(1,1);
*Engle does not estimate the AR(1) part;
proc autoreg data = mycon.garch_data outest = work.arch_est;
  model portfolio_return = / nlag = 1 garch = (p=1, q=1);
  output out = work.arch_res CPEV = htpred HT = ht p = yhat pm=ytrend residual= RESIDUAL;
run;
* check the standardized residuals to make sure there are no;
*more arch effects;
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

*save the mean portfolio return;
proc means data = mycon.garch_data mean noprint;
var portfolio_return;
output out = portfolio_mean mean = port_mean;
run;


*Assuming a normal distribution with a variance equal to our predicted variance;
*we find the vale that corresponds to 1% probability the the return would be less;
*than this value Z = (x-mu)\sigma  x = z*sigma+mu;

data predicted_val;
  set work.arch_res (where=(Date = "13NOV2021"d));
  if _n_ = 1 then set portfolio_mean;
  forc = htpred;
  xLeft= yhat + quantile("Normal", .05)*forc**.5;
  VaR = xLeft*1000000;
run;

proc print;
  var VaR;
run;

*What would the tail value be using the standardized distribution?;
proc stdize data = mycon.garch_data out = work.std_return;
  var portfolio_return;
run;

proc means data = work.std_return mean p1;
 var portfolio_return;
output out = portfolio_mean mean = port_mean p1 = z1;
run;

data predicted_val;
  set work.arch_res (where=(Date = "24MAR2000"d));
  if _n_ = 1 then set portfolio_mean;
  forc = htpred;
  xLeft= yhat + z1*forc**.5;
  VaR = xLeft*1000000;
run;

proc print;
  var VaR;
run;






