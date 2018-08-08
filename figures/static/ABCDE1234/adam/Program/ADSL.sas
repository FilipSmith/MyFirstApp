libname adam "/folders/myfolders/adam";
libname sdtm "/folders/myfolders/sdtm";
dm 'log; clear; lst; clear;';
*******************************************************************************;
* PROGRAM     : ABDC1234\ADAM\Program\ADAE.sas
* SOFTW/PLAT. : SAS v9.4 - W32 platform
* DATE        : Wed 05/26/2018 (mm/dd/yyyy) 
* PROGRAMMER  : Philippe Remusat
* PURPOSE     : Adverse Event (ADAM)
*
* INPUT       : DM, DS , (SDTM)
* OUTPUT      : ADSL.sas7bdat (ADAM)
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


%let domain=ADSL;
%let keepvar=STUDYID USUBJID SUBJID SITEID BRTHDT DTHDT AGE AAGE AGEU SEX SEXN RACE RACEN ICDT ICGDT 
             RACEOTH COUNTRY COUNTRYN ARM TRTSDT TRTEDT SAFFL SCRNFFL RANDFL PKFL PKREAS SCRNREAS TAPERFL OLEFL SCRNFL CLOFL LEVFL STIFL TOPFL VALFL
             TRT01P TRT01PN TRT01A TRT01AN TR01SDT TR01EDT EOT01STT DCT01RS DCT01RSP
             TRT02P TRT02PN TRT02A TRT02AN TR02SDT TR02EDT EOT02STT DCT02RS DCT02RSP
             TRT03P TRT03PN TRT03A TRT03AN TR03SDT TR03EDT EOT03STT DCT03RS DCT03RSP
             HEIGHT WEIGHT BMI CNUSEYN CNSTATU CNLUTM CNLUTMCA ABNEEGFL ABNNEUFL GETESTFL VISDT:;
option varlenchk=nowarn;

