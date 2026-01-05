from django.urls import path
from . import views

urlpatterns = [
    path("", views.home, name="home"),            # ✅ ROOT → home.html
    path("upload/", views.upload_dataset, name="upload"),
    path("dashboard/", views.index, name="index"), # index.html moved to /dashboard/
]
