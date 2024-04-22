// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {THMinerInterface} from "./THMinerInterface.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {DataMarketPlaceInterface} from "../market/interface/DataMarketPlaceInterface.sol";
import {TokenBankInterface} from "contracts/plugins/eth-contracts/assets/TokenBankInterface.sol";
import {THPeriodInterface} from "../THPeriodInterface.sol";
import {Address} from "@chainlink/contracts/src/v0.7/vendor/Address.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

contract THMiner is THMinerInterface, AccessControl, Ownable {
    bytes32 public constant TRUSTED_ROLE = keccak256("TRUSTED_ROLE");
    using Address for address;
    DataMarketPlaceInterface public data_market_place;
    TokenBankInterface public token_pool;
    THPeriodInterface public period_contract;

    uint256 public ratio_base = 1000000;
    uint256 public algo_ratio;
    uint256 public data_ratio;
    uint256 public buyer_ratio;
    uint256 public total_reward_per_round;
    address public reward_token;

    struct user_info {
        uint256 algo_amount;
        uint256 data_amount;
        uint256 buy_amount;
        bool claimed;
        bool exist;
    }
    struct round_info {
        uint256 algo_total;
        uint256 data_total;
    }

    mapping(address => mapping(uint256 => user_info)) public all_users;
    mapping(uint256 => round_info) public all_rounds;
    mapping(address => uint256) public user_last_active_round;

    constructor(
        address _market,
        address _token_pool,
        address _period,
        address _reward_token
    ) Ownable(msg.sender) {
        data_market_place = DataMarketPlaceInterface(_market);
        token_pool = TokenBankInterface(_token_pool);
        period_contract = THPeriodInterface(_period);
        reward_token = _reward_token;
    }

    event ChangeMarketPlace(address _old, address _new);

    function changeMarketPlace(address m) public onlyOwner {
        emit ChangeMarketPlace(address(data_market_place), m);
        data_market_place = DataMarketPlaceInterface(m);
    }

    event ChangeRatios(
        uint256 _algo_ratio,
        uint256 _data_ratio,
        uint256 _buyer_ratio
    );

    function changeRatios(
        uint256 _algo_ratio,
        uint256 _data_ratio,
        uint256 _buyer_ratio
    ) public onlyOwner {
        algo_ratio = _algo_ratio;
        data_ratio = _data_ratio;
        buyer_ratio = _buyer_ratio;
        require(
            algo_ratio + data_ratio + buyer_ratio <= ratio_base,
            "invalid ratios"
        );
        emit ChangeRatios(_algo_ratio, _data_ratio, _buyer_ratio);
    }

    event ChangeRewardToken(address token);

    function changeRewardToken(address token) public onlyOwner {
        reward_token = token;
        emit ChangeRewardToken(token);
    }

    event ChangeRewardPerRound(uint256 amount);

    function changeRewardPerRound(uint256 amount) public onlyOwner {
        total_reward_per_round = amount;
        emit ChangeRewardPerRound(amount);
    }

    /**
  1. take relevant information from the data_market_place
  2. take the record at the current transation period.
  3. issue reward of revelant users at their last active round(except the current round)
   */

    function mine_submit_result(
        bytes32 _vhash,
        bytes32 request_hash
    ) public onlyRole(TRUSTED_ROLE) {
        address data_owner;
        address algo_owner;
        address buyer;
        uint256 data_price;
        uint256 algo_price;
        (, , data_price, , data_owner, , , ) = data_market_place.getDataInfo(
            _vhash
        );

        {
            bytes32 program_hash;
            (buyer, , , , , program_hash, ) = data_market_place.getRequestInfo1(
                _vhash,
                request_hash
            );
            algo_owner = data_market_place.program_proxy().program_owner(
                program_hash
            );
            algo_price = data_market_place.program_proxy().program_price(
                program_hash
            );
        }
        mine_for_tx(data_owner, algo_owner, buyer, data_price, algo_price);

        issue_user_last_reward(data_owner);
        issue_user_last_reward(algo_owner);
        issue_user_last_reward(buyer);

        uint256 round = period_contract.get_current_period();
        user_last_active_round[data_owner] = round;
        user_last_active_round[algo_owner] = round;
        user_last_active_round[buyer] = round;
    }

    function mine_for_tx(
        address data_owner,
        address algo_owner,
        address buyer,
        uint256 data_price,
        uint256 algo_price
    ) internal {
        uint256 round = period_contract.get_current_period();
        if (round == 0) {
            // not start yet
            return;
        }
        all_users[data_owner][round].data_amount =
            all_users[data_owner][round].data_amount +
            data_price;
        all_users[algo_owner][round].algo_amount =
            all_users[algo_owner][round].algo_amount +
            algo_price;
        all_users[buyer][round].buy_amount =
            all_users[buyer][round].buy_amount +
            data_price +
            algo_price;
        all_users[data_owner][round].exist = true;
        all_users[algo_owner][round].exist = true;
        all_users[buyer][round].exist = true;
        all_rounds[round].algo_total =
            all_rounds[round].algo_total +
            algo_price;
        all_rounds[round].data_total =
            all_rounds[round].data_total +
            data_price;
    }

    function issue_user_last_reward(address _user) internal {
        uint256 round = user_last_active_round[_user];
        issue_token_for_user_and_round(_user, round);
    }

    event THRewardUserAtRound(address addr, uint256 round, uint256 amount);

    function issue_token_for_user_and_round(
        address _user,
        uint256 _round
    ) internal {
        user_info storage info = all_users[_user][_round];
        if (!info.exist) {
            return;
        }
        if (info.claimed) {
            return;
        }
        if (_round >= period_contract.get_current_period()) {
            return;
        }
        round_info storage r = all_rounds[_round];
        uint256 total = 0;
        if (info.data_amount > 0) {
            uint256 t = (total_reward_per_round * data_ratio) / ratio_base;
            t = (t * info.data_amount) / r.data_total;
            total = total + t;
        }

        if (info.algo_amount > 0) {
            uint256 t = (total_reward_per_round * algo_ratio) / ratio_base;
            t = (t * info.algo_amount) / r.algo_total;
            total = total + t;
        }
        if (info.buy_amount > 0) {
            uint256 t = (total_reward_per_round * buyer_ratio) / ratio_base;
            t = (t * info.buy_amount) / r.algo_total + r.data_total;
            total = total + t;
        }
        token_pool.issue(reward_token, payable(_user), total);
        info.claimed = true;
        emit THRewardUserAtRound(_user, _round, total);
    }

    function claimTokenForRound(address addr, uint256 _round) public {
        require(
            _round < period_contract.get_current_period(),
            "can only claim when a round is end"
        );
        user_info storage info = all_users[addr][_round];
        require(info.exist, "address not exist");
        require(!info.claimed, "already claimed");
        issue_token_for_user_and_round(addr, _round);
    }

    function userClaimStatus(
        address _user,
        uint256 _round
    )
        public
        view
        returns (
            uint256 data_amount,
            uint256 algo_amount,
            uint256 buy_amount,
            bool claimed,
            bool exist
        )
    {
        user_info storage info = all_users[_user][_round];
        data_amount = info.data_amount;
        algo_amount = info.algo_amount;
        buy_amount = info.buy_amount;
        claimed = info.claimed;
        exist = info.exist;
    }

    function roundStatus(
        uint256 _round
    ) public view returns (uint256 data_total, uint256 algo_total) {
        data_total = all_rounds[_round].data_total;
        algo_total = all_rounds[_round].algo_total;
    }
}
