dm 'log; clear; lst; clear;';
*******************************************************************************;
* PROGRAM     : Z:\GWPharma\GWEP1447\DB\Biostatistics\Production\Tables\Pgm\T-SAE.sas
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
%InitUid(uid=T-SAE); %* name of unique Ouptut Id to be updated potentially;

*-------------------------------------------------*;
* GET THE DATA                                    *;
*-------------------------------------------------*;
DATA x1;
	SET adam.adae(WHERE=(upcase(APERIODC)="OLE PERIOD" and aeser="Y")) ;
    pt=input(COMPRESS(tranwrd(substr(usubjid,12),'-','')),12.0);
RUN;
data pop;
    set adam.adsl(where=(saffl="Y" and OLEFL="Y"));
    pt=input(COMPRESS(tranwrd(substr(usubjid,12),'-','')),12.0);
    trt01an=1;
    format trt01an trtdbn.;
run;
data x1b;
    merge x1(in=A) pop;
    by pt;
    if a and OLEFL="Y";
run;


*-------------------------------------------------*;
* PRODUCE THE TABLE                               *;
*-------------------------------------------------*;
%macro check;

	%let dsid =%sysfunc(open(X1,I));
	%let nlobs = %sysfunc(attrn(&dsid,NLOBS));
	%let rc = %sysfunc(close(&dsid));
	%PUT &nlobs;

	%IF &nlobs > 0 %THEN %DO;

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
               lab_all1=Subject with at least one treatment-emergent SAE);

        DATA pt.%sysfunc(transtrn(&uniqueid,-,_)) xx;
        	 SET aecm;
        RUN;
	%END;


	%ELSE %IF &nlobs = 0 %THEN %DO;
		DATA pt.%sysfunc(transtrn(&uniqueid,-,_));
			 LENGTH V1  $50.;v1="";
			 DELETE;
		RUN;
	%END;
*-------------------------------------------------*;
* CREATE THE RTF DOCUMENT                         *;
*-------------------------------------------------*;

	%tabrtf(d=pt.%sysfunc(transtrn(&uniqueid,-,_)),
			outfile=&PGM.,
			cellwidth= 100 %IF &nlobs > 0 %THEN  18; ,
			nbleft=0,
			lefta=1,
		section1=N,
        section2=Y,
        section3=N,
	        table_align=center,
	        title_align=C,
			eventdata=Y,
			%IF &nlobs = 0 %THEN %do;
				nodata=Y,
				labnodata=No SAEs,
			%end;
			pagebreaks=22);
%mend;

%check;

%*--- at output level: save lst file if generated;
%SaveLst;

%*--- at output level: track output status;
%track;

%*--- end of program -----------------------------------------------------------;
