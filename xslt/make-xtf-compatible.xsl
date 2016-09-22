<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei">
	<xsl:template match="* | @*">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="tei:body">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<div xml:id="main">
				<head type="incipit"><supplied reason="XTF-compatiblity"><xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"/></supplied></head>
				<xsl:apply-templates/>
			</div>
		</xsl:copy>
	</xsl:template>
</xsl:transform>
