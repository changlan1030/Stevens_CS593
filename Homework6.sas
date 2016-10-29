data arcs;
infile datalines;
input Node $ A B C D E F G;
datalines;
A 0 1 0 0 0 0 0
B 1 0 0 1 0 0 1
C 1 0 0 1 0 1 0
D 1 1 0 0 0 0 0
E 0 0 1 0 0 0 0
F 0 0 0 0 1 0 0
G 0 1 0 0 0 0 1
;
run;

proc sql;
create table matrix as
select
a/sum(a) as x1,
b/sum(b) as x2,
c/sum(c) as x3,
d/sum(d) as x4,
e/sum(e) as x5,
f/sum(f) as x6,
g/sum(g) as x7
from arcs;
run;

data rank_p;
x1=1/7;
x2=1/7;
x3=1/7;
x4=1/7;
x5=1/7;
x6=1/7;
x7=1/7;
output;
run;

proc iml;
use matrix;
read all var { x1 x2 x3 x4 x5 x6 x7 } into M;
print M;

use rank_p;
read all var { x1 x2 x3 x4 x5 x6 x7 } into rank_p1;
rank_p = t(rank_p1);

unit={1,1,1,1,1,1,1};
print unit;

do i=1 to 75;
new_rank_p=0.8*(M*rank_p)+((1-0.8)/7)*unit;
print new_rank_p;
rank_p=new_rank_p;
end;
quit;
