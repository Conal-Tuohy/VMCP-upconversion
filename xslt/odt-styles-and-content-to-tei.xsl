<xsl:stylesheet version="3.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0" 
	xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
	xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
	xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0" 
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0" 
	xmlns="http://www.tei-c.org/ns/1.0"
	xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0" 
	exclude-result-prefixes="style text office fo dc draw table">
	<xsl:param name="file-name"/>
	<xsl:template match="/odt">
		<TEI>
			<teiHeader>
				<fileDesc>
					<!-- The title statement of the electronic text -->
					<titleStmt>
						<!-- Provide a title for the document e.g. Letter from X to Y, on such-and-such date -->
						<title></title>
						<author></author>
						<!-- ... and credits for the digital file -->
						<respStmt>
							<resp>Transcribed into Microsoft Word</resp>
							<orgName>Correspondence of Ferdinand von Mueller Project</orgName>
						</respStmt>
						<respStmt>
							<resp>Converted from Microsoft Word to TEI P5</resp>
							<persName>Conal Tuohy</persName>
						</respStmt>
						<xsl:for-each-group select="//text:annotation" group-by="text:sender-initials">
							<respStmt xml:id="editor-{text:sender-initials}">
								<resp>Editor</resp>
								<persName><xsl:value-of select="dc:creator"/></persName>
							</respStmt>
						</xsl:for-each-group>
					</titleStmt>
					<!-- The publication statement of the electronic text -->
					<publicationStmt>
						<authority>Royal Botanic Gardens Victoria</authority>
						<idno type="filename"><xsl:value-of select="$file-name"/></idno>
					</publicationStmt>
					<sourceDesc>
						<p><!-- TODO provide a description of the source --></p>
					</sourceDesc>
				</fileDesc>
				<encodingDesc>
					<!-- TODO flesh out encoding description -->
					<!--
					<projectDesc>
						<p>See http://www.rbg.vic.gov.au/science/herbarium-and-resources/library/mueller-correspondence-project</p>
					</projectDesc>
					-->
					<p>The file <idno><xsl:value-of select="$file-name"/></idno> was converted from Microsoft Word format into TEI using an XProc pipeline.</p>
				</encodingDesc>
				<profileDesc>
					<textClass/><!-- to be filled in by later steps -->
					<langUsage/><!-- to be filled in by later steps -->
				</profileDesc>
			</teiHeader>
			<text>
				<body>
					<xsl:apply-templates select="office:document-content/office:body/office:text/*"/>
				</body>
			</text>
		</TEI>
	</xsl:template>
	
	<!-- ignore change tracking -->
	<xsl:template match="text:changed-region"/>
	
	<xsl:template match="text:a">
		<xsl:element name="ref">
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="@xlink:href" xmlns:xlink="http://www.w3.org/1999/xlink">
		<!-- NB the LibreOffice converter erroneously adds an extra '../' prefix to every relative URL, which needs to be trimmed off and discarded. -->
		<!-- Then the residual URL can be normalized by trimming off pairs of ../prefix until there are no more '../' segments -->
		<xsl:choose>
			<xsl:when test="matches(., '^(/|[^:]+:)')">
				<!-- a root-relative URL (starting with "/"), or an absolute URL (starting with a scheme) can be copied without change -->
				<xsl:attribute name="target"  select="."/>
			</xsl:when>
			<xsl:otherwise>
				<!-- strip off all the "parent" ('../') segments in the URL, and a corresponding number of segments representing 
				the names of child folders, to minimize the URL length -->
				<xsl:variable name="components" select="tokenize(., '/')"/>
				<xsl:variable name="parent-steps-count" select="count($components[.='..'])"/>
				<xsl:variable name="child-steps" select="$components[.!='..']"/>
				<xsl:variable name="relative-path" select="$child-steps => subsequence($parent-steps-count) => string-join('/')"/>
				<!-- since we're transforming .doc files to .xml files, replace the doc extension in the hyperlink to refer to an xml file -->
				<xsl:variable name="reference" select="replace($relative-path, '(\.doc)$', '.xml')"/>
				<xsl:attribute name="target"  select="$reference"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="text:p">
		<xsl:element name="p">
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	<!-- NB headings are not generally used in the corpus but there are a few -->
	<!-- Since in Word a heading can be indistinguishable from a regular paragraph, they may not have been used correctly to identify headings,
	and for this reason they are not mapped to TEI head elements, but to anonymous blocks -->
	<xsl:template match="text:h">
		<xsl:element name="ab">
			<xsl:apply-templates select="@*"/>
			<xsl:attribute name="type">heading</xsl:attribute>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="text:span">
		<xsl:element name="seg">
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="text:span[@text:style-name='Footnote_20_Symbol']">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="office:annotation">
		<xsl:element name="note">
			<xsl:attribute name="type">annotation</xsl:attribute>
			<xsl:attribute name="resp">
				<xsl:value-of select="concat('#editor-', text:sender-initials)"/>
			</xsl:attribute>
			<xsl:apply-templates select="text:p"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="text:note">
		<xsl:element name="note">
			<xsl:apply-templates select="@*"/>
			<!-- the note's marker attribute is either taken from the text:note-citation descendant element, if present; otherwise it's the numeric portion of the text:note's @text:id attribute -->
			<xsl:attribute name="n" select="(.//text:note-citation[not(.='0')], substring-after(@text:id, 'ftn'))[1]"/>
			<xsl:apply-templates select="text:note-body"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="@*"/>
	<xsl:template match="@text:id">
		<xsl:attribute name="xml:id"><xsl:value-of select="."/></xsl:attribute>
	</xsl:template>
	<xsl:template match="@text:note-class">
		<xsl:attribute name="type"><xsl:value-of select="."/></xsl:attribute>
	</xsl:template>
	<xsl:template match="@*" mode="style-name">
		<xsl:analyze-string select="." regex="_(..)_">
			<xsl:matching-substring>
				<xsl:value-of select="concat('%', regex-group(1))"/>
			</xsl:matching-substring>
			<xsl:non-matching-substring>
				<xsl:value-of select="."/>
			</xsl:non-matching-substring>
		</xsl:analyze-string>
	</xsl:template>
	<xsl:template match="@text:style-name | @table:style-name">
		<!-- TODO capture all style information as CSS -->
		<!-- automatic styles CSS should be encoded @as tei:style, common styles as tei:rendition -->
		
		<!-- the style name may be the name of a real style, or it may be the name of an "automatic style" - 
		a name such as P2 or T1. If the style name belongs to an automatic style, replace it with the automatic
		style's parent style's name, if it has one -->
		<xsl:variable name="automatic-style" select="key('automatic-styles-by-name', .)"/>
		<xsl:choose>
			<xsl:when test="exists($automatic-style)">
				<!-- "automatic" style is just an anonymous style based on a real ("common") style which is its "parent" -->
				<xsl:for-each select="$automatic-style/@style:parent-style-name">
					<xsl:attribute name="rend"><xsl:apply-templates mode="style-name" select="."/></xsl:attribute>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<!-- no automatic style of that name - it's a "common" (i.e. named) style -->
				<xsl:attribute name="rend"><xsl:apply-templates mode="style-name" select="."/></xsl:attribute>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:variable name="style" select="
			key('styles-by-name', .) |
			key('automatic-styles-by-name', .)
		"/>
		<xsl:call-template name="extract-style-formatting">
			<xsl:with-param name="style" select="$style"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template name="extract-style-formatting">
		<!-- generate a flattened set of formatting attributes -->
		<xsl:param name="style"/>
		<xsl:param name="existing-attributes" select="/.."/>
		<xsl:variable name="existing-attribute-names" select="for $attribute in $existing-attributes return local-name($attribute)"/>
		<xsl:variable name="formatting-attributes" select="$style/*/@fo:* | $style/*/@style:font-name"/>
		<xsl:variable name="combined-attributes" select="
			$existing-attributes | 
			$formatting-attributes[not(local-name(.) = $existing-attribute-names)]
		"/>
		<xsl:choose>
			<xsl:when test="$style/@style:parent-style-name">
				<xsl:call-template name="extract-style-formatting">
					<xsl:with-param name="style" select="key('styles-by-name', $style/@style:parent-style-name)"/>
					<xsl:with-param name="existing-attributes" select="$combined-attributes"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<!-- no more ancestral styles - we have accumulated the full set; now render them as a style attribute -->
				<xsl:attribute name="style">
					<xsl:apply-templates select="$combined-attributes"/>
				</xsl:attribute>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Wrap underlined elements in hi tags (DR)-->
	<xsl:variable name="underline-style-name" select="/odt/*:document-content/*:automatic-styles/*:style[*:text-properties/@*:text-underline-style]/@*:name" />
	<xsl:template match="//text:span[@text:style-name=$underline-style-name]/text()" priority="5">
		<xsl:if test="not(normalize-space(.)='')">
			<hi rend="underline"><xsl:value-of select="." /></hi>
		</xsl:if>
		<xsl:if test="normalize-space(.)=''">
			<xsl:value-of select="." />
		</xsl:if>
	</xsl:template>

	<!-- render a formatting objects atribute as a CSS property -->
	<xsl:template match="@fo:*  | @style:font-name">
		<xsl:value-of select="concat(local-name(.), ': ', ., '; ')"/>
	</xsl:template>
	
	<!-- formatting objects attributes without a corresponding CSS property -->
	<xsl:template match="@fo:language | @fo:country"/>
	<!-- unwanted CSS properties -->
	<xsl:template match="@fo:widows | @fo:orphans"/>
	
	<xsl:key name="styles-by-name"
		match="/odt/office:document-styles/office:styles/style:style"
		use="@style:name"/>
		
	<xsl:key name="automatic-styles-by-name"
		match="/odt/office:document-content/office:automatic-styles/style:style"
		use="@style:name"/>	
		
	<!-- capture word-processor tab characters as TEI space elements - may require extra processing later -->
	<xsl:template match="text:tab"><space dim="horizontal" extent="tab"/></xsl:template>
	
	<!-- capture drawn lines as figures -->
	<xsl:template match="draw:line">
		<figure rend="horizontal-line"/>
	</xsl:template>
	
	<!-- custom shapes with a preset type are captured as figures rendered as that type --> 
	<xsl:template match="draw:custom-shape[draw:enhanced-geometry/@draw:type]">
		<figure rend="{draw:enhanced-geometry/@draw:type}">
			<xsl:apply-templates select="text:p[normalize-space()]"/>
		</figure>
	</xsl:template>
	
	<!-- a drawing frame provides a new graphical coordinate space for its contents -->
	<!-- treated as a TEI note with a @type of "frame" -->
	<xsl:template match="draw:frame">
		<note type="frame">
			<xsl:apply-templates/>
		</note>
	</xsl:template>
	
	<!-- a sequence of spaces -->
	<xsl:template match="text:s">
		<xsl:element name="space">
			<xsl:attribute name="unit">chars</xsl:attribute>
			<xsl:attribute name="quantity"><xsl:value-of select="(@text:c, 1)[1]"/></xsl:attribute>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="table:table">
		<xsl:element name="table">
			<xsl:attribute name="n" select="@table:name"/>
			<!-- TODO table style-name -->
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="table:table-row">
		<xsl:element name="row">
			<!-- TODO table style-name -->
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="table:table-cell">
		<xsl:element name="cell">
			<!-- TODO table style-name -->
			<xsl:apply-templates select="@table:style-name"/>
			<xsl:apply-templates select="@table:number-columns-spanned | @table:number-rows-spanned"/>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="@table:number-columns-spanned">
		<xsl:attribute name="cols" select="."/>
	</xsl:template>
	
	<xsl:template match="@table:number-rows-spanned">
		<xsl:attribute name="rows" select="."/>
	</xsl:template>		
</xsl:stylesheet>
