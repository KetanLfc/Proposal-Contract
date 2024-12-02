// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract ProposalContract {

    address public owner;
    uint256 private counter; // Counter to keep track of proposal IDs

    struct Proposal {
        string title; // Title of the proposal for easier identification
        string description; // Description of the proposal
        uint256 approve; // Number of approve votes
        uint256 reject; // Number of reject votes
        uint256 pass; // Number of pass votes
        uint256 total_vote_to_end; // When the total votes in the proposal reaches this limit, proposal ends
        bool current_state; // This shows the current state of the proposal, meaning whether it passes or fails
        bool is_active; // This shows if others can vote on our contract
    }

    mapping(uint256 => Proposal) private proposal_history; // Recordings of previous proposals
    address[] private voted_addresses;

    constructor() {
        owner = msg.sender;
        voted_addresses.push(msg.sender); // Owner is automatically marked as voted
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier active() {
        require(proposal_history[counter].is_active == true, "The proposal is not active");
        _;
    }

    modifier newVoter(address _address) {
        require(!isVoted(_address), "Address has already voted");
        _;
    }

    // Set a new owner
    function setOwner(address new_owner) external onlyOwner {
        owner = new_owner;
    }

    // Create a new proposal
    function create(string calldata _title, string calldata _description, uint256 _total_vote_to_end) external onlyOwner {
        counter += 1;
        proposal_history[counter] = Proposal(
            _title,
            _description,
            0, // Initial approve votes
            0, // Initial reject votes
            0, // Initial pass votes
            _total_vote_to_end,
            false, // Initial state is pending
            true // Proposal starts as active
        );
    }

    // Cast a vote (choice: 1 = approve, 2 = reject, 0 = pass)
    function vote(uint8 choice) external active newVoter(msg.sender) {
        Proposal storage proposal = proposal_history[counter];
        uint256 total_votes = proposal.approve + proposal.reject + proposal.pass;

        voted_addresses.push(msg.sender);

        if (choice == 1) {
            proposal.approve += 1;
        } else if (choice == 2) {
            proposal.reject += 1;
        } else if (choice == 0) {
            proposal.pass += 1;
        } else {
            revert("Invalid vote choice");
        }

        proposal.current_state = calculateCurrentState();

        if (total_votes + 1 >= proposal.total_vote_to_end) {
            proposal.is_active = false;
            resetVoters();
        }
    }

    // Terminate the current proposal
    function terminateProposal() external onlyOwner active {
        proposal_history[counter].is_active = false;
    }

    // Calculate the current state of the proposal
    function calculateCurrentState() private view returns (bool) {
        Proposal storage proposal = proposal_history[counter];

        uint256 approve = proposal.approve;
        uint256 reject = proposal.reject;
        uint256 pass = proposal.pass;

        // Adjust pass votes (50% weight)
        if (pass % 2 == 1) {
            pass += 1; // Make pass even if odd
        }
        pass /= 2;

        // Approve wins if it exceeds reject + weighted pass votes
        return approve > (reject + pass);
    }

    // Check if an address has already voted
    function isVoted(address _address) public view returns (bool) {
        for (uint256 i = 0; i < voted_addresses.length; i++) {
            if (voted_addresses[i] == _address) {
                return true;
            }
        }
        return false;
    }

    // Reset the voted addresses (for next proposal)
    function resetVoters() private {
        delete voted_addresses;
        voted_addresses.push(owner); // Owner is always marked as voted
    }

    // Get the current proposal
    function getCurrentProposal() external view returns (Proposal memory) {
        return proposal_history[counter];
    }

    // Get a specific proposal by ID
    function getProposal(uint256 number) external view returns (Proposal memory) {
        require(number <= counter, "Proposal does not exist");
        return proposal_history[number];
    }
}
