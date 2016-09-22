<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="tei xs">
<!--
write the list of renditions in html
-->
	<xsl:template match="/">
		<html>
			<head>
				<title>Distinctly styled elements</title>
				<style type="text/css">
th, td {
    padding: 15px;
    text-align: left;
}
tr:nth-child(even) {background-color: #f2f2f2}
th {
    background-color: #4CAF50;
    color: white;
}
				</style>
			</head>
			<body>
				<h1>Distinctly styled elements</h1>
				<table>
					<tr><th>Frequency</th><th>TEI element</th><th>Style name</th></tr>
					<xsl:for-each select="//*[@rend]">
						<xsl:sort select="@n" data-type="number" order="descending"/>
						<tr>
							<td><xsl:value-of select="@n"/></td>
							<td><xsl:value-of select="local-name(.)"/></td>
							<td><xsl:analyze-string select="@rend" regex="_([0123456789abcdef]{{2}})_">
								<xsl:matching-substring>
									<xsl:variable name="digits" select=" '0123456789abcdef' "/>
									<xsl:variable name="sixteens-digit" select="substring(regex-group(1), 1, 1)"/>
									<xsl:variable name="sixteens-value" select="string-length(substring-before($digits, $sixteens-digit))"/>
									<xsl:variable name="ones-digit" select="substring(regex-group(1), 2, 1)"/>
									<xsl:variable name="ones-value" select="string-length(substring-before($digits, $ones-digit))"/>
									<xsl:variable name="codepoint" select="16 * $sixteens-value + $ones-value"/>
									<xsl:value-of select="codepoints-to-string($codepoint)"/>
								</xsl:matching-substring>
								<xsl:non-matching-substring>
									<xsl:value-of select="."/>
								</xsl:non-matching-substring>
							</xsl:analyze-string></td>
						</tr>
					</xsl:for-each>
				</table>
			</body>
		</html>
	</xsl:template>
		
</xsl:stylesheet>
