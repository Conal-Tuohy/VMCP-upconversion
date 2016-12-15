<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei">
	<xsl:template match="* | @*">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="tei:*[tei:p]">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<!-- Group adjacent paragraphs by the number of tabular columns they have.
			Paragraphs with the same number of columns will be grouped into a table.
			Paragraphs which don't begin with non-whitespace text (before any tab) are
			assumed not to be part of a table (they count as having zero columns)  -->
			<xsl:for-each-group select="*" group-adjacent="
				count(
					self::tei:p
						[
							tei:space
								[@dim='horizontal']
								[@extent='tab']
								[1]
								/preceding-sibling::node()
									[1]
									[normalize-space()]
						]
						/tei:space
							[@dim='horizontal']
							[@extent='tab']
							[preceding-sibling::node()[1][normalize-space()]]
				)
			">
				<xsl:variable name="tab-count" select="current-grouping-key()"/>
				<xsl:choose>
					<xsl:when test="count(current-group() = 1)">
						<!-- no such thing as a single-row table -->
						<xsl:copy-of select="current-group()"/>
					</xsl:when>
					<xsl:when test="$tab-count = 0">
						<!-- tab-count = 0 implies a single column table; i.e. just a bunch of paragraphs -->
						<xsl:copy-of select="current-group()"/>
					</xsl:when>
					<xsl:otherwise>
						<!-- calculate number of tabs in the first para of the group -->
						<xsl:variable name="number-of-tabs" select="
							count(
								self::tei:p/tei:space
									[@dim='horizontal']
									[@extent='tab']
							)
						"/>
						<!-- check if all paragraphs in the group have the same number -->
						<xsl:choose>
							<xsl:when test="
								current-group()[
									$number-of-tabs !=
									count(
										self::tei:p/tei:space
											[@dim='horizontal']
											[@extent='tab']
									)
								]
							">
								<!-- not an evenly tabulated group of paragraphs -->
								<xsl:copy-of select="current-group()"/>
							</xsl:when>
							<xsl:otherwise>
								<!-- it's an evenly tabulated set of paragraphs -->
								<table class="converted%20tabs">
									<!-- create a row for each paragraph in the group -->
									<xsl:for-each select="current-group()">
										<row>
											<!-- create a cell for each tab in the paragraph -->
											<xsl:for-each-group group-starting-with="
												tei:space
													[@dim='horizontal']
													[@extent='tab']
											">
												<cell>
													<xsl:copy-of select="
														current-group()[not(self::tei:space
															[@dim='horizontal']
															[@extent='tab']
														)]
													"/>
												</cell>
											</xsl:for-each-group>
										</row>
									</xsl:for-each>
								</table>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each-group>
		</xsl:copy>
	</xsl:template>
</xsl:transform>
