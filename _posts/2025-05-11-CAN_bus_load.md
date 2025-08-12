---
title: Calculating CAN Bus load
description: Wost-case estimation of CAN bus load
date: 2025-05-11 17:00:00 -0500
categories: [CAN]
tags: [automotive]
---

# CAN Bus Load
How to calculate the time it takes to send a CAN message. This can be used to estimate the bus load on the CAN bus.
This will *always* be an estimation since the number of stuff bits is impacted by the data being sent.
Bus arbitration also makes the entire bus non-deterministic.

## Fields in a CAN frame
| Field Name   |                                                                Size (in bits) |
| :----------- | ----------------------------------------------------------------------------: |
| Start        |                                                                             1 |
| Identifier   |                                               11 (standard), or 27 (extended) |
| RTR          |                                                                             1 |
| Control      |                                                                             6 |
| Data         |                          64 (worst case standard), or 512 (worst case CAN-FD) |
| CRC          | 15, or (CAN-FD is 16 for 0-16 data **bytes** and 21 for 17-64 data **bytes**) |
| ACK          |                                                                             3 |
| EOF          |                                                                             7 |
| Intermission |                                                                             1 |
| Stuffing`*`  |     CEIL( (`Identifier` + `Data` + `CRC`) / 5) (worst case is all `0` or `1`) |
`*`: The `5` here represents the maximum number of stuffing bits

```
Therefore a single standard CAN frame has a worst case size of 128 bits

A single CAN-FD frame with an extended identifier would have a worst case size of 702 bits
```

The CAN-FD example assumes `64 bytes` of data, and therefore a CRC size of `21 bits`.

It is unrealistic that the CRC and/or Identifier would be all `0` or all `1`, but it makes for a reasonable worst-case estimation.

## Calculating the bit time
- The bit time is simply: `1 / bit rate`, so for a 500 K CAN bus
- `bit time = 1 / bit rate  = 1 / (500 * 1000) s = 2 µs`

Based on the worst case numbers above this would mean the time it takes is:
- `256 µs` for a standard CAN frame at `500K`
- `1404 µs` for a CAN-FD frame with an extended identifier

## Estimating the bus load

Assuming that every `100 ms` one message will be sent every `100 ms` the bus will be occupied for `256 µs`.
So the bus load from these cyclic messages is:

```
256 µs / 100 ms = (256 / (100 * 1000)) * 100% = 25600 / 100000% = 0.256%
```

Assuming the following transmission intervals on the bus as:

```
1 frame every 10 ms     =  100 frames every 1000 ms
1 frame every 100 ms    =   10 frames every 1000 ms
1 frame every 1000 ms   =    1 frame  every 1000 ms

Frame total:           111 frames every 1000 ms
Total time on bus is:  111 * 256 µs
Total time is:         1000 ms = 1000 * 1000 µs
Bus load is:           ((111 * 256) / (1000 * 1000)) * 100% = 2.84%
```

## References
 - https://support.vector.com/kb?id=kb_article_view&sysparm_article=KB0012332
 - http://esd.cs.ucr.edu/webres/can20.pdf
