
# The *SpHEAR Project

# Requirements

## Hardware

### Basic

* A 3D printer (we use an Ultimaker Extended Plus and PLA filament)

* A PCB (printed circuit board) prototyping system (we use the OtherMill computer controlled mill)

### Tools

* X-Acto knife or similar with set of blades (for trimming and cleaning up 3D prints)

* Needle file set (for trimming and cleaning up 3D prints)

* Soldering iron with temperature control and fine tip (for assembling the phantom power interfaces)

* Long nosed pliers

* Wire stripper

* Wire cutter

* Digital Multimeter with hFE measuring function (transistor forward current gain - for matching phantom power interface transistors)

* Headband Magnifying glass (this project has a lot of very small things you need to see, solder and manipulate)

### Calibration equipment

* Speaker: preferably a wide bandwidth single driver small speaker (we have used a H&K M50 with a frequency response of 100 to 20KHz +/- 5dB). If your speaker is small but ported it is best to plug the ports. This speaker is used to measure the response of the completed Ambisonics microphone (and reference microphone) during the calibration.

* Reference microphone: a flat omnidirectional reference microphone, preferably with its own calibrated response. We use this as a reference for calibrating the TinySpHEAR Ambisonics microphone. I have been using an individually calibrated Dayton EM-6 Electret Measurement Microphone. You can buy a very reasonably priced and calibrated EM-6 here:

<http://cross-spectrum.com/measurement/calibrated_dayton.html>

* A Big Room: you need a relatively big space for doing the calibration measurements (or an anechoic chamber, of course). If the room is not anechoic the distance between the nearest reflecting surface, the microphone and the speaker will determine the usable impulse response length (in the space I am using I get 5 to 6 mSecs of usable impulse response which is apparently enough for a reasonable calibration). 

## Software

All the software used to design and build the microphones is Free Software under various licenses and runs under the GNU/Linux operating system. At the time of this writing I'm running this software on Fedora 24 in my laptop (most of the software described below is available either from the Fedora repositories or from the Planet CCRMA repository). 

### 3D Printing and Printed Circuit Design

* **Openscad**: 3D design language and renderer. All 3D models in this project are created in Openscad. 

<http://www.openscad.org/>

* **3D printer slicer**: this is a tool that takes the STL (STereoLithography) output from a rendered Openscad object and outputs the G-code that the 3D printer understands. You will need software that supports the 3D printer you have access to. We use Cura as that is tailored to the printer we have (Ultimaker Plus Extended).

<https://ultimaker.com/en/products/cura-software>

* **Kicad**: schematic capture and printed circuit layout software. This is used to create the phantom power printed circuit boards that connect each capsule to one input of a four channel preamplifier or recorder. The Gerber format export from the printed circuit layout software is used to mill or etch the printed circuit boards. 

<http://kicad-pcb.org/>

### Calibration

* **Aliki**: an integrated system for Impulse Response measurements, using the logaritmic sweep method. This is used to capture the impulse responses of the reference microphone and the finished TinySpHEAR Ambisonics microphone array which are then used to calibrate the microphone. 

<http://kokkinizita.linuxaudio.org/linuxaudio/downloads/>

* **Octave**: a scientific programming language with a powerful mathematics-oriented syntax with built-in plotting and visualization tools. Most of the calibration software is written in Octave. In addition to the base software you will also need to install the "Signal" package. 

<https://www.gnu.org/software/octave/>

* **DRC (Digital Room Correction)**: a program used to generate correction filters for acoustic compensation of HiFi and audio systems in general, including listening room compensation. This is used to calibrate the excitation speaker using the calibrated reference microphone

<http://drc-fir.sourceforge.net/>

* **SOX**: the Swiss Army knife of sound processing programs. Used during the calibration process to convert soundfile formats. 

<http://sox.sourceforge.net/>

* **Ecasound**: a software package designed for multitrack audio processing. Together with Python and Pyecasound it is (optionally) used to measure the final FIR calibration matrix as deployed in TetraProc. 

