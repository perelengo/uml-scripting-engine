<?xml version="1.0" encoding="UTF-8"?>
<!--
  #%L
  uml2qvto.xsl
  %%
  Copyright (C) 2014 - 2020 Pere Joseph Rodriguez
  %%
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
 * #L%
  -->

<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xmi="http://www.omg.org/spec/XMI/20131001"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:uml="http://www.eclipse.org/uml2/5.0.0/UML"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:common="http://exslt.org/common"
	xmlns:ecore="http://www.eclipse.org/emf/2002/Ecore"
    exclude-result-prefixes="common"
    xmlns:xalan="http://xml.apache.org/xslt"
    xmlns:regex="http://www.samsara-software.es/XSLT/extend/regex"
	>

	<!-- Will use a javascript replace function very useful -->
	<xalan:component prefix="regex" functions="replaceAll">
	  <xalan:script lang="javascript">
	    
	    function replaceAll(string, pattern, replace){
	    	var rex=new RegExp(pattern,'g');
	    	return string.replace(rex,replace);
	    }
	    
	  </xalan:script>
	</xalan:component>
	
	<xsl:output method="text" encoding="UTF-8" />
	<xsl:param name="in_files" />
	<xsl:param name="inout_files" />
	<xsl:param name="out_files" />
	<xsl:param name="selection_array" />
	
	<xsl:variable name="root" select="/" />
	<xsl:variable name="umlMetamodel" select="document('metamodels/http__www.eclipse.org_uml2_5_0_0_UML.ecore')"/>
	<xsl:template match="/">
		<xsl:apply-templates select="//uml:Model"></xsl:apply-templates>
	</xsl:template>	






<xsl:template match="//uml:Model">
<!-- 
The template that processes the script and creates the qvto transformation
 -->

<!-- the generated qvto uses at least two metamodels:  uml and umlPrimitiveTypes. -->
modeltype uml uses "<xsl:value-of select="$umlMetamodel//ecore:EPackage[1]/@nsURI"></xsl:value-of>";
modeltype umlPrimitiveTypes uses "http://www.eclipse.org/uml2/5.0.0/UML";


<!-- the transformation name is the name of the script model. -->
transformation <xsl:apply-templates select="@name" mode="normalize-id"/>(
	<!-- the input parameters of the transformation will be:
	the uml file to transform
	the umlPrimitiveTypes model
	the profile definition file of all of the profiles applied to this model.
	 -->
	inout file : uml
	, in umlPrimitiveTypesFile:umlPrimitiveTypes
	<xsl:apply-templates select="//*[namespace-uri()!='http://www.omg.org/spec/XMI/20131001' and namespace-uri()!='' and namespace-uri()!='http://www.eclipse.org/uml2/5.0.0/UML'  and namespace-uri()!='http://www.samsarasoftware.net/uml2qvto.profile']" mode="transformation-profiles-params"/>
	<xsl:variable name="in_files_arr">
		<xsl:call-template name="split">
			<xsl:with-param name="text" select="$in_files"/>
			<xsl:with-param name="splitChar" select="';'"/>
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="inout_files_arr">
		<xsl:call-template name="split">
			<xsl:with-param name="text" select="$inout_files"/>
			<xsl:with-param name="splitChar" select="';'"/>
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="out_files_arr">
		<xsl:call-template name="split">
			<xsl:with-param name="text" select="$out_files"/>
			<xsl:with-param name="splitChar" select="';'"/>
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="selection_array_arr">
		<xsl:call-template name="split">
			<xsl:with-param name="text" select="$selection_array"/>
			<xsl:with-param name="splitChar" select="';'"/>
		</xsl:call-template>
	</xsl:variable>	
		
	<xsl:for-each select="common:node-set($in_files_arr)//text">
		<xsl:if test="not(.='')">
		//<xsl:value-of select="."/> 
		,in inFile<xsl:value-of select="position()"/> : uml
		</xsl:if>
	</xsl:for-each>
	<xsl:for-each select="common:node-set($inout_files_arr)//text">
		<xsl:if test="not(.='')">
		//<xsl:value-of select="."/> 
		,inout inoutFile<xsl:value-of select="position()"/> : uml
		</xsl:if>
	</xsl:for-each>
	<xsl:for-each select="common:node-set($out_files_arr)//text">
		<xsl:if test="not(.='')">
		//<xsl:value-of select="."/> 
		,out outFile<xsl:value-of select="position()"/> : uml
		</xsl:if>
	</xsl:for-each>
	
	
);

<!-- the global variable allModels can be used to resolve external model references -->
property allModels:Collection(uml::Model)=file.objects()->select(e | e.oclIsTypeOf(uml::Model))->any(true).oclAsType(Model).allOwnedElements()->collect(e | e.oclAsType(Element).getRelationships())->collect( e | e.relatedElement)->collect(e | e.getModel())->asSet();
	<xsl:for-each select="common:node-set($in_files_arr)//text">
		<xsl:if test="not(.='')">
//<xsl:value-of select="."/> 
property inModel<xsl:value-of select="position()"/> : Model = inFile<xsl:value-of select="position()"/>.objects()->select(e | e.oclIsTypeOf(uml::Model))->any(true).oclAsType(Model);
		</xsl:if>
	</xsl:for-each>

	<xsl:for-each select="common:node-set($inout_files_arr)//text">
		<xsl:if test="not(.='')">
//<xsl:value-of select="."/> 
property inoutModel<xsl:value-of select="position()"/> : Model = inoutFile<xsl:value-of select="position()"/>.objects()->select(e | e.oclIsTypeOf(uml::Model))->any(true).oclAsType(Model);
		</xsl:if>
	</xsl:for-each>

	<xsl:for-each select="common:node-set($out_files_arr)//text">
		<xsl:if test="not(.='')">
//<xsl:value-of select="."/>
property outModel<xsl:value-of select="position()"/> : Model = outFile<xsl:value-of select="position()"/>.objects()->select(e | e.oclIsTypeOf(uml::Model))->any(true).oclAsType(Model);
		</xsl:if>
	</xsl:for-each>

	<xsl:for-each select="common:node-set($selection_array_arr)//text">
		<xsl:if test="not(.='')">
		<xsl:variable name="selection_map_obj">
			<xsl:call-template name="split">
				<xsl:with-param name="text" select="$selection_array"/>
				<xsl:with-param name="splitChar" select="'#'"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="selection_map" select="common:node-set($selection_map_obj)//text" />
//<xsl:value-of select="."/> 
property <xsl:value-of select="$selection_map[1]"/> : <xsl:value-of select="$selection_map[2]"/>;
		</xsl:if>
	</xsl:for-each>
<!-- the main script of the transformation -->
main(){
	file.objects()->select(e | e.oclIsTypeOf(uml::Model))->forEach(__model){
		var model:uml::Model;
		model:=__model.oclAsType(Model);

	

	<xsl:for-each select="common:node-set($selection_array_arr)//text">
		<xsl:if test="not(.='')">
		<xsl:variable name="selection_map_obj">
			<xsl:call-template name="split">
				<xsl:with-param name="text" select="$selection_array"/>
				<xsl:with-param name="splitChar" select="'#'"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="selection_map" select="common:node-set($selection_map_obj)//text" />
		
		<xsl:choose>
			<xsl:when test="substring($selection_map[3],1,1) =  '{'">
				<xsl:variable name="sequence_arr">
					<xsl:call-template name="split">
						<xsl:with-param name="text" select="$selection_map[3]"/>
						<xsl:with-param name="splitChar" select="'}'"/>
					</xsl:call-template>
				</xsl:variable>	
				<xsl:for-each select="common:node-set($sequence_arr)//text">
					<xsl:if test="not(.='')">
						<xsl:variable name="len" select="string-length($selection_map[3])-2"/>
this.<xsl:value-of select="$selection_map[1]"/> = this.<xsl:value-of select="$selection_map[1]"/>->append(<xsl:value-of select="substring($selection_map[3],2,$len)"/>);
					</xsl:if>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
<xsl:value-of select="$selection_map[1]"/> := <xsl:value-of select="$selection_map[3]"/>;
			</xsl:otherwise>
		</xsl:choose>
		</xsl:if>
	</xsl:for-each>
		
		<!-- apply profiles to the generated model -->
		<xsl:apply-templates select="//*[namespace-uri()!='http://www.omg.org/spec/XMI/20131001' and namespace-uri()!='' and namespace-uri()!='http://www.eclipse.org/uml2/5.0.0/UML'  and namespace-uri()!='http://www.samsarasoftware.net/uml2qvto.profile']" mode="apply-profiles"/>
		
		<!-- invoke the generated transformation -->
		model.map <xsl:apply-templates select="@name" mode="normalize-id"/>(model);
	};
};

/** BEGIN Utility method used in the generated script **/

mapping Element::setStereotypeByQualifiedName(qualifiedStereotypeName : String)  {
	var st:=self.getApplicableStereotype(qualifiedStereotypeName);
	self.applyStereotype(st);
}

mapping Element::setTaggedValueByStereotypeQualifiedName(qualifiedStereotypeName : String, qualifiedTaggedValueName : String, value : OclAny)  {
	var st:=self.getApplicableStereotype(qualifiedStereotypeName);
	self.setValue(st, qualifiedTaggedValueName, value);
}

mapping Element::setTaggedValueByStereotypeQualifiedName(qualifiedStereotypeName : String, qualifiedTaggedValueName : String, value : Collection(String))  {
	var st:=self.getApplicableStereotype(qualifiedStereotypeName);
	Sequence{0..value->size()-1}->forEach(i){
		self.setValue(st, qualifiedTaggedValueName+'['+i.toString()+']', value->asSequence()->at(i+1));
	}
}

query  getStereotype (elem : Element, qualifiedName : String) : Stereotype { 
	elem.getAppliedStereotypes()->select(s | 
		getStereotypeHierarchy(s.oclAsType(Stereotype))
		->exists(sh | 
			sh.oclAsType(Stereotype).qualifiedName=qualifiedName
		)
	)->asSequence()->at(1).oclAsType(Stereotype)
}
query getStereotypeHierarchy(st : Stereotype) : Sequence(Stereotype) { 
	if(st.general->size()>0) then
		st.general->select(u | u.oclIsTypeOf(Stereotype))->collect(u | getStereotypeHierarchy(u.oclAsType(Stereotype)))->asSequence()->append(st)
	else
		Sequence{st}
	endif
}
/** END Utility method used in the generated script **/

/** BEGIN : Reference-resolvers **/
	<xsl:apply-templates select="/" mode="referenceResolvers"/>
/** END: Reference-resolvers **/
	
/** BEGIN : User-defined additional methods **/
	<xsl:apply-templates select="/.//*[name(.)='uml:Model']/following::*[(name(.)='uml2qvto:QvtoAdditionalOperations'  )]" mode="additional-operations"/>
/** END: User-defined additional methods **/

/** BEGIN : User-defined queries **/
	<xsl:apply-templates select="/.//*[name(.)='uml:Model']/following::*[(name(.)='uml2qvto:QvtoQuery'  )]" mode="query"/>
/** END : User-defined queries **/

mapping inout Package::<xsl:apply-templates select="@name" mode="normalize-id"/>(
inout model : uml::Model
) {
<!-- Declare the vars that are gonna be used -->
<xsl:apply-templates select="." mode="var"/><xsl:text>

</xsl:text>

	<!--
	We dont create static structures anymore. 
	<xsl:apply-templates select="." mode="struct"/> 
	-->
	
	<xsl:apply-templates select="." mode="qvtoTemplate">
	<xsl:with-param name="nestingLevel" select="1"/>
	</xsl:apply-templates>

 	<!-- 
 	We dont create static structures anymore. 
	<xsl:apply-templates select="/.//*[name(.)='uml:Model']/following::*" mode="stereotypes-nonTemplate"/>
 	-->

	<xsl:apply-templates mode="recover-qvtoTemplate">
		<xsl:with-param name="nestingLevel" select="1"/>
	</xsl:apply-templates>

<xsl:text>
}
</xsl:text>
</xsl:template>	


<xsl:template match="*" mode="transformation-profiles-params">
	<!-- Process all the profiles applied to the input model, and defines them as input variables of the transformation -->
	<xsl:variable name="nodeName" select="substring-before(name(),':')"/>
	<xsl:variable name="localName" select="local-name()"/>
	<xsl:variable name="prec" select="preceding::*[substring-before(name(.),':')=$nodeName]"/>
	<xsl:if test="count($prec)=0">
	,in <xsl:value-of select="$nodeName"/>ProfileFile : uml <xsl:text>
</xsl:text>
	</xsl:if>
</xsl:template>

	
<xsl:template match="//xmi:XMI" mode="stereotypes">
	<!-- we don't process the root element when processing stereotypes-->
</xsl:template>	
	
<xsl:template match="*" mode="apply-profiles">
	<!-- Process all the profiles applied to the input model, and applies them to the generated model -->
	<xsl:variable name="nodeName" select="substring-before(name(),':')"/>
	<xsl:variable name="localName" select="local-name()"/>
	<xsl:variable name="prec" select="preceding::*[substring-before(name(.),':')=$nodeName]"/>
	<xsl:if test="count($prec)=0">
<xsl:text>
	var </xsl:text><xsl:value-of select="$nodeName"/>Profile:=<xsl:value-of select="$nodeName"/>ProfileFile.objects()->select(e | e.oclIsTypeOf(uml::Profile))->any(true).oclAsType(uml::Profile);
	if(not(model.getAppliedProfiles()->includes(<xsl:value-of select="$nodeName"/>Profile))){
		model.applyProfile(<xsl:value-of select="$nodeName"/>Profile);
	};

	</xsl:if>
</xsl:template>	
	

<xsl:template match="*[name()!='xmi:XMI']" mode="stereotypes">
	<!-- process the stereotypes to apply to the generated elements -->
	<xsl:param name="templateNode"/>
	<xsl:param name="nestingLevel"/>
	<xsl:param name="update"/>
	<!-- don't apply uml2qvto profiles -->
	<xsl:if test="not(contains(name(),'uml2qvto'))">
		<xsl:variable name="id1" select="@xmi:id"/>
		<!-- normalize-id -->
		<xsl:variable name="refAttr" select="translate(translate(translate(translate(translate(translate(translate(./@*[contains(name(.),'base' )],'.','_'),':','_'),'-','_'),' ','_'),'$','_'),'{','_'),'}','_')"/>
		<!-- format -->
		<xsl:text>
		</xsl:text>
		<xsl:for-each select="$templateNode/ancestor::*"><xsl:text>	</xsl:text></xsl:for-each>
		<!-- reference of the element to which apply the stereotype -->
		<xsl:choose><xsl:when test="$update">__elem<xsl:value-of select="$nestingLevel"/></xsl:when><xsl:otherwise><xsl:value-of select="$refAttr"/></xsl:otherwise></xsl:choose>.setStereotypeByQualifiedName('<xsl:call-template name="processProfileName"><xsl:with-param name="val" select="substring-before(name(.),':')"/></xsl:call-template>::<xsl:value-of select="substring-after(name(.),':')" />');
		<!-- all attributes are tagged-values -->
		<xsl:apply-templates select="./@*[name()!='xmi:id' and not(contains(name(.),'base_'))]" mode="stereotypes">
			<xsl:with-param name="nodeElem" select="$refAttr"/>
			<xsl:with-param name="stereotypeName" select="name()"/>
			<xsl:with-param name="nestingLevel" select="$nestingLevel"/>
			<xsl:with-param name="update" select="$update"/>
		</xsl:apply-templates>
		<!--  child elements are multi-tagged-values -->
		<xsl:apply-templates select="." mode="multiTaggedValues">
			<xsl:with-param name="nodeElem" select="$refAttr"/>
			<xsl:with-param name="stereotypeName" select="name()"/>
			<xsl:with-param name="nestingLevel" select="$nestingLevel"/>
			<xsl:with-param name="update" select="$update"/>
		</xsl:apply-templates>
	</xsl:if>	
