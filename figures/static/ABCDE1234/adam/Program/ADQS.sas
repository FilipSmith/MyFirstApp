libname adam "/folders/myfolders/adam";
libname sdtm "/folders/myfolders/sdtm";
dm 'log; clear; lst; clear;';
*******************************************************************************;
* PROGRAM     : ABDC1234\ADAM\Program\ADQS.sas
* SOFTW/PLAT. : SAS v9.4 - W32 platform
* DATE        : Wed 05/26/2018 (mm/dd/yyyy) 
* PROGRAMMER  : Philippe Remusat
* PURPOSE     : Columbia-Suicide Severity Rating ScalE (css SCORE adam)
*
* INPUT       : SDTM.PD, ADAM.ADQS
* OUTPUT      : ADQS.sas7bdat (ADAM)
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



%let domain=ADQS;
%let keepvar=STUDYID USUBJID SUBJID SITEID SAFFL TRTSDT TRTEDT SEX SEXN RACE RACEN SAFFL TRTSDT TRTEDT TRTP TRTAN TRTA 
             VISITNUM VISIT AVISITN AVISIT ADT ADY ADY2 PARAMN PARAMCD PARAM AVALC APERIOD APERIODC DTYPE;
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
    TRTSDT    num format=yymmdd10.     label="Date of First Exposure to Treatment",
    TRTEDT    num format=yymmdd10.     label="Date of Last Exposure to Treatment",
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
    ADY       num                      label="Analysis Relative Day (DB)",
    ADY2      num                      label="Analysis Relative Day (OLE)",
    PARAMN    num                      label="Parameter (N)",
    PARAMCD   Char(8)                  label="Parameter Code",
    PARAM     Char(200)                label="Parameter",
    AVALC     Char(200)                label="Analysis Value (C)",
    DTYPE     Char(200)                label="Derivation Type"
    );
quit;

*-------------------------------------------------*;
* ADSL DATA                                       *;
*-------------------------------------------------*;
proc sort data=adam.adsl out=adsl;
    by usubjid;
run;

*-------------------------------------------------*;
* Get the Data                                    *;
*-------------------------------------------------*;
data qs;
    set sdtm.qs;
    where qscat="Columbia-Suicide Severity Rating Scale";
proc sort;
    by studyid usubjid visitnum visit qsdtc;
run;

proc transpose data=qs out=qs1;
    by studyid usubjid visitnum visit qsdtc;
    var qsorres;
    id qstestcd;
    idl qstest;
run;

data qs2;
    set qs1;
    rename css0101=cs_q1 css0102=cs_q2 css0103=cs_q3 css0104=cs_q4 css0105=cs_q5 css0112=csatmp css0114=cs_inj 
            css0115=csinter css0117=csabort css0119=cs_prep css0120=cs_beha css0221=cs_suic;
run;

data qs3;
    set qs2;
    if cs_q1="Y" or cs_q2="Y" or cs_q3="Y" or cs_q4="Y" or cs_q5="Y"          then cs_q12="Y";
    if cs_prep="Y" or csabort="Y" or csinter="Y" or csatmp="Y" or cs_suic="Y" then cs_q13="Y";
    if cs_q12="Y" or cs_q13="Y" then cs_q14="Y";
run;

proc transpose data=qs3 out=qs4(rename=(_name_=paramcd _label_=param));
  by studyid usubjid visitnum visit qsdtc;
  var cs_q1 cs_q2 cs_q3 cs_q4 cs_q5
      csatmp cs_inj csinter csabort 
    cs_prep cs_suic   
    cs_q12 cs_q13 cs_q14 cs_beha;
run;


