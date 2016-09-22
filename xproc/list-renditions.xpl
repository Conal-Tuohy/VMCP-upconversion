<p:declare-step version="1.0" 
	name="list-renditions"
	type="vmcp:list-renditions"
	xmlns:file="http://exproc.org/proposed/steps/file"
	xmlns:p="http://www.w3.org/ns/xproc" 
	xmlns:c="http://www.w3.org/ns/xproc-step" 
	xmlns:cx="http://xmlcalabash.com/ns/extensions"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:vmcp="tag:conaltuohy.com,2015:vmcp"
	xmlns:l="http://xproc.org/library"
	xmlns:pxp="http://exproc.org/proposed/steps"
	xmlns:xs="http://www.w3.org/2001/XMLSchema">
	<p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
	<p:import href="recursive-directory-list.xpl"/>
	
	<l:recursive-directory-list path="../tei"/>
	<p:xslt name="files-with-path-names">
		<p:input port="parameters"><p:empty/></p:input>
		<p:input port="stylesheet">
			<p:document href="../xslt/add-path-name-attributes-to-files.xsl"/>
		</p:input>
	</p:xslt>
	<p:for-each name="file-in-directory">
		<p:iteration-source select="/c:directory//c:file"/>
		<p:load>
			<p:with-option name="href" select="/c:file/@path-name"/>
		</p:load>
		<p:xslt name="distinct-renditions-in-text">
			<p:input port="parameters"><p:empty/></p:input>
			<p:input port="stylesheet">
				<p:document href="../xslt/aggregate-renditions.xsl"/>
			</p:input>
		</p:xslt>
	</p:for-each>
	<p:wrap-sequence wrapper="corpus"/>
	<p:xslt name="distinct-renditions-in-corpus">
		<p:input port="parameters"><p:empty/></p:input>
		<p:input port="stylesheet">
			<p:document href="aggregate-renditions.xsl"/>
		</p:input>
	</p:xslt>
	<p:xslt name="renditions-in-html">
		<p:input port="parameters"><p:empty/></p:input>
		<p:input port="stylesheet">
			<p:document href="../xslt/rendition-list-to-html.xsl"/>
		</p:input>
	</p:xslt>
	<p:store href="../renditions.html"/>
</p:declare-step>
