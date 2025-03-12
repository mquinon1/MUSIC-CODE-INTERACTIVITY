s.boot;

Date.getDate

(midinote: 70).play

{PinkNoise.ar(0.4)}.play

getDate(Date)

~mynode = NodeProxy.new.play

(
~mynode[0..2] =
{
	var pitch = exprand(100, 2000);
	var volume = MouseY.kr(0, 0.2);
	SinOsc.ar(pitch, 0, volume);
}
)

