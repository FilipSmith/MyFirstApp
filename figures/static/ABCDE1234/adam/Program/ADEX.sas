libname adam "/folders/myfolders/adam";
libname sdtm "/folders/myfolders/sdtm";
dm 'log; clear; lst; clear;';
*******************************************************************************;
* PROGRAM     : ABDC1234\ADAM\Program\ADEX.sas
* SOFTW/PLAT. : SAS v9.4 - W32 platform
* DATE        : Wed 05/26/2018 (mm/dd/yyyy) 
* PROGRAMMER  : Philippe Remusat
* PURPOSE     : Exposure (ADAM)
*
* INPUT       : SDTM.EX, ADAM.ADSL
* OUTPUT      : ADEX.sas7bdat (ADAM)
*
* MACROS      : 
*
*******************************************************************************;
* Modifications History:
*------------------------------------------------------------------------------;
* Modif. #01  :
* Programmer  :
* Date        :
* Purpose     :
*******************************************************************************;
gfgfg


%let domain=ADEX;
%let keepvar=STUDYID USUBJID SUBJID SITEID SAFFL TRTSDT TRTEDT SEX SEXN RACE RACEN SAFFL TRTSDT TRTEDT 
             APERIODC APERIOD TRTP TRTAN TRTA PARAMN PARAMCD PARAM AVAL AVALC;
option varlenchk=nowarn;

%*--- Create a Template;
proc sql noprint;
    create table ADAM_TEMPLATE
    (
    STUDYID   Char(15)                 label="Study Identifier",
    USUBJID   Char(40)                 label="Unique Subject Identifier",
    SUBJID    Char(10)                 label="Subject Identifier for the Study",
    SITEID    Char(8)                  label="Study Site Identifier",
	SAFFL     Char(1)                  label="Safety Population Flag",
    SEX       Char(6)                  label="Sex",
    SEXN      num                      label="Sex (N)",
    RACE      Char(50)                 label="Race",
    RACEN     num                      label="Race (N)",
    SAFFL     Char(1)                  label="Safety Population Flag",
    TRTSDT    num format=yymmdd10.     label="Date of First Exposure to Treatment",
    TRTEDT    num format=yymmdd10.     label="Date of Last Exposure to Treatment",
	APERIODC  Char(200)                label="Period (C)",
	APERIOD   num                      label="Period",
    TRTP      Char(100)                label="Planned Treatment",
    TRTAN     num                      label="Actual Treatment (N)",
    TRTA      Char(100)                label="Actual Treatment",
    VISITNUM  num                      label="Visit (N)",
    VISIT     Char(200)                label="Visit",
    AVISITN   num                      label="Analysis Visit (N)",
    AVISIT    Char(200)                label="Analysis Visit",
    ADT       num format=yymmdd10.     label="Analysis Date",
    ADY       num                      label="Analysis Relative Day",
    PARAMN    num                      label="Parameter (N)",
    PARAMCD   Char(8)                  label="Parameter Code",
    PARAM     Char(200)                label="Parameter",
    AVAL      num                      label="Analysis Value",
    AVALC     Char(200)                label="Analysis Value (C)"
    );
quit;

************************************************************************************;
* ADSL
************************************************************************************;
proc sort data=adam.adsl out=adsl;
    by usubjid;
run;

************************************************************************************;
* Duration of treatment 
************************************************************************************;
data db;
    set adam.adsl(where=(tr01sdt ne .));
    exstdt=tr01sdt;
    exendt=tr01edt;
    aperiod=1;
    keep studyid usubjid exstdt exendt aperiod;
run;

data ole;
    set adam.adsl(where=(tr02sdt ne .));
    exstdt=tr02sdt;
    exendt=tr02edt;
    aperiod=2;
    keep studyid usubjid exstdt exendt aperiod;
run;

data taper;
    set adam.adsl(where=(tr03sdt ne .));
    exstdt=tr03sdt;
    exendt=tr03edt;
    aperiod=3;
    keep studyid usubjid exstdt exendt aperiod;
run;

data all;
    set db ole taper;
    format exstdt exendt ddmmyy10.;
proc sort;
    by usubjid;
run;

data ex;
    set all;
    if not missing(exendt) then aval=exendt-exstdt+1;
    if exendt=. then aval=mdy(05,01,2017)-exstdt+1; *** Ongoing subjects: cutoff date used; 
    length param $40. paramcd $8.;
    paramcd="EXDUR";
    param="Treatment Duration (Days)";
    paramn=1;
proc sort;
    by usubjid;
run;

************************************************************************************;
* Compliance 
************************************************************************************;
proc sort data=sdtm.da out=da;
    by studyid usubjid daseq;
run;

proc sort data=sdtm.suppda(where=(idvarval ne "" and idvar="DASEQ")) out=sda1;
    by usubjid idvarval;
run;

proc transpose data=sda1 out=sda2;
    by studyid usubjid idvarval;
    var qval;
    id qnam;
run;

data sda3;
    set sda2;
    daseq=input(idvarval,best12.);
    drop idvarval _name_ _label_;
    if dausedl="Yes" then daused=1;
        else if dausedl="No" then daused=2;
    if daspabl="Yes" then daspab=1;
	   else if daspabl="No" then daspab=2;
