package net.samsarasoftware.scripting.qvto;


//Modification of org.eclipse.m2m.internal.qvt.oml.InternalTransformationExecutor
/*******************************************************************************
 * Copyright (c) 2009, 2015 R.Dvorak and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     Radek Dvorak - initial API and implementation
 *     Christopher Gerking - bug 431082
 *     Pere Joseph - Allow extension mecanism for standalone mode https://bugs.eclipse.org/bugs/show_bug.cgi?id=514167
*******************************************************************************/

import static org.eclipse.m2m.internal.qvt.oml.emf.util.EmfUtilPlugin.isSuccess;

import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.util.ArrayList;
import java.util.List;

import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.NullProgressMonitor;
import org.eclipse.core.runtime.SubMonitor;
import org.eclipse.emf.common.util.BasicDiagnostic;
import org.eclipse.emf.common.util.BasicMonitor;
import org.eclipse.emf.common.util.Diagnostic;
import org.eclipse.emf.common.util.DiagnosticChain;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EClassifier;
import org.eclipse.emf.ecore.EEnumLiteral;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EOperation;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.EParameter;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.m2m.internal.qvt.oml.ExecutionDiagnosticImpl;
import org.eclipse.m2m.internal.qvt.oml.Messages;
import org.eclipse.m2m.internal.qvt.oml.NLS;
import org.eclipse.m2m.internal.qvt.oml.QvtMessage;
import org.eclipse.m2m.internal.qvt.oml.ast.env.InternalEvaluationEnv;
import org.eclipse.m2m.internal.qvt.oml.ast.env.ModelExtentContents;
import org.eclipse.m2m.internal.qvt.oml.ast.env.ModelParameterExtent;
import org.eclipse.m2m.internal.qvt.oml.ast.env.QvtEvaluationResult;
import org.eclipse.m2m.internal.qvt.oml.ast.env.QvtOperationalEnv;
import org.eclipse.m2m.internal.qvt.oml.ast.env.QvtOperationalEnvFactory;
import org.eclipse.m2m.internal.qvt.oml.ast.env.QvtOperationalEvaluationEnv;
import org.eclipse.m2m.internal.qvt.oml.ast.env.QvtOperationalFileEnv;
import org.eclipse.m2m.internal.qvt.oml.ast.env.QvtOperationalStdLibrary;
import org.eclipse.m2m.internal.qvt.oml.common.MdaException;
import org.eclipse.m2m.internal.qvt.oml.compiler.CompiledUnit;
import org.eclipse.m2m.internal.qvt.oml.compiler.CompilerUtils;
import org.eclipse.m2m.internal.qvt.oml.compiler.DelegatingUnitResolver;
import org.eclipse.m2m.internal.qvt.oml.compiler.QVTOCompiler;
import org.eclipse.m2m.internal.qvt.oml.compiler.UnitProxy;
import org.eclipse.m2m.internal.qvt.oml.emf.util.EmfUtil;
import org.eclipse.m2m.internal.qvt.oml.evaluator.EvaluationMessages;
import org.eclipse.m2m.internal.qvt.oml.evaluator.InternalEvaluator;
import org.eclipse.m2m.internal.qvt.oml.evaluator.ModelInstance;
import org.eclipse.m2m.internal.qvt.oml.evaluator.ModelParameterHelper;
import org.eclipse.m2m.internal.qvt.oml.evaluator.QVTEvaluationOptions;
import org.eclipse.m2m.internal.qvt.oml.evaluator.QvtException;
import org.eclipse.m2m.internal.qvt.oml.evaluator.QvtInterruptedExecutionException;
import org.eclipse.m2m.internal.qvt.oml.evaluator.QvtRuntimeException;
import org.eclipse.m2m.internal.qvt.oml.evaluator.QvtStackOverFlowError;
import org.eclipse.m2m.internal.qvt.oml.expressions.DirectionKind;
import org.eclipse.m2m.internal.qvt.oml.expressions.ImperativeOperation;
import org.eclipse.m2m.internal.qvt.oml.expressions.ModelParameter;
import org.eclipse.m2m.internal.qvt.oml.expressions.Module;
import org.eclipse.m2m.internal.qvt.oml.expressions.OperationalTransformation;
import org.eclipse.m2m.internal.qvt.oml.library.Context;
import org.eclipse.m2m.internal.qvt.oml.trace.Trace;
import org.eclipse.m2m.qvt.oml.ExecutionContext;
import org.eclipse.m2m.qvt.oml.ExecutionDiagnostic;
import org.eclipse.m2m.qvt.oml.ModelExtent;
import org.eclipse.m2m.qvt.oml.util.IContext;
import org.eclipse.m2m.qvt.oml.util.ISessionData;
import org.eclipse.m2m.qvt.oml.util.Log;
import org.eclipse.ocl.EvaluationVisitor;
import org.eclipse.ocl.ecore.CallOperationAction;
import org.eclipse.ocl.ecore.Constraint;
import org.eclipse.ocl.ecore.SendSignalAction;


