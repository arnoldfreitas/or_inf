
# we can define our own functions
# by using the keyword `function`
function mytestfunction() # this function does not have any input
    println("This is just a test.")
end

# calling it 
mytestfunction()

function do_stuff(n) # this function has an input argument
    x = 0
    for i in 1:n # this n is the input to our function
        x += i # this is equal to x = i + x
    end
    return x # and it returns something
end

do_stuff(5), do_stuff(2), do_stuff(10)

# a function can have more than one arugment
function do_stuff(n, start) 
    x = start
    for i in 1:n 
        x += i 
    end
    return x 
end

do_stuff(3,0), do_stuff(3,-10)

function do_stuff(n, start=0; doubleit=false) # we can also specify keyword arguments
    # here we set a default value for the input argument "doubleit"
    # so if you do not set it to true it will be false by default
    x = start
    for i in 1:n
        x += i
    end
    
    if doubleit # if the keyword argument is true
        return 2*x # in that case double our output
    else
        return x # if the keyword argument is false then just return x
    end
end

do_stuff(2, doubleit=false), do_stuff(2, doubleit=true), do_stuff(2, -5, doubleit=false)

function do_stuff(n::Float64; doubleit=false) #we create a version for our function where n is a float number
    # we need a integer number for our for-loop
    # if the input is a float we want that number to be rounded
    x = 0
    n_rounded = round(n) # the `round` function does exactly that 
    for i in 1:n_rounded
        x += i
    end
    
    if doubleit 
        return 2*x 
    else
        return x 
    end
end

do_stuff(2.4, doubleit=false), do_stuff(2.6, doubleit=true)

#if our function is really short we can neglect the function keyword
mytestfunction(x) = println("The input x is not specified!") 
mytestfunction(x::Int64) = println("x is an integer!") # the :: behind the variable indicates that a type definition follows
mytestfunction(x::String) = println("x is an string!")
mytestfunction(x::Float64) = println("x is an float!")

mytestfunction(1)

mytestfunction(1.5)

mytestfunction("a")

# now we use a complex number for which we did not define a specilized method
mytestfunction(1 + 2im)

# it says that println is a generic function with 3 methods
sqrt

# here we see that sqrt is defined for a lot of different number types but also to some arrays/matrices
methods(sqrt)

# now you might understand what this error message means
# a "MethodError" always means that the function does not accept this input
sum(nothing)

# also our basic math operations are just functions provided by the Julia Base library
# the plus function for example has 166 different methods
+ 

# this defines an anonymous function
x -> x > 0 #so this is not very helpful yet

# we already used that in an earlier example where we wanted to filter an a vector
arr = [-2,-1,0,2,4]

filter(x-> x > 0, arr)

# ?filter

# the alternative would be to write a function and use that as an argument
filter_function(x) = x > 0 # if we only use that function one time it is better to just use an anonymous function
filter(filter_function, arr)

# `map` applies a function to a collection of elements (e.g. an array) elementwise
arr = [1,2,3]
# we already had that example earlier
map(sqrt, arr) # is equal to sqrt.(arr)

# this is especially useful in combination with an anonymous function
map(x-> x^2 - 1, arr)

# this is 
map(sqrt, arr)
# equal to
map(x-> sqrt(x), arr)


# if the operations become too complex to fit in one line we can use the do block syntax

map(arr) do x # instead of define the function in the x-> x style we can handle it like a regular function
    if x > 0
        return sqrt(x)
    elseif x == 0
        return 0
    else
        return sqrt(-x)
    end
end

# we want to measure the time that has passed during a calculation
start = time() # `time()` returns the current time
sleep(1) # the functions just pauses our execution for 1 sec
time() - start # the difference should be the time that has passed by between the start and stop

# fortunately there is a macro that does exactly that for us
@elapsed sleep(1) # a macro always starts with an `@`

@elapsed begin # if our code does not fit in one line we can use the keyword `begin` with an `end`
    sleep(1)
    # here we could do more complex operations
end

mutable struct Bankaccount # mutable means that the fields can be manipulated
    id::Int
    balance::Float64
end

current_balance(b::Bankaccount) = b.balance
id(b::Bankaccount) = b.id


function withdraw!(b::Bankaccount, amount::Number)
    b.balance -= amount
    println("$amount € has been withdrawn from $(b.id). The new balance is $(b.balance)")
end


function deposit!(b::Bankaccount, amount::Number)
    b.balance += amount
    println("$amount € has been deposited to $(b.id). The new balance is $(b.balance)")
end

b1 = Bankaccount(123, 0)
b2 = Bankaccount(789, 500)
b1, b2

deposit!(b1, 100)

withdraw!(b2, 200)

# before we can define a customized method on base functions, we need to import them
import Base: +, -

+(b::Bankaccount, amount::Number) = b.balance + amount

-(b::Bankaccount, amount::Number) = b.balance - amount

b1 + 1000

current_balance(b1)

b2 - 100

function transfer!(from::Bankaccount, to::Bankaccount, amount::Number)
    from.balance = from - amount #we could also use our functions `withdraw!` and `deposit` here
    to.balance = to + amount
    println("$amount € has been transfered from id $(from.id) to id $(to.id).")
end

transfer!(b2, b1, 100)

+(b::Bankaccount, bb::Bankaccount) = b.balance + bb.balance

b1, b2, b1 + b2

methodswith(Bankaccount)

sum([b1,b2])
