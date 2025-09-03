<xsl:transform version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:css="https://www.w3.org/Style/CSS/" xmlns:map="http://www.w3.org/2005/xpath-functions/map" xmlns:array="http://www.w3.org/2005/xpath-functions/array">


	<xsl:function name="css:filter-declaration-block">
		<xsl:param name="declaration-block"/>
		<xsl:param name="desired-properties"/>
		<xsl:sequence select="
			($declaration-block => tokenize(';')) [substring-before(., ':') => normalize-space() = $desired-properties]
			=> string-join('; ')
		"/>
	</xsl:function>

</xsl:transform>