/**
 * Internal transformation executor
 * 
 * @since 3.0
 */
public  class InternalTransformationExecutor {

	private byte[] qvto;
	private EPackage.Registry fPackageRegistry;
	private CompiledUnit fCompiledUnit;
	private ResourceSet fCompilationRs;
	private ExecutionDiagnostic fLoadDiagnostic;
	private OperationalTransformation fTransformation;
	private QvtOperationalEnvFactory fEnvFactory;
	private Class resolver=null;

	/**
	 * Constructs the executor for the given transformation URI.
	 * <p>
	 * No attempt to resolve and load the transformation is done at this step
	 * 
	 * @param uri
	 *            the URI of an existing transformation
	 */
	public InternalTransformationExecutor(byte[] qvto) {
		this.qvto=qvto;
	}
	
			
	public ResourceSet getResourceSet() {
		return fCompilationRs;
	}
		
	/**
	 * Attempts to load the transformation referred by this executor and checks
	 * if it is valid for execution.
	 * <p>
	 * <b>Remark:</b></br> Only the first performs the actual transformation
	 * loading, subsequent calls to this method will return the existing
	 * diagnostic.
	 * 
	 * @return the diagnostic indicating possible problems of the load action
	 */
	public Diagnostic loadTransformation(IProgressMonitor monitor) {
		try {
			if (fLoadDiagnostic == null) {
				doLoad(monitor);
			}
			return fLoadDiagnostic;
		} 
		finally {
			monitor.done();
		}
	}
	
	/**
	 * Retrieves compiled unit if the referencing URI gets successfully resolved
	 * <p>
	 * <b>Remark</b>: This method invocation causes the referenced transformation to
	 * load if not already done before by direct call to
	 * {@linkplain #loadTransformation()} or
	 * {@linkplain #execute(ExecutionContext, ModelExtent...)}
	 * 
	 * @return compiled unit or <code>null</code> if it failed to be obtained
	 */
	public CompiledUnit getUnit() {
		loadTransformation(new NullProgressMonitor());
		return fCompiledUnit;
	}	

	/**
	 * Executes the transformation referred by this executor using the given
	 * model parameters and execution context.
	 * 
	 * @param executionContext
	 *            the context object keeping the execution environment details
	 * @param modelParameters
	 *            the actual model arguments to the transformation
	 * 
	 * @return the diagnostic object indicating the execution result status,
	 *         also keeping the details of possible problems
	 * @throws IllegalArgumentException
	 *             if the context or any of the model parameters is
	 *             <code>null</code>
	 */
	public ExecutionDiagnostic execute(ExecutionContext executionContext, ModelExtent[] modelParameters) {
		// Java API check for nulls etc.
		if (executionContext == null) {
			throw new IllegalArgumentException();
		}
		
		IProgressMonitor monitor = executionContext.getProgressMonitor();
				
		try {							
			SubMonitor progress = SubMonitor.convert(monitor, "Execute ", 2); //$NON-NLS-1$
						
			checkLegalModelParams(modelParameters);
	
			// ensure transformation unit is loaded
			loadTransformation(progress.newChild(1));
			
			// check if we have successfully loaded the transformation unit
			if (!isSuccess(fLoadDiagnostic)) {
				return fLoadDiagnostic;
			}
	
			try {
				return doExecute(modelParameters,
						createInternalContext(executionContext, progress.newChild(1)));
			} catch (QvtRuntimeException e) {
				Log logger = executionContext.getLog();
				logger.log(EvaluationMessages.TerminatingExecution);
	
				return createExecutionFailure(e);
			}
		} finally {
			if (monitor != null) {
				monitor.done();
			}
		}
	}

