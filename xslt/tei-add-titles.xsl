<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei">
	<xsl:template match="* | @*">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
	<!-- the letters don't have titles, so here we generate an incipit, being the first 200 chars of text taken from the first 5 lines --> 
	<xsl:template match="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[not(normalize-space())]">
		<xsl:copy>
			<xsl:value-of select="
				concat(
					substring(
						string-join(
							(/tei:TEI/tei:text/tei:body/tei:p[normalize-space()])[position()&lt;6]/node()[not(self::tei:note)], 
							' ¶ '
						),
						1, 
						200
					),
					'...'
				)
			"/>
		</xsl:copy>
	</xsl:template>
</xsl:transform>
