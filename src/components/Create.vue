<template>
	<div>
		<section class="is-fullheight is-turquoise" style="min-height:100vh;">
			<!-- Navbar -->
			<Navbar isLogoActive="none" />
			<SidebarMenu width='280px' :menu="menu" collapsed />

			<div class="container">
				<!-- style="justify-content: center;" -->
				<div class="columns is-mobile is-multiline">
					<div class="column is-2">
					</div>
					<div class="column is-10">
						<div class="columns is-mobile">
							<div class="column is-6">
								<b-field label="TITLE">
									<b-input v-model="electionTitle" pack="fas" icon="quote-left" type="text" maxlength="30"></b-input>
								</b-field>
							</div>
						</div>

						<div class="form-group" v-for="(cand, index) in candidates" :key="index">
							<b-field label="Candidate">
								<div class="columns is-mobile is-multiline">
									<div class="column is-6">
										<b-input type="text" value="" maxlength="30" v-model="cand.name" icon-pack="far" icon="user">
										</b-input>
									</div>
									<div class="column is-2">
										<b-button v-if="candidates.length > 2" v-on:click="removeCandidate(index)" type="is-danger" rounded>
											<b-icon pack="fas" icon="minus" size="is-small" />
										</b-button>
									</div>
								</div>
							</b-field>
						</div>

						<div class="columns">
							<div class="column is-3">
								<div class="buttons" style="margin-top:5px;">
									<!-- style="justify-content: center;" -->
									<b-button v-on:click="addCandidate()" type="is-warning" rounded>
										<b-icon pack="fas" icon="plus" size="is-small" />
										<!-- <span>Add Candidate</span> -->
									</b-button>
								</div>
							</div>
							<div class="column is-3">
								<b-field label="Voter Count">
									<b-numberinput v-model="voterCount" controls-position="compact" type="is-warning"
										:min="candidates.length" controls-rounded>
									</b-numberinput>
								</b-field>
							</div>
						</div>

						<b-field label="Start date">
							<div class="columns">
								<div class="column is-3" style="overflow: visible;">
									<b-datepicker :placeholder="startDatePlaceholder" pack="far" icon="calendar-alt"
										:disabled="startAfterLaunch" :first-day-of-week=1 position="is-top-right" :min-date="yesterday"
										v-model="startingDate">
									</b-datepicker>
								</div>
								<div class="column is-3">
									<b-clockpicker :placeholder="startingTimePlaceholder" v-model="startingTime" pack="far"
										:disabled="startAfterLaunch" icon="clock" :hour-format="'24'" position="is-top-right"
										ref="startClockPicker" :readonly="false" :min-time="getMinTimeForStartingTime">

										<b-button type="is-danger" size="is-small" v-on:click="startingTime = null" rounded>
											<b-icon pack="fas" icon="broom"></b-icon>
											<span>Clear</span>
										</b-button>
									</b-clockpicker>
								</div>

								<div class="column is-4" style="margin-top:8px;">
									<div class="field">
										<b-checkbox v-model="startAfterLaunch" :value="true" type="is-warning">
											Start after launch
										</b-checkbox>
									</div>
								</div>
							</div>
						</b-field>

						<b-field label="End date">
							<div class="columns">
								<div class="column is-3" style="overflow: visible;">
									<b-datepicker v-model="endingDate" placeholder="Click to select..." pack="far" icon="calendar-alt"
										:first-day-of-week=1 position="is-top-right" :min-date="getMinDateForEndingDate">
									</b-datepicker>
								</div>
								<div class="column is-3">
									<b-clockpicker v-model="endingTime" pack="far" icon="clock" placeholder="Click to select..."
										:hour-format="'24'" :min-time="getMinTimeForEndingTime" position="is-top-right"
										ref="endClockPicker">

										<b-button size="is-small" type="is-danger" v-on:click="endingTime = null" rounded>
											<b-icon pack="fas" icon="broom"></b-icon>
											<span>Clear</span>
										</b-button>
									</b-clockpicker>
								</div>
							</div>
						</b-field>

						<div class="columns is-mobile is-multiline">
							<div class="column is-6">
								<div class="buttons" style="justify-content: center;">
									<b-button type="is-primary" size="is-medium" v-on:click="start()" inverted>
										<span>Start</span>
									</b-button>
								</div>
							</div>
						</div>
						<!-- <ResultChart /> -->
					</div>
				</div>

			</div>
		</section>
	</div>
