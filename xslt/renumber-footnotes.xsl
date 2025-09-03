<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0" xmlns:tei="http://www.tei-c.org/ns/1.0">
	<!-- Renumber footnotes sequentially -->
	<xsl:mode on-no-match="shallow-copy"/>
	<!-- 
	There are two distinct markup idioms in Word for creating footnotes; one is using Word's "footnotes" feature,
	and another is to style a paragraph as "note" and link to it with a hyperlink. This means footnote numbers don't
	form a single sequence.
	
	Additionally, footnotes can appear in "metadata" paragraphs (such as "location") which are stripped from the
	body of the TEI and moved somewhere into the teiHeader. When this happens, the remaining footnotes in the
	transcript don't start their numbering from 1.
	
	To fix up footnote numbering, the current note/@n attributes are simply replaced with a running sequence number.
	-->
	<!--
	<xsl:accumulator name="footnote" as="xs:integer" initial-value="1" streamable="yes">
		<xsl:accumulator-rule match="tei:note" select="$value + 1"/>
	</xsl:accumulator>
	<xsl:template match="tei:note">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:attribute name="n" select="accumulator-before('footnote')"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
	-->
	<xsl:template match="tei:note">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:attribute name="n" select="1 + count(preceding::tei:note[ancestor::tei:text])"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
	
</xsl:stylesheet>