<http://www.eca.cx/ecasound/>

### Running

You will need software that processes the A-format signals that the microphone outputs into the B-format Ambisonics signals (and that can use the output of our calibration process). 

* **TetraProc**: TetraProc converts the A-format signals from a tetrahedral Ambisonic microphone into B-format signals ready for recording. The calibration process generates a 4x4 matrix of FIR filters that can be directly loaded into TetraProc. TetraProc is a very capable front end for the TinySpHEAR Ambisonics microphone. 

<http://kokkinizita.linuxaudio.org/linuxaudio/downloads/>

## Building the microphone

As outlined in the introduction this is not an easy to build project. It is assumed in these instructions that you have previous experience with 3D printing, precision printed circuit circuit and connector soldering skills and have a steady hand and a lot of patience. The reward at the end of the road is a calibrated Ambisonics microphone with very good performance. 

You will need access to a 3D printer. Plan on doing many experiments as you learn the ins and outs of the particular printer you are using. You will probably need to tweak model parameters so that all the parts fit together nicely.

There are at this point two different types of microphone bodies depending on the type of electrical interface you choose. The simplest one connects the capsule array directly to a standard clip on microphone stand and includes no electronics. The interface to the phantom power supply is just a few components that usually fit into the shell of the XLR connector. This is very simple but the output is not balanced so cable runs have to be short, and is very sensitive to noise in the phantom power supply (for example it leads to unacceptable low frequency performance when using a Zoom F8 recorder). 

By far the best design (and of course the most complicated) uses a balanced phantom power interface derived from the well known Shoeps interface (by Zapnspark). The main body of the microphone assemble houses four of these interfaces. There is an upper "flare" that snaps into place and holds the array of four capsules. Four shielded cables connect the capsules to the printed circuit boards. There is a second lower "flare" that has two design options. The simplest one directly connects a 4 pair balanced snake cable to the printed circuit boards (microphone and cable are a single unit), the second option houses a 12 pin DIN connector that enables the microphone to be disconnected from the cable, but is more expensive. 

For our prints we have used an Ultimaker Plus Extended with PLA filament. 

If you want to build the phantom power printed circuit boards from scratch you will need access to PCB prototype manufacturing equipment. We have used the small OtherMill computer controlled mill with success. 

## Parts list

This is a probably incomplete list of what you will need to build a complete microphone. Some of the items below are optional and depend on which type of mount you want to build. 

* electret capsules: in our prototypes we have used either the Primo 10mm EM182 (approximately U$S 8.50 each) or 14mm EM200 capsules (approximately U$S 16 each). The 3D models are dimensioned for both capsules. The 10mm capsules allow for the smallest array radius (around 9.6mm) and highest transition frequency. The 14mm capsules have a lower transition frequency as the array radius is bigger (around 11mm), but their low frequency response is much better - and they are more expensive. 

* components for building the Zapnspark phantom power interfaces. See the full list in this spreadsheet:

pcb/zapnspark/zapnspark_parts_list.xlsx

Plan on buying at least three or four times the number of transistors needed (8 for a complete four capsule microphone), you want to be able to match them by measuring their hFE using the digital multimeter so that each pair has the closest hFE values possible. You will get the best balanced performance if they are matched - that is also why some of the resistors are 1% tolerance.

_Please be aware that the geometry of the body of the microphone assembly is optimized for the exact size of the printed circuit board and those exact components (specially the diameter of the electrolitic capacitors). If the components you buy are different the completed printed circuit board may not fit inside the microphone body._

* Mogami W2490 Ultraflexible Miniature Microphone Cable - for connecting the capsules and 12 pin connector (if used) to the phantom power printed circuit boards, the 3D models are dimensioned to use this cable

<http://www.mogamicable.com/category/bulk/ultra_flex_mini/>

* Mogami W2931 Analog 4 Pair Audio Snake Cable Black - for connecting the microphone to the XLR audio connectors, 3D models assume use of this cable

