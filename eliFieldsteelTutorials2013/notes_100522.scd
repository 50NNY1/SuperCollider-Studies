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
(
z = {
arg freq = 440, amp = 1;
var sig;
sig = SinOsc.ar(freq!2) * amp;
}.play;
)
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
x = {SinOsc.ar(400.dup(2))}.play;
x = {SinOsc.ar(400!2)}.play; //also works
/*

##ITERATION
we've already looked a fairbit on iteration with dup, and how we create two synths with arrays
all arrays have member functions we can use for various iterative operations.
*/
(
[1,3,5,6,10,13].do{ //here we declare a function to run at each iteration. arg names are seemingly default ones that run in conjuction with array member functions.
	arg item, count;
	[count, item.squared].postln; //we can run .collect(_.squared) to automatically square & print these
}
)
/*
##Signal ROUTING
between different synthdefs we may wish to make our code/audioenvironment more modular and route in and out between different objects. to do this supercollider provides us with routing capable UGENS, which we should use within our synthdef.
*/
(
SynthDef.new(\blip, {
	arg out;
	var freq, trig, sig;
	freq = LFNoise0.kr(3).exprange(300,1200).round(300);
	sig = SinOsc.ar(freq) * 0.25;
	trig = Dust.kr(2);
	sig = sig * EnvGen.kr(Env.perc(0.01,0.2), trig);
	Out.ar(out, sig);
}).add;
SynthDef.new(\reverb, {
	arg in, out=0;
	var sig;
	sig = In.ar(in, 1);
	sig = FreeVerb.ar(sig, 0.5, 0.2, 0.9, 0.2)!2;
	Out.ar(out, sig);
}).add;
)

(
y = Synth.new(\reverb, [\in, 6]);
x = Synth.new(\blip, [\out, 6]);
)

//also abit safer, sc can handle bus sends numerically for us, and we should in good practice use this to avoid conflicts with hardware limitations
(
~reverbBus = Bus.audio(s, 1);
//order of execution is crucial, we must create the input signal before the output signal.
y = Synth.new(\reverb, [\in, ~reverbBus]);
x = Synth.new(\blip, [\out, ~reverbBus]);
)

(
~sourceGroup = Group.new;
~fxGroup = Group.after(~sourceGroup);

//use of groups allows us to failproof the order of execution by allocating necessary memory prior to code execution in which sound should be outputted.
y = Synth.new(\reverb, [\in, ~reverbBus], ~fxGroup);
x = Synth.new(\blip, [\out, ~reverbBus], ~sourceGrp);
)
/*
##GROUPS
groups allow us to safeproof from errors regarding order of execution, onwards of this we can use groups to affect parameters of all instances of a synthdef within the group.
*/
(
SynthDef.new(\groupTest, {
	arg freq = 440;
	var sig,env;
	env = EnvGen.kr(
		Env.perc(0.01,5, 1, -2),
		doneAction:2);
	sig = SinOsc.ar(freq!2);
	sig = sig * env;
	Out.ar(0, sig);
}).add;
)


~groupTestGrp = Group.new;
(
8.do{
	Synth.new(\groupTest, [\fund, 80], ~groupTestGrp);
}
)

//tada!
~groupTestGrp.set(\freq, 220);
/*
