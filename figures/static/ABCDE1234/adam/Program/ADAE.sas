libname sdtm "/folders/myfolders/adam";
libname sdtm "/folders/myfolders/sdtm";
dm 'log; clear; lst; clear;';
*******************************************************************************;
* PROGRAM     : ABDC1234\ADAM\Program\ADAE.sas
* SOFTW/PLAT. : SAS v9.4 - W32 platform
* DATE        : Wed 05/26/2018 (mm/dd/yyyy) 
* PROGRAMMER  : Philippe Remusat
* PURPOSE     : Adverse Event (ADAM)
*
* INPUT       : AE.sas7bdata (SDTM)
* OUTPUT      : ADAE.sas7bdat (ADAM)
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
 

%let domain=ADAE;
%let keepvar=STUDYID USUBJID SUBJID SITEID AESEQ AETERM AEDECOD AEBODSYS AELLT AEHLT AEHLGT AESOC APERIODC APERIOD TRTA TRTAN TRTSDT TRTEDT AESTDTC ASTDT ASTDTF
             ASTDY AEENDTC AENDT AENDTF AENDY TRTEMFL AESER AESEV AESEVN AEREL AERELN AEOUT AEACN ANL01FL ANL02FL
;
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
	APERIODC  Char(200)                label="Period (C)",
	APERIOD   num                      label="Period",
	TRTA      Char(200)                label="Actual Treatment",
	TRTAN     num                      label="Actual Treatment (N)",
    TRTSDT    num format=yymmdd10.     label="Date of First Exposure to Treatment",
    TRTEDT    num format=yymmdd10.     label="Date of Last Exposure to Treatment",
	AESTDTC   Char(200)                label="Start Date/Time of Adverse Event",
	ASTDT     num format=yymmdd10.     label="Analysis Start Date",
	ASTDTF    Char(1)                  label="Analysis Start Date Imputation Flag",
	ASTDY     num                      label="Analysis Start Relative Day",
	AEENDTC   Char(200)                label="End Date/Time of Adverse Event",
	AENDT     num format=yymmdd10.     label="Analysis End Date",
	AENDTF    Char(1)                  label="Analysis End Date Imputation Flag",
	AENDY     num                      label="Analysis End Relative Day",
    TRTEMFL   Char(1)                  label="Treatment Emergent Analysis Flag",
	AESER     Char(200)                label="Serious Event",
	AESEV     Char(200)                label="Severity/Intensity",
	AESEVN    num                      label="Severity/Intensity (N)",
	AEREL     Char(200)                label="Causality",
	AERELN    num                      label="Causality (N)",
	AEOUT     Char(200)                label="Outcome of Adverse Event",
	AEACN     Char(200)                label="Action Taken with Study Treatment",
	ANL01FL	  Char(1)                  label="Analysis Record Flag 01",
	ANL02FL	  Char(1)                  label="Analysis Record Flag 02"
    );
quit;

************************************************************************************;
* ADSL
************************************************************************************;
proc sort data=adam.adsl out=adsl;by studyid usubjid;run;

************************************************************************************;
* Get the data
************************************************************************************;
data ae;
  length studyid siteid subjid aedecod aebodsys $200. usubjid $19.;
  set sdtm.ae;
  subjid=substr(usubjid,10);
  siteid=substr(subjid,3,4);

  dds=substr(aestdtc,9,2);
  mms=substr(aestdtc,6,2);
  yys=substr(aestdtc,1,4);

  dde=substr(aeendtc,9,2);
  mme=substr(aeendtc,6,2);
  yye=substr(aeendtc,1,4);

  if compress(aestdtc) ne "" and dds="" and mms ne "" then do;
		ASTDT=mdy(mms,1,yys);
		astdtf="D";
  end;
  else if compress(aestdtc) ne "" and dds="" and mms="" then do;
		ASTDT=mdy(1,1,yys);
		astdtf="M";
  end;
   else ASTDT=mdy(mms,dds,yys);


  if compress(aeendtc) ne "" and dde="" and mme ne ""  then do;
	   	if mme<12 then aendt=mdy(mme+1,1,yye)-1;
	               else aendt=mdy(1,1,yye+1)-1;
		aendtf="D";
  end;
  else if compress(aeendtc) ne "" and dde="" and mme=""  then do;
	   	AENDT=mdy(12,31,yye);
		aendtf="M";
  end;
    else AENDT=mdy(mme,dde,yye);

  *aesev=propcase(aesev);
  Select (propcase(aesev));
	When("Mild") aesevn=1;
    When("Moderate") aesevn=2;
    When("Severe") aesevn=3;
	Otherwise;
  end;
  aerel=propcase(aerel);
  Select (aerel);
    When("Related") aereln=1;
    When("Not Related") aereln=2;
    When("Prior to study medication") aereln=3;
	Otherwise;
  end;

  format astdt aendt yymmdd10.;