<http://www.mogamicable.com/category/bulk/snake/>

* Amphenol Part Number: T 3635 002, male to cable connector, for cable diameter 6-8 mm, solder termination, gold plated contacts (only the inner core is used, housed in the bottom flare of the microphone assembly).

<http://www.mouser.com/ProductDetail/Amphenol/T-3635-002/?qs=%2fha2pyFaduj9RozDj9VGZwhE1bng9mEr%2fVqLjk4F3KI%3d>

* Amphenol Part number: T 3636 002, female to cable connector for cable diameter 6-8 mm, solder termination, gold plated contacts (this is used to build the cable that splits the microphone output into separate XLR connectors).

<http://www.mouser.com/ProductDetail/Amphenol-Tuchel/T-3636-002/?qs=sGAEpiMZZMvf6myxbP4FpDJYY7d64fyYD%252bV0bNAbSo8%3d>

* Switchcraft or Amphenol XLR connectors (four), male to cable

* screw and nut for shock mount (screw: 10/24 x 3/4 Trimmed, Hex Steel GR8 Cap Screw, B2032024; nut: #10 Thumbnut, 5/8"Diameter Black Knurl Style Knob, 10/24 Custom aluminum nut)

* black short hair ties for assembling shock mount (scünci 15975-A or similar)

* Switchcraft Mini-XLR Connectors 8 pin, male, TA8MSHF (Mouser #502-TA8MSHF) - for proposed H2N new design



## 3D Printing the parts

There are two top level Openscad files, each one optimized for one of the two Primo capsules we have used:

* TinySpHEAR_EM182.scad (Primo EM182 10mm capsules)
* TinySpHEAR_EM200.scad (Primo EM200 10mm capsules)

We assume that you are building a complete microphone assembly with phantom power balanced interfaces and a 12 pin DIN connector. If you want to build a microphone with a different capsule copy one of the files and start by modifying the capsule dimensions as measured from your selected capsule.

Each file has one line statements that render each component of the microphone and are "commented out" by a leading "\*". If you load the file into Openscad and remove the leading "\*" from one of the lines you should be able to preview the part by pressing "F5" (or do a full rendering by pressing "F6").

For building a TinySpHEAR four capsule Ambisonics microphone you will need to 3D print: 

* microphone body ("render_tetra_body"), holds four phantom power printed circuit boards
* upper flare to capsule array ("render_tetra_capsule_flare")
* lower flare to DIN connector ("render_tetra_connector_flare")
* two top capsules ("render_tetra_capsule_top")
* two bottom capsule holders ("render_tetra_capsule_bot")

If you add the TinySpHEAR shock mount with adaptor for Quik-Release KQ-2B microphone adapter:

* adapter to Quik-Release clip-on stand ("render_tetra_shock_mount_stand")
* shock mount external ring ("render_tetra_shock_mount_external_ring")
* shock mount internal top ring ("render_tetra_shock_mount_internal_ring_bot")
* shock mount internal bottom ring ("render_tetra_shock_mount_internal_ring_top")
* four shock mount internal ring connectors ("render_tetra_shock_mount_ring_connectors")

For each part you need to print you will have to export the rendered part to STL in Openscad, then load the STL code into your slicer (Cura in our case) and save the G-code generated by the slicer. The G-code will drive the printing process.

## Assembling the printed circuit boards

The printed circuit boards as milled by OtherMill are a little fragile. The traces are quite thin and can be lifted by pushing on soldered components. So, for the biggest ones (all four capacitors) I recommend using a small glue gun to put a drop of glue on the component before positioning it on the PCB so that it will not move once soldered (you have to be pretty fast when doing this).

Also make sure the two transistors are close to the PCB and leaning towards the center of the PCB, otherwise fitting of all four PCBs inside the microphone body might not be possible (there is not a lot of clearance - I tried to make the body as small as possible).

Once the boards are assembled test them!

It is best to prepare a set of "test components". Select one of the capsules and solder a length of Mogami W2490 cable to it (red to "Drain", white to "Source", shield to "Ground"). Also solder a length of Mogami W2490 cable to one of the XLR connectors (red to pin 2, white to pin 3, shield to pin 1).

Now test each of the boards by soldering the capsule and XLR cable, connect them into a preamplifier and check that it works.

Also test all capsules separately as well (you do not want to finish building the microphone and discover that one of the assemblies is not working - believe me, it is not fun).

Make sure that the PCBs fit into the printed microphone body. Depending on the print and PCB tolerances you may need to ligthly and carefully sand the sides of the PCBs so that they fit inside. You want a snug fit so that the PCB does not slide out by itself. Be careful when inserting them into the body (do not bend them). 

## Assembling the microphone

At this point we have all the 3D printed parts and we verified they fit together. You may need to use the needle files and/or the X-Acto knife to trim away imperfections. Make sure the inside of the capsule holders are free of burs and that the capsules have a tight fit. 

The first step is to glue together the four capsule holders and mount them on top of the capsule array mount. I have used 5 minute two part epoxy, but it sets almost too fast so you have to work quicky and precisely. You may want to use something that takes longer to set.

First snap the four capsule holders together. Apply epoxy to the inside of the mounting slots on the top of the capsule array mount and to the curved surfaces on which the two bottom capsules rest. Clip the four capsules into the array mount. Remove the upper two capsules gently and apply glue to the inside of all connection fingers. Remount them and press everything together carefully. Look at the geometry of the array from the side and top. This is your chance to align everything properly and make sure the array is symetrical. Keep holding the array until the glue sets. 

Solder a length of Mogami W2490 wire to each capsule, strip and pre-tin both ends. Mark each wire with one through four strips with a indelible pen so that you know which one is which. The small bump in the microphone stalk below the capsules is the "back" of the microphone. Capsule #1 is the "front upper left" capsule, capsule #2 is the "front lower right" capsule, #3 is the "back lower left" capsule and #4 is the "back upper right" capsule. 

To solder the cable to the capsule I find it easiest to strip and pre-tin all three wires, then form and cut the shield wire into a tiny "L" and solder the bottom of the "L" into the ground pad so that the wire is straight. Then carefully position the red and white wires (pre-cut to lenght) and solder them to the other two pads. Make sure the wires do not obstruct the tiny holes in the back of the capsules (those make the microphone into a cardiod)

Insert that capsules into the capsule holders. I start with the two bottom capsules. Thread the wire through the array mount hole that is closest to the center and push it down gently with a long nosed plier. Eventually you will be able to seat the capsule into the holder and push it in position. Do that with both of the bottom capsules. Then do the same with top capsules (much easier).

Insert the four PCBs into the body of the microphone and find some way to hold the whole thing securely (you need a lot of hands). Solder the microphone wires to the pads on the outside of the PCBs.

Now solder four lengths of Mogami W2490 cable to all 12 pins of the DIN connector. This is precision work and quite difficult to do cleanly. Of the four three pin groups the ones where one pin is "inside" are the most difficult. Start with that pin. Once you have all four wires soldered assemble the other half of the connector, thread the threaded ring and insert the connector into the bottom flare of the microphone threading the wires into it. Use the screws that are normally used to secure the strain relief to screw the connector to the mount.

Now solder all four cables to the bottom of the four PCBs in the microphone body. Carefully push together all three sections of the microphone until they click. 

Finally build the cable, again strip and pre-tin the Mogami W2931 cable, solder it to the 12 pin DIN connector (do not forget to thread all the parts before you start!) and assemble the whole thing. You will have to refer to the assembly drawings to fit everything together nicely.

Solder the four XLR connectors to the other end of the cable.

Connect all four connectors to your microphone preamplifier or recorder and make sure everything works. Label the XLR connectors appropriately by gently tapping on the capsules and making sure they are connected to the preamp in the right order.

And now on to the calibration!

