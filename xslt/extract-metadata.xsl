<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="tei">
<!--
Pulls metadata elements from the text into the teiHeader

tei:p[@rend='correspondent] -> tei:profileDesc/tei:correspDesc/tei:p
tei:p[@rend='number'] -> tei:msDesc/tei:altIdentiier/tei:idno
tei:p[@rend='location'] -> tei:msDesc/tei:msIdentiier/tei:idno

-->
	
	<xsl:template match="tei:teiHeader">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates select="*"/>
			<!--
			<xsl:if test="//tei:p[@rend='correspondent']">
				<profileDesc>
					<correspDesc>
						<xsl:copy-of select="//tei:p[@rend='correspondent']"/>
					</correspDesc>
				</profileDesc>
			</xsl:if>
			-->
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="tei:teiHeader//tei:author[not(normalize-space())]">
		<xsl:copy-of select="$authors"/>
	</xsl:template>

	<xsl:variable name="title" select="
		concat(
			substring(
				string-join(
					(/tei:TEI/tei:text/tei:body/tei:p[not(@xml:lang='de')][normalize-space()])[position()&lt;6]/node()[not(self::tei:note)], 
					' ¶ '
				),
				1, 
				200
			),
			'...'
		)
	"/>

	<xsl:variable name="authors">
		<xsl:variable name="correspondent" select="//tei:p[@rend='correspondent'][normalize-space()]"/>
		<xsl:variable name="text" select="string-join($correspondent/text(), ' ')"/><!-- ignoring any notes -->
		<xsl:variable name="correspondent" select="//tei:p[@rend='correspondent'][normalize-space()]"/>
		<xsl:variable name="text" select="string-join($correspondent/text(), ' ')"/><!-- ignoring any notes -->
		<xsl:element name="author">
			<xsl:choose>
				<xsl:when test="starts-with($text, 'From ')">
					<xsl:value-of select="substring-after($text, 'From ')"/>
				</xsl:when>
				<!-- "correspondent" is a recipient - assume FvM is the sender -->
				<xsl:when test="starts-with($text, 'To ')">
					<xsl:text>Ferdinand von Mueller</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>Ferdinand von Mueller?</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:variable>

	<xsl:template match="tei:teiHeader//tei:title[not(normalize-space())]">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:value-of select="$title"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="tei:profileDesc">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
			<correspDesc>
				<correspAction type="sentTo">
					<xsl:variable name="correspondent" select="//tei:p[@rend='correspondent'][normalize-space()]"/>
					<xsl:variable name="text" select="string-join($correspondent/text(), ' ')"/><!-- ignoring any notes -->
					<xsl:choose>
						<xsl:when test="starts-with($text, 'To ')">
							<name><xsl:value-of select="substring-after($text, 'To ')"/></name>
						</xsl:when>
						<xsl:when test="starts-with($text, 'From ')"><!-- "correspondent" is a sender - assume FvM is the recipient -->
							<name>Ferdinand von Mueller</name>
						</xsl:when>
						<xsl:otherwise>
							<name><xsl:value-of select="concat($text, '?')"/></name>
						</xsl:otherwise>
					</xsl:choose>
				</correspAction>
			</correspDesc>
		</xsl:copy>
	</xsl:template>
	
	<xsl:variable name="plant-names" 
		select="//tei:p[@rend=('Plant%20names', 'plant%20names')][normalize-space()]"/>

	<xsl:template match="tei:encodingDesc">
		<xsl:copy>
			<xsl:copy-of select="@* | node()"/>
			<xsl:element name="classDecl">
				<xsl:if test="$plant-names">
					<xsl:element name="taxonomy">
						<xsl:attribute name="xml:id">plant-names</xsl:attribute>
						<xsl:element name="bibl">plant names</xsl:element>
					</xsl:element>
				</xsl:if>
				<xsl:element name="taxonomy">
					<xsl:attribute name="xml:id">features</xsl:attribute>
					<xsl:element name="bibl">features</xsl:element>
				</xsl:element>
				<xsl:element name="taxonomy">
					<xsl:attribute name="xml:id">styles</xsl:attribute>
					<xsl:element name="bibl">styles</xsl:element>
				</xsl:element>
			</xsl:element>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="tei:textClass">
		<xsl:copy>
			<xsl:copy-of select="@* | node()"/>
			<xsl:if test="$plant-names">
				<keywords scheme="#plant-names">
					<xsl:for-each select="$plant-names">
						<term><xsl:value-of select="."/></term>
					</xsl:for-each>
				</keywords>
			</xsl:if>
			<!-- tag the documents which contain tables or figures -->
			<xsl:variable name="keywords">
				<xsl:if test="exists(//tei:table)"><term>table</term></xsl:if>
				<xsl:if test="exists(//tei:note)"><term>note</term></xsl:if>
				<xsl:if test="exists(//tei:figure)"><term>figure</term></xsl:if>
				<xsl:if test="exists(//tei:ref)"><term>hyperlink</term></xsl:if>
				<!-- "tab alignment" is when a text includes two paragraphs in a row
				which contain a tab which is not the start of the para -->
				<xsl:if test="
					//tei:p[
						tei:space 	[@dim='horizontal'] [@extent='tab']
							/preceding-sibling::text( )[normalize-space()]
					]
					[
						preceding-sibling::*[1]/self::tei:p/
							tei:space 	[@dim='horizontal'] [@extent='tab']
								/preceding-sibling::text( )[normalize-space()]
					]
				"><term>tab alignment</term></xsl:if> 
				<!-- "uneven tabulation" is when a text uses tab alignment, but
				the number of tab characters used varies from one para to the next -->
				<xsl:if test="
					//tei:p[
						tei:space 	[@dim='horizontal'] [@extent='tab']
							/preceding-sibling::text( )[normalize-space()]
					]
					[
						preceding-sibling::*[1]/self::tei:p/
							tei:space 	[@dim='horizontal'] [@extent='tab']
								/preceding-sibling::text( )[normalize-space()]
					]
					[
						count(
							tei:space 	[@dim='horizontal'] [@extent='tab']
								/preceding-sibling::text( )[normalize-space()]
						) != count(
							preceding-sibling::*[1]/self::tei:p/
								tei:space 	[@dim='horizontal'] [@extent='tab']
									/preceding-sibling::text( )[normalize-space()]
						)
					]
				"><term>uneven tabulation</term></xsl:if> 				
			</xsl:variable>
			<xsl:if test="$keywords">
				<keywords scheme="#features">
					<xsl:copy-of select="$keywords"/>
				</keywords>
			</xsl:if>
			<!-- tag the document with the names of the styles used -->
			<keywords scheme="#styles">
				<xsl:for-each-group select="//tei:*/@rend" group-by=".">
					<term><xsl:analyze-string select="." regex="%(.)(.)">
						<xsl:matching-substring>
							<xsl:variable name="hex" select=" '0123456789abcdef' "/>
							<xsl:variable name="decimal" select="
								string-length(substring-before($hex, regex-group(1))) * 16 +
								string-length(substring-before($hex, regex-group(2)))
							"/>
							<xsl:value-of select="codepoints-to-string($decimal)"/>
						</xsl:matching-substring>
						<xsl:non-matching-substring>
							<xsl:value-of select="."/>
						</xsl:non-matching-substring>
					</xsl:analyze-string></term>
				</xsl:for-each-group>
			</keywords>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="tei:sourceDesc">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<msDesc>
				<msIdentifier>
					<xsl:for-each select="//tei:p[@rend='location'][normalize-space()]">
						<msName><xsl:value-of select="."/></msName>
					</xsl:for-each>
					<xsl:for-each select="//tei:p[@rend='number'][normalize-space()]">
						<altIdentifier>
							<idno><xsl:value-of select="."/></idno>
						</altIdentifier>
					</xsl:for-each>
				</msIdentifier>
			</msDesc>
			<bibl>
				<xsl:copy-of select="$authors"/>
				<title><xsl:value-of select="$title"/></title>
				<xsl:variable name="date-regex">([1-9]\d)-(\d\d)-(\d\d)</xsl:variable><!-- yy-mm-dd -->
				<xsl:analyze-string select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type='filename']" regex="{$date-regex}">
					<xsl:matching-substring>
						<xsl:variable name="year" select="regex-group(1)"/>
						<xsl:variable name="month" select="regex-group(2)"/>
						<xsl:variable name="day" select="regex-group(3)"/>
						<xsl:variable name="when" select="
							concat(
								if (number($year) &lt; 40) then '19' else '18', 
								$year,
								if ($month = '00') then 
									'' 
								else 
									concat(
										'-', 
										$month,
										if ($day = '00') then 
											'' 
										else 
											concat('-', $day)
									)
							)
						"/>
						<date when="{$when}"><xsl:value-of select="$when"/></date>
					</xsl:matching-substring>
				</xsl:analyze-string>
			</bibl>
		</xsl:copy>
	</xsl:template>
	

	<!-- remove "number"-styled paragraphs from text -->
	<!--<xsl:template match="tei:p[@rend='number']"/>-->
	<!-- remove "location"-styled paragraphs from text -->
	<!--<xsl:template match="tei:p[@rend='location']"/>-->
	<!-- remove "correspondent"-styled paragraphs from text -->
	<!-- really?
	<xsl:template match="tei:p[@rend='correspondent']"/>
	-->

	<xsl:template match="* | @*">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
		
</xsl:stylesheet>
