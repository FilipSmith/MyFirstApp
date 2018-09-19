from django.http import HttpResponse
from figures.forms import DocumentForm, UploadFileForm

import numpy as np
import pandas as pd
import pandas_profiling
 
 
def pop_count(df,df_raw ,flag_list): 
    ctable= ''    
    profile = pandas_profiling.ProfileReport(df)
    profile.to_file(outputfile="figures/static/tmpdata/myoutputfile.html")

    dff=df_raw[flag_list]
    ctable=dff.apply(pd.Series.value_counts) 
 		
    return ctable