proc sort;
    by studyid usubjid daseq;
run;

data sda4;
  merge sda3 da(keep=studyid usubjid daseq visitnum);
  by studyid usubjid daseq;
  if 20<=visitnum<=60            then aperiod=1;
  else if visitnum in (80,100) then aperiod=3;
  else if visitnum in(90,110,120,130,140,150,160,170,180)then aperiod=2;
  if visitnum>=200 then delete;
run;

proc sort data=sdtm.suppda(where=(idvar="VISITNUM")) out=sda5;
    by usubjid idvarval;
run;

proc transpose data=sda5 out=sda6;
  by studyid usubjid idvarval;
  var qval;
  id qnam;
run;

data sda7;
  set sda6;
  visitnum=input(idvarval,best12.);
  if 20<=visitnum<=60          then aperiod=1;
  else if visitnum in (80,100) then aperiod=3;
  else if visitnum in(90,110,120,130,140,150,160,170,180) then aperiod=2;
  if visitnum>=200 then delete;
run;

proc sql noprint;
  create table quest1 as select distinct studyid,usubjid,aperiod,max(dacomp) as quest1 from sda7 group by studyid,usubjid,aperiod;
  create table quest2 as select distinct studyid,usubjid,aperiod,max(daused) as quest2 from sda4  group by studyid,usubjid,aperiod;
  create table quest3 as select distinct studyid,usubjid,aperiod,min(daspab) as quest3 from sda4  group by studyid,usubjid,aperiod;

  create table quest1No  as select distinct studyid,usubjid,aperiod,max(dacomp) as quest1No  from sda7 where dacomp="2" group by studyid,usubjid,aperiod;
  create table quest2No  as select distinct studyid,usubjid,aperiod,max(daused) as quest2No  from sda4  where daused=2 group by studyid,usubjid,aperiod;
  create table quest3Yes as select distinct studyid,usubjid,aperiod,min(daspab) as quest3Yes from sda4  where daspab=1 group by studyid,usubjid,aperiod;
  
quit;

data compliance;
  merge quest:;
  by usubjid aperiod;
  length param avalc $40. paramcd $8.;
  paramcd="EXCOMP";
  param="Compliance";
  paramn=2;
       if quest1="1" and quest2="1" and quest3="2"      then avalc="Yes";
  else if quest1No="2" or quest2No="2" or quest3Yes="1" then avalc="No";
  else avalc="Unknown";
  keep studyid usubjid avalc paramn paramcd param aperiod;
run;

************************************************************************************;
* Pull the data together
************************************************************************************;
data all_expo;
  set ex compliance;
  length aperiodc $200.;
       if aperiod=1 then aperiodc="DB Period";   
  else if aperiod=2 then aperiodc="OLE Period";  
  else if aperiod=3 then aperiodc="Taper Period";
  %* Modification: Monday, July 10, 2017 05:02:49;
  if usubjid ="GWEP1447-X-1114-002" and aperiod=2 then delete;
  %* End of Modification: Monday, July 10, 2017 05:02:49;
run;

proc sort;by usubjid;run;

data all;
  merge adsl all_expo(in=a);
  by usubjid;
  if a;
  length trtp $10.;
  if aperiod=1 then do;trtp=trt01p;trta=trt01a;trtan=trt01an;end;
  if aperiod=2 then do;trtp=trt02p;trta=trt02a;trtan=trt02an;end;
  if aperiod=3 then do;trtp=trt03p;trta=trt03a;trtan=trt03an;end;
run;

proc sort;by usubjid aperiod paramn;run;

%*--- Create ADaM dataset;
data adex;
 informat _all_;
 set adam_template all;
 keep &keepvar.;
run;

data adam.&domain;
  set adex;
run;

%*--- Adjust length of varibales;
data _null_;
  set sashelp.vcolumn(where=(LIBNAME="ADAM" and MEMNAME="&domain." and upcase(type)="CHAR")) end=eof;
  if _n_=1 then do;
    call execute("proc sql noprint;");
  end;
  call execute("select max(length("||compress(name)||")) into: l" ||compress(name)|| " from adam.&domain.;");
  if eof then do;
   call execute("quit;");
  end;
run;

data _null_;
  set sashelp.vcolumn(where=(LIBNAME="ADAM" and MEMNAME="&domain.")) end=eof;
  if _n_=1 then do;
    call execute("data adam.&domain.(label='Exposure Analysis Dataset');");
  end;
  if type="char"  then do;
    lentmp=symget("l"||compress(name));
    if lentmp=. then lentmp=1;
    call execute("attrib " || compress(name) || " length=" || compress("$" || lentmp || ".;"));
  end;
  else do;
   if compress(format)="" then call execute("attrib " || compress(name) || " length=8.;");
   if compress(format)="YYMMDD10." then call execute("attrib " || compress(name) || " format=yymmdd10.;");
   if compress(format)="TIME5."    then call execute("attrib " || compress(name) || " format=time5.;");
  end;
  if eof then do;
    call execute("set adam.&domain.;run;");
  end;
run;
 