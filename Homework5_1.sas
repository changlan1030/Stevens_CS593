*-------------------------------------------------------------------------;
* Problem        :  CS 593 Assignment 5 Problem 1                         ;
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
data churn1;
set churn;
if churn="False." then churn_ind=0;
else churn_ind=1;
if service_calls<2 then V_CSC=0;
else if service_calls<4 then V_CSC=1;
else V_CSC=2;
run;

title "Frequency on churn and V_CSC";
proc freq data=churn1;
tables churn_ind V_CSC churn_ind*V_CSC;
run;

title "Logistic regression analysis for churn on V_CSC";
proc logistic data=churn1 descending;
class V_CSC (ref='0')/ param=ref;
model churn_ind=V_CSC;
quit;
