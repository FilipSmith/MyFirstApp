from django.http import HttpResponse


# Il faut ajouter l'import get_object_or_404, attention !
from django.shortcuts import render, get_object_or_404, redirect
from figures.models import Study, Output, Objet, Specs, UserProfile, Comment, ListCode, Description,Document, Graph
from tablib import Dataset
from django.http import HttpResponse, HttpResponseRedirect
from django.utils import timezone
##from study.forms import OutputForm , OutputForm_f,OutputForm_d, OutputList,CommentForm
from django.utils.safestring import mark_safe
from django.core.files import File
from django.views.generic.edit import FormView, CreateView
from django.contrib.auth import authenticate, login, logout
from django.urls import reverse
from django.contrib.auth.decorators import login_required
from django.contrib.auth.models import User
from django_pandas.io import read_frame
from django.db.models import Q
 
##from figures.filters import OutputFilter     #for search bar
from django.conf import settings
from django.core.files.storage import FileSystemStorage
 
from figures.forms import DocumentForm, UploadFileForm

from .data_check import data_check
from .stat_report import pop_count


from sas7bdat import SAS7BDAT

"""import le formulaire de form.py"""
import datetime
import numpy as np
import pandas as pd
import os
import mammoth    #to handle docx
import csv
import shutil
"""for import CSV"""



def index(request):
    return HttpResponse("Hello, world. You're at the polls index.")



    """view of a containt of a dataset"""	
