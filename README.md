# Smart Meter Signature Verification
On-chain verification of signatures created by smart meters is difficult. Germany's Federal Office for Information Security mandates that the following curves be supported by smart meters for various purposes:
- BrainpoolP256r1
- BrainpoolP384r1
- BrainpoolP512r1
- NIST P-256
- NIST P-384

Conducting computations on any of these curves on-chain is expensive in terms of gas costs as none of them is supported by Ethereum. Ethereum only supports the curve ALT_BN_128 via precompiled contracts, offering vastly reduced gas costs for ECC computations on this curve when compared to conducting the same computations on the same curve but via an implementation in a regular smart contract. Adding two points only costs 500 gas; preforming a scalar multiplication only costs 40 000 gas.

Luckily, the curve chosen for signing content is BrainpoolP256r1. This is the cheapest one of the ones that are required to be supported by smart meters as it is the one with the smallest primes.

Our ECC Operations library provides the following operations at the respective approximate costs:

| Operation             | Approximate Cost in Gas |
|-----------------------|-------------------------|
| Addition              | 70 000                  |
| Doubling              | 65 000                  |
| Scalar multiplication | 84 000 -- 19 000 000    |
| Inverse (mod p or n)  | 30 000 -- 60 000        |

Note that the costs vary. In particular, the costs for scalar multiplication varies substantially. This is because with the double-and-add algorithm used, multiplication of points with a scalar is more expensive the bigger that scalar is and the more ones it contains in binary representation.

Our Smart Meter Signatures Verification library provides on-chain verification of ECDSA signatures created in accordance with the specifications laid out in BSI-TR-03111 Version 2.1. Verifying a signature on-chain costs about 25 million gas with costs of verification of short strings being nearly identical to the cost of verifying the respective hash (additional costs of 550 gas for short strings; more for longer strings). Implementing a more advanced algorithm for performing scalar multiplication can reduce this cost slightly.