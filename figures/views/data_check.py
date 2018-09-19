from django.http import HttpResponse
from figures.forms import DocumentForm, UploadFileForm

import numpy as np
import pandas as pd
 

	
def data_check( domain , df, variables, init_list  ):
    check_list2=init_list 
    if domain =='ADAE':
        if not "TRTP" in variables :
                check_list2="TRTP is required for AEexplorer analysis"
				
    if domain =='ADSL':
            if not "AGE" in variables :
               check_list2="AGE is required is required"  

    return check_list2
	

	
	
	
	
	