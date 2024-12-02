// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract ProposalContract {
    
uint256 private counter; // Counter to keep track of proposal IDs

    struct Proposal {
        string title; // Title of the proposal for easier identification
        string description; // Description of the proposal
        uint256 approve; // Number of approve votes
        uint256 reject; // Number of reject votes
        uint256 pass; // Number of pass votes
        uint256 total_vote_to_end; // When the total votes in the proposal reaches this limit, proposal ends
        bool current_state; // This shows the current state of the proposal, meaning whether if passes of fails
        bool is_active; // This shows if others can vote to our contract
}

mapping(uint256 => Proposal) proposal_history; // Recordings of previous proposals

// Function to create a new proposal
    function create(string calldata _title, string calldata _description, uint256 _total_vote_to_end) external {
        counter += 1; // Increment the proposal ID counter
        proposal_history[counter] = Proposal(
            _title, // Set the title
            _description, // Set the description
            0, // Initialize approve votes to 0
            0, // Initialize reject votes to 0
            0, // Initialize pass votes to 0
            _total_vote_to_end, // Set the vote limit
            false, // Initialize current state as false (pending)
            true // Mark the proposal as active
        );
    }

}