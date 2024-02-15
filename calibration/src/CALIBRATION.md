
# The *SpHEAR Project

This file details the current calibration procedure for the TinySpHEAR B format 1st order microphone.

## Measurements

Requirements for a successful calibration:

* speaker: a single driver full frequency response speaker, best if not ported (we have used a H&K M50 with a frequency response of 100 to 20KHz +/- 5dB). 

* reference microphone: a decent reference microphone, hopefully one that has been calibrated so that the frequency response is known.

* impulse response measurement software (we have used Aliki running under Linux).

* ambisonics microphone, of course, and suitable four channel recorder. This is important: you need to use a microphone preamplifier with digitally controlled input gain (and with good tracking between channels). Anything with analog controls is not suitable as the calibration depends on repeatable and exact gains being maintained at all times between all four channels. You would be forced to use them at maximum or minimum gain which is very suboptimal. It is best to pair the microphone with a particular preamplifier or recorder and calibrate them as a unit. 

The software calibration requires at least 16 impulse response measurements at regular angle intervals in the horizontal plane. These should be recorded in a suitable space, either an anechoic chamber or a large space in which the first reflections are delayed enough so that they can be removed from the impulse response. Once you have them you can proceed with the rest of the calibration.

## Calibration

* calculate all A2B matrixes as a function of frequency (returned in A2BF).

```octave
[F FE A2BF PVF] = sphear_a2b_all((1:16), 300, 20000, 3, 48000, 256, 32, 0);
```

The last parameter can be used to enable the b format component polar plots.

The first parameter specifies the measurements to process, (1:16) is a vector that contains all measurement numbers. To specify a subset of measurements just build an array with the desired numbers. 

```octave
[F FE A2BF PVF] = sphear_a2b_all([1, 5, 9, 13, 15], 300, 20000, 3, 48000, 256, 32, 0);
```

Then design the FIR filter to correct each component of the A2B matrix as a function of frequency for low and mid frequencies (below 5000Hz in this example). Also restrict the maximum boost of the filter to 12 dB in this example. 

```octave
FIR = sphear_fir_design(F, A2BF, 256, 12, 48000, 5000);
```

Now plot, for each measurement, the B format signals as recovered after passing through the FIR filter, and also write a B-format soundfile of the rendered result. 

```octave
sphear_fir_render(FIR, 300, 20000, 8192, 128, 48000, 1);
```

Now calculate the power envelope for all B format components, normalize everything to (arbitrarily) the average power of W between 600 and 1200Hz. And optionally display the polar plots of W, X, Y and Z for each frequency band.

```octave
[B] = sphear_a2b_fir_all(300, 20000, 3, 8192, 48000, 1);
```

Extract the frequency response shapes from the B array. The second argument specifies whether to average all measurements (1) or only the on axis measurements (0). 

```octave
[W X Y Z] = sphear_fir_extract(B, 1, 1);
```

Redesign the FIR filter using the extracted W, X, Y and Z shapes. The lower frequency range (below 5000Hz in this example) will directly use the A2B matrix coefficients to design the frequency response shape, the upper frequency range will use an interpolated polynomial over the average frequency response of each component as calculated above. 

```octave
FIR = sphear_fir_design(F, A2BF, 256, 12, 48000, 5000, W, X, Y, Z);
```

Filter all capsule inputs through the B format conversion, write a B-format four channel soundfile to disk:

```octave
sphear_fir_render(FIR, 300, 20000, 8192, 128, 48000, 1);
```

Finally, plot all the b format component polar plots. The amplitude of the plots is normalized by the power of the W signal between 600 and 1200Hz. Frequency range considered is between 300Hz and 20KHz, the FFT size is 8192, sampling rate 48000, measurements done in 1/3 octave increments (approximately)

```octave
[B] = sphear_a2b_fir_all(300, 20000, 3, 8192, 48000, 1);
```

FIR contains a 4 x 4 matrix, each cell contains a FIR filter, applying those to each one of the four A format components coming from the microphone will generate 4 B format calibrated outputs.

