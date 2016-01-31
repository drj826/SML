# Purpose

I created the Semantic Manuscript Language (SML) because I wanted to
create and maintain documentation the same way I create and maintain
software (agile, in teams, continuous integration, automatically
tested, etc.).  I wanted a "compiler" to mercilessly throw errors
found in my documents.  I also wanted to validate the *meaning* of
document content against my own ontology (like a semantic schema); the
application warns me when I say something that doesn't make sense.

# Description

Semantic Manuscript Language (SML) is a plain text language that:

- is human readable

- enables you to capture and validate the meaning (i.e. the semantics)
  of document content pre-defined by you in an ontology

- minimizes markup

- enables you to build a library of related documents

- enables you to automatically publish documentation using a
  "[continuous
  integration](https://en.wikipedia.org/wiki/Continuous_integration)"
  approach to documentation

- represents document structures like paragraphs, sections, lists,
  tables, figures, listings, cross references, preformatted text,
  attachments, source citations, glossary entries, index entries, and
  more

- represents common presentation elements like bold, italics, lines
  breaks, page breaks, superscript, subscript, font size, text
  justiication, and more

- enables you to modularize reusable document content into separate
  files via an "include" mechanism

- makes it easy to automatically generate document content

# Functionality

The Perl code here enables you to:

- (Parser.pm) parse SML text into an object model

- (Reasoner.pm) reason about document content

- (Library.pm) manage a collection of related documents

- (Publisher.pm) publish SML documents to a variety of renditions and
  styles

Think of the SML code as a "compiler" for documentation containing
rich semantics. For instance, I wanted this document "compiler" to
throw an error if a "test" is not associated with a "requirement" and
a "solution."  Or, throw an error when I try to do something silly
like make a "bicycle" part of a "person."

# Stay Tuned

I've been using versions of this software for years to manage
thousands of pages of documentation.  But I've never gotten around to
sharing the code with a wider community until now.

This project is very rough around the edges and is not yet
packaged for distribution.

  Don Johnson
  drj826@acm.org
