from __future__ import unicode_literals
from django.db import models
from django.utils import timezone
from django.contrib.auth.models import User
#to extand user profile
from django.db.models.signals import post_save
from django.dispatch import receiver
from django.urls import reverse
import os

class Study(models.Model):
    nom = models.CharField(max_length=30)
    title = models.TextField(max_length=400) 
    phase = models.CharField(max_length=10) 	
    Table=models.IntegerField(default=0)
    Listing=models.IntegerField(default=0)
    Figure=models.IntegerField(default=0)
    SDTM=models.IntegerField(default=0)
    ADAM=models.IntegerField(default=0)
    def __str__(self):
        return self.nom
		

    # User roles .		
class Role(models.Model):
    role = models.CharField(max_length=30)
    def __str__(self):
        return self.role
    # User profile .
	
class UserProfile(models.Model):
    # This line is required. Links UserProfile to a User model instance.
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    study = models.ManyToManyField(Study)

    # The additional attributes we wish to include.
    role = models.CharField(max_length=30)   
    email = models.EmailField(blank=True)
    location = models.CharField(max_length=100, blank=True)
	
    # Override the __unicode__() method to return out something meaningful!
    def __unicode__(self):
        return self.user.username







		
class Objet(models.Model):
    nom = models.CharField(max_length=30)

    def __str__(self):
        return self.nom
		
		
class Output(models.Model):
    domain=models.CharField(max_length=20)
    type=models.CharField(max_length=20)
    number=models.CharField(max_length=20)
    title = models.TextField(max_length=400) 
    footnote = models.TextField(max_length=400) 
    population = models.CharField(max_length=50) 
    program = models.CharField(max_length=20)
    programmer = models.CharField(max_length=42)
	
    indata= models.CharField(max_length=50) 
	
	
    SAS = 'SAS'
    R = 'R'
    PYTHON = 'Python'	
	
    SOFTWARE_CHOICES = (
        (SAS, 'SAS'),
        (R, 'R'),
        (PYTHON, 'Python'),
    )
	
    software = models.CharField(
        max_length=10,
        choices=SOFTWARE_CHOICES,
        default=SAS,
    ) 		
	
 
    qcprogram = models.CharField(max_length=20)
    qcprogrammer = models.CharField(max_length=42)
    qcsoftware = models.CharField(
        max_length=10,
        choices=SOFTWARE_CHOICES,
        default=SAS,
    ) 		

    statistician = models.CharField(max_length=50)
 
    outputfile = models.CharField(max_length=50)
	
    DRAFT = 'DRAFT'
    NOTSARTED = 'Not started'
    PRODUCTION = 'Production'
	
    STATUS_CHOICES = (
        (DRAFT, 'Draft'),
        (NOTSARTED, 'Not Started'),
        (PRODUCTION, 'Production'),
    )
	
    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default=DRAFT,
    ) 
	
    date = models.DateTimeField(default=timezone.now, 
                                verbose_name="Date de parution")
    study = models.ForeignKey('Study', on_delete=models.CASCADE)							
    objet = models.ForeignKey('Objet', on_delete=models.CASCADE)	
  

	
    class Meta:
        verbose_name = "Output"
        ordering = ['study', 'number']
    
    def __str__(self):
        """ 
        Cette méthode que nous définirons dans tous les modèles
        nous permettra de reconnaître facilement les différents objets que 
        nous traiterons plus tard dans l'administration
        """
        return   '%s %s' % (self.domain, self.title)
		
 

 	
class Comment(models.Model):
 
    comment = models.TextField(null=True)
    role = models.CharField(max_length=30)
    date = models.DateTimeField()
	
    study = models.ForeignKey('Study', on_delete=models.CASCADE)
    objet = models.ForeignKey('Objet', on_delete=models.CASCADE)
    output = models.ForeignKey('Output', on_delete=models.CASCADE)
    user = models.ForeignKey(User, on_delete=models.DO_NOTHING)
    class Meta:
        verbose_name = "Comments"
        ordering = ['study','output','date']
    
    def __str__(self):
        return self.comment	
	
