<xsl:stylesheet version="3.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	xmlns="http://www.tei-c.org/ns/1.0">
	
	<xsl:mode on-no-match="shallow-copy"/>
	
	<!-- These are the @rend values of paragraphs which contain metadata rather than transcription -->
	<!-- Any notes which are inside these paragraphs will be moved into the body of the letter -->
	<xsl:variable name="metadata-paragraph-rend-values" select="
		(
			'progress%20note',
			'location',
			'correspondent',
			'plant%20names',
			'number',
			'VMCPTitle'
		)
	"/>
	
	<!-- don't copy notes which appear in metadata -->
	<xsl:template match="(//p | //ab)[lower-case(@rend)=$metadata-paragraph-rend-values]//note"/>
	
	<!-- Any notes which were removed from metadata paragraphs should be inserted instead
	as the first children of the first non-whitespace, non-metadata child of the body element -->
	<xsl:template match="
		body/*
			[normalize-space()]
			[not(lower-case(@rend)=$metadata-paragraph-rend-values)]
			[not(preceding-sibling::*[normalize-space()][not(lower-case(@rend)=$metadata-paragraph-rend-values)])]
	">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<!-- These are the notes which originally appeared in metadata paragraphs -->
			<xsl:copy-of select="(//p | //ab)[lower-case(@rend)=$metadata-paragraph-rend-values]//note"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
		
</xsl:stylesheet>
