package net.samsarasoftware.scripting.qvto;

/*-
 * #%L
 * net.samsarasoftware.scripting.qvto
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


import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.io.UnsupportedEncodingException;
import java.util.Collections;
import java.util.List;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.URIConverter;
import org.eclipse.m2m.internal.qvt.oml.QvtPlugin;
import org.eclipse.m2m.internal.qvt.oml.compiler.DelegatingUnitResolver;
import org.eclipse.m2m.internal.qvt.oml.compiler.ResolverUtils;
import org.eclipse.m2m.internal.qvt.oml.compiler.UnitContents;
import org.eclipse.m2m.internal.qvt.oml.compiler.UnitProxy;
import org.eclipse.m2m.internal.qvt.oml.compiler.UnitResolver;






	public  class ByteArrayUnitResolver extends DelegatingUnitResolver {


		public ByteArrayUnitResolver() {
		}

		private final class SUnit extends UnitProxy {

			private byte[] qvto;

			private SUnit(byte[] qvto) {
				//Create fake params just to execute.
				super("net.samsarasoftware","internalQvtoTransform",URI.createURI("plugin://new.samsarasoftware/uml-scripting-engine/qvto"));
				this.qvto = qvto;
			}
			
			@Override
			public int getContentType() {
				return UnitProxy.TYPE_CST_STREAM;
			}

			@Override
			public UnitContents getContents() throws IOException {
				return new UnitContents.CSTContents() {
					public Reader getContents() throws IOException {
						try {
							return new InputStreamReader(new ByteArrayInputStream(qvto), "UTF-8"); //$NON-NLS-1$
						} catch (Exception e) {
							throw new IOException(e.getMessage());
						}
						
					}
				};
			}

			@Override
			public UnitResolver getResolver() {
				return ByteArrayUnitResolver.this;
			}
		}
		

			
		@Override
		protected UnitProxy doResolveUnit(String qualifiedName) {
			return null;
		}


		protected UnitProxy doResolveUnit(byte[] qvto) {
			try {
				return new SUnit(qvto);
			} catch(RuntimeException e) {
				QvtPlugin.getDefault().log(e);
			} 
			
			return null;
		}
	}
