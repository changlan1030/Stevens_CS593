* select the following folder as mylib;
options obs=max;
libname mylib "C:\CHANGLAN\study\2016_Spring\CS_593\SAS\SAS_data" access=read;

* copy dataset "mroz" from mylib to work;
proc copy in=mylib out=work;
select mroz;
run;

* correlation analysis for TAXABLEINC on all variables;
title "correlation analysis for TAXABLEINC on all variables";
proc corr data=mroz;
var HSIBLINGS HFATHEREDUC HMOTHEREDUC SIBLINGS LFP HOURS KIDSL6 KIDS618 AGE EDUC WAGE WAGE76 HHOURS HAGE HEDUC HWAGE FAMINC MTR MOTHEREDUC FATHEREDUC UNEMPLOYMENT LARGECITY EXPER;
with TAXABLEINC;
run;

* simple multiple regression model to predict using backward selection;
title "multiple regression analysis using backward selection";
proc reg data=mroz;
model TAXABLEINC=HSIBLINGS HFATHEREDUC HMOTHEREDUC SIBLINGS LFP HOURS KIDSL6 KIDS618 AGE EDUC WAGE WAGE76 HHOURS HAGE HEDUC HWAGE FAMINC MTR MOTHEREDUC FATHEREDUC UNEMPLOYMENT LARGECITY EXPER/ dwProb pcorr1 VIF selection=backward;
run;

*divide the data into two datasets by LFP;
data income_1 income_2;
set mroz;
if mod(LFP, 2)=0 then output income_1;
else if mod(LFP, 2)=1 then output income_2;
run;

*create new libs named sasdata1, sasdata2;
libname sasdata1 "C:\CHANGLAN\study\2016_Spring\CS_593\Project\sasdata1";
libname sasdata2 "C:\CHANGLAN\study\2016_Spring\CS_593\Project\sasdata2";

*copy these data to two servers;
proc copy in=work out=sasdata1;
select income_1;
run;
proc copy in=work out=sasdata2;
select income_2;
run;

*select the income_1 from the first server and create a copy on the reduce server;
option autosignon=yes;
option sascmd="!sascmd";
rsubmit task1 wait=no sysrputsync=yes;
libname sasdata1 "C:\CHANGLAN\study\2016_Spring\CS_593\Project\sasdata1";
libname reduce1 "C:\CHANGLAN\study\2016_Spring\CS_593\Project\reduce1";

* create a variable "LOG_TAXABLEINC";
data sasdata1.log_income_1;
set sasdata1.income_1;
LOG_TAXABLEINC=log(TAXABLEINC);
run;

* copy dataset "log_income_1" from sasdata1 to reduce1;
proc sql;
create table reduce1.log_income_1 as
select *
from sasdata1.log_income_1
;
run;

endrsubmit;
RGET task1;

*select the income_2 from the second server and create a copy on the reduce server;
option autosignon=yes;
option sascmd="!sascmd";
rsubmit task2 wait=no sysrputsync=yes;
libname sasdata2 "C:\CHANGLAN\study\2016_Spring\CS_593\Project\sasdata2";
libname reduce1 "C:\CHANGLAN\study\2016_Spring\CS_593\Project\reduce1";

* create a variable "LOG_TAXABLEINC";
data sasdata2.log_income_2;
set sasdata2.income_2;
LOG_TAXABLEINC=log(TAXABLEINC);
run;

* copy dataset "log_income_2" from sasdata1 to reduce1;
proc sql;
create table reduce1.log_income_2 as
select *
from sasdata2.log_income_2
;
run;

endrsubmit;
RGET task2;

* combine two datasets;
libname main "C:\CHANGLAN\study\2016_Spring\CS_593\Project\reduce1";
proc sql;
insert into main.log_income_1 select * from main.log_income_2;
run;

* normal distribute plot;
title "normal distribute plot on TAXABLEINC and LOG_TAXABLEINC";
proc univariate data=main.log_income_1 normaltest plot;
var TAXABLEINC LOG_TAXABLEINC;
run;

* correlation analysis for LOG_TAXABLEINC on all variables;
title "correlation analysis for LOG_TAXABLEINC on all variables";
proc corr data=main.log_income_1;
var HSIBLINGS HFATHEREDUC HMOTHEREDUC SIBLINGS LFP HOURS KIDSL6 KIDS618 AGE EDUC WAGE WAGE76 HHOURS HAGE HEDUC HWAGE FAMINC MTR MOTHEREDUC FATHEREDUC UNEMPLOYMENT LARGECITY EXPER;
with LOG_TAXABLEINC;
run;

* simple multiple regression model to predict using backward selection;
title "multiple regression analysis using backward selection";
proc reg data=main.log_income_1;
model LOG_TAXABLEINC=HSIBLINGS HFATHEREDUC HMOTHEREDUC SIBLINGS LFP HOURS KIDSL6 KIDS618 AGE EDUC WAGE WAGE76 HHOURS HAGE HEDUC HWAGE FAMINC MTR MOTHEREDUC FATHEREDUC UNEMPLOYMENT LARGECITY EXPER/ dwProb pcorr1 VIF selection=backward;
run;

* select the necessary variables;
data income(keep=LOG_TAXABLEINC HSIBLINGS HFATHEREDUC HMOTHEREDUC SIBLINGS LFP KIDSL6 EDUC WAGE76 TAXABLEINC);
set main.log_income_1;
run;

* simple multiple regression;
title "multiple regression analysis";
proc reg data=income;
model LOG_TAXABLEINC=HSIBLINGS HFATHEREDUC HMOTHEREDUC SIBLINGS LFP KIDSL6 EDUC WAGE76/ dwProb;
OUTPUT OUT=reg_out PREDICTED=predict RESIDUAL=residual L95M=L95m U95M=U95m L95=L95 U95=U95
rstudent=rstudent h=lev cookd=cookd dffits=dffits STDP=s_predicted STDR=s_residual STUDENT=student;
run;

* univariate analysis for the reg output dataset;
title "univariate analysis for the reg output dataset";
proc univariate data=reg_out;
var lev cookd dffits;
run;

* multicollinearity analysis;
title "multicollinearity analysis";
proc reg data=income;
model LOG_TAXABLEINC=HSIBLINGS HFATHEREDUC HMOTHEREDUC SIBLINGS LFP KIDSL6 EDUC WAGE76/ tol vif collin;
quit;
