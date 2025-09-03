<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
	xmlns:css="https://www.w3.org/Style/CSS/"
	xmlns:tei="http://www.tei-c.org/ns/1.0">
	<!-- remove paragraphs which contain metadata fields and are relics of the Word-conversion process,
	as well as the incipit headings which were added for XTF's benefit, 
	and purge unwanted CSS properties
	-->
	
	<xsl:import href="css.xsl"/>
	
	<xsl:mode on-no-match="shallow-copy"/>
	<!-- XTF required that a document contain at least one div with a head -->
	<xsl:template match="tei:head[@type='incipit']"/>
	<xsl:template match="tei:body/tei:div[@xml:id='main']">
		<xsl:apply-templates/>
	</xsl:template>
	<!-- these are elements in the text of the Word document which contain metadata. The values have already been copied into the teiHeader -->
	<xsl:template match="(tei:p|tei:ab)[lower-case(@rend)=('number', 'correspondent', 'location', 'progress%20note', 'plant%20names', 'prelim%20head')]"/>
	<!-- filter the CSS rules from style attributes, retaining only font-weight and font-style properties --> 
	<xsl:template match="@style">
		<xsl:variable name="desired-properties" select="(
			'font-weight', 'font-style', 'font-variant',
			'text-align',
			'padding', 'padding-left', 'padding-right', 'padding-top', 'padding-bottom',
			'border', 'border-left', 'border-right', 'border-top', 'border-bottom'
		)"/>
		<xsl:variable name="purified-declarations" select="css:filter-declaration-block(., $desired-properties)"/>
		<xsl:if test="$purified-declarations">
			<xsl:attribute name="style" select="$purified-declarations"/>
		</xsl:if>
	</xsl:template>
	<!-- completely purge any inline formatting from VMCPTitle paragraphs -->
	<xsl:template match="tei:p[contains-token(@rend, 'VMCPTitle')]/@style"/>
	<!-- discard any embedded markup from VMCPTitle paragraphs -->
	<xsl:template match="tei:p[contains-token(@rend, 'VMCPTitle')]/*">
		<xsl:apply-templates/>
	</xsl:template>
	<xsl:template match="@rend">
		<xsl:attribute name="rend" select="replace(., '(%20)', '_')"/>
	</xsl:template>
</xsl:stylesheet>