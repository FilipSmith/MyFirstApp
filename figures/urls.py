from django.urls import path 
from django.conf.urls import url, include
from . import views
from django.conf.urls.static import static
from django.conf import settings

urlpatterns = [
    path('', views.index, name='index'),
    path('test', views.test, name='test'),
    path('upload', views.model_form_upload, name='model_form_upload'),
  ###   path('upload_tmp', views.upload_file, name='upload_file'),	
    path('getData/<slug:doc_id>', views.getData, name='getData'),  
    path('data_visu/<str:domain>/<str:graff>', views.data_visu, name='data_visu'), 
    path('getData/infoVar/<str:domain>/<str:var>/', views.infoVar, name='infovar'), 	
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)