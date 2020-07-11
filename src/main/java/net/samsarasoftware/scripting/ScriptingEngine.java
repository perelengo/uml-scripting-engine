package net.samsarasoftware.scripting;



import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileFilter;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.net.URLClassLoader;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Enumeration;
import java.util.List;
import java.util.Map;
import java.util.jar.JarEntry;
import java.util.jar.JarFile;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.eclipse.emf.common.EMFPlugin;
import org.eclipse.emf.common.util.Diagnostic;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.plugin.EcorePlugin;
import org.eclipse.emf.ecore.plugin.EcorePlugin.ExtensionProcessor;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.eclipse.m2m.qvt.oml.ExecutionContextImpl;
import org.eclipse.m2m.qvt.oml.ExecutionDiagnostic;
import org.eclipse.uml2.uml.Profile;
import org.eclipse.uml2.uml.UMLPackage;
import org.eclipse.uml2.uml.UMLPlugin;
import org.eclipse.uml2.uml.resource.UMLResource;

import net.samsarasoftware.scripting.qvto.In;
import net.samsarasoftware.scripting.qvto.InOut;
import net.samsarasoftware.scripting.qvto.InternalTransformationExecutor;
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

public class ScriptingEngine {

	public String MODEL;
	public String OUTPUT;
	public List<Param> INPUT=new ArrayList<Param>();


	private void parseParams(String[] args) throws Exception {
		if (args.length < 4)
			printUsage();

		for (int i = 0; i < args.length; i++) {
			if ("-model".equals(args[i])) {
					MODEL = args[++i];
			}else if("-in".equals(args[i])){
				if(args[i+1].contains(":/"))
					INPUT.add(new In(URI.createURI(args[++i])));
				else
					INPUT.add(new In(URI.createFileURI(args[++i])));
			}else if("-inout".equals(args[i])){
				if(args[i+1].contains(":/"))
					INPUT.add(new InOut(URI.createURI(args[++i])));
				else
					INPUT.add(new InOut(URI.createFileURI(args[++i])));
			}else if("-out".equals(args[i])){
				if(args[i+1].contains(":/"))
					INPUT.add(new Out(URI.createURI(args[++i])));
				else
					INPUT.add(new Out(URI.createFileURI(args[++i])));
			}else{
				printUsage();
			}
		}
	}

	private void printUsage() throws Exception {
		throw new Exception("Errores en los argumentos. Uso:\n java -jar <nombrejar>.jar \n "
				+ "[-model <path to the UML model>\n " + "[-output <path to qvto output>]" + "");
	}

	private ByteArrayOutputStream runCompile() throws Exception {
		try {
			
			//Inicio de transformación XSL
			TransformerFactory factory = TransformerFactory.newInstance();
			ByteArrayOutputStream baos = new ByteArrayOutputStream();
			InputStream bais = new ByteArrayInputStream(baos.toByteArray());
			Source xslt = new StreamSource(bais);
			Transformer transformer = factory.newTransformer(xslt);

			Source text = new StreamSource(new File(MODEL));
			ByteArrayOutputStream baosXsl=new ByteArrayOutputStream();
			transformer.transform(text, new StreamResult(baosXsl));
			
			return baosXsl;
			
		} catch (Exception e) {
			e.printStackTrace();
			throw e;
		}
	}
	
