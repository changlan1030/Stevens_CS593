*This program is to;
*distribute the posted "Cereal593" data over three servers,;
*using the above distributed architecture, establish a simple regression between variables "rating" and "fiber" and analyze the results,;
*and analyze the result by looking at ANOVA, and influential observations;
*Auther Lan Chang;
*Date 03/10/2016;

*part 1(for homework 2.1);

*read dataset "cereal593_ds" in mylib;
options obs=max;
libname mylib "C:\CHANGLAN\study\2016_Spring\CS_593\SAS\SAS_data" access=read;

*copy dataset "cereal593_ds" from mylib to work;
proc copy in=mylib out=work;
select cereal593_ds;
run;

*create new libs named SEVER_1, SEVER_2 and SEVER_3;
libname server_1 "C:\CHANGLAN\study\2016_Spring\CS_593\Homework\HW_2\server_1";
libname server_2 "C:\CHANGLAN\study\2016_Spring\CS_593\Homework\HW_2\server_2";
libname server_3 "C:\CHANGLAN\study\2016_Spring\CS_593\Homework\HW_2\server_3";

*distribute the data;
data Rating(keep=Product_id name rating)
Mfr(keep=Product_id name mfr type shelf)
NutVal(drop=rating mfr type shelf)
;
set cereal593_ds;
run;

*copy these data to three servers;
proc copy in=work out=server_1;
  select Rating;
run;

proc copy in=work out=server_2;
  select Mfr;
run;

proc copy in=work out=server_3;
  select NutVal;
run;

*part 2(for homework 2.2);

*create a table and select the rating in server_1 and fiber in server_3 where they have the same id;
proc sql;
create table regression as
select Rating.Product_id,Rating.rating,NutVal.fiber
from server_1.Rating,server_3.NutVal
where Rating.Product_id=NutVal.Product_id
;
quit;

title "Box plot for rating by fiber";
proc sgplot data=regression;
vbox rating/category=fiber;
run;

title "Scatter plot for rating vs. fiber";
proc sgplot data=regression;
scatter x=fiber  y=rating;
ellipse x=fiber  y=rating;
run;

*establish a simple regression between variables "rating" and "fiber";
title "Simple Regression for rating vs. fiber";
proc reg data=regression outest=est_regression;
model rating=fiber / dwProb;
OUTPUT OUT=reg_cerealOUT PREDICTED=c_predict RESIDUAL=res L95M=L95m U95M=U95m L95=L95 U95=U95
rstudent=rstudent h=lev cookd=cookd dffits=dffit STDP=C_s_predicted STDR=C_s_residual STUDENT=student;
quit;

title "Simple Regression for rating vs. fiber";
title2 "Univariate Analysis for the reg output dataset ";
proc univariate data=reg_cerealOUT normaltest plot;
var res rstudent lev cookd dffit;
run;

/*
Analyze:
In the table "Number of Observation", there are 77 observations. 
In the table "Analysis of Variance", the DF for Model is 1 and the DF for Corrected Total is 76, which is 77-1.
From SSM(Sum of Squares for Model) and SSE(Sum of Squares for Error), we can get the F value, which is (SSM/DF)/(SSE/DF).
The F value is 38.85 and the Pr>F is <0.0001, which indicates that the model is a good model.
The R-Square is 34.12%(SSM/SST), which indicates how well the data fit this model.
In the table "Parameter Estimates", t value and Pr>|t| shows that the intercept and fiber parameter estimates are highly significant.
The parameter estimates are 35.26 and 3.44, which indicates that the model is rating=35.26+3.44*fiber.
In the graph "Residuals for rating", it shows the residuals versus the fiber.
In the table "reg_cerealOUT", the Cook's D Influence Statistic shows the effect of removing a data point on all the parameters combined,
which means that if this data has a big value of cookd, it will have a more obvious effect on this model.
*/

title "Univariate Analysis for the regression";
proc univariate data=regression;
var fiber;
run;

title "Variance Analysis for rating vs. fiber";
proc anova data=regression;
class fiber;
model rating=fiber;
run;
quit;

/*
Analyze:
In the table "Class Level Information", there are 13 fiber levels and 77 observations.
In the next table, the DF for Model is 12, which is 13-1, and the DF for Corrected Total is 76, which is 77-1.
The F value is 4.40 and Pr>F is <0.0001, which indicates that the model is a good model.
In the next table, the R-Square is 45.19%, which indicates that the fiber accounts for 45.19% of the variation in Rating.
In the graph "Distribution of rating", it shows a box plot of the dependent variable.
*/
