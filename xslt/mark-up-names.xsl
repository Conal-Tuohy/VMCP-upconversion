<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:tei="http://www.tei-c.org/ns/1.0" 
	xmlns="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei">
	<!--
	Mark up taxonomic names where they appear in the text, using a list of taxonomic names already present in the teiHeader
	-->
	<xsl:template match="* | @*">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
	<!-- sort the names in descending order of length, so that more specific names come first in the regular expression -->
	<xsl:variable name="plant-names" select="/tei:TEI/tei:teiHeader/tei:profileDesc/tei:textClass/tei:keywords[@scheme='#plant-names']/tei:term"/>
	<xsl:variable name="regex" select="
		string-join(
			$plant-names,
			'|'
		)
	"/>
	<xsl:template match="/">
		<xsl:choose>
			<xsl:when test="$regex">
				<xsl:apply-templates/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="tei:text//text()">
		<xsl:analyze-string select="." regex="{$regex}">
			<xsl:matching-substring>
				<xsl:element name="name">
					<!-- for convenience of downstream formatting, the 'key' attribute can be used in a URI component -->
					<xsl:attribute name="key" select="encode-for-uri(.)"/>
					<xsl:value-of select="."/>
				</xsl:element>
			</xsl:matching-substring>
			<xsl:non-matching-substring>
				<xsl:value-of select="."/>
			</xsl:non-matching-substring>
		</xsl:analyze-string>
	</xsl:template>

</xsl:stylesheet>