	private void runTransform(ByteArrayOutputStream baosXsl) throws Exception {
		try {
			
			//Inicio de transformación QVTO
			InternalTransformationExecutor executor = new InternalTransformationExecutor(baosXsl.toByteArray());

			ExecutionContextImpl context = new ExecutionContextImpl();
			ResourceSet resourceSet = new ResourceSetImpl();
			registerResourceFactories(resourceSet);
			registerPackages(resourceSet);

			
			INPUT.add(new InOut(URI.createFileURI(MODEL)));

			for (Param inputURI : INPUT) {
				resourceSet.getURIConverter().getURIMap();
				Resource inResource = resourceSet.getResource(inputURI.getUri(), true);
				EList<EObject> inObjects = inResource.getContents();
				inputURI.setContents(inObjects);
			}
			


			ExecutionDiagnostic result = executor.execute(context,  INPUT.toArray(new Param[INPUT.size()]));

			if (result.getSeverity() == Diagnostic.OK) {
				for (Param modelExtent : INPUT) {
					if(modelExtent instanceof InOut
							|| modelExtent instanceof Out){
						List<EObject> outObjects = modelExtent.getContents();
						ResourceSet resourceSet2 = new ResourceSetImpl();
						Resource outResource = resourceSet2
								.getResource(modelExtent.getUri(), true);
						outResource.getContents().clear();
						outResource.getContents().addAll(outObjects);
						outResource.save(Collections.emptyMap());
						
//						//PJR: Al ser un entorno standalone, las URLs de los perfiles se transforman a URLs del sistema de ficheros.
//						//Convertimos las URLs del sistema de ficheros al URLs de plugin de la plataforma
//						InputStream fis=new FileInputStream(modelExtent.getUri().toFileString());
//						ByteArrayOutputStream baos3=new ByteArrayOutputStream();
//						byte buf[]=new byte[10240];
//						int readed=0;
//						while((readed=fis.read(buf))!=-1){
//							baos3.write(buf,0,readed);
//						}
//						try{
//							fis.close();
//						}catch(Exception e){}
//						
//						String content=baos3.toString();
//						String replacedContent;
//						String replacedContent2;
//						replacedContent=content.replaceAll("jar([^\\s]*)net.samsarasoftware.metamodels([^\\s]*)jar!", "platform:/plugin/net.samsarasoftware.metamodels");
//						replacedContent=replacedContent.replaceAll("jar([^\\s]*)Standard.profile.uml#_0", "pathmap://UML_PROFILES/Standard.profile.uml#_0");
//						FileOutputStream fos=new FileOutputStream(modelExtent.getUri().toFileString());
//						fos.write(replacedContent.getBytes());
//						try{
//							fos.close();
//						}catch(Exception e){}
						
					}

				}
			} else {
				System.err.println(result.getMessage());
			}
			
			
			
		} catch (Exception e) {
			e.printStackTrace();
			throw e;
		}
	}

	public static void main(String[] args) {
		ScriptingEngine s = new ScriptingEngine();
		try {
			s.parseParams(args);
		} catch (Exception e) {
			e.printStackTrace();
			System.exit(1);
		}
		
		ByteArrayOutputStream baos = null;

		try {
			baos= s.runCompile();
		} catch (Exception e) {
			e.printStackTrace();
			System.exit(2);
		}

		try {
			s.runTransform(baos);
		} catch (Exception e) {
			e.printStackTrace();
			System.exit(3);
		}

		
	}


