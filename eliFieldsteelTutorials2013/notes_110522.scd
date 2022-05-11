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
*/
