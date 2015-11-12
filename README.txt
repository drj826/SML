Semantic Manuscript Language (SML) is a plain text language that:

- is human readable

- minimizes markup

- enables you to automatically publish documentation using a
  `continuous integration' approach to documentation

- represents document structures like paragraphs, sections, lists,
  tables, figures, listings, cross references, preformatted text,
  attachments, source citations, glossary entries, index entries, and
  more

- represents common presentation elements like bold, italics, lines
  breaks, page breaks, superscript, subscript, font size, text
  justiication, and more

- enables you to modularize reusable document content into separate
  files via an `include' mechanism

- makes it easy to automatically generate document content

- enables you to capture and validate the meaning (i.e. the semantics)
  of document content pre-defined by you in an ontology

- represents related documents in libraries

The Perl code here enables you to:

- parse SML text into an object model (Parser.pm)

- reason about document content (Reasoner.pm)

- manage a collection of related documents (Library.pm)

- publish SML documents to a variety of renditions and styles
  (Publisher.pm)

I created SML because I wanted to create and maintain documentation
the same way I create and maintain code.  Furthermore, I wanted the
ability to pre-define and validate the semantics of my documents.

For instance, I wanted the publisher to warn me that a `test' is
invalid if it is associated with a valid `requirement' and a valid
`solution.'

I've been using early prototypes for years to manage thousands of
pages of documentation.  But I've never gotten around to sharing the
code with a wider community until now.

This project is very rough around the edges and is not yet
packaged for distribution.

  Don Johnson
  drj826@acm.org
