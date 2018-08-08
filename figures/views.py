from django.http import HttpResponse


# Il faut ajouter l'import get_object_or_404, attention !
from django.shortcuts import render, get_object_or_404, redirect
from figures.models import Study, Output, Objet, Specs, UserProfile, Comment, ListCode, Description
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

 
"""import le formulaire de form.py"""
import datetime
import numpy as np
import pandas as pd
import os
import mammoth    #to handle docx
import csv
"""for import CSV"""



def index(request):
    return HttpResponse("Hello, world. You're at the polls index.")



def test(request):
    b = Output(study_id=1, domain='AE',outputfile='ADAE',type='ADAM',objet_id=2)
    b.save()
    return render(request, 'figures/test.html' ,{ 'output' : b } )   
	
	
	
    """view of a containt of a dataset"""	
def getData(request,study_id, id):
      output = get_object_or_404(Output, id=id)
      studyy=get_object_or_404(Study, id=study_id)
      if output.objet_id==1:
         df = pd.read_sas('study/static/'+studyy.nom+'/SDTM/'+output.outputfile+'.sas7bdat',encoding="iso-8859-1")
      if output.objet_id==2:
         df = pd.read_sas('study/static/'+studyy.nom+'/ADAM/'+output.outputfile+'.sas7bdat',encoding="iso-8859-1")
      if output.objet_id==3:
         df = pd.read_sas('study/static/'+studyy.nom+'/TFLS/'+output.outputfile+'.rtf',encoding="utf-8")
	  
      variables=list(df.columns.values)

      for varr in variables: 
          df.rename(columns={''+varr+'': "<a href='"+varr+"/showSpecs#"+varr+"' Target='_blank' >"+varr+"</a>" }, inplace=True) 
      dataset=mark_safe(df.to_html(classes='table table-bordered').replace('&lt;','<').replace('&gt;','>'))
      
      return render(request, 'study/getData.html', { 'dataframe' : df ,'dataset':dataset , 'var': variables, 'study_id':study_id, 'id':id, 'output':output})   
 	
	

from sas7bdat import SAS7BDAT
def get_Label(foo,varname):
   
    a=foo.header
    aa=str(a)
    apos=aa.find("Num")
    c=aa[apos:].replace("YYMMDD","  ").split("\n")
 
    matching = [s for s in c if varname in s]
    res=matching[0].strip().replace("  ","$")[::-1].split("$")[0][::-1]
    return res


	
def output(request,study_id, id ):
    """ Afficher un output (more info and link for a dataset or a TFL) """
    output = get_object_or_404(Output, id=id)
    outtyp = "Dataset"
	
	###DATA-output
    if output.objet_id==1 or  output.objet_id==2:
        dspath='study/static/'+str(output.study)+'/'+str(output.objet)+'/'+str(output.outputfile)
        data_exist=os.path.isfile(dspath+'.sas7bdat')
		
        if data_exist:
           df = pd.read_sas(dspath+'.sas7bdat',encoding="iso-8859-1")
           dset=SAS7BDAT(dspath+'.sas7bdat')
           variables=list(df.columns.values)
           df.to_csv(dspath+'.csv') 
           a=0
           for varr in variables:
              labell=get_Label(dset," "+varr+" ")	
              specs=Specs.objects.filter(study_id=study_id, dataset=output.domain ,variable=varr)

              ###CDISC CHECK
              WARN=""
              LINK=1			  
              if len(varr)>8 :
                 WARN="<span style='color:red;font-size:200%;'> ? </span>"	
              if len(labell)>30 :
                 WARN="<span style='color:red;font-size:200%;'> ! </span>"
              if specs.count()>0  :	
                 speco=get_object_or_404(Specs, study_id=study_id, dataset=output.domain,variable=varr )			  
                 if speco.variable!=varr:
                    WARN="<span style='color:GREEN;font-size:200%;'> SPEC ISSUE</span>"	
                 if speco.label!=labell:
                    WARN="<span style='color:GREEN;font-size:200%;'> SPEC ISSUE </span>"	
              else :
                 WARN="<span style='color:GREEN;font-size:200%;'> NO SPEC </span>"	
                 LINK=0
				 
              if LINK==1 :
                 df.rename(columns={''+varr+'':  "<p style='font-size:70%;text-align:center;'> ("+labell+")"+WARN+" </p>"+"<a href='"+varr+"/showSpecs#"+varr+"' Target='_blank' >"+varr+"</a>" }, inplace=True) 
              else:
                 df.rename(columns={''+varr+'': varr +"<p style='font-size:70%;text-align:center;'> ("+labell+")"+ WARN+" </p>" }, inplace=True) 			  
              result=mark_safe(df.to_html(classes='display nowrap').replace('&lt;','<').replace('&gt;','>').replace('<table ',' <table id="example" style="width:100%" ')   )
              a=a+1
        else:
           result="File"+str(output.outputfile)+".sas7bdat does not exist"	
		   
		###data visualization for safety ADAMs 
        if output.outputfile =='ADAE':
           graph_list = ['aeTimelines','aeExplorer']


		   
        else :
             if output.outputfile =='ADLB' or output.outputfile =='ADVS' or output.outputfile =='ADEG':
                graph_list = ['safetyHistogram','safetyOutlierExplorer','safetyResultsOverTime','safety-shift-plot-master']
             else :
                  if output.outputfile =='ADSL':
                     graph_list = ['demoPlot']             
                  else :
                        graph_list = [ ] 
               		
		   
			###data visualization for safety ADAMs 
        if output.outputfile =='AE':
           graph_list = ['aeTimelines' ]	

		   
	###RTF-output	
    else: 
        graph_list = [ ]
        data_exist=os.path.isfile('study/static/'+str(output.study)+'/'+str(output.objet)+'/'+str(output.outputfile)+'.rtf')
        if data_exist:
           with open('study/static/'+str(output.study)+'/TFLS/'+output.outputfile+'.docx', "rb") as docx_file:
                 result_ = mammoth.convert_to_html(docx_file)
                 result=result_.value.replace("<p>","<p class='c' style:'line-height:  1;' >") 
        else:  
           result="File"+str(output.outputfile)+".rtf does not exist"	
		   
    return render(request, 'study/output.html', {'data_exist':data_exist, 'viewOutput':result ,  'study_id':study_id, 'id':id, 'output':output,'stu_name': output.study, 'outtyp':outtyp ,'graph_list':graph_list })   
		
		
 	
def viewOutput(request,study_id, id):
      output = get_object_or_404(Output, id=id)
      studyy=get_object_or_404(Study, id=study_id)
      if output.objet_id==3:
         with open('study/static/'+studyy.nom+'/TFLS/'+output.outputfile+'.docx', "rb") as docx_file:
              result_ = mammoth.convert_to_html(docx_file)
              result=result_.value.replace("<p>","<p class='c' style:'line-height:  1;' >") 
      return render(request, 'study/viewOutput.html', {'viewOutput':result ,  'study_id':study_id, 'id':id, 'output':output})   
 	  
	