run;

* Duplicate records to be removed: ANL01FL;
proc sort data=ae;
    by usubjid aedecod astdt aeacn aendt aeout;
run;
data ae1;
  set ae;
  by usubjid aedecod astdt;
  if last.astdt then ANL01FL="Y";
proc sort;
	by usubjid;
run;

************************************************************************************;
* Pull the data together
************************************************************************************;
data all;
	merge adsl ae1(in=b);
	by usubjid;
	if b;
	length aperiodc $200.;

	if astdt<tr01sdt then do;
		aperiod=0;
		aperiodc="Pre-Study";
		trta=trt01a;
		trtsdt=tr01sdt;
		trtedt=tr01edt;
		trtan=trt01an;
	end;
	else if (tr01sdt ne . and tr01sdt<=astdt<=tr01edt  and tr02sdt eq . ) or (.<tr01sdt<=astdt<tr01edt  and tr02sdt ne  . ) then do;
		aperiod=1;
		aperiodc="DB Period";
		trtemfl="Y";
		trta=trt01a;
		trtan=trt01an;
		trtsdt=tr01sdt;
		trtedt=tr01edt;
	end;
	else if (tr02edt ne . and  tr02sdt ne . and tr02sdt<=astdt<=tr02edt) or (tr02edt=. and .<tr02sdt<=astdt<=mdy(05,01,2017)) 
            or  (tr02sdt =. and tr02edt =. and astdt<=max(visdt90,visdt110,visdt120,visdt130,visdt140,visdt150,visdt160,visdt170,visdt180)) then do;
		aperiod=2;
		aperiodc="OLE Period";
		trtemfl="Y";
		trta=trt02a;
		trtan=trt02an;
		trtsdt=tr02sdt;
		trtedt=tr02edt;

	end;
  
	else if (tr03edt ne . and .<tr03sdt<=astdt<=tr03edt) or (tr03edt=. and .<tr03sdt<=astdt) then do;
		aperiod=3;
		aperiodc="Taper Period";
		trtemfl="Y";
		trta=trt03a;
		trtan=trt03an;
	end;

	if aperiod=2 then do;
		trtsdt=tr02sdt;
		if tr02edt ne . then trtedt=tr02edt;
		  else trtedt=mdy(05,01,2017);*cut-off date;
	end;

	* ANL02FL;
	if (.<astdt<=tr01edt and (aendt>tr01edt or (aendt=. and aeout="RECOVERING/RESOLVING"))) or (aperiod=2) then ANL02FL="Y";

	if astdt>=trtsdt then astdy=astdt-trtsdt+1;
	                 else astdy=astdt-trtsdt;

	if aendt>=trtsdt then aendy=aendt-trtsdt+1;
	                 else aendy=aendt-trtsdt;
proc sort ;
	by usubjid aeseq ;
run;

%*--- Create ADaM dataset;
data adae;
 informat _all_;
 set adam_template all;
 keep &keepvar.;
run;

data adam.&domain;
  set adae;
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
    call execute("data adam.&domain.(label='Adverse Event Analysis Dataset');");
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
