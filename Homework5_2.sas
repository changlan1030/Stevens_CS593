*-------------------------------------------------------------------------;
* Problem        :  CS 593 Assignment 5 Problem 2                         ;
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
run;

* insert the record number;
proc sql;
create table churn_temp as
select
monotonic() as record,day_minutes,churn_ind
from churn0
;
run;

* divide the "churn" into "churn1" and "churn2";
data churn1 churn2;
set churn_temp;
if mod(record, 2)=1 then output churn1;
else if mod(record, 2)=0 then output churn2;
run;

title "Logistic regression analysis for churn1 on V_CSC";
proc logistic data=churn1 descending;
model churn_ind=day_minutes;
run;

title "Logistic regression analysis for churn2 on V_CSC";
proc logistic data=churn2 descending;
model churn_ind=day_minutes;
run;
