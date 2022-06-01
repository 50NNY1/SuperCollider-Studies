/*
##Changing audio interfaces
if we evaluate the line of code

ServerOptions.devices

in our post window we are returned an array of possible ins and outs to use.
to make use of these returned values we can do.

s.options.inDevice =
s.options.outDevice =

##wavetable synthesis

first we must allocate space server side.

b= Buffer.alloc(s, 2048)

to create a wave table, we use the Signal class to generate various waveforms.
to create a sine wave we would do

~sig = Signal.sineFill(1024, [1], [0]);

gonna be quite useful to ploit this right?
thats very easily done

~sig.plot;
b.loadCollection(sig);

we can convert to wavetable format with
.asWavetable

--this doesnt allow for interpolative wavetables, only stepped ones.
  to create interpolative ones...

we need to create two wavetables as shown above ^^ into two seperate buffers.
Vosc is used here plugged in with both wavetables and will interpolate between.


*/
