# Nagios-running-container
Install nagios under container as like watchdog for your infra.Few proactive or monitoring steps can save your infra DT

#To build your image from given Dockerfile :
   docker build -t nagios-container-image:v1 .
 
#To spin up your container with created above image :
   docker run -it --name nagios-container nagios-container-image
