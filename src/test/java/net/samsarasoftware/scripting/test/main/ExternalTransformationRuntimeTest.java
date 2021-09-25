package net.samsarasoftware.scripting.test.main;



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
import org.junit.Test;

import net.samsarasoftware.scripting.ScriptingEngine;
import net.samsarasoftware.scripting.main.ScriptingEngineLauncher;
import net.samsarasoftware.scripting.test.utils.OCLTool;

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
 * Tests the runtime for external transformations
 * @author pere joseph rodríguez
 *
 */
public class ExternalTransformationRuntimeTest {

	String script=null;
	File outputModel=null;
	
	@Before
	public void initialize(){
		String internalScriptPath=this.getClass().getSimpleName()+"/script.uml";
		URL scriptUrl = this.getClass().getResource(internalScriptPath);
		if(scriptUrl!=null)
			script=scriptUrl.getPath();
		else
			fail("Faled to get resource: "+internalScriptPath);
		
		
		String internalInputModelPath=this.getClass().getSimpleName()+"/model_in.uml";
		URL inputModelUrl = this.getClass().getResource(internalInputModelPath);
		if(inputModelUrl!=null){
			
			
			try {
				outputModel = File.createTempFile(this.getClass().getSimpleName()+"-model_out", ".uml");
				FileOutputStream tempCopyFileOutputStream = new FileOutputStream(outputModel);
				IOUtils.copy(inputModelUrl.openStream(), tempCopyFileOutputStream);
				
				if (scriptUrl != null)
					script = scriptUrl.getPath();
				else
					fail("Faled to get resource: " + internalScriptPath);
				
			} catch (IOException e) {
				fail(e.getMessage());
			}
		}else{
			fail("Faled to get resource: "+internalInputModelPath);
		}
		
	}
	
	
	@Test
	public void run() {

		
		ScriptingEngineLauncher scriptingEngine = new ScriptingEngineLauncher();
		
		runTransform(scriptingEngine);
		
		ResourceSet trasnformedResourceSet = refreshResourceSet(scriptingEngine);
		
		OCLTool oclTool = null;
		ModelImpl modelEClassifier = null;
		try{
			//get the transformed resource
			Resource resource = trasnformedResourceSet.getResource(URI.createFileURI(outputModel.getPath()), true);
			//get the context classifier
			modelEClassifier=(ModelImpl) EcoreUtil.getObjectByType(resource.getContents(),UMLPackage.Literals.MODEL);
			// create an OCLTool
			oclTool=new OCLTool((EClass) modelEClassifier.eClass(), trasnformedResourceSet.getPackageRegistry());
		} catch (Exception e) {
			e.printStackTrace();
			System.exit(5);
		}
		
		
		try {
			String validation1="self.name='"+this.getClass().getSimpleName()+"'";
			if( ((boolean)oclTool.evaluateQuery(validation1,modelEClassifier))!=true )
				fail("Vaidation failed: "+validation1);
		} catch (ParserException e) {
			fail(e.getMessage());
			e.printStackTrace();
		}
	}

	private ResourceSet refreshResourceSet(ScriptingEngineLauncher scriptingEngine) {
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

	private void runTransform(ScriptingEngineLauncher scriptingEngine) {
		String[] args = new String[]{
				"-script"
				,script
				,"-model"
				,outputModel.getPath()
				,"-dep"
				,"pathmap://UML_LIBRARIES/UMLPrimitiveTypes.library.uml"
		};
		
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
}
