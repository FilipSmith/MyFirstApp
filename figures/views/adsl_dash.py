from django.http import HttpResponse

# Il faut ajouter l'import get_object_or_404, attention !
from django.shortcuts import render, get_object_or_404, redirect
from figures.models import Study, Output, Objet, Specs, UserProfile, Comment, ListCode, Description,Document, Graph
##from study.forms import OutputForm , OutputForm_f,OutputForm_d, OutputList,CommentForm
from django.utils.safestring import mark_safe
from django.contrib.auth import authenticate, login, logout
from django.urls import reverse
from django.contrib.auth.decorators import login_required
from django.contrib.auth.models import User
from django_pandas.io import read_frame
from django.db.models import Q
 
##from figures.filters import OutputFilter     #for search bar
from django.conf import settings
from .views import *
from .stat_report import pop_count
from sas7bdat import SAS7BDAT

######demo table
from tableone import TableOne

"""import le formulaire de form.py"""
import datetime
import numpy as np
import pandas as pd
 

def dataCheck(doc_id):
    doc=get_object_or_404(Document, id=doc_id)
	
    WARN_FL=""
    WARN_VS=""
    WARN_CDISC="EMPTY"		

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

    #if doc.domain =='ADSL':
	###CDISC ADAM
     #   if  "AGE" not in variables :
     #       WARN_CDISC=mark_safe(WARN_CDISC+"<p style='color:red'>AGE is required in ADSL as per CDISC rules</p>")
			
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

    #########################################################################
    WARN_MESSAGE=dataCheck(doc_id)
    if WARN_MESSAGE[2] == 'EMPTY' :	
    
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
       for num,val in  enumerate(armcd, start=1):
           age_f0.append(df[(df.SEX == "F") & (df.ARMCD == val)]['AGE'].values.tolist() )
           age_m0.append(df[(df.SEX == "M") & (df.ARMCD == val)]['AGE'].values.tolist() )
           if num == 1 :
              df.loc[df['ARMCD'] == val, 'ARM'] = mark_safe('<span class="label label-success">' + arml[num-1] + '</span>')
           if num == 2 :
              df.loc[df['ARMCD'] == val, 'ARM'] = mark_safe('<span class="label label-warning">' + arml[num-1] + '</span>')
           if num == 3 :
              df.loc[df['ARMCD'] == val, 'ARM'] = mark_safe('<span class="label label-info">' + arml[num-1] + '</span>')
           if num == 4 :
              df.loc[df['ARMCD'] == val, 'ARM'] = mark_safe('<span class="label label-danger">' + arml[num-1] + '</span>')
				
	   	###Height and Weight are available
           if WARN_MESSAGE[1] == '' :   
              dftmp=df[(df['ARMCD'] == val)]
              dftmp['BMIBL']=dftmp['BMIBL']/3			
              WTMP = dftmp[[WARN_MESSAGE[3],WARN_MESSAGE[4],'BMIBL']].to_json(orient='records').replace('"','').replace(WARN_MESSAGE[3],"y").replace('BMIBL',"r").replace(WARN_MESSAGE[4],"x")
              WTMP_ =mark_safe( "label: ['"+ val +"'],data:" + WTMP + ",backgroundColor: '"+bgcolor_arm[num-1]+"',borderColor:  '"+bocolor_arm[num-1] +"', borderWidth: 1" ) 
			
              WV['line_dict_{}'.format(num)] = WTMP_
            		
       age_f=age_f0
       age_m=age_m0
       box_labels = mark_safe(armcd)
       listing=df[["USUBJID", "SITEID", "ARM", "AGE", "SEX"] ].values.tolist()

###Demographic tableone
       columns = ['AGE','SEX','RACE','ARM']
       categorical = ['SEX','RACE']
       groupby = ['ARM']
  
       mytable = TableOne(df, columns, categorical, groupby,isnull=False,)
       mytablej = mark_safe(mytable.to_html(classes='stripe row-border order-column').replace('&lt;','<').replace('&gt;','>').replace('<table border="1" class="dataframe stripe row-border order-column">','<table class="table no-margin">'))
	
       if WARN_MESSAGE[0] == '' :
          FLAG_ = flag_var(doc_id) 
          flag1=FLAG_[0]
          flag2=FLAG_[1]
          c_flag1= df_f=df[(df[flag1] == "Y")]['USUBJID'].count()	
          c_flag2= df_f=df[(df[flag2] == "Y")]['USUBJID'].count()
          p_flag1=100*c_flag1/df['USUBJID'].count()
          p_flag2=100*c_flag2/df['USUBJID'].count()
 		
       return render(request, 'figures/data_dash2.html', { 'document':doc,'bar_all':bar_all,'bar_male':bar_male, 'bar_female':bar_female, 'bar_labels':bar_labels,'box_labels':box_labels,'age_f':age_f,'age_m':age_m,'listing':listing[:10] ,'WARN_MESSAGE':WARN_MESSAGE,'FLAG1':flag1,'FLAG2':flag2,'C_FLAG1':c_flag1,'C_FLAG2':c_flag2,'P_FLAG1':p_flag1,'P_FLAG2':p_flag2,'WV':WV,'mytable' : mytablej} )   
    
    else :
	
        return render(request, 'figures/CDISC_ERROR.html', { 'document':doc, 'CDISC_ERROR' :WARN_MESSAGE[2] } )   
    