</xsl:template>



<xsl:template name="printElemsSequence">
	<!-- prints the sequence of nested template loops current elements.
		 It is used to invoke query methods with all the templating stack parameters. 
	-->
	<xsl:param name="nestingLevel" select="0"/>
	<xsl:param name="currentLevel" select="$nestingLevel"/>
	
	<xsl:text>__elem</xsl:text><xsl:value-of select="$currentLevel"/>
	<xsl:if test="$currentLevel &gt; 1">
		<xsl:text>,</xsl:text>
	    <xsl:call-template name="printElemsSequence">
	        <xsl:with-param name="currentLevel" select="$currentLevel - 1" />
	        <xsl:with-param name="nestingLevel" select="$nestingLevel" />
	    </xsl:call-template>
	</xsl:if>
</xsl:template>

<xsl:template match="@*[name()!='xmi:id' and not(contains(name(.),'base_'))]" mode="stereotypes">
	<!-- processes all tagged values applicable to an element -->
	<xsl:param name="nodeElem"/>
	<xsl:param name="stereotypeName"/>
	<xsl:param name="nestingLevel"/>
	<xsl:param name="update"/>

	<xsl:variable name="xmi_id" select="."/>
	<xsl:variable name="refElement" select="/.//*[@xmi:id=$xmi_id]"/>
	<xsl:variable name="refStereotype" select="/.//*[@xmi:id=$xmi_id]/@*[ contains(name(.),'base_')][1]"/><!-- ponemos [1] por si hay más de 1 base_ -->
	<xsl:variable name="val">
		<xsl:choose>
		<xsl:when test="$refStereotype">
			<!-- if the tagged value is a reference to another stereotype application (when the profile has associations, the associations are defined as references to other stereotype applications, no to the uml element) -->
			<xsl:variable name="appliedStereotypeName" select="name($refElement)"/>
			<xsl:variable name="ignore" select="/.//*[(name(.)='uml2qvto:Ignore'  ) and  ./@base_Element=$refStereotype]"/>
			<xsl:variable name="ignoreAll" select="/.//*[(name(.)='uml2qvto:IgnoreAll') and  ./@base_Element=$refStereotype]"/>
			<xsl:variable name="query" select="/.//*[(name(.)='uml2qvto:QvtoQuery' ) and  ./@base_Element=$refStereotype]"/>
			<xsl:variable name="type" select="/.//*[(name(.)='standard:Type'  ) and  ./@base_Class=$refStereotype]"/>
			<xsl:choose>
				<xsl:when test="($ignore or $ignoreAll) and $query">
				<!-- if the referenced element is defined as a query (ignore+query) 
						we want the stereotype applied to the queried element
				-->
					<xsl:value-of select="$query/@name"/>(model<xsl:if test="$nestingLevel=0">,null</xsl:if><xsl:if test="$nestingLevel>0">,Sequence{<xsl:call-template name="printElemsSequence"><xsl:with-param name="nestingLevel" select="$nestingLevel"/></xsl:call-template>}</xsl:if>)
					.getStereotypeApplication(
						getStereotype(<xsl:value-of select="$query/@name"/>(model<xsl:if test="$nestingLevel=0">,null</xsl:if><xsl:if test="$nestingLevel>0">,Sequence{<xsl:call-template name="printElemsSequence"><xsl:with-param name="nestingLevel" select="$nestingLevel"/></xsl:call-template>}</xsl:if>),'<xsl:call-template name="processProfileName"><xsl:with-param name="val" select="substring-before($appliedStereotypeName,':')"/></xsl:call-template>::<xsl:value-of select="substring-after($appliedStereotypeName,':')" />')
					)
					
				</xsl:when>
				<xsl:otherwise>
				<!-- if the referenced element is not defined as a query (ignore+query) 
						we want the stereotype applied to the queried element
				-->
					 <xsl:apply-templates select="$refStereotype" mode="normalize-id"/>
					.getStereotypeApplication(
						<xsl:apply-templates select="$refStereotype" mode="normalize-id"/>.getAppliedStereotype('<xsl:call-template name="processProfileName"><xsl:with-param name="val" select="substring-before($appliedStereotypeName,':')"/></xsl:call-template>::<xsl:value-of select="substring-after($appliedStereotypeName,':')" />')
					)
				</xsl:otherwise>
				
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$refElement">
			<!-- if the tagged value is a reference to another uml element -->
			<xsl:variable name="ignore" select="/.//*[(name(.)='uml2qvto:Ignore'  ) and  ./@base_Element=$refElement/@xmi:id]"/>
			<xsl:variable name="ignoreAll" select="/.//*[(name(.)='uml2qvto:IgnoreAll') and  ./@base_Element=$refElement/@xmi:id]"/>
			<xsl:variable name="query" select="/.//*[(name(.)='uml2qvto:QvtoQuery' ) and  ./@base_Element=$refElement/@xmi:id]"/>
			<xsl:variable name="type" select="/.//*[(name(.)='standard:Type'  ) and  ./@base_Class=$refElement/@xmi:id]"/>
			<xsl:choose>
				<xsl:when test="($ignore or $ignoreAll) and $query">
				<!-- if the referenced element is defined as a query (ignore+query) 
						we want the queried element
				-->
				<xsl:value-of select="$query/@name"/>(model<xsl:if test="$nestingLevel=0">,null</xsl:if><xsl:if test="$nestingLevel>0">,Sequence{<xsl:call-template name="printElemsSequence"><xsl:with-param name="nestingLevel" select="$nestingLevel"/></xsl:call-template>}</xsl:if>)</xsl:when>
				<xsl:otherwise>
				<!-- if the referenced element is not defined as a query (ignore+query) 
						we want the referenced element
				-->
<xsl:value-of select="$refElement/@xmi:id"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:otherwise>
			<!-- if the tagged value does not refer to another element, it is a value specification
			-->
			<xsl:text>'</xsl:text><xsl:value-of select="$xmi_id"/><xsl:text>'</xsl:text>
		</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<!-- format -->
	<xsl:for-each select="ancestor::*"><xsl:text>	</xsl:text></xsl:for-each> 
	<!--element to which apply the tagged value	-->
	<xsl:choose><xsl:when test="$update"><xsl:text>__elem</xsl:text><xsl:value-of select="$nestingLevel"/></xsl:when><xsl:otherwise><xsl:value-of select="$nodeElem"/></xsl:otherwise></xsl:choose>   
	<xsl:text>.setTaggedValueByStereotypeQualifiedName('</xsl:text><xsl:call-template name="processProfileName"><xsl:with-param name="val" select="substring-before($stereotypeName,':')"/></xsl:call-template><xsl:text>::</xsl:text><xsl:value-of select="substring-after($stereotypeName,':')" /><xsl:text>','</xsl:text><xsl:value-of select="name()"/><xsl:text>',</xsl:text><xsl:value-of select="$val"/><xsl:text>);
</xsl:text>
</xsl:template>



<xsl:template match="*" mode="multiTaggedValues">	
	<!-- processes all tagged values applicable to an element, 
		@contraint
		at the moment,just value instances, not references 
	-->
	<xsl:param name="nodeElem"/>
	<xsl:param name="stereotypeName"/>
	<xsl:param name="nestingLevel"/>
	<xsl:param name="update" />
	
	<xsl:variable name="actualNode" select="."/>
	<xsl:for-each select="child::*">
		<xsl:variable name="lname" select="local-name()"/>
		<xsl:if test="not(preceding-sibling::*[local-name()=$lname])">	
			<xsl:variable name="curName" select="name(.)"/>
			<xsl:for-each select="ancestor::*"><xsl:text>	</xsl:text></xsl:for-each><xsl:choose><xsl:when test="$update">__elem<xsl:value-of select="$nestingLevel"/></xsl:when><xsl:otherwise><xsl:value-of select="$nodeElem"/></xsl:otherwise></xsl:choose>.setTaggedValueByStereotypeQualifiedName('<xsl:call-template name="processProfileName"><xsl:with-param name="val" select="substring-before($stereotypeName,':')"/></xsl:call-template>::<xsl:value-of select="substring-after($stereotypeName,':')" />','<xsl:value-of select="name()"/>',
			<xsl:for-each select="ancestor::*"><xsl:text>		</xsl:text></xsl:for-each>Sequence{
			<xsl:for-each select="$actualNode/child::*[name()=$curName]">
				<xsl:for-each select="ancestor::*"><xsl:text>			</xsl:text></xsl:for-each><xsl:if test="preceding-sibling::*">,</xsl:if>'<xsl:value-of select="./text()"/>'
			</xsl:for-each>
			<xsl:for-each select="ancestor::*"><xsl:text>		</xsl:text></xsl:for-each>});
		</xsl:if>
	</xsl:for-each>
	
</xsl:template>


<!-- 

<xsl:template match="*" mode="getStereotype">
	<xsl:param name="stereotype"/>
	<xsl:variable name="xmi_id" select="./@*[name(.)='xmi:id']"/>
	<xsl:variable name="appliedStereotypes" select="/.//*[name(.)='uml:Model']/following::*[./@*[contains(name(),'base_')]=$xmi_id]"/>
	<xsl:value-of select="$appliedStereotypes/*[name()=$stereotype]"/>
</xsl:template>


 -->
 
 <xsl:template match="*" mode="query">
 <!-- prints the query -->
<xsl:text>
</xsl:text><xsl:value-of select="@query"/>
</xsl:template>


<xsl:template match="*" mode="additional-operations">
 <!-- prints the additional qvto operations -->
<xsl:text>
</xsl:text><xsl:value-of select="@qvto"/>
</xsl:template>

<xsl:template match="eAnnotations | eAnnotations/* | eAnnotations/@* | *[@xmi:type='uml:ProfileApplication']" mode="var">
<!-- we don't process ecore:eAnnotations when defining variables
	neither profile applications
 -->
</xsl:template>

<xsl:template match="node()" mode="var">
	<!-- defines the variables that are gonna be used in the script-->
	<xsl:param name="allow" select="true()"/>
	<xsl:variable name="xmi_id" select="./@*[name(.)='xmi:id']"/>
	<xsl:variable name="ignore" select="//*[(name(.)='uml2qvto:Ignore'   ) and  ./@base_Element=$xmi_id]"/>
	<xsl:variable name="query" select="//*[(name(.)='uml2qvto:QvtoQuery' ) and  ./@base_Element=$xmi_id]"/>
	<xsl:variable name="ignoreAll" select="//*[(name(.)='uml2qvto:IgnoreAll') and  ./@base_Element=$xmi_id]"/>
	<xsl:variable name="template" select="//*[(name(.)='uml2qvto:QvtoTemplate' ) and  ./@base_Element=$xmi_id]"/>
	<xsl:variable name="update" select="//*[(name(.)='uml2qvto:QvtoUpdate' ) and  ./@base_Element=$xmi_id]"/>
	<xsl:variable name="delete" select="//*[(name(.)='uml2qvto:QvtoDelete' ) and  ./@base_Element=$xmi_id]"/>
	<xsl:choose>
	<xsl:when test="$ignore or name()='uml:Model'">
	<xsl:text>	// ignore as variable </xsl:text><xsl:value-of select="$ignore/@xmi:id"></xsl:value-of><xsl:text>
</xsl:text>	
	</xsl:when>
	<xsl:when test="$ignoreAll">
	<xsl:text>	// ignore all variable </xsl:text><xsl:value-of select="$ignoreAll/@xmi:id"></xsl:value-of><xsl:text>
</xsl:text>
	</xsl:when>
	<xsl:when test="@xmi:id and $allow">
		<xsl:text>	var	</xsl:text><xsl:apply-templates select="@xmi:id" mode="normalize-id"/><xsl:text>:</xsl:text><xsl:value-of select="substring-before(@xmi:type,':' )" /><xsl:text>::</xsl:text><xsl:value-of select="substring-after(@xmi:type,':' )" /><xsl:text>;
</xsl:text>
	</xsl:when>
	</xsl:choose>
	<xsl:choose>
		<xsl:when test="$query and ($ignore or $ignoreAll or not($allow))">
			<xsl:text>	var	</xsl:text><xsl:apply-templates select="@xmi:id" mode="normalize-id"/><xsl:text>:</xsl:text><xsl:value-of select="substring-before(@xmi:type,':' )" /><xsl:text>::</xsl:text><xsl:value-of select="substring-after(@xmi:type,':' )" /><xsl:text>;
</xsl:text>		
			<xsl:apply-templates select="./node()" mode="var"><xsl:with-param name="allow" select="$allow"/></xsl:apply-templates>
		</xsl:when>
		<xsl:when test="not($allow) and ($template or $update or $delete)">
			<xsl:text>	var	</xsl:text><xsl:apply-templates select="@xmi:id" mode="normalize-id"/><xsl:text>:</xsl:text><xsl:value-of select="substring-before(@xmi:type,':' )" /><xsl:text>::</xsl:text><xsl:value-of select="substring-after(@xmi:type,':' )" /><xsl:text>;
</xsl:text>		
			<xsl:apply-templates select="./node()" mode="var"><xsl:with-param name="allow" select="true()"/></xsl:apply-templates>
		</xsl:when>
		<xsl:when test="$ignoreAll">
			<xsl:apply-templates select="./node()" mode="var"><xsl:with-param name="allow" select="false()"/></xsl:apply-templates>		
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="./node()" mode="var"><xsl:with-param name="allow" select="$allow"/></xsl:apply-templates>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="*" mode="struct">
	<xsl:param name="nestingLevel" select="0"/>
	<xsl:variable name="xmi_id" select="./@*[name(.)='xmi:id']"/>
	<xsl:variable name="parent_xmi_id" select="../@*[name(.)='xmi:id']"/>
	<xsl:variable name="ignore" select="/.//*[(name(.)='uml2qvto:Ignore'  ) and  ./@base_Element=$xmi_id]"/>
	<xsl:variable name="ignoreAll" select="/.//*[(name(.)='uml2qvto:IgnoreAll') and  ./@base_Element=$xmi_id]"/>
	<xsl:variable name="template" select="/.//*[(name(.)='uml2qvto:QvtoTemplate' ) and  ./@base_Element=$xmi_id]"/>
	<xsl:variable name="update" select="/.//*[(name(.)='uml2qvto:QvtoUpdate' ) and  ./@base_Element=$xmi_id]"/>
	<xsl:variable name="delete" select="/.//*[(name(.)='uml2qvto:QvtoDelete' ) and  ./@base_Element=$xmi_id]"/>
	<xsl:variable name="updateChild" select="/.//*[(name(.)='uml2qvto:QvtoUpdate' ) and  ./@base_Element=$parent_xmi_id]"/>
	<xsl:variable name="deleteChild" select="/.//*[(name(.)='uml2qvto:QvtoDelete' ) and  ./@base_Element=$parent_xmi_id]"/>
	<xsl:choose>
	<xsl:when test="$ignore or name()='uml:Model'">
	// ignore as struct <xsl:value-of select="@name"></xsl:value-of><xsl:text>
