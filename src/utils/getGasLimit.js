const axios = require('axios')

// FIXME: Remove 'x' suffix in URL.
let getCurrentGasPrices = axios.get('https://ethgasstation.info/json/ethgasAPI.json')
    .then((response) => {
        console.log('response:', response.data);
        let prices = {
            low: response.data.safeLow / 10,
            medium: response.data.average / 10,
            high: response.data.fast / 10,
        }

        console.log("\n");
        console.log(`__Current ETH Gas Prices (in GWEI)__`);
        console.log("\n");
        console.log(`Low: ${prices.low} (transaction completes in < 30 minutes)`);
        console.log(`Standard: ${prices.medium} (transaction completes in < 5 minutes)`);
        console.log(`Fast: ${prices.high} (transaction completes in < 2 minutes)`);
        console.log("\n");

        return prices;
    })
    .catch(function (_, reject) {
        reject('[ethGasStation INFO] -> ' + error.message);
    });

getCurrentGasPrices.then(result => {
        console.log('Function completed successfuly.\n');
    })
    .catch(error => {
        console.log('An error occured !?!?')
    });

// const getCurrentGasPrices = new Promise(function(resolve, reject) {
//     let response = axios.get('https://ethgasstation.info/json/ethgasAPIx.json')
//                     .catch(function(error) {
//                         return reject('An error occured while getting current gas prices. [ethGasStation INFO] ->');
//                     });
//     resolve(response);
//     // (response !== undefined) ? resolve(response) : reject('Response is undefined [ethGasStation]')
// }).then(response => {
//     console.log('response then:', response.data);
//     let prices = {
//         low: response.data.safeLow / 10,
//         medium: response.data.average / 10,
//         high: response.data.fast / 10
//     }

//     console.log("\r\n")
//     console.log(`__Current ETH Gas Prices (in GWEI)__`)
//     console.log("\r\n")
//     console.log(`Low: ${prices.low} (transaction completes in < 30 minutes)`)
//     console.log(`Standard: ${prices.medium} (transaction completes in < 5 minutes)`)
//     console.log(`Fast: ${prices.high} (transaction completes in < 2 minutes)`)
//     console.log("\r\n")

//     return prices;
// });

// getCurrentGasPrices.then((result) => {
//     console.log('Sonuc:', result)
// });