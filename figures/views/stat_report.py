from django.http import HttpResponse
from figures.forms import DocumentForm, UploadFileForm

import numpy as np
import pandas as pd
 
 
 
def pop_count(df,df_raw ,flag_list): 
    ctable= ''    
   
    dff=df_raw[flag_list]
    ctable=dff.apply(pd.Series.value_counts) 
 		
    return ctable
