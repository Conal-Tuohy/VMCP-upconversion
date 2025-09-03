<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0" xmlns="http://www.tei-c.org/ns/1.0" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:vmcp="https://vmcp.rbg.vic.gov.au/" xmlns:xs="http://www.w3.org/2001/XMLSchema" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
	<!-- recognises the filenames of documents and inserts TEI <ref> markup -->
	
	<xsl:mode on-no-match="shallow-copy"/>
	<xsl:template match="note[not(normalize-space())]"/>
	<xsl:template match="
		(
			msName | (: the manuscript name often refers to other manuscripts :)
			note | (: footnotes refer to other manuscripts :)
			/TEI
				[teiHeader/fileDesc/publicationStmt/idno[@type='filename'] => starts-with('data/Apparatus files/')]
				/text (: the entire text of the Apparatus files may refer to manuscripts :) 
		)
		//text()[normalize-space()]">
		<!-- This text node may contain a reference to another letter, which should be converted to a hyperlink.
		
		Arthur explains:
			The trouble is that cross references are implicit unless there are multiple letters with the same date, when suffixes are added. 
			To make explicit automatic links to these should be possible. They are all [supposed to be] in the form 
			"M to <Initial><Surname> , <day in normal numerals> <Month spelled out><year in full numerals>" where the days below 10 do not have a leading zero. 
			Or  "<Initial><Surname> to M, <day in normal numerals> <Month spelled out><year in full numerals>.
			
		So a human readable date "15 June 1870" should be converted to a link to the file "70-06-15", unless the same note contains an explicit identifier 
		for the same date, e.g. '70-06-15a', (with the disambiguating "a") suffix, in which case the explicit identifier should be used and the human-readable date ignored.
		i.e.
			see M to J. Haast, 15 June 1870. ⇒ 
			see M to J. Haast, <ref target="70-06-15a">15 June 1870</ref>.
		but:
			see M to J. Haast, 15 June 1870 (in this edition as 70-06-15a). ⇒ 
			see M to J. Haast, 15 June 1870 (in this edition as <ref target="70-06-15a">70-06-15a</ref>).
		Consequently this means that we need to process the note twice: firstly to create a list of explicit file identifiers,
		and secondly to convert the dates (ignoring any dates which are explicitly disambiguated by an explicit file identifier). 
		NB this assumes that the human-readable date and any corresponding explicit identifier appear in the same text node.
		-->
		<!-- pathname e.g. "data/Mueller letters/1840-9/1845-9/45-04-00-final.doc" -->
		<xsl:variable name="pathname" select="/TEI/teiHeader/fileDesc/publicationStmt/idno[@type='filename']"/>
		<!-- file-identifier e.g. "45-04-00" -->
		<xsl:variable name="file-identifier" select="replace($pathname, '^.*/(.*).doc$', '$1')"/>
		<!-- identify the explicit filenames in the text, a sequence of fn:match elements, with the date
		components parsed as individual fn:group elements : e.g.
		<fn:match> <fn:group>70</fn:group>-<fn:group>06</fn:group>-<fn:group>15</fn:group>a</fn:match>
		-->
		<!-- filenames must follow white space; they have an optional prefix of up to two alpha characters, then yy-mm-dd, and
		finishing with an optional suffix of a single alpha character -->  
		<xsl:variable name="explicit-filenames" select="analyze-string(., '\s(\w{0,2})(\d\d)-(\d\d)-(\d\d)(\w|\s|$)')/fn:match"/>
		<xsl:variable name="explicit-filename-dates" select="
		  for $match in $explicit-filenames 
		  return 
			  let
				$year:= $match/fn:group[@nr='2'],
				$month:= $match/fn:group[@nr='3'],
				$day:= $match/fn:group[@nr='4']
			  return 
				vmcp:year-month-day-to-date($year, $month, $day)
		"/>
		<!-- recognise human-readable cross-references and parse date components -->
		<xsl:variable name="human-readable-date-regex" select="
			'(M to [^\d]*| to M[^\d]*)(\d\d?) (January|February|March|April|May|June|July|August|September|October|November|December) (\d\d\d\d)'
		"/>
		<xsl:variable name="explicit-filename-regex" select="
			'(\s)(\w{0,2})(\d\d)-(\d\d)-(\d\d)(\w|\s|$)'
		"/>
		<xsl:analyze-string select="." regex="{$human-readable-date-regex}|{$explicit-filename-regex}">
			<xsl:matching-substring>
				<xsl:choose>
					<xsl:when test="regex-group(1)">
						<!-- We have a human-readable date which we can convert to a ref but ONLY if the date value doesn't match an explicit filename date -->
						<xsl:variable name="correspondents" select="regex-group(1)"/>
						<xsl:variable name="day" select="regex-group(2)"/>
						<xsl:variable name="month" select="regex-group(3)"/>
						<xsl:variable name="year" select="regex-group(4)"/>
						<xsl:variable name="date" select="vmcp:day-month-year-to-date($day, $month, $year)"/>
						<xsl:choose>
							<xsl:when test="$date = $explicit-filename-dates">
								<!-- there is a disambiguating reference to the file coming up later, so don't render this date as a link -->
								<xsl:value-of select="."/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$correspondents"/><!-- the "M to Joe Bloggs, " portion of the reference -->
								<xsl:element name="ref">
									<xsl:attribute name="target" expand-text="yes">{$resolver-base-url}{$date}</xsl:attribute>
									<xsl:value-of select=". => substring-after($correspondents)"/>
								</xsl:element>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<!-- We have an explicit file identifier rather than a human-readable date -->
						<xsl:variable name="white-space" select="regex-group(5)"/>
						<xsl:variable name="prefix" select="regex-group(6)"/>
						<xsl:variable name="year" select="regex-group(7)"/>
						<xsl:variable name="month" select="regex-group(8)"/>
						<xsl:variable name="day" select="regex-group(9)"/>
						<xsl:variable name="suffix" select="regex-group(10)"/>
						<xsl:variable name="date" select="vmcp:year-month-day-to-date($year, $month, $day)"/>
						<xsl:value-of select="$white-space"/>
						<xsl:element name="ref">
							<xsl:attribute name="target" expand-text="yes">{$resolver-base-url}{$prefix}{$year}-{$month}-{$day}{$suffix}</xsl:attribute>
							<xsl:text expand-text="yes">{$prefix}{$year}-{$month}-{$day}{$suffix}</xsl:text>
						</xsl:element>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:matching-substring>
			<xsl:non-matching-substring>
				<xsl:value-of select="."/>
			</xsl:non-matching-substring>
		</xsl:analyze-string>
	</xsl:template>
	<!-- parse a human-readable date like "15" "June" "1870" -->
	<xsl:function name="vmcp:day-month-year-to-date">
		<xsl:param name="day"/>
		<xsl:param name="month"/>
		<xsl:param name="year"/>
		<xsl:variable name="months" select="
			map{
				'January': '01',
				'February': '02',
				'March': '03',
				'April': '04',
				'May': '05',
				'June': '06',
				'July': '07',
				'August': '08',
				'September': '09',
				'October': '10',
				'November': '11',
				'December': '12'
			}
		"/>
		<xsl:sequence select="
			concat(
				$year => substring(3),
				'-',
				$months($month),
				'-',
				$day => number() => format-number('99')
			)
		"/>
	</xsl:function>
	
	<!-- parse a date like "76" "12" "29" -->
	<xsl:function name="vmcp:year-month-day-to-date">
		<xsl:param name="year"/>
		<xsl:param name="month"/>
		<xsl:param name="day"/>
		<xsl:sequence select="concat($year, '-', $month, '-', $day)"/>
	</xsl:function>
	<xsl:variable name="resolver-base-url" select=" '/id/' "/>
</xsl:stylesheet>