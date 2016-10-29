*-------------------------------------------------------------------------;
* Problem        :  CS 593 Midterm Problem 3                              ;
* Developer(s)   :  Lan Chang                                             ;
* Date           :  04/11/16                                              ;
* Comments       :  use map-reduce architecture to                        ;
*                   calculate the matrix multiplication                   ;
*-------------------------------------------------------------------------;

* create two matrix and divide each of them into two parts;
data matrixa_col1_2 matrixa_col3_4;
infile datalines;
input row col val;
if col<3 then output matrixa_col1_2;
else output matrixa_col3_4;
datalines;
1	1	10
1	2	15
1	3	20
1	4	25
2	1	5
2	2	10
2	3	15
2	4	20
3	1	5
3	2	15
3	3	25
3	4	35
4	1	10
4	2	20
4	3	30
4	4	40
;
run;

data matrixb_row1_2 matrixb_row3_4; 
input row col val;
if row<3 then output matrixb_row1_2;
else output matrixb_row3_4;
datalines;
1	1	1
2	1	3
3	1	5
4	1	7
1	2	2
2	2	4
3	2	6
4	2	8
;
run;

* create new libs named server1, server2;
libname server1 "C:\CHANGLAN\study\2016_Spring\CS_593\Midterm\server1";
libname server2 "C:\CHANGLAN\study\2016_Spring\CS_593\Midterm\server2";

* copy matrixa_col1_2 matrixb_row1_2 data to server1;
proc copy in=work out=server1;
select matrixa_col1_2 matrixb_row1_2;
run;

* copy matrixa_col3_4 matrixb_row3_4 data to server2;
proc copy in=work out=server2;
select matrixa_col3_4 matrixb_row3_4;
run;

* map1;
option autosignon=yes;
option sascmd="!sascmd";
rsubmit task1 wait=no sysrputsync=yes;
libname server1 "C:\CHANGLAN\study\2016_Spring\CS_593\Midterm\server1";
libname reduce1 "C:\CHANGLAN\study\2016_Spring\CS_593\Midterm\reduce1";

* change the name of row, col and val in matrixa_col1_2;
proc sql;
create table server1.a1 as
select
row as row_a1,
col as col_a1,
val as val_a1
from server1.matrixa_col1_2
;
run;

* change the name of row, col and val in matrixb_row1_2;
proc sql;
create table server1.b1 as
select
row as row_b1,
col as col_b1,
val as val_b1
from server1.matrixb_row1_2
;
run;

* combine these two table where the col of a1 is equal to the row of b1;
proc sql;
create table server1.c1 as
select *
from server1.a1 a,server1.b1 b
where a.col_a1=b.row_b1
;
run;

* multiply these two val and add a column of order number;
proc sql;
create table server1.v1 as
select
monotonic() as no,
c1.row_a1 as row_a1,
c1.col_a1 as col_a1,
c1.row_b1 as row_b1,
c1.col_b1 as col_b1,
(c1.val_a1*c1.val_b1) as val_1
from server1.c1
;
run;

* divide the table into two parts, and one part has the order 1, 2, 5, 6, 9, 10, 13, 14 and the other has the rest;
data server1.v11 server1.v12;
set server1.v1;
if mod(no-1,4)<2 then output server1.v11;
else output server1.v12;
run;

* add these two val;
proc sql;
create table server1.s1 as
select
v11.row_a1 as row_1,
v11.col_b1 as col_1,
(v11.val_1+v12.val_1) as val_1
from server1.v11, server1.v12
where v11.row_a1=v12.row_a1 and v11.col_b1=v12.col_b1
;
run;

* delete the unnecessary table;
proc delete data=server1.a1 server1.b1 server1.c1 server1.v1 server1.v11 server1.v12;
run;

* create a copy of s1 on the reduce server;
proc sql;
create table reduce1.s1 as
select *
from server1.s1
;
run;

endrsubmit;
RGET task1;

* map2;
option autosignon=yes;
option sascmd="!sascmd";
rsubmit task2 wait=no sysrputsync=yes;
libname server2 "C:\CHANGLAN\study\2016_Spring\CS_593\Midterm\server2";
libname reduce1 "C:\CHANGLAN\study\2016_Spring\CS_593\Midterm\reduce1";

* change the name of row, col and val in matrixa_col3_4;
proc sql;
create table server2.a2 as
select
row as row_a2,
col as col_a2,
val as val_a2
from server2.matrixa_col3_4
;
run;

* change the name of row, col and val in matrixb_row3_4;
proc sql;
create table server2.b2 as
select
row as row_b2,
col as col_b2,
val as val_b2
from server2.matrixb_row3_4
;
run;

* combine these two table where the col of a2 is equal to the row of b2;
proc sql;
create table server2.c2 as
select *
from server2.a2 a,server2.b2 b
where a.col_a2=b.row_b2
;
run;

* multiply these two val and add a column of order number;
proc sql;
create table server2.v2 as
select
monotonic() as no,
c2.row_a2 as row_a2,
c2.col_a2 as col_a2,
c2.row_b2 as row_b2,
c2.col_b2 as col_b2,
(c2.val_a2*c2.val_b2) as val_2
from server2.c2
;
run;

* divide the table into two parts, and one part has the order 1, 2, 5, 6, 9, 10, 13, 14 and the other has the rest;
data server2.v21 server2.v22;
set server2.v2;
if mod(no-1,4)<2 then output server2.v21;
else output server2.v22;
run;

* add these two val;
proc sql;
create table server2.s2 as
select
v21.row_a2 as row_2,
v21.col_b2 as col_2,
(v21.val_2+v22.val_2) as val_2
from server2.v21, server2.v22
where v21.row_a2=v22.row_a2 and v21.col_b2=v22.col_b2
;
run;

* delete the unnecessary table;
proc delete data=server2.a2 server2.b2 server2.c2 server2.v2 server2.v21 server2.v22;
run;

* create a copy of s1 on the reduce server;
proc sql;
create table reduce1.s2 as
select *
from server2.s2
;
run;

endrsubmit;
RGET task2;


* reduce;
libname main "C:\CHANGLAN\study\2016_Spring\CS_593\Midterm\reduce1";

* add these two val;
proc sql;
create table main.result as
select
s1.row_1 as row,
s1.col_1 as col,
(s1.val_1+s2.val_2) as val
from main.s1,main.s2
where s1.row_1=s2.row_2 and s1.col_1=s2.col_2
;
quit;
