from django.http import HttpResponse
from figures.forms import DocumentForm, UploadFileForm

import numpy as np
import pandas as pd
 


###https://wiki.cdisc.org/display/RULESADAM/CDISC+ADaM+Conformance+Rules+v2.0+compiled	
def data_check( domain , df, variables, flag_list_l,flag_list_n  ):
    data_check_list=[] 
    check_list2=""
	###Any domain (CDISC checks)        
    if  all(elem in ([elem[:-2] for elem in flag_list_n])  for elem in ([elem[:-2] for elem in flag_list_l])): 
        WARN="A variable with a suffix of FN is present but a variable with the same root and a suffix of FL is not present"        
 					
    if domain =='ADSL':
	###CDISC ADAM
        if not "AGE" in variables :
               check_list="AGE is required is required"  
	
	
    if domain =='ADAE':
	###CDISC ADAM
	
	###check for graph report
        if not "TRTP" in variables :
            check_list2="TRTP is required for AEexplorer analysis"
			
			
			
    if domain =='ADSL':
	###CDISC ADAM
        if  "AGE" not in variables :
            check_list2="AGE is required in ADSL"  		
			   
    return check_list2
	

	
	
	
	
def variable_check( domain , df, variable  ):
    check_var=[] 

	###CDISC rules for any domain
    if variable[-2:]  == 'FL':
        if  any(elem in df.variable.unique()  for elem in ["Y","N",""]): 
          WARN="A variable with a suffix of FL has a value that is not Y, N, or null"
    if variable[-2:]  == 'FN':
        if  any(elem in df.variable.unique()  for elem in [1,0,np.NaN]): 
          WARN="A variable with a suffix of FN has a value that is not  0, 1, or null" 			
 
    return check_list2
		
	
	
	