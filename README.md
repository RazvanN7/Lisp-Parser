Lisp Parser Implementation

The parser is implemented using [the D programming language](https://dlang.org/).
D supports builtin unittests, so tests are embedded directly in the implementation.

To compile and run tests simple run:

```
make unittest
```

To build the project and run it on lisp files:

```
make lisp_parser
./lisp_parser code.lisp
```

The parser currently outputs minimal errors, however, it should accept the majority of valid code.
Improvements will be added soon.

TODO:
- add better error messages that include location
- add comments (comments are not supported currently)
- double check what atoms are accepted (is `1sd` a valid atom?)
- add more complex tests
- beautify code
- optimize code
