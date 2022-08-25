<p:declare-step version="1.0" 
	name="convert"
	type="vmcp:convert"
	xmlns:file="http://exproc.org/proposed/steps/file"
	xmlns:p="http://www.w3.org/ns/xproc" 
	xmlns:c="http://www.w3.org/ns/xproc-step" 
	xmlns:cx="http://xmlcalabash.com/ns/extensions"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:vmcp="tag:conaltuohy.com,2015:vmcp"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:l="http://xproc.org/library"
	xmlns:pxp="http://exproc.org/proposed/steps"
	xmlns:xs="http://www.w3.org/2001/XMLSchema">
	<p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
	
<!--
	<vmcp:convert-directory input-directory="../odt/1840-9/1840-4" output-directory="../tei/1840-9/1840-4"/>
	<vmcp:convert-directory input-directory="../odt/Mentions/1870-9" output-directory="../tei/Mentions/1870-9"/>
-->	
	<p:option name="input-directory" required="true"/>
	<p:option name="output-directory" required="true"/>
	<p:option name="temp-directory" select=" '/tmp/' "/>
	<vmcp:vicflora-names name="vicflora-names">
		<p:with-option name="temp-directory" select="$temp-directory"/>
	</vmcp:vicflora-names>
	<vmcp:convert-directory cx:depends-on="vicflora-names">
		<p:with-option name="input-directory" select="$input-directory"/>
		<p:with-option name="output-directory" select="$output-directory"/>
		<p:with-option name="temp-directory" select="$temp-directory"/>
	</vmcp:convert-directory>
		
	<p:declare-step name="sorted-directory-list" type="vmcp:directory-list">
		<p:option name="path"/>
		<p:output port="result"/>
		<p:directory-list name="directory-list">
			<p:with-option name="path" select="$path"/>
		</p:directory-list>
		<p:xslt name="sort-directory-list"><!-- just so we can process the documents in chronological order -->
			<p:input port="parameters"><p:empty/></p:input>
			<p:input port="stylesheet">
				<p:inline>
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
						<xsl:template match="/c:directory">
							<xsl:copy>
								<xsl:copy-of select="@*"/>
								<xsl:for-each select="*">
									<xsl:sort select="@name"/>
									<xsl:copy-of select="."/>
								</xsl:for-each>
							</xsl:copy>
						</xsl:template>
					</xsl:stylesheet>
				</p:inline>
			</p:input>
		</p:xslt>
	</p:declare-step>
	
	<p:declare-step name="add-keywords" type="vmcp:add-keywords" xmlns="http://www.tei-c.org/ns/1.0">
		<p:option name="scheme-id" required="true"/>
		<p:option name="scheme-name" required="true"/>
		<p:option name="term" required="true"/>
		<p:input port="source"/>
		<p:output port="result"/>
		<p:insert name="class-decl" match="/tei:TEI/tei:teiHeader/tei:encodingDesc[not(exists(tei:classDecl))]" position="last-child">
			<p:input port="insertion">
				<p:inline exclude-inline-prefixes="c cx fn vmcp tei l pxp xs file">
					<classDecl/>
				</p:inline>
			</p:input>
		</p:insert>
		<p:template name="taxonomy">
			<p:with-param name="scheme-id" select="$scheme-id"/>
			<p:with-param name="scheme-name" select="$scheme-name"/>
			<p:input port="template">
				<p:inline exclude-inline-prefixes="c cx fn vmcp tei l pxp xs file">
					<taxonomy xml:id="{$scheme-id}">
						<bibl>{$scheme-name}</bibl>
					</taxonomy>
				</p:inline>
			</p:input>
		</p:template>
		<p:insert match="/tei:TEI/tei:teiHeader/tei:encodingDesc/tei:classDecl" position="last-child">
			<p:input port="source">
				<p:pipe step="class-decl" port="result"/>
			</p:input>
			<p:input port="insertion">
				<p:pipe step="taxonomy" port="result"/>
			</p:input>
		</p:insert>
		<p:insert match="/tei:TEI/tei:teiHeader[not(tei:profileDesc)]" position="last-child">
			<p:input port="insertion">
				<p:inline exclude-inline-prefixes="c cx fn vmcp tei l pxp xs file"><profileDesc/></p:inline>
			</p:input>
		</p:insert>
		<p:insert name="textClass" match="/tei:TEI/tei:teiHeader/tei:profileDesc[not(tei:textClass)]" position="last-child">
			<p:input port="insertion">
				<p:inline exclude-inline-prefixes="c cx fn vmcp tei l pxp xs file"><textClass/></p:inline>
			</p:input>
		</p:insert>
		<p:template name="insertion">
			<p:with-param name="scheme-id" select="$scheme-id"/>
			<p:with-param name="term" select="$term"/>
			<p:input port="template">
				<p:inline exclude-inline-prefixes="c cx fn vmcp tei l pxp xs file">
					<keywords scheme="#{$scheme-id}">
						<term>{$term}</term>
					</keywords>
				</p:inline>
			</p:input>
		</p:template>
		<p:insert match="/tei:TEI/tei:teiHeader/tei:profileDesc/tei:textClass" position="last-child">
			<p:input port="source">
				<p:pipe step="textClass" port="result"/>
			</p:input>
			<p:input port="insertion">
				<p:pipe step="insertion" port="result"/>
			</p:input>
		</p:insert>
	</p:declare-step>
	
	<p:declare-step name="convert-directory" type="vmcp:convert-directory">
		<p:option name="input-directory" required="true"/>
		<p:option name="output-directory" required="true"/>
		<p:option name="temp-directory" required="true"/>
		<p:option name="path-name" select=" '' "/>
		<file:mkdir fail-on-error="false">
			<p:with-option name="href" select="$output-directory"/>
		</file:mkdir>
		<vmcp:directory-list name="input-directory-list">
			<p:with-option name="path" select="$input-directory"/>
		</vmcp:directory-list>
		<cx:message>
			<p:with-option name="message" select="
				concat(
					'Converting ', 
					$input-directory,
					' to ',
					$output-directory, 
					' ...'
				)
			"/>
		</cx:message>
		<p:for-each name="file-in-directory">
			<p:iteration-source select="/c:directory/c:file[ends-with(@name, '.odt')]"/>
			<p:variable name="file-name" select="/c:file/@name"/>
			<p:variable name="input-file-uri-component" select="concat('/', encode-for-uri($file-name))"/>
			<!-- for the output filename, convert the extension from '.odt' to '.xml' and replace any '#' characters with '_' -->
			<p:variable name="output-file-uri-component" select="
				concat(
					'/', 
					replace(
						encode-for-uri(
							translate($file-name, '#', '_')
						), 
						'odt$', 
						'xml'
					)
				)
			"/>
			<cx:message>
				<p:with-option name="message" select="
					concat(
						'Converting ', 
						$input-directory, $input-file-uri-component,
						' to ',
						$output-directory, $output-file-uri-component,
						' ...'
					)
				"/>
			</cx:message>
			<p:group>
				<p:documentation>extract text and formatting stylesheet from the OpenDocument file</p:documentation>
				<pxp:unzip file="content.xml" name="content">
					<p:with-option name="href" select="concat($input-directory, $input-file-uri-component)"/>
				</pxp:unzip>
				<pxp:unzip file="styles.xml" name="styles">
					<p:with-option name="href" select="concat($input-directory, $input-file-uri-component)"/>
				</pxp:unzip>
				<p:wrap-sequence wrapper="odt">
					<p:input port="source">
						<p:pipe step="styles" port="result"/>
						<p:pipe step="content" port="result"/>
					</p:input>
				</p:wrap-sequence>
			</p:group>
			<p:identity name="styles-and-content"/>
			<p:xslt name="p5">
				<p:documentation>convert the OpenDocument file into TEI</p:documentation>
				<p:with-param name="file-name" select="concat('data', $path-name, '/', replace($file-name, 'odt', 'doc'))"/>
				<p:input port="stylesheet">
					<p:document href="../xslt/odt-styles-and-content-to-tei.xsl"/>
				</p:input>
			</p:xslt>
			<p:xslt name="symbols-in-unicode">
				<p:documentation>Fix the obsolete "Symbol" encoding</p:documentation>
				<p:input port="parameters"><p:empty/></p:input>
				<p:input port="stylesheet">
					<p:document href="../xslt/fix-symbol-encoding.xsl"/>
				</p:input>
			</p:xslt>
			<p:xslt name="language-encoded-translations">
				<p:documentation>handle German/English translations</p:documentation>
				<p:input port="parameters"><p:empty/></p:input>
				<p:input port="stylesheet">
					<p:document href="../xslt/encode-translations.xsl"/>
				</p:input>
			</p:xslt>
			<p:xslt name="semantic-tei">
				<p:documentation>upconvert styles to semantic TEI elements</p:documentation>
				<p:input port="parameters"><p:empty/></p:input>
				<p:input port="stylesheet">
					<p:document href="../xslt/tei-styled-text-to-semantic-markup.xsl"/>
				</p:input>
			</p:xslt>
			<p:xslt name="metadata-extracted">
				<p:documentation>find metadata in text and insert in header</p:documentation>
				<p:input port="parameters"><p:empty/></p:input>
				<p:input port="stylesheet">
					<p:document href="../xslt/extract-metadata.xsl"/>
				</p:input>
			</p:xslt>
			<p:xslt name="resolve-plant-names-with-vicflora">
				<p:documentation>look plant names up in vicflora</p:documentation>
				<p:with-param name="plant-names" select="concat($temp-directory, 'vicflora-names.json')"/>
				<p:input port="stylesheet">
					<p:document href="../xslt/resolve-plant-names-with-vicflora.xsl"/>
				</p:input>
			</p:xslt>
			<p:xslt name="mark-up-names">
				<p:documentation>find and mark up taxonomic names where they appear in the transcript text</p:documentation>
				<p:input port="parameters"><p:empty/></p:input>
				<p:input port="stylesheet">
					<p:document href="../xslt/mark-up-names.xsl"/>
				</p:input>
			</p:xslt>
			<p:xslt name="language-usage-metrics">
				<p:documentation>Measure usage of English and German</p:documentation>
				<p:input port="parameters"><p:empty/></p:input>
				<p:input port="stylesheet">
					<p:document href="../xslt/tei-add-lang-usage.xsl"/>
				</p:input>
			</p:xslt>
			<!--
			<p:xslt name="titled">
				<p:documentation>The letters don't have titles, so here we generate an incipit</p:documentation>
				<p:input port="parameters"><p:empty/></p:input>
				<p:input port="stylesheet">
					<p:document href="../xslt/tei-add-titles.xsl"/>
				</p:input>
			</p:xslt>-->
			<p:xslt name="xtf-compatible">
				<p:documentation>make changes for XTF compatibility; headings, identifiers, top-level div</p:documentation>
				<p:input port="parameters"><p:empty/></p:input>
				<p:input port="stylesheet">
					<p:document href="../xslt/make-xtf-compatible.xsl"/>
				</p:input>
			</p:xslt>
			<p:xslt name="footnotes-renumbered">
				<p:documentation>renumber footnotes, which may not have been correctly sequentially numbered because they may be a mixture of OpenOffice footnotes and also manually formatted endnotes</p:documentation>
				<p:input port="parameters"><p:empty/></p:input>
				<p:input port="stylesheet">
					<p:document href="../xslt/renumber-footnotes-sequentially.xsl"/>
				</p:input>
			</p:xslt>
			<p:xslt name="clean-header">
				<p:documentation>clean up header to remove empty container elements</p:documentation>
				<p:input port="parameters"><p:empty/></p:input>
				<p:input port="stylesheet">
					<p:document href="../xslt/prune-empty-header-elements.xsl"/>
				</p:input>
			</p:xslt>
			<p:xslt name="minimal-css">
				<p:documentation>clean up unneeded css inherited from formatting in the Word document</p:documentation>
				<p:input port="parameters"><p:empty/></p:input>
				<p:input port="stylesheet">
					<p:document href="../xslt/strip-rendundant-css.xsl"/>
				</p:input>
			</p:xslt>
			<p:try>
				<p:documentation>check schema validity and flag invalid documents</p:documentation>
				<p:group name="validate-and-save">
					<p:validate-with-relax-ng>
						<p:input port="schema">
							<p:document href="../schema/tei_all.rng"/>
						</p:input>
					</p:validate-with-relax-ng>
					<vmcp:add-keywords scheme-id="validity" scheme-name="validity" term="valid"/>
				</p:group>
				<p:catch name="invalid">
					<vmcp:add-keywords scheme-id="validity" scheme-name="validity"  term="invalid"/>
				</p:catch>
			</p:try>
			<!-- save TEI file -->
			<p:store indent="true">
				<p:with-option name="href" select="concat($output-directory, $output-file-uri-component)"/>
			</p:store>
			<!-- save ODT content+style file for reference -->
