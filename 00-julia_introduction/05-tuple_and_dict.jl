
mytuple = (1,2,3)

Tuple([1,2,3])

# manipulating the fields of tuple does not work
#mytuple[1] = 5

typeof(mytuple)

length(mytuple)

namedtuple = (a=5, b=4)

namedtuple.a

namedtuple[1]

namedtuple[:a]

namedtuple.c

mydict = Dict("key1" => 3, "key2" => 1, "key3" => 0)

mydict["key2"]

# this does not work
mydict[1]

# new key value pairs can be added
mydict["newkey"] = 10
mydict

#another way of adding new entries
push!(mydict, "key4" => 1)

# if you do not know if a certain key exists you can use the haskey function

haskey(mydict, "key1"), haskey(mydict, "key9")

# if a key does not exist and you want to use a default value instead you can use the get function
get(mydict, "key1", 0), get(mydict, "key9", -1)

# to check if a specific key value pairs exists you can use the `in` function

in(("key1" => 2), mydict) # this is false because our key value pair is `"key1" => 3`

# all keys and values can be collected using the `keys` and `values` function
keys(mydict)
values(mydict)

# with `delete!` keys can be deleted from the dictionary
delete!(mydict, "newkey")

# we can also iterate over a dictionary

for (key,value) in mydict
    println("The value of key $key is $value")
end

# create a list
mylist = [x for x in 1:10]

# also functions can be applied
[sqrt(x) for x in 1:10]

# also if statements are allowed
[sqrt(x) for x in 1:10 if isodd(x)] # `isodd` returns true if x is a odd number e.g. 1,3,5,7,...

# we can also use short circuit evaluations
# this returns 0 if the number is odd otherwise returns the sqrt of x
[isodd(x) ? 0 : sqrt(x) for x in 1:10]

# we can also use it to construct a dictionary
Dict("$i" => x for (i,x) in enumerate(1:10))

# function is also a type
typeof(println)

# with the `()` at the end of a function name you call the function meaning that the function is executed
println("test")
