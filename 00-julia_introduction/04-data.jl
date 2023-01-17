
# `rand` create an array with random values between 0 and 1
longarray = rand(100)

# if we want to view a specific part of that array we can use ranges
longarray[1:5]

# view the last 3 elements
longarray[end-2:end]

# show every 20th item
longarray[1:20:end]

# remember strings also behave like arrays when it comes to indexing
abc = "This is a sentence"
abc[6]

abc[1:2:end]

# when we index an array we obtaint a view of the original array meaning that we do not get a copy of the original array
# therefore, manipulating values will result in a manipulation of the array itself
longarray[end-1:end] = [-10, -10]

# note that the last two items are now changed to -10
# if you do not want that behaviour you have to use `copy` like in the example earlier
longarray

# of course you can also use regular arrays to subset other arrays
longarray[[1,2,5]]


sum([1,1,1])

mat

sum(mat)

sum(mat, dims=1)

sum(mat, dims=2)

prod([1,2,3]) # works the same way as `sum`

using Statistics # the mean function is not loaded by default, we need to load "Statistics" package
mean([1,2,1,2]) # mean also accepts the "dim" keyword

myvector = [2, 1]

# so in that case it is not clear what we want to do
# possible scenarios are `[1, 1] + myvector` or `[1, 0] + myvector` ?
#1 + myvector

# the dot indicates that the addition shoule be performed elementwise
1 .+ myvector #this is equal to `[1, 1,] + myvector`

mystring = "This sentence has some word"
splitted_string = split(mystring, " ") # returns an array with 5 strings

# the print function prints the arrays (despite the fact that is contains strings)
println(splitted_string)

# however, if we apply the `println` function to each element inside the array
# it should print each element in a single line
println.(splitted_string)

myarray = [5,10,15]

#example 1
myresult = Float64[] # init empty array which contains the type `Float64`
for x in myarray # iterate over each element
    y = sqrt(x) # apply the square root
    push!(myresult, y) # push the result of the calcution to our array with the results
end
myresult

#example 2
sqrt.(myarray) # a shorter (and faster) way is to use the dot sytax

# example 3
# just to show that there are plenty of ways you could approach such a problem
map(sqrt, myarray) # we will talk about the `map` function later

# an instance of `missing` (lower case)
missing

# the type "Missing" (with capital M) like we had the type "Float64" or "Int64" earlier
typeof(missing)

# There is also a type called `Nothing`
# in contrast to Missing, Nothing is not a data type
typeof(nothing)

# this works because `sum` can handle the Missing type and recognizes it as something "number like"
missarray = [1, missing, 1]
sum(missarray) #however, the result is still `missing` because something unkown plus a number has also an unkown result 

# this does not work since `nothing` is not a data type
nothingarray = [1, nothing, 1]
sum(nothingarray)


# u can use `skipmissing` to solve the problem
sum(skipmissing(missarray))

# we could use replace in order to treat `missing`like a 0 (which depends on the context of our data)
# if a function ends with ! it means that the first argument of the function is manipulated in place
replace!(missarray, missing => 0) # remember `!` means the value will be changed in place
missarray
sum(missarray) # now the sum is a number
