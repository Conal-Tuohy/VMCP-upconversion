<xsl:stylesheet version="3.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xpath-default-namespace="http://www.tei-c.org/ns/1.0">
	<xsl:mode on-no-match="shallow-copy" use-accumulators="footnote-number"/>
	<xsl:accumulator name="footnote-number" initial-value="0">
		<xsl:accumulator-rule match="note[@type='footnote']" select="$value + 1"/>
	</xsl:accumulator>
	<xsl:template match="note[@type='footnote']">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:attribute name="n" select="accumulator-before('footnote-number')"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>