	/**
     * Registers all content that needs to be referenced in XMI files or xmi imported files and dependencies, such as standard uml packages, standard profiles and user defined profiles.
     * 
     * @param resourceSet
     *            The resource set which registry has to be updated.
     *
     */
    public void registerPackages(ResourceSet resourceSet) {
        
        
        Map uriMap = resourceSet.getURIConverter().getURIMap();

        //All this block is key to register properly the URL handlers of the references in xmi files
        //All this stuff is necessary to workin standalone mode (without eclipse), but also enables the application to run inside eclipse
        //resolving references of type plugin and of type resource, in maven projects, whose compiled resources are usually in target/classes folder
        if(!EMFPlugin.IS_ECLIPSE_RUNNING){
        	String[] cpFiles=null;
        	
        	URLClassLoader classLoader=(URLClassLoader) (Thread.currentThread().getContextClassLoader());
            ExtensionProcessor.process(classLoader);
            	
            String classpath = null;
            try
            {
            	URL[] ucp=classLoader.getURLs();
    	        cpFiles=new String[ucp.length];

            	for (int i=0;i<ucp.length;i++) {
					cpFiles[i]=ucp[i].toString();
				}
            }
            catch (Throwable throwable)
            {
              // Failing thet, get it from the system properties.
              throwable.printStackTrace();
              classpath = System.getProperty("java.class.path");
              cpFiles=classpath.split(";");
            }
        	
	        Pattern bundleSymbolNamePattern = Pattern.compile("^\\s*Bundle-SymbolicName\\s*:\\s*([^\\s;]*)\\s*(;.*)?$", Pattern.MULTILINE);
	        
	        for (String filePath : cpFiles) {
	        	InputStream inputStream = null;
	            try
	            {
		        	
		        	byte bytes[]=new byte[1024];
		        	String pluginID=null;
		        	URI baseUri=null;
		        	
		        	String basePath = filePath;
		        	String baseURL=null;
		        	
		            if(basePath.endsWith(".jar")){
		             	try{
		             		try{
		             			baseURL="file:/"+basePath+"!/META-INF/MANIFEST.MF";
		             			inputStream = new URL("jar:file:/"+basePath+"!/META-INF/MANIFEST.MF").openStream();
		             		}catch(Exception e1){
		             			baseURL=basePath+"!/META-INF/MANIFEST.MF";
		             			inputStream = new URL("jar:"+baseURL).openStream();
		             		}
		             		
		             		
		             	}catch(Exception e){}
		            }else{
	             		try{
	             			baseURL="file:///"+basePath+"/META-INF/MANIFEST.MF";
	             			inputStream = new URL(baseURL).openStream();
	             		}catch(Exception e1){
	             			try{
	             				baseURL=basePath+"/META-INF/MANIFEST.MF";
	             				inputStream = new URL(baseURL).openStream();
		             		}catch(Exception e2){ //check for local compiled plugins
			             		try{
			             			baseURL=URI.createURI(new URL("file:///"+basePath).toString()).trimSegments(1).toString()+"/META-INF/MANIFEST.MF";
			             			inputStream = new URL(baseURL).openStream();
			             		}catch(Exception e3){
			             			try{
			             				baseURL=URI.createURI(new URL(basePath).toString()).trimSegments(1).toString()+"/META-INF/MANIFEST.MF";
			             				inputStream = new URL(baseURL).openStream();
				             		}catch(Exception e4){ //Check for local maven compiled plugins
					             		try{
					             			baseURL=URI.createURI(new URL("file:///"+basePath).toString()).trimSegments(2).toString()+"/META-INF/MANIFEST.MF";
					             			inputStream = new URL(baseURL).openStream();
					             		}catch(Exception e5){
					             			try{
					             				baseURL=URI.createURI(new URL(basePath).toString()).trimSegments(2).toString()+"/META-INF/MANIFEST.MF";
					             				inputStream = new URL(baseURL).openStream();
						             		}catch(Exception e6){
							             		try{
							             			baseURL=URI.createURI(new URL("file:///"+basePath).toString()).trimSegments(3).toString()+"/META-INF/MANIFEST.MF";
							             			inputStream = new URL(baseURL).openStream();
							             		}catch(Exception e7){
							             			try{
							             				baseURL=URI.createURI(new URL(basePath).toString()).trimSegments(3).toString()+"/META-INF/MANIFEST.MF";
							             				inputStream = new URL(baseURL).openStream();
								             		}catch(Exception e8){
								             			
								             		}
							             		}
						             		}
					             		}
				             		}
			             		}		             			
		             		}
	             		}
		            }
		            if (inputStream!=null)
		            {
		                int available = inputStream.available();
		                if (bytes.length < available)
		                {
		                  bytes = new byte [available];
		                }
		                inputStream.read(bytes);
		                String contents = new String(bytes, "UTF-8");
		                Matcher matcher = bundleSymbolNamePattern.matcher(contents);
		                if (matcher.find())
		                {
		                	pluginID = matcher.group(1);
		                	URI platformPluginURI = URI.createPlatformPluginURI(pluginID +"/", false);
		                	URI platformResourceURI = URI.createPlatformResourceURI(pluginID +"/",  true);
		                	if(!resourceSet.getURIConverter().exists(platformPluginURI, null)){
		                	 	  
			                  	  
			                  	  if(baseURL.indexOf(pluginID)!=-1){
				                	  Object resolvedURL=null;
				                	  
				                	  if(!basePath.endsWith(".jar")){
				                		  
				                		  resolvedURL=baseURL.substring(0,
				                				  baseURL.indexOf(pluginID)+pluginID.length()+1);
				                		  if(EcorePlugin.getPlatformResourceMap().get(pluginID)==null)
				                			  EcorePlugin.getPlatformResourceMap().put(pluginID, 
							                		URI.createURI((String) resolvedURL)
					                		  );
						                  //aqui puede ser que tengamos una referencia plugin o una referencia resource->classes
				                		  //hacia un solo proyecto. El problema es que para la referencia resource tenemos el directorio target/classes
				                		  //pero para la referencia plugin no.
				                		  //asi que cogemos del path
						                  uriMap.put(platformPluginURI, URI.createURI(basePath));
						                  uriMap.put(platformResourceURI, URI.createURI((String) resolvedURL));
						                  
						                  File resolvedDir=new File(resolvedURL.toString().replace("file:/",""));
					                	  registeProfilesDir(resourceSet, resolvedDir);
				                	  }else{
				                		  resolvedURL="jar:"+baseURL.substring(0,
				                				  baseURL.indexOf("!")+2);
				                		  if(EcorePlugin.getPlatformResourceMap().get(pluginID)==null)
				                			  EcorePlugin.getPlatformResourceMap().put(pluginID, 
							                		URI.createURI((String) resolvedURL)
					                		  );

				                		 
				                		  uriMap.put(platformPluginURI, URI.createURI((String) resolvedURL));
				                		  uriMap.put(platformResourceURI.trimSegments(1).appendSegment("target").appendSegment("classes").appendSegment(""), URI.createURI((String) resolvedURL));
				                		  
				                		  registerJarProfiles(resourceSet, (String) baseURL.substring(0,baseURL.indexOf("!")).replace("file:/", ""));
				                	  }
				                  		
		                	  		}
		                	}
		                }
		            }
	            }catch (Exception exception)
	              {
	            	  exception.printStackTrace();
	              }
	              finally
	              {
	                if (inputStream != null)
	                {
	                  try
	                  {
	                    inputStream.close();
	                  }
	                  catch (IOException exception)
	                  {
	                	  exception.printStackTrace();
	                  }
	                }
	              }
	            }
        }
        //URI platformPluginURI = URI.createPlatformPluginURI(pluginID + "/", false);
        //URI platformResourceURI = URI.createPlatformResourceURI(project.getName() + "/",  true);
        //result.put(platformPluginURI, platformResourceURI);

        
        //EList<URIHandler> uriHandlers = resourceSet.getURIConverter().getURIHandlers();
    	//uriHandlers.add(0, new ClasspathURIHandler());
    	
        
        //Register basic libraries uri handlers
        String resourcesPlugin = "org/eclipse/uml2/uml/resources/ResourcesPlugin.class";
        URL url = this.getClass().getClassLoader().getResource( resourcesPlugin );
        String baseUrl = url.toString();    
        baseUrl = baseUrl.substring( 0, baseUrl.length() - resourcesPlugin.length() );
        URI baseUri=URI.createURI(baseUrl);
        uriMap.put(URI.createURI( UMLResource.LIBRARIES_PATHMAP ), baseUri.appendSegment( "libraries" ).appendSegment( "" ));
        uriMap.put(URI.createURI( UMLResource.METAMODELS_PATHMAP ), baseUri.appendSegment( "metamodels" ).appendSegment( "" ));
        uriMap.put(URI.createURI( UMLResource.PROFILES_PATHMAP ), baseUri.appendSegment( "profiles" ).appendSegment( "" ));
        try {
			registerJarProfiles(resourceSet,baseUrl.replace("jar:file:/","").replace("!/", ""));
		} catch (IOException e) {
			e.printStackTrace();
		}
  
        UMLPlugin.getEPackageNsURIToProfileLocationMap().put(org.eclipse.uml2.uml.profile.standard.StandardPackage.eINSTANCE.getNsURI()
        		, URI.createURI("pathmap://UML_PROFILES/Standard.profile.uml#_0"));

        //Registers all profiles in the folder configured in the environment variable PROFILE_LIB
        String libFolderPath=System.getenv("PROFILE_LIB");
        if(libFolderPath!=null){
	        File libFolder=new File(libFolderPath);
	        registeProfilesDir(resourceSet, libFolder);
        }

        //PJR - Para cargar un profile din?aicamente:
        //Resource simpleMMResource0 = resourceSet.getResource(URI.createURI("file:///"+alFolder.getAbsolutePath().replaceAll("\\\\","/")+"/ActionLanguage-Profile.profile.uml"), true);
        //resourceSet.getPackageRegistry().put("http://www.omg.org/spec/ALF/20120827/ActionLanguage-Profile",((Profile)EcoreUtil.getObjectByType(simpleMMResource0.getContents(),UMLPackage.Literals.PROFILE)).getDefinition());
       

    }