</template>

<script>
	import Navbar from './Navbar.vue'
	import Result from './Result.vue'
	import {
		SidebarMenu
	} from 'vue-sidebar-menu'
	import 'vue-sidebar-menu/dist/vue-sidebar-menu.css'
	import moment from 'moment'
	import jspdf from 'jspdf'
	import qr from 'qr-image'

	import Tx from 'ethereumjs-tx'
	import keythereum from 'keythereum'
	import * as ethUtil from 'ethereumjs-util'

	import getWeb3 from '../utils/getWeb3'
	import DenemelerContract from '../../build/contracts/Denemeler.json'
	import { setInterval } from 'timers';
	// import VueSidebarMenu from 'vue-sidebar-menu'

	export default {
		name: "create",
		components: {
			Navbar,
			SidebarMenu,
		},
		data() {
			return {
				candidates: [{
					id: 0,
					name: ''
				}, {
					id: 1,
					name: ''
				}],
				menu: [{
						header: true,
						title: 'OYLA.',
						// component: componentName
						// visibleOnCollapse: true
						// class:''
						// attributes: {}
					},
					{ // item
						href: '/create',
						title: 'Create an Election',
						icon: 'fas fa-plus-circle',
					},
					{ // item
						href: '/vote',
						title: 'Vote',
						icon: 'fas fa-person-booth',
					},
					{ // item with child
						href: '/result',
						title: 'Results',
						icon: 'fas fa-chart-pie',
					},
				],
				startingDate: null, // Helps to disable dates before current day.
				startingTime: null, // default: `now`
				endingDate: null,
				endingTime: null,
				startingUnixTime: 0,
				endingUnixTime: 0,
				yesterday: this.getYesterdayTime(),
				startDatePlaceholder: 'Click to select...',
				startingTimePlaceholder: 'Click to select...',
				startAfterLaunch: false,
				contractABI: DenemelerContract.abi,
				contractInstance: null,
				oylaWeb3: null,
				voterCount: 2,
				electionTitle: '',
				voters: [],
				candList: [],
				privKeys: [],
				pubKeys: [],
				electionId: '',
			}
		},
		methods: {
			handleCandidates() {
				this.candidates.map((cand, index) => {
					cand.id = index;
				})
			},
			addCandidate() {
				this.candidates.push({
					id: '',
					name: '',
				});
				this.handleCandidates();
				// this.printCandidates();
			},
			removeCandidate(index) {
				this.candidates.splice(index, 1);
				this.handleCandidates();
				// this.printCandidates();
			},
			printCandidates() {
				this.candidates.forEach(element => {
					console.log('id: ' + element.id + ' | name: ' + element.name);
				});
			},
			getYesterdayTime() {
				return new Date(Date.now() - 86400000);
			},
			pushNewElectionRoute(path) {
				console.log("Path:" + path);
				this.$router.push({
					path: `results/${path}`,
					component: Result
				});
			},
			instantiateContract() {
				this.contractInstance = new this.oylaWeb3.eth.Contract(this.contractABI, '0x45B6552eB5bD7C93609B814ad0Ff27081c1500B5');
			},
			handleCandidateNames() {
				for (let i = 0; i < this.candidates.length; i++) {
					this.candList.push(this.oylaWeb3.utils.fromAscii(this.candidates[i].name));
				}
				console.log('Hex Cand List:', this.candList);
			},
			handleElectionDates() {
				let endDate = moment(this.endingDate).format("DD-MM-YYYY");
				let endTime = moment(this.endingTime).format("HH:mm");

				this.endingUnixTime = moment(endDate + " " + endTime, "DD-MM-YYYY HH:mm").unix();

				if (this.startAfterLaunch) {
					console.log('> Election starting date is initiliazed at the moment unix time. [StartAfterLaunch]')
					this.startingUnixTime = moment().unix();
				} else {
					let startDate = moment(this.startingDate).format("DD-MM-YYYY");
					let startTime = moment(this.startingTime).format("HH:mm");

					this.startingUnixTime = moment(startDate + " " + startTime, "DD-MM-YYYY HH:mm").unix();
				}
			},
			generateKeyPairs() {
				for (let i = 0; i < this.voterCount; i++) {
					let key = keythereum.create(); // Generate  private key
					let privKey = key.privateKey.toString('hex'); // Convert it to Hex
					this.privKeys.push(privKey);

					// console.log(`[${i}] Private Key: ` + privKey);

					let pubKey = ethUtil.privateToPublic(Buffer.from(key.privateKey, 'hex')); // Generate public key from private key
					let publicAddr = '0x' + ethUtil.publicToAddress(pubKey).toString('hex'); // Transform public key to public address
					this.pubKeys.push(publicAddr);

					// console.log(`[${i}] Public Address: ` + publicAddr);
					this.voters.push(publicAddr);
				}
				console.log("Voters adresses:", this.voters);
			},
			generateQRFile() {
				let QR_arr = [];

				for (let i = 0; i < this.voterCount; i++) {
					let data = {
						address: this.privKeys[i],
						electionId: this.electionId,
						candidates: this.candidates,
					}

					QR_arr.push(qr.imageSync(JSON.stringify(data).toString('base64'), {
						type: 'png',
						margin: 8
					}));
				}

				var pdfDocument = new jspdf('p', 'mm', 'a4');
				var posX = 0;
				var posY = 0;
				var size = 70;
				var paperX = 210;
				var paperY = 297;

				for (let i = 0; i < this.voterCount; i++) {
					pdfDocument.addImage(QR_arr[i], 'PNG', posX, posY, size, size, "qr" + i);
					posX += size;
					if (posX >= paperX) { // Next line
						posX = 0;
						posY += size;
					}
					if (posY >= paperY - size) { // Next page
						pdfDocument.addPage();
						posX = 0;
						posY = 0;
					}
				}

				pdfDocument.save("voter_list.pdf");
			},
			start() {
				// Convert dates to unix timestamp to pass time in an appropriate way t
				this.handleElectionDates();

				// Then generate public and private key addresses for each voter.
				this.generateKeyPairs();
				let tempNonce;
				this.$swal({
						title: 'Successfully created an election',
						icon: "success",
						closeOnClickOutside: false,
					})
					.then((swal) => {
						getWeb3.then(data => {
								this.oylaWeb3 = data;
							})
							.then(() => {
								this.handleCandidateNames();
								this.instantiateContract();
							})
							.then(() => {
								console.log('Starting unix time:', this.startingUnixTime);
								console.log('Ending unix time:', this.endingUnixTime);
								this.oylaWeb3.eth.getTransactionCount('0x64B15665779A8D85D79ac81ec71E4985D61dc606', (err,
									txCount) => {
									if (err) {
										console.log('[CreateElection] An error occured:', err.message);
										return;
									}
										tempNonce = txCount;

									// Build the transaction
									const txObject = {
										// nonce is basically that account's transaction count. It helps to prevent double-spending problem
										nonce: this.oylaWeb3.utils.toHex(txCount),
										gasLimit: this.oylaWeb3.utils.toHex(1000000),
										gasPrice: this.oylaWeb3.utils.toHex(this.oylaWeb3.utils.toWei('10', 'gwei')), // web3.utils.toHex(web3.eth.getGasPrice()),
										to: '0x45B6552eB5bD7C93609B814ad0Ff27081c1500B5', // Contract adress or public adress
										data: this.contractInstance.methods.createElection(
											this.electionTitle, this.candList, this.voters, this.voterCount, this.startingUnixTime, this.endingUnixTime
										).encodeABI(),
									}

									// Sign
									const tx = new Tx(txObject); // FIXME: Hard coded private key is not secure
									let bufferPK = Buffer.from('<INSERT PRIVATE KEY HERE>', 'hex');
									tx.sign(bufferPK);

									const serializeTx = tx.serialize();
									const raw = '0x' + serializeTx.toString('hex');

									this.oylaWeb3.eth.sendSignedTransaction(raw, (err, txHash) => {
										if (err) {
											console.log("SendSignedTransaction -> Error:", err.message)
										} else {
											console.log('txHash:', txHash);
											this.contractInstance.methods.getNextElectionId().call()
											.then(result => {
												this.electionId = Number(result.toString());
												console.log('Election ID --->>>', this.electionId );
											})
											.then(() => {
												this.generateQRFile();							
											})
											.catch(error => console.log('An error occured while getting Election ID:', error));
										}
									});
								});								
							})
							.then(() => {				

								// let alacaklilar = ['0x0740f3E914A877ABccF871Ce3d57D3Dad936cF6D', '0x32223dBAbb761cAbD033C2370560d078693C44A3']

								// FIXME: Uncomment below here!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1
								this.oylaWeb3.eth.getTransactionCount('0x64B15665779A8D85D79ac81ec71E4985D61dc606', (err, txCount) => {
									if (err) {
										console.log('[SendEtherToVoters] An error occured:', err.message);
										return;
									}
									console.log('Voter length:', this.voters.length);
									for (let i = 0; i < this.voters.length; i++) {
										// Build the transaction
										const txObject = {
											// nonce is basically that account's transaction count. It helps to prevent double-spending problem
											nonce: 		this.oylaWeb3.utils.toHex(++tempNonce), 
											// FIXME: We have nonce conflicts when multiple transactions are broadcasted before confirmation of the other.

											to: 			this.voters[i], // Contract adress or public adress
											gasLimit: this.oylaWeb3.utils.toHex(1000000),
											gasPrice: this.oylaWeb3.utils.toHex(this.oylaWeb3.utils.toWei('10','gwei')), // web3.utils.toHex(web3.eth.getGasPrice()),
											value:		this.oylaWeb3.utils.toHex(this.oylaWeb3.utils.toWei('0.01', 'ether')),
										}

										// Sign
										const tx = new Tx(txObject); // FIXME: Hard coded private key is not secure
										let bufferPK = Buffer.from('<INSERT PRIVATE KEY HERE>', 'hex');
										tx.sign(bufferPK);

										const serializeTx = tx.serialize();
										const raw = '0x' + serializeTx.toString('hex');

										this.oylaWeb3.eth.sendSignedTransaction(raw, (err, txHash) => {
											if (err) {
												console.log("SendSignedTransaction -> Error:", err.message)
											} else {
												console.log('txHash:', txHash);
											}
										});
									}
								});
							})
							.catch(error => {
								console.log('getWeb3 call error:', error);
							});
					})
					.catch(err => {
						this.$swal({
							title: 'Oops! An error occured',
							text: `Errors info: ${err}`,
							icon: "error",
						});
					});
			},			
		},
		computed: {
			getMinTimeForStartingTime: function () {
				// If selected starting date is TODAY so limit min. time to `now` else `null`.
				return (moment(this.startingDate).isSame(moment(), 'day')) ? new Date() : null;
			},
			getMinDateForEndingDate: function () {
				return (this.startingDate == null) ? new Date() : this.startingDate;
			},
			getMinTimeForEndingTime: function () {
				return (moment(this.startingDate).isSame(this.endingDate, 'day')) ? this.startingTime : null;
			},
		}
	}
</script>

<style scoped>
	.is-turquoise {
		background-color: #00d1b2;
	}
</style>