<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:log4j="http://jakarta.apache.org/log4j/"
               version="2.0">
<!--
Sample xslt to be able to view the import file as html
-->
  <xsl:output method="html" indent="yes" encoding="US-ASCII"/>

  <xsl:template match="/">
    <xsl:call-template name="recursive_table" >
      <xsl:with-param name="level">1</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="recursive_table">
    <xsl:param name="level"/>
    <table>
      <tbody>
        <xsl:for-each select="attribute::*">
          <tr>
            <th>
              <xsl:value-of select ="local-name()"/>
            </th>
            <td>
              <xsl:attribute name="class">
                <xsl:value-of select ="local-name()"/>
              </xsl:attribute>
              <xsl:call-template name="break">
                <xsl:with-param name="text" select="./text()" />
              </xsl:call-template>
            </td>
          </tr>
        </xsl:for-each>
      </tbody>
    </table>

    <xsl:if test="count(*) > 0">
      <table>
        <xsl:attribute name="border">
          <xsl:value-of select="$level" />
        </xsl:attribute>
        <tbody>
          <xsl:for-each select="*">
            <tr>
              <th>
                <xsl:value-of select ="name()"/>
              </th>
              <td>
                <!--<xsl:value-of select="."/>-->
                <xsl:call-template name="break">
                  <xsl:with-param name="text" select="./text()" />
                </xsl:call-template>

                <xsl:call-template name="recursive_table" >
                  <xsl:with-param name="level">
                    <xsl:value-of select="$level+1" />
                  </xsl:with-param>
                </xsl:call-template>

              </td>
            </tr>
          </xsl:for-each>
        </tbody>
      </table>
    </xsl:if>
  </xsl:template>

  <xsl:template name="break">
    <xsl:param name="text" select="."/>
    <xsl:choose>
      <xsl:when test="contains($text, '&#xa;')">
        <xsl:value-of select="translate(substring-before($text, '&#xa;'),' ','&#160;')"/>
        <br/>
        <xsl:call-template name="break">
          <xsl:with-param
            name="text"
            select="substring-after($text, '&#xa;')"
        />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:transform>
