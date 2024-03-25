const { expect } = require("chai");

describe('WGovernance', function () {

    let wGovernance;
    let workHub; 

    beforeEach(async function () {
        const WorkHub = await ethers.getContractFactory('WorkHub');
        const WGovernance = await ethers.getContractFactory('WGovernance');

        workHub = await WorkHub.deploy();
        wGovernance = await WGovernance.deploy(
            workHub.target,
            { value: ethers.parseEther("0.0001") }
        );
    })
    

    it('Should join the Governance and emit an event', async function () {

        expect(await wGovernance.joinGovernance(
            {value: ethers.parseEther("0.0001")}
        )).to.emit(wGovernance.newMemberJoined);
    });

    it('Should join and  leave the governance', async function () {
        
        expect(await wGovernance.joinGovernance(
            {value: ethers.parseEther("0.0001")}
        )).to.emit(wGovernance.newMemberJoined);

        console.log("Joined Governance... Proceeding to leave")
        
        expect(await wGovernance.leaveGovernance()
        ).to.emit(wGovernance.memberLeaved);
    });

    it('Should create a Proposal', async function () {

        // Join in the governance
        expect(await wGovernance.joinGovernance(
            {value: ethers.parseEther("0.0001")}
        )).to.emit(wGovernance.newMemberJoined);
        
        // Define the parameters for the proposal
        const proposalType = "FeeUpdate"; // ProposalType.MemberRem
        const votingPeriod = 86400; // 1 day in seconds
        const memberRem = ''; // Replace with the address to be removed
        const feeUpdate = 1; // fee update
        const stkUpdate = 0; // stake update
        const categUpdate = ''; // category update
        const skillUpdate = ''; // skill update

        // Check if the event was emitted
        await expect(await wGovernance.createProposal(
            proposalType,
            votingPeriod,
            memberRem,
            feeUpdate,
            stkUpdate,
            categUpdate,
            skillUpdate
        )).to.emit(wGovernance.proposalCreated);
    });


});
