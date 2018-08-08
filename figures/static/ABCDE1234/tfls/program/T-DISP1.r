##################################################
##### Study{{study}}                         #####
##### Name={{username}}                      #####
##################################################

###Import metadata 

 
setwd("C:/Users/Felipe/Documents/django/")
source("study/static/ABCDE1234/tfls/program/meta/meta_T-DISP1.r")
###############Start Coding .....#######################
### ...................
### ....................
### ....................
##################################################
 

###Filter fr safety pop
datatmp=data2[data2[,"OLEFL"]=="Y",]

###Count number of subject by SITEID

datatmpa<-datatmp
datatmpb<-datatmp
datatmpa[,"COUNTRYN"]<-"All countries"
datatmpa[,"SITEID"]<-"All countries"
datatmpb[,"SITEID"]<-"All sites"
 
datatmp2<-rbind(datatmp,datatmpa,datatmpb)
result<-as.data.frame(tapply(datatmp2[,"USUBJID"],list(datatmp2[,"COUNTRYN"],datatmp2[,"SITEID"]), function(x) length(unique(x))))
t(result)
aa<-dim(result)
aa[1]
a=t(result[1,])
for (i in 2:aa[1]) { 
a=rbind(a,t(result[i,]))
}
newdata <- na.omit(a)
colnames(newdata)<-"Results"

 

###############create RTF report###############

 

table<-file.path(directory, paste(id, ".rtf", sep=""))
rtf<-RTF(table,width=11,height=9,font.size=11)
 
 

for ( i in 1:1) { 

   ###Add title
   for (i in 1:length(title_)){
      addAlignedText(rtf, TL[i], 'c')
    }


    addNewLine(rtf, n=2)

    ###add results
    addTable(rtf, newdata ,font.size=10,space.before=0.1,row.names=TRUE,NA.string="-",  col.widths=c(1.5,1.5),col.justify="C", header.col.justify="C")

    
  
    ###add footnote
    for (i in 1:length(footnote_)){
        addFootNote (rtf , "", FT[i],'l')
     }

       addFootNote  (rtf , "", PATH_FOOT,'l')
                                                                                                             
  }
 
    ###add pagebreak
   ##  addPageBreak(rtf, width=11, height=8.5, omi=c(1, 1, 1, 1) )   

    done(rtf)

 ##################End of Program##################