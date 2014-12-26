######################################################################

title:: Generate Content

######################################################################

This SML document contains a generate block. The 'generate' statement tells an application to generate content based on the parsed data elements.

The 'generate' statement in this test file generates a problem listing. That is, a listing of all the problems in the document.

:grey: !!Top Level!!

:grey:

:grey:

:grey:

:grey:

---

:grey: ~~problem~~

:grey: ~~parts~~

:grey: ~~priority~~

:grey: ~~status~~

:grey: ~~traceability~~

---

: !!Parent Problem:!! This is the parent problem. ~~technical, problem-1, [ref:problem-1]~~

: 2

:yellow: routine

:grey: grey

:

---

:grey: !!Parent Problem!!

:grey:

:grey:

:grey:

:grey:

---

:grey: ~~problem~~

:grey: ~~parts~~

:grey: ~~priority~~

:grey: ~~status~~

:grey: ~~traceability~~

---

: !!First Child Problem:!! This is the first child problem. ~~technical, problem-2, [ref:problem-2]~~

: 0

:yellow: routine

:grey: grey

:

---

: !!Second Child Problem:!! This is the second child problem. ~~technical, problem-3, [ref:problem-3]~~

: 0

:yellow: routine

:grey: grey

:

---

#---------------------------------------------------------------------

>>>problem

title:: Parent Problem

id:: problem-1

type:: technical

description:: This is the parent problem.

<<<problem

#---------------------------------------------------------------------

>>>problem

title:: First Child Problem

id:: problem-2

type:: technical

parent:: problem-1

description:: This is the first child problem.

<<<problem

#---------------------------------------------------------------------

>>>problem

title:: Second Child Problem

id:: problem-3

type:: technical

parent:: problem-1

description:: This is the second child problem.

<<<problem

#---------------------------------------------------------------------
