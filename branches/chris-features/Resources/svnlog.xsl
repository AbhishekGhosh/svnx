<?xml version="1.0"?>
<!--
  An XML transformation style sheet for converting the Subversion log listing to xhtml.
-->
<xsl:stylesheet version='1.0'
                xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
                xmlns:date='http://exslt.org/dates-and-times'
                xmlns:str='http://exslt.org/strings'>

  <xsl:param name='file' />
  <xsl:param name='revision' />
  <xsl:param name='base' />

  <xsl:output method='html'
              encoding='UTF-8'
              omit-xml-declaration='no'
              doctype-public='-//W3C//DTD XHTML 1.0 Strict//EN'
              doctype-system='http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd'
              indent='yes'/>

  <xsl:template match='*' />

  <xsl:template match='log'>
    <!--<html xml:space='preserve' xmlns='http://www.w3.org/1999/xhtml'>-->
    <html xmlns='http://www.w3.org/1999/xhtml'>
      <head>
        <xsl:if test='string-length($file) != 0'>
          <title>
            <xsl:text>Log for: </xsl:text><xsl:value-of select='concat($file, " r", $revision)'/>
          </title>
        </xsl:if>
        <xsl:if test='string-length($base) != 0'>
          <base><xsl:attribute name='href'>file://<xsl:value-of select='$base'/>/</xsl:attribute></base>
        </xsl:if>
        <link rel='stylesheet' type='text/css' href='svnlog.css'/>
      </head>
      <!--<body xml:space='preserve'>-->
      <body>
        <table class='svn'>
          <xsl:apply-templates/>
        </table>
      </body>
    </html>
  </xsl:template>

  <xsl:template match='logentry'>
    <tbody class='entry'>
      <tr>
        <td class='rev'>r<xsl:value-of select='@revision'/></td>
        <td class='author'><xsl:value-of select='author'/></td>
        <!--<td class='date'><div class='date'><xsl:value-of select='date'/></div></td>-->
        <td class='date'><xsl:value-of select='concat(substring-before(date, "T"),
                                                      "&#xA0;&#xA0;",
                                                      substring-before(substring-after(date, "T"),
                                                                       "."))'/></td>
      </tr>
      <tr>
        <!--<td class='msg' colspan='3'><xsl:value-of select='msg'/></td>-->
        <td class='msg' colspan='3'>
        <xsl:for-each select='str:split(msg, "&#x0A;")'>
          <xsl:if test='position() != 1'><br/></xsl:if>
          <xsl:choose>
            <xsl:when test='starts-with(text(), " ")'><xsl:value-of select='concat("&#xA0;", substring-after(text(), " "))'/></xsl:when>
            <xsl:otherwise><xsl:value-of select='text()'/></xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
        </td>
      </tr>
      <xsl:apply-templates select='paths/path'/>
    </tbody>
  </xsl:template>

  <xsl:template match='paths/path'>
      <xsl:choose>
        <xsl:when test='string-length(@copyfrom-rev) != 0'>
          <xsl:call-template name='path1'>
           	<xsl:with-param name='path' select='concat(text(), "&#xA0;&#xA0;&#x21E6;&#xA0;&#xA0;", @copyfrom-rev, ":&#xA0;", @copyfrom-path)'/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name='path1'>
            <xsl:with-param name='path' select='text()'/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
  </xsl:template>

  <xsl:template name='path1'>
    <tr>
      <td class='act'><xsl:value-of select='@action'/></td>
      <td class='path' colspan='2'><xsl:value-of select='$path'/></td>
    </tr>
  </xsl:template>

</xsl:stylesheet>
