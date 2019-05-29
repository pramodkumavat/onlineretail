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
*%let cdate = %sysfunc(INPUTN(&currentdate, date9.), ddmmyy10.);
%let cdate = %sysfunc(putn("&currentdate"d,5.));
format &cdate ddmmyy10.;
proc sql outobs=1;
create table maxsaleday as 
select input(scan(o1.InvoiceDate,1,' '), ddmmyy10.) as date format=date9., 
sum(o1.Quantity*o2.UnitPrice) as TotalSale format=comma12.2
from onlineretail o1, onlineretail o2 
where o1.InvoiceNo = o2.InvoiceNo and o1.CustomerID = o2.CustomerID 
and o1.Description = o2.Description and o1.Quantity = o2.Quantity 
and o1.UnitPrice = o2.UnitPrice and o1.InvoiceDate = o2.InvoiceDate 
and input(scan(o1.InvoiceDate,1,' '), ddmmyy10.) >= &cdate-7 
and input(scan(o1.InvoiceDate,1,' '), ddmmyy10.) < &cdate
group by date
order by TotalSale desc;
run;
%mend;

%maxsales(currentdate=23mar2011);
