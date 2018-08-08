libname adam "/folders/myfolders/adam";
libname sdtm "/folders/myfolders/sdtm";
dm 'log; clear; lst; clear;';
*******************************************************************************;
* PROGRAM     : ABDC1234\ADAM\Program\ADMH.sas
* SOFTW/PLAT. : SAS v9.4 - W32 platform
* DATE        : Wed 05/26/2018 (mm/dd/yyyy) 
* PROGRAMMER  : Philippe Remusat
* PURPOSE     : Laboratory (ADAM)
*
* INPUT       : SDTM.LB, ADAM.ADMH
* OUTPUT      : ADMH.sas7bdat (ADAM)
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

%let domain=ADMH;
%let keepvar=STUDYID USUBJID SUBJID SITEID MHTERM MHDECOD MHBODSYS MHLLT MHHLT MHHLGT AESOC TRTSDT TRTEDT
             MHCAT MHTERM MHBODSYS MHDECOD MHSTDTC ASTDT ASTDY MHENDTC AENDT AENDY MHENRF MHHLGT MHHLT MHLLT
             TRT01P TRT01PN TRT01A TRT01AN TRT02P TRT02PN TRT02A TRT02AN TRT03P TRT03PN TRT03A TRT03AN ASTDTF AENDTF;
option varlenchk=nowarn;

%*--- Create a Template;
proc sql noprint;
    create table ADAM_TEMPLATE
    (
    STUDYID   Char(15)                 label="Study Identifier",
    USUBJID   Char(40)                 label="Unique Subject Identifier",
    SUBJID    Char(10)                 label="Subject Identifier for the Study",
    SITEID    Char(8)                  label="Study Site Identifier",
    AESEQ     Num                      label="Sequence Number",
	AETERM    Char(200)                label="Reported Term for the Adverse Event",
	AEDECOD   Char(200)                label="Dictionary-Derived Term",
	AEBODSYS  Char(200)                label="Body System or Organ Class",
	AELLT     Char(200)                label="Lowest Level Term",
	AEHLT     Char(200)                label="High Level Term",
	AEHLGT    Char(200)                label="High Level Group Term",
	AESOC     Char(200)                label="Primary System Organ Class",
    TRTSDT    num format=yymmdd10.     label="Date of First Exposure to Treatment",
    TRTEDT    num format=yymmdd10.     label="Date of Last Exposure to Treatment",

	TRT01P    Char(200)                label="Planned Treatment for DB Phase",
	TRT01PN   num                      label="Planned Treatment for DB Phase (N)",
	TRT01A    Char(200)                label="Actual Treatment for DB Phase",
	TRT01AN   num                      label="Actual Treatment for DB Phase (N)",
	TRT02P    Char(200)                label="Planned Treatment for OLE Phase",
	TRT02PN   num                      label="Planned Treatment for OLE Phase (N)",
	TRT02A    Char(200)                label="Actual Treatment for OLE Phase",
	TRT02AN   num                      label="Actual Treatment for OLE Phase (N)",
	TRT03P    Char(200)                label="Planned Treatment for Taper Phase",
	TRT03PN   num                      label="Planned Treatment for Taper Phase (N)",
	TRT03A    Char(200)                label="Actual Treatment for Taper Phase",
	TRT03AN   num                      label="Actual Treatment for Taper Phase (N)",

    MHCAT     Char(100) 			   label="Category for Medical History",
    MHTERM    Char(200)                label="Reported Term for the Medical History",
    MHBODSYS  Char(200)                label="Body System or Organ Class",
    MHDECOD   Char(200)                label="Dictionary-Derived Term",
    MHHLGT    Char(200)                label="High Level Group Term",
    MHHLT     Char(200)                label="High Level Term",
    MHLLT     Char(200)                label="Lowest Level Term",
    MHSTDTC   Char(200)                label="Start Date/Time of Medical History",
    ASTDT     num format=yymmdd10.     label="Analysis Start Date",
    ASTDY     num                      label="Analysis Start Relative Day",
	ASTDTF    Char(1)                  label="Analysis Start Date Imputation Flag",
    MHENDTC   Char(10)                label="End Date/Time of Medical History",
    AENDT     num format=yymmdd10.     label="Analysis End Date",
    AENDY     num                      label="Analysis End Relative Day",
	AENDTF    Char(1)                  label="Analysis End Date Imputation Flag",
	MHENRF    Char(20)                 label="End Relative to Reference Period"
    );
quit;

************************************************************************************;
* ADSL
************************************************************************************;
proc sort data=adam.adsl out=adsl;
    by studyid usubjid;
run;

************************************************************************************;
* Get the data
************************************************************************************;
data mh00;
    length  mhstdtc MHENDTC $10.;
    set sdtm.mh(where=(compress(mhterm) ne ""));
run;

data mh01;
  set mh00;
  if length(mhstdtc) <4 then astdt =.;
  else if length(mhstdtc)=10 then ASTDT=input(mhstdtc,is8601da.);
  else if 4<=length(mhstdtc)<10  then do;
      dds=substr(mhstdtc,9,2);
      mms=substr(mhstdtc,6,2);
      yys=substr(mhstdtc,1,4);
     if dds=. and mms ne "" then do;
    		ASTDT=mdy(input(mms,2.),1,input(yys,4.));
    		astdtf="D";
      end;
      else if dds=. and mms="" then do;
    		ASTDT=mdy(1,1,input(yys,4.));
    		astdtf="M";
      end;
  end;
  if length(mhendtc) <4 then aendt =.;
  else if length(mhendtc)=10 then AENDT=input(mhendtc,is8601da.);
  else if 4<=length(mhendtc)<10  then do;
      dde=substr(mhendtc,9,2);
      mme=substr(mhendtc,6,2);
      yye=substr(mhendtc,1,4);
     if dds="" and mms ne "" then do;
    		AENDT=mdy(input(mme,2.),1,input(yye,4.));
    		aendtf="D";
      end;
      else if dds="" and mms="" then do;
    		AENDT=mdy(1,1,input(yye,4.));
    		aendtf="M";
      end;
  end;
  format astdt aendt is8601da.;
proc sort;
    by usubjid mhcat astdt aendt;
run;


/** History of Seizure **/
Data seiz;
length FASTRESC $200 usubjid $19.;

    set sdtm.fa;
    %* Modification: Thursday, July 13, 2017 Put in comment control on visitnum;
    where FACAT in ("HISTORY OF CURRENT SEIZURES" "HISTORY OF SEIZURES NO LONGER OCCURING") and FATEST =: "Seizure type" /*and visitnum=10*/;
    %* End of Modification: Thursday, July 13, 2017 ;
    rename FACAT=MHCAT
           FASTRESC=MHTERM;
           DOMAIN="FA";
    keep STUDYID DOMAIN USUBJID FACAT FASTRESC ;
run;

************************************************************************************;
* Pull the data together
************************************************************************************;
data mh02;
  length studyid MHTERM mhcat $200. usubjid $19.;
  set mh01 seiz;
proc sort;
    by studyid usubjid; 
run;

data all;
  merge adsl mh02(in=b);
  by usubjid;
  if b;
  if astdt>=trtsdt then astdy=astdt-trtsdt+1;
                   else astdy=astdt-trtsdt;

  if aendt>=trtsdt then aendy=aendt-trtsdt+1;
                   else aendy=aendt-trtsdt;
run;

%*--- Create ADaM dataset;
data admh;
    informat _all_;
    set adam_template all;
    keep &keepvar.;
run;

data adam.&domain;
    set admh;
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
    call execute("data adam.&domain.(label='Medical History Analysis Dataset');");
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