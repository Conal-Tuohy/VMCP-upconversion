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
		<xsl:apply-templates select="//tei:p[@rend='correspondent']" mode="correspondent-name"/>
	</xsl:variable>

	<xsl:template match="tei:teiHeader//tei:title[not(normalize-space())]">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:value-of select="$title"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="tei:textClass">
		<xsl:copy>
			<xsl:copy-of select="@* | node()"/>
			<xsl:variable name="plants" select="//tei:p[@rend=('Plant_20_names', 'plant_20_names')]/text()"/>
			<xsl:if test="$plants">
				<keywords scheme="plants">
					<xsl:for-each select="$plants">
						<term><xsl:value-of select="."/></term>
					</xsl:for-each>
				</keywords>
			</xsl:if>
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
								'18', 
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
	
	<!-- extract only a name from the 'correspondent' paragraph (which may start with 'From ') -->
	<xsl:template match="tei:p[@rend='correspondent']" mode="correspondent-name">
		<xsl:variable name="text" select="string-join(text(), ' ')"/><!-- ignoring any notes -->
		<xsl:analyze-string select="$text" regex="(From )?(.+)">
			<xsl:matching-substring>
				<author><xsl:value-of select="regex-group(2)"/></author>
			</xsl:matching-substring>
		</xsl:analyze-string>
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
