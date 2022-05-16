play{2.collect{RecordBuf.ar(Limiter.ar(HPF.ar(Convolution2.ar(k=Crackle.ar(l=Line.kr(1,2,90)),b=LocalBuf(2048),Dust.kr(4)),8)+k)*(2-l),b)}}

{x=Array.fill(5,{[0.00001,0.03].asSpec.map(LFNoise2.kr(3))});Splay.ar(Friction.ar(LFTri.ar(50),friction:x,mass:x*30000))}.play

play{f=LocalIn.ar(2).tanh;k=Latch.kr(f[0].abs,Impulse.kr(1/4));LocalOut.ar(f+CombC.ar(Blip.ar([4,6],100*k+50,0.9),1,k*0.3,50*f));f}//44.1kHz