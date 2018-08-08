##################################################
##### 	Standard Metadata import             #####
#####     R 3.4                              #####
##################################################


####################Import SAS data###############
library(sas7bdat)
dataset<-"ADSL"     
study<-"ABCDE1234"   
title<-"Subject Disposition, Visit Attendance, Protocol Violations|Safety pop|ole etc..."   
footnote<-"All site are represented of a country.|Each country is only decribed one time."  
population<-"Safety Population"    
type<-"Table"
number<-"T-DISP1" 


directory<-"study/static/"
filesas<-paste(directory,study,"/adam/",dataset,".sas7bdat",sep="")
read.sas7bdat(filesas)
data<-read.sas7bdat(filesas)
 
##################################################


###############Apply filter#######################

##if (exists("{{filter}}"))
##data2<-subset(data, {{filter}})
## }
data2<-data
##################################################



###########Prepare RTF file###########
source(file.path(directory, paste("rtf_formatter.R", sep="")))
library(rtf)
directory<-paste(directory,study,"tfls",sep="/")
id<-number




                  ###Title###
title_=scan(text = title, what = 'character', sep = '|')
TL<-""

for (i in 1:(length(title_)+1)){ 
   if (i==1) {
      TL[i]<-getAlignedText(study, 'l') }
   else {
      TL[i]<-getAlignedText(title_[i-1], 'c') }
}



 ###  TITLE2<-getAlignedText("Table 14.1-2.1", 'c')
 ###  TITLE3<-getAlignedText("Number (percent) of subjects in the analysis sets", 'c')
 ###  TITLE4<-getAlignedText("All subjects", 'c')




                 ###Footnote###	
PATH_FOOT=paste("Program:",study,"/tfls/program/",number,".R               ",date(),sep="")
footnote_=scan(text = footnote, what = 'character', sep = '|')
FT<-""
for (i in 1:length(footnote_)){
      FT[i]<-getAlignedText(footnote_[i],'l') }

 ### FOOTNOTE1<-"Treatment: 150 mg AAA-XXXYYY"
 ### FOOTNOTE2<-"Safety analysis set: Subjects that received study drug"
 ### FOOTNOTE3<-"PK analysis set: Subjects with evaluable PK parameter data." 
 ### FOOTNOTE4<-"Program: C:/Users /Desktop/report (template)/pgm_saf/p_demosum3.r"  


 