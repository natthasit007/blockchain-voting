// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Voting {
    struct Poll {
        string title;
        string[] options;
        uint256[] votes;
        uint256 endTime;
        address creator;
    }

    Poll[] private polls;

    // pollId => voter => เคยโหวตหรือยัง
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    event PollCreated(uint256 indexed pollId, string title, address indexed creator, uint256 endTime);
    event Voted(uint256 indexed pollId, address indexed voter, uint256 optionIndex);

    function createPoll(
        string calldata title,
        string[] calldata options,
        uint256 durationInSeconds
    ) external returns (uint256 pollId) {
        require(options.length >= 2, "Need at least 2 options");
        require(durationInSeconds > 0, "Duration must be > 0");

        pollId = polls.length;
        Poll storage p = polls.push();
        p.title = title;
        p.creator = msg.sender;
        p.endTime = block.timestamp + durationInSeconds;

        for (uint256 i = 0; i < options.length; i++) {
            p.options.push(options[i]);
            p.votes.push(0);
        }

        emit PollCreated(pollId, title, msg.sender, p.endTime);
    }

    function vote(uint256 pollId, uint256 optionIndex) external {
        require(pollId < polls.length, "Poll not found");
        Poll storage p = polls[pollId];

        require(block.timestamp < p.endTime, "Poll ended");
        require(!hasVoted[pollId][msg.sender], "Already voted");
        require(optionIndex < p.options.length, "Invalid option");

        hasVoted[pollId][msg.sender] = true;
        p.votes[optionIndex] += 1;

        emit Voted(pollId, msg.sender, optionIndex);
    }

    function getPoll(uint256 pollId)
        external
        view
        returns (
            string memory title,
            string[] memory options,
            uint256[] memory votes,
            uint256 endTime,
            address creator
        )
    {
        require(pollId < polls.length, "Poll not found");
        Poll storage p = polls[pollId];
        return (p.title, p.options, p.votes, p.endTime, p.creator);
    }

    function pollCount() external view returns (uint256) {
        return polls.length;
    }
}