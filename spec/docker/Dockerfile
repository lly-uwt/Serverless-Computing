FROM openjdk:8
COPY serverless-lambda-1.0.0.jar /
COPY daemon.sh /
RUN mkdir /specjvm2008
RUN cd /specjvm2008 ; jar xf ../serverless-lambda-1.0.0.jar
ENTRYPOINT ["/daemon.sh"]
CMD ["20"]

