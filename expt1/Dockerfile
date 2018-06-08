FROM openjdk:8
RUN mkdir /specjvm2008
COPY serverless-lambda-1.0.0.jar /specjvm2008
RUN cd /specjvm2008 ; jar xf serverless-lambda-1.0.0.jar ; rm serverless-lambda-1.0.0.jar
