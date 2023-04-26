*Question 1;

data app_profile;
infile '/courses/dbd74ce5ba27fe300/datafiles/appinfo.dat';
input Name $ 1-11  SSN: $11. 
   #2 Gender $ DOB mmddyy10.
   #4 Height $ Weight
   #5 EyeColor $  HairColor $
   #3 SystolicBP DiastoliBP BT $;
   format DOB mmddyy10.;
run;
proc print data=app_profile;
 TITLE "PROFILE OF INDIVIDUALS";
run;

data app_profile2 (drop =height_f height_m height_feet);
set app_profile;
height_f=substr(height,1,1);
height_m=substr(height,3,1);
height_feet=(height_f*12)+height_m;
height=height_feet;
run;

proc print;
run;


 




**Question 2;

proc sgplot data=sashelp.heart;
reg y=Diastolic x= Cholesterol/group=weight_status;
Title "Scatter Diagram and Regression Line between Diastolic Level and Cholesterol Level for each Weight Status";
run;

/*From the plots it can be inferred that there is a positive relationship
between the diastolic levels and cholesterol levels for each weight status.*/


proc sgplot data=sashelp.heart;
reg y=Cholesterol x=Systolic/group=Smoking_Status;
Title "Scatter Diagram and Regression Line of Diastolic Level and Cholesterol Level for each smoking Status";
run;

/*From the plots above it can be infered that is a positive linear relationship between
systolic and cholesterol at each smoking status.*/



*Question 3;
libname myclass "~/my_shared_file_links/ohu0";
data x;
set myclass.client;
clientnoo=input(clientno,5.0);
run;

data y;
set work.x;
drop clientno;
run;

data z;
set work.y;
clientno=clientnoo;
run;

data comp_sales;
merge work.z(in=clientno) myclass.orders(in=clientNo);
by clientno;
ord_date_floor=intnx('month',ord_date,0,'b');
run;

data currency_floor;
set myclass.currency;
ord_date_floor = intnx('month',cur_date,0,'b');
run;

proc sort data=comp_sales; by currency ord_date_floor; run;
proc sort data=currency_floor; by currency ord_date_floor; run;

/*calculating sales in usd for each of the companies*/

data comp_sales_curr;
merge comp_sales(in=a) currency_floor(in=b);
by currency ord_date_floor;
usd_sales = totsale*exchrate;
if a and b then output;
run;



proc sort data=comp_sales_curr; by company; run;

proc means
data=comp_sales_curr noprint nway;
class company;
var usd_sales;
output out=comp_sales_sum (drop=_TYPE_ _FREQ_) sum=  /autoname;
run;

proc print;
run;

proc univariate data=comp_sales_sum;
    var usd_sales_sum;
 
    output out=min_comp_sale
	min=min_sale;
run;
 
 
proc print data=min_comp_sale noobs;
run;

*The lowest amount of sales was recorded by Heymann's;














*Question 4;
libname myclass "~/my_shared_file_links/ohu0";


*3yr cumulative returns;

data cumu_rets;
set myclass.annexmkt;
set myclass.annexmkt ( firstobs = 2 keep = exmkt rename = (exmkt = N2) );
set   myclass.annexmkt ( firstobs = 3 keep = exmkt rename = (exmkt = N3) );
cumu_ret = sum(exmkt,N2,N3);
run;

data probs;
set cumu_rets;
if exmkt >= 20 then
 do;
  gt_20 = 1;
 end;
if cumu_ret > 0 then
 do;
  p = 1;
 end;
run;

proc means data=probs sum; 
    var gt_20;
run;

proc means data=probs sum; 
    var p;
run;


data p2;
set probs;
if (gt_20 and p = 1) then 
 do ;
  p2 = 1;
 end;
run;

proc means data=p2 sum; 
    var p2;
run;

*probability;

data cumu_prob_20;
set probs;
if gt_20 =  1 then
 do;
  probability_cumu_ret = (26/92)/(28/92);
 end;
run;

proc print;
run;

* The probability of a positive return after an at least 20% surge in the current year is 92.857% */

**Question 5;

libname myclass "~/my_shared_file_links/ohu0";

data ind_mktrt;
merge myclass.indrt(in=a) myclass.mktrt(in=b);
by year;
durbl_diff = durbl-mkt;
enrgy_diff = enrgy-mkt;
hitec_diff = hitec-mkt;
hlth_diff  = hlth-mkt;
manuf_diff = manuf-mkt;
nodur_diff = nodur-mkt;
other_diff = other-mkt;
telcm_diff = telcm-mkt;
utils_diff = utils-mkt;
shops_diff = shops-mkt;
run;


%macro sum_stat(t);
proc summary data=ind_mktrt;
where &t > 0;
output out=&t._sum;
run;
%mend;

%sum_stat(durbl_diff);
%sum_stat(enrgy_diff);
%sum_stat(hitec_diff);
%sum_stat(hlth_diff);
%sum_stat(manuf_diff);
%sum_stat(nodur_diff); /*>50%*/
%sum_stat(other_diff);
%sum_stat(telcm_diff);
%sum_stat(utils_diff);
%sum_stat(shops_diff); /*>50%*/

*Nodur and shops have a return that is most frequently higher than the market return;

/*plot the shops and nondurable goods segment, which exceeds market return in more than 50% of years*/

ods graphics / reset width=6.4in height=4.8in imagemap;

proc sgplot data=WORK.IND_MKTRT;
	title height=14pt "Non-Durable Goods vs. Market Returns";
	reg x=Mkt y=NoDur / nomarkers;
	scatter x=Mkt y=NoDur / markerattrs=(color=CX99001a);
	xaxis grid;
	yaxis grid;
run;

ods graphics / reset;
title;

ods graphics / reset width=6.4in height=4.8in imagemap;

proc sgplot data=WORK.IND_MKTRT;
	title height=14pt "Shops vs. Market Returns";
	reg x=Mkt y=shops / nomarkers;
	scatter x=Mkt y=shops / markerattrs=(color=CX99001a);
	xaxis grid;
	yaxis grid;
run;

ods graphics / reset;
title;

proc means data=ind_mktrt stackodsoutput mean median std;
output out = ind_mktrt_std  /autoname;
run;

proc transpose data=ind_mktrt_std out=ind_mktrt_tran;
run;

/*calculating the risk adjusted return*/

data ind_mktkrt_rar;
set ind_mktrt_tran;
rar = col4/col5;
run;		

proc print;
run;		

*Nodur and Hlth have risk adjusted returns higher than that of market;																																																			











   
