---
title: "Upgrading from Rust 0.5 to 0.6"
date: 2013-04-07 17:39
---

Here are some error messages that I got when updating [Rust for
Rubyists](http://www.rustforrubyists.com/) from Rust 0.5 to the new 0.6, and
how to fix those errors.

--------------

Error:

```
rust.rs:1:4: 1:16 error: unresolved name
rust.rs:1 use task::spawn;
              ^~~~~~~~~~~~
rust.rs:1:4: 1:16 error: failed to resolve import: task::spawn
rust.rs:1 use task::spawn;
              ^~~~~~~~~~~~
error: failed to resolve imports
error: aborting due to 3 previous errors
make: *** [all] Error 101
```

or

```
rust.rs:1:4: 1:16 error: unresolved name
rust.rs:1 use io::println;
              ^~~~~~~~~~~~
rust.rs:1:4: 1:16 error: failed to resolve import: io::println
rust.rs:1 use io::println;
              ^~~~~~~~~~~~
error: failed to resolve imports
error: aborting due to 3 previous errors
make: *** [all] Error 101
```

The fix:

Imports are now more explicit, so you can't just import things from `core`
without specifying that you want to any more.

```diff
+ use core::task::spawn;
- use task::spawn;
```

or

```diff
+ use core::io::println;
- use io::println;
```

etc.

--------------

Error:

```
error: main function not found
error: aborting due to previous error
```

The fix:

--------------

When I used to write TDD'd Rust, I wouldn't often write a `main` function
until I had done a bunch of tests. This was okay, but now, you need one.

```diff
+ fn main() {
+ }
```

--------------

Error:

```
rustc rust.rs --test
rust.rs:5:2: 5:6 error: unresolved name: `fail`.
rust.rs:5   fail;
            ^~~~
error: aborting due to previous error
make: *** [build_test] Error 101
```

The fix:

`fail` was turned into a macro. It now needs to be passed an owned pointer
to a string:

```diff
- fail;
+ fail!(~"Fail!");
```

--------------

Error:

```
rust.rs:5:18: 5:26 error: unresolved name: `int::str`.
rust.rs:5           println(int::str(num))
                            ^~~~~~~~
error: aborting due to previous error
make: *** [build] Error 101
```

The fix:

`int::str` is now `int::to_str`

```diff
- int::str
+ int::to_str
```

--------------

Error:

```
rust.rs:5:12: 5:18 error: cannot determine a type for this local variable: unconstrained type
rust.rs:5     let mut answer;
                      ^~~~~~
error: aborting due to previous error
make: *** [build] Error 101
```

The fix:

You have to tell it what kind it is. In my case, it was a string:

```diff
- let mut answer;
+ let mut answer = "";
```

--------------

Error:

```
rust.rs:3:11: 3:21 error: expected `;` or `}` after expression but found `is_fifteen`
rust.rs:3     assert is_fifteen(15)
                     ^~~~~~~~~~
make: *** [build_test] Error 101
```

The fix:

This happens because `assert` is now a macro.

```diff
- assert is_fifteen(15)
+ assert!(is_fifteen(15))
```

--------------

Error:

```
rustc rust.rs
rust.rs:11:10: 11:24 error: the type of this value must be known in this context
rust.rs:11 chan.send(10);
^~~~~~~~~~~~~~
error: aborting due to previous error
make: *** [build] Error 101
```

The fix:

Rust 0.6 got rid of 'capture clauses.' Don't worry about it.

```diff
- do spawn |chan| {
+ do spawn {
```

--------------

Error:

```
rust.rs:10:17: 10:21 error: expected `,` but found `chan`
rust.rs:10   do spawn |move chan| {
                            ^~~~
make: *** [build] Error 101
```

The fix:

`move` is gone. Just remove it.

```diff
- do spawn |move chan| {
+ do spawn |chan| {
```

Note that this diff wouldn't actually make it work, you'd still run into the
issue above. But it gets rid of the `move` error.

--------------

Error:

```
rust.rs:13:6: 13:12 error: unexpected token: `static`
rust.rs:13       static fn count() {
                 ^~~~~~
make: *** [build] Error 101
```

The fix:

`static` was removed. Any method that doesn't take `self` is static.

```diff
- static fn count() {
+ fn count() {
```

--------------

Error:

```
rust.rs:11:30: 11:37 error: obsolete syntax: colon-separated impl syntax
```

The fix:

As it says, the colon syntax is gone. Replace it with `for`:

```
- impl float: Num
+ impl Num for float
```

--------------

Error:

```
rust.rs:5:18: 5:22 error: use of undeclared type name `self`
rust.rs:5       fn new() -> self;
                            ^~~~
```

The fix:

This happens when you're making a trait, and you want the implementations to
return whatever type they are. The type name is now `Self`:

```diff
- fn new() -> self;
+ fn new() -> Self;
```

--------------

I hope you found that informative! Happy hacking!