</xsl:text>
		<xsl:apply-templates select="./*" mode="struct">
			<xsl:with-param name="nestingLevel" select="$nestingLevel"/>
		</xsl:apply-templates>
	</xsl:when>
	<xsl:when test="$ignoreAll">
	// ignore all struct <xsl:value-of select="@name"></xsl:value-of><xsl:text>
</xsl:text>
	</xsl:when>
	<xsl:otherwise>
		<xsl:choose>
			<xsl:when test="$template or $update or $delete">
	//ignore template update or delete struct <xsl:value-of select="@name"></xsl:value-of><xsl:text>
</xsl:text>
			</xsl:when>
		<xsl:otherwise>
			<xsl:choose><xsl:when test="@xmi:type">
				<xsl:for-each select="ancestor-or-self::*"><xsl:text>	</xsl:text></xsl:for-each>
<xsl:if test="$template/@target"><xsl:choose><xsl:when test="contains($template/@target,'(')"><xsl:value-of select="$template/@target"/></xsl:when><xsl:otherwise><xsl:apply-templates select="$template/@target" mode="normalize-id"/></xsl:otherwise></xsl:choose>.</xsl:if>
	<xsl:if test="$updateChild">__elem<xsl:value-of select="$nestingLevel"/>.</xsl:if>
<!--PJR-DELETES 
<xsl:if test="$deleteChild">__elem<xsl:value-of select="$nestingLevel"/>.</xsl:if>
 -->
 				<xsl:call-template name="processReservedWords"><xsl:with-param name="input" select="local-name()"/></xsl:call-template>
				<xsl:variable name="ln" select="local-name()"/>
				<xsl:choose>
					<!-- <xsl:when test="$updateChild or $deleteChild or (count(following-sibling::*[local-name()=$ln])+count(preceding-sibling::*[local-name()=$ln]))>0">+</xsl:when> -->
					<xsl:when test="(count(following-sibling::*[local-name()=$ln])+count(preceding-sibling::*[local-name()=$ln]))>0">+</xsl:when>
					<xsl:otherwise>:</xsl:otherwise>
				</xsl:choose>
				<xsl:choose>
					<xsl:when test="./@xmi:type='uml:PrimitiveType'">=umlPrimitiveTypesFile.objects()->select(e | e.oclIsTypeOf(uml::Model))->any(true).oclAsType(Model).packagedElement->select(t | t.name="<xsl:value-of select="substring-after(@href, '#')"/>")->any(true).oclAsType(Type);<xsl:text>
</xsl:text>
					</xsl:when>
					<xsl:otherwise>=object <xsl:apply-templates select="@xmi:id" mode="normalize-id"/> :<xsl:value-of select="substring-before(@xmi:type,':' )" />::<xsl:value-of select="substring-after(@xmi:type,':' )" />{<xsl:text>
</xsl:text>
						<xsl:for-each select="./* | ./@*[not(contains(name(),'xmi'))]" >
						<xsl:apply-templates select="." mode="struct">
							<xsl:with-param name="nestingLevel" select="$nestingLevel"/>
						</xsl:apply-templates>
						</xsl:for-each>
							<xsl:for-each select="ancestor-or-self::*"><xsl:text>	</xsl:text></xsl:for-each>};<xsl:text>
</xsl:text>
				</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				ERROR: The input file has no @xmi:type serialized. Try to edit with a tool that serializes this field.
			</xsl:otherwise></xsl:choose>

		</xsl:otherwise>
		</xsl:choose>
	</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="@*" mode="struct">
<xsl:param name="nestingLevel" select="0"/>
<xsl:variable name="parent_xmi_id" select="../@*[name(.)='xmi:id']"/>
<xsl:variable name="update" select="/.//*[(name(.)='uml2qvto:QvtoUpdate' ) and  ./@base_Element=$parent_xmi_id]"/>
<xsl:variable name="delete" select="/.//*[(name(.)='uml2qvto:QvtoDelete' ) and  ./@base_Element=$parent_xmi_id]"/>
<xsl:variable name="needsPrefix" select="$update"/>
<xsl:variable name="attr" select="."/>
<xsl:variable name="localName" select="local-name()"/>
<xsl:variable name="tLen">
 <xsl:call-template name="countTokens"> 
   <xsl:with-param name="csv" select="." /> 
 </xsl:call-template>
</xsl:variable>
<xsl:variable name="ancestorOrSelf" select="ancestor-or-self::*"/>
 <xsl:call-template name="tokenize-struct"> 
   <xsl:with-param name="csv" select="string(.)" /> 
   <xsl:with-param name="currAttr" select="." /> 
   <xsl:with-param name="localName" select="$localName" /> 
   <xsl:with-param name="ancestorOrSelf" select="$ancestorOrSelf" />
   <xsl:with-param name="len" select="string(common:node-set($tLen))"/>
	<xsl:with-param name="nestingLevel" select="$nestingLevel"/>
	<xsl:with-param name="needsPrefix" select="$needsPrefix"/>
 </xsl:call-template>
</xsl:template>

<xsl:template match="//profileApplication" mode="struct"></xsl:template>

<xsl:template match="eAnnotations | eAnnotations/* | eAnnotations/@*" mode="struct"></xsl:template>



<xsl:template name="tokenize-struct">
	<xsl:param name="nestingLevel" select="0"/>
	<xsl:param name="currAttr" />
	<xsl:param name="csv" />
	<xsl:param name="len" />
	<xsl:param name="localName" />
	<xsl:param name="ancestorOrSelf" />
	<xsl:param name="needsPrefix" />
	<xsl:variable name="first-item">
		<xsl:call-template name="getFirstItem">
			<xsl:with-param name="currAttr" select="$currAttr"/>
			<xsl:with-param name="csv" select="$csv"/>
			<xsl:with-param name="localName" select="$localName"/>
		</xsl:call-template>
	</xsl:variable> 
  	<xsl:variable name="check" select="string($first-item)"/>
 <xsl:if test="not($check='')">
 	<xsl:variable name="attr" select="$check"/>
	<xsl:variable name="referencedObject" select="$root//uml:Model//*[@xmi:id=$attr]"/>
	<xsl:variable name="ref" select="$root//*[@xmi:id=$attr]"/>
	<xsl:variable name="ignore" select="/.//*[(name(.)='uml2qvto:Ignore'  ) and  ./@base_Element=$referencedObject/@xmi:id]"/>
	<xsl:variable name="ignoreAll" select="/.//*[(name(.)='uml2qvto:IgnoreAll') and  ./@base_Element=$referencedObject/@xmi:id]"/>
	<xsl:variable name="query" select="/.//*[(name(.)='uml2qvto:QvtoQuery' ) and  ./@base_Element=$referencedObject/@xmi:id]"/>
	<xsl:variable name="type" select="/.//*[(name(.)='standard:Type'  ) and  ./@base_Class=$referencedObject/@xmi:id]"/>
	
	<xsl:choose>
		<xsl:when test="$referencedObject">
<!-- 			
<xsl:text>
</xsl:text><xsl:for-each select="$ancestorOrSelf"><xsl:text>	</xsl:text></xsl:for-each>//## <xsl:value-of select="$referencedObject/@xmi:id"/>_ <xsl:value-of select="$ignore/@xmi:id"/>_ <xsl:value-of select="$ignoreAll/@xmi:id"/>_ <xsl:value-of select="$query/@xmi:id"/><xsl:text>
</xsl:text> -->
			<xsl:variable name="ln" select="local-name()"/>
			<xsl:choose>
				<!--  PJR-UPDATES_AND_DELETES <xsl:when test="$needsPrefix or $len>1 or count(following-sibling::node()[local-name()=$ln])+count(preceding-sibling::node()[local-name()=$ln])>0">-->
				<xsl:when test="$len>1 or count(following-sibling::node()[local-name()=$ln])+count(preceding-sibling::node()[local-name()=$ln])>0">
					<xsl:choose>
						<xsl:when test="$query">
<xsl:for-each select="$ancestorOrSelf"><xsl:text>	</xsl:text></xsl:for-each><xsl:text>	</xsl:text> <xsl:if test="$needsPrefix">__elem<xsl:value-of select="$nestingLevel"/>.</xsl:if><xsl:call-template name="processReservedWords"><xsl:with-param name="input" select="$localName"/></xsl:call-template>+= <xsl:value-of select="$query/@name"/>(model<xsl:if test="$nestingLevel=0">,null</xsl:if><xsl:if test="$nestingLevel>0">,Sequence{<xsl:call-template name="printElemsSequence"><xsl:with-param name="nestingLevel" select="$nestingLevel"/></xsl:call-template>}</xsl:if>);<xsl:text>
</xsl:text>	
						</xsl:when>
						<xsl:otherwise>
<xsl:for-each select="$ancestorOrSelf"><xsl:text>	</xsl:text></xsl:for-each><xsl:text>	</xsl:text><xsl:if test="$needsPrefix">__elem<xsl:value-of select="$nestingLevel"/>.</xsl:if><xsl:call-template name="processReservedWords"><xsl:with-param name="input" select="$localName"/></xsl:call-template>+= object <xsl:call-template name="normalize-id" ><xsl:with-param name="val" select="$attr" /></xsl:call-template> :<xsl:value-of select="substring-before($ref/@xmi:type,':' )" />::<xsl:value-of select="substring-after($ref/@xmi:type,':' )" />{};<xsl:text>
</xsl:text>		
						</xsl:otherwise>
					</xsl:choose>	
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="$query">
<xsl:for-each select="$ancestorOrSelf"><xsl:text>	</xsl:text></xsl:for-each><xsl:text>	</xsl:text><xsl:if test="$needsPrefix">__elem<xsl:value-of select="$nestingLevel"/>.</xsl:if><xsl:call-template name="processReservedWords"><xsl:with-param name="input" select="$localName"/></xsl:call-template>:= <xsl:value-of select="$query/@name"/>(model<xsl:if test="$nestingLevel=0">,null</xsl:if><xsl:if test="$nestingLevel>0">,Sequence{<xsl:call-template name="printElemsSequence"><xsl:with-param name="nestingLevel" select="$nestingLevel"/></xsl:call-template>}</xsl:if>);<xsl:text>
</xsl:text>		
						</xsl:when>
						<xsl:otherwise>
<xsl:for-each select="$ancestorOrSelf"><xsl:text>	</xsl:text></xsl:for-each><xsl:text>	</xsl:text><xsl:if test="$needsPrefix">__elem<xsl:value-of select="$nestingLevel"/>.</xsl:if><xsl:call-template name="processReservedWords"><xsl:with-param name="input" select="$localName"/></xsl:call-template>:= object <xsl:call-template name="normalize-id" ><xsl:with-param name="val" select="$attr" /></xsl:call-template> :<xsl:value-of select="substring-before($ref/@xmi:type,':' )" />::<xsl:value-of select="substring-after($ref/@xmi:type,':' )" />{};<xsl:text>
</xsl:text>		
						</xsl:otherwise>
					</xsl:choose>	
				</xsl:otherwise>
			</xsl:choose>		
		</xsl:when>
		<xsl:otherwise>
			
			<xsl:variable name="metaClassName" select="substring-after(parent::node()/@xmi:type,'uml:' )"/>
			<xsl:variable name="metaClass" select="$umlMetamodel//ecore:EPackage[1]//*[./@xsi:type='ecore:EClass' and ./@name=$metaClassName]"/>
			<!-- <xsl:variable name="metaClassAttribute" select="$metaClass/*[@xsi:type='ecore:EAttribute' and @name=$localName]"/>-->
			<xsl:variable name="metaClassAttribute1" >
				<xsl:call-template name="getMetaClassETypeAtribute">
					<xsl:with-param name="metaClass" select="$metaClass"/>
					<xsl:with-param name="localName2" select="$localName"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="metaClassAttribute" select="common:node-set( $metaClassAttribute1)"/>
			<xsl:variable name="metaClassAttributeTypeMetaClass" select="$umlMetamodel//ecore:EPackage[1]//*[ @name=substring-after($metaClassAttribute,'#//')]"/>
<!-- 		<xsl:for-each select="$ancestorOrSelf"><xsl:text>	</xsl:text></xsl:for-each>//@1@<xsl:value-of select="$metaClassName"></xsl:value-of><xsl:text>
</xsl:text>
		<xsl:for-each select="$ancestorOrSelf"><xsl:text>	</xsl:text></xsl:for-each>//@2@<xsl:value-of select="$metaClass/@name"></xsl:value-of><xsl:text>
</xsl:text>
		<xsl:for-each select="$ancestorOrSelf"><xsl:text>	</xsl:text></xsl:for-each>//@3@<xsl:value-of select="$metaClassAttribute"></xsl:value-of><xsl:text>
</xsl:text>
		<xsl:for-each select="$ancestorOrSelf"><xsl:text>	</xsl:text></xsl:for-each>//@4@<xsl:value-of select="$metaClassAttributeTypeMetaClass/@xsi:type"></xsl:value-of><xsl:text>
