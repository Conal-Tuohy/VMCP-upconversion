<xsl:stylesheet version="3.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	xmlns="http://www.tei-c.org/ns/1.0">
	
	<xsl:mode on-no-match="shallow-copy"/>
	
	<!-- These are the @rend values of paragraphs which contain metadata rather than transcription -->
	<!-- Any notes which are inside these paragraphs will be moved into the body of the letter -->
	<xsl:variable name="metadata-paragraph-rend-values" select="
		(
			'Progress%20note',
			'location',
			'correspondent',
			'Plant%20names', 
			'plant%20names',
			'number'
		)
	"/>
	
	<!-- These are the metadata paragraphs -->
	<xsl:variable name="metadata" select="(//p | //ab)[@rend=$metadata-paragraph-rend-values]"/>
	
	<!-- These are the notes which appear in metadata paragraphs -->
	<xsl:variable name="notes-in-metadata" select="$metadata//note"/>
	
	<!-- don't copy notes which appear in metadata -->
	<xsl:template match="$notes-in-metadata">
		<xsl:comment>discarded note</xsl:comment>
	</xsl:template>
	
	<!-- Any notes which were removed from metadata paragraphs should be inserted instead
	as the first children of the first non-whitespace, non-metadata child of the body element -->
	<xsl:template match="
		body/*
			[normalize-space()]
			[not(@rend=$metadata-paragraph-rend-values)]
			[not(preceding-sibling::*[normalize-space()][not(@rend=$metadata-paragraph-rend-values)])]
	">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:copy-of select="$notes-in-metadata"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
		
</xsl:stylesheet>