def getData(request , doc_id):
      
    doc=get_object_or_404(Document, id=doc_id)    
    test_name,test_ext=os.path.splitext(''+doc.document.name+'')
    test_ext= test_ext.replace('.','') 	
	
	###import data to dataframe 
    df = pd.DataFrame({'A' : []})   
    df_raw = pd.DataFrame({'A' : []})  
	
    if test_ext == "sas7bdat" :
	   
       with SAS7BDAT('figures/media/'+test_name+'.sas7bdat') as f:	   
            df = f.to_data_frame()	   
       df_raw = df
       df = df.rename(columns=lambda x: x.upper())
       df.to_csv('figures/static/tmpdata/'+doc.domain+'.csv',encoding="iso-8859-1") 
    elif test_ext == "xpt" :
       df = pd.read_sas('figures/media/'+test_name+'.xpt',format='xport',encoding="iso-8859-1")
       df_raw = df	   
       df = df.rename(columns=lambda x: x.upper())
       df.to_csv('figures/static/tmpdata/'+doc.domain+'.csv',encoding="iso-8859-1") 
    elif test_ext == "csv" :
       df = pd.read_csv('figures/media/'+test_name+'.csv',encoding="iso-8859-1")
       df_raw = df    
       df = df.rename(columns=lambda x: x.upper()) 
       shutil.copy('figures/media/'+test_name+'.csv', 'figures/static/tmpdata/'+doc.domain+'.csv')
    else: 
       warn_message = "Only sasdataset or xpt file are accepted"		 
 	 

	###list of data visualization by domain 
    graph_list = [ ]	
    if doc.domain == 'ADAE':
       graph_list = ['aeTimelines','aeExplorer']   
    else :
        if  doc.domain == 'ADLB' or  doc.domain =='ADVS' or  doc.domain =='ADEG':
            graph_list = ['safetyHistogram','safetyOutlierExplorer','safetyResultsOverTime','safety-shift-plot-master' ]
        else :
            if  doc.domain == 'ADSL':
                graph_list = ['demoPlot','adsl_dash','adsl_dash2']   
            else :
                if  doc.domain == 'ADPP' or  doc.domain =='ADPC':
                    graph_list = ['pk1plot','pk2plot' ]
                else :
                       graph_list = [ ] 
 
	###data visualization for safety SDTMs 
    if  doc.domain == 'AE':
        graph_list = ['aeTimelines' ]	

    ctable=pd.DataFrame({'A' : []})   

	###Init lists for data cehcks
    pop_fl=[]
    flag_list_l=[]	
    flag_list_n=[]	
    day_list=[]		
    trt_list=[]	
    check_list=""
	
    if df.empty :
       dataset=''
       warn_message = "Only sasdataset or xpt file are accepted"		 
    else:
 	       	  
       variables=list(df.columns.values )
	    
	   ###check_list
       data_check(doc.domain , df, variables, flag_list_l, flag_list_n)
       if 'check_list2' in vars():
           check_list=check_list2           
 
       ###Link each variable to a description
       df2=df
       df2["id"] = df2.index + 1
       df2 = df2[['id'] + df2.columns[:-1].tolist()]
       ###data_json= df2.to_json( orient='records',path_or_buf="figures/static/tmpdata/jsonfile.json" ) 
       data_json= df2.to_json( orient='records')

       ###Get study name	  
       study_name=df.STUDYID.unique()
       doc.number_of_subj = len(df.USUBJID.unique())
       doc.arms = df.ARM.unique()
          
	   ###dataset check (CDISC) 	   
	   
       for varr in variables: 
           df.rename(columns={''+varr+'': "<a href='"+"infoVar/"+doc.domain+"/"+varr+"/' Target='_blank' >"+varr+"</a>" }, inplace=True) 
           ###Population flag ? 
           if varr in ("EFFICACY",  "SAFETY" , "ITT"):
              pop_fl = pop_fl + [varr]		   
           if varr[-2:]  == 'FL' : 
              flag_list_l=flag_list_l + [varr]
           if varr[-2:]  == 'FN' : 
              flag_list_n=flag_list_n + [varr]
           if varr[-2:]  == 'DY' :
              day_list=day_list + [varr]	
           if varr in ("TRTA",  "TRTP")    :
              trt_list=trt_list + [varr]
       
       try:
           b=pop_fl.index(1)
       except ValueError:
              flag1=" "
       else:
              flag1 = pop_fl[1]
       
       doc.n_pop_flag = flag1###df.flag1.count()
   
       dataset=mark_safe(df.to_html(classes='stripe row-border order-column').replace('&lt;','<').replace('&gt;','>').replace('<table ',' <table id="example2" style="width:100%; border-collapse: collapse; " ').replace('dataframe ',' ').replace('border="1" ','border="0" ') )
 
       flag_list_l=flag_list_l+ pop_fl      
       ctable11=  flag_list_l
       ###    ctable11=pop_count(df_raw ,flag_list_l)  
          
    doc.study_name= study_name
    doc.pop_flag = flag_list_l 
    doc.variables = variables

    doc.save()	
	   
    return render(request, 'figures/getData.html', { 'document':doc, 'doc_id':doc_id , 'dataset':dataset, 'graph_list':graph_list , 'check_list':check_list,'variables':variables, 'trt_list':trt_list ,'flag_list_l':flag_list_l,'day_list':day_list, 'df':df, 'ctable':ctable11, 'data_json':mark_safe( data_json), 'study_name': study_name  })   
 
  
def data_visu(request, doc_id, graff ):
    doc=get_object_or_404(Document, id=doc_id)   
    graph_=get_object_or_404(Graph, nom=graff)  
    ###Check data before to display the figure
    ###result =  all(elem in graff.req_var  for elem in variables)
    ###if result:
    ###    warn_note="Yes, all variables are presents"     
    ###else :
    ###    warn_note="No, some required variables are missing" 
        ###descriptive stats	
   
    return render(request, 'figures/data_visu.html', {  'document':doc, 'domain':doc.domain,  'graph':graph_  }) 
		
		
		
