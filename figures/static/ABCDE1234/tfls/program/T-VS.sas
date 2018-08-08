dm 'log; clear; lst; clear;';
*******************************************************************************;
* PROGRAM     : Z:\GWPharma\GWEP1447\DB\Biostatistics\Production\Tables\Pgm\T-VS.sas
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
%InitUid(uid=T-VS); %* name of unique Ouptut Id to be updated potentially;

*-------------------------------------------------*;
* GET THE DATA                                    *;
*-------------------------------------------------*;

DATA tp_x1 ;
	 SET adam.advs;
	 where saffl="Y"  and (upcase(APERIODC)="OLE PERIOD" or ablfl="Y");
	 if avisitn>210 then delete;
	 if ABLFL="Y" then avisitn=35;
     trt01an=1;
	 if paramcd="HEIGHT" then delete;
RUN;

data pop;
    set adam.adsl;
	where saffl="Y" and OLEFL="Y";
    trt01an=1;
    format  trt01an trtdbn.;
    keep usubjid trt01an OLEFL ;
run;


data x1b;
    merge tp_x1(in=a) pop(in=b);
    by usubjid;
    if a and b;
    format avisitn avisitn. aval 12.1 paramn vitals.;
run;


* modify format to get the worse between VS/BP and PE at anytime;
data tp_mc;
    set x1b;
    if ady>1;
    if mcyn=1 then tp_mcyn=3;
    else if mcyn=2 then tp_mcyn=2;
run;

proc sql;
    create table mc as
    select distinct usubjid, trt01an,"VS/BP/PE indicative of AE? " as paramn, "Anytime post baseline" as avisitn, max(tp_mcyn) as mcyn format=yesno.
    from tp_mc
    group by usubjid, trt01an ;
quit;

data mc;
    set mc;
    if mcyn=3 then mcyn=1;
run;

*-------------------------------------------------*;
* PRODUCE THE TABLE                               *;
*-------------------------------------------------*;
%TAB(d=x1b,
     dlabel=pop,
     t=trt01an,
	 reference_t=pop,
	 v_row=paramn avisitn ,
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
	 p_label=Parameters,
     s_label=Statistics);

%TAB(d=mc,
     dlabel=pop,
     t=trt01an,
	 reference_t=pop,
	 v_row=paramn avisitn ,
     l_var=mcyn,
     v_cat=mcyn,
	 v_cont=,
     pn=usubjid,
     symbpct=,
	 dout=tabmc,
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

DATA pt.&uniqueid_. xx;
     SET tabmc(in=A) tab;
	 label v2="Parameter (Unit)" v3="Visit";
	 if v2="Overall" then delete;
	 if v3="Overall" then delete;
	 if a and v4="n" then do;
        v5=scan(v5,1,"(");
        v6=scan(v6,1,"(");
     end;
	 drop v1 V5;
RUN;

*-------------------------------------------------*;
* CREATE THE RTF DOCUMENT                         *;
*-------------------------------------------------*;
option nomprint;
%tabrtf(d=pt.&uniqueid_.,
		outfile=&pgm.,
		cellwidth=45 25 18 18 ,
		nbleft=2,
		section1=Y,
        section2=Y,
        section3=Y,
		lefta=3,
        table_align=center,
        title_align=C,
		pagebreaks=28);


%*--- at output level: save lst file if generated;
%SaveLst;

%*--- at output level: track output status;
%track;

%*--- end of program -----------------------------------------------------------;
