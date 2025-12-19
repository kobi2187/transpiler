//! Comprehensive Rust Test File
//! Tests all major Rust language constructs

use std::fmt::{Display, Debug};
use std::ops::Add;

/// A simple Point struct
#[derive(Debug, Clone)]
pub struct Point {
    pub x: f64,
    pub y: f64,
}

/// Tuple struct
pub struct Color(pub u8, pub u8, pub u8);

/// Unit struct
pub struct Unit;

/// Enum with variants
#[derive(Debug, PartialEq)]
pub enum Option<T> {
    Some(T),
    None,
}

/// Enum with struct variants
pub enum Message {
    Quit,
    Move { x: i32, y: i32 },
    Write(String),
    ChangeColor(u8, u8, u8),
}

/// Trait definition
pub trait Drawable {
    fn draw(&self);
    fn bounds(&self) -> (f64, f64, f64, f64);
}

/// Generic trait with associated type
pub trait Iterator {
    type Item;
    fn next(&mut self) -> Option<Self::Item>;
}

/// Inherent impl block
impl Point {
    /// Associated function (constructor)
    pub fn new(x: f64, y: f64) -> Self {
        Point { x, y }
    }

    /// Associated const
    pub const ORIGIN: Point = Point { x: 0.0, y: 0.0 };

    /// Method with &self
    pub fn distance(&self) -> f64 {
        (self.x * self.x + self.y * self.y).sqrt()
    }

    /// Method with &mut self
    pub fn scale(&mut self, factor: f64) {
        self.x *= factor;
        self.y *= factor;
    }

    /// Method taking ownership
    pub fn into_tuple(self) -> (f64, f64) {
        (self.x, self.y)
    }
}

/// Trait implementation
impl Display for Point {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        write!(f, "({}, {})", self.x, self.y)
    }
}

/// Generic impl with bounds
impl<T: Display + Clone> Iterator for Vec<T> {
    type Item = T;

    fn next(&mut self) -> Option<T> {
        self.pop()
    }
}

/// Type alias
pub type Result<T> = std::result::Result<T, Box<dyn std::error::Error>>;

/// Const and static
pub const MAX_SIZE: usize = 100;
pub static mut COUNTER: i32 = 0;

/// Function with generics and where clause
pub fn print_all<T>(items: &[T])
where
    T: Display,
{
    for item in items {
        println!("{}", item);
    }
}

/// Async function
pub async fn fetch_data(url: &str) -> Result<String> {
    Ok(url.to_string())
}

/// Unsafe function
pub unsafe fn raw_ptr_deref(ptr: *const i32) -> i32 {
    *ptr
}

/// Function with lifetime
pub fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
    if x.len() > y.len() { x } else { y }
}

/// Expression examples
pub fn expressions() {
    // Literals
    let i = 42;
    let f = 3.14;
    let s = "hello";
    let b = true;

    // Arrays and slices
    let arr = [1, 2, 3, 4, 5];
    let slice = &arr[1..3];

    // Tuples
    let tup = (1, "hello", 3.14);
    let (a, b, c) = tup;

    // Struct literal
    let p = Point { x: 1.0, y: 2.0 };

    // Struct update syntax
    let p2 = Point { x: 5.0, ..p };

    // If-else
    let max = if a > 0 { a } else { 0 };

    // Match
    let opt: Option<i32> = Option::Some(5);
    match opt {
        Option::Some(n) if n > 10 => println!("Big: {}", n),
        Option::Some(n) => println!("Small: {}", n),
        Option::None => println!("None"),
    }

    // Loops
    loop {
        break;
    }

    let mut x = 0;
    while x < 10 {
        x += 1;
    }

    for i in 0..10 {
        println!("{}", i);
    }

    // Range expressions
    let r1 = 1..10;
    let r2 = 1..=10;
    let r3 = ..10;
    let r4 = 1..;

    // Closures
    let add = |x, y| x + y;
    let result = add(1, 2);

    // Method calls
    let dist = p.distance();

    // Question mark operator
    fn maybe_add() -> Result<i32> {
        let x = Some(1)?;
        Ok(x + 1)
    }

    // Async/await
    async fn async_example() {
        let data = fetch_data("http://example.com").await;
    }

    // Unsafe block
    unsafe {
        let p = &mut COUNTER;
        *p += 1;
    }

    // References
    let x = 5;
    let r = &x;
    let mr = &mut x.clone();

    // Raw pointers
    let raw_const: *const i32 = &x;
    let raw_mut: *mut i32 = &mut x.clone();

    // Raw address-of
    let addr = &raw const x;
    let addr_mut = &raw mut x.clone();

    // Type cast
    let f = 3.5;
    let i = f as i32;

    // Array repeat
    let zeros = [0; 100];

    // Try block (experimental)
    // let result: Result<i32> = try {
    //     let x = Some(1)?;
    //     x + 1
    // };
}

/// Pattern matching examples
pub fn patterns(opt: Option<i32>) {
    // If let
    if let Some(x) = opt {
        println!("{}", x);
    }

    // While let
    let mut stack = vec![1, 2, 3];
    while let Some(top) = stack.pop() {
        println!("{}", top);
    }

    // Match patterns
    match opt {
        Some(x @ 1..=5) => println!("small: {}", x),
        Some(x) if x > 10 => println!("big: {}", x),
        Some(_) => println!("other"),
        None => println!("none"),
    }

    // Destructuring
    let Point { x, y } = Point::new(1.0, 2.0);
    let (a, b, c) = (1, 2, 3);
}

/// Module
pub mod inner {
    pub fn helper() -> i32 {
        42
    }

    pub(super) fn parent_visible() {}
    pub(crate) fn crate_visible() {}
}

/// Macro invocation
macro_rules! say_hello {
    () => {
        println!("Hello!");
    };
}

/// Union (unsafe)
#[repr(C)]
pub union Data {
    pub i: i32,
    pub f: f32,
}

/// Extern block
extern "C" {
    fn c_function(x: i32) -> i32;
    static C_GLOBAL: i32;
}

/// Main function
fn main() {
    let p = Point::new(3.0, 4.0);
    println!("Distance: {}", p.distance());

    say_hello!();

    expressions();
    patterns(Option::Some(5));
}
