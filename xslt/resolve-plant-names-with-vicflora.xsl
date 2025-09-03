<xsl:stylesheet version="3.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	xmlns="http://www.tei-c.org/ns/1.0"
	xmlns:array="http://www.w3.org/2005/xpath-functions/array">
<!--
	Look at each plant name <term>: "/TEI/teiHeader/profileDesc/textClass/keywords[@scheme='#plant-names']/term"
	Resolve the name to an identifier it using the json document downloaded from the VicFlora API. 
	Use the resulting identifier to decorate the <term>:
		<term key="Banksia serrata" ref="https://vicflora.rbg.vic.gov.au/flora/taxon/58481dd5-27b8-4285-881e-4753e4afab7a">Banksia serrata</term>
-->
	<xsl:mode on-no-match="shallow-copy"/>
	
	<xsl:param name="plant-names"/>
	<!--
	<xsl:variable name="taxa-by-name" select="json-doc($plant-names)"/>
	-->
	<xsl:variable name="taxa-by-name" select="parse-json(xml-to-json(doc($plant-names)))"/>

	<xsl:template match="/TEI/teiHeader/profileDesc/textClass/keywords[@scheme='#plant-names']/term">
		<xsl:copy>
			<xsl:variable name="taxon-id" select="$taxa-by-name(.)"/>
			<xsl:if test="$taxon-id">
				<xsl:attribute name="ref" select=" 'https://vicflora.rbg.vic.gov.au/flora/taxon/' || $taxon-id "/>
			</xsl:if>
			<xsl:copy-of select="text()"/>
		</xsl:copy>
	</xsl:template>
	
</xsl:stylesheet>
