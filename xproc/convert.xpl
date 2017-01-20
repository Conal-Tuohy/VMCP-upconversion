<p:declare-step version="1.0" 
	name="convert"
	type="vmcp:convert"
	xmlns:file="http://exproc.org/proposed/steps/file"
	xmlns:p="http://www.w3.org/ns/xproc" 
	xmlns:c="http://www.w3.org/ns/xproc-step" 
	xmlns:cx="http://xmlcalabash.com/ns/extensions"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:vmcp="tag:conaltuohy.com,2015:vmcp"
      xmlns:l="http://xproc.org/library"
	xmlns:xs="http://www.w3.org/2001/XMLSchema">
	<p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
	<p:import href="recursive-directory-list.xpl"/>
	<p:option name="input-root-folder" required="true"/><!-- select=" 'doc' "/>-->
	<p:option name="output-root-folder" required="true"/>
	<p:option name="output-shell-script" required="true"/>
<!--
convert-to docx - -outdir "docx/no date letters" "doc/no date letters/Macdonald00-00-00Teucrium.doc"
-->
	<l:recursive-directory-list name="output-document-tree">
		<p:with-option name="path" select="$output-root-folder"/>
	</l:recursive-directory-list>
	<l:recursive-directory-list name="input-document-tree">
		<p:with-option name="path" select="$input-root-folder"/>
	</l:recursive-directory-list>
	<p:delete name="pruned-input-document-tree" 
		match="c:file[not(ends-with(@name, '.doc') or ends-with(@name, '.DOC')) or starts-with(@name, '.')]"/>
	<p:wrap-sequence wrapper="output-and-input-trees">
		<p:input port="source">
			<p:pipe step="output-document-tree" port="result"/>
			<p:pipe step="pruned-input-document-tree" port="result"/>
		</p:input>
	</p:wrap-sequence>
	<p:xslt name="conversions">
		<p:with-param name="output-root-folder" select="$output-root-folder"/>
		<p:with-param name="input-root-folder" select="$input-root-folder"/>
		<p:input port="stylesheet">
			<p:inline>
				<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:c="http://www.w3.org/ns/xproc-step" >
					<xsl:param name="output-root-folder"/>
					<xsl:param name="input-root-folder"/>
					<xsl:variable name="apos">'</xsl:variable>
					<xsl:variable name="escaped-apos">\\'</xsl:variable>
					<xsl:variable name="quot">"</xsl:variable>
					<xsl:template match="output-and-input-trees">
						<bash>
							<xsl:text>#!/bin/bash&#xA;</xsl:text>
							<xsl:text>mkdir -p "</xsl:text>
							<xsl:value-of select="$output-root-folder"/>
							<xsl:text>" 2>&amp;1&#xA;</xsl:text>
							<xsl:text>echo Purging derivatives of deleted source files ...&#xA;</xsl:text>
							<!-- first process the output tree, deleting any files if there's no corresponding file in the input tree -->
							<xsl:apply-templates select="c:directory[1]" mode="delete-from-output-tree">
								<xsl:sort select="@name"/>
							</xsl:apply-templates>
							<xsl:text>echo Converting updated Word document files to OpenDocument format ...&#xA;</xsl:text>
							<!-- second process the input tree files, convert into output tree, unless output file exists and is not stale -->
							<xsl:apply-templates select="c:directory[2]" mode="convert-from-input-tree">	
								<xsl:sort select="@name"/>
							</xsl:apply-templates>
						</bash>
					</xsl:template>
					<xsl:template match="c:directory" mode="delete-from-output-tree">
						<xsl:apply-templates mode="delete-from-output-tree">
							<xsl:sort select="@name"/>
						</xsl:apply-templates>
					</xsl:template>
					<xsl:template match="c:file" mode="delete-from-output-tree">
						<!-- delete file from output directory if the corresponding file in the input directory has been deleted -->
						<xsl:variable name="output-file" select="
							string-join(ancestor-or-self::*[parent::c:directory]/@name, '/')
						"/>
						<xsl:variable name="input-file" select="replace($output-file, '\....$', '.doc')"/>
						<!--
						<xsl:variable name="input-folder" select="
								string-join(
									(
										$input-root-folder, 
										ancestor-or-self::c:directory[parent::c:directory]/@name
									),
									'/'
								)
						"/>
						<xsl:variable name="output-folder" select="
								string-join(
									(
										$output-root-folder, 
										ancestor-or-self::c:directory[parent::c:directory]/@name
									),
									'/'
								)
						"/>
						-->
						<xsl:text>if [ ! -f "</xsl:text>
						<xsl:value-of select="$input-root-folder"/>
						<xsl:text>/</xsl:text>
						<xsl:value-of select="$input-file"/>
						<xsl:text>" ]; then&#xA;</xsl:text>
						<xsl:text>   echo purging file "</xsl:text>
						<xsl:value-of select="$output-file"/>
						<xsl:text>" derived from deleted source file "</xsl:text>
						<xsl:value-of select="$input-file"/>
						<xsl:text>" ...&#xA;</xsl:text>
						<xsl:text>   rm "</xsl:text>
						<xsl:value-of select="$output-root-folder"/>
						<xsl:text>/</xsl:text>
						<xsl:value-of select="$output-file"/>
						<xsl:text>" 2>&amp;1&#xA;fi&#xA;</xsl:text>
					</xsl:template>
					<xsl:template match="c:file" mode="convert-from-input-tree">
						<xsl:variable name="input-file" select="
							string-join(ancestor-or-self::*[parent::c:directory]/@name, '/')
						"/>
						<xsl:variable name="output-file" select="replace($input-file, '\....$', '.odt')"/>
						<xsl:variable name="output-folder" select="
								string-join(
									(
										$output-root-folder, 
										ancestor::*[parent::c:directory]/@name
									),
									'/'
								)
						"/>
						<!-- http://tldp.org/LDP/Bash-Beginners-Guide/html/sect_07_01.html -->
						<xsl:text>if [ "</xsl:text>
						<xsl:value-of select="concat($input-root-folder, '/', $input-file)"/>
						<xsl:text>" -nt "</xsl:text>
						<xsl:value-of select="concat($output-root-folder, '/', $output-file)"/>
						<xsl:text>" ]; then&#xA;</xsl:text>
						<xsl:text>	libreoffice --headless --convert-to odt --outdir "</xsl:text>
						<xsl:value-of select="$output-folder"/>
						<xsl:text>" "</xsl:text>
						<xsl:value-of select="concat($input-root-folder, '/', $input-file)"/>
						<xsl:text>" 2>&amp;1&#xA;</xsl:text>
						<xsl:text>touch -r "</xsl:text>
						<xsl:value-of select="concat($input-root-folder, '/', $input-file)"/>
						<xsl:text>" "</xsl:text>
						<xsl:value-of select="concat($output-root-folder, '/', $output-file)"/>
						<xsl:text>" 2>&amp;1&#xA;</xsl:text>
						<xsl:text>fi&#xA;</xsl:text>
					</xsl:template>
					<xsl:template match="c:directory" mode="convert-from-input-tree">
						<xsl:if test="not(starts-with(@name, '.'))">
							<xsl:variable name="input-folder" select="
									string-join(
										(
											$input-root-folder, 
											ancestor-or-self::c:directory[parent::c:directory]/@name
										),
										'/'
									)
							"/>
							<xsl:variable name="output-folder" select="
									string-join(
										(
											$output-root-folder, 
											ancestor-or-self::c:directory[parent::c:directory]/@name
										),
										'/'
									)
							"/>
							<xsl:text>mkdir -p "</xsl:text>
							<xsl:value-of select="$output-folder"/>
							<xsl:text>" 2>&amp;1&#xA;</xsl:text>
							<!-- convert documents in directory -->
							<xsl:apply-templates mode="convert-from-input-tree">
								<xsl:sort select="@name"/>
							</xsl:apply-templates>
						</xsl:if>
					</xsl:template>
				</xsl:stylesheet>
			</p:inline>
		</p:input>
	</p:xslt>
<!--
	<p:sink/>
	<p:identity>
		<p:input port="source">
			<p:pipe step="document-tree" port="result"/>
		</p:input>
	</p:identity>	-->
	<p:store media-type="text/plain" method="text">
		<p:with-option name="href" select="$output-shell-script"/>
	</p:store>
</p:declare-step>
