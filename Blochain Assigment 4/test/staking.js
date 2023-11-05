const { expect } = require("chai");

describe("Staking Contract", function () {

    let Staking;
    let staking;
    let owner;
    let addr1;
    let addr2;
    let addrs;

    beforeEach(async function () {
        Staking = await ethers.getContractFactory("Staking");
        [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
        staking = await Staking.deploy(604800, 1000000);  // Assume 1 week staking period and 1 million total rewards for simplicity
    });

    describe("Deployment", function () {
        it("Should set the right owner", async function () {
            expect(await staking.owner()).to.equal(owner.address);
        });

        it("Should assign the total rewards and staking period", async function () {
            expect(await staking.totalRewards()).to.equal(1000000);
            expect(await staking.stakingPeriod()).to.equal(604800);
        });
    });

    describe("Transactions", function () {
        it("Should allow users to deposit", async function () {
            await staking.connect(addr1).deposit(100);
            expect(await staking.userBalances(addr1.address)).to.equal(100);
        });

        it("Should allow users to stake", async function () {
            await staking.connect(addr1).deposit(100);
            await staking.connect(addr1).stake(100);
            expect(await staking.stakedBalances(addr1.address)).to.equal(100);
        });

        it("Should not allow users to stake more than they have", async function () {
            await staking.connect(addr1).deposit(100);
            await expect(staking.connect(addr1).stake(200)).to.be.revertedWith("Insufficient balance");
        });

        it("Should allow users to withdraw after staking period", async function () {
            await staking.connect(addr1).deposit(100);
            await staking.connect(addr1).stake(100);
            await ethers.provider.send("evm_increaseTime", [605000])  // Increase time by just over a week
            await ethers.provider.send("evm_mine")  // Mine the next block
            await staking.connect(addr1).withdraw();
            expect(await staking.userBalances(addr1.address)).to.be.gt(100);  // Expecting a reward as well
        });
    });
});
