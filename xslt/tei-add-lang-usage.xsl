<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei">
	<xsl:template match="* | @*">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
	<!-- generate langUsage statistics --> 
	<xsl:template match="/tei:TEI/tei:teiHeader/tei:profileDesc/tei:langUsage">
		<xsl:copy>
			<xsl:choose>
				<xsl:when test="exists(//*/@xml:lang)">
					<xsl:variable name="english" select="key('text-by-language', 'en')"/>
					<xsl:variable name="german" select="key('text-by-language', 'de')"/>
					<xsl:variable name="english-length" select="sum(for $t in $english return string-length($t))"/>
					<xsl:variable name="german-length" select="sum(for $t in $german return string-length($t))"/>
					<xsl:variable name="english-percentage" select="(100 * $english-length) idiv ($english-length + $german-length)"/>
					<xsl:variable name="german-percentage" select="100 - $english-percentage"/>
					<language id="en" usage="{$english-percentage}">English</language>
					<language id="de" usage="{$german-percentage}">German</language>
				</xsl:when>
				<xsl:otherwise>
					<language id="en" usage="100">English</language>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:copy>
	</xsl:template>
	<xsl:key name="text-by-language" match="text()" use="ancestor::*/@xml:lang[1]"/>
</xsl:transform>
