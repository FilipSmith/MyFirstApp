from django.http import HttpResponse
from figures.forms import DocumentForm, UploadFileForm

import numpy as np
import pandas as pd
 

###https://wiki.cdisc.org/display/RULESADAM/CDISC+ADaM+Conformance+Rules+v2.0+compiled	
def cdisc_check(  domain   ):
    check_list=[]	 
    WARN_MESS=""	
###Any domain 

    for varr in variables: 
	    ###A variable with a suffix of FL has a value that is not Y, N, or null	
        if varr[-2:]  == 'FL' and df.varr not in ("Y" , "N", ""): 
            WARN_MESS= "A variable with a suffix of FL has a value that is not Y, N, or null"	
	    

			
    if domain =='ADAE':
        if not "TRTP" in variables :
                check_list="TRTP is required for AEexplorer analysis"
				
    if domain =='ADSL':
            if not "AGE" in variables :
               check_list="AGE is required is required"  

			   
    return render(request, 'figures/cdisc_check.html', {  'check_list':check_list ,'WARN_MESS':WARN_MESS})  


	

	
	
	
	
	