package net.samsarasoftware.scripting;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EClassifier;
import org.eclipse.emf.ecore.EOperation;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.eclipse.emf.ecore.EPackage.Registry;
import org.eclipse.ocl.OCL;
import org.eclipse.ocl.ParserException;
import org.eclipse.ocl.ecore.Constraint;
import org.eclipse.ocl.ecore.EcoreEnvironmentFactory;
import org.eclipse.ocl.expressions.OCLExpression;
import org.eclipse.ocl.helper.OCLHelper;
import org.eclipse.uml2.uml.UMLPackage;
import org.eclipse.uml2.uml.internal.impl.ModelImpl;

public class OCLTool {
	//initialize the OCL tooling
	OCL<?, EClassifier, EOperation, EStructuralFeature, ?, ?, ?, ?, ?, Constraint, ?, ?> ocl = null;
	OCLHelper<EClassifier, EOperation, EStructuralFeature, Constraint> helper = null;
	ModelImpl modelEClassifier = null;
			
	public OCLTool(EClassifier context, Registry packageRegistry) {
			//Initialize OCL system as explained at https://help.eclipse.org/2020-06/index.jsp?topic=%2Forg.eclipse.ocl.doc%2Fhelp%2FParsingDocuments.html
			EcoreEnvironmentFactory environmentFactory = new EcoreEnvironmentFactory(packageRegistry);
			ocl = OCL.newInstance(environmentFactory);
			// create an OCL helper object
			helper = ocl.createOCLHelper();
			//set the helper context
			helper.setContext(context);
	}

	public Object evaluateQuery(String oclQueryString, Object context) throws ParserException {
		OCLExpression<EClassifier> query;
		query = helper.createQuery(oclQueryString);
		return ocl.evaluate(context, query);
	}


}