	private ExecutionDiagnostic doExecute(ModelExtent[] args, IContext context) {
		QvtOperationalEnvFactory factory = getEnvironmentFactory();
		QvtOperationalEvaluationEnv evaluationEnv = factory
				.createEvaluationEnvironment(context, null);

		ExecutionDiagnostic modelParamsDiagnostic = initArguments(evaluationEnv, fTransformation, args);
		if (!isSuccess(modelParamsDiagnostic)) {
			return modelParamsDiagnostic;
		}

		QvtOperationalFileEnv rootEnv = factory.createEnvironment(fCompiledUnit.getURI());
		EvaluationVisitor<EPackage, EClassifier, EOperation, EStructuralFeature, EEnumLiteral, EParameter, EObject, CallOperationAction, SendSignalAction, Constraint, EClass, EObject> evaluator = factory
				.createEvaluationVisitor(rootEnv, evaluationEnv, null);

		// perform the actual execution
		assert evaluator instanceof InternalEvaluator : "expecting InternalEvaluator implementation"; //$NON-NLS-1$
		InternalEvaluator rawEvaluator = (InternalEvaluator) evaluator;

		Object evalResult = rawEvaluator.execute(fTransformation);
		
		// unpack the internal extents into the passed model parameters
		if (evalResult instanceof QvtEvaluationResult) {
			int extentIndex = 0;
			for (int i = 0; i < fTransformation.getModelParameter().size(); ++i) {
				ModelParameter p = fTransformation.getModelParameter().get(i);
				if (p.getKind() == DirectionKind.IN) {
					continue;
				}
				
				ModelExtentContents extent = ((QvtEvaluationResult) evalResult).getModelExtents().get(extentIndex++);
				args[i].setContents(extent.getAllRootElements());
			}
		}
		else {
			List<Object> resultArgs = evaluationEnv.getOperationArgs();
			int i = 0;
			for (Object nextResultArg : resultArgs) {
				ModelInstance modelInstance = (ModelInstance) nextResultArg;
				ModelParameterExtent extent = modelInstance.getExtent();
	
				List<EObject> allRootElements = extent.getContents().getAllRootElements();
				try {
					args[i++].setContents(allRootElements);
				} catch (UnsupportedOperationException e) {
					return new ExecutionDiagnosticImpl(Diagnostic.ERROR, ExecutionDiagnostic.MODEL_PARAMETER_MISMATCH, 
							NLS.bind(Messages.ReadOnlyExtentModificationError, i - 1));
				}
			}
		}
		
		// do some handy processing with traces
		Trace traces = evaluationEnv.getAdapter(InternalEvaluationEnv.class).getTraces();
		handleExecutionTraces(traces);
		
		return ExecutionDiagnostic.OK_INSTANCE;
	}
	
	protected void handleExecutionTraces(Trace traces) {
		// nothing interesting here
	}

	private void doLoad(IProgressMonitor monitor) {
		fLoadDiagnostic = ExecutionDiagnostic.OK_INSTANCE;

		UnitProxy unit = getUnit(qvto);
		if (unit == null) {
			fLoadDiagnostic = new ExecutionDiagnosticImpl(Diagnostic.ERROR,
					ExecutionDiagnostic.TRANSFORMATION_LOAD_FAILED, NLS.bind(
							Messages.UnitNotFoundError, ""));
			return;
		}

		QVTOCompiler compiler = createCompiler();
		try {
			fCompiledUnit = compiler.compile(unit, null, BasicMonitor.toMonitor(monitor));
			fCompilationRs = compiler.getResourceSet();

			fLoadDiagnostic = createCompilationDiagnostic(fCompiledUnit);

		} catch (MdaException e) {
			fLoadDiagnostic = new ExecutionDiagnosticImpl(Diagnostic.ERROR,
					ExecutionDiagnostic.TRANSFORMATION_LOAD_FAILED, NLS.bind(
							Messages.FailedToCompileUnitError, ""));

			((DiagnosticChain) fLoadDiagnostic).merge(BasicDiagnostic.toDiagnostic(e));
		}

		if (fCompiledUnit != null
				&& isSuccess(fLoadDiagnostic)) {
			fTransformation = getTransformation();
			if (fTransformation == null) {
				fLoadDiagnostic = new ExecutionDiagnosticImpl(Diagnostic.ERROR,
						ExecutionDiagnostic.TRANSFORMATION_LOAD_FAILED, NLS
								.bind(Messages.NotTransformationInUnitError,
										""));
				return;
			}

			ExecutionDiagnostic validForExecution = checkIsExecutable(fTransformation);
			if (!isSuccess(validForExecution)) {
				fLoadDiagnostic = validForExecution;
			}
		}
	}