%*--- Create a Template;
proc sql noprint;
    create table ADAM_TEMPLATE
    (
    STUDYID   Char(15)                 label="Study Identifier",
    USUBJID   Char(40)                 label="Unique Subject Identifier",
    SUBJID    Char(10)                 label="Subject Identifier for the Study",
    SITEID    Char(8)                  label="Study Site Identifier",
    BRTHDT    num format=yymmdd10.     label="Date of Birth",
    DTHDT     num format=yymmdd10.     label="Date of Death",
    ICDT      num format=yymmdd10.     label="Date of Informed Consent",
    ICGDT     num format=yymmdd10.     label="Date of Genetic Testing Informed Consent",
    AGE       num                      label="Age",
    AAGE      num                      label="Analysis Age",
    AGEU      Char(5)                  label="Age Units",
    SEX       Char(6)                  label="Sex",
    SEXN      num                      label="Sex (N)",
    RACE      Char(50)                 label="Race",
    RACEN     num                      label="Race (N)",
    RACEOTH   Char(50)                 label="Race (Other)",
    COUNTRY   Char(25)                 label="Country",
    COUNTRYN  num                      label="Country (N)",
    ARM       Char(7)                  label="Description of Planned Arm",
	SCRNFL    Char(1)                  label="Screening Flag",
	SCRNFFL	  Char(1)			       label="Screen Failure Flag",
	SCRNREAS  Char(200)                label="Screen Failure Reason",
	SAFFL     Char(1)                  label="Safety Population Flag",
	RANDFL    Char(1)			       label="Randomized Population Flag",
	PKFL	  Char(1)			       label="Pharmacokinetic Population Flag",
	PKREAS    Char(200)                label="PK Exclusion Reason",
    TAPERFL	  Char(1)			       label="Taper Population Flag",
	OLEFL	  Char(1)			       label="Open Label Extension Population Flag",

	CLOFL	  Char(1)			       label="Clobazam Population Flag",
	LEVFL	  Char(1)			       label="Levetiracetam Population Flag",
	STIFL	  Char(1)			       label="Stiripentol Population Flag",
	TOPFL	  Char(1)			       label="Topiramate Population Flag",
	VALFL	  Char(1)			       label="Valproate Population Flag",

	TRTSDT    num format=yymmdd10.     label="Date of First Exposure to Treatment",
	TRTEDT    num format=yymmdd10.     label="Date of Last Exposure to Treatment",
	TRT01P    Char(200)                label="Planned Treatment for DB Phase",
	TRT01PN   num                      label="Planned Treatment for DB Phase (N)",
	TRT01A    Char(200)                label="Actual Treatment for DB Phase",
	TRT01AN   num                      label="Actual Treatment for DB Phase (N)",
	TR01SDT   num format=yymmdd10.     label="Date of First Exposure in DB Phase",
	TR01EDT   num format=yymmdd10.     label="Date of Last Exposure in DB Phase",
    EOT01STT  Char(200)                label="End of Treatment Status in DB Phase",
    DCT01RS   Char(200)                label="Reason for Discont of Treat in DB Phase",
    DCT01RSP  Char(200)                label="Reason Spec for Disc of Trt in DB Phase",
	TRT02P    Char(200)                label="Planned Treatment for OLE Phase",
	TRT02PN   num                      label="Planned Treatment for OLE Phase (N)",
	TRT02A    Char(200)                label="Actual Treatment for OLE Phase",
	TRT02AN   num                      label="Actual Treatment for OLE Phase (N)",
	TR02SDT   num format=yymmdd10.     label="Date of First Exposure in OLE Phase",
	TR02EDT   num format=yymmdd10.     label="Date of Last Exposure in OLE Phase",
	EOT02STT  Char(200)                label="End of Treatment Status in OLE Phase",
    DCT02RS   Char(200)                label="Reason for Discont of Treat in OLE Phase",
    DCT02RSP  Char(200)                label="Reason Spec for Disc of Trt in OLE Phase",
	TRT03P    Char(200)                label="Planned Treatment for Taper Phase",
	TRT03PN   num                      label="Planned Treatment for Taper Phase (N)",
	TRT03A    Char(200)                label="Actual Treatment for Taper Phase",
	TRT03AN   num                      label="Actual Treatment for Taper Phase (N)",
	TR03SDT   num format=yymmdd10.     label="Date of First Exposure in Taper Phase",
	TR03EDT   num format=yymmdd10.     label="Date of Last Exposure in Taper Phase",
	EOT03STT  Char(200)                label="End of Treatment Status in Taper Phase",
    DCT03RS   Char(200)                label="Reason for Discont of Treat in Taper Phase",
	DCT03RSP  Char(200)                label="Reason Spec for Disc of Trt in Taper Phase",
	HEIGHT	  num                      label="Height (cm)",
    WEIGHT	  num                      label="Weight (kg) at Visit 1",
    BMI	      num                      label="Body Mass Index (kg/m2) at Visit 1",
	CNUSEYN   num                      label="Has the patient previously used Cannabis?",
    CNSTATU   Char(200)                label="Frequency of use of Cannabis",
    CNLUTM    num                      label="Time since Last of use of Cann. (Months)",
	CNLUTMCA  Char(200)                label="Time since Last of use of Cann. (Categ.)",
    ABNEEGFL  Char(1)                  label="Abnormal EEG",
    ABNNEUFL  Char(1)                  label="Abnormal Neuroimaging Test",
    GETESTFL  Char(1)                  label="Genetic Testing Performed in the Past",
    VISDT10   num format=yymmdd10.     label="V1 (Day -14 to -7)",
    VISDT20   num format=yymmdd10.     label="V2 (Day 1)",
    VISDT30   num format=yymmdd10.     label="V2 (Day 2)",
    VISDT40   num format=yymmdd10.     label="V3 (Day 12)",
    VISDT50   num format=yymmdd10.     label="V4 (Day 26)",
    VISDT60   num format=yymmdd10.     label="V4 (Day 27)",
    VISDT80   num format=yymmdd10.     label="V5 DB (End of Taper after DB period)",
    VISDT100   num format=yymmdd10.     label="V6 DB (SFU after DB period)",
    VISDT90   num format=yymmdd10.     label="V5 (OLE Week 2)",
    VISDT110   num format=yymmdd10.     label="V6 (OLE Month 1)",
    VISDT120   num format=yymmdd10.     label="V7 (OLE Month 2)",
    VISDT130  num format=yymmdd10.     label="V8 (OLE Month 3)",
    VISDT140  num format=yymmdd10.     label="V9 (OLE Month 6)",
    VISDT150  num format=yymmdd10.     label="V10 (OLE Month 9)",
    VISDT160  num format=yymmdd10.     label="V11 (OLE Month 12)",
    VISDT170  num format=yymmdd10.     label="V12 (End of Taper after OLE period)",
    VISDT180  num format=yymmdd10.     label="V13 (SFU after OLE period)"
    );