</xsl:text>
 -->
			<xsl:choose>
			<xsl:when test="$metaClassAttributeTypeMetaClass/@xsi:type='ecore:EEnum'">
				<xsl:for-each select="$ancestorOrSelf"><xsl:text>	</xsl:text></xsl:for-each><xsl:text>	</xsl:text><xsl:if test="$needsPrefix">__elem<xsl:value-of select="$nestingLevel"/>.</xsl:if><xsl:call-template name="processReservedWords"><xsl:with-param name="input" select="$localName"/></xsl:call-template>:=uml::<xsl:value-of select="substring-after($metaClassAttribute,'#//')"/>::<xsl:call-template name="escape"><xsl:with-param name="val" select="$attr"/></xsl:call-template>;	
			</xsl:when>
			<xsl:when test="$metaClassAttribute='ecore:EDataType platform:/plugin/org.eclipse.uml2.types/model/Types.ecore#//UnlimitedNatural'">
				<xsl:for-each select="$ancestorOrSelf"><xsl:text>	</xsl:text></xsl:for-each><xsl:text>	</xsl:text><xsl:if test="$needsPrefix">__elem<xsl:value-of select="$nestingLevel"/>.</xsl:if><xsl:call-template name="processReservedWords"><xsl:with-param name="input" select="$localName"/></xsl:call-template>:=<xsl:value-of select="$attr"/>;	
			</xsl:when>
			<xsl:when test="$metaClassAttribute='ecore:EDataType platform:/plugin/org.eclipse.uml2.types/model/Types.ecore#//Integer'">
				<xsl:for-each select="$ancestorOrSelf"><xsl:text>	</xsl:text></xsl:for-each><xsl:text>	</xsl:text><xsl:if test="$needsPrefix">__elem<xsl:value-of select="$nestingLevel"/>.</xsl:if><xsl:call-template name="processReservedWords"><xsl:with-param name="input" select="$localName"/></xsl:call-template>:=<xsl:value-of select="$attr"/>;	
			</xsl:when>			
			<xsl:when test="$metaClassAttribute='ecore:EDataType platform:/plugin/org.eclipse.uml2.types/model/Types.ecore#//Real'">
				<xsl:for-each select="$ancestorOrSelf"><xsl:text>	</xsl:text></xsl:for-each><xsl:text>	</xsl:text><xsl:if test="$needsPrefix">__elem<xsl:value-of select="$nestingLevel"/>.</xsl:if><xsl:call-template name="processReservedWords"><xsl:with-param name="input" select="$localName"/></xsl:call-template>:=<xsl:value-of select="$attr"/>;	
			</xsl:when>			
			<xsl:when test="$metaClassAttribute='ecore:EDataType platform:/plugin/org.eclipse.uml2.types/model/Types.ecore#//Boolean'">
				<xsl:for-each select="$ancestorOrSelf"><xsl:text>	</xsl:text></xsl:for-each><xsl:text>	</xsl:text><xsl:if test="$needsPrefix">__elem<xsl:value-of select="$nestingLevel"/>.</xsl:if><xsl:call-template name="processReservedWords"><xsl:with-param name="input" select="$localName"/></xsl:call-template>:=<xsl:value-of select="$attr"/>;	
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$nestingLevel>0 and $localName='name' and $needsPrefix">
						<xsl:for-each select="$ancestorOrSelf"><xsl:text>	</xsl:text></xsl:for-each><xsl:text>	</xsl:text><xsl:if test="$needsPrefix">__elem<xsl:value-of select="$nestingLevel"/>.</xsl:if><xsl:call-template name="processReservedWords"><xsl:with-param name="input" select="$localName"/></xsl:call-template>:= '<xsl:value-of select="$ancestorOrSelf[last()]/@name"/>';
					</xsl:when>
					<xsl:when test="$nestingLevel>0 and $localName='name' and not($needsPrefix)">
						<xsl:for-each select="$ancestorOrSelf"><xsl:text>	</xsl:text></xsl:for-each><xsl:text>	</xsl:text><xsl:if test="$needsPrefix">__elem<xsl:value-of select="$nestingLevel"/>.</xsl:if><xsl:call-template name="processReservedWords"><xsl:with-param name="input" select="$localName"/></xsl:call-template>:= '<xsl:call-template name="getUniqueName"><xsl:with-param name="val" select="$ancestorOrSelf[last()]"/></xsl:call-template>';
					</xsl:when>
					<xsl:otherwise>
						<xsl:for-each select="$ancestorOrSelf"><xsl:text>	</xsl:text></xsl:for-each><xsl:text>	</xsl:text><xsl:if test="$needsPrefix">__elem<xsl:value-of select="$nestingLevel"/>.</xsl:if><xsl:call-template name="processReservedWords"><xsl:with-param name="input" select="$localName"/></xsl:call-template>:= '<xsl:value-of select="$attr"/>';
					</xsl:otherwise>
				</xsl:choose>
								
			</xsl:otherwise>
			</xsl:choose>
				
		</xsl:otherwise>
	</xsl:choose>
<xsl:text>
</xsl:text>
	<xsl:if test="not($check='') and /.//*[@xmi:id=$attr]">	
	  <xsl:call-template name="tokenize-struct"> 
	   <xsl:with-param name="currAttr" select="$currAttr" />
	   <xsl:with-param name="csv" select="substring-after($csv,' ')" /> 
	   <xsl:with-param name="localName" select="$localName" />
	    <xsl:with-param name="len" select="$len" /> 
	   <xsl:with-param name="ancestorOrSelf" select="$ancestorOrSelf" />   
	   <xsl:with-param name="needsPrefix" select="$needsPrefix"/> 
	   <xsl:with-param name="nestingLevel" select="$nestingLevel"/>
	  </xsl:call-template>  
 	</xsl:if>  
 </xsl:if>  
</xsl:template>



<xsl:template name="getMetaClassETypeAtribute">
	<xsl:param name="metaClass"/>
	<xsl:param name="localName2"/>
	<xsl:variable name="metaClassAttribute" select="$metaClass//eStructuralFeatures[@xsi:type='ecore:EAttribute' and @name=$localName2]"/>
	<xsl:choose>
		<xsl:when test="$metaClassAttribute"><xsl:value-of select="$metaClassAttribute/@eType"/></xsl:when>
		<xsl:otherwise>
			<xsl:variable name="extendedMmetaClass" select="$umlMetamodel//ecore:EPackage[1]//*[ @name=substring-after($metaClass/@eSuperTypes,'#//')]"/>
			<xsl:choose>
				<xsl:when test="$extendedMmetaClass">
					<xsl:call-template name="getMetaClassETypeAtribute">
						<xsl:with-param name="metaClass" select="$extendedMmetaClass"/>
						<xsl:with-param name="localName2" select="$localName2"/>
					</xsl:call-template>
				</xsl:when>
			</xsl:choose>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="getAllSuperClasses">
	<xsl:param name="attr"/>

	<xsl:if test="$attr!=''">
		<xsl:variable name="attr1" select="substring-before($attr,' ')"/>
		<xsl:choose>
			<xsl:when test="$attr1!=''">
				<xsl:variable name="attr2" select="$umlMetamodel//ecore:EPackage[1]//*[ @name=substring-after($attr1,'#//')]"/>
				<xsl:copy-of select="$attr2"/>
				<xsl:call-template name="getAllSuperClasses">
					<xsl:with-param name="attr" select="substring-after($attr,' ')"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="attr2" select="$umlMetamodel//ecore:EPackage[1]//*[ @name=substring-after($attr,'#//')]"/>
				<xsl:copy-of select="$attr2"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:if>
</xsl:template>

<xsl:template name="getMetaClassAtribute">
	<xsl:param name="metaClass"/>
	<xsl:param name="localName2"/>
	<xsl:variable name="metaClassAttribute" select="$metaClass//eStructuralFeatures[(@xsi:type='ecore:EAttribute' or @xsi:type='ecore:EReference') and @name=$localName2]"/>
	<xsl:variable name="res">
		<xsl:choose>
			<xsl:when test="$metaClassAttribute"><xsl:copy-of select="$metaClassAttribute"/></xsl:when>
			<xsl:otherwise>
				<xsl:variable name="extendedMmetaClass">
				 	<xsl:call-template name="getAllSuperClasses">
					 	<xsl:with-param name="attr" select="$metaClass/@eSuperTypes"/>
				 	</xsl:call-template>
				 </xsl:variable>
					<xsl:for-each select="common:node-set( $extendedMmetaClass)//eClassifiers">
						<xsl:call-template name="getMetaClassAtribute">
							<xsl:with-param name="metaClass" select="."/>
							<xsl:with-param name="localName2" select="$localName2"/>
						</xsl:call-template>
					</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:copy-of select="$res"/>
</xsl:template>

<xsl:template name="getMetaClassAtributes">
	<xsl:param name="metaClass"/>
	<xsl:variable name="metaClassAttributes" select="$metaClass//eStructuralFeatures[(@xsi:type='ecore:EAttribute' or @xsi:type='ecore:EReference')] "/>
	<xsl:variable name="metaClassDuplicates" select="$metaClass//eAnnotations/contents[(@xsi:type='ecore:EAttribute' or @xsi:type='ecore:EReference')] "/>
	<xsl:variable name="res">
			<xsl:copy-of select="$metaClassAttributes"/>
			<xsl:copy-of select="$metaClassDuplicates"/>
			<xsl:variable name="extendedMmetaClass">
			 	<xsl:call-template name="getAllSuperClasses">
				 	<xsl:with-param name="attr" select="$metaClass/@eSuperTypes"/>
			 	</xsl:call-template>
			 </xsl:variable>
				<xsl:for-each select="common:node-set( $extendedMmetaClass)//eClassifiers">
					<xsl:call-template name="getMetaClassAtributes">
						<xsl:with-param name="metaClass" select="."/>
					</xsl:call-template>
				</xsl:for-each>
	</xsl:variable>
	<xsl:copy-of select="$res"/>
</xsl:template>


<xsl:template name="printMetaClassAtributes">
<xsl:param name="metaClass"/>/******************************
* - <xsl:value-of select="$metaClass/@name"></xsl:value-of> -
*	
<xsl:variable name="metaClassAttributes" select="$metaClass//eStructuralFeatures[(@xsi:type='ecore:EAttribute' or @xsi:type='ecore:EReference')] "/>
<xsl:variable name="metaClassDuplicates" select="$metaClass//eAnnotations/contents[(@xsi:type='ecore:EAttribute' or @xsi:type='ecore:EReference')] "/>
<xsl:for-each select="$metaClassAttributes">
<xsl:text>* Attr:			</xsl:text><xsl:value-of select="@name"/><xsl:call-template name="tabulate"><xsl:with-param name="maxValue" select="30-(string-length(@name))"/></xsl:call-template>
<xsl:text>(</xsl:text><xsl:value-of select="substring-after(@eType,'#')"/><xsl:text>)</xsl:text><xsl:call-template name="tabulate"><xsl:with-param name="maxValue" select="30-(string-length(substring-after(@eType,'#')))"/></xsl:call-template>
<xsl:text>,defaultValueLiteral=</xsl:text><xsl:value-of select="@defaultValueLiteral"/><xsl:call-template name="tabulate"><xsl:with-param name="maxValue" select="30-(string-length(@defaultValueLiteral))"/></xsl:call-template>
<xsl:text>,isDerived=</xsl:text><xsl:value-of select="@derived"/><xsl:call-template name="tabulate"><xsl:with-param name="maxValue" select="30-(string-length(@derived))"/></xsl:call-template><xsl:text>
</xsl:text></xsl:for-each> 
<xsl:for-each select="$metaClassDuplicates">
<xsl:text>* Dupl:			</xsl:text><xsl:value-of select="@name"/><xsl:call-template name="tabulate"><xsl:with-param name="maxValue" select="30-(string-length(@name))"/></xsl:call-template>
<xsl:text>(</xsl:text><xsl:value-of select="substring-after(@eType,'#')"/><xsl:text>)</xsl:text><xsl:call-template name="tabulate"><xsl:with-param name="maxValue" select="30-(string-length(substring-after(@eType,'#')))"/></xsl:call-template>
<xsl:text>,defaultValueLiteral=</xsl:text><xsl:value-of select="@defaultValueLiteral"/><xsl:call-template name="tabulate"><xsl:with-param name="maxValue" select="30-(string-length(@defaultValueLiteral))"/></xsl:call-template>
<xsl:text>,isDerived=</xsl:text><xsl:value-of select="@derived"/><xsl:call-template name="tabulate"><xsl:with-param name="maxValue" select="30-(string-length(@derived))"/></xsl:call-template><xsl:text>
</xsl:text></xsl:for-each> 
<xsl:variable name="extendedMmetaClass">
<xsl:call-template name="getAllSuperClasses">
<xsl:with-param name="attr" select="$metaClass/@eSuperTypes"/>
</xsl:call-template>
</xsl:variable>
<xsl:for-each select="common:node-set( $extendedMmetaClass)//eClassifiers">
<xsl:call-template name="printMetaClassAtributes">
<xsl:with-param name="metaClass" select="."/>
</xsl:call-template>
</xsl:for-each>
**/
</xsl:template>

<xsl:template name="tabulate">
  <xsl:param name="index" select="1"/>
  <xsl:param name="maxValue" select="30" />
  <xsl:text> </xsl:text>
  <xsl:if test="$index &lt; $maxValue">
    <xsl:call-template name="tabulate">
        <xsl:with-param name="index" select="$index + 1" />
        <xsl:with-param name="maxValue" select="$maxValue" />
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<xsl:template name="getMetaClassAtribute2">
	<xsl:param name="metaClass"/>
	<xsl:param name="localName2"/>
	<xsl:variable name="metaClassAttribute" select="$metaClass//eStructuralFeatures[(@xsi:type='ecore:EAttribute' or @xsi:type='ecore:EReference') and @name=$localName2]"/>
	<xsl:variable name="res">
		<xsl:choose>
			<xsl:when test="$metaClassAttribute"><xsl:copy-of select="$metaClassAttribute"/></xsl:when>
			<xsl:otherwise>
				<xsl:variable name="extendedMmetaClass" select="$umlMetamodel//ecore:EPackage[1]//*[ @name=substring-after($metaClass/@eSuperTypes,'#//')]"/>
				<xsl:choose>
					<xsl:when test="$extendedMmetaClass">
						<xsl:call-template name="getMetaClassAtribute">
							<xsl:with-param name="metaClass" select="$extendedMmetaClass"/>
							<xsl:with-param name="localName2" select="$localName2"/>
						</xsl:call-template>
					</xsl:when>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:copy-of select="$res"/>
</xsl:template>


<xsl:template name="escape">
<xsl:param name="val"/>
<xsl:choose>
<xsl:when test="$val='out' or $val='return' or $val='in'">
<xsl:text>_</xsl:text><xsl:value-of select="$val"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$val"/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>



<xsl:template match="eAnnotations | eAnnotations/* | eAnnotations/@*" mode="qvtoTemplate">
</xsl:template>

<xsl:template match="*" mode="qvtoTemplate">
	<xsl:param name="debug" select="'true'"/>
	<xsl:param name="nestingLevel"/>
	<xsl:variable name="xmi_id" select="./@*[name(.)='xmi:id']"/>
	<xsl:variable name="ignore" select="//*[(name(.)='uml2qvto:Ignore'  ) and  ./@base_Element=$xmi_id]"/>
	<xsl:variable name="ignoreAll" select="//*[(name(.)='uml2qvto:IgnoreAll') and  ./@base_Element=$xmi_id]"/>
	<xsl:variable name="template" select="//*[(name(.)='uml2qvto:QvtoTemplate' ) and  ./@base_Element=$xmi_id]"/>
	<xsl:variable name="update" select="//*[(name(.)='uml2qvto:QvtoUpdate' ) and  ./@base_Element=$xmi_id]"/>
	<xsl:variable name="delete" select="//*[(name(.)='uml2qvto:QvtoDelete' ) and  ./@base_Element=$xmi_id]"/>
	
	<xsl:choose>
	<xsl:when test="$ignore">
	// mode qvtoTemplate -- ignore as template <xsl:value-of select="@name"></xsl:value-of><xsl:text>
</xsl:text>
	<xsl:apply-templates select="./*" mode="qvtoTemplate">
	<xsl:with-param name="nestingLevel" select="$nestingLevel"/>
	</xsl:apply-templates>
	</xsl:when>
	<xsl:otherwise>
		<xsl:if test="$template">
		<xsl:variable name="realNestingLevel" select="$nestingLevel+count($template//selector)-1"/>
		//qvtoTemplate <xsl:value-of select="$xmi_id"/>