	protected UnitProxy getUnit(byte[] qvto2) {
			return new ByteArrayUnitResolver().doResolveUnit(qvto2);
	}

	protected DelegatingUnitResolver getResolver(URI uri){
			try {
				
				Constructor constructor=(resolver).getConstructor(new Class[]{URI.class});
				return (DelegatingUnitResolver) constructor.newInstance(new Object[]{uri});
			} catch (NoSuchMethodException | SecurityException | InstantiationException | IllegalAccessException
					| IllegalArgumentException | InvocationTargetException e) {
				throw new RuntimeException(e);
			}
		
		
	}
	public void setResolver(Class resolver){
		this.resolver=resolver;
	}

	protected String getQualifiedName(URI fURI) {
		return fURI.trimFileExtension().lastSegment();
	}

	private ExecutionDiagnostic initArguments(
			QvtOperationalEvaluationEnv evalEnv,
			OperationalTransformation transformationModel, ModelExtent[] args) {

		EList<ModelParameter> modelParameters = transformationModel.getModelParameter();
		if (modelParameters.size() > args.length) {
			return new ExecutionDiagnosticImpl(Diagnostic.ERROR,
					ExecutionDiagnostic.MODEL_PARAMETER_MISMATCH, NLS.bind(
							Messages.InvalidModelParameterCountError,
							args.length, modelParameters.size()));
		}

		ExecutionDiagnostic result = ExecutionDiagnostic.OK_INSTANCE;
		List<ModelParameterExtent> extents = new ArrayList<ModelParameterExtent>(modelParameters.size());

		int argCount = 0;
		for (ModelParameter modelParam : modelParameters) {
			ModelParameterExtent nextExtent;
			ModelExtent nextArg = args[argCount++];

			if (modelParam.getKind() != org.eclipse.m2m.internal.qvt.oml.expressions.DirectionKind.OUT) {
				nextExtent = new ModelParameterExtent(nextArg.getContents(), getResourceSet(), modelParam);
			} else {
				nextExtent = new ModelParameterExtent(getResourceSet());
			}

			evalEnv.addModelExtent(nextExtent);
			extents.add(nextExtent);
		}

		List<ModelInstance> modelArgs = ModelParameterHelper
				.createModelArguments(transformationModel, extents);
		evalEnv.getOperationArgs().addAll(modelArgs);

		return result;
	}

	private  ExecutionDiagnostic checkIsExecutable(
			OperationalTransformation transformation) {
		
		if (transformation.isIsBlackbox()) {
			return ExecutionDiagnostic.OK_INSTANCE;
		}
		
		EList<EOperation> operations = transformation.getEOperations();
		for (EOperation oper : operations) {
			if (oper instanceof ImperativeOperation
					&& QvtOperationalEnv.MAIN.equals(oper.getName())) {
				return ExecutionDiagnostic.OK_INSTANCE;
			}
		}

		return new ExecutionDiagnosticImpl(Diagnostic.ERROR,
				ExecutionDiagnostic.VALIDATION, NLS.bind(
						Messages.NoTransformationEntryPointError,
						transformation.getName()));
	}

	public OperationalTransformation getTransformation() {
		// TODO - cached the transformation selected as main
		if(fCompiledUnit == null) {
			return null;
		}
		
		List<Module> allModules = fCompiledUnit.getModules();
		for (Module module : allModules) {
			if (module instanceof OperationalTransformation) {
				return (OperationalTransformation) module;
			}
		}

		return null;
	}
	
	public void setEnvironmentFactory(QvtOperationalEnvFactory factory) {
		fEnvFactory = factory;
	}

	protected QvtOperationalEnvFactory getEnvironmentFactory() {
		return fEnvFactory != null ? fEnvFactory : new QvtOperationalEnvFactory();
	}
	
