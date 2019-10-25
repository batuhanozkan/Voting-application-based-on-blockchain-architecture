pragma solidity ^0.5.0;

contract Denemeler {
	uint8 constant MAX_ELECTION_COUNT = 20;
	uint electionCount = 0;

	struct Election {
		uint 		id;
		string 		title;
		bytes32[] 	candidates;
		address[] 	votersAddr;
		uint 		voterCount;
		uint 		numOfUsedVotes;
		address 	organizer;
		bool 		active;

		// Unix timestamps
		uint start;
		uint end;

		mapping(address => bool) voters;
		// `uint` represents candidate ID
		mapping(uint => Candidate) cands;
	}

	struct Candidate {
		uint 	id;
        bytes32	name;
        uint	voteCount;
    }

	mapping(uint => Election) elections;

	modifier isOrganizerOfElec(uint _elecID) {
		require(msg.sender == elections[_elecID].organizer, "Auth error: Only organizer could do that");
		_;
	}

	modifier checkElectionCount() {
		require(electionCount <= MAX_ELECTION_COUNT, "You have reached the max election count");
		_;
	}

	modifier isActive(uint _elecID) {
		require(elections[_elecID].start < now && elections[_elecID].end > now, "Election was ended.");
		_;
	}

	modifier checkVoterCount(uint _elecID) {
		require(elections[_elecID].numOfUsedVotes < elections[_elecID].voterCount, "All of the voters have voted.");
		_;
	}

	modifier hasVoted(uint _elecID, address _voter) {
		require(elections[_elecID].voters[_voter] == false, "User had already voted.");
		_;
	}

	// 0x44656e656d65 -> Hex converted version of `Deneme`
	// [FIXED] WARNING: You can create an election with same ID.
	// Before creating an election it checks whether electionCount is less than `10` or not.
	function createElection(string memory _title, bytes32[] memory _candNames, address[] memory _voters,
		uint _voterCount, uint _start, uint _end) public checkElectionCount
	{
		address organizer = msg.sender;
		uint _electionID = electionCount;

		elections[_electionID] = Election(_electionID, _title, _candNames, _voters, _voterCount, 0, organizer, true, _start, _end);

		for (uint256 i = 0; i < _candNames.length; i++) {
		 	elections[_electionID].cands[i].name = _candNames[i];
		}

		// Save all voters to the contract. Set voted status to `false`
		for (uint256 i = 0; i < _voters.length; i++) {
			elections[_electionID].voters[_voters[i]] = false;
		}

		electionCount++;
	}

	function vote(uint _elecID, uint _candId, address _voter) public isActive(_elecID)
		checkVoterCount(_elecID) hasVoted(_elecID, _voter)
	{
		elections[_elecID].numOfUsedVotes++;
		elections[_elecID].voters[_voter] = true;
		elections[_elecID].cands[_candId].voteCount++;
	}

	function getNextElectionId() public view returns (uint) {
		return electionCount;
	}

	function getCandidateName(uint _elecID, uint _candidateID) public view returns (bytes32,uint,uint,uint) {
        return (elections[_elecID].cands[_candidateID].name, elections[_elecID].cands[_candidateID].voteCount,
			elections[_elecID].numOfUsedVotes, elections[_elecID].cands[_candidateID].id);
    }

    function getCandidateCount(uint _elecID) public view returns (uint) {
		return elections[_elecID].candidates.length;
    }

	// function getCandidateVoteCount(uint _elecID, bytes32 _candidateName) public view returns(uint) {
	// 	return elections[_elecID].cands[_candidateName];
	// 	return elections[_elecID].candidates[_candidateID].voteCount;
	// }
}