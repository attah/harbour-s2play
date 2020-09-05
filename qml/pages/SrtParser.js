/* Copyright (c) 2010, 2011 Mozilla Foundation

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

/* Taken from popcorn.js, adapted for this application */

function parse(data) {

    var subs = [],
        i = 0,
        idx = 0,
        lines,
        time,
        text,
        endIdx,
        sub;

    // Here is where the magic happens
    // Split on line breaks
    lines = data.split( /(?:\r\n|\r|\n)/gm );
    endIdx = lastNonEmptyLine( lines ) + 1;

    var vtt = false;
    var i = 0;
    if(lines[i].indexOf("WEBVTT") != -1)
    {
        i++;
        vtt=true;
    }

    for(; i < endIdx; i++ ) {
        sub = {};
        text = [];

        i = nextNonEmptyLine( lines, i );
        if(!vtt)
        {
            sub.id = parseInt( lines[i++], 10 );
        }

        // Split on '-->' delimiter, trimming spaces as well
        time = lines[i++].split( /[\t ]*-->[\t ]*/ );

        sub.start = toSeconds( time[0] );

        // So as to trim positioning information from end
        idx = time[1].indexOf( " " );
        if ( idx !== -1) {
            time[1] = time[1].substr( 0, idx );
        }
        sub.end = toSeconds( time[1] );

        // Build single line of text from multi-line subtitle in file
        while ( i < endIdx && lines[i] ) {
            text.push( lines[i++] );
        }

        // Join into 1 line, SSA-style linebreaks
        // Strip out other SSA-style tags
        sub.text = text.join( "\\N" ).replace( /\{(\\[\w]+\(?([\w\d]+,?)+\)?)+\}/gi, "" );

//        // Escape HTML entities
//        sub.text = sub.text.replace( /</g, "&lt;" ).replace( />/g, "&gt;" );

//        // Unescape great than and less than when it makes a valid html tag of a supported style (font, b, u, s, i)
//        // Modified version of regex from Phil Haack's blog: http://haacked.com/archive/2004/10/25/usingregularexpressionstomatchhtml.aspx
//        // Later modified by kev: http://kevin.deldycke.com/2007/03/ultimate-regular-expression-for-html-tag-parsing-with-php/
//        sub.text = sub.text.replace( /&lt;(\/?(font|b|u|i|s))((\s+(\w|\w[\w\-]*\w)(\s*=\s*(?:\".*?\"|'.*?'|[^'\">\s]+))?)+\s*|\s*)(\/?)&gt;/gi, "<$1$3$7>" );

        // ...NO drop them like they're hot... weird tags afoot
        sub.text = sub.text.replace(/(<([^>]+)>)/ig,"");

        // finally, put back the linebreak(s)
        sub.text = sub.text.replace( /\\N/gi, "<br />" );

        subs.push( sub );
    }
    return subs;
}

// Simple function to convert HH:MM:SS,MMM or HH:MM:SS.MMM to SS.MMM
// Assume valid, returns 0 on error
function toSeconds( t_in ) {
    var t = t_in.split( ':' );

    try {
        var s = t[2].split( ',' );

        // Just in case a . is decimal seperator
        if ( s.length === 1 ) {
          s = t[2].split( '.' );
        }

        return parseFloat( t[0], 10 ) * 3600 + parseFloat( t[1], 10 ) * 60 + parseFloat( s[0], 10 ) + parseFloat( s[1], 10 ) / 1000;
    } catch ( e ) {
        return 0;
    }
}

function nextNonEmptyLine( linesArray, position ) {
    var idx = position;
    while ( !linesArray[idx] ) {
        idx++;
    }
    return idx;
}

function lastNonEmptyLine( linesArray ) {
    var idx = linesArray.length - 1;

    while ( idx >= 0 && !linesArray[idx] ) {
        idx--;
    }

    return idx;
}
