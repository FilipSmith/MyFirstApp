dm 'log; clear; lst; clear;';
*******************************************************************************;
* PROGRAM     : Z:\GWPharma\GWEP1447\DB\Biostatistics\Production\Tables\Pgm\T-ECGCHG.sas
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
%InitUid(uid=T-ECGCHG); %* name of unique Ouptut Id to be updated potentially;


*-------------------------------------------------*;
* GET THE DATA                                    *;
*-------------------------------------------------*;
DATA x1 ;
	 SET adam.adeg;
	 where saffl="Y" and upcase(APERIODC)="OLE PERIOD" ;
     if avisitn>=210 or  ABLFL="Y" then delete;   
         trt01an=1;
     format trt01an trtdbn.;
proc sort;
    by usubjid;
RUN;

data pop;
    set adam.adsl;
	where saffl="Y" and OLEFL="Y";
    trt01an=1;
    format trt01an trtdbn.;
    keep usubjid trt01an OLEFL aage;
proc sort;
    by usubjid;
RUN;

data x1b;
    merge x1(in=A) pop;
    by usubjid;
    if a and OLEFL ="Y";
    format avisitn avisitn. chg 12.0 paramn ecg.;
run;


*-------------------------------------------------*;
* PRODUCE THE TABLE                               *;
*-------------------------------------------------*;
%TAB(d=x1b,
     dlabel=pop,
     t=trt01an,
	 reference_t=pop,
	 v_row=paramn avisitn ,
     l_var=chg,
     v_cat=,
	 v_cont=chg,
     pn=usubjid,
     symbpct=,
	 label_nmiss=n,
	 lab_overall=Overall,
	 stat_list=n meansd median q1q3 minmax,
	 fmt_pct=8.1,
     show_freq_0=no,
     stat_col=NAME STAT,
	 p_label=Parameters,
     s_label=Statistics);



*-------------------------------------------------*;
* SAVE A DATASET FOR QC PURPOSE                   *;
*-------------------------------------------------*;
DATA pt.%sysfunc(transtrn(&uniqueid,-,_)) xx;
	 SET  tab;
	 label v2="Parameter (Unit)" v3="Visit";
	 if v2="Overall" then delete;
	 if v3="Overall" then delete;
	 drop v1 v5;
RUN;

*-------------------------------------------------*;
* CREATE THE RTF DOCUMENT                         *;
*-------------------------------------------------*;
option nomprint;
%tabrtf(d=pt.%sysfunc(transtrn(&uniqueid,-,_)),
		outfile=&PGM.,
		cellwidth=35 20 18 18 ,
		section1=N,
        section2=N,
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
