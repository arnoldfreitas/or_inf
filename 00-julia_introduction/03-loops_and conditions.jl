
# Range as an iterator
for i in 1:5
    println("The current iteration is $i")
end

myarr = [5,10,12]
# a common way to iterator an array is to use 1:length(x)

for i in 1:length(myarr) # length(myarr) returns 3 resulting basically in 1:3
    println("The current iteration is $i and value is $(myarr[i])")
end

emptyarray

# `eachindex` also returns an iterator and has the same results als 1:length(emptyarray)
for i in eachindex(emptyarray)
    println(i)
end

# we can just iterate over the values of an array
for x in emptyarray
    println("The current value is $x")
end

# another way is to `enumarate`
# it returns the position and the value as a tuple
for (position,value) in enumerate(emptyarray)
    println("The current iteration is $position and value is $value")
end

mat = [1 2; 5 6]

# in a multidimensional array the iterator works rowwise
for (position,value) in enumerate(mat)
    println("The current iteration is $position and value is $value")
end

# `zip` zips two (or more) equally long vectors together
# the result is a array of tuples (or pairs)
arr1 = ["a","b","c"]
arr2 = [1,2,3]
zip(arr1, arr2)

collect(zip(arr1, arr2)) # we need to call `collect` because zip returns an iterator that is not stored in memory yet

for (a1,a2) in zip(arr1, arr2)
    println("The first value $a1 comes from arr1 and the second value $a2 comes from arr2")
end


true, false

typeof(true), typeof(false)

1 == 1.0

2 != 2

!(2 == 2)

x = 2
mylist = [1,2,3,4]

# check if an element is in an array
x in mylist

x = 10
x in mylist

# initiate an array with booleans
fill(true, 3)

boolarray = [true, false, true, false]
# use a boolean array to subset another array
mylist[boolarray]

bitarray = [1,2,3,4] .>= 3
mylist[bitarray]
mylist[mylist .>= 3]

if true
    println("This is true")
end

if false
    println("This is not true")
end

x = 5

if x >= 1
    println("x is greater than 0")
elseif x == 0
    println("x is zero")
else
    println("x is smaller than 0")
end

# while loops
i = 10
let i=1
    while i<=5
        println(i)
        i += 1
    end
end

println(i)

while i>=1
    println(i)
    i -= 1
end

println(i)

# while loops
let i=1
    while true
        println(i)
        i += 1
        if i == 5
            break
        end
    end
end

x = -1

x >= 0 ? (y = "positive") : (y = "negative")
# this is equal to
#if x >= 0
#    y = "positive"
#else
#    y = "negative"
#end

y

x = 1

# && is an "and"
x > 0 && println("x is greater than zero")

x = -11

# || is an "or "
x <= 0 || println("x is greater than zero")
