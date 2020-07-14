# uml-scripting-engine
Executes uml transformations defined with a profile.
Contains unfinished code.

This project is part of https://www.samsara-software.es tools and has been freed in honor to my newborn daughter.

To use this tool, need to use the uml2qvto profile available at [net.samsarasoftware.metamodels 0.2.0](https://github.com/perelengo/net.samsarasoftware.metamodels/tree/net.samsarasoftware.metamodels-0.2.0) version's repository, or eclipse update-site http://updates.samsara-software.es/eclipse/

As soon as possible I have more time, will add info on how to use it in simple and advanced modes.

## Run
JDK > 1.7
java -cp "./target/dist/lib/*;./target/dist/uml-scripting-engine-0.2.0-SNAPSHOT.jar"  net.samsarasoftware.scripting.ScriptingEngine
  -script <path to uml model with the uml2qvto profile applied>
  -model <path to uml model the transform will be applied to. If not defined or is the same as the script model, the script model is used and is treated as an internal transformation.>
  -in <QVTO dependencies Input URI (metamodel URI, uml primitive types model URI,...)>
  -in ...
  -in ...
  -inout <additional URIs of files that are input and output at the same time>
  -inout ...
  -inout ...
  -out <additional URIs of files that are output files>
  
### Note on input/output URIs
In windows filesystems, backslash (\) separators are mandatory to avoid confusion with PDE plugins or platform URIs.
Filesystem URIs must contain full path.

### Example of an internal transformation
java -cp "./target/dist/lib/*;./target/dist/uml-scripting-engine-0.2.0-SNAPSHOT.jar"  net.samsarasoftware.scripting.ScriptingEngine
  -script <path to uml model with the uml2qvto profile applied>
  -in "pathmap://UML_LIBRARIES/UMLPrimitiveTypes.library.uml"
  -in "pathmap://UML_PROFILES/Standard.profile.uml"
  -in "c:\temp\myprofile.profile.uml"
  -in "platform:/plugin/plugin-id/path/my.profile.uml"

### Example of an external transformation
java -cp "./target/dist/lib/*;./target/dist/uml-scripting-engine-0.2.0-SNAPSHOT.jar"  net.samsarasoftware.scripting.ScriptingEngine
 -script C:\samsara-workspace\net.samsarasoftware\uml-scripting-engine\src\test\uml\test1\model\stacks.uml 
 -model C:\samsara-workspace\net.samsarasoftware\uml-scripting-engine\src\test\uml\test1\out\stacks.uml
 -in pathmap://UML_LIBRARIES/UMLPrimitiveTypes.library.uml
 -in pathmap://UML_PROFILES/Standard.profile.uml
 -in platform:/plugin/net.samsarasoftware.metamodels/profiles/dojo.profile.uml
 -in platform:/plugin/net.samsarasoftware.metamodels/profiles/transaction.profile.uml
 -in platform:/plugin/net.samsarasoftware.metamodels/profiles/database.profile.uml
 -in platform:/plugin/net.samsarasoftware.metamodels/profiles/http.profile.uml


## How-to
The transpiler can generate internal or external transformations.
Internal transformations are applied to the same model the profile is applied to.
External transformations are applied to external models.

### Internal transformations
TO-DO

### External transformations
TO-DO

### Querying elements
TO-DO

### Temlating content
TO-DO

### Updating content
TO-DO

### Removing content
TO-DO

## Components
### uml2qvto.xsl
Transpiles the uml2qvto profile applications to a qvto transformation.
This transformation is finished and works.

#### Development requirements
It is necessary to clone and execute mvn clean install on [net.samsarasoftware.install-dependencies](https://github.com/perelengo/net.samsarasoftware.install-dependencies) to install all eclipse plugins dependencies as maven dependencies.
To develop the uml2qto.xsl: JDK>=1.7 + Xalan-2.7.1 + org.apache.bsf:bsf:2.4 + org.mozilla:rhino:1.17.12



### net.samsarasoftware.scripting.ScriptingEngine
Processes the input UML scripting model to generate the corresponding qvto, and then executes the qvto transformation.
The XSLexecution code needs testing, because haven't tested already since the inclusion of the BSF libraries.
The qvto execution code works.

#### Development requirements
It is necessary to clone and execute mvn clean install on [net.samsarasoftware.install-dependencies](https://github.com/perelengo/net.samsarasoftware.install-dependencies) to JDK>=1.7
