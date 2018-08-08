dm 'log; clear; lst; clear;';
*******************************************************************************;
* PROGRAM     : Z:\GWPharma\GWEP1447\DB\Biostatistics\Production\Tables\Pgm\T-AESEV.sas
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
%InitUid(uid=T-AESEV); %* name of unique Ouptut Id to be updated potentially;

*-------------------------------------------------*;
* GET THE DATA                                    *;
*-------------------------------------------------*;

DATA x1;
	SET adam.adae(WHERE=(anl01fl="Y" and anl02fl="Y" and upcase(APERIODC)="OLE PERIOD" )) ;
	pt=input(COMPRESS(tranwrd(substr(usubjid,12),'-','')),12.0);
RUN;
data pop;
	set adam.adsl(where=(saffl="Y" and OLEFL="Y"));
	pt=input(COMPRESS(tranwrd(substr(usubjid,12),'-','')),12.0);
    trt01an =1;
	format trt01an trtdbn.;
run;

data x1b;
	merge x1(in=A) pop;
	by pt;
	if a and saffl="Y" and OLEFL="Y";
run;

data x1b_;
	length AEBODSYS AEDECOD $400.;
	set x1b;
	*Dummy variable for max ;
	output;
	AEDECOD="All PTs";
	output;
	AEBODSYS="All systems";
	output;
run;
proc sort data=x1b_ out=srt_x1b;
	by pt AEBODSYS AEDECOD AESEVN;
run;

data worse;
	set srt_x1b;
	by pt AEBODSYS AEDECOD AESEVN;
	if last.aedecod;
	AEBODSYS=compbl(AEBODSYS!!"@@"!!AEDECOD);
	aesevb=compress(aesevn!!aesev);
	keep AEBODSYS AEDECOD AESEVN aesevb pt trt01an; 
run;

*-------------------------------------------------*;
* PRODUCE THE TABLE                               *;
*-------------------------------------------------*;

%aecm( d=worse,
       dt=pop,
       t=trt01an,
       by1=AEBODSYS,
       by2=aesevb,
	   ord_tab=1,
	   ord_trt=2,
       pt=pt,
	   trt_all=Overall,
       p_label=System Organ Class ^n%sysfunc(byte(160))       Preferred Term,
       lab_all1=Subject with at least one treatment-emergent AE);



data aecm2;
    set aecm;
    length v0 $200. v21-v23 v31-v33 $17.;
    retain v0 v21-v23 v31-v33  ord;
    if _N_=1 then do;
        v0=v1;
        ord=0;
    call symput ('lgw',vlabel(v2));
    call symput ('lall',vlabel(v3));
    end;
    else if "A"<=substr(v1,1,1)<="Z" then do;
        ord+1;
    	v0=v1;
        v21="";
        v22="";
        v23="";
        v31="";
        v32="";
        v33=""; 
    end;
    if v1="        1MILD" then do;          
       v21=v2;
       v31=v3;
    end;
    else if v1="        2MODERATE" then do;
        v22=v2;
        v32=v3;
    end;
    else if v1="        3SEVERE" then do;   
        v23=v2;
        v33=v3;
    end;

    bodysys=scan(v0,1,"@@");
    pt=scan(v0,2,"@@");

    ARRAY _v(6) v21-v23 v31-v33;
    do i=1 to 6; 
        _v(I)=left(_v(I));
    end;
run;
    
data aecm3;
    set aecm2;
    by ord;
    if last.ord;
run;

proc sql;
    create table aecm4 as
    select *,min(ord) as ord2
    from aecm3
    group by bodysys;
quit;

proc sort data=aecm4;
    by ord2 ord;
run;

*-------------------------------------------------*;
* SAVE A DATASET FOR QC PURPOSE                   *;
*-------------------------------------------------*;
DATA pt.&uniqueid_. xx;
	SET aecm4;
    if pt="All PTs" or pt="" then v1=bodysys;
	else v1="       "!!PT;
	if _N_=1 then delete;
	if v1="All systems" then v1="Subject with at least one treatment-emergent AE";
    attrib v21 label="&lgw ~Mild";
    attrib v22 label="&lgw ~Moderate";
    attrib v23 label="&lgw ~Severe";
    attrib v31 label="&lall ~Mild";
    attrib v32 label="&lall ~Moderate";
    attrib v33 label="&lall ~Severe";

    ARRAY _allcol(3) v21-v23;
    do i=1 to 3;
     if _allcol(I)="" or compress(_allcol(I))="0" then _allcol(I)="    ";
     else do;
          if 0<=input(scan(_allcol(I),1,"("),12.0)<10 then _allcol(I)="   "||trim(left(_allcol(I)));
                else _allcol(I)="  "||trim(left(_allcol(I)));
     end;
    end;
    keep V1 V31 V32 V33;
    /*drop i ord ord2 v2 v3 v0 bodysys pt i;*/
RUN;

*-------------------------------------------------*;
* CREATE THE RTF DOCUMENT                         *;
*-------------------------------------------------*;
option nomprint;
%tabrtf(d=pt.&uniqueid_.,
		outfile=&pgm.,
		cellwidth=50 20 20 20  ,
		section1=N,
        section2=Y,
        section3=N,
		nbleft=0,
		lefta=1,
        table_align=center,
        title_align=C,
		pagebreaks=20);




/* ... */







%*--- at output level: save lst file if generated;
%SaveLst;

%*--- at output level: track output status;
%track;

%*--- end of program -----------------------------------------------------------;
