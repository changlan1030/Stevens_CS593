*-------------------------------------------------------------------------;
* Problem        :  CS 593 Midterm Problem 1                              ;
* Developer(s)   :  Lan Chang                                             ;
* Date           :  04/11/16                                              ;
* Comments       :  use the "lung" dataset to find the regression         ;
*                   of FEV1_mother (dependent variable) on height_mother  ;
*-------------------------------------------------------------------------;

options obs=max;
libname mylib "C:\CHANGLAN\study\2016_Spring\CS_593\SAS\SAS_data" access=read;

* copy dataset "lung" from mylib to work;
proc copy in=mylib out=work;
select lung;
run;

*-------------------------------------------------------------------------;
* question 1                                                              ;
*-------------------------------------------------------------------------;

* normal distribute plot for Height_mother;
title "Normal distribute plot for Height_mother";
proc sgplot data=lung;
histogram Height_mother/;
density Height_mother;
density Height_mother/type=kernel;
run;

title "Normal distribute plot for FEV1_mother";
* normal distribute plot for FEV1_mother;
proc sgplot data=lung;
histogram FEV1_mother/;
density FEV1_mother;
density FEV1_mother/type=kernel;
run;

* box plot for FEV1_mother by Height_mother;
title "Box plot for FEV1_mother by Height_mother";
proc sgplot data=lung;
vbox FEV1_mother/category=Height_mother;
run;

* scatter plot for FEV1_mother vs. Height_mother;
title "Scatter plot for FEV1_mother vs. Height_mother";
proc sgplot data=lung;
scatter x=Height_mother  y=FEV1_mother;
ellipse x=Height_mother  y=FEV1_mother;
run;

*-------------------------------------------------------------------------;
* question 2, 4, 6                                                        ;
*-------------------------------------------------------------------------;

* establish a simple regression between variables "FEV1_mother" and "Height_mother";
title "Simple Regression for FEV1_mother vs. Height_mother";
proc reg data=lung outest=est_regression;
model FEV1_mother=Height_mother / dwProb;
OUTPUT OUT=reg_out PREDICTED=predict RESIDUAL=residual L95M=L95m U95M=U95m L95=L95 U95=U95
rstudent=rstudent h=lev cookd=cookd dffits=dffits STDP=s_predicted STDR=s_residual STUDENT=student;
quit;

title "Univariate analysis for FEV1_mother vs. Height_mother";
proc univariate data=Lung normaltest plot;
var Height_mother FEV1_mother;
run;

*-------------------------------------------------------------------------;
* question 3                                                              ;
*-------------------------------------------------------------------------;

* create a variable "logHeight_mother";
data lung;
set lung;
logHeight_mother = log(Height_mother);
run;

* establish a simple regression between variables "FEV1_mother" and "logHeight_mother";
title "Simple Regression for FEV1_mother vs. logHeight_mother";
proc reg data=lung outest=est_regression;
model FEV1_mother=logHeight_mother / dwProb;
OUTPUT OUT=reg_out PREDICTED=predict RESIDUAL=residual L95M=L95m U95M=U95m L95=L95 U95=U95
rstudent=rstudent h=lev cookd=cookd dffits=dffits STDP=s_predicted STDR=s_residual STUDENT=student;
quit;

*-------------------------------------------------------------------------;
* question 5                                                              ;
*-------------------------------------------------------------------------;

* univariate analysis for the reg output dataset;
title "Univariate analysis for the reg output dataset";
proc univariate data=reg_out;
var residual lev cookd dffits;
run;
