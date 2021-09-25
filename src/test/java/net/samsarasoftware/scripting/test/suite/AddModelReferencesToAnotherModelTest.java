package net.samsarasoftware.scripting.test.suite;



import static org.junit.Assert.fail;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.URL;
import java.util.HashSet;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.eclipse.ocl.ParserException;
import org.eclipse.uml2.uml.NamedElement;
import org.eclipse.uml2.uml.Package;
import org.eclipse.uml2.uml.UMLPackage;
import org.eclipse.uml2.uml.internal.impl.ModelImpl;
import org.junit.Test;

import net.samsarasoftware.scripting.test.utils.ExternalTransformationTestBase;
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
 * Tests the application of a profile to keep references to original elements of a transformation 
 * @author pere joseph rodríguez
 *
 */
public class AddModelReferencesToAnotherModelTest extends ExternalTransformationTestBase {
	File outFile;
	String modelViewPath=null;
	 
	@Test
	public void testProfileApplication() throws ParserException{
	
		String viewContainersQuery="self.oclAsType(Model).allOwnedElements()->select(e | not e.oclAsType(Element).getAppliedStereotype('modelview::ViewContainer').oclIsUndefined())";
		String viewElementsQuery="self.oclAsType(Element).allOwnedElements()->select(e | not e.oclAsType(Element).getAppliedStereotype('modelview::ViewOf').oclIsUndefined())";
		HashSet viewContainers = (HashSet) oclTool.evaluateQuery(viewContainersQuery,resultModel);
		for (Object containerObject: viewContainers) {
			org.eclipse.uml2.uml.Package viewContainer=(Package) containerObject;
			HashSet views=(HashSet) oclTool.evaluateQuery(viewElementsQuery,viewContainer);
			System.out.println("Found ViewContainer with name: "+viewContainer.getName());

			for (Object viewObject : views) {
				NamedElement view=(NamedElement) viewObject;
				System.out.println("Found View with name: "+view.getName());
			}
			
		}
		System.out.println("done");
	}
	
	@Override
	protected void prepareValidation(ResourceSet transformedResourceSet2) {
		try{
			//get the transformed resource
			Resource resource = transformedResourceSet.getResource(URI.createFileURI(outFile.getPath()), true);
			//get the context classifier
			resultModel=(ModelImpl) EcoreUtil.getObjectByType(resource.getContents(),UMLPackage.Literals.MODEL);
			// create an OCLTool
			oclTool=new OCLTool((EClass) resultModel.eClass(), transformedResourceSet.getPackageRegistry());
		} catch (Exception e) {
			e.printStackTrace();
			System.exit(5);
		}
	}

	@Override
	public void customInitialize() {
		
		try {
			//initialize an output empty model
			outFile=File.createTempFile(outputModelPath.getName()+"_out_", ".uml");
			FileOutputStream fos=new FileOutputStream(outFile);
			String emptyModel="<?xml version=\"1.0\" encoding=\"UTF-8\"?><uml:Model xmi:version=\"20131001\" xmlns:xmi=\"http://www.omg.org/spec/XMI/20131001\" xmlns:uml=\"http://www.eclipse.org/uml2/5.0.0/UML\" xmi:id=\"AddModelReferencesToAnotherModelOutputModel\" name=\"AddModelReferencesToAnotherModelOutputModel\"></uml:Model>";
			fos.write(emptyModel.getBytes("UTF-8"));
			fos.close();
			
			
			String internalScriptPath=this.getClass().getSimpleName()+"/script.uml";
			URL scriptUrl = this.getClass().getResource(internalScriptPath);
			if(scriptUrl!=null)
				scriptPath=scriptUrl.getPath();
			else
				fail("Faled to get resource: "+internalScriptPath);
			
			//Load the modelview path
			String internalModelViewProfilePath=this.getClass().getSimpleName()+"/modelview.profile.uml";
			URL inputModelViewProfileUrl = this.getClass().getResource(internalModelViewProfilePath);
			
			
			if(inputModelViewProfileUrl!=null){
				
				if (inputModelViewProfileUrl != null)
					modelViewPath = inputModelViewProfileUrl.getPath();
				else
					fail("Faled to get resource: " + internalModelViewProfilePath);
			}else{
				fail("Faled to get resource: "+internalModelViewProfilePath);
			}
		} catch (IOException e) {
			e.printStackTrace();
			System.exit(6);
		}
	}
	
	@Override
	protected String[] getTransformArgs() {
		return new String[]{
				"-script"
				,scriptPath
				,"-model"
				,outFile.getAbsolutePath()
				,"-dep"
				,"pathmap://UML_LIBRARIES/UMLPrimitiveTypes.library.uml"
				,"-dep"
				,modelViewPath
				,"-in"
				,outputModelPath.getPath()
		};
	}

}
