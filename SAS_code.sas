* Loading data;
data onlineretail;
length InvoiceNo $10 StockCode $12 Description $200 
InvoiceDate $20 Country $20;
infile '/folders/myfolders/sasuser.v94/OnlineRetail_new.csv' dsd dlm=',';
input InvoiceNo $ StockCode $ Description $ 
Quantity InvoiceDate $ UnitPrice CustomerID Country $;
run;


* Find maximum sale day of the previous week according to the day the report is run.
The date needs to be kept dynamic.;

%macro maxsales(currentdate=);
%let cdate = %sysfunc(putn("&currentdate"d,5.));
proc sql;
create table maxsaleday as 
select input(scan(InvoiceDate,1,' '), ddmmyy10.) as date format=date9., 
sum(Quantity*UnitPrice) as TotalSale format=comma12.2
from onlineretail
where input(scan(InvoiceDate,1,' '), ddmmyy10.) >= &cdate-7 
and input(scan(InvoiceDate,1,' '), ddmmyy10.) < &cdate
group by date
order by TotalSale desc;
run;
%mend;

%maxsales(currentdate=23mar2011);
