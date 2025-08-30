# Automatic UI Generation Using Macros

A Swift macro package that provides the `@FormBuilder` macro for automatic, type-safe UI generation of SwiftUI forms based on your data model struct’s properties.



## Features

- **Automatic Form Generation:**  
  Annotate your SwiftUI view struct with `@FormBuilder` and automatically generate a complete `body` with properly bound SwiftUI controls for each property.
- **Type Inference:**  
  - `String` → `TextField`
  - `Bool` → `Toggle`
  - `Date` → `DatePicker`, etc.
- **Reduces Boilerplate:**  
  Focus on your data model, not repetitive form code.
- **Swift 5.9+ / Xcode 15+ Support:**  
  Built using Swift's macro system and SwiftSyntax.



## Usage

1. **Import the Macro Package:**

    ```
    import FormBuilderMacros
    ```

2. **Use the Macro in Your SwiftUI View:**

    ```
    @FormBuilder
    struct EditContact: View {
        @State var name: String
        @State var number: String
        @State var isFavourite: Bool
    }
    ```

    The macro automatically generates this form's body with a `TextField` and `Toggle` bound to the properties.



## References & Learning

- [Presentation - Automatic UI Generation Using Macros](https://gamma.app/docs/Automatic-UI-Generation-Using-Macros-7w6vbdl08leti3m)
- [Swift Macros Documentation](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/macros/)
- [SwiftSyntax GitHub](https://github.com/apple/swift-syntax)
- [WWDC: Write Swift Macros](https://developer.apple.com/videos/play/wwdc2023/10166/)

