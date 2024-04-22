// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.19;

// const fs = require("fs");

// var DHelper = function(_deployer, _network, _accounts){
//   if (!(this instanceof DHelper)) {
//     return new DHelper(_deployer, _network, _accounts)
//   }

//   var deployer = _deployer;
//   var network = _network;
//   var accounts = _accounts;

//   var file_path = "contract_info.json";

//   this.readOrCreateContract = async function(contract, libraries, ...args) {
//     const data = JSON.parse(fs.readFileSync(file_path, 'utf-8').toString());
//     if(network.includes("main") || network.includes("ropsten")){
//       address = data["main"][contract._json.contractName]
//       if(address){
//         console.log("Using exised contract ", contract.name, " at ", address)
//         return await contract.at(address)
//       }
//     }

//     if(typeof libraries !== 'undefined' && libraries !== null){
//       for(let lib of libraries ){
//         if(network.includes("main")){
//           var r= {};
//           r.contract_name = lib._json.contractName;
//           address = data["main"][lib._json.contractName]
//           r.address = address
//           if(typeof address !== 'undefined' && address !== null){
// 	          lib.networks["1"] = {"address":address}
// 	          console.log('address is: ', address);
//           }
// 	        await deployer.link(lib, contract);
// 	        console.log("linked ", r.contract_name, ":", r.address, " to ", contract._json.contractName);
//         }else{
//           await deployer.link(lib, contract)
//         }
//       }
//     }
//     await deployer.deploy(contract, ...args);
//     return await contract.deployed();
//   }

// }
// const StepRecorder = function(_network, _filename){
//   if (!(this instanceof StepRecorder)) {
//     return new StepRecorder(_network, _filename)
//   }

//   var network = _network;
//   var filename = _filename;

//   var get_filename = function(){
//     if(filename.endsWith(".json")){
//       return network + '-' + filename;
//     }
//     return network + "-" + filename + ".json";
//   }

//   this.write = function(key, value){
//     common = {}
//     if(fs.existsSync(get_filename())){
//       const data = fs.readFileSync(get_filename(), 'utf-8');
//       common = JSON.parse(data.toString());
//     }
//     if(typeof common[network] ==='undefined'){
//       common[network] = {}
//     }

//     common[network][key] = value;

//     const wd = JSON.stringify(common);
//     fs.writeFileSync(get_filename(), wd);
//   }

//   this.read = function(key){
//     const data = fs.readFileSync(get_filename(), 'utf-8');
//     const common = JSON.parse(data.toString());
//     return common[network][key];
//   }

//   this.exist = function(key){
//     const data = fs.readFileSync(get_filename(), 'utf-8');
//     const common = JSON.parse(data.toString());
//     return key in common[network];
//   }
//   this.foreach = function(func){
//     const data = fs.readFileSync(get_filename(), 'utf-8');
//     const common = JSON.parse(data.toString());
//     for(var key in common[network]){
//       func(key, common[network][key]);
//     }
//   }
//   this.value = function(key){
//     return this.read(key);
//   }
// }

// module.exports = {DHelper, StepRecorder }