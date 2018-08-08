           dm 'log; clear; lst; clear;';
*******************************************************************************
* PROGRAM     : Z:\GWPharma\GWEP1447\DB\Biostatistics\Production\Tables\Pgm\T-DISP1.sas
* SOFTW/PLAT. : SAS v9.2 - W32 platform
* DATE        : Fri 06/09/2017 (mm/dd/yyyy) 
* PROGRAMMER  : nadra.mammasse (user name)
* PURPOSE     : Programming  of output(s) according to project spreadsheet
*
* INPUT       : 
* OUTPUT      : see project spreadsheet
*
* MACROS      : (getdirf/setup/initUid/track
*


*******************************************************************************;



* Modifications History:



*------------------------------------------------------------------------------;



* Modif. #01  :

* Programmer  : christelle.pommie
* Date        : 31July2017
* Purpose     : Label of total column

*------------------------------------------------------------------------------;
* odif. #0n  :
* Programmer  :
* Date        :

* urpose     :

*******************************************************************************;
%*--- global settings;
%getdirf(flvl=4);
%inc "&protdir\biostatistics\macros\setup.sas";











%*--- Initialization - at the level of the unique Ouptut Id;



%InitUid(uid=T-DISP1); %* name of unique Ouptut Id to be updated potentially;







PROC FORMAT;



     VALUE pop  1='Safety analysis set' ;



RUN;







*-------------------------------------------------*;



* GET THE DATA                                    *;



*-------------------------------------------------*;







DATA x1 POP( keep=usubjid trt01an pt);



     SET adam.adsl(where=(olefl="Y"));



     pop=1;



     pt=COMPRESS(tranwrd(substr(usubjid,12),'-',''))*1;



    trt01an=1;



     KEEP trt01an usubjid pt siteid country;



    format trt01an trtDBN.;



RUN;







*-------------------------------------------------*;



* PRODUCE THE TABLE                               *;



*-------------------------------------------------*;







%aecm( d=x1,



       dt=pop,



       t=trt01an,



       by1=country,



       by2=siteid,



	   ord_tab=2,



       pt=pt,



	   trt_all=Overall,



       p_label=Country ^n%sysfunc(byte(160))       Site,



       lab_all1=All countries);







*-------------------------------------------------*;



* SAVE A DATASET FOR QC PURPOSE                   *;



*-------------------------------------------------*;



 







DATA pt.%sysfunc(transtrn(&uniqueid,-,_)) xx;



     length v1 $200. v2-v3 $17.;



	 SET aecm;



     keep v1 v3;



RUN;











*-------------------------------------------------*;



* CREATE THE RTF DOCUMENT                         *;



*-------------------------------------------------*;







%tabrtf(d=pt.%sysfunc(transtrn(&uniqueid,-,_)),



		outfile=&PGM.,



		cellwidth=70 30/* 25 25 21*/ ,



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









           