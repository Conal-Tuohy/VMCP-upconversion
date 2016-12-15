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
	<!-- an empty para is just a line break -->
	<xsl:template match="tei:p[not(normalize-space())]" priority="100">
		<space dim="vertical" unit="lines" quantity="1"/>
	</xsl:template>
	
	<!-- match a p carrying the first part of a valediction -->
	<!--
	TODO enable this and ensure that these closer elements are genuinely situated at the bottom of divs
	(in the case of translated texts, there will be a German text with closer, followed by an English text)
	-->
	<!--
	<xsl:template match="tei:p[@rend='valediction'][not(preceding-sibling::*[1]/self::tei:p/@rend='valediction')]">
		<closer>
			<xsl:copy-of select="@rend"/>
			<xsl:apply-templates select="." mode="valediction-part"/>
		</closer>
	</xsl:template>
	-->
	
	<!-- match a p carrying a part of a valediction (not the first part, but a subsequent part) -->
	<!--
	<xsl:template match="tei:p[@rend='valediction'][preceding-sibling::*[1]/self::tei:p/@rend='valediction']"/>
	-->
	<!-- parts of valedictions can't be easily recognised as <signed> or <salute>, so treat them as phrases -->
	<!--
	<xsl:template match="tei:p[@rend='valediction']" mode="valediction-part" >
		<phr>
			<xsl:copy-of select="@style"/>
			<xsl:apply-templates/>
		</phr>
		<xsl:apply-templates mode="valediction-part"
			select="following-sibling::*[1][self::tei:p/@rend='valediction'][normalize-space()]"/>
	</xsl:template>
	-->

	<xsl:template match="* | @*">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
		
</xsl:stylesheet>