    /**
     * Searches all .profile.uml files compressed in a jar, and registers them to the UML profile registry.
     * @param resourceSet
     * @param jarFilePath
     * @throws IOException
     */
    private void registerJarProfiles(ResourceSet resourceSet, String jarFilePath) throws IOException {
    	JarFile jarFile=new java.util.jar.JarFile(jarFilePath);
    	Enumeration jarEntries=jarFile.entries();
    	JarEntry entry;
		while(jarEntries.hasMoreElements()){
			entry=(JarEntry) jarEntries.nextElement();
    		if(entry.getName().endsWith("profile.uml")){
    			registerProfile(resourceSet, URI.createURI("jar:file:/"+jarFilePath+"!/"+entry.getName()));
    		}
    	}
	}

    /**
     * Searches all .profile.uml files in a dir and all its .jar files, and registers them to the UML profile registry. 
     * @param resourceSet
     * @param libFolder
     */
	private void registeProfilesDir(ResourceSet resourceSet, File libFolder) {

        File[] libs=libFolder.listFiles(new FileFilter() {
			@Override
			public boolean accept(File pathname) {
				return pathname.getAbsolutePath().endsWith(".profile.uml") || pathname.isDirectory();
			}
		});
        
        if(libs!=null){
            for(int i=0;i<libs.length;i++){
                if(libs[i].isDirectory()){
                	registeProfilesDir(resourceSet,libs[i]);
                }else{
                	registerProfile(resourceSet, URI.createURI("file:///"+libs[i].getAbsolutePath()));
                }
            }
        }
        
        File[] jars=libFolder.listFiles(new FileFilter() {
			@Override
			public boolean accept(File pathname) {
				return pathname.getAbsolutePath().endsWith(".jar");
			}
		});
        if(jars!=null){
	        for(int i=0;i<jars.length;i++){
	        	try {
					registerJarProfiles(resourceSet, jars[i].getAbsolutePath());
				} catch (IOException e) {
					e.printStackTrace();
				}
	           
	        }
        }
        
        File[] directories=libFolder.listFiles(new FileFilter() {
			@Override
			public boolean accept(File pathname) {
				return pathname.isDirectory();
			}
		});
        if(directories!=null){
	        for(int i=0;i<directories.length;i++){
	        		registeProfilesDir(resourceSet, directories[i]);
	        }
        }
	}
	
	/**
	 * Registers a profile to the UML profiles registry.
	 * @param resourceSet
	 * @param uri
	 */
    private void registerProfile(ResourceSet resourceSet, URI uri) {
        Resource profileResource = resourceSet.getResource(uri, true);
        Profile profile=((Profile)EcoreUtil.getObjectByType(profileResource.getContents(),UMLPackage.Literals.PROFILE));
        
        if(profile!=null && profile.getURI()!=null){
        	EPackage.Registry.INSTANCE.put(profile.getURI().toString(),profile.getDefinition());
			UMLPlugin.getEPackageNsURIToProfileLocationMap().put(profile.getURI().toString(),EcoreUtil.getURI(profile.getDefinition()) );
			System.out.println("-- Registering profile "+profile.getURI().toString()+" ("+EcoreUtil.getURI(profile.getDefinition())+")");
        }
	}

	/**
     * Registers the .uml extension handler
     * @param resourceSet
     *            The resource set which registry has to be updated.
     *
     */
    public void registerResourceFactories(ResourceSet resourceSet) {
        resourceSet.getResourceFactoryRegistry().getExtensionToFactoryMap().put(UMLResource.FILE_EXTENSION, UMLResource.Factory.INSTANCE);

    }

}
