<!-- recognise texts which contain translations and wrap each language's content in its own text -->
<!-- so that they can be conveniently displayed side-by-side -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
	xmlns="http://www.tei-c.org/ns/1.0"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0">
	<xsl:mode on-no-match="shallow-copy"/>
	<xsl:template match="text[body//p/@xml:lang[. ne 'en']]">
		<!-- Where the document can be neatly divided into two texts, do so -->
		<!-- 
		In other cases, snippets of text in different languages are intermingled, and 
		these can't in general be adequately modelled as two distinct text elements; in these
		cases, the two languages need to be highlighted distinctly in the web page, e.g. by
		using different fonts or colours. 
		-->
		<!-- 
		The indivisible texts are the ones which
		produce more than two texts when the body/* elements are grouped-adjacent by xml:lang,
		have body/* elements in one language with descendants in a different language
		--> 
		<xsl:variable name="first-english-element" select="body/*[@xml:lang='en'][1]"/>
		<xsl:choose>
			<xsl:when test="
				(
					(: english followed by non-english, but also preceded by non-english :)
					exists($first-english-element/following-sibling::*[not(@xml:lang='en')]) and
					exists($first-english-element/preceding-sibling::*[not(@xml:lang='en')])
				) or (
					(: body contains elements in a language which differs from the language of
					an ancestor element :)
					body//*[@xml:lang][@xml:lang != ancestor::*/@xml:lang]
				)
			">
				<xsl:copy-of select="."/>
			</xsl:when>
			<xsl:otherwise>
				<!-- the text can be neatly divided into two texts with different languages -->
				<text>
					<group>
						<!-- group the child elements of the body into two groups: those in English, and the rest -->
						<xsl:for-each-group select="body/*" group-by="@xml:lang='en'">
							<!-- represent each group of elements as a TEI text -->
							<text>
								<!-- tag the text with the language of the elements in the group -->
								<xsl:copy-of select="@xml:lang[1]"/>
								<body>
									<xsl:copy-of select="current-group()"/>
								</body>
							</text>
						</xsl:for-each-group>
					</group>
				</text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>