quit;

************************************************************************************;
* Treatment Periods
* Period 1 : DB
* Period 2 : OLE
* Period 3 : Taper + SFU 4 weeks 
************************************************************************************;
data db;
    set sdtm.ex(where=(exseq=1));
    TR01SDT=input(exstdtc,yymmdd10.);
    TR01EDT=input(exendtc,yymmdd10.);
    keep studyid usubjid TR01SDT TR01EDT;
    format TR01SDT TR01EDT yymmdd10.;
run;


data ole;
    set sdtm.ex(where=(exseq=2));
    TR02SDT=input(exstdtc,yymmdd10.);
    TR02EDT=input(exendtc,yymmdd10.);
    keep studyid usubjid TR02SDT TR02EDT;
    format TR02SDT TR02EDT yymmdd10.;
run;

data taper;
    set sdtm.ex(where=(exseq=3));
    TR03SDT=input(exstdtc,yymmdd10.);
    TR03EDT=input(exendtc,yymmdd10.);
    keep studyid usubjid TR03SDT TR03EDT;
    format TR03SDT TR03EDT yymmdd10.;
run;


data ex;
    merge db ole taper;
    by studyid usubjid;
run;

************************************************************************************;
* Demographics
************************************************************************************;
data demo(keep=studyid usubjid sex sexn race racen brthdt icgdt icdt age arm aage ageu);
    merge sdtm.dm sdtm.suppdm(where=(qnam="GNICDT") rename=(qval=icgdt_) keep=studyid usubjid qnam qval) 
    	sdtm.suppdm(where=(qnam="RACEOTH") rename=(qval=raceoth) keep=studyid usubjid qnam qval);
    by studyid usubjid;

    brthdt=input(brthdtc,yymmdd10.);
    icdt=input(rficdtc,yymmdd10.);
    icgdt=input(icgdt_,yymmdd10.);

    ageu="YEARS";
    aage=round((icdt-brthdt+1)/365.25,0.1);

    if sex="M" then sexn=1;
      else if sex="F" then sexn=2;

    *race=propcase(race);
    Select (propcase(race));
        When("White")  do;racen=1;end;
        When("Black or African American")  do;racen=2;end;
        When("American Indian or Alaska Native")  do;racen=3;end;
        When("Asian")  do;racen=4;end;
        When("Native Hawaiian or Other Pacific Islander") do;racen=5;end;
        When("Other") do;racen=6;end;
    Otherwise;
    End;
run;

************************************************************************************;
* Vital Signs at Week 1: Heigth, Weight and BMI
************************************************************************************;
proc sort data=sdtm.vs(where=(vstestcd="HEIGHT" and visitnum=10)) 
    out=height(keep=studyid usubjid vsstresn rename=(vsstresn=HEIGHT));
    by studyid usubjid;
run;

/** Note that if weight is missing at visit 1, the first available weight taken after is to be used. **/
proc sort data=sdtm.vs(where=(vstestcd="WEIGHT" and visitnum=10))
    out=weight(keep=studyid usubjid vsstresn rename=(vsstresn=WEIGHT));
    by studyid usubjid;
run;

