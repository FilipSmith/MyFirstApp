libname adam "/folders/myfolders/adam";
libname sdtm "/folders/myfolders/sdtm";
dm 'log; clear; lst; clear;';
*******************************************************************************;
* PROGRAM     : ABDC1234\ADAM\Program\ADVS.sas
* SOFTW/PLAT. : SAS v9.4 - W32 platform
* DATE        : Wed 05/26/2018 (mm/dd/yyyy) 
* PROGRAMMER  : Philippe Remusat
* PURPOSE     : Vital Signs (ADAM)
*
* INPUT       : SDTM.VS, ADAM.ADPD
* OUTPUT      : ADVS.sas7bdat (ADAM)
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

%let domain=ADVS;
%let keepvar=STUDYID USUBJID SUBJID SITEID SAFFL TRTSDT TRTEDT SEX SEXN RACE RACEN SAFFL TRTSDT TRTEDT TRTP TRTAN TRTA 
             VISITNUM VISIT AVISITN AVISIT ADT ADY ADY2 PARAMN PARAMCD PARAM AVAL BASE CHG PCHG ABLFL ARML MCYN APERIOD APERIODC;
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
    AVAL      num                      label="Analysis Value",
    BASE      num                      label="Baseline Value",
    CHG       num                      label="Change from Baseline",
    PCHG      num                      label="Percent Change from Baseline",
    ABLFL     Char(1)                  label="Baseline Record Flag",
	ARML      Char(200)                label="Arm Used",
	MCYN      Num(1)                   label="Indicative of Medical Condition?"
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
proc sort data=sdtm.vs out=vss;
    by usubjid vsdtc;
run;

data pemcl;
    set sdtm.suppvs(where=(qnam="PEMCL"));
    if qval="No" then mcyn=2;
    	else if qval="Yes" then mcyn=1;
    vsdtc=idvarval;
    keep studyid usubjid vsdtc mcyn;
proc sort;
    by usubjid vsdtc;
run;

data pe;
    merge vss(where=(vstestcd in ("HEIGHT","WEIGHT"))) pemcl;
    by usubjid vsdtc;
run;

data vsmcl;
    set sdtm.suppvs(where=(qnam="VSMCL"));
    if qval="No" then mcyn=2;
    	else if qval="Yes" then mcyn=1;
    vsdtc=idvarval;
    keep studyid usubjid vsdtc mcyn;
proc sort;
    by usubjid vsdtc;
run;

data vs;
    merge vss(where=(vstestcd not in ("HEIGHT","WEIGHT"))) vsmcl;
    by usubjid vsdtc;
run;

data vs1;
    set pe vs;
    adt=input(vsdtc,yymmdd10.);
    format adt yymmdd10.;
    length paramcd $10.;
    paramcd=vstestcd;
    if vstestcd="DIABP" and vspos="SITTING" then paramcd="VSSIDIA";
    if vstestcd="DIABP" and vspos="STANDING" then paramcd="VSSTDIA";
    if vstestcd="DIABP" and vspos="SUPINE" then paramcd="VSSPDIA";
    if vstestcd="SYSBP" and vspos="SITTING" then paramcd="VSSISYS";
    if vstestcd="SYSBP" and vspos="STANDING" then paramcd="VSSTSYS";
    if vstestcd="SYSBP" and vspos="SUPINE" then paramcd="VSSPSYS";
proc sort;
    by usubjid;
run;

data vs2;
    merge vs1(in=a) adsl(keep=usubjid trtsdt);
    by usubjid;
    if a;
proc sort;
    by usubjid;
run;

