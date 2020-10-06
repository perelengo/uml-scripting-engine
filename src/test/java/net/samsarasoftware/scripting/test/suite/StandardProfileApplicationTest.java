package net.samsarasoftware.scripting.test.suite;



import org.junit.Test;
import static org.junit.Assert.fail;

import org.eclipse.ocl.ParserException;

import net.samsarasoftware.scripting.test.utils.ExternalTransformationTestBase;

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
 * Tests the Standard Profile application as an internal transformation 
 * @author pere joseph rodríguez
 *
 */
public class StandardProfileApplicationTest extends ExternalTransformationTestBase {

		
	 
	@Test
	public void testProfileApplication() throws ParserException{
		if(!(boolean)oclTool.evaluateQuery("self.profileApplication->exists( p | p.appliedProfile.name='StandardProfile')",resultModel))
			fail("StandardProfile not applied");
	}
	
	@Override
	protected String[] getTransformArgs() {
		return new String[]{
				"-script"
				,scriptPath
				,"-model"
				,outputModelPath.getPath()
				,"-in"
				,"pathmap://UML_LIBRARIES/UMLPrimitiveTypes.library.uml"
				,"-in"
				,"pathmap://UML_PROFILES/Standard.profile.uml"
		};
	}

}