<xsl:text>
</xsl:text>
<xsl:for-each select="$template//selector">
<xsl:variable name="level1Count" select="position()"/><xsl:variable name="nestingOffset" select="position()-1"/>
<xsl:for-each select="ancestor::*"><xsl:text>	</xsl:text></xsl:for-each><xsl:choose><xsl:when test="contains($template//selector[$level1Count]/text(),'(')"><xsl:value-of select="$template//selector[$level1Count]/text()"/></xsl:when><xsl:otherwise><xsl:apply-templates select="$template//selector[$level1Count]/text()" mode="normalize-id"/></xsl:otherwise></xsl:choose>->forEach(__elem<xsl:value-of select="$nestingLevel+$nestingOffset"/>){<xsl:text>
</xsl:text>
</xsl:for-each>
			<xsl:apply-templates mode="initialize-template-struct-vars" select=".">
				<xsl:with-param name="level" select="0"/>
				<xsl:with-param name="nestingLevel" select="$realNestingLevel"></xsl:with-param>
				<xsl:with-param name="topElement" select="."/>
			</xsl:apply-templates>
			<xsl:value-of select="$template/@template"/><xsl:text>
</xsl:text><xsl:for-each select="ancestor-or-self::*"><xsl:text>	</xsl:text></xsl:for-each><xsl:choose><xsl:when test="$template/@target"><xsl:choose><xsl:when test="contains($template/@target,'(')"><xsl:value-of select="$template/@target"/>.</xsl:when><xsl:otherwise><xsl:apply-templates select="$template/@target" mode="normalize-id"/>.</xsl:otherwise></xsl:choose></xsl:when><xsl:otherwise><xsl:if test="$nestingLevel>1"><xsl:apply-templates select="../@xmi:id" mode="normalize-id"/>.</xsl:if></xsl:otherwise></xsl:choose><xsl:call-template name="processReservedWords"><xsl:with-param name="input" select="local-name()"/></xsl:call-template>+=object <xsl:apply-templates select="@xmi:id" mode="normalize-id"/> :<xsl:value-of select="substring-before(@xmi:type,':' )" />::<xsl:value-of select="substring-after(@xmi:type,':' )" />{<xsl:text>
</xsl:text>
			<xsl:for-each select="./* | ./@*[not(contains(name(),'xmi'))]" >
				<xsl:apply-templates select="." mode="struct">
					<xsl:with-param name="nestingLevel" select="$realNestingLevel"></xsl:with-param>
				</xsl:apply-templates>
			</xsl:for-each>
			<xsl:for-each select="ancestor-or-self::*"><xsl:text>	</xsl:text></xsl:for-each>};<xsl:text>
</xsl:text>
			<!-- apply stereotypes -->
		  	<xsl:apply-templates select="." mode="stereotypes-template">
		  		<xsl:with-param name="templateNode" select=".."/>
		  		<xsl:with-param name="nestingLevel" select="$realNestingLevel"/>
		  	</xsl:apply-templates>

			<!-- process recursively -->
			<xsl:apply-templates select="./*" mode="qvtoTemplate">
				<xsl:with-param name="nestingLevel" select="$realNestingLevel+1"/>
			</xsl:apply-templates>
<xsl:text>
</xsl:text>
<xsl:for-each select="$template//selector">
<xsl:for-each select="ancestor::*"><xsl:text>	</xsl:text></xsl:for-each>};<xsl:text>
</xsl:text>
</xsl:for-each>
		</xsl:if>
		<xsl:if test="$update">
			<xsl:variable name="realNestingLevel" select="$nestingLevel+count($update//selector)-1"/>
			//qvtoUpdate <xsl:value-of select="$xmi_id"/>
<xsl:text>
</xsl:text>
<xsl:for-each select="$update//selector">
<xsl:variable name="level1Count" select="position()"/><xsl:variable name="nestingOffset" select="position()-1"/>
<xsl:for-each select="ancestor::*"><xsl:text>	</xsl:text></xsl:for-each><xsl:choose><xsl:when test="contains($update//selector[$level1Count]/text(),'(')"><xsl:value-of select="$update//selector[$level1Count]/text()"/></xsl:when><xsl:otherwise><xsl:apply-templates select="$update//selector[$level1Count]/text()" mode="normalize-id"/></xsl:otherwise></xsl:choose>->forEach(__elem<xsl:value-of select="$nestingLevel+$nestingOffset"/>){<xsl:text>
</xsl:text>
</xsl:for-each>
			<xsl:apply-templates mode="initialize-template-struct-vars" select=".">
				<xsl:with-param name="level" select="0"/>
				<xsl:with-param name="nestingLevel" select="$realNestingLevel"></xsl:with-param>
				<xsl:with-param name="topElement" select="."/>
			</xsl:apply-templates>
			<xsl:value-of select="$update/@template"/><xsl:text>
</xsl:text>
			<xsl:for-each select="./@*[not(contains(name(),'xmi'))]" >
				<xsl:apply-templates select="." mode="struct-for-updates">
					<xsl:with-param name="nestingLevel" select="$realNestingLevel"/>
					<xsl:with-param name="metaClassName" select="substring-after(../@xmi:type,'uml:' )"/>
				</xsl:apply-templates>
			</xsl:for-each>
			
			<!-- elementos de multiplicidad 1 en el metamodelo -->
			<xsl:for-each select="./*" >
				<xsl:apply-templates select="." mode="struct-for-updates">
					<xsl:with-param name="nestingLevel" select="$realNestingLevel"/>
					<xsl:with-param name="metaClassName" select="substring-after(../@xmi:type,'uml:' )"/>
				</xsl:apply-templates>
			</xsl:for-each>

			<!-- elementos de multiplicidad 1 en el metamodelo -->
			<xsl:apply-templates select="." mode="struct-for-updates-default-values">
				<xsl:with-param name="nestingLevel" select="$realNestingLevel"/>
				<xsl:with-param name="metaClassName" select="substring-after(@xmi:type,'uml:' )"/>
			</xsl:apply-templates>



		  	<xsl:apply-templates select="." mode="stereotypes-template">
		  		<xsl:with-param name="templateNode" select=".."/>
				<xsl:with-param name="nestingLevel" select="$realNestingLevel"/>
		  	</xsl:apply-templates>

			<xsl:apply-templates select="./*" mode="qvtoTemplate">
				<xsl:with-param name="nestingLevel" select="$realNestingLevel+1"/>
			</xsl:apply-templates>
<xsl:text>
</xsl:text>
<xsl:for-each select="$update//selector">
<xsl:for-each select="ancestor::*"><xsl:text>	</xsl:text></xsl:for-each>};<xsl:text>
</xsl:text>
</xsl:for-each>
		</xsl:if>
		<xsl:if test="$delete">
		<xsl:variable name="realNestingLevel" select="$nestingLevel+count($delete//selector)-1"/>
		//qvtoDelete <xsl:value-of select="$xmi_id"/>
<xsl:text>
</xsl:text>
<xsl:for-each select="$delete//selector">
<xsl:variable name="level1Count" select="position()"/><xsl:variable name="nestingOffset" select="position()-1"/>
<xsl:for-each select="ancestor::*"><xsl:text>	</xsl:text></xsl:for-each><xsl:choose><xsl:when test="contains($delete//selector[$level1Count]/text(),'(')"><xsl:value-of select="$delete//selector[$level1Count]/text()"/></xsl:when><xsl:otherwise><xsl:apply-templates select="$delete//selector[$level1Count]/text()" mode="normalize-id"/></xsl:otherwise></xsl:choose>->forEach(__elem<xsl:value-of select="$nestingLevel+$nestingOffset"/>){<xsl:text>
</xsl:text>
</xsl:for-each>
		<xsl:for-each select="ancestor-or-self::*"><xsl:text>	</xsl:text></xsl:for-each>__elem<xsl:value-of select="$realNestingLevel"/><xsl:text>.allOwnedElements()->collect(e | e.getStereotypeApplications())->union(</xsl:text>__elem<xsl:value-of select="$realNestingLevel"/><xsl:text>.getStereotypeApplications())->forEach(__stereotype__){
</xsl:text>
		<xsl:for-each select="ancestor-or-self::*"><xsl:text>	</xsl:text></xsl:for-each><xsl:text>	file.removeElement(__stereotype__);
</xsl:text>
		<xsl:for-each select="ancestor-or-self::*"><xsl:text>	</xsl:text></xsl:for-each><xsl:text>};
</xsl:text>
		<xsl:for-each select="ancestor-or-self::*"><xsl:text>	</xsl:text></xsl:for-each>file.removeElement(__elem<xsl:value-of select="$realNestingLevel"/>);<xsl:text>
</xsl:text>
<xsl:for-each select="$delete//selector">
<xsl:for-each select="ancestor::*"><xsl:text>	</xsl:text></xsl:for-each>};<xsl:text>
</xsl:text>
</xsl:for-each>
		</xsl:if>		
		<xsl:if  test="not($template) and not($delete) and not($update)">
			<xsl:apply-templates select="./*" mode="qvtoTemplate">
				<xsl:with-param name="nestingLevel" select="$nestingLevel"/>
			</xsl:apply-templates>		
		</xsl:if>
	</xsl:otherwise>
	</xsl:choose>
</xsl:template>



<xsl:template match="eAnnotations | eAnnotations/* | eAnnotations/@*" mode="struct-for-updates">
</xsl:template>

<xsl:template match="* | @*" mode="struct-for-updates">
	<xsl:param name="nestingLevel" select="0"/>
	<xsl:param name="metaClassName"/>
	<xsl:variable name="localName" select="local-name(.)"/>
<!-- //<xsl:value-of select="$metaClassName"/>_<xsl:value-of select="$localName"/> -->
	<xsl:variable name="metaClass" select="$umlMetamodel//ecore:EPackage[1]//*[./@xsi:type='ecore:EClass' and ./@name=$metaClassName]"/>
	<xsl:variable name="metaClassAttribute1" >
		<xsl:call-template name="getMetaClassAtribute">
			<xsl:with-param name="metaClass" select="$metaClass"/>
			<xsl:with-param name="localName2" select="$localName"/>
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="metaClassAttribute" select="common:node-set( $metaClassAttribute1)"/>
	<xsl:variable name="metaClassAttributeMultiplicity" select="$metaClassAttribute//@upperBound"/>
<!-- //multiplicity <xsl:value-of select="$metaClass/@name"/>.<xsl:value-of select="$metaClassAttribute//@name"/>=<xsl:value-of select="$metaClassAttributeMultiplicity"/><xsl:text> 
</xsl:text>-->
	<xsl:if test="$metaClassAttribute!='' and not($metaClassAttributeMultiplicity='-1')">
			<xsl:apply-templates select="." mode="struct">
				<xsl:with-param name="nestingLevel" select="$nestingLevel"/>
			</xsl:apply-templates>
	</xsl:if>			
</xsl:template>

<xsl:template match="*" mode="struct-for-updates-default-values">
	<xsl:param name="nestingLevel" select="0"/>
	<xsl:param name="metaClassName"/>
	
	<xsl:variable name="processingNode" select="." />
<!-- 	<xsl:variable name="alreadyProcessedAttributes" select="./@*[not(contains(name(),'xmi'))]" />
	<xsl:variable name="alreadyProcessedChild" select="./node()" /> -->
	<xsl:variable name="metaClass" select="$umlMetamodel//ecore:EPackage[1]//*[./@xsi:type='ecore:EClass' and ./@name=$metaClassName]"/>
	
<!--
	-For debug purpose-
 	<xsl:call-template name="printMetaClassAtributes">
			<xsl:with-param name="metaClass" select="$metaClass"/>
	</xsl:call-template>
 -->

	<xsl:variable name="metaClassAttributes1" >
		<xsl:call-template name="getMetaClassAtributes">
			<xsl:with-param name="metaClass" select="$metaClass"/>
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="metaClassAttributes" select="common:node-set( $metaClassAttributes1)/node()[local-name()='eStructuralFeatures' or local-name()='contents']"/>
<!-- <xsl:for-each select="$metaClassAttributes">
//-0-<xsl:value-of select="@name"/>,<xsl:value-of select="@derived"/>,<xsl:value-of select="@defaultValueLiteral"/>,<xsl:value-of select="count(preceding-sibling::*)"/>
</xsl:for-each>
 -->
 	<xsl:variable name="attributesToProcess" select="$metaClassAttributes[(not(@derived) or @derived='false')]"/>
	<xsl:for-each select="$attributesToProcess">
		<xsl:variable name="currAtt" select="."/>
		<xsl:variable name="attName" select="@name"/>
<!-- 		//-2-<xsl:value-of select="@name"/>,<xsl:value-of select="count($currAtt/preceding-sibling::*)"/>,<xsl:value-of select="count($attributesToProcess[@name=$attName and @defaultValueLiteral][1]/preceding-sibling::*)"/> -->
<!-- //-3-<xsl:value-of select="$currAtt/@name"/>;<xsl:value-of select="count($processingNode/@*[not(contains(name(),'xmi')) and local-name(.)=$currAtt/@name])"></xsl:value-of> -->
		<xsl:if test="not($processingNode/@*[not(contains(name(),'xmi')) and local-name(.)=$currAtt/@name])">
<!-- //-4-<xsl:value-of select="$currAtt/@name"/>;<xsl:value-of select="count($processingNode/node()[not(contains(name(),'xmi')) and local-name(.)=$currAtt/@name])"></xsl:value-of> -->
		<xsl:if test="not($processingNode/node()[not(contains(name(),'xmi')) and local-name(.)=$currAtt/@name])">
		<xsl:if test="
		(count($currAtt/preceding-sibling::*)=count($attributesToProcess[@name=$attName and @defaultValueLiteral][1]/preceding-sibling::*))
		">
			<xsl:apply-templates select="$processingNode" mode="struct-defaults">
				<xsl:with-param name="nestingLevel" select="$nestingLevel"/>
				<xsl:with-param name="metaAttribute" select="$currAtt"/>
			</xsl:apply-templates>
		</xsl:if>
		</xsl:if>
		</xsl:if>
	</xsl:for-each>
</xsl:template>

<xsl:template match="node()" mode="struct-defaults">
	<xsl:param name="nestingLevel" select="0"/>
	<xsl:param name="metaAttribute"/>
	<xsl:variable name="xmi_id" select="./@*[name(.)='xmi:id']"/>
	<xsl:variable name="template" select="/.//*[(name(.)='uml2qvto:QvtoTemplate' ) and  ./@base_Element=$xmi_id]"/>
	<xsl:variable name="update" select="/.//*[(name(.)='uml2qvto:QvtoUpdate' ) and  ./@base_Element=$xmi_id]"/>
	<xsl:variable name="delete" select="/.//*[(name(.)='uml2qvto:QvtoDelete' ) and  ./@base_Element=$xmi_id]"/>
			<xsl:variable name="ln" select="$metaAttribute/@name"/>
			<xsl:variable name="metaAttributeTypeMetaClass" select="$umlMetamodel//ecore:EPackage[1]//*[ @name=substring-after($metaAttribute/@eType,'#//')]"/>
