*-------------------------------------------------------------------------;
* Problem        :  CS 593 Assignment 4 Problem 2                         ;
* Developer(s)   :  Lan Chang                                             ;
* Date           :  04/17/16                                              ;
*-------------------------------------------------------------------------;

* select the following folder as mylib;
options obs=max;
libname mylib "C:\CHANGLAN\study\2016_Spring\CS_593\SAS\SAS_data" access=read;

* copy dataset "new_york" from mylib to work;
proc copy in=mylib out=work;
select new_york;
run;

* correlation analysis on all variables;
title "Correlation analysis";
proc corr data=new_york cov;
var male_fem tot_pop pct_u18 pc_18_65 pct_o65;
run;

* simple regression model to predict using all variables;
title "Simple regression all variables";
proc reg data=new_york;
model male_fem=tot_pop pct_u18 pc_18_65 pct_o65/ dwProb stb;
run;

* simple regression model to predict using forward selection;
title "Simple regression forward selection";
proc reg data=new_york;
model male_fem=tot_pop pct_u18 pc_18_65 pct_o65/ dwProb pcorr1 VIF selection=forward;
run;

* simple regression model to predict using backward selection;
title "Simple regression backward selection";
proc reg data=new_york;
model male_fem=tot_pop pct_u18 pc_18_65 pct_o65/ dwProb pcorr1 VIF selection=backward;
run;

* simple regression model to predict using stepwise selection;
title "Simple regression stepwise selection";
proc reg data=new_york;
model male_fem=tot_pop pct_u18 pc_18_65 pct_o65/ dwProb pcorr1 VIF selection=stepwise;
run;

* simple regression model to predict using the best subset;
title "Simple regression best subset";
proc reg data=new_york;
model male_fem=tot_pop pct_u18 pc_18_65 pct_o65/ dwProb pcorr1 VIF selection=MAXR;
run;

title "Simple regression with tot_pop";
proc reg data=new_york;
model male_fem=tot_pop pct_u18 pct_o65/ dwProb stb;
run;

title "Simple regression without tot_pop";
proc reg data=new_york;
model male_fem=pct_u18 pct_o65/ dwProb stb;
run;

* Multicollinearity analysis;
title "Multicollinearity analysis";
proc reg data=new_york;
model male_fem=pct_u18 pct_o65/ tol vif collin;
run;
