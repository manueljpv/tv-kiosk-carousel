# Alternatives and lessons learned

## Why we did not use a laptop

The first version of the project ran on an old laptop connected to the TV, with the lid closed and the internal screen turned off. It worked, but the setup was poor: the laptop got hot even after maintenance and cleaning, and leaving a closed laptop behind a TV is neither practical nor safe. What solved it was looking for idle equipment inside the company. Mini PCs from earlier network use were sitting unused in a cabinet. They are small, run cool, have a wired network port, and already have video outputs ready for a TV. Reusing idle equipment was simpler, cheaper and more reliable than adapting a laptop.

## Two problems that may show up on other hardware

On the laptop, which had 10th generation Intel graphics (Ice Lake), plugging in the HDMI cable while the system was running froze the machine completely, even dropping the remote access. The cause was a regression in a newer kernel (7.x series) with the Intel video driver; an earlier kernel (6.14) worked. The fix was to pin the working kernel in GRUB and hold the packages that would upgrade it. Anyone reusing similar hardware should test HDMI with someone next to the machine and, if it freezes, try another kernel before blaming the cable, the TV or the browser. Chrome and GPU acceleration were ruled out as the cause.

The second problem was Wi-Fi, which has power saving turned on by default and can become unstable on a machine that never rests. Turning off Wi-Fi power saving in NetworkManager and keeping reconnection attempts active stabilized the connection. Whenever possible, prefer a network cable for a machine that has to stay on every day without supervision.
