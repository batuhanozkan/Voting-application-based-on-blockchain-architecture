<template>
	<div>
		<section class="is-fullheight is-turquoise" style="min-height:100vh;">
			<!-- Navbar -->
			<Navbar isLogoActive="none" />

			<!-- style="justify-content: center;" -->
			<div class="container" style="display: flex; justify-content: center; align-items: center;">
				<div class="columns is-mobile is-multiline">
					<div class="column is-1">
						<SidebarMenu width='280px' :menu="menu" collapsed />
					</div>
					<div class="column is-11 box" style="margin-top: 14px;">
						<article class="media">
							<div class="media-content" style="overflow-x: hidden; text-align: center;">
								<div style="width: 380px; margin-right:10px;">
									<p class="decode-result"><b>Scan QR to vote.</b></p>

									<qrcode-stream :camera="camera" @decode="onDecode" @init="onInit">
										<div v-if="validationSuccess" class="validation-success">
											Voting transaction was successful.
										</div>

										<div v-if="validationFailure" class="validation-failure">
											Oops! An error occured.
										</div>

										<div v-if="validationPending" class="validation-pending">
											Validation in progress...
										</div>
									</qrcode-stream>

									<!-- <p class="decode-result">Last result: <b>{{ result }}</b></p> -->
									<br>
									<b-field label="Candidates">
										<b-select placeholder="Select a candidate" icon="user" icon-pack="fas" v-model="selectedCandidate"
											expanded>
											<option v-for="cand in candidates" :key="cand.id" :value="cand">{{ cand.name }}</option>
										</b-select>
									</b-field>
									<b-button type="is-primary" v-on:click="vote()">
										<b-icon pack="fas" icon="person-booth" size="is-small" />
										<span>Vote</span>
									</b-button>
								</div>
							</div>
						</article>
					</div>
				</div>
			</div>
		</section>
	</div>
</template>

