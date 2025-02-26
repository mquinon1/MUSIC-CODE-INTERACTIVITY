~bufrest= (Buffer.read(s, "/Users/danielfishkin/gitprojects/MUSIC-CODE-INTERACTIVITY/class6/daxos/bouncy_2.wav");)

~bufrest.bufnum

~bufrest.play

n = NodeProxy.audio(s,2).play;
n.play

n.source = {Pan2.ar(PlayBuf.ar(
		numChannels: 1,
		bufnum: ~bufrest,
	rate: 1.0,
	loop: 0))}


a = NodeProxy.audio(s,2).play;
a.play

~bp = NodeProxy.audio(s,2).play;
~bp.play;

~numChannels = 2;				// number of channels in the sound file
~soundFileIndex = 0;				// which sound file in the array ~buffers. use different numbers to select files for sampling

~bp[0] = {  PlayBuf.ar(~numChannels, bufnum: ~buffers[~soundFileIndex], rate: 1.0, loop: 0) };   	// play once

~bp[0]=
{
	arg amp=1, buf=~buffers[~soundFileIndex];
	var sig, ptr;
	ptr = Line.ar(0, BufFrames.kr(buf) - 1, BufDur.kr(buf), doneAction:2);
	sig = BufRd.ar(2, buf, ptr);
	sig = sig * amp;
	Pan2.ar(sig, 0);
};



~daxos[4].bufnum