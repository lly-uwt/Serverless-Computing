Some Maven commands:
```sh
mvn clean package -U # -U update snapshots - help remove the artifacts from old build?
mvn clean install -U # similar to clean package - put final jar into local .m2 repo
mvn versions:use-latest-versions
mvn versions:display-plugin-updates
mvn dependency:purge-local-repository # help remove the artifacts from old build?
```
Build local Maven repository:
```
mvn clean install:install-file -Dfile=specjvm.jar -DgroupId=uwt -DartifactId=specjvm -Dversion=1.0 -Dpackaging=jar -DlocalRepositoryPath=${basedir}/maven-local-repo
```
http://www.mojohaus.org/versions-maven-plugin/

Benchmarks that don't work on AWS Lambda:
- derby: due to IO directory path error
- xml.transform and xml.validation: unable to find xml.validation and xml.tranform directories in resources