def data_dash(request, doc_id, graff  ):
    graph_=get_object_or_404(Graph, nom=graff) 
    doc=get_object_or_404(Document, id=doc_id)  
 	
    WARN_MESSAGE=""
	
	###A few check for unusual naming
    FLAG_EFF = 'EFFL'
    FLAG_SAF = 'SAFFL'
    flag_list_l = doc.pop_flag
	
	###A few check for unusual naming
    HEIGHT_VAR = 'HEIGHT'
    WEIGHT_VAR = 'WEIGHT'
    BMI_VAR = 'BMI'
    variables = doc.variables	
		
    if 'EFFICACY' in flag_list_l and 'EFFL' not in flag_list_l:
        FLAG_EFF='EFFICACY'
    if 'SAFETY' in flag_list_l and 'SAFFL' not in flag_list_l:
        FLAG_SAF='SAFETY'
		
    if 'HEIGHTBL' in variables :
        HEIGHT_VAR='HEIGHTBL'
    if 'HTBL' in variables :
        HEIGHT_VAR='HTBL'
    if 'WEIGHTBL' in variables  :
        WEIGHT_VAR='WEIGHTBL'
    if 'WTBL' in variables  :
        WEIGHT_VAR='WTBL'
    if 'BMIBL' in variables :
        BMI_VAR='BMIBL'
	
    if HEIGHT_VAR not in variables: 
       WARN_MESSAGE=mark_safe(WARN_MESSAGE+"<p style='color:red'> The variable " +HEIGHT_VAR+ " is missing </p>")  
    if WEIGHT_VAR not in variables: 
       WARN_MESSAGE=mark_safe(WARN_MESSAGE+"<p style='color:red'> The variable " +WEIGHT_VAR+ " is missing </p>")

    if doc.domain =='ADSL':
	###CDISC ADAM
        if  "AGE" not in variables :
            WARN_MESSAGE=mark_safe(WARN_MESSAGE+"<p style='color:red'>AGE is required in ADSL as per CDISC rules</p>") 			   
		
    return render(request, 'figures/data_dash.html', { 'document':doc ,   'graph':graph_, 'variables':variables, 'HEIGHT_VAR':HEIGHT_VAR,'WEIGHT_VAR':WEIGHT_VAR, 'BMI_VAR':BMI_VAR ,'FLAG_EFF':FLAG_EFF,'FLAG_SAF':FLAG_SAF,'WARN_MESSAGE':WARN_MESSAGE })   

def dataCheck(doc_id):
    doc=get_object_or_404(Document, id=doc_id)
	
    WARN_FL=""
    WARN_VS=""
    WARN_CDISC=""		

	### NO FLag defined
    flag_list_l = doc.pop_flag
    if len(flag_list_l) == 0:
       WARN_FL="There is no flag defined";  
	
	###A few check for unusual naming
    HEIGHT_VAR = 'HEIGHT'
    WEIGHT_VAR = 'WEIGHT'
    variables = doc.variables	
		
    if 'HTBL' in variables :
        HEIGHT_VAR='HTBL'		
    if 'HEIGHTBL' in variables :
        HEIGHT_VAR='HEIGHTBL'
    if 'WEIGHTBL' in variables  :
        WEIGHT_VAR='WEIGHTBL'
    if 'WTBL' in variables  :
        WEIGHT_VAR='WTBL'

	
    if HEIGHT_VAR not in variables: 
       WARN_VS=mark_safe(WARN_VS+"<p style='color:red'> The variable " +HEIGHT_VAR+ " is missing </p>") 
    if WEIGHT_VAR not in variables: 	   
       WARN_VS=mark_safe(WARN_VS+"<p style='color:red'> The variable " +WEIGHT_VAR+ " is missing </p>")
    if (HEIGHT_VAR not in variables)  & (WEIGHT_VAR not in variables) :
       WARN_VS= "<p style='color:red'> Height and Weight are not available </p>" 

    if doc.domain =='ADSL':
	###CDISC ADAM
        if  "AGE" not in variables :
            WARN_CDISC=mark_safe(WARN_CDISC+"<p style='color:red'>AGE is required in ADSL as per CDISC rules</p>")
			
    res=[WARN_FL,WARN_VS,WARN_CDISC,HEIGHT_VAR,WEIGHT_VAR]
			
    return res
	
