<template>
  <section class="hero is-fullheight is-turquoise is-bold">
    
    <!-- Navbar -->
    <Navbar />

    <!-- Hero content: will be in the middle -->
    <IndexLogoBody />

  </section>
</template>

<script>
  import Navbar from './Navbar.vue'
  import IndexLogoBody from './IndexLogoBody.vue'

  export default {
    name: 'welcome',
    components: {
      Navbar, IndexLogoBody
    }    
  }
</script>


<!-- styling for the component -->
<style scoped>
  .is-turquoise {
    background-color: #00d1b2;
  }

  /* @import url(https://fonts.googleapis.com/css?family=Open+Sans:800); */
  /* Main styles */

  /* .text {
  fill: none;
  stroke-width: 3;
  stroke-linejoin: round;
  stroke-dasharray: 70 330;
  stroke-dashoffset: 0;
  -webkit-animation: stroke 6s infinite linear;
  animation: stroke 6s infinite linear;
} */
  /* .text:nth-child(5n + 1) { */
  /* stroke: #332244; */
  /* stroke: #f2385a;
  -webkit-animation-delay: -1.2s;
  animation-delay: -1.2s;
} */
  /* .text:nth-child(5n + 2) {
  stroke: #f5a503;
  -webkit-animation-delay: -2.4s;
  animation-delay: -2.4s;
}
.text:nth-child(5n + 3) {
  stroke: #e9f1df;
  -webkit-animation-delay: -3.6s;
  animation-delay: -3.6s;
}
.text:nth-child(5n + 4) {
  stroke: #004fff;
  -webkit-animation-delay: -4.8s;
  animation-delay: -4.8s;
}
.text:nth-child(5n + 5) {
  stroke: #111; */
  /* stroke: #3aa1bf; */
  /* -webkit-animation-delay: -6s;
  animation-delay: -6s;
}
@-webkit-keyframes stroke {
  100% {
    stroke-dashoffset: -400;
  }
}
@keyframes stroke {
  100% {
    stroke-dashoffset: -400;
  }
} */
  /* Other styles */
  /* html, body {
  height: 100%;
}
body {
  background: #00D1B2; */
  /* background: #111; */
  /* background-size: 0.2em 100%;
  font: 8em Open Sans, Impact; */
  /* text-transform: uppercase; */
  /* margin: 0;
} */
  /* svg {
  position: absolute;
  width: 100%;
  height: 100%;
} */
</style>