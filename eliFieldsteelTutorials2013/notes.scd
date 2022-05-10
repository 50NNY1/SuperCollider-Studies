/*
_100522

##KEYBD SHORTCUTS
ctrl . = stop
shift enter = run one line
ctrl enter = run all code

##MATHS
all numbers have member functions, we can call .cubed, .squared etc to run simple arithmetic in shorthand.

##VARIABLES
variables must be declared before they are used e.g:

x = 3.cubed will return nil, as the variable cant be used prior to instantiation,
therefore we would do.

*/
var x;
x = 3.cubed
/*
global variables are prexied with ~
local variables must be created and used within the same (chunk?) of code execution, whereas global variables are much more fluid in their application and rules

##SCOPE
scope is created in most languages with {} in SC we use () (?not sure why)

##FUNCTIONS
{}
not entirely sure the difference of {} and () as of yet, as this doesn't seem to follow many of the same rules as over languages I have learnt, I should return to this.

in a function, perhaps we cant do this in ()
we can create arguments

for example
*/
z = {
arg freq = 440, amp = 1;
var sig;
sig = SinOsc.ar(freq) * amp;
}.play;
/*
we can now also run set commands on z to create the equivalent of presets for our synth
*/
z.set(\freq, 330, \amp, 0.5);
/*
will give us more modular control of our now created synth.

##Sound classes
all sound related classes i.e SinOSC and PlayBuf
all need to have specified their relevant member to construct

.ar
gives us 'in human range of hearing' frequency, and in general if we wish to hear sound this is what we should use

.kr
creates a control signal, we would use this for example in conjuction with the creation of an lfo within our project.

--LFO EXAMPLE:
*/
(
z = {
	arg noiseHz=20;
	var freq, sig;
	freq = LFNoise0.kr(noiseHz).range(200,1000); //we could also use .exprange here for exponential
	sig = SinOsc.ar(freq);
}.play;
)

z.set(\noiseHz, 1); //here we could use exprand(4, 64) to get random values
/*

##SYNTHDEF

*/
SynthDef.new(\test, {
	arg noiseHz=20;
	var freq, sig;
	freq = LFNoise0.kr(noiseHz).range(200,1000); //we could also use .exprange here for exponential
	sig = SinOsc.ar(freq);
	Out.ar(0,sig); //we have to specify output in our function here
}).add //we use add to send our def from the client to the server.
/*

essentially this has created a class,within the supercollider architecture which can be instantiated elsewhere in our code...
*/
x = Synth.new(\test); //if we had arguements for our synth we would declare them here!
/*

##UGENS
functions for sample by sample calculations of audio(?)

##ENVELOPES
*/
(
x ={
	var sig, env, freqEnv;
	freqEnv = Line.kr(500, 1, 0.5, doneAction:0);
	env = XLine.kr(1,0.01,1, doneAction:2); //Very simple to plot a ar envelope here, doneaction 2, means we destroy the synth instance after the envelope is done. done action 0 will leave it alone
	sig = Pulse.ar(freqEnv * env);
}.play;
)
/*
--custom envelopes
*/
Env.new([0, 1, 0.2, 0], [0.5, 1, 2], \exp).plot; //3rd arguement allows us to control curvature.
/*

##METERS
*/
s.meter;
/*

##MULTICHANNEL EXPRESSION
*/
x = {SinOsc.ar([300,500])}.play; //passing in an array of 2 frequencies for the sin osc tells the sc server to create two sinosc instances

x = {[SinOsc.ar(300), SinOsc.ar(500)]}.play; // we can also pass a function an array of ugens.

(
x = {
	var sig, amp;
	amp = SinOsc.kr([7, 40]);
	sig = SinOsc.ar([300,500]); //here supercollider figures out which one should be left and which right
	sig = sig * amp;
}.play;
)

/*
--DUP METHOD!!
this is a great shorthand in SC, essentially it returns an array of ur given number
*/
x = {SinOsc.ar(400.dup(2))}.play; //this is the quickest.
/*

