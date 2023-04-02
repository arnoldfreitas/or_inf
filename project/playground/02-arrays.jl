### Arrays ###
# a vector is a one dimensional array
myvector = [1,2,3]

typeof(myvector)

# a two dimensional array is a matrix
mymatrix = [1 2 3; 4 5 6]

another_matrix = [6 5 4
                  3 2 1]

# in order to perform a matrix multiplication the dimensions need to fit
# mymatrix * another_matrix

# a matrix can be transposed using `'`
another_matrix'

# now it works
mymatrix * another_matrix'

# why does this not work? we will adress this in the section "Broadcasting"
#[1,2] * [1 1; 1 1]

# init a 3x3 matrix with zeros
zeros(3,3)

myemptyarray = zeros(Int, 3,3)

ones(Int, 3,3)

fill(5, 2,3)

# here we already initialized an array with zeros as default value
# with `fill!` we manipulate (or overwrite) these existing values inside our contrainer (which is an array here)
fill!(myemptyarray, -1)
# myemptyarray = fill(myemptyarray, -1)

# so if we look at our array
myemptyarray

# another constructor which create an array of the same size but without any meaningful values
similar(myemptyarray)

# ask for the dimension of an array
ndims(myemptyarray)

# get the size of the respective dimensions
size(myemptyarray)

# the number of elements inside a container (despite their dimension)
length(myemptyarray)

# length can also be applied to other types. For example, strings can also have a length.
length("Three") # obviously this counts the number of letters not the meaning of the word

myemptyarray

# elements can be access by their index
myemptyarray[1,1]

# single elements can also be manipulated
myemptyarray[1,1] = 0

myemptyarray

# if you link container types to a variable, be aware that this is not a copy but just a pointer to the same object!
a = [1,2,3]
b = a

# if we change a value of that object (here an array)
a[1] = 0
a

# the changed value is also present when we call `b` because `a` and `b` actually point to the same object in the memory.
b

rowa = [1 2 3]
rowb = [1 ,2, 3]
rowc = [1; 2; 3]
rowd = [1, 2, 3]'

# if that is not intendend you can just use `copy` to create really copy the array instead of just creating a link.
a = [1,2,3]
b = copy(a)

a[1] = 0
# now `b` is unchanged
b

# if you want to last element of an array you can use the keyword `end`
a[end]

# from there you can also go backwards
a[end-1]

# init an empty array 
emptyarray = []

# since the first position does not exist yet, we cannot manipulate it
#emptyarray[1] = 1

# with `push!` we can add a new element to the array at the last position
push!(emptyarray, 1) # note the `!` here, we change the content of our array and do not create a new object!
push!(emptyarray, -1)
emptyarray

emptyarray[1] = 0 # now we can changed the existing fields
emptyarray

# to append another array you have to use `append!` instead of `push!`
append!(emptyarray, [1,2,3])

# deletes the first item
popfirst!(emptyarray)
emptyarray

# inserts a new element at the first position
pushfirst!(emptyarray, 0)

emptyarray

# unfortunately this does not work
# deleteat!(emptyarray, end-1)

#but we can obtain the length to calculate the position
deleteat!(emptyarray, length(emptyarray)-1)

# note there is not `!` so this is not done in place but returns a copy (`sort!` also exists though)
sorted_emptyarray = sort(emptyarray)

sorted_emptyarray, emptyarray

sort(emptyarray, rev=true) #reverse sort

maximum(emptyarray) # returns the maximum of the values

findmax(emptyarray) # returns maximum of the values and the position

# finds all positions in an array where a condition applies
# what `x-> x <= 0` is we will discuss later, for now it is important that the condition is x <= 0
findall(x-> x <= 0, emptyarray)

# same as findall but only return the first position where that condition was true
# while findall returns always an array this function return a integer which might be useful in some cases
findfirst(x-> x <= 0, emptyarray)

# filters the array based on a condition and returns an array with the values that satisfied the condition
filter(x-> x >= 0, emptyarray)

arr1 = [5,4,3]
arr2 = [2, 1]
# if you want to concatenate two (or more) vectors
vcat(arr1, arr2) #vertical

# horizontal concat only works if the length is equal
#hcat(arr1, arr2)

push!(arr2, 0) # we expand the shorter one and now it should work
hcat(arr1, arr2)

# there are many applications where you want to store objects in an array
["a", "c", "asdf"]

# we can also mix different types
[1, "a", 6.8]

# arrays can also contain other arrays
["t", [1,2,3], 99]

# we can create ranges with the :
myrange = 1:10

typeof(myrange)

# as previously mentioned the values are not stored in memory.
# Sometimes we want to convert a Range into an array then we use `collect`
collect(1:10)

# you can create a range with this syntax `start:stop` which basically `start:1:stop` meaning the step size is 1
# if you want to have another step size or direction you can do `start:step:stop`
collect(1:2:10)

# go backwards
collect(10:-1:1)

# also fractions are allowed
collect(1:0.5:5)