def flag_var(doc_id):
    doc=get_object_or_404(Document, id=doc_id)
    flag_list_l = doc.pop_flag.replace("[","").replace("]","").replace("'","").replace(' ', '')
    flag_list_l= flag_list_l.split(',')

    ###A few check for unusual naming
    FLAG_ITTFL = 'ITTFL'
    FLAG_SCRFL = 'SCRNFL'
    FLAG_EFF = 'EFFL'
    FLAG_SAF = 'SAFFL'
    FLAG_RAND = 'RANDFL'
    FLAG_PK = 'PKFL'
	
    if 'EFFICACY' in flag_list_l and 'EFFL' not in flag_list_l:
        FLAG_EFF='EFFICACY'
    if 'SAFETY' in flag_list_l and 'SAFFL' not in flag_list_l:
        FLAG_SAF='SAFETY' 
		
		##select the more pertinent and avaialble flag  
    if FLAG_RAND in  flag_list_l :
       flag_list_l.insert(0, FLAG_RAND)
    if FLAG_PK in  flag_list_l :
       flag_list_l.insert(0, FLAG_PK)  
    if FLAG_SCRFL in  flag_list_l :
       flag_list_l.insert(0, FLAG_SCRFL)
    if FLAG_EFF in  flag_list_l :
       flag_list_l.insert(0, FLAG_EFF)		
    if FLAG_SAF in  flag_list_l :
       flag_list_l.insert(0, FLAG_SAF)		
    if FLAG_ITTFL in  flag_list_l :
       flag_list_l.insert(0, FLAG_ITTFL)		

    return flag_list_l	   
 
def data_dash2(request, doc_id  ):
    doc=get_object_or_404(Document, id=doc_id)  
    
    df = pd.read_csv('figures/static/tmpdata/'+doc.domain+'.csv',encoding="iso-8859-1")
    df_raw = df    
    df = df.rename(columns=lambda x: x.upper()) 
  
    ##########################Data for Pie plot#############################  
    df_a=df.groupby(['RACE']).count()
    bar_all=df_a['USUBJID'].values.tolist()
	
	##########################Data for Bar Chart#############################
    df_f=df[(df.SEX == "F")].groupby(['RACE']).count()
    df_m=df[(df.SEX == "M")].groupby(['RACE']).count()

    bar_male=df_m['USUBJID'].values.tolist()
    bar_female=df_f['USUBJID'].values.tolist()

    df['RACE']=df['RACE'].str.split(" ", n = 1, expand = True) 
    bar_labels = mark_safe(df.RACE.unique().tolist())
    
    #########################################################################
    WARN_MESSAGE=dataCheck(doc_id)	

    ###Height and Weight are available then we calculate BMI
    if WARN_MESSAGE[1] == '' :
       df['BMIBL'] = df[WARN_MESSAGE[4]] / ((df[WARN_MESSAGE[3]]/100)**2)
		
    WV={}
    age_f0 = [] 
    age_m0 = []  
    bgcolor_arm = ['rgba(46, 204, 113, 0.4)','rgba(252, 185, 65, 0.4)','rgba(129, 207, 224, 0.4)','rgba(255, 99, 132, 0.4)','yellow']	
    bocolor_arm = ['rgba(46, 204, 113, 1)','rgba(252, 185, 65, 1)','rgba(129, 207, 224, 1)','rgba(255, 99, 132, 1)','rgba(245, 230, 83, 1)']	
    if "ARMCD" not in list(df) :
        df['ARMCD'] = df['ARM']
    armcd=df.ARMCD.unique().tolist()
    arml=df.ARM.unique().tolist()
    for  num,val in  enumerate(armcd, start=1):
        age_f0.append(df[(df.SEX == "F") & (df.ARMCD == val)]['AGE'].values.tolist() )
        age_m0.append(df[(df.SEX == "M") & (df.ARMCD == val)]['AGE'].values.tolist() )
        if num == 1 :
           df.loc[df['ARMCD'] == val, 'ARM'] = mark_safe('<span class="label label-success">' + arml[num-1])
        if num == 2 :
           df.loc[df['ARMCD'] == val, 'ARM'] = mark_safe('<span class="label label-warning">' + arml[num-1])
        if num == 3 :
           df.loc[df['ARMCD'] == val, 'ARM'] = mark_safe('<span class="label label-info">' + arml[num-1])
        if num == 4 :
           df.loc[df['ARMCD'] == val, 'ARM'] = mark_safe('<span class="label label-danger">' + arml[num-1])
		
		
		###Height and Weight are available
        if 	WARN_MESSAGE[1] == '' :
             
            dftmp=df[(df['ARMCD'] == val)]
            dftmp['BMIBL']=dftmp['BMIBL']/3			
            WTMP = dftmp[[WARN_MESSAGE[3],WARN_MESSAGE[4],'BMIBL']].to_json(orient='records').replace('"','').replace(WARN_MESSAGE[3],"y").replace('BMIBL',"r").replace(WARN_MESSAGE[4],"x")
            WTMP_ =mark_safe( "label: ['"+ val +"'],data:" + WTMP + ",backgroundColor: '"+bgcolor_arm[num-1]+"',borderColor:  '"+bocolor_arm[num-1] +"', borderWidth: 1" ) 
			
            WV['line_dict_{}'.format(num)] = WTMP_
            		
    age_f=age_f0
    age_m=age_m0
    box_labels = mark_safe(armcd)
    listing=df[["USUBJID", "SITEID", "ARM", "AGE"] ].values.tolist()

	    
    if 	WARN_MESSAGE[0] == '' :
        FLAG_ = flag_var(doc_id) 
        flag1=FLAG_[0]
        flag2=FLAG_[1]
        c_flag1= df_f=df[(df[flag1] == "Y")]['USUBJID'].count()	
        c_flag2= df_f=df[(df[flag2] == "Y")]['USUBJID'].count()
        p_flag1=100*c_flag1/df['USUBJID'].count()
        p_flag2=100*c_flag2/df['USUBJID'].count()
 		
    return render(request, 'figures/data_dash2.html', { 'document':doc,'bar_all':bar_all,'bar_male':bar_male, 'bar_female':bar_female, 'bar_labels':bar_labels,'box_labels':box_labels,'age_f':age_f,'age_m':age_m,'listing':listing[:10] ,'WARN_MESSAGE':WARN_MESSAGE,'FLAG1':flag1,'FLAG2':flag2,'C_FLAG1':c_flag1,'C_FLAG2':c_flag2,'P_FLAG1':p_flag1,'P_FLAG2':p_flag2,'WV':WV} )   
 
    
 
 
 
 
 
 
