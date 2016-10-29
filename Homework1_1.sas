*This program is to;
*read in the "Lung_all" dataset into the SAS work library,;
*using prime number 3 and the "family id" column, divide the data into three datasets(Lung_1, Lung_2 and Lung_3),;
*and allocate three new libraries sasdata1, sasdata2, and sasdata3 and copy Lung_1 to sasdata1, Lung_2 to sasdata2 and Lung_3 to sasdata3;
*Auther Lan Chang;
*Date 02/22/2016;

options obs=max;
libname mylib "C:\CHANGLAN\study\2016_Spring\CS_593\SAS\SAS_data" access=read;

*copy dataset "lung_all" from mylib to work;
proc copy in=mylib out=work;
 select lung_all;
run;

*divide the data into three datasets by the remainder;
data Lung_1 Lung_2 Lung_3;
 set lung_all;
 if mod(Family_ID, 3)=0 then output Lung_1;
 else if mod(Family_ID, 3)=1 then output Lung_2;
 else output Lung_3;
run;

*create new lib named sasdata1;
libname sasdata1 "C:\CHANGLAN\study\2016_Spring\CS_593\Homework\HW_1\sasdata1";

*copy dataset "Lung_1" from work to sasdata1;
proc copy in=work out=sasdata1;
 select Lung_1;
run;

*create new lib named sasdata2;
libname sasdata2 "C:\CHANGLAN\study\2016_Spring\CS_593\Homework\HW_1\sasdata2";

*copy dataset "Lung_2" from work to sasdata2;
proc copy in=work out=sasdata2;
 select Lung_2;
run;

*create new lib named sasdata3;
libname sasdata3 "C:\CHANGLAN\study\2016_Spring\CS_593\Homework\HW_1\sasdata3";

*copy dataset "Lung_3" from work to sasdata3;
proc copy in=work out=sasdata3;
 select Lung_3;
run;
