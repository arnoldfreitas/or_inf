# a comment

#?

2+2

x1 = 5
x2 = 2

#assigns the result of x1 + x2 to the variable "result"
result = x1 + x2

### Basic math operations ###

# 5 * 2
x1 * x2

# 5 / 2
x1 / x2

# 5^2
x1^x2

# 5 + 1 * 2
x1 + 1 * x2

# (5 + 1) * 2
(x1 + 1) * x2

# latex signs are supported
# y\_1 and then press tab to archiv the subscript
y₁ = 1

# you cannot assign a value to number
# not valid
1 = y₁

y₂ = 4

# other useful math operations are available as functions
# x²
sqrt(x1)

# "println" prints a string to the console
# you can mix strings with with numbers

println("This is a number:", 4)
println("The sine of y₂ is: ", sin(y₂))
println("The cosine of y₂ is: ", cos(y₂))

#?typeof # types of objects can be asked with `typeof`

# every in Julia has a type
# for now this not that important since the necessary
# conversions are done under the hood
# however, for a deeper understanding later on you
# should that in mind
typeof(1)
typeof(1.0)
typeof("this is a string")

# when calculating you do not need to take of converting
x = 1 + 1.0

println(
    "The result of 1 + 1.0 is ",
    x,
    " and has the type of ",
    typeof(x)
)

# you can force conversion manually
# this rarely necessary though
x_int = convert(Int64, x)
typeof(x_int)

acomplexnumber = 1+2im
typeof(acomplexnumber)
acomplexnumber + 1+1im

# we probably will not need them but they do exist
# BigFloat and BigInt
BigFloat(5.1), BigInt(5)

# Julia's type system has a tree structure
# "Int64" is a subtype of the super type "Integer"
# we can ask if a type is a subtype
Int64 <: Integer
Float64 <: Integer
Float64 <: Number
Complex{Int64} <: Number, Complex{Int64} <: Real


### Basic operations for strings ###

mystring = "This is a string"
typeof(mystring)

part1 = "This is the start of a sentrence "
part2 = "and this the end."

# strings can be concatenated with *
part1*part2
merged_string = string(part1, part2)

# split a string based on a character or a string
split(merged_string, " ")

# replace a character or a string with another one
new_string = replace(merged_string, " " => "_")

# strings can be interpolated with variables
myresult = 5

"The result of my fancy calculation is $myresult"
"The square root of 4 is $(sqrt(4))"

# a Julia specific type is a "Symbol"
# basically they are similiar to strings
mysymbol = :a
typeof(mysymbol)

# spaces are not supported
# :this is a sentence

#a symbol can be converted to a string
string(mysymbol)

# we can use a string to create Symbols
Symbol("mystring")