<!--
			<p:store indent="true">
				<p:with-option name="href" select="concat($input-directory, $output-file-uri-component)"/>
				<p:input port="source">
					<p:pipe step="styles-and-content" port="result"/>
				</p:input>
			</p:store>
-->
		</p:for-each>
		<p:for-each name="subdirectory">
			<p:iteration-source select="/c:directory/c:directory">
				<p:pipe step="input-directory-list" port="result"/>
			</p:iteration-source>
			<p:variable name="directory-name" select="/c:directory/@name"/>
			<p:variable name="directory-uri-component" select="concat('/', encode-for-uri($directory-name))"/>
			<vmcp:convert-directory>
				<p:with-option name="input-directory" select="concat($input-directory, $directory-uri-component)"/>
				<p:with-option name="output-directory" select="concat($output-directory, $directory-uri-component)"/>
				<p:with-option name="temp-directory" select="$temp-directory"/>
				<p:with-option name="path-name" select="concat($path-name, '/', $directory-name)"/>
			</vmcp:convert-directory>
		</p:for-each>
	</p:declare-step>
	
	<p:declare-step name="vicflora-names" type="vmcp:vicflora-names">
		<p:option name="temp-directory"/>
		<p:http-request name="graphql-query">
			<p:input port="source">
				<p:inline>
					<c:request method="POST" href="https://vicflora.rbg.vic.gov.au/graphql" override-content-type="text/plain">
						<c:header name="Accept" value="application/json"/>
						<c:body content-type="application/json">
{"query":"query SearchQuery($input: SearchInput!) {\r\n  search(input: $input) {\r\n    meta {\r\n      params {\r\n        q\r\n        fq\r\n        fl\r\n        rows\r\n      }\r\n      pagination {\r\n        lastPage\r\n        total\r\n        currentPage\r\n      }\r\n    }\r\n    docs {\r\n      id\r\n      scientificName\r\n      scientificNameAuthorship\r\n      taxonomicStatus\r\n      acceptedNameUsageId\r\n    }\r\n  }\r\n}\r\n","variables":{"input":{"q":"*:*","fq":"taxonomic_status:(accepted OR homotypicSynonym OR heterotypicSynonym OR synonym)","rows":12000}}}
						</c:body>
					</c:request>
				</p:inline>
			</p:input>
		</p:http-request>
		<p:xslt>
			<p:input port="parameters"><p:empty/></p:input>
			<p:input port="stylesheet">
				<p:inline>
					<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" expand-text="yes"
						xmlns:c="http://www.w3.org/ns/xproc-step"
						xmlns:fn="http://www.w3.org/2005/xpath-functions">
						<xsl:template match="/c:body">
							<xsl:copy>
								<xsl:variable name="scientific-name-to-taxon-id-map">
									<fn:map>
										<xsl:for-each-group group-by="fn:string[@key='scientificName']" select="
											json-to-xml(.)
												/fn:map
													/fn:map[@key='data']
														/fn:map[@key='search']
															/fn:array[@key='docs']
																/fn:map[fn:string[@key='scientificName']]
										">
											<fn:string key="{fn:string[@key='scientificName']}">{fn:string[@key='id']}</fn:string>
										</xsl:for-each-group>
									</fn:map>
								</xsl:variable>
								<xsl:sequence select="xml-to-json($scientific-name-to-taxon-id-map)"/>
							</xsl:copy>
						</xsl:template>
					</xsl:stylesheet>
				</p:inline>
			</p:input>
		</p:xslt>
		<p:store method="text" indent="true">
			<p:with-option name="href" select="concat($temp-directory, 'vicflora-names.json')"/>
		</p:store>
	</p:declare-step>
	
</p:declare-step>
