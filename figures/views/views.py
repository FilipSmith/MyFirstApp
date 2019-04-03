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
from .adsl_dash import data_dash2
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


     
def getData(request , doc_id):
      
    doc=get_object_or_404(Document, id=doc_id)    
    test_name,test_ext=os.path.splitext(''+doc.document.name+'')
    test_ext= test_ext.replace('.','') 	
	
	###import data to dataframe 
    df = pd.DataFrame({'A' : []})   
    df_raw = pd.DataFrame({'A' : []})  
    ###check the format of the data and import to csv	
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
       warn_message = "Only sasdataset or xpt or csv files are accepted"		 
 	 

	###list of data visualization by domain 
    graph_list = [ ]	
    if doc.domain == 'ADAE':
       graph_list = ['aeTimelines','aeExplorer']   
    else :
        if  doc.domain == 'ADLB' or  doc.domain =='ADVS' or  doc.domain =='ADEG':
            graph_list = ['safetyHistogram','safetyOutlierExplorer','safetyResultsOverTime','safety-shift-plot-master' ]
        else :
            if  doc.domain == 'ADSL':
                graph_list = ['demoPlot','adsl_dash2']   
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
	   
       if  doc.domain == 'ADSL' :
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
   
    return render(request, 'figures/data_visu.html', {  'document':doc, 'domain':doc.domain,  'graph':graph_  }) 
		
		
 
 
def get_Label(foo,varname):
   
    a=foo.header
    aa=str(a)
    apos=aa.find("Num")
    c=aa[apos:].replace("YYMMDD","  ").split("\n")
 
    matching = [s for s in c if varname in s]
    res=matching[0].strip().replace("  ","$")[::-1].split("$")[0][::-1]
    return res

	
##patient card
def patient(request, doc_id, patid):
    doc=get_object_or_404(Document, id=doc_id)   
    df = pd.read_csv('figures/static/tmpdata/'+doc.domain+'.csv',encoding="iso-8859-1")
    listing=df[df['USUBJID'] == patid][["STUDYID", "USUBJID", "SITEID",'SEX', "ARM", "AGE", "RACE"] ].values 
    if listing[0][3]== 'F' :
       avatar='female.png'
    else : 
       avatar='male.png'
    return render(request, 'figures/patient.html', { 'doc': doc, 'listing':listing[0] ,'avatar':  avatar  })	
	 
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
	
	
	
	