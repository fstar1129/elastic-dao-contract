// SPDX-License-Identifier: GPLv3
pragma solidity 0.7.2;
pragma experimental ABIEncoderV2;

import './Ecosystem.sol';
import './EternalModel.sol';
import '../libraries/SafeMath.sol';
import '../services/ReentryProtection.sol';
import '../tokens/ElasticGovernanceToken.sol';

/**
 * @title A data storage for EGT (Elastic Governance Token)
 * @notice More info about EGT could be found in ./tokens/ElasticGovernanceToken.sol
 * @notice This contract is used for storing token data
 * @dev ElasticDAO network contracts can read/write from this contract
 * Serialize - Translation of data from the concerned struct to key-value pairs
 * Deserialize - Translation of data from the key-value pairs to a struct
 */
contract Token is EternalModel, ReentryProtection {
  struct Instance {
    address uuid;
    string name;
    string symbol;
    uint256 eByL;
    uint256 elasticity;
    uint256 k;
    uint256 lambda;
    uint256 m;
    uint256 maxLambdaPurchase;
    uint256 numberOfTokenHolders;
    Ecosystem.Instance ecosystem;
  }

  event Serialized(address indexed uuid);

  /**
   * @dev deserializes Instance struct
   * @param _uuid - address of the unique user ID
   * @return record Instance
   */
  function deserialize(address _uuid, Ecosystem.Instance memory _ecosystem)
    external
    view
    returns (Instance memory record)
  {
    record.uuid = _uuid;
    record.ecosystem = _ecosystem;

    if (_exists(_uuid)) {
      record.eByL = getUint(keccak256(abi.encode(_uuid, 'eByL')));
      record.elasticity = getUint(keccak256(abi.encode(_uuid, 'elasticity')));
      record.k = getUint(keccak256(abi.encode(_uuid, 'k')));
      record.lambda = getUint(keccak256(abi.encode(_uuid, 'lambda')));
      record.m = getUint(keccak256(abi.encode(_uuid, 'm')));
      record.maxLambdaPurchase = getUint(keccak256(abi.encode(_uuid, 'maxLambdaPurchase')));
      record.name = getString(keccak256(abi.encode(_uuid, 'name')));
      record.numberOfTokenHolders = getUint(keccak256(abi.encode(_uuid, 'numberOfTokenHolders')));
      record.symbol = getString(keccak256(abi.encode(_uuid, 'symbol')));
    }

    return record;
  }

  function exists(address _uuid, Ecosystem.Instance memory) external view returns (bool) {
    return _exists(_uuid);
  }

  /**
   * @dev serializes Instance struct
   * @param _record Instance
   */
  function serialize(Instance memory _record) external preventReentry {
    require(
      msg.sender == _record.uuid ||
        msg.sender == _record.ecosystem.daoAddress ||
        (msg.sender == _record.ecosystem.configuratorAddress && !_exists(_record.uuid)),
      'ElasticDAO: Unauthorized'
    );

    setString(keccak256(abi.encode(_record.uuid, 'name')), _record.name);
    setString(keccak256(abi.encode(_record.uuid, 'symbol')), _record.symbol);
    setUint(keccak256(abi.encode(_record.uuid, 'eByL')), _record.eByL);
    setUint(keccak256(abi.encode(_record.uuid, 'elasticity')), _record.elasticity);
    setUint(keccak256(abi.encode(_record.uuid, 'k')), _record.k);
    setUint(keccak256(abi.encode(_record.uuid, 'lambda')), _record.lambda);
    setUint(keccak256(abi.encode(_record.uuid, 'm')), _record.m);
    setUint(keccak256(abi.encode(_record.uuid, 'maxLambdaPurchase')), _record.maxLambdaPurchase);

    setBool(keccak256(abi.encode(_record.uuid, 'exists')), true);

    emit Serialized(_record.uuid);
  }

  function updateNumberOfTokenHolders(Instance memory _record, uint256 numberOfTokenHolders)
    external
    preventReentry
  {
    setUint(keccak256(abi.encode(_record.uuid, 'numberOfTokenHolders')), numberOfTokenHolders);
  }

  function _exists(address _uuid) internal view returns (bool) {
    return getBool(keccak256(abi.encode(_uuid, 'exists')));
  }
}