************************************************************************************;
* Treatment Discontinuation per Period
************************************************************************************;
/** DB **/
data disc_db(keep=studyid usubjid eot01stt dct01rs dct01rsp dslsdt1);
  merge sdtm.ds(where=(epoch="BLINDED TREATMENT" ) in=a) 
	sdtm.suppds(where=(qnam="OCPROTX" and IDVARval="3") keep=studyid usubjid qnam qval IDVARval rename=(qval=ocprotx))
	sdtm.suppds(where=(qnam="OCAEITX" and IDVARval="3") keep=studyid usubjid qnam qval IDVARval rename=(qval=ocaeitx)) sdtm.suppds(where=(qnam="OCCOSTX" and IDVARval="3") keep=studyid usubjid qnam IDVARval qval rename=(qval=occostx))
	sdtm.suppds(where=(qnam="OCINVTX" and IDVARval="3") keep=studyid usubjid qnam qval IDVARval rename=(qval=ocinvtx)) sdtm.suppds(where=(qnam="DSSPEC" and IDVARval="3") keep=studyid usubjid qnam IDVARval qval rename=(qval=dsspec));
  by studyid usubjid;
  if a;
  length eot01stt dct01rs dct01rsp $200.;
  dslsdt1=dsstdtc;
  Select (DSDECOD);
    When("COMPLETED") eot01stt="COMPLETED";
    When ("WITHDRAWAL BY SUBJECT") eot01stt="DISCONTINUED";
    When ("ADVERSE EVENT") eot01stt="DISCONTINUED";
	Otherwise;
  end;
  if dsdecod="WITHDRAWAL BY SUBJECT" then dct01rs=dsterm;
  Select (dct01rs);
    /*When("Adverse Event") dct01rsp=ocaeitx;*/
    When("Patient and/or legal representative withdrew consent to participate") dct01rsp=occostx;
    When("Patient met (protocol specified) withdrawal criteria") dct01rsp=ocprotx;
    When("Patient was withdrawn from participation by the Investigator") dct01rsp=ocinvtx;
    When("Other") dct01rsp=dsspec;
	Otherwise;
  end;
  if dsdecod="ADVERSE EVENT" then do dct01rs=dsterm; dct01rsp=ocaeitx; end;


run;


/** OLE **/
data disc_ole(keep=studyid usubjid eot02stt dct02rs dct02rsp dslsdt2);
  merge sdtm.ds(where=(epoch="OPEN LABEL TREATMENT" ) in=a) sdtm.suppds(where=(qnam="OCPROTX" and IDVARval="4") keep=studyid usubjid qnam qval IDVARval rename=(qval=ocprotx))
	sdtm.suppds(where=(qnam="OCAEITX" and IDVARval="4") keep=studyid usubjid qnam qval IDVARval rename=(qval=ocaeitx)) sdtm.suppds(where=(qnam="OCCOSTX" and IDVARval="4") keep=studyid usubjid qnam qval IDVARval rename=(qval=occostx))
	sdtm.suppds(where=(qnam="OCINVTX" and IDVARval="4") keep=studyid usubjid qnam qval IDVARval rename=(qval=ocinvtx)) sdtm.suppds(where=(qnam="DSSPEC" and IDVARval="4") keep=studyid usubjid qnam qval IDVARval rename=(qval=dsspec));
  by studyid usubjid;
  if a;
  length eot02stt dct02rs dct02rsp $200.;
  dslsdt2=dsstdtc;
  Select (DSDECOD);
    When("COMPLETED") eot02stt="COMPLETED";
    When("WITHDRAWAL BY SUBJECT","ADVERSE EVENT","LOST TO FOLLOW-UP") eot02stt="DISCONTINUED";
	Otherwise;
  end;
  if dsdecod in ("WITHDRAWAL BY SUBJECT","ADVERSE EVENT","LOST TO FOLLOW-UP") then dct02rs=dsterm;
  Select (dct02rs);
    When("Adverse Event") dct02rsp=ocaeitx;
    When("Patient and/or legal representative withdrew consent to participate") dct02rsp=occostx;
    When("Patient met (protocol specified) withdrawal criteria") dct02rsp=ocprotx;
   * When("Patient was withdrawn from participation by the Investigator") dct02rsp=ocinvtx;
    When("Other") dct02rsp=dsspec;
	Otherwise;
	end;
run;


