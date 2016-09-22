<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="tei">
<!--
input 
p[@rend]
ab[@type=heading] 
seg[@style] - formatted span of text
note[@type=annotation][@resp]
note[@n][@type] @type is the note class, whatever that is
@xml:id
space[@dim='horizontal' and @extent='tab']
figure[@rend='horizontal-line']
figure[@rend='{draw:enhanced-geometry/@draw:type}']/text()
note[@type='frame'] - a drawing frame
space[@unit='chars'][@quantity]
-->


	<xsl:template match="* | @*">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
		
</xsl:stylesheet>
