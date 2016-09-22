<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns="http://www.tei-c.org/ns/1.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="tei xs">
<!--
make a list of elements with distinct rendition
-->
	<xsl:template match="/*">
		<xsl:copy>
			<xsl:for-each-group select="//*[@rend]" group-by="concat(local-name(.), @rend)">
				<xsl:element name="{local-name()}">
					<xsl:copy-of select="@rend"/>
					<xsl:attribute name="n">
						<xsl:value-of select="sum(
							for $rend in current-group() return if ($rend/@n) then xs:integer($rend/@n) else 1
						)"/>
					</xsl:attribute>
				</xsl:element>
			</xsl:for-each-group>
		</xsl:copy>
	</xsl:template>
		
</xsl:stylesheet>
