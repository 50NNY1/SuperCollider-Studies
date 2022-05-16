/*
##Randomisation

--quick note re: arrays
instead of creating an array like:
[1,2,3,4,5,6];
we can use the syntactical shortcut of doing
(1..6) to achieve the same thing

--randomisation on arrays
we can also use the .choose array member function to pick a random member of the array, this can be chained up with .do still.

##SCALES
sc provides a Scale class, constructors for such arrays come with a dot method
Scale.minor
Scale.major etc

which return scales in C, we can transpose this by calling

.degree + (semitones)

Scale.minor+61 for a c# minor scale just above middle c.

##ServerTree
when server is set to its default state, i.e with 'ctrl + .' the use of the server tree class allows to instantiate certain members to the server, saves us having to pass thru like 4 different lines of code before running our actual 'performance code' etc. i.e if we had a reverb global variable that would indeed have to be reinstantiated for performance.

*/