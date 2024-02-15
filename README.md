
# The *SpHEAR Project

The *SpHEAR (Spherical Harmonics Ear) Project is a collection of 3D models and associated code for building, testing and calibrating full surround Ambisonics microphones. All 3D models are written in Openscad with the code licensed under the GPL 3+ license (GNU Public License version 3 or higher), and the 3D models licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International license.

The 3D models are almost completely parametric and are designed to be able to be printed on low cost widely available 3D printers (at CCRMA we use an Ultimaker 2 Extended Plus printer, using PLA material). The design is modular and tries to avoid using overhangs and support structures. That is why each microphone assembly is made of a number of independently printed capsule holders interconnected by legs that interlock and hold the structure together. The capsule holders and the mount are glued together to create a 3D structure that securely holds all microphone capsules. A mount that can be clipped into a standard microphone stand is part of the design.

## Mailing list

You can subscribe to a development mailing list (sphear-devel@ccrma.stanford.edu) here:
<https://cm-mail.stanford.edu/mailman/listinfo/sphear-devel>

## About building microphones

Successfully printing a microphone assembly is only the first step in a long and complicated process. This also includes finding and buying the required microphone capsules, assembling the electronics (requires precision skill with the soldering iron) and finally calibrating the multi-capsule microphone to get the best performance out of it (you will need at least a single driver sound source and a calibrated microphone).

The whole process is not easy and requires knowledge of acoustics and electronics, plus a healthy dose of patience and the ability to perform tasks with precision and care. This repository will eventually include more detailed instructions, electronic schematics, suggested and tested parts and software and procedures for calibrating and measuring the microphone, including models for test and calibration rigs.

## 3D models

The 3D models currently include the TinySpHEAR, a four capsule first order Ambisonics microphone, the Octathingy, an eight capsule second order design by Eric Benjamin and Aaron Heller and preliminary designs for 12 and 20 capsule designs (the BigSpHEAR_12 and BigSpHEAR_20 models). The models will be expanded as testing proceeds. 

* [TinySpHEAR](doc/TinySpHEAR_simple.md): four capsule first order microphone with simple stand mount

  * [TinySpHEAR Zapnspark](doc/TinySpHEAR_zapnspark.md): four capsule first order microphone with four Zapnspark phantom power interfaces and shock mount

* [Octathingy](): eight capsule microphone (proof of concept so far)

* [BigSpHEAR_12 / BigSpHEAR_20](): 12 and 20 capsule designs (proof of concept)

## Electronics

The pcb/zapnspark directory contains the Kicad electrical circuit and printed circuit board design for the Zapnspark phantom power interface. The current printed circuit board design fits into four slots carved inside the body of the [TinySpHEAR plus Zapnspark model](doc/TinySpHEAR_zapnspark.md). Everything is dimensioned for the sizes of the components specified in the parts list, any changes (specially the diameter of the electrolytic capacitors) would need to be taken into account by changing appropriate model parameters. 

## Calibration

The calibration/src directory contains the Octave files for the current calibration software. The CALIBRATION.md file in there has a very brief description of usage, but currently is out of date with the current source code. Look into the individual files for more guidance. Hopefully this will be fixed soon.

