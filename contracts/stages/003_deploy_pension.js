const interestRate5PCnominators = require('../../web-app/src/math/interestRate5PCnominators');
const lifeTable = require('../../web-app/src/math/germanLifeTable1994');

module.exports = async ({ accounts, initialRun, deploy, getDeployedContract, sendTxAndWait }) => {
    const deployer = accounts[0];
    const gas = 3000000;
    const contractName = 'Pension';

    const eligibilityOracle = getDeployedContract('AlwaysEligibleUnlessDead');
    const deployResult = await deploy(
        contractName,
        { from: deployer, gas },
        contractName,
        lifeTable, interestRate5PCnominators, eligibilityOracle.address
    );

    if (initialRun) {
        console.log(contractName + ' deployed used  ' + deployResult.receipt.gasUsed.toString() + ' gas');
    }

    await sendTxAndWait({ from: deployer, gas }, contractName, 'init');
};
