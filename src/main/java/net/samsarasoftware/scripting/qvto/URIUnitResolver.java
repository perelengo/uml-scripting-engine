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

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.URIConverter;
import org.eclipse.m2m.internal.qvt.oml.QvtPlugin;
import org.eclipse.m2m.internal.qvt.oml.compiler.BlackboxUnitResolver;
import org.eclipse.m2m.internal.qvt.oml.compiler.ClassPathUnitResolver;
import org.eclipse.m2m.internal.qvt.oml.compiler.CompositeUnitResolver;
import org.eclipse.m2m.internal.qvt.oml.compiler.DelegatingUnitResolver;
import org.eclipse.m2m.internal.qvt.oml.compiler.ResolverUtils;
import org.eclipse.m2m.internal.qvt.oml.compiler.UnitContents;
import org.eclipse.m2m.internal.qvt.oml.compiler.UnitProxy;
import org.eclipse.m2m.internal.qvt.oml.compiler.UnitResolver;





	public  class URIUnitResolver extends DelegatingUnitResolver {

		private final class Unit extends UnitProxy {

			protected final URI fURI;

			protected Unit(String namespace, String unitName, URI unitURI) {
				super(namespace, unitName, unitURI);
				this.fURI = unitURI;
			}
			
			@Override
			public int getContentType() {
				return UnitProxy.TYPE_CST_STREAM;
			}

			@Override
			public UnitContents getContents() throws IOException {
				return new UnitContents.CSTContents() {
					public Reader getContents() throws IOException {
						InputStream is = URIConverter.INSTANCE.createInputStream(fURI);
						try {
							return new InputStreamReader(is,"UTF-8");
						} catch (Exception e) {
							throw new IOException(e.getMessage());
						}
						
					}
				};
			}

			@Override
			public UnitResolver getResolver() {
				return URIUnitResolver.this;
			}
		}
		

		protected List<URI> fBaseURIs;
		
		public URIUnitResolver(URI baseURI) {
			this(Collections.singletonList(baseURI));
		}
				
		public URIUnitResolver(List<URI> baseURIs) {
			if(baseURIs == null || baseURIs.contains(null)) {
				throw new IllegalArgumentException();
			}
			
			fBaseURIs = new ArrayList<URI>(baseURIs.size());

			for (URI uri : baseURIs) {
				URI normalizedURI = uri;
				if(!normalizedURI.hasTrailingPathSeparator()) {
					// Note: URI represents the empty segment as trailing path separator
					normalizedURI = normalizedURI.appendSegment(""); //$NON-NLS-1$
				}
				
				fBaseURIs.add(normalizedURI);
			}
			
			// enable resolution of black-box module dependencies and classpath imports
			setParent(new CompositeUnitResolver(
					BlackboxUnitResolver.DEFAULT,
					ClassPathUnitResolver.INSTANCE)
			);		
		}
			
		@Override
		protected UnitProxy doResolveUnit(String qualifiedName) {
			for (URI baseURI : fBaseURIs) {
				UnitProxy unit = doResolveUnit(baseURI, qualifiedName);
				if(unit != null) {
					return unit;
				}
			}
			
			return null;
		}

		protected UnitProxy doResolveUnit(URI baseURI, String qualifiedName) {
			try {
				String namespace = null;
				String[] nameSegments = ResolverUtils.getNameSegments(qualifiedName);
				if(nameSegments.length > 1) {
					namespace = ResolverUtils.toQualifiedName(nameSegments, 0, nameSegments.length - 2);
				}
		
				String unitFilePath = ResolverUtils.toNamespaceRelativeUnitFilePath(qualifiedName);
				URI unitURI = URI.createURI(unitFilePath).resolve(baseURI);
				if(!URIConverter.INSTANCE.exists(unitURI, Collections.EMPTY_MAP)) {
					return null;
				}
				
				String unitName = nameSegments[nameSegments.length - 1];
				return new Unit(namespace, unitName, unitURI);
			} catch(RuntimeException e) {
				QvtPlugin.getDefault().log(e);
			} 
			
			return null;
		}
	}
