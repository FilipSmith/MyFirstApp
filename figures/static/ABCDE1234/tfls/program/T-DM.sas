dm 'log; clear; lst; clear;';
*******************************************************************************;
* PROGRAM     : Z:\GWPharma\GWEP1447\DB\Biostatistics\Production\Tables\Pgm\T-DM.sas
* SOFTW/PLAT. : SAS v9.2 - W32 platform
* DATE        : Mon 06/12/2017 (mm/dd/yyyy) 
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
* Date        : 31July2017
* Purpose     : Label of total column
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
%InitUid(uid=T-DM); %* name of unique Ouptut Id to be updated potentially;

*-------------------------------------------------*;
* GET THE DATA                                    *;
*-------------------------------------------------*;

DATA x1 POP( keep=usubjid trt01pn);
	 SET adam.adsl;
	 where olefl="Y";
     trt01pn=1;
	 
	 label sexn="Sex" racen="Race" AAGE="Age (years)" weight="Weight (kg)" bmi="Body Mass Index (kg/m2)";
	 format AAGE height weight bmi 6.1 sexn sexf. trt01pn trtdbn. racen racef. ;
RUN;
	

*-------------------------------------------------*;
* PRODUCE THE TABLE                               *;
*-------------------------------------------------*;
%TAB(d=x1,
     dlabel=x1,
     t=trt01pn,
	 reference_t=pop,
	 v_row=,
     l_var=AAGE sexn racen height weight bmi,
     v_cat=sexn racen,
	 v_cont=AAGE height weight bmi,
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
	 SET tab;
	 if v2="n" then do;
      v3=scan(v3,1,"(");
      v4=scan(v4,1,"(");
     end;
	 drop v3;
RUN;

*-------------------------------------------------*;
* CREATE THE RTF DOCUMENT                         *;
*-------------------------------------------------*;

%tabrtf(d=pt.%sysfunc(transtrn(&uniqueid,-,_)),
		outfile=&PGM.,
		cellwidth=35 30 20,
		nbleft=1,
		lefta=2,
		section1=Y,
        section2=N,
        section3=N,
        table_align=center,
        title_align=C,
		pagebreaks=35);

%*--- at output level: save lst file if generated;
%SaveLst;

%*--- at output level: track output status;
%track;

%*--- end of program -----------------------------------------------------------;
