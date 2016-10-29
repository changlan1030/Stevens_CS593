*-------------------------------------------------------------------------;
* Problem        :  CS 593 Assignment 5 Problem 3                         ;
* Developer(s)   :  Lan Chang                                             ;
* Date           :  04/22/16                                              ;
*-------------------------------------------------------------------------;

* select the following folder as mylib;
options obs=max;
libname mylib "C:\CHANGLAN\study\2016_Spring\CS_593\SAS\SAS_data" access=read;

* copy dataset "churn" from mylib to work;
proc copy in=mylib out=work;
select churn;
run;

* create the categorical variable;
data churn0;
set churn;
if churn="False." then churn_ind=0;
else churn_ind=1;
if international_plan="no" then intl_ind=0;
else intl_ind=1;
if voice_mail_plan="no" then voice_ind=0;
else voice_ind=1;
if service_calls<2 then V_CSC2=0;
else if service_calls<4 then V_CSC2=1;
else V_CSC2=2;
if account<10 then length=1;
else if account<100 then length=2;
else length=3;
run;

title "Logistic regression analysis for churn on all variables";
proc logistic data=churn0 descending;
model churn_ind=intl_ind voice_ind V_CSC2 length day_minutes eve_minutes night_minutes intl_minutes;
run;
