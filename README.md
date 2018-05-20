Some Maven commands:
```
mvn clean package
mvn versions:use-latest-versions
mvn versions:display-plugin-updates
```
Build Maven repository:
```
mvn install:install-file -Dfile=specjvm.jar -DgroupId=uwt -DartifactId=specjvm -Dversion=1.0 -Dpackaging=jar -DlocalRepositoryPath=${basedir}/maven-local-repo
```
http://www.mojohaus.org/versions-maven-plugin/