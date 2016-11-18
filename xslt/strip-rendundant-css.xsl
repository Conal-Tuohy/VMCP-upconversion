<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="tei">
	<!-- throw out all the formatting associated with paragraphs using various styles, on the assumption that
	they are not transcriptional but rather metadata field (TODO check this assumption) -->
	<xsl:template match="tei:p[@rend=('number', 'location', 'correspondent', 'plant_20_names')]/@style"/>

	<xsl:template match="* | @*">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
		
</xsl:stylesheet>
