<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="tei">
	<!-- replace the "Private Use" Symbol character encoding with regular Unicode -->
	
	<xsl:template match="@style[contains(., 'font-name: ')]" priority="100">
		<xsl:variable name="new-style" select="replace(., 'font-name: [^;]+; ', '')"/>
		<xsl:if test="$new-style">
			<xsl:attribute name="style" select="$new-style"/>
		</xsl:if>
	</xsl:template>
	
	<!-- See https://en.wikipedia.org/wiki/Symbol_(typeface) -->
	<xsl:variable name="adobe-unicode-mapping" select="
		concat(
			' !∀#∃%&amp;∍()*+,-./',
			'0123456789:;&lt;=&gt;?',
			'≅ΑΒΧΔΕΦΓΗΙϑΚΛΜΝΟ',
			'ΠΘΡΣΤΥςΩΞΨΖ[∴]⊥_',
			'αβχδεφγηιϕκλμνο',
			'πθρστυϖωξψζ{|}~�',
			'����������������',
			'����������������',
			'€ϒʹ≤⁄∞ƒ♣♦♥♠↔←↑→↓',
			'°±ʺ≥×∝∂•÷≠≡≈…⏐⎯↵',
			'ℵℑℜ℘⊗⊕∅∩∪⊃⊇⊄⊂⊆∈∉',
			'∠∇®©™∏√⋅¬∧∨⇔⇐⇑⇒⇓',
			'◊〈®©™∑⎛⎜⎝⎡⎢⎣⎧⎨⎩⎪',
			'�〉∫⌠⎮⌡⎞⎟⎠⎤⎥⎦⎫⎬⎭'
		)
	"/>
	<xsl:template match="tei:*[contains(@style, 'font-name: Symbol; ')]/text()">
		<!-- this text uses a private encoding -->
		<xsl:for-each select="string-to-codepoints(.)">
			<xsl:choose>
				<xsl:when test="(. &lt; 61472) or (. &gt; 61694)">
					<xsl:text>�</xsl:text><!-- "Replacement Character" since code is out of range -->
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="adobe-codepoint" select=". - 61472"/>
					<xsl:value-of select="
						substring(
							$adobe-unicode-mapping,
							$adobe-codepoint + 1,
							1
						)
					"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="* | @*">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
		
</xsl:stylesheet>