###Specifications CDISC ####

	
class Specs(models.Model):
    nom="Data Specifications"
    dataset=models.CharField(max_length=20)
    variable=models.CharField(max_length=20)
    label=models.CharField(max_length=50)
    data_type = models.CharField(max_length=20) 
    length = models.CharField(max_length=5) 
    significant_digit = models.CharField(max_length=5)
    format = models.CharField(max_length=42)
    mandatory = models.CharField(max_length=3)
    codelist = models.CharField(max_length=20)
    origin = models.CharField(max_length=20)
    pages = models.CharField(max_length=5)
    method = models.CharField(max_length=20)
    derivation = models.TextField(max_length=400) 
    predecessor = models.CharField(max_length=20)
    role = models.CharField(max_length=20)
    comment = models.CharField(max_length=100)
	
    derivation = models.TextField(max_length=400) 
	
    study = models.ForeignKey('Study', on_delete=models.CASCADE)							
    objet = models.ForeignKey('Objet', on_delete=models.CASCADE)	
		
    class Meta:
        verbose_name = "Data Specifications"
 
    
    def __str__(self):
        """ 
        Cette méthode que nous définirons dans tous les modèles
        nous permettra de reconnaître facilement les différents objets que 
        nous traiterons plus tard dans l'administration
        """
        return  '%s %s' % (self.dataset, self.variable)

	


class ListCode(models.Model):
    nom="Code List"
	
    variable= models.CharField(max_length=30) 
    label= models.CharField(max_length=30) 	
	
    codelist = models.CharField(max_length=100)
    type = models.CharField(max_length=15)
    order = models.CharField(max_length=4)	
    term = models.CharField(max_length=200)
    termcode = models.CharField(max_length=30)
    decode = models.TextField(max_length=400) 
	
    study = models.ForeignKey('Study', on_delete=models.CASCADE)							
    objet = models.ForeignKey('Objet', on_delete=models.CASCADE)	
		
    class Meta:
        verbose_name = "Code List"
 
    def __str__(self):
        
        return  '%s %s' % (self.variable, self.codelist)
 	
		
class Description(models.Model):
    nom="Description"
    
    label= models.CharField(max_length=50)
    type = models.CharField(max_length=30)
    description = models.TextField(max_length=400) 
    ex_context = models.CharField(max_length=30)
    ex_code = models.CharField(max_length=30)
    document = models.CharField(max_length=30)
    pages = models.CharField(max_length=30) 
	 
	 
    variable=models.CharField(max_length=30)
    study = models.ForeignKey('Study', on_delete=models.CASCADE)							
    objet = models.ForeignKey('Objet', on_delete=models.CASCADE)	
		
    class Meta:
        verbose_name = "Description"
 
    def __str__(self):
        
        return   self.variable 
 	
	

from django import forms

 
##File uploader
class Document(models.Model):
    description = models.CharField(max_length=255, blank=True)
    document = models.FileField(upload_to='documents/')
    uploaded_at = models.DateTimeField(auto_now_add=True)
  
###DOMAIN SELECTION
    ADAE = 'ADAE'
    ADSL = 'ADSL'
    ADVS = 'ADVS'
    ADLB = 'ADLB'
    ADEG = 'ADEG'
    ADPC = 'ADPC'
    ADPP = 'ADPP'
    DM = 'DM'
    EG = 'EG'
    VS = 'VS'
    AE = 'AE'
    SV = 'SV'
    LB = 'LB'
    TA = 'TA'	
	  
    DOMAIN_CHOICES = (
        (ADAE, 'ADAE'),
        (ADSL, 'ADSL'),
        (ADVS, 'ADVS'),
        (ADLB, 'ADLB'),
        (ADEG, 'ADEG'),
        (ADPC, 'ADPC'),
        (ADPP, 'ADPP'),
        (DM, 'DM'),
        (EG, 'EG'),
        (VS, 'VS'),
        (AE, 'AE'),
        (SV, 'SV'),
        (LB, 'LB'),
        (TA, 'TA')
    )
	
    domain = models.CharField(
        max_length=20,
        choices=DOMAIN_CHOICES,
        default=ADSL,
    )


	###TYPE SELECTION 
	
	
    SDTM = 'SDTM'
    ADAM = 'ADAM'
    RAW = 'RAW'	
	  
    TYPE_CHOICES = (
        (SDTM, 'SDTM'),
        (ADAM, 'ADAM'),
        (RAW, 'RAW')
    )
	
    type = models.CharField(
        max_length=5,
        choices=TYPE_CHOICES,
        default=ADAM,
    ) 	
	
    def __str__(self):
        return  '%s %s' % (self.id,  self.document.name)      	
		
    
		

class Graph(models.Model):
    nom = models.CharField(max_length=30)
    title = models.TextField(max_length=400) 
    req_var = models.TextField(max_length=400)

    def __str__(self):
        return self.nom
		
		
class Dataset(models.Model):
    nom = models.CharField(max_length=30)
    title = models.TextField(max_length=400) 
    req_var = models.TextField(max_length=400)
    type=models.CharField(max_length=20)   
    def __str__(self):
        return self.nom




		
		
		