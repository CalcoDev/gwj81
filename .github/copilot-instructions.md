# Project Coding Standards

- NEVER reference `external/godot_docs` in the code or in prompts, unless actively included in the prompt.

## GDScript Coding Standards

- ALWAYS use static typing (explicit type annotations).
- ALWAYS denote private variables using an `_`
- ALWAYS use `self.` when referencing member variables, unless they start with `_` or are static
- ALWAYS define class attributes with type annotations at the top of the class

- ALWAYS favour simplicity.

## Comment Writing Standards

- Use MINIMAL or NO comments, unless stated oterwise.
- Use # TODO(username): format for todos with a brief explanation.
- Add SMALL comments ONLY for complex logic or non-obvious behavior.