<!-- 			//<xsl:value-of select="$metaAttribute/@name"/>,<xsl:value-of select="$metaAttribute/@eType"/> -->
			<xsl:choose>
			<xsl:when test="$metaAttributeTypeMetaClass/@xsi:type='ecore:EEnum'">
				<xsl:for-each select="ancestor::node()"><xsl:text>	</xsl:text></xsl:for-each>
				<xsl:if test="$update">__elem<xsl:value-of select="$nestingLevel"/>.</xsl:if>
				<xsl:call-template name="processReservedWords"><xsl:with-param name="input" select="$ln"/></xsl:call-template>:=uml::<xsl:value-of select="substring-after($metaAttribute//@eType,'#//')"/>::<xsl:call-template name="escape"><xsl:with-param name="val" select="$metaAttribute/@defaultValueLiteral"/></xsl:call-template>;	
			</xsl:when>
			<xsl:when test="$metaAttribute/@eType='ecore:EDataType platform:/plugin/org.eclipse.uml2.types/model/Types.ecore#//UnlimitedNatural'">
				<xsl:for-each select="ancestor::node()"><xsl:text>	</xsl:text></xsl:for-each>
				<xsl:if test="$update">__elem<xsl:value-of select="$nestingLevel"/>.</xsl:if>
				<xsl:call-template name="processReservedWords"><xsl:with-param name="input" select="$ln"/></xsl:call-template>:=<xsl:value-of select="$metaAttribute/@defaultValueLiteral"/>;	
			</xsl:when>
			<xsl:when test="$metaAttribute/@eType='ecore:EDataType platform:/plugin/org.eclipse.uml2.types/model/Types.ecore#//Integer'">
				<xsl:for-each select="ancestor::node()"><xsl:text>	</xsl:text></xsl:for-each>
				<xsl:if test="$update">__elem<xsl:value-of select="$nestingLevel"/>.</xsl:if>
				<xsl:call-template name="processReservedWords"><xsl:with-param name="input" select="$ln"/></xsl:call-template>:=<xsl:value-of select="$metaAttribute/@defaultValueLiteral"/>;	
			</xsl:when>			
			<xsl:when test="$metaAttribute/@eType='ecore:EDataType platform:/plugin/org.eclipse.uml2.types/model/Types.ecore#//Real'">
				<xsl:for-each select="ancestor::node()"><xsl:text>	</xsl:text></xsl:for-each>
				<xsl:if test="$update">__elem<xsl:value-of select="$nestingLevel"/>.</xsl:if>
				<xsl:call-template name="processReservedWords"><xsl:with-param name="input" select="$ln"/></xsl:call-template>:=<xsl:value-of select="$metaAttribute/@defaultValueLiteral"/>;	
			</xsl:when>			
			<xsl:when test="$metaAttribute/@eType='ecore:EDataType platform:/plugin/org.eclipse.uml2.types/model/Types.ecore#//Boolean'">
				<xsl:for-each select="ancestor::node()"><xsl:text>	</xsl:text></xsl:for-each>
				<xsl:if test="$update">__elem<xsl:value-of select="$nestingLevel"/>.</xsl:if>
				<xsl:call-template name="processReservedWords"><xsl:with-param name="input" select="$ln"/></xsl:call-template>:=<xsl:value-of select="$metaAttribute/@defaultValueLiteral"/>;	
			</xsl:when>
			</xsl:choose>
</xsl:template>

<xsl:template match="eAnnotations | eAnnotations/* | eAnnotations/@*" mode="stereotypes-template">
	<!-- we don't process ecore:eAnnotations when defining stereotypes-templates -->
</xsl:template>

<xsl:template match="*" mode="stereotypes-template">
	<xsl:param name="templateNode"/>
	<xsl:param name="nestingLevel"/>
	
	<xsl:variable name="refId" select="."/>
	<xsl:variable name="xmi_id" select="./@*[name(.)='xmi:id']"/>	
	<xsl:variable name="ignore" select="//*[(name(.)='uml2qvto:Ignore'  ) and  ./@base_Element=$xmi_id]"/>
	<xsl:variable name="ignoreAll" select="//*[(name(.)='uml2qvto:IgnoreAll') and  ./@base_Element=$xmi_id]"/>
	<xsl:variable name="template" select="//*[(name(.)='uml2qvto:QvtoTemplate' ) and  ./@base_Element=$xmi_id]"/>
	<xsl:variable name="update" select="//*[(name(.)='uml2qvto:QvtoUpdate' ) and  ./@base_Element=$xmi_id]"/>
	<xsl:variable name="delete" select="//*[(name(.)='uml2qvto:QvtoDelete' ) and  ./@base_Element=$xmi_id]"/>
	
	<xsl:choose>
	<xsl:when test="$ignore">
	</xsl:when>
	<xsl:otherwise>
		<!-- stereotypes allways are applied to an element, defined by a attribute whose name starts with "base_" -->
		<xsl:apply-templates select="/.//*[name(.)='uml:Model']/following::*[./@*[contains(name(),'base_')]=$xmi_id]" mode="stereotypes">
			<xsl:with-param name="templateNode" select="$templateNode"/>
			<xsl:with-param name="nestingLevel" select="$nestingLevel"/>
			<xsl:with-param name="update" select="$update"/>
		</xsl:apply-templates>
	
		<xsl:for-each select="./*">
			<xsl:variable name="xmi_id" select="@xmi:id"/>
			<xsl:variable name="template" select="/.//*[(name(.)='uml2qvto:QvtoTemplate' ) and  ./@base_Element=$xmi_id]"/>
			<xsl:variable name="update" select="/.//*[(name(.)='uml2qvto:QvtoUpdate' ) and  ./@base_Element=$xmi_id]"/>
			<xsl:variable name="delete" select="/.//*[(name(.)='uml2qvto:QvtoDelete' ) and  ./@base_Element=$xmi_id]"/>
			<xsl:if test="not($template) and not($update) and not($delete)">
			<xsl:apply-templates select="." mode="stereotypes-template">
				<xsl:with-param name="templateNode" select="$templateNode"/>
				<xsl:with-param name="nestingLevel" select="$nestingLevel"/>
			</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>
	</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<xsl:template match="eAnnotations | eAnnotations/* | eAnnotations/@*" mode="referenceResolvers">
	<!-- we don't process ecore:eAnnotations when defining reference resolvers-->
</xsl:template>

<xsl:template match="*" mode="referenceResolvers">
	<!-- 	Creates a mapping for each used type of the uml metamodel.
			This mapping will be used to create elements, and also will be used to resolve already created elements by name.
			This is very useful to simplify the transformations, but requires that all elements are created with a distinguishable name (whe use the all the names of its full path from the root element), and at the end of the transformation have to be renamed to the desired name (its desired name)
	 -->
	<xsl:variable name="type" select="./@xmi:type"/>
	<!-- process if is the very first instance of the type processed, to avoid duplicates -->
	<xsl:if test="count(preceding::*[@xmi:type=$type and @name])=0 and count(ancestor::*[@xmi:type=$type and @name])=0">
	<!-- don't process elements without type, and that without name -->
	<xsl:if test="$type!='' and @name">
<xsl:text>
</xsl:text><xsl:for-each select="ancestor-or-self::*"><xsl:text>	</xsl:text></xsl:for-each><!-- format -->
mapping <xsl:value-of select="substring-after(@xmi:type,':' )" />(n : String) : <xsl:value-of select="substring-before(@xmi:type,':' )" />::<xsl:value-of select="substring-after(@xmi:type,':' )" />{
	name:=n;
};
	</xsl:if>
		</xsl:if>
	<xsl:apply-templates select="./*" mode="referenceResolvers"/>
	
</xsl:template>




<!--  por cada tipo de elemento template o hijo de template que tenga un atributo name
Hay que generar una funcion 
map <tipo>(String nombre):<tipo>{
name=nombre;
}

En la parte initialize-template-struct-vars hay que hacer aparte de poner a null:
Si vemos que hay un elemento o atributo que pinta el modo struct (nodos o atributos), que es template o hijo de un nodo template

com_onlineshop_onlineshop_front_form_0_0_1_war:=null; //para no afectar al valor antiguo
com_onlineshop_onlineshop_front_form_0_0_1_war:=map Component('<nombre>');
					
Para crear una referencia, o recuperar una ya creada, a partir del nombre (que suele ser el id ónico, para los demós casos, a joderse)

 -->

<xsl:template match="eAnnotations | eAnnotations/* | eAnnotations/@*" mode="initialize-template-struct-vars">
</xsl:template>

<xsl:template match="*" mode="initialize-template-struct-vars">
	<xsl:param name="level" />
	<xsl:param name="nestingLevel" />
	<xsl:param name="topElement"/>
	<xsl:variable name="topElement_xmi_id" select="$topElement/@xmi:id"/>
	<xsl:variable name="curr" select="."/>
	<xsl:variable name="xmi_id" select="./@*[name(.)='xmi:id']"/>
	<xsl:variable name="ignore" select="/.//*[(name(.)='uml2qvto:Ignore'  ) and  ./@base_Element=$xmi_id]"/>
	<xsl:variable name="ignoreAll" select="/.//*[(name(.)='uml2qvto:IgnoreAll') and  ./@base_Element=$xmi_id]"/>
	<xsl:variable name="template" select="/.//*[(name(.)='uml2qvto:QvtoTemplate' ) and  ./@base_Element=$xmi_id]"/>
	<xsl:variable name="update" select="/.//*[(name(.)='uml2qvto:QvtoUpdate' ) and  ./@base_Element=$xmi_id]"/>
	<xsl:variable name="delete" select="/.//*[(name(.)='uml2qvto:QvtoDelete' ) and  ./@base_Element=$xmi_id]"/>
<!-- <xsl:text>//begin  - initialize-template-struct-vars - </xsl:text><xsl:value-of select="name()"/><xsl:text>
</xsl:text>	 -->

	<xsl:choose>
	<xsl:when test="$ignore">
		<xsl:apply-templates select="./*" mode="initialize-template-struct-vars">
						<xsl:with-param name="topElement" select="$topElement"/>
						<xsl:with-param name="nestingLevel" select="$nestingLevel"/>
		</xsl:apply-templates>
	</xsl:when>
	<xsl:when test="$ignoreAll or $update"><!-- PJR en este caso los updates no generan variables, si hiciera falta, habría que mirar si en el metamodelo tienen multiplicidad -1 para ignorarlos -->
	</xsl:when>
	<xsl:when test="$level!='0' and ($template/@base_Element!='' or $update/@base_Element!='' or $delete/@base_Element!='')">
	</xsl:when>
	<xsl:otherwise>	
	 	<xsl:variable name="notTemplateOrChild">
			<xsl:for-each select="ancestor-or-self::*">
				 <xsl:variable name="xmi_id2" select="./@xmi:id"/>
				 <xsl:variable name="templates" select="//*[(name(.)='uml2qvto:QvtoTemplate' ) and  ./@base_Element=$xmi_id2]"/>
				 <xsl:variable name="updates" select="//*[(name(.)='uml2qvto:QvtoUpdate' ) and  ./@base_Element=$xmi_id2]"/>
				 <xsl:variable name="deletes" select="//*[(name(.)='uml2qvto:QvtoDelete' ) and  ./@base_Element=$xmi_id2]"/>
				 <xsl:value-of select="$templates/@base_Element"/>
				 <xsl:value-of select="$updates/@base_Element"/>
				 <xsl:value-of select="$deletes/@base_Element"/>
			 </xsl:for-each>
		</xsl:variable>
		
		<xsl:if test="$notTemplateOrChild!='' and @xmi:id">
			<xsl:for-each select="ancestor-or-self::*"><xsl:text>	</xsl:text></xsl:for-each><xsl:apply-templates select="@xmi:id" mode="normalize-id"/> :=null;<xsl:text>
</xsl:text>
			<xsl:if test="@name">
			<xsl:choose>
			<xsl:when test="$update and string($topElement_xmi_id)=string($xmi_id)">
			<xsl:for-each select="ancestor::*"><xsl:text>	</xsl:text></xsl:for-each><xsl:text>	</xsl:text><xsl:apply-templates select="@xmi:id" mode="normalize-id"/> := __elem<xsl:value-of select="$nestingLevel"/>;<xsl:text>
</xsl:text>
			</xsl:when>
			<xsl:otherwise>
			<xsl:for-each select="ancestor-or-self::*"><xsl:text>	</xsl:text></xsl:for-each><xsl:apply-templates select="@xmi:id" mode="normalize-id"/> := map <xsl:value-of select="substring-after(@xmi:type,':' )" />('<xsl:call-template name="getUniqueName"><xsl:with-param name="val" select="."/> </xsl:call-template>');<xsl:text>
</xsl:text>
			</xsl:otherwise>
			</xsl:choose>

			</xsl:if>
		</xsl:if>
				 
		<xsl:variable name="xmi_id2" select="./@xmi:id"/>
		<xsl:variable name="templateName" select="'uml2qvto:QvtoTemplate'"/>
		<xsl:variable name="updateName" select="'uml2qvto:QvtoUpdate'"/>
		<xsl:variable name="deleteName" select="'uml2qvto:QvtoDelete'"/>
		<xsl:variable name="newLevel">
			<xsl:choose>
			<xsl:when test='//*[(name(.)=$templateName or name(.)=$updateName or name(.)=$deleteName ) and  ./@base_Element=$xmi_id2]'>1</xsl:when>
		 		<xsl:otherwise><xsl:value-of select="$level"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
 <!-- 			// ######## <xsl:value-of select="$level"/>_<xsl:value-of select="$newLevel"/> <xsl:value-of select="$template/@base_Element"/>  <xsl:value-of select="$template/@base_Element!=''"/><xsl:text>
	</xsl:text>  -->
	<!-- <xsl:text>///initialize-template-struct-vars - @*
</xsl:text> -->
	 	<xsl:apply-templates select="./@*" mode="initialize-template-struct-vars">
				<xsl:with-param name="topElement" select="$topElement"/>
				<xsl:with-param name="nestingLevel" select="$nestingLevel"/>
	 	</xsl:apply-templates>  
	<!-- <xsl:text>///initialize-template-struct-vars - ./*
</xsl:text> -->
		<xsl:apply-templates select="./*" mode="initialize-template-struct-vars">
			<xsl:with-param name="level" select="$newLevel"/>
			<xsl:with-param name="topElement" select="$topElement"/>
			<xsl:with-param name="nestingLevel" select="$nestingLevel"/>
		</xsl:apply-templates>
	<!-- <xsl:text>///initialize-template-struct-vars - stereotype
</xsl:text> -->
		<xsl:apply-templates mode="initialize-template-struct-vars" select="/.//*[name(.)='uml:Model']/following::*[./@*[contains(name(),'base_')]=$xmi_id2]">
			<xsl:with-param name="level" select="$level"/>
			<xsl:with-param name="topElement" select="$topElement"/>
			<xsl:with-param name="nestingLevel" select="$nestingLevel"/>
		</xsl:apply-templates>
	</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="@*" mode="initialize-template-struct-vars">
	<xsl:param name="topElement"/>
	<xsl:param name="nestingLevel" />
