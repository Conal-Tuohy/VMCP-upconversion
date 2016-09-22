<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="tei">

	<!-- earlier stages in the pipeline may have created container elements which were never
	subsequently filled with content; here those container elements are removed -->

	<xsl:template match="tei:profileDesc | tei:textClass">
		<xsl:variable name="content">
			<xsl:apply-templates/>
		</xsl:variable>
		<xsl:if test="$content">
			<xsl:copy>
				<xsl:copy-of select="@*"/>
				<xsl:copy-of select="$content"/>
			</xsl:copy>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="* | @*">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
		
</xsl:stylesheet>