/** TAPER **/
data disc_tp(keep=studyid usubjid eot03stt dct03rs dct03rsp dslsdt3);
  merge sdtm.ds(where=(epoch="OPEN LABEL TAPER") in=a) sdtm.suppds(where=(qnam="OCPROTX") keep=studyid usubjid qnam qval rename=(qval=ocprotx))
	sdtm.suppds(where=(qnam="OCAEITX") keep=studyid usubjid qnam qval rename=(qval=ocaeitx)) sdtm.suppds(where=(qnam="OCCOSTX") keep=studyid usubjid qnam qval rename=(qval=occostx))
	sdtm.suppds(where=(qnam="OCINVTX") keep=studyid usubjid qnam qval rename=(qval=ocinvtx)) sdtm.suppds(where=(qnam="DSSPEC") keep=studyid usubjid qnam qval rename=(qval=dsspec));
  by studyid usubjid;
  if a;
  length eot03stt dct03rs dct03rsp $200.;
  dslsdt3=dsstdtc;
  Select (DSDECOD);
    When("COMPLETED") eot03stt="COMPLETED";
    When("WITHDRAWAL BY SUBJECT") eot03stt="DISCONTINUED";
	Otherwise;
  end;
  if dsdecod="WITHDRAWAL BY SUBJECT" then dct03rs=dsterm;
  Select (dct03rs);
    When("Adverse Event") dct03rsp=ocaeitx;
    When("Patient and/or legal representative withdrew consent to participate") dct03rsp=occostx;
    When("Patient met (protocol specified) withdrawal criteria") dct03rsp=ocprotx;
    When("Patient was withdrawn from participation by the Investigator") dct03rsp=ocinvtx;
    When("Other") dct03rsp=dsspec;
	Otherwise;
  end;
run;

/** All periods **/
data disc_all;
    merge disc_db disc_ole disc_tp;
    by studyid usubjid;
run;

************************************************************************************;
* Screen Failure
************************************************************************************;
data sf(keep=studyid usubjid scrnreas subjid);
    length subjid $10.;
    set sdtm.ds;
    where dsdecod="SCREEN FAILURE";
    length scrnreas $200.;
    scrnreas=dsterm;
    subjid=substr(usubjid,10);
run;

************************************************************************************;
* Cannabis Use
************************************************************************************;
data cannabis(keep=studyid usubjid cnuseyn cnstatu cnlstdtn);
	set sdtm.su;
	cnuseyn=1;
	Select (sudosfrq);
	  When("PA") cnstatu="Once per year"; 
	otherwise;
	End;

	if substr(SUSTDTC,8)="" then cnlstdtn=mdy(substr(sustdtc,6,2)+1,1,substr(sustdtc,1,4))-1;
		else cnlstdtn=mdy(substr(sustdtc,6,2),substr(sustdtc,9,2),substr(sustdtc,1,4));

	format cnlstdtn yymmdd10.;
run;

************************************************************************************;
* Medical History
************************************************************************************;
/** Abnormal EEG **/
proc sort nodupkey data=sdtm.fa(where=(scan(facat,-2,"")="(EEG)")) 
    out=mhee(keep=studyid usubjid) ;
    by studyid usubjid;
run; 

/** Abnormal Neuroimaging Test **/
proc sort nodupkey data=sdtm.fa(where=(scan(facat,-2,"")="NEUROIMAGING" and fatestcd in ("IMGRES1L","IMGRES2L") and faorres="Abnormal")) 
	out=mhnr(keep=studyid usubjid) ;
    by studyid usubjid;
run;

/** Genetic Testing Performed in the Past **/    
proc sort nodupkey data=sdtm.fa(where=(scan(facat,-3,"")="GENETIC")) 
    out=mhgn(keep=studyid usubjid) ;
    by studyid usubjid;
run; 

************************************************************************************;
* Visits
************************************************************************************;
proc sort data=sdtm.sv(where=(visitnum<=210)) 
    out=sv;
    by studyid usubjid visitnum;
run;

data sv1;
	set sv;
	yy=input(substr(svstdtc,1,4),4.);
	mm=input(substr(svstdtc,6,2),2.);
	dd=input(substr(svstdtc,9),2.);
	visitd=mdy(mm,dd,yy);
	format visitd date9.;
	if visitd<=mdy(05,01,2017); ** Datacut off date applied ;
