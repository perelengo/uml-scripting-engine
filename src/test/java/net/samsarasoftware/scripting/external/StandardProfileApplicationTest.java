package net.samsarasoftware.scripting.external;



import java.net.URL;

import org.junit.Before;

import net.samsarasoftware.scripting.ScriptingEngine;

import org.junit.*;
import static org.junit.Assert.*;

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

public class StandardProfileApplicationTest {

	String script=null;
	String inputModel=null;
	
	@Before
	public void initialize(){
		String internalScriptPath="/"+this.getClass().getSimpleName()+"/script.uml";
		URL scriptUrl = this.getClass().getResource(internalScriptPath);
		if(scriptUrl!=null)
			script=scriptUrl.getPath();
		else
			fail("Faled to get resource: "+internalScriptPath);
		
		
		String internalInputModelPath="/"+this.getClass().getSimpleName()+"/model_in.uml";
		URL inputModelUrl = this.getClass().getResource(internalInputModelPath);
		if(inputModelUrl!=null)
			inputModel=inputModelUrl.getPath();
		else
			fail("Faled to get resource: "+internalInputModelPath);
	}
	
	
	@Test
	public void run() {

		ScriptingEngine.main(new String[]{
				"-script"
				,script
				,"-model"
				,inputModel
				,"-in"
				,"pathmap://UML_LIBRARIES/UMLPrimitiveTypes.library.uml"
				,"-in"
				,"pathmap://UML_PROFILES/Standard.profile.uml"
		});
		
	}
}
