# uml-scripting-engine
Executes uml transformations defined with a profile.
Contains unfinished code.

This project is part of https://www.samsara-software.es tools and has been freed in honor to my newborn daughter.

To use this tool, need to use the profile available at net.samsarasoftware.metamodels 0.2.0 version's repository, or eclipse update-site http://updates.samsara-software.es/eclipse/

As soon as possible I have more time, will add info on how to use it in simple and advanced modes.





# uml2qvto.xsl
Transpiles the uml2qvto profile applications to a qvto transformation.
This transformation is finished and works.
Has been tested in eclipse with apache xalan 2.7.1 and needs BSF 2.4 engine and bsf-3.1-all.jar in the execution classpath.


# net.samsarasoftware.scripting.ScriptingEngine
Processes the input UML scripting model to generate the corresponding qvto, and then executes the qvto transformation.
The XSLexecution code needs testing, because haven't tested already since the inclusion of the BSF libraries.
The qvto execution code works.


