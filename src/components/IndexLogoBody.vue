<template>
  <div class="hero-body">
    <div class="container">
      <div class="is-flex" style="justify-content: center;"> 
        <figure style="width:32%; height: 32%;">
          <img src="../../static/img/logo_transparent.png">
        </figure>
      </div>
      <div class="is-flex" style="justify-content: center;">
        <div class="buttons">
          <b-button tag="a" href="/create" type="is-warning"  rounded>
            <b-icon pack="fas" icon="angle-right" size="is-small" />
            <span>Get started.</span>
          </b-button>
        </div>
      </div>                
    </div>
  </div>

</template>

<script>
  export default {
    name: 'index-logo-body',
  }
</script>
<!-- styling for the component -->
<style>
  /* #about {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  
  color: #2c3e50;
  margin-top: 60px;
} */
</style>