data qs5(keep=paramn param paramcd avalc dtype avisitn avisit visitnum visit usubjid qsdtc dtype);
  length param $200.;
  set qs4;
  by studyid usubjid visitnum visit qsdtc;
  Select (paramcd);
    When("CS_Q1")   do;paramn=1;param="Wish to be dead";end;
    When("CS_Q2")   do;paramn=2;param="Non-Specific Active Suicidal Thoughts";end;
    When("CS_Q3")   do;paramn=3;param="Active Suicidal Ideation Without Intent";end;
    When("CS_Q4")   do;paramn=4;param="Active Suicidal Ideation with Some Intent to Act, without Specific Plan";end;
    When("CS_Q5")   do;paramn=5;param="Active Suicidal Ideation with Specific Plan and Intent";end;
    When("CS_PREP") do;paramn=6;param="Preparatory Acts";end;
    /*When("CS_PRTX") do;paramn=6.1;end;*/
    When("CSABORT") do;paramn=7;param="Aborted Attempt";end;
    /*When("CSABOTX") do;paramn=7.1;end;*/
    When("CSINTER") do;paramn=8;param="Interrupted Attempt";end;
    When("CSATMP")  do;paramn=9;param="Actual Attempt";end;
    /*When("CSATMTX")  do;paramn=9.1;end;
    When("CSATMPN")  do;paramn=9.2;end;*/
    When("CS_SUIC") do;paramn=10;param="Suicide";end;
    When("CS_INJ")  do;paramn=11;param="Non-Suicidal Self-Injurious Behavior";end;
    When("CS_Q12")  do;paramn=12;param="Suicidal Ideation";dtype="DERIVED";end;
    When("CS_Q13")  do;paramn=13;param="Suicidal Behavior";dtype="DERIVED";end;
    When("CS_Q14")  do;paramn=14;param="Suicidal ideation or behavior";dtype="DERIVED";end;
    When("CS_BEHA") do;paramn=15;param="Suicidal Behavior Present";end;
    Otherwise;
  End;
  avalc=qsorres;

  length avisit $200.;
  avisitn=visitnum;
  avisit=visit;
  subjid=substr(usubjid,10);
  siteid=substr(subjid,3,4);
run;
/*proc sql;
    create table aa as
    select distinct paramn,param
    from qs5;
quit;*/

************************************************************************************;
* Pull the data together
************************************************************************************;
data all;
  merge adsl qs5(in=b);
  by usubjid;
  if b;
  length aperiodc $200. trtp trta $10. aperiod 8.; 
  adt=mdy(substr(qsdtc,6,2),substr(qsdtc,9,2),substr(qsdtc,1,4));
  format adt yymmdd10.;
  if .<adt<=tr01edt or (adt>=mdy(05,01,2017) and  visitnum in (20 30 40 50 60 )) or (adt =. and visitnum eq 80) then do;
    aperiod=1;
    aperiodc="DB Period";
    trta=trt01a;
    trtp=trt01p;
    trtan=trt01an;
  end;
  else if (.<tr02sdt<=adt<=tr02edt) or (tr02edt=. and .<tr02sdt<=adt) or (adt>trtsdt and visitnum in (170 180)) then do;
    aperiod=2;
    aperiodc="OLE Period";
    trta=trt02a;
    trtp=trt02p;
    trtan=trt02an;
  end;
  else if (tr03edt ne . and .<tr03sdt<=adt<=tr03edt) or (tr03edt=. and .<tr03sdt<=adt) then do;
    aperiod=3;
    aperiodc="Taper Period";
    trta=trt03a;
    trtp=trt03p;
    trtan=trt03an;
  end;

  if adt>=trtsdt then ady=adt-trtsdt+1;
                 else ady=adt-trtsdt;

  if adt>=tr02sdt then ady2=adt-tr02sdt+1;
                 else ady2=adt-tr02sdt;
proc sort;
    by usubjid avisitn adt paramn;
run;

%*--- Create ADaM dataset;
data adqs;
 informat _all_;
 set adam_template all;
 keep &keepvar.;
run;

data adam.&domain;
  set adqs;
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
    call execute("data adam.&domain.(label='C-SSRS Analysis Dataset');");
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
 
