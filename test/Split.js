const { expect } = require("chai");
const { ethers } = require("hardhat");
const { getBigNumber } = require("./utils");

describe("Split contract", async function () {
  let Split;
  let hardhatSplit;
  let owner;
  let addr1 = "0x047425f8d784dcc6d73df12bc6eeca3aa51f4fb2";
  let addr2 = "0x522eb82b8394f1abc499be2b986b79feaf7e451e";

  before(async function () {
    Split = await ethers.getContractFactory("Split");
    [owner] = await ethers.getSigners();
    hardhatSplit = await Split.deploy();
    await hardhatSplit.deployed();
    console.log("deployed address: ", hardhatSplit.address);
  });

  it("Should set the right owner", async function () {
    expect(await hardhatSplit.owner()).to.equal(owner.address);
  });
  
  it("Should add share amounts for the accounts", async function () {
    await hardhatSplit.addToList(addr1, 30);
    await hardhatSplit.addToList(addr2, 70);
  });

  it("Should deposite and split share amounts", async function () {
    await hardhatSplit.deposit({value: getBigNumber(1)});
    bal1 = await hardhatSplit.balance(addr1);
    bal2 = await hardhatSplit.balance(addr2);
    console.log("balance of ", addr1, ": ", bal1);
    console.log("balance of ", addr2, ": ", bal2);
  });

  it("Withdraw addr1 right now", async function () {
    bal1 = await hardhatSplit.balance(addr1);
    console.log("balance of ", addr1, ": ", bal1);
    await hardhatSplit.testWithdraw(addr1);
    bal1 = await hardhatSplit.balance(addr1);
    console.log("balance of ", addr1, ": ", bal1);
  });

  it("Withdraw addr2 5 seconds after", async function () {
    await new Promise(r => setTimeout(r, 5000));
    bal2 = await hardhatSplit.balance(addr2);
    console.log("balance of ", addr2, ": ", bal2);
    await hardhatSplit.testWithdraw(addr2);
    bal2 = await hardhatSplit.balance(addr2);
    console.log("balance of ", addr2, ": ", bal2);
  });
});