*This program is to;
*use the distributed Cereal data set and join the "rating" and "shelf";
*using "product ID" in a Map-Reduce environment;
*Auther Lan Chang;
*Date 03/17/2016;

*read dataset "cereal593_ds" in mylib;
options obs=max;
libname mylib "C:\CHANGLAN\study\2016_Spring\CS_593\SAS\SAS_data" access=read;

*copy dataset "cereal593_ds" from mylib to work;
proc copy in=mylib out=work;
select cereal593_ds;
run;

*create new libs named sasdata1, sasdata2;
libname sasdata1 "C:\CHANGLAN\study\2016_Spring\CS_593\Homework\HW_3\sasdata1";
libname sasdata2 "C:\CHANGLAN\study\2016_Spring\CS_593\Homework\HW_3\sasdata2";

*distribute the data;
data rating(keep=Product_id name rating)
mfr(keep=Product_id name mfr type shelf)
;
set cereal593_ds;
run;

*copy these data to two servers;
proc copy in=work out=sasdata1;
select rating;
run;
proc copy in=work out=sasdata2;
select mfr;
run;


*select the rating from the first server and create a copy on the reduce server;
option autosignon=yes;
option sascmd="!sascmd";
rsubmit task1 wait=no sysrputsync=yes;
libname sasdata1 "C:\CHANGLAN\study\2016_Spring\CS_593\Homework\HW_3\sasdata1";
libname reduce1 "C:\CHANGLAN\study\2016_Spring\CS_593\Homework\HW_3\reduce1";
proc sql;
create table reduce1.rating as
select * from sasdata1.rating
;
quit;

endrsubmit;
RGET task1;

*select the mfr from the second server and create a copy on the reduce server;
option autosignon=yes;
option sascmd="!sascmd";
rsubmit task2 wait=no sysrputsync=yes;
libname sasdata2 "C:\CHANGLAN\study\2016_Spring\CS_593\Homework\HW_3\sasdata2";
libname reduce1 "C:\CHANGLAN\study\2016_Spring\CS_593\Homework\HW_3\reduce1";
proc sql;
create table reduce1.mfr as
select * from sasdata2.mfr
;
quit;

endrsubmit;
RGET task2;

*process the data on the main/reduce server;
libname main "C:\CHANGLAN\study\2016_Spring\CS_593\Homework\HW_3\reduce1";

proc sql;
create table mydata as
select a.Product_id, a.rating, b.shelf
from main.rating a, main.mfr b
where a.Product_id=b.Product_id
;
quit;
