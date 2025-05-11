# Project Coding Standards

- NEVER reference `external/godot_docs` in the code or in prompts, unless actively included in the prompt.

## GDScript Coding Standards

- ALWAYS use SPACES instead of TABS.
- ALWAYS use 4 spaces for indentation.
- ALWAYS use static typing (explicit type annotations).
- ALWAYS denote private variables using an `_`
- ALWAYS use `self.` when referencing member variables, unless they start with `_` or are static
- ALWAYS define class attributes with type annotations at the top of the class

- ALWAYS favour simplicity.

## Comment Writing Standards

- Use MINIMAL or NO comments, unless stated oterwise.
- Use # TODO(username): format for todos with a brief explanation.
- Add SMALL comments ONLY for complex logic or non-obvious behavior.

<!-- ## Code Organization

- ONLY USE REGIONS WHEN I TELL YOU TO.
- ALWAYS use code regions to organize scripts into logical sections.
- Use `#region Name` to start a region and `#endregion` to end it.
- Organize code with the following standard region structure, ALWAYS following this order:
  1. `#region Signals`: Signal declarations
  2. `#region Properties`: Exported and public properties
  3. `#region Variables`: Private member variables
  4. `#region Node Lifecycle`: Core methods (\_ready, \_process, etc.)
  5. `#region API`: Public methods
  6. `#region Callbacks`: Event handlers
  7. Add additional regions for specific functionality as needed -->
