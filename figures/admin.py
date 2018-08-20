from django.contrib import admin
from .models import  Document,Output,Study
# Register your models here.
 

@admin.register(Document)
class DocumentAdmin(admin.ModelAdmin):
    pass

 
@admin.register(Output)
class OutputAdmin(admin.ModelAdmin):
    fields = ('domain','title')