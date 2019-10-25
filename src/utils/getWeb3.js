import Web3 from 'web3'

let getWeb3 = new Promise(function (resolve, reject) {
    window.addEventListener('load', function() {
        // Check for injected web3 (mist/metamask)
        var web3js = window.web3;
        var web3;
        if (typeof web3js !== 'undefined') {
            // var web3 = new Web3(web3js.currentProvider);
            reject('You should disable Metamask/Mist');
        } else {
            web3 = new Web3(new Web3.providers.HttpProvider("https://ropsten.infura.io/v3/1d6a7f1c8bed4cec8f6f05d0f83f481e"));
            // web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
            resolve(web3);
        }
    });
})

export default getWeb3