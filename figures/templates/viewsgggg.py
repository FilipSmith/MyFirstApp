from django.http import HttpResponse


# Il faut ajouter l'import get_object_or_404, attention !
from django.shortcuts import render, get_object_or_404, redirect
from figures.models import Study, Output, Objet, Specs, UserProfile, Comment, ListCode, Description,Document
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
"""import le formulaire de form.py"""
import datetime
import numpy as np
import pandas as pd
import pandas_profiling
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
    df= pd.DataFrame({'A' : []}) 
	
    if test_ext =="sas7bdat" :
       df = pd.read_sas('figures/media/'+test_name+'.sas7bdat',encoding="iso-8859-1")
       df = df.rename(columns=lambda x: x.upper())
       df.to_csv('figures/static/tmpdata/'+doc.domain+'.csv') 
    elif test_ext =="xpt" :
       df = pd.read_sas('figures/media/'+test_name+'.xpt',format='xport',encoding="iso-8859-1")
       df = df.rename(columns=lambda x: x.upper())
       df.to_csv('figures/static/tmpdata/'+doc.domain+'.csv') 
    elif test_ext =="csv" :
       df = pd.read_csv('figures/media/'+test_name+'.csv',encoding="iso- -1")
       df = df.rename(columns=lambda x: x.upper())  
       shutil.copy('figures/media/'+test_name+'.csv', 'figures/static/tmpdata/'+doc.domain+'.csv')
    else: 
       warn_message = "Only sasdataset or xpt file are accepted"		 
 	 
	

	 	###data visualization for safety ADAMs 
    graph_list = [ ]	
    if doc.domain =='ADAE':
       graph_list = ['aeTimelines','aeExplorer']   
    else :
        if  doc.domain =='ADLB' or  doc.domain =='ADVS' or  doc.domain =='ADEG':
            graph_list = ['safetyHistogram','safetyOutlierExplorer','safetyResultsOverTime','safety-shift-plot-master']
        else :
            if  doc.domain =='ADSL':
                graph_list = ['demoPlot','adsl_dash']   
            else :
                if  doc.domain =='ADPP' or  doc.domain =='ADPC':
                    graph_list = ['pk1plot','pk2plot' ]
                else :
                       graph_list = [ ] 
 
			###data visualization for safety SDTMs 
    if  doc.domain =='AE':
        graph_list = ['aeTimelines' ]	

		
    if df.empty :
       dataset=''
       warn_message = "Only sasdataset or xpt file are accepted"		 
    else:
       profile = pandas_profiling.ProfileReport(df)
       profile.to_file(outputfile="figures/static/tmpdata/myoutputfile.html")	   
       variables=list(df.columns.values )	
       ###Link each variable to a description
       for varr in variables: 
           df.rename(columns={''+varr+'': "<a href='"+"infoVar/"+doc.domain+"/"+varr+"/' Target='_blank' >"+varr+"</a>" }, inplace=True) 
       dataset=mark_safe(df.to_html(classes='display nowrap').replace('&lt;','<').replace('&gt;','>').replace('<table ',' <table id="example" style="width:100%" ') )
	  
    return render(request, 'figures/getData.html', { 'document':doc , 'dataset':dataset, 'graph_list':graph_list })   
 
  
def data_visu(request, domain, graff ):
    return render(request, 'figures/data_visu.html', {  'domain':domain,  'graff':graff}) 
		
  
 		

	

from sas7bdat import SAS7BDAT

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
  
	

	
	
	
	
	