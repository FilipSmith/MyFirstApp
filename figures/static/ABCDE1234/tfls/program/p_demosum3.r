#####Import SAS data#####
library(sas7bdat)
filesas<-"C:/Users/Felipe/Documents/site/studyreport/Folder Structure/Study XYZ/Production/InHouse data/a_dmg.sas7bdat"
read.sas7bdat(filesas)
dmg<-read.sas7bdat(filesas)
dmg[,2]

########################
dmg_tot<-dmg
dmg_tot$TGPDSC1A <-"Total"
dmg_tot$TGP1A <-"T99"
dmg2<-rbind(dmg,dmg_tot)
dmg2$RANDO <-"Y"
dmg2$PD_ANLYS <-"Y"

 

RANDO<-aggregate(cbind (count = dmg2$RANDO)  ~   TGP1A ,
          data = dmg2, 
          FUN = function(x){NROW(x)})
 colnames(RANDO ) <- c("One", "Two")
SAFETY<-aggregate(cbind(count = SAFETY) ~   TGP1A , 
          data = dmg2, 
          FUN = function(x){NROW(x)})

PK_ANLYS<-aggregate(cbind(count = PK_ANLYS) ~   TGP1A , 
          data = dmg2, 
          FUN = function(x){NROW(x)})
PD_ANLYS<-aggregate(cbind(count = PD_ANLYS) ~   TGP1A , 
          data = dmg2, 
          FUN = function(x){NROW(x)})

final<-cbind(RANDO,SAFETY[,2],PK_ANLYS[,2],PD_ANLYS[,2])
colnames(final) <- c("TGPDSC1A", "RANDO", "SAFETY","PK_POP","PD_POP")
tfinal <- as.data.frame(t(final))
rownames(tfinal)<-c("Treatment","Randomized","Safety","PK Popuplation","PD Population")
colnames(tfinal)<-c("ADBC\n(N=7)","AECB\n(N=7)","DCAB\n(N=7)","EBAC\n(N=7)","CBDA\n(N=7)", "BCEA\n(N=7)","BACD\n(N=7)","CABE\n(N=7)","Total\n(N=56)")
 
#####create RTF report#####
directory<-"C:/Users/Felipe/Documents/django/study/static/"
source(file.path(directory, paste("rtf_formatter.R", sep="")))
 

library(rtf)


directory<-"C:/Users/Felipe/Documents/django/study/static/ABCDE1234/tfls"
id<-"141_21" 
table<-file.path(directory, paste(id, ".rtf", sep=""))
rtf<-RTF(table,width=11,height=8.5,font.size=10,omi=c(1,1,1,1))


TITLE1<-getAlignedText("Study XYZ", 'l')
TITLE2<-getAlignedText("Table 14.1-2.1", 'c')
TITLE3<-getAlignedText("Number (percent) of subjects in the analysis sets", 'c')
TITLE4<-getAlignedText("All subjects", 'c')
TITLE5<-getwd()

FOOTNOTE1<-"Treatment: 150 mg AAA-XXXYYY"
FOOTNOTE2<-"Safety analysis set: Subjects that received study drug"
FOOTNOTE3<-"PK analysis set: Subjects with evaluable PK parameter data." 
FOOTNOTE4<-"Program: C:/Users /Desktop/report (template)/pgm_saf/p_demosum3.r"  

addFootNote <- function(rtf, text, footNoteText, alignment='l'){
    addText(rtf, paste0(text, '  {\\footnote \\pard\\q', alignment, ' ', footNoteText, ' }'))
}

addAlignedText <- function(rtf, text, alignment='l'){
  addText(rtf, paste0('\\pard\\q', alignment, ' ', text, '\\par'))
 
}

rtf<-RTF(table,width=11,height=8.5,font.size=12)
 
 
 for ( i in 1:10) { 
 
 k1=(i-1)*7+1
 k2=(i)*7
 
 addParagraph(rtf,   TITLE1)
 addParagraph(rtf,   TITLE2)
 addParagraph(rtf,   TITLE3)
 addParagraph(rtf, TITLE4)
 addParagraph(rtf, TITLE5)
 addNewLine(rtf, n=2)

addTable(rtf,as.data.frame(tfinal[2:5,]),font.size=10,space.before=0.1,row.names=TRUE,NA.string="-",col.widths=c(1.5,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8),col.justify="C", header.col.justify="C")

addNewLine(rtf, n=4)
addFootNote(rtf, " ", FOOTNOTE1)
addFootNote(rtf, " ", FOOTNOTE2)
addFootNote(rtf, " ", FOOTNOTE3)

                                                                                          
addPageBreak(rtf, width=11, height=8.5, omi=c(1, 1, 1, 1) )
                                                              
                                                            
}

done(rtf)









 


