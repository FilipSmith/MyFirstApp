from django.contrib import admin
from django.urls import include, path

urlpatterns = [
    path('figures/', include('figures.urls')),
    path('admin/', admin.site.urls),
]