run;

proc sql;
	create table vis2 as
	select distinct *
	from sv1
    where SVUPDES eq ""
	order by studyid,usubjid,visitnum;
run;

proc transpose data=vis2 out=vis3(drop=_name_) prefix=visdt;
	by studyid usubjid;
	var visitd;
	id visitnum;
	idl visit;
run;


************************************************************************************;
* Treatments on each period
************************************************************************************;
proc sort data=sdtm.ex out=rando(keep=studyid usubjid exseq epoch extrt);
    by usubjid exseq;
run;

data rando1;
	length extrt $40.;
	set rando;
   /* if Epoch="OPEN LABEL TREATMENT" and extrt="BLD" then extrt="GWP42003-P";
	if extrt="GWP42003" then extrt="GWP42003-P";*/
run;

proc sort data=rando1 out=rando2;
    by studyid usubjid;
run;

proc transpose data=rando2 out=rando3(keep=studyid usubjid trtp:) prefix=trtp;
	by studyid usubjid;
	id exseq;
	var extrt;
run;

************************************************************************************;
* PK pop not derived for this analysis
************************************************************************************;

************************************************************************************;
* AED data 
************************************************************************************;

data aed;
    set sdtm.fa(where=(facat="CONCOMITANT AED DOSING"));
    if substr(FADTC,12) < '12:00' then do; aday=visitnum; time=substr(FADTC,12);end;
    if substr(FADTC,12) >= '12:00' then do; aday=visitnum+0.1;time=substr(FADTC,12);end;
proc sort ;
    by studyid usubjid FAORRES fadtc ;
run;

proc transpose data=aed out=aed1;
    where aday not in (30.1,60.1);
    by studyid usubjid FAORRES ;
    var  time ;
    id aday;
run;

data class_aed(DROP=_NAME_);
    set aed1;
    na6=0;time6=0;naf3=0;timef3=0;nal3=0;timel3=0;
    array _vis(6)  _20 _20d1 _30 _50 _50d1 _60 ;
    do i=1 to 6;
    	if _vis(I)=" " then do;
    		na6+1;
    		if I<=3 then naf3+1;
    		if I>3 then nal3+1;
    	end;
    	else do;
    		time6+1;
    		if I<=3 then timef3+1;
    		if I>3 then timel3+1;
    	end;
    end;
    if na6=6 then pop=2;
    if time6>=4 then pop=1;
    if _50="" and _50d1="" and _60="" then do;
    	if naf3=3 then pop=2;
    	if timef3=3 then pop=1;
    end;
    if FAORRES="CLOBAZAM" then aed="AEDCLO";
    else if FAORRES="LEVETIRACETAM" then aed="AEDLEV";
    else if FAORRES="STIRIPENTOL" then aed="AEDSTI";
    else if FAORRES="TOPIRAMATE" then aed="AEDTOP";
    else if FAORRES="VALPROATE" then aed="AEDVAL";
run;

proc transpose data=class_aed out=popaed(KEEP=studyid usubjid aed:);
    by studyid usubjid;
    idl FAORRES;
    id aed;
    var pop;
run;

data popaed2(drop =studyid aed:);
    set popaed;
    by studyid usubjid;
    /*clofl="N";*/levfl="N";topfl="N";

    if aedclo=1 then CLOFL="Y";else clofl="N";
    /*if aedlev=1 then LEVFL="Y";else levfl="N";*/
    if aedsti=1 then STIFL="Y";else stifl="N";
    /*if aedtop=1 then TOPFL="Y";else topfl="N";*/
    if aedval=1 then VALFL="Y";else valfl="N";
run;