*-------------------------------------------------*;
* BASELINE - CHANGE FROM BASELINE                 *;
*-------------------------------------------------*;
data vs3;
    set vs2;
    by usubjid;
    aval=vsstresn;
    if adt<=trtsdt and aval ne . then baseline=1; /** Up to First Dose **/
                   else baseline=2; /** Post First Dose  **/
    length param $40.;
    Select (paramcd);
        When("HEIGHT")   do;paramn=1;param="Height (cm)";end;
        When("WEIGHT")   do;paramn=2;param="Weight (kg)";end;
        When("VSSIDIA")  do;paramn=3;param="Sitting Diastolic Blood Pressure (mmHg)";end;
        When("VSSISYS")  do;paramn=4;param="Sitting Systolic Blood Pressure (mmHg)";end;
        When("VSSPDIA")  do;paramn=5;param="Supine Diastolic Blood Pressure (mmHg)";end;
        When("VSSPSYS")  do;paramn=6;param="Supine Systolic Blood Pressure (mmHg)";end;
        When("VSSTDIA")  do;paramn=7;param="Standing Diastolic Blood Pressure (mmHg)";end;
        When("VSSTSYS")  do;paramn=8;param="Standing Systolic Blood Pressure (mmHg)";end;
        When("PULSE")    do;paramn=9;param="Pulse Rate (Beats/min)";end;
        When("TEMP")     do;paramn=10;param="Temperature (C)";end;
        When("RESP")     do;paramn=11;param="Respiratory Rate (Breaths/min)";end;
        Otherwise;
    End;
proc sort;
    by usubjid paramcd param baseline adt;
run;

data vs4;
    set vs3;
    by usubjid paramcd param baseline adt;
    retain basedt base;
    if first.param then do;basedt=.;base=.;ablfl=" "; chg=.;pchg=.;end;
         if not last.baseline  and baseline=1 then do;basedt=.;base=.;end;
    else if last.baseline and baseline=1 then do;ablfl="Y";basedt=adt;base=aval;end;
    else if baseline=2 and not first.param then do;
      chg=aval-base;
      if aval ne . and base not in (.,0) then pchg=((aval-base)/base)*100;
    end;
    %* Modification: Tuesday, July 11, 2017 1242-004 reported baseline value at screening;
    if ablfl ne 'Y' and visitnum <=10 then base=.;
    %* End of Modification: Tuesday, July 11, 2017 ;

    if adt>=trtsdt then ady=adt-trtsdt+1;
                   else ady=adt-trtsdt;

    length avisit arml $200.;
    avisitn=visitnum;
    avisit=visit;
    arml=compress(propcase(vslat))||" "||compress(lowcase(vsloc));
    format basedt yymmdd10.;
run;


************************************************************************************;
* Pull the data together
************************************************************************************;
data all;
    merge adsl vs4(in=b);
    by usubjid;
    if b;
    length aperiodc $200. trtp $10.;
    if trtsdt ne . and ((.<adt<=tr01edt) or (adt>=mdy(05,01,2017) and  visitnum in (20 30 40 50 60)) )then do;
        aperiod=1;
        aperiodc="DB Period";
        trta=trt01a;
        trtp=trt01p;
        trtan=trt01an;
    end;
    else if (.<tr02sdt<=adt<=tr02edt) or (tr02edt=. and .<tr02sdt<=adt) or (adt>trtsdt and visitnum in (170,180)) then do;
        aperiod=2;
        aperiodc="OLE Period";
        trtp=trt02p;
        trta=trt02a;
        trtan=trt02an;
    end;
    else if (tr03edt ne . and .<tr03sdt<=adt<=tr03edt) or (tr03edt=. and .<tr03sdt<=adt) then do;
        aperiod=3;
        aperiodc="Taper Period";
        trta=trt03a;
        trtp=trt03p;
        trtan=trt03an;
    end;
    if adt>=tr02sdt then ady2=adt-tr02sdt+1;
                    else ady2=adt-tr02sdt;
proc sort;
    by usubjid avisitn adt paramn;
run;

%*--- Create ADaM dataset;
data advs;
    informat _all_;
    set adam_template all;
    keep &keepvar.;
    format aval base chg pchg;
run;

data adam.&domain;
  set advs;
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
    call execute("data adam.&domain.(label='Vital Signs Analysis Dataset');");
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
 