def get_Label(foo,varname):
   
    a=foo.header
    aa=str(a)
    apos=aa.find("Num")
    c=aa[apos:].replace("YYMMDD","  ").split("\n")
 
    matching = [s for s in c if varname in s]
    res=matching[0].strip().replace("  ","$")[::-1].split("$")[0][::-1]
    return res

	
  
 	  
##upload
 

def test(request):
    documents = Document.objects.all()
    return render(request, 'figures/test.html', { 'document': documents.last(),   })	
	
	###permanent saved file 
def model_form_upload(request):
    if request.method == 'POST':
        form = DocumentForm(request.POST, request.FILES)
        if form.is_valid():
            form.save()
            documents = Document.objects.all()
            return render(request, 'figures/test.html', {'document' : documents.last(),  }   )
    else:
        form = DocumentForm()
    return render(request, 'figures/upload_form.html', {
        'form': form
    })  
	
 

##Specifications##
 
def infoVar(request,domain, var):
     
      df = pd.read_csv('figures/static/tmpdata/'+domain+'.csv',encoding="iso-8859-1") 
      df = df.rename(columns=lambda x: x.upper())   
  
      uniq_val=df[[""+var+""]].describe().to_html(classes='table table-bordered table-sm') 
      n_val=len(uniq_val)
      graff =  'simpleCharts'  
      return render(request, 'figures/infoVar.html', {'domain':domain , 'var':var, 'uniq_val':uniq_val,'n_val':n_val,'graff':graff })
  
	


def report_select(request):
    documents = Document.objects.all()
    return render(request, 'figures/report_select.html', { 'document': documents   })		
	
	
	
	