/*
##Buffers
function as we would expect
*/
~buf0 = Buffer.read(s,"E:/recordings/soundwalk 130422/000318_0040.wav");
~buf0.play;
~buf0.zero; //clears buffer but doesnt remove buffer allocation.
~buf0.free; //removes all traces of buffer.
Buffer.freeAll; //removes all traces of all buffers.
/*
--Array of Buffers
a very powerful tool SC grants us is the power to load multiple buffers at once and store them all within an array
*/
~sounds = Array.new;
~folder = PathName.new("E:/recordings/soundwalk 130422/");
(
~folder.entries.do({
	arg path;
	~sounds = ~sounds.add(Buffer.read(s, path.fullPath));
});
)
~sounds[0].play;
/*
note if the buffer sample rate is different to the server sample rate, the playback rate will change. to fix this we should multiply our playback rate by the output of BufRateScale.kr.

we can also control our playback with a phasor, start at 0 end at BufRateScale.kr(buf)*rate
we then use BufRd.ar(2, buf, phasor) for our signal.

##MIDI
midi routing seems simple enough.
MIDIClient.init;
MIDIIn.connectAll;
MIDIDef.noteOn (\noteontest, {"KeyDown.postln"}); simple enough right, mididef has listeners already built for everything we want

all mididef listener functions pass our defined function multiple arguements

for example, MIDIdef.noteOn returns arg vel, nn, chan, src (nn is note number, chan is midi channel)

##EVENTS/Patterns
Pbind, a class used to create sequences, used in conjunction with subclasses like Pseq to create sequences, lots of predefined arguements exist here, i.e \instrument, where we would plug in a synthdef, this handles synth instantiation so no need for Synth.new, we have \dur for our sequencing, this defines the length of each step (on and off times). \freq for pitches, we can also use \midinote as this is for frequencies and will automatically be plugged into the synth instantiation to get pitches

--in conjuction with buffers,
we can do some pretty sweet idm-y drums, we store Pathnames as keys in a dictionary.

create a synthdef which plays a buffer, buffer should be an arguement here,
and in a pbind we can set \dur to a random member of this dictionary (note: key must be specified for this to work as expected)

also ! in patterns we can use probability weighting with Pwrand.
*/
Pwrand([sound1, sound2, sound3], [0.8, 0.2, 0.3].normalizeSum); //normalize sum rounds all these to add up to 1.
[0.8, 0.2, 0.3].sum
a = [0.8,0.2,0.3].normalizeSum
a.sum
/*
we can also, and should make extensive use of the ability to nest patterns, these are simple, it essentially concatenates patterns per step we specify.
*/
Pseq([
	Prand(sounds[\kicks], 1),
	Prand(sounds[\hats], 7),
	Prand(sounds[\snares], 1),
	Prand(sounds[\hats], 7)
])
/*