	public void cleanup() {
		setEnvironmentFactory(null);
		if (fCompilationRs != null) {
			EmfUtil.cleanupResourceSet(fCompilationRs);
		}
	}


	private  ExecutionDiagnostic createExecutionFailure(
			QvtRuntimeException qvtRuntimeException) {
		int code = 0;
		int severity = Diagnostic.ERROR;
		String message = qvtRuntimeException.getLocalizedMessage();
		Object[] data = null;

		if (qvtRuntimeException instanceof QvtException) {
			code = ((QvtException) qvtRuntimeException).getExceptionType() == QvtOperationalStdLibrary.INSTANCE.getAssertionFailedClass() ?
					ExecutionDiagnostic.FATAL_ASSERTION : ExecutionDiagnostic.EXCEPTION_THROWN;
		} else if (qvtRuntimeException instanceof QvtInterruptedExecutionException) {
			code = ExecutionDiagnostic.USER_INTERRUPTED;
			severity = Diagnostic.CANCEL;
		} else {
			code = ExecutionDiagnostic.EXCEPTION_THROWN;
			if (qvtRuntimeException instanceof QvtStackOverFlowError == false) {
				Throwable cause = qvtRuntimeException.getCause();
				data = new Object[] { cause != null ? cause : qvtRuntimeException };
			} else {
				message = Messages.StackTraceOverFlowError;
			}
		}

		if (message == null) {
			message = NLS.bind(Messages.QVTRuntimeExceptionCaught,
					qvtRuntimeException.getClass().getName());
		}
		ExecutionDiagnosticImpl diagnostic = new ExecutionDiagnosticImpl(severity,
				code, message, data);
		diagnostic.setStackTrace(qvtRuntimeException.getQvtStackTrace());
		return diagnostic;
	}

	private void checkLegalModelParams(ModelExtent[] extents)
			throws IllegalArgumentException {
		if (extents == null) {
			throw new IllegalArgumentException("Null model parameters"); //$NON-NLS-1$
		}

		for (int i = 0; i < extents.length; i++) {
			if (extents[i] == null) {
				throw new IllegalArgumentException(
						"Null model parameter[" + i + "]"); //$NON-NLS-1$ //$NON-NLS-2$
			}
		}
	}

	private  ExecutionDiagnostic createCompilationDiagnostic(
			CompiledUnit compiledUnit) {
		List<QvtMessage> errors = compiledUnit.getErrors();
		if (errors.isEmpty()) {
			return ExecutionDiagnostic.OK_INSTANCE;
		}

		URI uri = compiledUnit.getURI();
		ExecutionDiagnosticImpl mainDiagnostic = new ExecutionDiagnosticImpl(
				Diagnostic.ERROR, ExecutionDiagnostic.VALIDATION, NLS.bind(
						Messages.CompilationErrorsFoundInUnit, uri.toString()));

		for (QvtMessage message : errors) {
			// FIXME - we should include warnings as well
			mainDiagnostic.add(CompilerUtils.createProblemDiagnostic(uri, message));
		}

		return mainDiagnostic;
	}

	private  IContext createInternalContext(ExecutionContext executionContext, IProgressMonitor monitor) {
		Context ctx = new Context();
		ctx.setLog(executionContext.getLog());
		ctx.setProgressMonitor(monitor);

		for (String key : executionContext.getConfigPropertyNames()) {
			Object value = executionContext.getConfigProperty(key);
			ctx.setConfigProperty(key, value);
		}
		
		for (ISessionData.Entry<Object> key : executionContext.getSessionDataEntries()) {
			ctx.getSessionData().setValue(key, executionContext.getSessionData().getValue(key));
		}
		
		org.eclipse.m2m.qvt.oml.util.Trace trace = executionContext.getSessionData().getValue(QVTEvaluationOptions.INCREMENTAL_UPDATE_TRACE);
		if (trace != null) {
			ctx.getTrace().setTraceContent(trace.getTraceContent());
		}

		return ctx;
	}

	@Override
	public String toString() {
		return "QVTO-Executor: " + ""; //$NON-NLS-1$
	}
	
	protected QVTOCompiler createCompiler() {
		if(fPackageRegistry == null) {
			return CompilerUtils.createCompiler();
		}
		
		return QVTOCompiler.createCompiler(fPackageRegistry);
	}

	
}
