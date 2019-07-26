pragma solidity ^0.5.0;

/*
License: GPL-3.0
Author: Christoph Michelbach
Contact: christoph.michelbach@blockinfinity.com
*/

import "./EccOperations/EccOperations.sol";

contract Verify {
	// Order of the group. This parameter is called q in the IETF RFC.
	uint256 constant n = 0xA9FB57DBA1EEA9BC3E660A909D838D718C397AA3B561A6F7901E0E82974856A7;

	// The prime number specifying the field.
	uint256 p = 0xA9FB57DBA1EEA9BC3E660A909D838D726E3BF623D52620282013481D1F6E5377;

	// The generator.
	uint256 constant G_x = 0x8BD2AEB9CB7E57CB2C4B482FFC81B7AFB9DE27E1E3BD23C23A4453BD9ACE3262;
	uint256 constant G_y = 0x547EF835C3DAC4FD97F8461A14611DC9C27745132DED8E545C1D54C72F046997;

	uint256 debugQ_x;
	uint256 debugR;
	function isValidSignatureForHash(uint256 PK_x, uint256 PK_y, uint256 r, uint256 s, uint256 messageHash) public returns (bool valid) {
		require(r >= 1);
		require(s >= 1);
		require(r < n);
		require(s < n);

		uint256 s_inv = EccOperations.inverseModN(s);
		assert(s_inv < n);
		assert(mulmod(s, s_inv, n) == 1);

		uint256 u_1 = mulmod(s_inv, messageHash, n);
		uint256 u_2 = mulmod(s_inv, r, n);

		(uint256 t1_x, uint256 t1_y) = EccOperations.multiplyScalar(G_x, G_y, u_1);
		(uint256 t2_x, uint256 t2_y) = EccOperations.multiplyScalar(PK_x, PK_y, u_2);
		(uint256 Q_x, uint256 Q_y) = EccOperations.add(t1_x, t1_y, t2_x, t2_y);

		(uint256 neutral_x, uint256 neutral_y) = EccOperations.getNeutral();
		require(Q_x != neutral_x || Q_y != neutral_y);
		require(Q_x < n);

		debugQ_x = Q_x;
		debugR = r;
		return Q_x == r;
	}

	function isValidSignatureForMessage(uint256 PK_x, uint256 PK_y, uint256 r, uint256 s, string memory message) public returns (bool valid) {
		bytes memory preimage = bytes(message);
		bytes32 hash = sha256(preimage);
		uint256 hashIntRepr = uint256(hash);

		return isValidSignatureForHash(PK_x, PK_y, r, s, hashIntRepr);
	}

	function getDebugQ_x() public view returns (uint256) {
		return debugQ_x;
	}

	function getDebugR() public view returns (uint256) {
		return debugR;
	}

}
