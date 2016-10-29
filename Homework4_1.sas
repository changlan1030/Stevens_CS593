*-------------------------------------------------------------------------;
* Problem        :  CS 593 Assignment 4 Problem 1                         ;
* Developer(s)   :  Lan Chang                                             ;
* Date           :  04/17/16                                              ;
*-------------------------------------------------------------------------;

* select the following folder as mylib;
options obs=max;
libname mylib "C:\CHANGLAN\study\2016_Spring\CS_593\SAS\SAS_data" access=read;

* copy dataset "calif" from mylib to work;
proc copy in=mylib out=work;
select calif;
run;

* exploratory analysis on all variables;
title "Normal distribute plot for all variables";
proc univariate data=calif normaltest plot;
var population pct_under_18 pct_between_18_64 pct_over male_female_ratio;
run;

* simple regression analysis of pct_over on population;
title "Simple regression for pct_over vs. population";
proc reg data=calif outest=est_reg_pop;
model pct_over=population / dwProb;
OUTPUT OUT=reg_pop_out PREDICTED=predict RESIDUAL=residual L95M=L95m U95M=U95m L95=L95 U95=U95
rstudent=rstudent h=lev cookd=cookd dffits=dffits STDP=s_predicted STDR=s_residual STUDENT=student;
quit;

* create a variable "log_population";
data calif;
set calif;
log_population = log(population);
run;

* simple regression analysis of pct_over on log_population;
title "Simple regression for pct_over vs. log_population";
proc reg data=calif outest=est_reg_log_pop;
model pct_over=log_population / dwProb;
OUTPUT OUT=reg_log_pop_out PREDICTED=predict RESIDUAL=residual L95M=L95m U95M=U95m L95=L95 U95=U95
rstudent=rstudent h=lev cookd=cookd dffits=dffits STDP=s_predicted STDR=s_residual STUDENT=student;
quit;

* univariate analysis for the reg output dataset;
title "Univariate analysis for the reg output dataset";
proc univariate data=reg_log_pop_out;
var residual lev cookd dffits;
run;
