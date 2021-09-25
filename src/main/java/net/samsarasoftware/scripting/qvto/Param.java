package net.samsarasoftware.scripting.qvto;

import org.eclipse.emf.common.util.EList;

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

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.m2m.qvt.oml.BasicModelExtent;

/**
 * Basic URI Model Extent, to be loaded and saved.
 *
 */
public class Param extends BasicModelExtent{
		protected URI uri;
		
		public Param(String uri) {
			super();
			this.uri=URI.createURI(uri);
		}
		public Param(URI uri) {
			super();
			this.uri=uri;
			
		}
    	public URI getUri() {
    		return uri;
    	}
    	
    	/**
    	 * Initializes the content provided in the URI
    	 * 
    	 * @param resourceSet
    	 */
		public void initialize(ResourceSet resourceSet) {
			if(getContents()==null || getContents().isEmpty()) {
				//Si es una URI debemos cargar el contenido
				Resource inResource = resourceSet.getResource(uri, true);
				EList<EObject> inObjects = inResource.getContents();
				setContents(inObjects);
			}
		}
    	
    }

