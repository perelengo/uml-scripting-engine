package net.samsarasoftware.scripting.test.utils;



import static org.junit.Assert.fail;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.URL;

import org.apache.commons.io.IOUtils;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.eclipse.ocl.ParserException;
import org.eclipse.uml2.uml.UMLPackage;
import org.eclipse.uml2.uml.internal.impl.ModelImpl;
import org.junit.Before;

import net.samsarasoftware.scripting.ScriptingEngine;

/*-
 * #%L
 * net.samsarasoftware.scripting.ScriptingEngine
 * %%
 * Copyright (C) 2014 - 2020 Pere Joseph Rodriguez
 * %%
 * Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
 * #L%
 */

/**
 * Abstract external transformation test
 * @author pere joseph rodríguez
 *
 */
public abstract class ExternalTransformationTestBase {

	protected String 	scriptPath		=null;
	protected File 		outputModelPath	=null;
	protected OCLTool 	oclTool 		=null;
	protected ResourceSet transformedResourceSet = null;
	protected ModelImpl resultModel 	= null;

	@Before
	public void initialize(){
		String internalScriptPath=this.getClass().getSimpleName()+"/script.uml";
		URL scriptUrl = this.getClass().getResource(internalScriptPath);
		if(scriptUrl!=null)
			scriptPath=scriptUrl.getPath();
		else
			fail("Faled to get resource: "+internalScriptPath);
		
		
		String internalInputModelPath=this.getClass().getSimpleName()+"/model_in.uml";
		URL inputModelUrl = this.getClass().getResource(internalInputModelPath);
		if(inputModelUrl!=null){
			
			try {
				outputModelPath = File.createTempFile(this.getClass().getSimpleName()+"-model_out", ".uml");
				FileOutputStream tempCopyFileOutputStream = new FileOutputStream(outputModelPath);
				IOUtils.copy(inputModelUrl.openStream(), tempCopyFileOutputStream);
				
				if (scriptUrl != null)
					scriptPath = scriptUrl.getPath();
				else
					fail("Faled to get resource: " + internalScriptPath);
				
			} catch (IOException e) {
				fail(e.getMessage());
			}
		}else{
			fail("Faled to get resource: "+internalInputModelPath);
		}

		prepareTest();
		
	}
	
	protected void prepareTest() {

		
		ScriptingEngine scriptingEngine = new ScriptingEngine();
		
		runTransform(scriptingEngine);
		
		transformedResourceSet = refreshResourceSet(scriptingEngine);
		
		try{
			//get the transformed resource
			Resource resource = transformedResourceSet.getResource(URI.createFileURI(outputModelPath.getPath()), true);
			//get the context classifier
			resultModel=(ModelImpl) EcoreUtil.getObjectByType(resource.getContents(),UMLPackage.Literals.MODEL);
			// create an OCLTool
			oclTool=new OCLTool((EClass) resultModel.eClass(), transformedResourceSet.getPackageRegistry());
		} catch (Exception e) {
			e.printStackTrace();
			System.exit(5);
		}
		
	}

	private ResourceSet refreshResourceSet(ScriptingEngine scriptingEngine) {
		ResourceSet transformedResourceSet = null;
		try {
			//refresh the ResourceSet with the transformed model
			transformedResourceSet = new ResourceSetImpl();
			scriptingEngine.registerResourceFactories(transformedResourceSet);
			scriptingEngine.registerPackages(transformedResourceSet);
		} catch (Exception e) {
			e.printStackTrace();
			System.exit(4);
		}
		return transformedResourceSet;
	}

	protected void runTransform(ScriptingEngine scriptingEngine) {
		String[] args = getTransformArgs();
		
		try {
			scriptingEngine.parseParams(args);
		} catch (Exception e) {
			e.printStackTrace();
			System.exit(1);
		}
		
		File qvto = null;

		try {
			qvto= scriptingEngine.runCompile();
		} catch (Exception e) {
			e.printStackTrace();
			System.exit(2);
		}

		try {
			scriptingEngine.runTransform(qvto);
		} catch (Exception e) {
			e.printStackTrace();
			System.exit(3);
		}	
	}
	
	/**
	 * Override to generate tests
	 * The args should always start with the following array new String[]{		
				"-script"
				,scriptPath
				,"-model"
				,outputModelPath.getPath()
				,"-in"
				,"pathmap://UML_LIBRARIES/UMLPrimitiveTypes.library.uml"
				};
	 * @return
	 */
	protected abstract String[] getTransformArgs();
}