************************************************************************************;
* Pull the data together
************************************************************************************;
data all;
    length studyid siteid subjid usubjid cnlutmca $200.;
    merge ex demo(in=demo) weight height disc_all sf(in=sf) cannabis mhee(in=mhee) mhnr(in=mhnr) mhgn(in=mhgn) vis3(in=vis3)
    rando3(in=rd3) /*all_dev(in=dev)*/ popaed2;
    by usubjid;
    CNUSEYN=2;
    if (visdt50 ne . or visdt60 ne .) and .< visdt90 <=mdy(05,01,2017) /*and TR02SDT ne .*/ then olefl="Y";
    	else olefl="N";
    if visdt80 ne . or visdt170 ne . then taperfl="Y";
    	else taperfl="N";


    if mhee then abneegfl="Y";
    if mhnr then abnneufl="Y";
    if mhgn then getestfl="Y";

    if demo then scrnfl="Y";
            else scrnfl="N";

    cnlutm=(icdt-cnlstdtn+1)/30.5;
         if .<cnlutm<=3 then cnlutmca="<=3 months"; 
    else if   cnlutm>3  then cnlutmca=">3 months"; 

    subjid=substr(usubjid,10);
    siteid=substr(subjid,3,4);

    if height ne . and weight ne . then bmi=(weight)/((height/100)*(height/100));
    *SAP info: Romanian site numbers are 1261 and 1289, Spanish site numbers are 1114, 1160 and 1238 and the Swedish site number is 1242. ;
    length country $200.;
        if siteid in  ("1261","1289")            then do;country="Romania";countryn=1;end;
        else if siteid in ("1114","1160","1238") then do;country="Spain";countryn=2;end;
        else if siteid in ("1242")              then do;country="Sweden";countryn=3;end;

    /*if dev then pkfl="N"; */
    /*else if sf then pkfl="N";
    else pkfl="Y";*/

    if rd3 then randfl="Y"; else randfl="N"; if subjid="X-1114-003" then randfl="Y";
    length trt01a trt01p trt02p trt03p $200.;
    trt01p=trtp1;
    trt02p=trtp2;
    trt03p=""/*trtp3*/;

    if trt01p="BLD" then trt01pn=.;
    if trt02p="BLD" then trt02pn=.;
    if trt03p="BLD" then trt03pn=.;

    if trt01p="GWP42003-P" then trt01pn=2;
    if trt02p="GWP42003-P" then trt02pn=2;
    if trt03p="GWP42003-P" then trt03pn=2;

    trt01a=trt01p;
    trt01an=trt01pn;
    trt02a=trt02p;
    trt02an=trt02pn;
    trt03a=trt03p;
    trt03an=trt03pn;

    if trt02p in("" "BLD") then do;trt02p="ABCD1234-P";trt02pn=2;end;
    if trt03p in ("" "BLD") then do;trt03p="ABCD1234-P";trt03pn=2;end;

    /** Exposure: Last dose date will be the completion period date coming from the termination page **/
    %* Modification: Thursday, June 22, 2017 Update TR01EDT for patients ongoing DB as cut-off date;
    if dslsdt1 ne "" then tr01edt=input(dslsdt1,yymmdd10.); else if dslsdt1 eq "" and tr01sdt ne . then tr01edt=mdy(05,01,2017);
    %* End of Modification: Thursday, June 22, 2017 05:05:19;

    if tr02sdt ne . then tr02sdt=tr01edt;
    tr02edt=input(dslsdt2,yymmdd10.);
    if tr02sdt ne . and tr02edt=. then tr02edt=mdy(05,01,2017); * cutoff date;
    if tr03sdt ne . then tr03sdt=tr02edt+1;
    tr03edt=input(dslsdt3,yymmdd10.);
    trtsdt=tr01sdt;
    trtedt=max(tr01edt,tr02edt,tr03edt);

    if sf then do;scrnffl="Y";taperfl="N";olefl="N";
    			TRT01P="Not randomized";TRT01PN=0;
    			TRT01A="Not randomized";TRT01AN=0;
         end;else scrnffl="N";
    if trtsdt>. then saffl="Y";else saffl="N";
	format trtsdt trtedt is8601da.;
run;
	
%*--- Create ADaM dataset;
data adsl;
 informat _all_;
 set adam_template all;
 keep &keepvar.;
run;

data adam.&domain;
  set adsl;
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
    call execute("data adam.&domain.(label='Subject-Level Analysis Dataset');");
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

%*--- end of program -----------------------------------------------------------;
