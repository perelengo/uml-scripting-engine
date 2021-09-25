package net.samsarasoftware.scripting.qvto;

import java.util.List;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.m2m.qvt.oml.ModelExtent;

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
 * Adapts a current Resorce to be used on a QVTO.
 * 
 */
public class ModelExtentAdapter implements ModelExtent{

	private Resource adapted;

	public ModelExtentAdapter(Resource adapted) {
		this.adapted=adapted;
	}
	
	@Override
	public List<EObject> getContents() {
		return adapted.getContents();
	}
	
	@Override
	public void setContents(List<? extends EObject> arg0) {
		adapted.getContents().clear();
		adapted.getContents().addAll(arg0);
	}
}