<xsl:if test="not(starts-with(name(),'base_') or name()='xmi:id')">	
	<xsl:variable name="topElement_xmi_id" select="$topElement/@xmi:id"/>
	<xsl:variable name="xmi_id" select="."/>
	<xsl:variable name="ref" select="/.//*[@xmi:id=$xmi_id]"/>
	<xsl:variable name="ignore" select="/.//*[(name(.)='uml2qvto:Ignore'  ) and  ./@base_Element=$xmi_id]"/>
	<xsl:variable name="notTemplateChild">
		<xsl:for-each select="$ref/ancestor::* ">
			 <xsl:variable name="xmi_id2" select="./@xmi:id"/>
			 <xsl:variable name="templates" select="/.//*[(name(.)='uml2qvto:QvtoTemplate' ) and  ./@base_Element=$xmi_id2]"/>
			 <xsl:variable name="updates" select="/.//*[(name(.)='uml2qvto:QvtoUpdate' ) and  ./@base_Element=$xmi_id2]"/>
			 <xsl:variable name="deletes" select="/.//*[(name(.)='uml2qvto:QvtoDelete' ) and  ./@base_Element=$xmi_id2]"/>
			 <xsl:value-of select="$templates/@base_Element"/>
			 <xsl:value-of select="$updates/@base_Element"/>
			 <xsl:value-of select="$deletes/@base_Element"/>
		 </xsl:for-each>
	</xsl:variable>
	<xsl:variable name="notTemplate">
			 <xsl:variable name="templates" select="/.//*[(name(.)='uml2qvto:QvtoTemplate' ) and  ./@base_Element=$xmi_id]"/>
			 <xsl:variable name="updates" select="/.//*[(name(.)='uml2qvto:QvtoUpdate' ) and  ./@base_Element=$xmi_id]"/>
			 <xsl:variable name="deletes" select="/.//*[(name(.)='uml2qvto:QvtoDelete' ) and  ./@base_Element=$xmi_id]"/>
			 <xsl:value-of select="$templates/@base_Element"/>
			 <xsl:value-of select="$updates/@base_Element"/>
			 <xsl:value-of select="$deletes/@base_Element"/>
	</xsl:variable>
	<xsl:variable name="update" select="/.//*[(name(.)='uml2qvto:QvtoUpdate' ) and  ./@base_Element=$xmi_id]"/>

	<!-- // ##<xsl:value-of select="$notTemplateChild" />_<xsl:value-of select="$notTemplate" />__@_<xsl:value-of select="$xmi_id" />_#_<xsl:value-of select="$ref/@xmi:id" /> <xsl:text>
</xsl:text>
	<xsl:text>//@</xsl:text><xsl:value-of select="name()"/><xsl:text>
</xsl:text> -->
	<xsl:choose>
	<xsl:when test="$ignore">
	</xsl:when>
	<xsl:when test="($notTemplateChild!='' or $notTemplate!='')">
		<xsl:if test="$ref/@name">
		<xsl:for-each select="ancestor::*"><xsl:text>	</xsl:text></xsl:for-each><xsl:apply-templates select="$ref/@xmi:id" mode="normalize-id"/> :=null;<xsl:text>
</xsl:text>
			<xsl:choose>
			<xsl:when test="$update and string($topElement_xmi_id)=string($ref/@xmi:id)">
		<xsl:for-each select="ancestor::*"><xsl:text>	</xsl:text></xsl:for-each><xsl:apply-templates select="$ref/@xmi:id" mode="normalize-id"/> := __elem<xsl:value-of select="$nestingLevel"/>;<xsl:text>
</xsl:text>
			</xsl:when>
			<xsl:otherwise>
		<xsl:for-each select="ancestor::*"><xsl:text>	</xsl:text></xsl:for-each><xsl:apply-templates select="$ref/@xmi:id" mode="normalize-id"/> := map <xsl:value-of select="substring-after($ref/@xmi:type,':' )" />('<xsl:call-template name="getUniqueName"><xsl:with-param name="val" select="$ref"/> </xsl:call-template>');<xsl:text>
</xsl:text>
			</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:when>
	</xsl:choose>
</xsl:if>
</xsl:template>


<xsl:template match="eAnnotations | eAnnotations/* | eAnnotations/@*" mode="recover-qvtoTemplate">
</xsl:template>

<xsl:template match="*" mode="recover-qvtoTemplate">
	<xsl:param name="nestingLevel"/>
	<xsl:variable name="xmi_id" select="./@*[name(.)='xmi:id']"/>
	<xsl:variable name="ignore" select="//*[(name(.)='uml2qvto:Ignore'  ) and  ./@base_Element=$xmi_id]"/>
	<xsl:variable name="ignoreAll" select="//*[(name(.)='uml2qvto:IgnoreAll') and  ./@base_Element=$xmi_id]"/>
	<xsl:variable name="template" select="//*[(name(.)='uml2qvto:QvtoTemplate' ) and  ./@base_Element=$xmi_id]"/>
	<xsl:variable name="update" select="//*[(name(.)='uml2qvto:QvtoUpdate' ) and  ./@base_Element=$xmi_id]"/>
	<xsl:variable name="delete" select="//*[(name(.)='uml2qvto:QvtoDelete' ) and  ./@base_Element=$xmi_id]"/>
	
	<xsl:choose>
	<xsl:when test="$ignore">
	// ignore as template <xsl:value-of select="@name"></xsl:value-of><xsl:text>
</xsl:text>
	<xsl:apply-templates select="./*" mode="recover-qvtoTemplate">
	<xsl:with-param name="nestingLevel" select="$nestingLevel"/>
	</xsl:apply-templates>
	</xsl:when>
	<xsl:otherwise>
		<xsl:choose>
		<xsl:when test="$template">
<xsl:text>
</xsl:text>
<xsl:for-each select="$template//selector">
<xsl:variable name="level1Count" select="position()"/><xsl:variable name="nestingOffset" select="position()-1"/>
<xsl:for-each select="ancestor::*"><xsl:text>	</xsl:text></xsl:for-each><xsl:choose><xsl:when test="contains($template//selector[$level1Count]/text(),'(')"><xsl:value-of select="$template//selector[$level1Count]/text()"/></xsl:when><xsl:otherwise><xsl:apply-templates select="$template//selector[$level1Count]/text()" mode="normalize-id"/></xsl:otherwise></xsl:choose>->forEach(__elem<xsl:value-of select="$nestingLevel+$nestingOffset"/>){<xsl:text>
</xsl:text>
</xsl:for-each>
			<xsl:if test="not($ignoreAll)">
				<xsl:apply-templates mode="recover-template-struct-vars" select=".">
					<xsl:with-param name="level" select="0"/>
				</xsl:apply-templates>
			</xsl:if>
			<xsl:apply-templates select="./*" mode="recover-qvtoTemplate">
				<xsl:with-param name="nestingLevel" select="$nestingLevel+1"/>
			</xsl:apply-templates>
<xsl:text>
</xsl:text>
<xsl:for-each select="$template//selector">
<xsl:for-each select="ancestor::*"><xsl:text>	</xsl:text></xsl:for-each>};<xsl:text>
</xsl:text>
</xsl:for-each>
		</xsl:when>
		<xsl:when test="$update"><!--  nada mapeado, así que no hay que recuperar nada --></xsl:when>
		<xsl:when test="$delete"><!--  nada mapeado, así que no hay que recuperar nada --></xsl:when>		
		<xsl:otherwise>
			<xsl:apply-templates select="./*" mode="recover-qvtoTemplate">
				<xsl:with-param name="nestingLevel" select="$nestingLevel"/>
			</xsl:apply-templates>		
		</xsl:otherwise>
		</xsl:choose>
	</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="*" mode="recover-template-struct-vars">
	<xsl:param name="level" />
	<xsl:variable name="xmi_id" select="./@*[name(.)='xmi:id']"/>
	<xsl:variable name="ignore" select="/.//*[(name(.)='uml2qvto:Ignore'  ) and  ./@base_Element=$xmi_id]"/>
	<xsl:variable name="ignoreAll" select="/.//*[(name(.)='uml2qvto:IgnoreAll') and  ./@base_Element=$xmi_id]"/>
	<xsl:variable name="template" select="/.//*[(name(.)='uml2qvto:QvtoTemplate' ) and  ./@base_Element=$xmi_id]"/>
	<xsl:variable name="update" select="/.//*[(name(.)='uml2qvto:QvtoUpdate' ) and  ./@base_Element=$xmi_id]"/>
	<xsl:variable name="delete" select="/.//*[(name(.)='uml2qvto:QvtoDelete' ) and  ./@base_Element=$xmi_id]"/>
	<xsl:choose>
	<xsl:when test="$ignore">
		<xsl:apply-templates select="./*" mode="recover-template-struct-vars"/>
	</xsl:when>
	<xsl:when test="$ignoreAll">
	</xsl:when>
	<xsl:when test="$level!='0' and ($template/@base_Element!='' or $update/@base_Element!='' or $delete/@base_Element!='')">
	</xsl:when>
	<xsl:otherwise>	
	 	<xsl:variable name="notTemplateOrChild">
			<xsl:for-each select="ancestor-or-self::*">
				 <xsl:variable name="xmi_id2" select="./@xmi:id"/>
				 <xsl:variable name="templates" select="//*[(name(.)='uml2qvto:QvtoTemplate' ) and  ./@base_Element=$xmi_id2]"/>
				 <xsl:variable name="updates" select="//*[(name(.)='uml2qvto:QvtoUpdate' ) and  ./@base_Element=$xmi_id2]"/>
				 <xsl:variable name="deletes" select="//*[(name(.)='uml2qvto:QvtoDelete' ) and  ./@base_Element=$xmi_id2]"/>
				 <xsl:value-of select="$templates/@base_Element"></xsl:value-of>
				 <xsl:value-of select="$updates/@base_Element"></xsl:value-of>
				 <xsl:value-of select="$deletes/@base_Element"></xsl:value-of>
			 </xsl:for-each>
		</xsl:variable>
		<xsl:if test="$notTemplateOrChild!='' and @xmi:id">
			<xsl:if test="@name">
<xsl:for-each select="ancestor-or-self::*"><xsl:text>	</xsl:text></xsl:for-each>map <xsl:value-of select="substring-after(@xmi:type,':' )" />('<xsl:call-template name="getUniqueName"><xsl:with-param name="val" select="."/></xsl:call-template>').name:='<xsl:value-of select="@name" />';<xsl:text>
</xsl:text>
			</xsl:if>
		</xsl:if>
				 
		<xsl:variable name="xmi_id2" select="./@xmi:id"/>
		<xsl:variable name="templateName" select="'uml2qvto:QvtoTemplate'"/>
		<xsl:variable name="updateName" select="'uml2qvto:QvtoUpdate'"/>
		<xsl:variable name="deleteName" select="'uml2qvto:QvtoDelete'"/>
		<xsl:variable name="newLevel">
			<xsl:choose>
			<xsl:when test='//*[(name(.)=$templateName or name(.)=$updateName or name(.)=$deleteName ) and  ./@base_Element=$xmi_id2]'>1</xsl:when>
		 		<xsl:otherwise><xsl:value-of select="$level"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
	<!-- 			 ######## <xsl:value-of select="$level"/>_<xsl:value-of select="$newLevel"/> <xsl:value-of select="$template/@base_Element"/>  <xsl:value-of select="$template/@base_Element!=''"/><xsl:text>
	</xsl:text> -->
	 	<xsl:apply-templates select="./@*" mode="recover-template-struct-vars"/>  
		<xsl:apply-templates select="./*" mode="recover-template-struct-vars">
			<xsl:with-param name="level" select="$newLevel"/>
		</xsl:apply-templates>

	</xsl:otherwise>
	</xsl:choose>
</xsl:template>



<xsl:template match="@*" mode="recover-template-struct-vars">
	<xsl:variable name="xmi_id" select="."/>
	<xsl:variable name="ref" select="/.//*[@xmi:id=$xmi_id]"/>
	<xsl:variable name="notTemplateChild">
		<xsl:for-each select="$ref/ancestor::* ">
			 <xsl:variable name="xmi_id2" select="./@xmi:id"/>
			 <xsl:variable name="templates" select="/.//*[(name(.)='uml2qvto:QvtoTemplate' ) and  ./@base_Element=$xmi_id2]"/>
			 <xsl:value-of select="$templates/@base_Element"></xsl:value-of>
		 </xsl:for-each>
	</xsl:variable>
	<xsl:variable name="notTemplate">
			 <xsl:variable name="templates" select="/.//*[(name(.)='uml2qvto:QvtoTemplate' ) and  ./@base_Element=$xmi_id]"/>
			 <xsl:value-of select="$templates/@base_Element"></xsl:value-of>
	</xsl:variable>
	<xsl:if test="($notTemplateChild!='' or $notTemplate!='')">
		<xsl:if test="not(../ancestor::*/@*[.=$xmi_id])"> <!-- el primero de todos para evitar duplicados -->
		<xsl:if test="$ref/@name">
<xsl:for-each select="ancestor-or-self::*"><xsl:text>	</xsl:text></xsl:for-each>map <xsl:value-of select="substring-after($ref/@xmi:type,':' )" />('<xsl:call-template name="getUniqueName"><xsl:with-param name="val" select="$ref"/></xsl:call-template>').name:='<xsl:value-of select="$ref/@name" />';<xsl:text>
</xsl:text>
		</xsl:if>
		</xsl:if>
	</xsl:if>
</xsl:template>


<xsl:template name="getUniqueName">
<xsl:param name="val"/>
<xsl:for-each select="$val/ancestor-or-self::*"><xsl:if test="./@name"><xsl:value-of select="./@name" /><xsl:text>_</xsl:text></xsl:if></xsl:for-each><xsl:value-of select="count($val/preceding::*[string(@name)=string($val/@name)])"/></xsl:template>

<xsl:template name="processProfileName">
<xsl:param name="val"/>
<xsl:choose>
<xsl:when test="$val='standard'">StandardProfile</xsl:when>
<xsl:otherwise><xsl:value-of select="$val"/></xsl:otherwise>
</xsl:choose>
</xsl:template>



<xsl:template match="* | @* | node()"  mode="normalize-id">
<xsl:value-of select="translate(translate(translate(translate(translate(translate(translate(.,'.','_'),':','_'),'-','_'),' ','_'),'$','_'),'{','_'),'}','_')"/>
</xsl:template>

<xsl:template name="normalize-id">
<xsl:param name="val"/>
<xsl:value-of select="translate(translate(translate(translate(translate(translate(translate($val,'.','_'),':','_'),'-','_'),' ','_'),'$','_'),'{','_'),'}','_')"/>
</xsl:template>


<xsl:template name="getFirstItem">
	<!--  function used to retrieve the first item of an xmi attribute sequence (an attribute with multiple referenced values, whith a blank space separator)-->
	<xsl:param name="currAttr" />
	<xsl:param name="csv" />
	<xsl:param name="localName" />
	<xsl:variable name="res">
		<xsl:choose>
		  	<xsl:when test="/.//*[@xmi:id=normalize-space(substring-before( concat( $csv, ' '), ' '))]">
		  		<xsl:value-of select="normalize-space(substring-before( concat( $csv, ' '), ' '))"/>
		  	</xsl:when>
		  	<xsl:otherwise>
		  		<xsl:choose>
		  			<xsl:when test="$localName='name'">
		  				<xsl:call-template  name="getUniqueName"><xsl:with-param name="val" select="$currAttr"/></xsl:call-template>
		  			</xsl:when>
		  			<xsl:otherwise>
		  				<xsl:value-of select="$csv"/>
		  			</xsl:otherwise>
		  		</xsl:choose>
		  	</xsl:otherwise>
		</xsl:choose>
 	</xsl:variable>
 	<xsl:value-of select="string(common:node-set($res))"/>
