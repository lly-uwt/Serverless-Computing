FROM openjdk:8
#RUN apt-get update
#RUN apt-get install -y openjdk-8-jdk
COPY serverless-lambda-1.0.0.jar /
COPY test.sh /
RUN mkdir /specjvm2008
RUN cd /specjvm2008 ; jar xf ../serverless-lambda-1.0.0.jar
ENTRYPOINT ["/test.sh"]
CMD ["20"]
#CMD ["/usr/bin/java","-cp","lambda_test-1.0-SNAPSHOT.jar","uwt.lambda_test","10000000","0","1",""]

