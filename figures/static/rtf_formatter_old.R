library(rtf)

#' Add foot note to the document
#' Example : addFootNote(rtf, "There is a footnote", "This is the right footnote", 'r')
#'
#' @param rtf rtf object
#' @param text text to add foot note
#' @param footNoteText foot note text
#' @param alignment 
addFootNote <- function(rtf, text, footNoteText, alignment='l'){
    addText(rtf, paste0(text, ' \\chftn {\\footnote \\pard\\q', alignment, '{\\chftn}', footNoteText, ' }'))
}


#' Align a given text
#' Example : addAlignedText(rtf, 'Centered text', 'c')
#'
#' @param rtf rtf object
#' @param text text to add foot note
#' @param alignment alignemnt
addAlignedText <- function(rtf, text, alignment='l'){
  addText(rtf, paste0('\\pard\\q', alignment, ' ', text,'kikou', '\\par'))
  addText(rtf, '\\pard')
}

#' Add footer to the document
#' Example : addFooter(rtf, 'Centered footer', 'c')
#'
#' @param rtf rtf object
#' @param text text to add foot note
#' @param alignment alignemnt
addFooter <- function(rtf, text, alignment='l'){
  addText(rtf, paste0('{\\footer \\pard \\q', alignment, ' ', text, '\\par }'))
}

#' Get a text with the alignment command (To be used with addHeader)
#' Example : addFooter(rtf, 'Centered footer', 'c')
#'
#' @param text text to add foot note
#' @param alignment alignemnt
getAlignedText <- function(text, alignment='l') {
  return( paste0('\\q', alignment, ' ', text))
}

############################################################
### Example
###

output<-"C:/Users/Felipe/Documents/django/study/static/ABCDE1234/tfls/rtf_test.rtf"

rtf<-RTF(output,width=8.5,height=11,font.size=10,omi=c(1,1,1,1))


addHeader(rtf, title =getAlignedText("Title - Page 1", 'c'), subtitle=getAlignedText("Sub Title", 'c'))

addAlignedText(rtf, 'Table Title Centred', 'c')

# Sample table from iris data
addTable(rtf,as.data.frame(head(iris)),font.size=10,row.names=FALSE,NA.string="-")

addParagraph(rtf, "\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore")
addParagraph(rtf, "\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore")


addFootNote(rtf, "\n\nThere is a footnote", "This is the left footnote")
addFootNote(rtf, "\nThere is a footnote", "This is the right footnote", 'r')
addFootNote(rtf, "\nThere is a footnote", "This is the center footnote", 'c')

# New page
addPageBreak(rtf)
addHeader(rtf, title =getAlignedText("Title - Page 2", 'c'), subtitle=getAlignedText("Sub Title", 'c'))

addAlignedText(rtf, 'Table Title Right', 'r')
# Sample table from iris data
addTable(rtf,as.data.frame(head(iris)),font.size=10,row.names=FALSE,NA.string="-")
addFooter(rtf, 'Right alined footer', 'r')

# New page
addPageBreak(rtf)
addHeader(rtf, title =getAlignedText("Title - Page 3", 'c'), subtitle=getAlignedText("Sub Title", 'c'))

addAlignedText(rtf, 'Table Title Center', 'c')
# Sample table from iris data
addTable(rtf,as.data.frame(head(iris)),font.size=10,row.names=FALSE,NA.string="-")
addFooter(rtf, 'Centered footer', 'c')

done(rtf)
