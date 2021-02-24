<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="tei">
<!--
Recognise where the text represents a source in German, alongside an English translation.
These translated passages consist of sequences of paragraphs with a style whose name begins with "t-".
The "t-" prefix identifies the text which is the English translation. The prefix should be stripped from the
style names as the remainder of the style name will then identify the semantics of the paragraph
("letter", "valediction", "date", etc) the same was as the untranslated text's styles do. 
-->

	<xsl:template match="tei:p">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:choose>
				<xsl:when test="starts-with(@rend, 't-')">
					<!-- paragraph is a translation, presumably into English -->
					<xsl:attribute name="xml:lang">en</xsl:attribute>
					<!-- strip the "t-" (translation flag) prefix -->
					<xsl:attribute name="rend"><xsl:value-of select="substring-after(@rend, 't-')"/></xsl:attribute>
				</xsl:when>
				<xsl:when test="following-sibling::tei:p[starts-with(@rend, 't-')][normalize-space()]">
					<!-- paragraph preceding a translation is assumed to be the German source text -->
					<xsl:attribute name="xml:lang">de</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<!-- paragraph in text not containing any translations, or paragraph trailing last translation -->
					<!-- assumed to be in English -->
					<xsl:attribute name="xml:lang">en</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="* | @*">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
		
</xsl:stylesheet>
