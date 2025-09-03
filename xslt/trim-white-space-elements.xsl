<!-- trim any leading and trailing tei:space elements within a tei:text/tei:body -->
<!-- The point is to remove elements such as <space dim="vertical" unit="lines" quantity="1"/> -->
<!-- which appear either before or after the textual content of the letter -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
	xmlns="http://www.tei-c.org/ns/1.0"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0">
	<xsl:mode on-no-match="shallow-copy"/>
	<xsl:template match="
		text/body/space[
			not(
				preceding-sibling::*[normalize-space()] and following-sibling::*[normalize-space()]
			)
		]
	"/>
</xsl:stylesheet>