<script>
	import Navbar from './Navbar.vue'
	import {
		QrcodeStream,
		QrcodeDropZone,
		QrcodeCapture
	} from 'vue-qrcode-reader'
	import {
		SidebarMenu
	} from 'vue-sidebar-menu'
	import 'vue-sidebar-menu/dist/vue-sidebar-menu.css'

	import Tx from 'ethereumjs-tx'
	import getWeb3 from '../utils/getWeb3'
	import * as ethUtil from 'ethereumjs-util'
	import DenemelerContract from '../../build/contracts/Denemeler.json'

	export default {
		name: "election",
		components: {
			Navbar,
			SidebarMenu,
			QrcodeStream,
			QrcodeDropZone,
			QrcodeCapture,
		},
		data() {
			return {
				isValid: undefined,
				camera: 'auto',
				result: null,
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
				contractInstance: null,
				contractABI: DenemelerContract.abi,
				oylaWeb3: null,
				privAddr: '',
				publicAddress: '',
				candidates: [],
				selectedCandidate: null,
				electionId: null,
			}
		},
		methods: {
			onInit(promise) {
				promise
					.catch(console.error)
					.then(this.resetValidationState);
			},

			resetValidationState() {
				this.isValid = undefined;
			},

			async onDecode(content) {
				this.result = content;
				this.turnCameraOff();

				console.log('Content içeriği:', content);

				let qrContent = JSON.parse(content)

				this.privAddr = qrContent.address;
				this.privToPublicAddr(this.privAddr);
				this.electionId = qrContent.electionId;
				this.candidates = qrContent.candidates;
				console.log('Candidates:', this.candidates);

				await this.timeout(2200);
				// this.isValid = content.startsWith('http');

				this.instantiateContract();

				this.$dialog.alert({
					title: 'Scan was succesful.',
					message: 'Please <b>select</b> a candidate to vote.',
					type: 'is-success',
					hasIcon: true,
					icon: 'check',
					iconPack: 'fas',
					onConfirm: () => {
						// this.isQRHidden = 'none';
						// this.isVotingHidden = '';
					} //this.$toast.open('Your voting has been recorded to the blockchain.')
				});

				// some more delay, so users have time to read the message
				await this.timeout(2000);

				if (this.isValid) {
					this.$dialog.alert({
						title: 'Successful.',
						message: 'Voting transaction was <b>successful</b>.',
						type: 'is-success',
						hasIcon: true,
						icon: 'check',
						iconPack: 'fas',
						onConfirm: () => this.$toast.open('Your voting has been recorded to the blockchain.')
					});
				} else {
					this.$dialog.alert({
						title: 'Error',
						message: 'Oops! Please scan eligible QR or try again.',
						type: 'is-danger',
						hasIcon: true,
						icon: 'times-circle',
						iconPack: 'fa'
					});
				}

				this.turnCameraOn();
			},

			turnCameraOn() {
				this.camera = 'auto';
			},

			turnCameraOff() {
				this.camera = 'off';
			},

			timeout(ms) {
				return new Promise(resolve => {
					window.setTimeout(resolve, ms);
				})
			},

			instantiateContract() {
				this.contractInstance = new this.oylaWeb3.eth.Contract(this.contractABI, '0x45B6552eB5bD7C93609B814ad0Ff27081c1500B5');
			},

			privToPublicAddr(addr) {
				console.log('privToPublicAddr parameter:', addr);
				let pubKey = ethUtil.privateToPublic(Buffer.from(addr, 'hex'));
				this.publicAddress = '0x' + ethUtil.publicToAddress(pubKey).toString('hex');
			},

			vote() {
				console.log('INFO BEFORE TX --> elecID: ' + this.electionId + ' | selctdCandName: ' + this.selectedCandidate.name + ' | PubAddr: ' + this.publicAddress)

				this.oylaWeb3.eth.getTransactionCount(this.publicAddress, (err, txCount) => {
					if (err) {
						console.log('[VoteInAnElection] An error occured:', err.message);
						this.isValid = false;
						return;
					}

					// Build the transaction
					const txObject = {
						// nonce is basically that account's transaction count. It helps to prevent double-spending problem
						nonce: this.oylaWeb3.utils.toHex(txCount),
						gasLimit: this.oylaWeb3.utils.toHex(100000),
						gasPrice: this.oylaWeb3.utils.toHex(this.oylaWeb3.utils.toWei('21', 'gwei')), // web3.utils.toHex(web3.eth.getGasPrice()),
						to: '0x45B6552eB5bD7C93609B814ad0Ff27081c1500B5', // Contract adress or public adress
						data: this.contractInstance.methods.vote(this.electionId, this.selectedCandidate.id, this.publicAddress).encodeABI(),
					}
					
					console.log('Before signing PRIVKEY:', this.privAddr);
					// Sign
					const tx = new Tx(txObject); // FIXME: Hard coded private key is not secure
					let bufferPK = Buffer.from(this.privAddr, 'hex');
					tx.sign(bufferPK);

					const serializeTx = tx.serialize();
					const raw = '0x' + serializeTx.toString('hex');

					this.oylaWeb3.eth.sendSignedTransaction(raw, (err, txHash) => {
						if (err) {
							console.log("SendSignedTransaction -> Error:", err.message)
							this.isValid = false;
						} else {
							console.log('txHash:', txHash);
							this.isValid = true;
						}
					});
				});
			},
		},
		computed: {
			validationPending() {
				return this.isValid === undefined && this.camera === 'off';
			},

			validationSuccess() {
				return this.isValid === true;
			},

			validationFailure() {
				return this.isValid === false;
			}
		},
		created() {
			getWeb3.then(data => {
				console.log('Web3 bağlandı.');
				this.oylaWeb3 = data;
			});
		}
	}
</script>

<style scoped>
	.is-turquoise {
		background-color: #09f0cd;
	}

	.center-items {
		display: flex;
		justify-content: center;
		align-items: center;
	}

	.validation-success,
	.validation-failure,
	.validation-pending {
		position: absolute;
		width: 100%;
		height: 100%;

		background-color: rgba(255, 255, 255, .8);
		text-align: center;
		font-weight: bold;
		font-size: 1.4rem;
		padding: 10px;

		display: flex;
		flex-flow: column nowrap;
		justify-content: center;
	}

	.validation-success {
		color: green;
	}

	.validation-failure {
		color: red;
	}
</style>