dm 'log; clear; lst; clear;';
*******************************************************************************;
* PROGRAM     : Z:\GWPharma\GWEP1447\DB\Biostatistics\Production\Tables\Pgm\T-CHEMVAL.sas
* SOFTW/PLAT. : SAS v9.2 - W32 platform
* DATE        : Tue 06/13/2017 (mm/dd/yyyy) 
* PROGRAMMER  : nadra.mammasse (user name)
* PURPOSE     : Programming  of output(s) according to project spreadsheet
*
* INPUT       : 
* OUTPUT      : see project spreadsheet
*
* MACROS      : (getdirf/setup/initUid/track)
*
*******************************************************************************;
* Modifications History:
*------------------------------------------------------------------------------;
* Modif. #01  :
* Programmer  : christelle.pommie
* Date        : 01Aug2017
* Purpose     : Label of overall column.
*------------------------------------------------------------------------------;
* Modif. #0n  :
* Programmer  :
* Date        :
* Purpose     :
*******************************************************************************;


%*--- global settings;
%getdirf(flvl=4);
%inc "&protdir\biostatistics\macros\setup.sas";


%*--- Initialization - at the level of the unique Ouptut Id;
%InitUid(uid=T-CHEMVAL); %* name of unique Ouptut Id to be updated potentially;

DATA tp_x1_;
    SET adam.adlb;
    where saffl="Y" and (upcase(APERIODC)="OLE PERIOD" or ablfl="Y") and upcase(parcat1)="CHEMISTRY" and aval ne .;
    if index(avisitn,'.')>0 then delete;
    if avalu ne "" then paramb=compbl(param)||"("||compress(avalu)||")";
    else paramb=compbl(param);
	if ABLFL="Y" then avisitn=35;
run;

proc sort data=tp_x1_ out=tp_x1;
    by USUBJID parcat1 paramn avisitn;
run;

data pop;
    set adam.adsl;
    where saffl="Y" and OLEFL="Y";
    trt01an=1;
    format trt01an trtdbn.;
    keep usubjid trt01an OLEFL;
proc sort;
    by USUBJID;
run;

proc sql;
    create table chempar as
    select distinct "chempar" as fmtname, paramn as start, paramb as label
    from tp_x1;
quit;

proc format cntlin=chempar;
run;

data x1b;
    merge tp_x1(in=A) pop(in=b);
    by usubjid;
    if a and b;
    format avisitn avisitn. paramn chempar. aval 12.1 ;
proc sort;
    by usubjid avisitn;
run;

*-------------------------------------------------*;
* PRODUCE THE TABLE                               *;
*-------------------------------------------------*;
%TAB(d=x1b,
     dlabel=pop,
     t=trt01an,
	 reference_t=pop,
	 v_row=paramb avisitn ,
     l_var=aval,
     v_cat=,
	 v_cont=aval,
     pn=usubjid,
     symbpct=,
	 label_nmiss=n,
	 lab_overall=Overall,
	 stat_list=n meansd median q1q3 minmax,
	 fmt_pct=8.1,
     show_freq_0=no,
     stat_col=NAME STAT,
	 p_label=Parameters (Units),
     s_label=Statistics);


*-------------------------------------------------*;
* SAVE A DATASET FOR QC PURPOSE                   *;
*-------------------------------------------------*;

DATA pt.&uniqueid_.;
	 SET tab;
	 label v2="Parameter (Unit)" v3="Visit";
	 if v2="Overall" then delete;
	 if v3="Overall" then delete;
	 drop v1 V5;
RUN;

*-------------------------------------------------*;
* CREATE THE RTF DOCUMENT                         *;
*-------------------------------------------------*;
option nomprint;
%tabrtf(d=pt.&uniqueid_.,
		outfile=&pgm.,
		cellwidth=45 25 20 20,
		section1=Y,
        section2=Y,
        section3=Y,
		nbleft=2,
		lefta=3,
        table_align=center,
        title_align=C,
		pagebreaks=30);


%*--- at output level: save lst file if generated;
%SaveLst;

%*--- at output level: track output status;
%track;

%*--- end of program -----------------------------------------------------------;
