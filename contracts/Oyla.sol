pragma solidity ^0.5.0;

contract Oyla {
    uint8 constant MAX_ELECTION_COUNT = 50;
    uint electionCount = 0;

    struct Election {
        uint id;
        string  name;
        uint    candidateCount;
        uint    voterCount;
        uint    numOfUsedVotes;
        address organizer;
        bool    initialized;

        // uint `key` represents candidateID
        mapping (uint => Candidate) candidates;
    }

    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }

    mapping (uint => Election) elections;

    modifier isOrganizerOfElec(uint _elecID) {
        require(msg.sender == elections[_elecID].organizer, "Auth error: Only organizer could do that");
        _;
    }

    modifier checkElectionCount() {
        require(electionCount <= MAX_ELECTION_COUNT, "You have reached maximum election count");
        _;
    }

    modifier isElecExists(uint _elecID) {
        require(elections[_elecID].initialized == true, "There is no election with that _elecID");
        _;
    }

    modifier isElecNotExists(uint _elecID) {
        require(elections[_elecID].initialized == false, "Election is already initialized");
        _;
    }

    modifier checkVoterCount(uint _elecID) {
        require(elections[_elecID].numOfUsedVotes < elections[_elecID].voterCount, "All of the voters have voted");
        _;
    }

    // [FIXED] WARNING: You can create an election with same ID.
    // It checks whether electionCount is less than `10` or not before creating an election.
    function createElection(string memory _name, uint _candidateCount, uint _voterCount)
        public checkElectionCount isElecNotExists(electionCount) returns (uint)
    {
        address organizer = msg.sender;
        uint _electionID = electionCount;

        elections[_electionID] = Election(_electionID, _name, _candidateCount, _voterCount, 0, organizer, true);
        electionCount++;

        return  _electionID;
    }

    // uint _candidateID argument removed
    function addCandidate(uint _elecID, string memory _name) public isElecExists(_elecID) isOrganizerOfElec(_elecID) {
        elections[_elecID].candidates[elections[_elecID].candidateCount] = Candidate(elections[_elecID].candidateCount, _name, 0);
        elections[_elecID].candidateCount++;
        // Candidate memory cand = Candidate(_candidateID, _name, 0);
        // Election storage election = elections[_elecID];
        // election.candidates[_candidateID] = cand;
    }

    function vote(uint _elecID, uint _candidateID) public isElecExists(_elecID) checkVoterCount(_elecID) {
        elections[_elecID].candidates[_candidateID].voteCount++;
        elections[_elecID].numOfUsedVotes++;
    }

    function getCandidateVoteCount(uint _elecID, uint _candidateID) public view returns (uint) {
        return elections[_elecID].candidates[_candidateID].voteCount;
    }

    function getCandidateName(uint _elecID, uint _candidateID) public view returns (string memory) {
        return elections[_elecID].candidates[_candidateID].name;
    }

    function getGreeting() public pure returns (string memory) {
        return "Hey MC!!!";
    }
}