<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0" 
	xmlns="http://www.tei-c.org/ns/1.0"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0">
	<!-- recognises the filenames of images and inserts TEI <figure> markup -->
	
	<xsl:mode on-no-match="shallow-copy"/>
	<xsl:template match="note[not(normalize-space())]"/>
	<xsl:template match="(msName | note)//text()[contains(., '.jpg')]">
		<!-- This text node contains the name of an image file e.g. "For sketch, see 64-10-03_image02.jpg." -->
		<!-- pathname e.g. "data/Mueller letters/1840-9/1845-9/45-04-00-final.doc" -->
		<xsl:variable name="pathname" select="/TEI/teiHeader/fileDesc/publicationStmt/idno[@type='filename']"/>
		<!-- file-identifier e.g. "45-04-00" -->
		<xsl:variable name="file-identifier" select="replace($pathname, '^.*/(.*).doc$', '$1')"/>
		<!-- searching for image file names in the text --> 
<!-- TODO recognise image filenames which don't end with '.jpg' -->
<!-- use the presence of "_image" in the filename as the identifying characteristic of an image filename -->
		<xsl:analyze-string select="." regex="[^\.\s]+\.jpg">
			<xsl:matching-substring>
				<graphic url="{encode-for-uri(.)}"/>
			</xsl:matching-substring>
			<xsl:non-matching-substring>
				<xsl:value-of select="."/>
			</xsl:non-matching-substring>
		</xsl:analyze-string>
	</xsl:template>
</xsl:stylesheet>