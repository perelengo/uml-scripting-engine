# uml-scripting-engine
Executes uml transformations defined with a profile.


This project is part of https://www.samsara-software.es tools and has been freed in honor to my newborn daughter.

To use this tool, need to use the uml2qvto profile available at [net.samsarasoftware.metamodels 0.2.1](https://github.com/perelengo/net.samsarasoftware.metamodels/tree/net.samsarasoftware.metamodels-0.2.1) version's repository, or eclipse update-site http://updates.samsara-software.es/eclipse/

As soon as possible I have more time, will add info on how to use it in simple and advanced modes.


## How-to
The transpiler can generate internal or external transformations.

Internal transformations are applied to the same model the profile is applied to.

External transformations are applied to external models.

## Execution parameters

-script 	<path to uml model with the uml2qvto profile applied> 

-model 		<path to uml model the transform will be applied to. If not defined or is the same as the script model, the script model is used and is treated as an internal transformation.> 

-dep 		<QVTO dependencies (not profiles) Input URI. A Transformation may need a fixed number of input files and a variable number of profiles. In this case, the input files should be passed as -dep and the profiles as -in parameters>

-in ... <additional profiles Input URI>

-in ...

-inout 	<additional URIs of files that are input and output at the same time>

-inout ...

-inout ...

-out 		<additional URIs of files that are output files>

### Qvto utility funcions

When you need to define additional functions or transformations, apply to the Model element the profile "uml2qvto:QvtoAdditionalOperations" and write in the tagged value "qvto" the QVTO code that you want to insert in the output QVTO.

Example qvto: (Returns all enumerations in the model whose name is "Enumeration1")

  query getEnumeration1Literals( model : uml::Model ) : Set ( EnumerationLiteral ) {

    return model.allOwnedElements()->selectByType(uml::Enumeration)->any(e | e.name = 'Enumeration1' ).ownedLiteral

  }


### Structuring the transformation

You can use the "uml2qvto:Ignore" stereotype to structure elements that won't be processed by the scripting engine. For example: You want to group different templates in packages. Each of this packages should be stereotyped with "uml2qvto:Ignore" so the engine will ignore them.
  
  
### Templating content

When an element in the script model is stereotyped with the "uml2qvto:QvtoTemplate" stereotype, all of its sub-elements are processed for-each of the elements in the sequence defined in the "selector" tagged value.

#### uml2qvto:QvtoTemplate Stereotype usage

The "selector" tagged value is a qvto code/query than mut be/return a Collection of elements to process.

The "target" tagged value is the qvto code/query that will be used as the destiny of applying the template. 

-It can be "model" -> the template results will be appended to the input model

-It can be a query invocation.

-It can be the XMI:ID of the element where you want to append the results of the template.

Every QvtoTemplate generates a forEach loop where the current element can be referenced with the "__elem"+template nesting level. For example:

If you apply a QvtoTemplate to a package where the selector returns all classes in an input model package, the template will generate a package for-each of the classes fond, and the current input model class can be referenced using the __elem1 variable.
Then if inside the QvtoTemplate'd package you have another class with another QvtoTemplate, you can use the __elem1 and __elem2 variable references.


### Querying elements

Sometimes you need to reference elements in a dynamic way, for example, want to create associations between a fixed class and a dynamic number of classes. As UML diagram forces to select the dynamic end as an UML element, you can apply to it the "uml2qvto:Query" stereotype to convert this element in a dynamic element, resulting as the result of the query execution.

For example, you want to create a Component realization form a component to another. To do that, create two components, each stereotyped with the Query stereotype whose "query" tagged value contains a qvto function that returns the desired elements. Then create a ComponentRealization in the script UML between these two components and stereotype it with QvtoTemplate.

### Updating content
TO-DO

### Removing content
TO-DO

## Run
JDK > 1.7

java -cp "./target/dist/lib/*;./target/dist/uml-scripting-engine-0.2.0-SNAPSHOT.jar"  net.samsarasoftware.scripting.ScriptingEngine

  -script < path to uml model with the uml2qvto profile applied >
  
  -model <path to uml model the transform will be applied to. If not defined or is the same as the script model, the script model is used and is treated as an internal transformation.>
  
  -in <QVTO dependencies Input URI (metamodel URI, uml primitive types model URI,...)>
  
  -in ...
  
  -in ...
  
  -inout <additional URIs of files that are input and output at the same time>
  
  -inout ...
  
  -inout ...
  
  -out <additional URIs of files that are output files>
  
  
  
### Note on input/output URIs
In windows filesystems, backslash (\\) separators are mandatory to avoid confusion with PDE plugins or platform URIs.
Filesystem URIs must contain full path.

### Example of an internal transformation
java -cp "./target/dist/lib/*;./target/dist/uml-scripting-engine-0.2.0-SNAPSHOT.jar"  net.samsarasoftware.scripting.ScriptingEngine

  -script < path to uml model with the uml2qvto profile applied >
  
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
 
 



## Components
### uml2qvto.xsl
Transpiles the uml2qvto profile applications to a qvto 

#### Development requirements
It is necessary to clone and execute mvn clean install on [net.samsarasoftware.install-dependencies](https://github.com/perelengo/net.samsarasoftware.install-dependencies) to install all eclipse plugins dependencies as maven dependencies.

To develop the uml2qto.xsl: JDK>=1.7 + Xalan-2.7.1 + org.apache.bsf:bsf:2.4 + org.mozilla:rhino:1.17.12



### net.samsarasoftware.scripting.ScriptingEngine
Processes the input UML scripting model to generate the corresponding qvto, and then executes the qvto transformation.


#### Development requirements
It is necessary to clone and execute mvn clean install on [net.samsarasoftware.install-dependencies](https://github.com/perelengo/net.samsarasoftware.install-dependencies) to JDK>=1.7
