dm 'log; clear; lst; clear;';
*******************************************************************************;
* PROGRAM     : Z:\GWPharma\GWEP1447\DB\Biostatistics\Production\Tables\Pgm\T-CHEMTOX.sas
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
%InitUid(uid=T-CHEMTOX); %* name of unique Ouptut Id to be updated potentially;
PROC FORMAT;
	value shift
	1="No tox to No tox"
	2="No tox to Tox increased"
	3="No tox to Tox decreased"
	4="Tox increased to No tox"
	5="Tox increased to Tox increased"
	6="Tox increased to Tox decreased"
	7="Tox decreased to No tox"
	8="Tox decreased to Tox increased"
	9="Tox decreased to Tox decreased";
RUN;

DATA x1 ;
	 SET adam.adlb;
	 where saffl="Y" and upcase(APERIODC)="OLE PERIOD" and upcase(parcat1)="CHEMISTRY" and (90<=avisitn<=180) and aval ne .;
     if index(avisitn,'.')>0 then delete;
proc sort;
    by usubjid param;
run;

data base;
    set adam.adlb;
    where saffl="Y" and upcase(APERIODC)="DB PERIOD" and upcase(parcat1)="CHEMISTRY";
    if ABLFL="Y";
    keep usubjid param toxfl;
    rename toxfl=btoxfl;
    label toxfl = "Baseline toxicity grade";
proc sort;
    by usubjid param;
run;

DATA x1b;
	merge x1 base;
	by usubjid param;
RUN;

DATA x1c;
	set x1b;
	where btoxfl ne "" and toxfl ne "";
	if avalu ne "" then paramb=compbl(param)||"("||compress(avalu)||")";
		else paramb=compbl(param);
    	shift1=compbl(btoxfl)||"to"||compbl(toxfl);
	if btoxfl='No Toxicity' then do;
		if toxfl='No Toxicity' then shift=1;
		else if toxfl='Toxicity increase' then shift=2;
		else shift=3;
	end;
	if btoxfl='Toxicity increase' then do;
		if toxfl='No Toxicity' then shift=4;
		else if toxfl='Toxicity increase' then shift=5;
		else shift=6;
	end;
	if btoxfl='Toxicity decrease' then do;
		if toxfl='No Toxicity' then shift=7;
		else if toxfl='Toxicity increase' then shift=8;
		else shift=9;
	end;
	format shift shift.;
proc sort;
    by subjid parcat1 paramn avisitn visit;
run;

proc sort nodupkey data=x1c out=x1d;
    by subjid parcat1 paramn avisitn;
run;

data pop;
    set adam.adsl;
	where saffl="Y" and OLEFL="Y";
    trt01an=1;
    format trt01an trtdbn.;
    keep usubjid trt01an ;
run;

data x1e;
    merge x1d(in=A) pop(in=b);
    by usubjid;
    if a and b;
    format avisitn avisitn. aval 12.1 ;
proc sort;
    by subjid paramn avisitn;
run;



*-------------------------------------------------*;
* PRODUCE THE TABLE                               *;
*-------------------------------------------------*;
%TAB(d=x1e,
     dlabel=pop,
     t=trt01an,
	 reference_t=pop,
	 v_row=paramb avisitn ,
     l_var=shift,
     v_cat=shift,
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


data avalc(drop=v5b v6b);
    set tabmc;
    retain v5b v6b ;
    if v4="n" then do;
        v5b=input(scan(v5,1,"("),12.0);
        v6b=input(scan(v6,1,"("),12.0);
    end;
    else do;
        if v5 NE "" then do;
                if 100*input(scan(v5,1,"("),12.0)/v5b = 100 then v5=put(input(scan(v5,1,"("),12.0),8.)||' (100.0)'; 
                else if 100*input(scan(v5,1,"("),12.0)/v5b >10 then v5=put(input(scan(v5,1,"("),12.0),8.)||' ( '||trim(left(put(100*input(scan(v5,1,"("),12.0)/v5b,8.1)))||')'; 
            else v5=put(input(scan(v5,1,"("),12.0),8.)||' (  '||trim(left(put(100*input(scan(v5,1,"("),12.0)/v5b,8.1)))||')';
          end;
        if v6 NE "" then do;
                if 100*input(scan(v6,1,"("),12.0)/v6b = 100 then v6=put(input(scan(v6,1,"("),12.0),8.)||' (100.0)'; 
                else if 100*input(scan(v6,1,"("),12.0)/v6b >10 then v6=put(input(scan(v6,1,"("),12.0),8.)||' ( '||trim(left(put(100*input(scan(v6,1,"("),12.0)/v6b,8.1)))||')'; 
            else v6=put(input(scan(v6,1,"("),12.0),8.)||' (  '||trim(left(put(100*input(scan(v6,1,"("),12.0)/v6b,8.1)))||')';
          end;
    end;
    if v4 ne "n" and v5 ne "" then do;
    	if 0<=input(scan(v5,1,"("),12.0)<10 then v5="   "||trim(left(v5));
    		else v5="  "||trim(left(v5));
    end;
    if v4 ne "n" and v6 ne "" then do;
    	if 0<=input(scan(v6,1,"("),12.0)<10 then v6="   "||trim(left(v6));
    		else v6="  "||trim(left(v6));
    end;
run;


*-------------------------------------------------*;
* SAVE A DATASET FOR QC PURPOSE                   *;
*-------------------------------------------------*;
DATA pt.&uniqueid_.;
    SET avalc(in=A);
    label v2="Parameter (Unit)" v3="Visit";
    if v2="Overall" then delete;
    if v3="Overall" then delete;
    if A and v4="n" then do;
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
		outfile=&PGM.,
		cellwidth=45 25 20 20,
		nbleft=2,
		section1=N,
        section2=N,
        section3=Y,
		lefta=3,
        table_align=center,
        title_align=C,
		pagebreaks=21);








%*--- at output level: save lst file if generated;
%SaveLst;

%*--- at output level: track output status;
%track;

%*--- end of program -----------------------------------------------------------;
