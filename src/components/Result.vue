<template>
	<div>
		<section class="is-fullheight is-turquoise" style="min-height:100vh;">
			<!-- Navbar -->
			<Navbar isLogoActive="none" />
			<div class="container">

				<!-- style="justify-content: center;" -->
				<div class="columns is-mobile is-multiline">
					<div class="column is-2">
						<SidebarMenu width='320px' :menu="menu" collapsed />
					</div>
					<div class="column is-10">
						<div class="column is-12" style="position: relative;left: 1%;">
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
										
									</div>
								</div>
							</article>
							<h1 class="title">{{ title }}</h1>
						</div>
						<div class="column is-12">
							<div class="columns">
								<div class="column is-6" style="position: relative;left: 1%;">
								
								</div>

								<br>
							</div>
						</div>
						<div class="column">
							<div class="column is-16">
								<b-table :data="isEmpty ? [] : data">
									<template slot-scope="props">
										<b-table-column field="first_name" label="Aday">
											{{ props.row.first_name }}
											<br>
											<br>
											<p style="font-size:70%">
												Oy Sayısı:{{props.row.oy}}
											</p>
											<div :class="
                            [
                                'tag',
                                {'is-danger': 10 /3 <= 0.45},
                                {'is-success': 10 / 2 > 0.45}
                            ]" style="height:10px" v-bind:style="{width:props.row.date+'%'}">

											</div>
											<br>
										</b-table-column>
										<b-table-column field="gender" label="Sonuç" centered>
											<div style=" font-size:300%">
												%{{ props.row.date}}
											</div>
										</b-table-column>
									</template>
								</b-table>




							</div>
						</div>




					</div>
				</div>

			</div>
		</section>
	</div>
</template>

<script>
	import Navbar from './Navbar.vue'
	import deneme2 from '../main.js'
	import getWeb3 from '../utils/getWeb3.js'
	import SampleContract from '../../build/contracts/Denemeler.json'
	//import SampleContract from './build/contracts/Sample.json'
	import {
		SidebarMenu
	} from 'vue-sidebar-menu'
	// import VueSidebarMenu from 'vue-sidebar-menu'
	import 'vue-sidebar-menu/dist/vue-sidebar-menu.css'
	import {
		QrcodeStream,
		QrcodeDropZone,
		QrcodeCapture
	} from 'vue-qrcode-reader'

	var a = "bs"
	export default {	
		name: "result",
		methods: {
			greet: function (event) {
				// getWeb3.then(data=>{
				//     console.log("burda çalıştı");
				//     this.oylaWeb3 = data
				//     let sampleContract = this.oylaWeb3.eth.Contract(this.contractABI,'0x26DAb41686B41F7c41bE5A524B3a5eE087f1BA5F')
				//          sampleContract.methods.get().call()
				//             .then(result => alert(result))
				//             .catch(error => console.log('An error occured! --> ' + error));
				// })
				// `this` inside methods points to the Vue instance
				// var oWeb3=this.oylaWeb3
				//   getWeb3.then = new Promise (function(result) {

				//        oWeb3=result

				//       // let sampleContract = this.oylaWeb3.eth.Contract(contractABI, '0x26DAb41686B41F7c41bE5A524B3a5eE087f1BA5F');
				//         alert(oWeb3)
				//     //    sampleContract.methods.get().call()
				//     //         .then(result => console.log('Sonuç: ' + result))
				//     //         .catch(error => console.log('An error occured! --> ' + error));
				//   })

				//let contractABI= SampleContract.abi;
				//let sampleContract = this.oylaWeb3.eth.Contract(contractABI,'0x26DAb41686B41F7c41bE5A524B3a5eE087f1BA5F');

				//   sampleContract.methods.get().call()
				//         .then(result => alert('Sonuç: ' + result))
				//         .catch(error => alert('An error occured! --> ' + error));

			},
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

				// this.privAddr = qrContent.address;
				// this.privToPublicAddr(this.privAddr);
				this.electionId = qrContent.electionId;
				// this.candidates = qrContent.candidates;
				// console.log('Candidates:', this.candidates);

				await this.timeout(2200);
				// this.isValid = content.startsWith('http');


				this.$dialog.alert({
					title: 'Scan was succesful.',
					message: 'You can see results below.',
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

				getWeb3.then(data => {

				var count = 0
				this.oylaWeb3 = data
				var sayac = 0
				var j = 0

				this.instantiateContract();

				let sampleContract = this.oylaWeb3.eth.Contract(this.contractABI, '0x45B6552eB5bD7C93609B814ad0Ff27081c1500B5')
				sampleContract.methods.getCandidateCount(this.electionId).call()
					.then(result => {
						var votes = []
						for (var i = 0; i < result; i++) {
							console.log("ilk" + i)

							sampleContract.methods.getCandidateName(this.electionId, i).call()
								.then(result => {
									console.log(result[1] + "=" + result[0])
									var element = {};
									element.first_name = this.oylaWeb3.utils.toAscii(result[0]);
									element.date = (result[1] / result[2]) * 100;
									element.gender = 'male'
									element.oy = result[1]

									this.data.push(element)

								})

								.catch(error => console.log('An error occured! --> ' + error));

						} //for kapanış
					})
					.catch(error => console.log('An error occured! --> ' + error));

			})

				// if (this.isValid) {
				// 	this.$dialog.alert({
				// 		title: 'Successful.',
				// 		message: 'Voting transaction was <b>successful</b>.',
				// 		type: 'is-success',
				// 		hasIcon: true,
				// 		icon: 'check',
				// 		iconPack: 'fas',
				// 		onConfirm: () => this.$toast.open('Your voting has been recorded to the blockchain.')
				// 	});
				// } else {
				// 	this.$dialog.alert({
				// 		title: 'Error',
				// 		message: 'Oops! Please scan eligible QR or try again.',
				// 		type: 'is-danger',
				// 		hasIcon: true,
				// 		icon: 'times-circle',
				// 		iconPack: 'fa'
				// 	});
				// }

				this.turnCameraOn();
			},

			instantiateContract() {
				this.contractInstance = new this.oylaWeb3.eth.Contract(this.contractABI, '0x45B6552eB5bD7C93609B814ad0Ff27081c1500B5');
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
		},
		name: "election",
		components: {
			Navbar,
			getWeb3,
			SidebarMenu,
			QrcodeStream,
			QrcodeDropZone,
			QrcodeCapture,
		},
		data() {
			const data = [

			]
			return {
				title: "Results",
				camera: 'auto',
				isValid: undefined,
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
				contractABI: SampleContract.abi,
				oylaWeb3: null,
				genislik: 700,
				data,
				electionId: null,
				selected: data[1],
				columns: [

					{
						field: 'first_name',
						label: 'Aday',
					},


					{
						field: 'gender',
						label: 'Aldığı Oy Oranı',


					}
				]
			}
		},
		created() {
			//   var element = {}
			//   var count=0
			//   element.id = 4
			//   element.first_name = 'osman'
			//   element.oy='1000'
			//   element.date='80'
			//   element.gender='male'
			//   this.data.push(element);
			
			//console.log('propertyComputed will update, as this.property is now reactive.')
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
	}
</script>

<style scoped>
	.is-turquoise {
		background-color: #09f0cd;
	}

	.title {
		color: red;
	}
</style>