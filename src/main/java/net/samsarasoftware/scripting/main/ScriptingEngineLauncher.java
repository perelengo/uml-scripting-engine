package net.samsarasoftware.scripting.main;



import java.io.File;
import java.io.FileInputStream;
import java.util.ArrayList;
import java.util.List;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.ResourceSet;

import net.samsarasoftware.scripting.ScriptingEngine;
import net.samsarasoftware.scripting.qvto.In;
import net.samsarasoftware.scripting.qvto.InOut;
import net.samsarasoftware.scripting.qvto.Out;
import net.samsarasoftware.scripting.qvto.Param;


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

public class ScriptingEngineLauncher {

	private String SCRIPT_MODEL = null;
	private String TARGET_MODEL = null;
	private List<Param> INPUT=new ArrayList<Param>();
	private List<String> IN=new ArrayList<String>();
	private List<String> INOUT=new ArrayList<String>();
	private List<String> OUT=new ArrayList<String>();
	private ResourceSet resourceSet;
	private ScriptingEngine engine;
	private String INPUT_OBJECTS=null;

	private void printUsage() throws Exception {
		throw new Exception("Errores en los argumentos. Uso:\n \n "
				+ "java -jar uml-scripting-engine-0.2.0-SNAPSHOT-jar-with-dependencies.jar \n " 
					+ "	-script 	<path to uml model with the uml2qvto profile applied> \n "
					+ "	-model 		<path to uml model the transform will be applied to. If not defined or is the same as the script model, the script model is used and is treated as an internal transformation.> \n "
					+ "	-dep 		<QVTO dependencies Input URI (metamodel URI, uml primitive types model URI,...)> \n "
					+ "	-in ... \n "
					+ "	-in ... \n "
					+ "	-inout 		<additional URIs of files that are input and output at the same time> \n "
					+ "	-inout ... \n "
					+ "	-inout ... \n "
					+ "	-out 		<additional URIs of files that are output files> \n "
					+ "	-params 	<additional inut object mappings that are not files : package1:Package;class1:Class > \n "
				);
	}

	public ScriptingEngineLauncher() {
		this.engine=new ScriptingEngine();
	}
	
	public void parseParams(String[] args) throws Exception {
		if (args.length < 4)
			printUsage();

		for (int i = 0; i < args.length; i++) {
			if ("-script".equals(args[i])) {
				SCRIPT_MODEL = args[++i];
				TARGET_MODEL = (TARGET_MODEL==null)?SCRIPT_MODEL:TARGET_MODEL;
			}else if("-model".equals(args[i])){
				TARGET_MODEL = args[++i];
			}else if("-dep".equals(args[i])){
				if(!new File(args[i+1]).exists())
					INPUT.add(new In(URI.createURI(args[++i])));
				else
					INPUT.add(new In(URI.createFileURI(args[++i])));
			}else if("-in".equals(args[i])){
				IN.add(args[i]);
				if(!new File(args[i+1]).exists())
					INPUT.add(new In(URI.createURI(args[++i])));
				else
					INPUT.add(new In(URI.createFileURI(args[++i])));
			}else if("-inout".equals(args[i])){
				INOUT.add(args[i]);

				if(!new File(args[i+1]).exists())
					INPUT.add(new InOut(URI.createURI(args[++i])));
				else
					INPUT.add(new InOut(URI.createFileURI(args[++i])));
			}else if("-out".equals(args[i])){
				if(!new File(args[i+1]).exists())
					INPUT.add(new Out(URI.createURI(args[++i])));
				else
					INPUT.add(new Out(URI.createFileURI(args[++i])));

				OUT.add(args[i]);
			}else if("-params".equals(args[i])){
				INPUT_OBJECTS = args[++i];
			}else{
				printUsage();
			}
		}
	}


	public static void main(String[] args) {
		ScriptingEngineLauncher s = new ScriptingEngineLauncher();
		try {
			s.parseParams(args);
		} catch (Exception e) {
			e.printStackTrace();
			System.exit(1);
		}
		
		File qvto = null;

		try {
			qvto= s.runCompile();
		} catch (Exception e) {
			e.printStackTrace();
			System.exit(2);
		}

		try {
			s.runTransform(qvto);
		} catch (Exception e) {
			e.printStackTrace();
			System.exit(3);
		}

		
	}

	public File runCompile() throws Exception {
		FileInputStream fis=null;
		try{
			fis=new FileInputStream(SCRIPT_MODEL);
			return engine.runCompile(fis, IN, INOUT, OUT,INPUT_OBJECTS);
		}finally {
			if(fis!=null) try { fis.close(); } catch(Exception e) {}
		}
	}

	public void runTransform(File qvto) throws Exception {
		INPUT.add(0,new InOut(URI.createFileURI(TARGET_MODEL)));
		engine.runTransformStandalone(qvto, INPUT);
	}
	
    public void registerPackages(ResourceSet resourceSet) {
    	engine.registerPackagesStandalone(resourceSet);
    }

    public void registerResourceFactories(ResourceSet resourceSet) {
    	engine.registerResourceFactories(resourceSet);

    }

}
