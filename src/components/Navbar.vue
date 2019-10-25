<template>
	<nav class="navbar is-turquoise" role="navigation" aria-label="main navigation" style="z-index: auto;">
		<div class="navbar-brand">
			<a href="/" v-bind:style="{display: isLogoActive}">
				<p>{{ isLogoActive }}<p>
						<figure class="level-item image" style="width: 130px; height: 50px;">
							<img src="../../static/img/navbar_logo.png">
						</figure>
			</a>

			<a role="button" class="navbar-burger burger" @click="showNav = !showNav;" :class="{ 'is-active': showNav }"
				aria-label="menu" aria-expanded="false" data-target="navbarBasicExample">
				<span aria-hidden="true"></span>
				<span aria-hidden="true"></span>
				<span aria-hidden="true"></span>
			</a>
		</div>

		<div class="navbar-menu" :class="{ 'is-active': showNav }">
			<div class="navbar-end">
				<div class="navbar-item" style="margin-left:17%;">
					<div class="buttons">
						<b-button tag="a" href="/" type="is-primary" inverted>
							<b-icon pack="fab" icon="codepen" size="is-small" />
							<span>Home</span>
						</b-button>
						<b-button tag="a" href="/create" type="is-primary" inverted>
							<b-icon pack="fab" icon="gg" size="is-small" />
							<span>Create an Election</span>
						</b-button>
					</div>
				</div>
			</div>
		</div>
	</nav>
</template>

<script>
	export default {
		name: 'Navbar',
		data: function () {
			return {
				showNav: false,
			}
		},
		props: {
			isLogoActive: String
		}
	}
</script>

<style scoped>

</style>