</xsl:template>

<xsl:template name="countTokens">
 <xsl:param name="csv" />
 <xsl:param name="counter" select="0"></xsl:param>
  <xsl:variable name="first-item" select="normalize-space( substring-before( concat( $csv, ' '), ' '))" /> 
	<xsl:choose>
	 	<xsl:when test="/.//*[@xmi:id=normalize-space(substring-before( concat( $csv, ' '), ' '))]">
		  <xsl:call-template name="countTokens"> 
		   <xsl:with-param name="csv" select="substring-after($csv,' ')" /> 
		   <xsl:with-param name="counter" select="$counter+1" />
		  </xsl:call-template> 
	 	</xsl:when>
	 	<xsl:otherwise>
		  <xsl:value-of select="$counter"/> 
	  	</xsl:otherwise>
	</xsl:choose>
 
</xsl:template>

<xsl:template name="processReservedWords">
	<!-- processes reserved qvto words -->
	<xsl:param name="input"/>
	<xsl:variable name="out0" select="string($input)"/>
	<xsl:variable name="out1" select="regex:replaceAll(string($out0),'^checkonly$','_checkonly')"/>
	<xsl:variable name="out2" select="regex:replaceAll(string($out1),'^domain$','_domain')"/>
	<xsl:variable name="out3" select="regex:replaceAll(string($out2),'^enforce$','_enforce')"/>
	<xsl:variable name="out4" select="regex:replaceAll(string($out3),'^extends$','_extends')"/>
	<xsl:variable name="out5" select="regex:replaceAll(string($out4),'^implementedby$','_implementedby')"/>
	<xsl:variable name="out6" select="regex:replaceAll(string($out5),'^import$','_import')"/>
	<xsl:variable name="out7" select="regex:replaceAll(string($out6),'^key$','_key')"/>
	<xsl:variable name="out8" select="regex:replaceAll(string($out7),'^overrides$','_overrides')"/>
	<xsl:variable name="out9" select="regex:replaceAll(string($out8),'^primitive$','_primitive')"/>
	<xsl:variable name="out10" select="regex:replaceAll(string($out9),'^query$','_query')"/>
	<xsl:variable name="out11" select="regex:replaceAll(string($out10),'^relation$','_relation')"/>
	<xsl:variable name="out12" select="regex:replaceAll(string($out11),'^top$','_top')"/>
	<xsl:variable name="out13" select="regex:replaceAll(string($out12),'^transformation$','_transformation')"/>
	<xsl:variable name="out14" select="regex:replaceAll(string($out13),'^when$','_when')"/>
	<xsl:variable name="out15" select="regex:replaceAll(string($out14),'^where$','_where')"/>
	<xsl:variable name="out16" select="regex:replaceAll(string($out15),'^and$','_and')"/>
	<xsl:variable name="out17" select="regex:replaceAll(string($out16),'^body$','_body')"/>
	<xsl:variable name="out18" select="regex:replaceAll(string($out17),'^context$','_context')"/>
	<xsl:variable name="out19" select="regex:replaceAll(string($out18),'^def$','_def')"/>
	<xsl:variable name="out20" select="regex:replaceAll(string($out19),'^derive$','_derive')"/>
	<xsl:variable name="out21" select="regex:replaceAll(string($out20),'^else$','_else')"/>
	<xsl:variable name="out22" select="regex:replaceAll(string($out21),'^endif$','_endif')"/>
	<xsl:variable name="out23" select="regex:replaceAll(string($out22),'^endpackage$','_endpackage')"/>
	<!-- <xsl:variable name="out24" select="regex:replaceAll(string($out40),'^false$','_false')"/> -->
	<xsl:variable name="out24" select="$out23"/>
	<xsl:variable name="out25" select="regex:replaceAll(string($out24),'^if$','_if')"/>
	<xsl:variable name="out26" select="regex:replaceAll(string($out25),'^implies$','_implies')"/>
	<xsl:variable name="out27" select="regex:replaceAll(string($out26),'^in$','_in')"/>
	<xsl:variable name="out28" select="regex:replaceAll(string($out27),'^init$','_init')"/>
	<xsl:variable name="out29" select="regex:replaceAll(string($out28),'^inv$','_inv')"/>
	<xsl:variable name="out30" select="regex:replaceAll(string($out29),'^invalid$','_invalid')"/>
	<xsl:variable name="out31" select="regex:replaceAll(string($out30),'^let$','_let')"/>
	<xsl:variable name="out32" select="regex:replaceAll(string($out31),'^not$','_not')"/>
	<xsl:variable name="out33" select="regex:replaceAll(string($out32),'^null$','_null')"/>
	<xsl:variable name="out34" select="regex:replaceAll(string($out33),'^or$','_or')"/>
	<xsl:variable name="out35" select="regex:replaceAll(string($out34),'^package$','_package')"/>
	<xsl:variable name="out36" select="regex:replaceAll(string($out35),'^post$','_post')"/>
	<xsl:variable name="out37" select="regex:replaceAll(string($out36),'^pre$','_pre')"/>
	<xsl:variable name="out38" select="regex:replaceAll(string($out37),'^self$','_self')"/>
	<xsl:variable name="out39" select="regex:replaceAll(string($out38),'^static$','_static')"/>
	<xsl:variable name="out40" select="regex:replaceAll(string($out39),'^then$','_then')"/>
	<!-- <xsl:variable name="out41" select="regex:replaceAll(string($out40),'^true$','_true')"/> -->
	<xsl:variable name="out41" select="$out40"/>
	<xsl:variable name="out42" select="regex:replaceAll(string($out41),'^xor$','_xor')"/>
	<xsl:variable name="out43" select="regex:replaceAll(string($out42),'^Bag$','_Bag')"/>
	<xsl:variable name="out44" select="regex:replaceAll(string($out43),'^Boolean$','_Boolean')"/>
	<xsl:variable name="out45" select="regex:replaceAll(string($out44),'^Collection$','_Collection')"/>
	<xsl:variable name="out46" select="regex:replaceAll(string($out45),'^Integer$','_Integer')"/>
	<xsl:variable name="out47" select="regex:replaceAll(string($out46),'^OclAny$','_OclAny')"/>
	<xsl:variable name="out48" select="regex:replaceAll(string($out47),'^OclInvalid$','_OclInvalid')"/>
	<xsl:variable name="out49" select="regex:replaceAll(string($out48),'^OclMessage$','_')"/>
	<xsl:variable name="out50" select="regex:replaceAll(string($out49),'^OclVoid$','_OclVoid')"/>
	<xsl:variable name="out51" select="regex:replaceAll(string($out50),'^OrderedSet$','_OrderedSet')"/>
	<xsl:variable name="out52" select="regex:replaceAll(string($out51),'^Real$','_Real')"/>
	<xsl:variable name="out53" select="regex:replaceAll(string($out52),'^Sequence$','_Sequence')"/>
	<xsl:variable name="out54" select="regex:replaceAll(string($out53),'^Set$','_Set')"/>
	<xsl:variable name="out55" select="regex:replaceAll(string($out54),'^String$','_String')"/>
	<xsl:variable name="out56" select="regex:replaceAll(string($out55),'^Tuple$','_Tuple')"/>
	<xsl:variable name="out57" select="regex:replaceAll(string($out56),'^UnlimitedNatural$','_UnlimitedNatural')"/>
	<xsl:variable name="out58" select="regex:replaceAll(string($out57),'^forEach$','_forEach')"/>
	<xsl:variable name="out59" select="regex:replaceAll(string($out58),'^compute$','_compute')"/>
	<xsl:variable name="out60" select="regex:replaceAll(string($out59),'^break$','_break')"/>
	<xsl:variable name="out61" select="regex:replaceAll(string($out60),'^continue$','_continue')"/>
	<xsl:variable name="out62" select="regex:replaceAll(string($out61),'^xselect$','_xselect')"/>
	<xsl:variable name="out63" select="regex:replaceAll(string($out62),'^xcollect$','_xcollect')"/>
	<xsl:variable name="out64" select="regex:replaceAll(string($out63),'^map$','_map')"/>
	<xsl:variable name="out65" select="regex:replaceAll(string($out64),'^access$','_access')"/>
	<xsl:variable name="out66" select="regex:replaceAll(string($out65),'^in$','_in')"/>
	<xsl:variable name="out67" select="regex:replaceAll(string($out66),'^out$','_out')"/>
	<xsl:variable name="out68" select="regex:replaceAll(string($out67),'^inout$','_inout')"/>
	<xsl:variable name="out69" select="regex:replaceAll(string($out68),'^var$','_var')"/>
	<xsl:variable name="out70" select="regex:replaceAll(string($out69),'^new$','_new')"/>
	<xsl:variable name="out71" select="regex:replaceAll(string($out70),'^return$','_return')"/>
	<xsl:variable name="out72" select="regex:replaceAll(string($out71),'^log$','_log')"/>
	<xsl:variable name="out73" select="regex:replaceAll(string($out72),'^this$','_this')"/>
	<xsl:variable name="out74" select="regex:replaceAll(string($out73),'^extension$','_extension')"/>
	<xsl:variable name="out75" select="regex:replaceAll(string($out74),'^mapping$','_mapping')"/>
	<xsl:variable name="out76" select="regex:replaceAll(string($out75),'^library$','_library')"/>
	<xsl:variable name="out77" select="regex:replaceAll(string($out76),'^end$','_end')"/>
	<xsl:variable name="out78" select="regex:replaceAll(string($out77),'^object$','_object')"/>
	<xsl:value-of select="$out78"/>
</xsl:template>

<xsl:template match="text()" name="split">
	<xsl:param name="text" select="."/>
	<xsl:param name="splitChar" select="';'"/>
	<xsl:if test="string-length($text)">
		<text><xsl:value-of select="substring-before(concat($text,$splitChar),$splitChar)"/></text>
	 	<xsl:call-template name="split">
	  		<xsl:with-param name="text" select="substring-after($text, $splitChar)"/>
	  		<xsl:with-param name="splitChar"  select="$splitChar"/>
	 	</xsl:call-template>
	</xsl:if>
</xsl:template>

<!-- BEGIN  Templates for static content
	Not used anymore
-->

<xsl:template match="*[name()!='xmi:XMI']" mode="stereotypes-nonTemplate">
	<!-- stereotypes for static structs: Not used anymore -->
	<xsl:param name="nestingLevel" ></xsl:param>

	<xsl:if test="not(contains(name(),'uml2qvto'))">
		<xsl:variable name="id1" select="@xmi:id"/>
		<xsl:variable name="refId" select="./@*[contains(name(.),'base' )]"/>
		<xsl:variable name="refAttr" select="translate(translate(translate(translate(translate(translate(translate(./@*[contains(name(.),'base' )],'.','_'),':','_'),'-','_'),' ','_'),'$','_'),'{','_'),'}','_')"/>
		<xsl:variable name="template1" select="/.//*[(name(.)='uml2qvto:QvtoTemplate' )]//@*[ contains(name(.),'base_') and .=$refId]"/>
		<xsl:variable name="update1" select="/.//*[(name(.)='uml2qvto:QvtoUpdate' )]//@*[ contains(name(.),'base_') and .=$refId]"/>
		<xsl:variable name="delete1" select="/.//*[(name(.)='uml2qvto:QvtoDelete' )]//@*[ contains(name(.),'base_') and .=$refId]"/>
		<xsl:variable name="ignore" select="/.//*[(name(.)='uml2qvto:Ignore'  )]//@*[ contains(name(.),'base_') and .=$refId]"/>
		<xsl:variable name="ignoreAll">
			<xsl:for-each select="//*[@xmi:id=$refId]/ancestor-or-self::*">
				<xsl:variable name="sub_id" select="./@xmi:id"/>
				<xsl:value-of select="/.//*[name()='uml2qvto:uml2qvto:IgnoreAll']//@*[contains(name(.),'base_') and .=$sub_id]"/>
			</xsl:for-each>
		</xsl:variable>
		<xsl:choose>
	
		<xsl:when test="$ignore">
			<xsl:for-each select="./*">
			<xsl:variable name="xmi_id" select="@xmi:id"/>
			<xsl:variable name="template" select="/.//*[(name(.)='uml2qvto:QvtoTemplate' ) and  ./@base_Element=$xmi_id]"/>
			<xsl:variable name="update" select="/.//*[(name(.)='uml2qvto:QvtoUpdate' ) and  ./@base_Element=$xmi_id]"/>
			<xsl:variable name="delete" select="/.//*[(name(.)='uml2qvto:QvtoDelete' ) and  ./@base_Element=$xmi_id]"/>
	
			<xsl:if test="not($template) and not($update) and not($delete)">
			<xsl:apply-templates select="./*" mode="stereotypes-nonTemplate">
				<xsl:with-param name="nestingLevel" select="$nestingLevel"/>
			</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>
		</xsl:when>
		<xsl:when test="$ignoreAll!=''">
		</xsl:when>
		<xsl:when test="$template1 or $update1 or $delete1">
		</xsl:when>
		<xsl:otherwise>
		
<xsl:text>
</xsl:text>
		<xsl:variable name="xmi_id" select="$refId"/>
		<xsl:variable name="template" select="/.//*[(name(.)='uml2qvto:QvtoTemplate' ) and  ./@base_Element=$xmi_id]"/>
		<xsl:variable name="update" select="/.//*[(name(.)='uml2qvto:QvtoUpdate' ) and  ./@base_Element=$xmi_id]"/>
		<xsl:variable name="delete" select="/.//*[(name(.)='uml2qvto:QvtoDelete' ) and  ./@base_Element=$xmi_id]"/>
	
		<xsl:if test="not($template) and not($update) and not($delete)">
			
			<xsl:for-each select="ancestor::*"><xsl:text>	</xsl:text></xsl:for-each><xsl:value-of select="$refAttr"/>.setStereotypeByQualifiedName('<xsl:call-template name="processProfileName"><xsl:with-param name="val" select="substring-before(name(.),':')"/></xsl:call-template>::<xsl:value-of select="substring-after(name(.),':')" />');
			<xsl:apply-templates select="./@*[name()!='xmi:id' and not(contains(name(.),'base_'))]" mode="stereotypes">
				<xsl:with-param name="nodeElem" select="$refAttr"/>
				<xsl:with-param name="stereotypeName" select="name()"/>
				<xsl:with-param name="nestingLevel" select="$nestingLevel"/>
			</xsl:apply-templates>
		
			
				<xsl:apply-templates select="./*" mode="stereotypes-nonTemplate">
					<xsl:with-param name="nestingLevel" select="$nestingLevel"/>
				</xsl:apply-templates>
	
		</xsl:if>		
		
		</xsl:otherwise>
		
		</xsl:choose>
	</xsl:if>	
</xsl:template>




<!-- END  Templates for static content
	Not used anymore
-->

</xsl:stylesheet>