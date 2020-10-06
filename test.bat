cd C:\samsara-workspace\net.samsarasoftware\uml-scripting-engine\
mvn -o -Dmaven.surefire.debug="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=8000 -Xnoagent -Djava.compiler=NONE" clean test
pause
