dm 'log; clear; lst; clear;';
*******************************************************************************;
* PROGRAM     : Z:\GWPharma\GWEP1447\DB\Biostatistics\Production\Tables\Pgm\T-AE.sas
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
%InitUid(uid=T-AE); %* name of unique Ouptut Id to be updated potentially;

*-------------------------------------------------*;
* GET THE DATA                                    *;
*-------------------------------------------------*;

DATA x1;
	SET adam.adae(WHERE=(upcase(APERIODC)="OLE PERIOD" )) ;
    pt=input(COMPRESS(tranwrd(substr(usubjid,12),'-','')),12.0);
    trt01an=1;
    format trt01an trtdbn.;
proc sort;
    by pt;
RUN;

data pop;
    set adam.adsl(where=(saffl="Y" and OLEFL="Y"));
    pt=input(COMPRESS(tranwrd(substr(usubjid,12),'-','')),12.0);
    trt01an=1;
    format trt01an trtdbn.;
    keep usubjid pt trt01an saffl OLEFL;
proc sort;
    by pt;
RUN;
data x1b;
    merge x1(in=A) pop;
    by pt;
    if a and saffl="Y" and OLEFL="Y";
run;

*-------------------------------------------------*;
* PRODUCE THE TABLE                               *;
*-------------------------------------------------*;

%aecm( d=x1b,
       dt=pop,
       t=trt01an,
       by1=AEBODSYS,
       by2=AEDECOD,
	   ord_tab=1,
	   ord_trt=1,
       pt=pt,
	   trt_all=Overall,
       p_label=System Organ Class ^n%sysfunc(byte(160))       Preferred Term,
       lab_all1=Subject with at least one treatment-emergent AE);


*-------------------------------------------------*;
* SAVE A DATASET FOR QC PURPOSE                   *;
*-------------------------------------------------*;
DATA pt.%sysfunc(transtrn(&uniqueid,-,_)) xx;
length v1 $200. v3 $17.;
	 SET aecm;
     drop v2;
RUN;

*-------------------------------------------------*;
* CREATE THE RTF DOCUMENT                         *;
*-------------------------------------------------*;
option nomprint;
%tabrtf(d=pt.%sysfunc(transtrn(&uniqueid,-,_)),
		outfile=&PGM.,
		cellwidth=70 25 ,
		nbleft=0,
		section1=Y,
        section2=Y,
        section3=N,
		lefta=1,
        table_align=center,
        title_align=C,
		pagebreaks=22);







%*--- at output level: save lst file if generated;
%SaveLst;

%*--- at output level: track output status;
%track;

%*--- end of program -----------------------------------------------------------;
